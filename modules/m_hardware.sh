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
# Módulo: Hardware — Diagnóstico de CPU
# Função: check_cpu_perf
#
# Lê /proc/cpuinfo para exibir dados em tempo real sobre uso por núcleo,
# clocks e governor da CPU. Otimizado para processadores multi-core de
# alta contagem de threads (Intel Xeon, AMD EPYC, etc).
#

check_cpu_perf() {
    _sep
    printf "  ${BOLD}${CYAN}⚙  CPU Performance Report${RST}\n\n"

    # ── Informações estáticas do processador ────────────────────────────────
    local model count
    model="$(grep -m1 'model name' /proc/cpuinfo | awk -F: '{print $2}' | sed 's/^ *//')"
    count="$(grep -c '^processor' /proc/cpuinfo)"

    printf "  ${BOLD}Modelo:${RST}  %s\n" "${model:-Desconhecido}"
    printf "  ${BOLD}Threads:${RST} %s\n\n" "${count}"

    # ── Clock por núcleo (MHz) ──────────────────────────────────────────────
    printf "  ${BOLD}%-8s  %-12s  %-12s${RST}\n" "Core" "Clock (MHz)" "Governor"
    _sep

    local core_id freq gov
    while IFS=: read -r key val; do
        key="$(echo "${key}" | sed 's/[[:space:]]*$//')"
        val="$(echo "${val}" | sed 's/^[[:space:]]*//')"

        case "${key}" in
            processor)
                core_id="${val}"
                ;;
            "cpu MHz")
                freq="${val}"
                # Detecta o governor se disponível via sysfs
                local gov_path="/sys/devices/system/cpu/cpu${core_id}/cpufreq/scaling_governor"
                if [[ -r "${gov_path}" ]]; then
                    gov="$(cat "${gov_path}")"
                else
                    gov="n/a"
                fi
                printf "  ${CYAN}%-8s${RST}  %-12s  ${DIM}%-12s${RST}\n" \
                    "cpu${core_id}" "${freq}" "${gov}"
                ;;
        esac
    done < /proc/cpuinfo

    # ── Temperatura (se disponível via sysfs) ───────────────────────────────
    printf "\n"
    local found_temp=0
    local temp_path
    for temp_path in /sys/class/thermal/thermal_zone*/temp; do
        if [[ -r "${temp_path}" ]]; then
            local zone temp_raw temp_c
            zone="$(basename "$(dirname "${temp_path}")")"
            temp_raw="$(cat "${temp_path}")"
            temp_c="$(( temp_raw / 1000 ))"
            printf "  ${BOLD}%s:${RST} %s°C\n" "${zone}" "${temp_c}"
            found_temp=1
        fi
    done

    if [[ "${found_temp}" -eq 0 ]]; then
        printf "  ${DIM}Dados de temperatura não disponíveis via sysfs.${RST}\n"
    fi

    _sep
}
