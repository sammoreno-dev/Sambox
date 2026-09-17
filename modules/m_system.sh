#!/usr/bin/env bash
# ============================================================================
# Sambox - Módulo de Otimização, Limpeza e Manutenção do Sistema
# BSD 2-Clause License (Simplified)
# Copyright (c) 2026, Sam Moreno
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# ============================================================================

# [1] Limpeza Profunda de Pacotes APT e Configurações Residiais (rc)
clean_apt_and_residuals() {
    printf "\n${YELLOW}[+]${RST} Limpando repositórios, cache do APT e pacotes órfãos...\n"
    export DEBIAN_FRONTEND=noninteractive

    if command -v apt-get &>/dev/null; then
        sudo apt-get clean -y
        sudo apt-get autoclean -y
        sudo apt-get autoremove --purge -y

        # Elimina arquivos de configuração residuais de pacotes desinstalados (estado 'rc')
        local rc_packages
        rc_packages=$(dpkg -l | grep '^rc' | awk '{print $2}' || true)
        if [[ -n "${rc_packages}" ]]; then
            printf "${YELLOW}[+]${RST} Removendo configurações residuais de pacotes antigos...\n"
            # ShellCheck directive to allow unquoted expansion for multi-package purge
            # shellcheck disable=SC2086
            sudo dpkg --purge ${rc_packages} 2>/dev/null || true
            _msg "Configurações residuais expurgadas do dpkg."
        fi
        _msg "Base de pacotes APT totalmente higienizada."
    else
        _err "APT não encontrado no sistema."
    fi
}

# [2] Truncamento de Logs Rotacionados e Limpeza do Journald
clean_system_logs() {
    printf "\n${YELLOW}[+]${RST} Executando limpeza do Journald e remoção de logs mortos...\n"

    # Trunca o log do Systemd para no máximo 50MB
    if command -v journalctl &>/dev/null; then
        sudo journalctl --vacuum-size=50M 2>/dev/null || true
        _msg "Journald truncado para o limite de segurança de 50MB."
    fi

    local log_count=0
    local log_bytes=0

    # Varredura direta via find para eliminação de arquivos comprimidos e rotacionados
    while IFS= read -r -d '' logfile; do
        local fsize
        fsize="$(stat -c '%s' "${logfile}" 2>/dev/null || echo 0)"
        log_bytes=$(( log_bytes + fsize ))
        log_count=$(( log_count + 1 ))
        sudo rm -f "${logfile}"
    done < <(find /var/log -type f \( -name '*.gz' -o -name '*.old' -o -name '*.xz' -o -name '*.1' \) -print0 2>/dev/null)

    local log_mb=$(( log_bytes / 1024 / 1024 ))

    if [[ "${log_count}" -gt 0 ]]; then
        _msg "${log_count} arquivo(s) de log rotacionado(s) removido(s) (≈${log_mb}MB liberados)."
    else
        _msg "Nenhum resíduo de log rotacionado encontrado em /var/log."
    fi
}

# [3] Limpeza de Caches de Usuário, Coredumps e Arquivos Temporários
clean_user_cache_and_tmp() {
    printf "\n${YELLOW}[+]${RST} Limpando miniaturas (thumbnails), coredumps e caches temporários...\n"

    # Limpeza do cache de miniaturas do usuário atual e de todos em /home
    sudo find /home/*/.cache/thumbnails -type f -atime +7 -delete 2>/dev/null || true
    rm -rf "${HOME}/.cache/thumbnails/"* 2>/dev/null || true

    # Limpeza de Crash Dumps do Systemd
    if [[ -d /var/lib/systemd/coredump ]]; then
        sudo rm -rf /var/lib/systemd/coredump/* 2>/dev/null || true
        _msg "Coredumps do systemd limpos."
    fi

    # Remove arquivos temporários mais antigos que 3 dias
    sudo find /tmp -mindepth 1 -atime +3 -delete 2>/dev/null || true
    sudo find /var/tmp -mindepth 1 -atime +3 -delete 2>/dev/null || true

    _msg "Caches temporários e thumbnails purgados."
}

# [4] Liberação de RAM (drop_caches) e Reciclagem da SWAP
free_ram_and_swap() {
    printf "\n${YELLOW}[+]${RST} Sincronizando sistema de arquivos e liberando memória RAM...\n"

    sync
    if echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1; then
        _msg "PageCache, dentries e inodes liberados no Kernel."
    else
        _err "Falha ao gravar em /proc/sys/vm/drop_caches."
    fi

    # Verifica se há SWAP ativa e realiza a reciclagem para renovar os blocos
    if swapon --show | grep -q '/'; then
        printf "${YELLOW}[+]${RST} Reciclando partição/arquivo SWAP...\n"
        sudo swapoff -a && sudo swapon -a 2>/dev/null || true
        _msg "Memória SWAP reciclada com sucesso."
    fi
}

# [5] Rotina Automatizada Completa (Purge System Bloat)
purge_system_bloat() {
    _sep
    printf "  ${BOLD}${CYAN}🧹  Purge System Bloat — Manutenção Geral (Debian)${RST}\n\n"

    clean_apt_and_residuals
    clean_system_logs
    clean_user_cache_and_tmp
    free_ram_and_swap

    _sep
    _msg "Manutenção preventiva concluída com sucesso!"
}

# ── Função Orquestradora do Módulo de Otimização de Sistema ────────────────
menu_system_central() {
    local sys_menu
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║    🛠️   MANUTENÇÃO E OTIMIZAÇÃO SYSTEM     ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  🚀  Executar Limpeza Completa Automatizada (Bloat Purge)\n"
        printf "  ${CYAN}[2]${RST}  📦  Limpar Caches do APT e Configurações Residiais (rc)\n"
        printf "  ${CYAN}[3]${RST}  📄  Truncar Systemd Journald & Deletar Logs Antigos\n"
        printf "  ${CYAN}[4]${RST}  🗑️   Limpar Caches de Usuário, Thumbnails e Dumps em /tmp\n"
        printf "  ${CYAN}[5]${RST}  ⚡  Forçar Liberação de RAM (drop_caches) e Reciclar SWAP\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-5]:$(printf "${RST}") " sys_menu

        case "${sys_menu}" in
            1) purge_system_bloat ;;
            2) clean_apt_and_residuals ;;
            3) clean_system_logs ;;
            4) clean_user_cache_and_tmp ;;
            5) free_ram_and_swap ;;
            0) break ;;
            *) _warn "Opção inválida no menu de sistema." ;;
        esac

        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}
