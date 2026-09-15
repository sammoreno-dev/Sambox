#!/usr/bin/env bash
# ============================================================================
# BSD 2-Clause License (Simplified)
#
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
#
# Módulo: System — Limpeza e Manutenção
# Função: purge_system_bloat
#
# Varre e limpa caches de pacotes (apt/zypper/pacman), logs antigos
# compactados e limpa com segurança o cache de RAM não utilizado
# no kernel (drop_caches).
#

purge_system_bloat() {
    _sep
    printf "  ${BOLD}${CYAN}🧹  Purge System Bloat${RST}\n\n"

    # ── Verificação de root ─────────────────────────────────────────────────
    if [[ "${EUID}" -ne 0 ]]; then
        _warn "Algumas operações requerem privilégios de root."
        _warn "Execute: sudo sambox"
        printf "\n"
    fi

    # ── 1. Limpeza de cache do gerenciador de pacotes ───────────────────────
    printf "  ${BOLD}[1/3] Cache do gerenciador de pacotes${RST}\n"

    if command -v apt-get &>/dev/null; then
        _msg "Detectado: APT (Debian/Ubuntu)"
        if [[ "${EUID}" -eq 0 ]]; then
            apt-get clean -y 2>/dev/null && _msg "apt cache limpo."
            apt-get autoremove -y 2>/dev/null && _msg "Pacotes órfãos removidos."
        else
            _warn "Pule (requer root): apt-get clean / autoremove"
        fi
    elif command -v zypper &>/dev/null; then
        _msg "Detectado: Zypper (openSUSE/SLES)"
        if [[ "${EUID}" -eq 0 ]]; then
            zypper clean --all 2>/dev/null && _msg "zypper cache limpo."
        else
            _warn "Pule (requer root): zypper clean"
        fi
    elif command -v pacman &>/dev/null; then
        _msg "Detectado: Pacman (Arch)"
        if [[ "${EUID}" -eq 0 ]]; then
            pacman -Scc --noconfirm 2>/dev/null && _msg "pacman cache limpo."
        else
            _warn "Pule (requer root): pacman -Scc"
        fi
    else
        _warn "Gerenciador de pacotes não reconhecido. Pulando."
    fi

    printf "\n"

    # ── 2. Logs antigos compactados ─────────────────────────────────────────
    printf "  ${BOLD}[2/3] Logs antigos compactados${RST}\n"

    local log_count=0
    local log_bytes=0

    while IFS= read -r -d '' logfile; do
        local fsize
        fsize="$(stat -c '%s' "${logfile}" 2>/dev/null || echo 0)"
        log_bytes=$(( log_bytes + fsize ))
        log_count=$(( log_count + 1 ))
        if [[ "${EUID}" -eq 0 ]]; then
            rm -f "${logfile}"
        fi
    done < <(find /var/log -type f \( -name '*.gz' -o -name '*.old' -o -name '*.xz' \) -print0 2>/dev/null)

    local log_mb=$(( log_bytes / 1024 / 1024 ))

    if [[ "${log_count}" -gt 0 ]]; then
        if [[ "${EUID}" -eq 0 ]]; then
            _msg "Removidos ${log_count} arquivo(s) de log antigo (≈${log_mb}MB liberados)."
        else
            _warn "Encontrados ${log_count} arquivo(s) de log antigo (≈${log_mb}MB). Requer root para remover."
        fi
    else
        _msg "Nenhum log antigo compactado encontrado."
    fi

    printf "\n"

    # ── 3. Drop caches do kernel (seguro) ───────────────────────────────────
    printf "  ${BOLD}[3/3] Cache de RAM do kernel (drop_caches)${RST}\n"

    if [[ "${EUID}" -eq 0 ]]; then
        # sync antes de dropar para evitar perda de dados
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null \
            && _msg "Page cache, dentries e inodes liberados." \
            || _err "Falha ao dropar caches do kernel."
    else
        _warn "Requer root: echo 3 > /proc/sys/vm/drop_caches"
    fi

    _sep
}
