#!/usr/bin/env bash
# ============================================================================
# BSD 2-Clause License (Simplified)
#
# Copyright (c) 2026, Sam Moreno
# All rights reserved.
# ============================================================================
#
# Módulo: System — Limpeza e Manutenção
# Função: purge_system_bloat
#
# Focado exclusivamente no ecossistema Debian. Varre e purga caches do APT,
# deleta logs antigos rotacionados e força o drop seguro de caches de RAM.
#

purge_system_bloat() {
    _sep
    printf "  ${BOLD}${CYAN}🧹  Purge System Bloat (Debian Engine)${RST}\n\n"

    # ── Verificação de root ─────────────────────────────────────────────────
    if [[ "${EUID}" -ne 0 ]]; then
        _warn "Esta central de manutenção requer privilégios de root."
        _warn "Execute o motor principal: sudo sambox"
        _sep
        return 1
    fi

    # ── 1. Limpeza Profunda do APT ──────────────────────────────────────────
    printf "  ${BOLD}[1/3] Limpeza do Gerenciador de Pacotes (APT)${RST}\n"
    
    if command -v apt-get &>/dev/null; then
        _msg "Purgando arquivos residuais do repositório..."
        apt-get clean -y 2>/dev/null
        apt-get autoclean -y 2>/dev/null && _msg "Caches de pacotes obsoletos limpos."
        apt-get autoremove --purge -y 2>/dev/null && _msg "Pacotes órfãos e arquivos de configuração purgados."
    else
        _err "APT não encontrado. Este módulo é exclusivo para sistemas baseados em Debian."
    fi

    printf "\n"

    # ── 2. Eliminação de Logs Rotacionados e Ociosos ────────────────────────
    printf "  ${BOLD}[2/3] Remoção de Logs Antigos Compactados${RST}\n"

    local log_count=0
    local log_bytes=0

    # Varredura direta e sem fricção via subshel do find
    while IFS= read -r -d '' logfile; do
        local fsize
        fsize="$(stat -c '%s' "${logfile}" 2>/dev/null || echo 0)"
        log_bytes=$(( log_bytes + fsize ))
        log_count=$(( log_count + 1 ))
        rm -f "${logfile}"
    done < <(find /var/log -type f \( -name '*.gz' -o -name '*.old' -o -name '*.xz' -o -name '*.1' \) -print0 2>/dev/null)

    local log_mb=$(( log_bytes / 1024 / 1024 ))

    if [[ "${log_count}" -gt 0 ]]; then
        _msg "Sucesso: ${log_count} arquivo(s) de log morto deletado (≈${log_mb}MB liberados)."
    else
        _msg "Nenhum resíduo de log antigo encontrado no sistema."
    fi

    printf "\n"

    # ── 3. Drop Caches de RAM do Kernel (Performance Bruta) ─────────────────
    printf "  ${BOLD}[3/3] Liberação Espelhada de RAM (drop_caches)${RST}\n"

    # Sincroniza o sistema de arquivos antes do drop para garantir total segurança
    sync
    if echo 3 > /proc/sys/vm/drop_caches 2>/dev/null; then
        _msg "Page cache, dentries e inodes limpos com sucesso direto no Kernel."
    else
        _err "Falha crítica ao tentar comunicar com /proc/sys/vm/drop_caches."
    fi

    _sep
}
