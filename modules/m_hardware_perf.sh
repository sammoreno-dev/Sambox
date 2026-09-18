#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Performance de Hardware para Servidores
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

check_cpu_perf() {
    _sep
    printf "  ${BOLD}${GREEN}⚙  CPU & Hardware Performance Report${RST}\n\n"

    local line="" key="" val="" model="Desconhecido" count=0
    
    # 1. Extração nativa do modelo de CPU sem dar forks pesados de grep ou cut
    if [[ -f /proc/cpuinfo ]]; then
        while IFS=: read -r key val; do
            if [[ "${key}" =~ "model name" ]]; then
                model="${val#*[[:space:]]}"
                break
            fi
        done < /proc/cpuinfo
        count=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo "1")
    fi

    printf "  ${BOLD}Modelo da CPU:${RST}   %s\n" "${model}"
    printf "  ${BOLD}Threads Ativos:${RST}  %s threads detectados\n\n" "${count}"

    # 2. Barra de RAM em ASCII processada 100% via aritmética de inteiros interna do Bash
    if [[ -r /proc/meminfo ]]; then
        local mem_t_kb=0 mem_a_kb=0
        while IFS=: read -r key val; do
            [[ "${key}" =~ "MemTotal" ]] && mem_t_kb=$(echo "${val}" | awk '{print $1}')
            [[ "${key}" =~ "MemAvailable" ]] && mem_a_kb=$(echo "${val}" | awk '{print $1}')
        done < /proc/meminfo

        if [[ ${mem_t_kb} -gt 0 ]]; then
            local mem_used=$(( mem_t_kb - mem_a_kb ))
            local mem_pct=$(( (mem_used * 100) / mem_t_kb ))

            local total_gb=$(( mem_t_kb / 1024 / 1024 ))
            local used_gb=$(( mem_used / 1024 / 1024 ))

            local filled=$(( mem_pct / 10 ))
            local empty=$(( 10 - filled ))
            local bar="" i
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty; i++)); do bar+="░"; done

            local mem_color="${GREEN}"
            local msg_ram="Servidor trabalhando folgado e estável! ☁️"
            
            if [[ ${mem_pct} -ge 70 ]]; then
                mem_color="${YELLOW}"
                msg_ram="Carga moderada detectada. De olho nos processos! ⚡"
            fi
            if [[ ${mem_pct} -ge 88 ]]; then
                mem_color="${RED}${BOLD}"
                msg_ram="Alerta de alta pressão em memória RAM! 🚨"
            fi

            printf "  ${BOLD}Uso de RAM:${RST}     [${mem_color}%s${RST}] %d%% (%d GB / %d GB)\n" \
                "${bar}" "${mem_pct}" "${used_gb}" "${total_gb}"
            printf "  ${DIM}Status:${RST}         %s\n\n" "${msg_ram}"
        fi
    fi

    # 3. Tabela de Clocks Avançada: Varre cirurgicamente os arquivos sysfs de cada core
    printf "  ${BOLD}%-10s  %-14s  %-12s${RST}\n" "Core" "Clock Atual" "Governor"
    _sep

    local core_id=0 freq_raw=0 freq=0 gov="n/a"
    for ((core_id=0; core_id<count; core_id++)); do
        local freq_sys_path="/sys/devices/system/cpu/cpu${core_id}/cpufreq/scaling_cur_freq"
        local gov_path="/sys/devices/system/cpu/cpu${core_id}/cpufreq/scaling_governor"

        if [[ -r "${freq_sys_path}" ]]; then
            read -r freq_raw < "${freq_sys_path}"
            freq=$(( freq_raw / 1000 ))
        else
            freq="0"
        fi

        [[ -r "${gov_path}" ]] && read -r gov < "${gov_path}" || gov="n/a"

        # Formata a cor do governor para destacar modos de economia vs performance
        local gov_colored="${DIM}${gov}${RST}"
        [[ "${gov}" == "performance" ]] && gov_colored="${GREEN}${gov}${RST}"
        [[ "${gov}" == "powersave" ]] && gov_colored="${CYAN}${gov}${RST}"

        printf "  ${GREEN}%-10s${RST}  %-14s  %-12b\n" \
            "cpu${core_id}" "${freq} MHz" "${gov_colored}"
    done
    printf "\n  ${GREEN}[✓] Relatório térmico e de frequência concluído! (ツ)${RST}\n"
}
