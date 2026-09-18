#!/usr/bin/env bash
# Sambox - Monitor de Performance em Memória Pura (Sem Forks/Subshells)
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_sysinfo_dashboard() {
    # Inicialização estrita para satisfazer a flag de proteção 'set -u'
    local hostname="" os_name="Debian GNU/Linux" kernel_version="" uptime_raw="N/A"
    local load_avg="N/A" disk_usage="N/A" temp_c="N/A"
    local line="" up_raw="" up_seconds="" l1="" l2="" l3=""
    local key="" val="" mem_t_kb=0 mem_a_kb=0 swap_t_kb=0 swap_f_kb=0
    local mem_t_mb=0 mem_u_mb=0 swap_t_mb=0 swap_u_mb=0 mem_pct=0

    # 1. Extração nativa de Identidade do Host e Kernel
    hostname="${HOSTNAME:-$(hostname 2>/dev/null || echo "localhost")}"
    kernel_version="$(uname -r)"

    # Parsing seguro do OS sem estourar o array do BASH_REMATCH
    if [[ -f /etc/os-release ]]; then
        while IFS= read -r line; do
            if [[ "${line}" =~ ^PRETTY_NAME= ]]; then
                os_name="${line#*=}"
                os_name="${os_name//\"/}" # Higieniza as aspas duplas da string
                break
            fi
        done < /etc/os-release
    fi

    # 2. Parsing nativo do uptime (Corta ponto flutuante em memória pura)
    if [[ -f /proc/uptime ]]; then
        read -r up_raw _ < /proc/uptime
        up_seconds="${up_raw%%.*}"
        
        local min=$(( (up_seconds / 60) % 60 ))
        local hrs=$(( (up_seconds / 3600) % 24 ))
        local days=$(( up_seconds / 86400 ))
        [[ ${days} -gt 0 ]] && uptime_raw="${days}d ${hrs}h ${min}m" || uptime_raw="${hrs}h ${min}m"
    fi

    # 3. Parsing nativo do Load Average e Alerta de Carga
    local msg_load="Estável" color_load="${GREEN}"
    if [[ -f /proc/loadavg ]]; then
        read -r l1 l2 l3 _ < /proc/loadavg
        load_avg="${l1}, ${l2}, ${l3}"
        
        # Converte o load de 1 min para inteiro para testar estresse
        local load_int="${l1%%.*}"
        load_int="${load_int:-0}"
        if [[ ${load_int} -ge 4 ]]; then
            msg_load="Sob Estresse! ⚡"
            color_load="${RED}${BOLD}"
        fi
    fi

    # 4. Extração cirúrgica de RAM e Swap (Garantia de retenção de dados)
    if [[ -f /proc/meminfo ]]; then
        while IFS=: read -r key val; do
            # Limpa os espaços e o sufixo 'kB' nativamente em memória
            local clean_val="${val% kB}"
            clean_val="${clean_val//[[:space:]]/}"
            
            case "${key}" in
                MemTotal)     mem_t_kb=${clean_val} ;;
                MemAvailable) mem_a_kb=${clean_val} ;;
                SwapTotal)    swap_t_kb=${clean_val} ;;
                SwapFree)     swap_f_kb=${clean_val} ;;
            esac
        done < /proc/meminfo

        mem_t_mb=$(( mem_t_kb / 1024 ))
        mem_u_mb=$(( (mem_t_kb - mem_a_kb) / 1024 ))
        swap_t_mb=$(( swap_t_kb / 1024 ))
        swap_u_mb=$(( (swap_t_kb - swap_f_kb) / 1024 ))
        
        [[ ${mem_t_kb} -gt 0 ]] && mem_pct=$(( (mem_u_mb * 100) / mem_t_mb ))
    fi

    # 5. UX Humorosa: Alertas de RAM Dinâmicos
    local color_ram="${GREEN}" msg_ram="Fluindo leve ツ"
    if [[ ${mem_pct} -ge 70 ]]; then
        color_ram="${YELLOW}"
        msg_ram="Carga moderada no servidor."
    fi
    if [[ ${mem_pct} -ge 88 ]]; then
        color_ram="${RED}${BOLD}"
        msg_ram="Pressão crítica de memória! 🚨"
    fi

    # 6. Uso de disco principal
    if command -v df &>/dev/null; then
        disk_usage="$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')"
    fi

    # 7. Temperatura térmica da CPU via sysfs
    if [[ -r /sys/class/thermal/thermal_zone0/temp ]]; then
        temp_c="$(( $(< /sys/class/thermal/thermal_zone0/temp) / 1000 ))°C"
    fi

    # 8. Renderização Avançada, Alinhada e Humana da TUI
    printf "  ${BOLD}Resumo Geral do Sistema:${RST}\n"
    _sep
    printf "  • ${BOLD}Host:${RST} %-22s • ${BOLD}OS:${RST} %s\n" "${hostname}" "${os_name}"
    printf "  • ${BOLD}Kernel:${RST} %-20s • ${BOLD}Bash:${RST} %s\n" "${kernel_version}" "${BASH_VERSION}"
    printf "  • ${BOLD}Uptime:${RST} %-20s • ${BOLD}Carga:${RST} %s (${color_load}%s${RST})\n" "${uptime_raw}" "${load_avg}" "${msg_load}"
    _sep
    printf "  • ${BOLD}RAM Usada:${RST} ${color_ram}%s MB${RST} / %s MB (%d%%) -> [${color_ram}%s${RST}]\n" "${mem_u_mb}" "${mem_t_mb}" "${mem_pct}" "${msg_ram}"
    printf "  • ${BOLD}Swap Usada:${RST} %s MB / %s MB       • ${BOLD}Temp CPU:${RST} %s\n" "${swap_u_mb}" "${swap_t_mb}" "${temp_c}"
    printf "  • ${BOLD}Disco (/):${RST} %-48s\n" "${disk_usage}"
    _sep
    printf "\n"
}
