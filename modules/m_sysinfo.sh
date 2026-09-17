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
# Módulo: System Info & Auditoria de Código (Source Dump)
# Função Orquestradora: show_system_info
#

# ── Helper Interno de Sanitize / Trim ───────────────────────────────────────
_sys_trim() {
    local str="$1"
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "${str}"
}

# ── Menu Principal / Orquestrador do Módulo ─────────────────────────────────
show_system_info() {
    local sys_opt
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║        ℹ️   SISTEMA & AUDITORIA            ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        
        # Renderiza a visão geral rápida do sistema
        _sysinfo_dashboard
        
        printf "  ${BOLD}OPÇÕES DE ANÁLISE & AUDITORIA${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  🧩  Inspetor Detalhado de Hardware & Virtualização\n"
        printf "  ${CYAN}[2]${RST}  ⚡  Processos em Foco (Top Consumidores CPU/RAM)\n"
        printf "  ${CYAN}[3]${RST}  📝  Consolidar Source Dump Localmente (/tmp)\n"
        printf "  ${CYAN}[4]${RST}  🚀  Exportar Source Dump para Nuvem (Link Seguro)\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-4]:$(printf "${RST}") " sys_opt

        case "${sys_opt}" in
            1) _hardware_inspect ;;
            2) _top_processes ;;
            3) _generate_source_dump "local" ;;
            4) _generate_source_dump "cloud" ;;
            0) break ;;
            *) _warn "Opção inválida." ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Dashboard de Visão Geral do Sistema ─────────────────────────────────────
_sysinfo_dashboard() {
    local hostname kernel_version os_name uptime_raw shell_ver disk_usage load_avg
    hostname="$(hostname)"
    kernel_version="$(uname -r)"
    shell_ver="${BASH_VERSION}"

    # Captura da Distribuição Linux
    if [[ -f /etc/os-release ]]; then
        os_name="$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
    else
        os_name="Linux / POSIX Generic"
    fi

    uptime_raw="$(uptime -p 2>/dev/null | sed 's/up //' || echo 'N/A')"

    # Métricas de Memória RAM e Swap (/proc/meminfo)
    local mem_t_kb mem_a_kb mem_u_mb mem_t_mb swap_t_kb swap_f_kb swap_u_mb swap_t_mb
    mem_t_kb="$(grep -E '^MemTotal:' /proc/meminfo | awk '{print $2}')"
    mem_a_kb="$(grep -E '^MemAvailable:' /proc/meminfo | awk '{print $2}')"
    mem_t_mb=$(( mem_t_kb / 1024 ))
    mem_u_mb=$(( (mem_t_kb - mem_a_kb) / 1024 ))

    swap_t_kb="$(grep -E '^SwapTotal:' /proc/meminfo | awk '{print $2}')"
    swap_f_kb="$(grep -E '^SwapFree:' /proc/meminfo | awk '{print $2}')"
    swap_t_mb=$(( swap_t_kb / 1024 ))
    swap_u_mb=$(( (swap_t_kb - swap_f_kb) / 1024 ))

    # Load Average
    load_avg="$(awk '{print $1 ", " $2 ", " $3}' /proc/loadavg 2>/dev/null || echo 'N/A')"

    # Uso do Disco Principal
    disk_usage="$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"

    # Temperatura da CPU (se disponível via sysfs)
    local temp_c="N/A"
    if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
        local raw_temp
        raw_temp="$(< /sys/class/thermal/thermal_zone0/temp)"
        temp_c="$(( raw_temp / 1000 ))°C"
    fi

    printf "  ${BOLD}Resumo Geral do Sistema:${RST}\n"
    _sep
    printf "  • ${BOLD}Host:${RST} %-22s • ${BOLD}OS:${RST} %s\n" "${hostname}" "${os_name}"
    printf "  • ${BOLD}Kernel:${RST} %-20s • ${BOLD}Bash:${RST} %s\n" "${kernel_version}" "${shell_ver}"
    printf "  • ${BOLD}Uptime:${RST} %-20s • ${BOLD}Carga (1/5/15m):${RST} %s\n" "${uptime_raw}" "${load_avg}"
    _sep
    printf "  • ${BOLD}RAM Usada:${RST} %s MB / %s MB   • ${BOLD}Swap Usada:${RST} %s MB / %s MB\n" "${mem_u_mb}" "${mem_t_mb}" "${swap_u_mb}" "${swap_t_mb}"
    printf "  • ${BOLD}Disco (/):${RST} %-20s • ${BOLD}Temp CPU:${RST} %s\n" "${disk_usage}" "${temp_c}"
    _sep
    printf "\n"
}

# ── Inspetor de Hardware & Ambientes Virtuais ──────────────────────────────
_hardware_inspect() {
    clear 2>/dev/null || true
    _sep
    printf "  ${BOLD}${CYAN}🧩  Inspetor de Hardware & Virtualização${RST}\n"
    _sep

    # CPU & Núcleos
    local cpu_model cores threads arch
    cpu_model="$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 || true)"
    cpu_model="$(_sys_trim "${cpu_model:-Processador Desconhecido}")"
    cores="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo '1')"
    arch="$(uname -m)"

    printf "  ${BOLD}Processador (CPU):${RST}\n"
    printf "  • Modelo: %s\n" "${cpu_model}"
    printf "  • Arquitetura: %s (%s núcleos/vCPUs)\n\n" "${arch}" "${cores}"

    # Detecção de Ambiente (Virtualização / Container / Bare-Metal)
    printf "  ${BOLD}Plataforma & Virtualização:${RST}\n"
    local virt_type="Bare-Metal (Físico)"

    if [[ -f /.dockerenv ]]; then
        virt_type="Container Docker"
    elif [[ -f /run/systemd/container ]]; then
        virt_type="Container LXC/Systemd"
    elif command -v systemd-detect-virt &>/dev/null; then
        local detected
        detected="$(systemd-detect-virt 2>/dev/null || true)"
        if [[ -n "${detected}" && "${detected}" != "none" ]]; then
            virt_type="Máquina Virtual (${detected^^})"
        fi
    fi
    printf "  • Tipo de Ambiente: ${CYAN}%s${RST}\n\n" "${virt_type}"

    # Processador Gráfico (GPU)
    printf "  ${BOLD}Placa Gráfica (GPU):${RST}\n"
    if command -v lspci &>/dev/null; then
        local gpu_info
        gpu_info="$(lspci | grep -iE 'vga|3d|display' || true)"
        if [[ -n "${gpu_info}" ]]; then
            printf "%s\n" "${gpu_info}" | sed 's/^/  • /'
        else
            printf "  • Nenhuma GPU PCI discreta detectada.\n"
        fi
    else
        printf "  • lspci não disponível para verificação de GPU.\n"
    fi
    _sep
}

# ── Monitor de Processos em Foco (Top CPU / RAM) ─────────────────────────────
_top_processes() {
    clear 2>/dev/null || true
    _sep
    printf "  ${BOLD}${CYAN}⚡  Top 5 Processos Consumidores de Recursos${RST}\n"
    _sep

    printf "  ${BOLD}🔥 Maior Consumo de CPU:  ${RST}\n"
    printf "  %-8s  %-8s  %-8s  %s\n" "PID" "%CPU" "%MEM" "COMANDO"
    _sep
    ps -eo pid,%cpu,%mem,comm --sort=-%cpu | head -n 6 | tail -n 5 | awk '{
        printf "  %-8s  %-8s  %-8s  %s\n", $1, $2, $3, $4
    }'
    printf "\n"

    printf "  ${BOLD}🧠 Maior Consumo de RAM:${RST}\n"
    printf "  %-8s  %-8s  %-8s  %s\n" "PID" "%MEM" "%CPU" "COMANDO"
    _sep
    ps -eo pid,%mem,%cpu,comm --sort=-%mem | head -n 6 | tail -n 5 | awk '{
        printf "  %-8s  %-8s  %-8s  %s\n", $1, $2, $3, $4
    }'
    _sep
}

# ── Geração e Exportação de Dump do Código-Fonte ────────────────────────────
_generate_source_dump() {
    local mode="$1"
    local output_file="/tmp/sambox_source_dump.txt"
    
    printf "\n${YELLOW}[+]${RST} Consolidador de Código Sambox iniciado...\n"

    # Cabeçalho do arquivo com termos legais e de auditoria
    {
        echo "=========================================================================="
        echo " SAMBOX SOFTWARE AUDIT - CONSOLIDATED SOURCE DUMP"
        echo " Generated on: $(date)"
        echo " Host: $(hostname) | Kernel: $(uname -r)"
        echo " Copyright (c) 2026, Sam Moreno. All rights reserved."
        echo " License: BSD 2-Clause License (Simplified)"
        echo "=========================================================================="
        printf "\n\n"

        echo "=== [ENTRYPOINT] sambox ==="
        cat "${SAMBOX_DIR:-.}/sambox" 2>/dev/null || echo "Erro ao ler entrypoint principal."
        printf "\n\n"
    } > "${output_file}"

    # Consolidação dinâmica dos módulos em modules/
    local mod_dir="${MODULES_DIR:-${SAMBOX_DIR:-.}/modules}"
    if [[ -d "${mod_dir}" ]]; then
        local mod
        for mod in "${mod_dir}"/*.sh; do
            if [[ -f "${mod}" ]]; then
                {
                    echo "=== [MODULE] $(basename "${mod}") ==="
                    cat "${mod}"
                    printf "\n\n"
                } >> "${output_file}"
            fi
        done
    fi

    # Cálculo do Hash SHA-256 de integridade
    local dump_hash="N/A"
    if command -v sha256sum &>/dev/null; then
        dump_hash="$(sha256sum "${output_file}" | awk '{print $1}')"
    fi

    if [[ "${mode}" == "local" ]]; then
        _msg "Código-fonte consolidado com sucesso para auditoria local!"
        printf "    • Arquivo: ${CYAN}${BOLD}%s${RST}\n" "${output_file}"
        printf "    • SHA-256: ${DIM}%s${RST}\n" "${dump_hash}"

    elif [[ "${mode}" == "cloud" ]]; then
        printf "${YELLOW}[+]${RST} Enviando dump para servidor de compartilhamento em nuvem...\n"
        
        local upload_url=""
        
        # Tentativa 1: 0x0.st
        if command -v curl &>/dev/null; then
            upload_url="$(curl -s --max-time 10 -F "file=@${output_file}" https://0x0.st 2>/dev/null || true)"
            
            # Fallback Tentativa 2: paste.rs se 0x0.st falhar
            if [[ -z "${upload_url}" ]]; then
                upload_url="$(curl -s --max-time 10 --data-binary "@${output_file}" https://paste.rs 2>/dev/null || true)"
            fi
        fi

        upload_url="$(_sys_trim "${upload_url}")"

        if [[ -n "${upload_url}" && "${upload_url}" =~ ^http ]]; then
            printf "${GREEN}[✔]${RST} Upload concluído com sucesso!\n"
            printf "    • URL do Dump: ${CYAN}${BOLD}%s${RST}\n" "${upload_url}"
            printf "    • Checksum SHA-256: ${DIM}%s${RST}\n" "${dump_hash}"
        else
            _err "Não foi possível realizar o upload para os servidores de suporte."
            printf "    O arquivo local foi mantido em: %s\n" "${output_file}"
            return
        fi

        # Limpeza do arquivo temporário pós-upload seguro
        rm -f "${output_file}"
    fi
}
