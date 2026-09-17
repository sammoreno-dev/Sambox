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
# Módulo: Hardware — Central de Diagnósticos Estendida (Zero-Dependencies)
# Função Principal: menu_hardware_central
#

# ── Helper Interno de Sanitize / Trim ───────────────────────────────────────
_trim_str() {
    local str="$1"
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "${str}"
}

# ── 1. CPU, RAM & Desempenho Térmico ────────────────────────────────────────
check_cpu_perf() {
    _sep
    printf "  ${BOLD}${CYAN}⚙  CPU & Hardware Performance Report${RST}\n\n"

    local raw_model model count
    raw_model="$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 || true)"
    model="$(_trim_str "${raw_model:-Desconhecido}")"
    count="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || echo "1")"

    printf "  ${BOLD}Modelo:${RST}   %s\n" "${model}"
    printf "  ${BOLD}Threads:${RST}  %s\n\n" "${count}"

    # Barra de Memória RAM em ASCII
    if [[ -r /proc/meminfo ]]; then
        local mem_total mem_avail mem_used mem_pct filled empty bar i
        mem_total="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
        mem_avail="$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)"

        if [[ -n "${mem_total}" && -n "${mem_avail}" && "${mem_total}" -gt 0 ]]; then
            mem_used=$(( mem_total - mem_avail ))
            mem_pct=$(( (mem_used * 100) / mem_total ))

            # Cálculo de capacidades em GB via awk único
            read -r total_gb used_gb <<< "$(awk -v t="${mem_total}" -v u="${mem_used}" 'BEGIN {printf "%.1f %.1f", t/1048576, u/1048576}')"

            filled=$(( mem_pct / 10 ))
            empty=$(( 10 - filled ))
            bar=""
            for ((i=0; i<filled; i++)); do bar+="█"; done
            for ((i=0; i<empty; i++)); do bar+="░"; done

            local mem_color="${GREEN}"
            [[ "${mem_pct}" -ge 70 ]] && mem_color="${YELLOW}"
            [[ "${mem_pct}" -ge 88 ]] && mem_color="${RED}${BOLD}"

            printf "  ${BOLD}RAM:${RST}      [${mem_color}%s${RST}] %d%% (%s GB / %s GB)\n\n" \
                "${bar}" "${mem_pct}" "${used_gb}" "${total_gb}"
        fi
    fi

    # Tabela de Clocks por Core
    printf "  ${BOLD}%-10s  %-14s  %-12s${RST}\n" "Core" "Clock (MHz)" "Governor"
    _sep

    local core_id="" freq="" gov="" gov_path freq_sys_path
    while IFS=: read -r key val; do
        key="$(_trim_str "${key}")"
        val="$(_trim_str "${val}")"

        case "${key}" in
            processor) core_id="${val}" ;;
            "cpu MHz")
                freq="${val%.*}"
                freq_sys_path="/sys/devices/system/cpu/cpu${core_id}/cpufreq/scaling_cur_freq"
                gov_path="/sys/devices/system/cpu/cpu${core_id}/cpufreq/scaling_governor"

                # Tenta frequência exata em tempo real via sysfs
                if [[ -r "${freq_sys_path}" ]]; then
                    local freq_raw
                    freq_raw="$(< "${freq_sys_path}")"
                    freq=$(( freq_raw / 1000 ))
                fi

                gov="n/a"
                [[ -r "${gov_path}" ]] && gov="$(< "${gov_path}")"

                printf "  ${CYAN}%-10s${RST}  %-14s  ${DIM}%-12s${RST}\n" \
                    "cpu${core_id}" "${freq} MHz" "${gov}"
                ;;
        esac
    done < /proc/cpuinfo

    # Sensores Térmicos do Sistema
    printf "\n  ${BOLD}Sensores Térmicos:${RST}\n"
    local found_temp=0 temp_path zone_dir type_path zone_name temp_raw temp_c temp_color

    for temp_path in /sys/class/thermal/thermal_zone*/temp; do
        [[ -r "${temp_path}" ]] || continue
        zone_dir="${temp_path%/temp}"
        type_path="${zone_dir}/type"
        
        zone_name="Zone"
        [[ -r "${type_path}" ]] && zone_name="$(< "${type_path}")"

        temp_raw="$(< "${temp_path}")"
        temp_c=$(( temp_raw / 1000 ))

        temp_color="${GREEN}"
        [[ "${temp_c}" -ge 60 ]] && temp_color="${YELLOW}"
        [[ "${temp_c}" -ge 80 ]] && temp_color="${RED}${BOLD}"

        printf "  • %-22s ${temp_color}%s°C${RST}\n" "${zone_name}:" "${temp_c}"
        found_temp=1
    done

    [[ "${found_temp}" -eq 0 ]] && printf "  ${DIM}Dados térmicos indisponíveis via sysfs.${RST}\n"
    _sep
}

# ── 2. Checagem de Virtualização / KVM ─────────────────────────────────────
_check_kvm_support() {
    printf "  ${BOLD}${CYAN}🖥️  Virtualização & Suporte KVM${RST}\n\n"
    local flags kvm_status dev_kvm

    flags="$(grep -m1 -E 'flags|Features' /proc/cpuinfo 2>/dev/null || true)"

    if [[ "${flags}" =~ vmx ]]; then
        kvm_status="${GREEN}Suportado (Intel VT-x)${RST}"
    elif [[ "${flags}" =~ svm ]]; then
        kvm_status="${GREEN}Suportado (AMD-V)${RST}"
    else
        kvm_status="${RED}Não suportado ou desativado na BIOS${RST}"
    fi

    if [[ -c /dev/kvm ]]; then
        if [[ -w /dev/kvm ]]; then
            dev_kvm="${GREEN}Ativo & Acessível (/dev/kvm)${RST}"
        else
            dev_kvm="${YELLOW}Módulo ativo (requer permissão de grupo kvm/root)${RST}"
        fi
    else
        dev_kvm="${RED}Módulo não carregado (/dev/kvm ausente)${RST}"
    fi

    printf "  ${BOLD}Tecnologia de CPU:${RST} %b\n" "${kvm_status}"
    printf "  ${BOLD}Status do Kernel:${RST}   %b\n" "${dev_kvm}"
    _sep
}

# ── 3. Diagnóstico de Armazenamento (NVMe, SSD, HDD & Capacidade) ──────────
_check_storage() {
    _sep
    printf "  ${BOLD}${CYAN}💾  Relatório de Armazenamento & Mídia (Zero-Bloat)${RST}\n\n"
    printf "  ${BOLD}%-12s  %-10s  %-15s  %-12s  %-20s${RST}\n" "Unidade" "Tamanho" "Tipo Mídia" "Status Kernel" "Modelo"
    _sep

    local disk dev_name rot model type state size_blocks size_gb found=0

    for disk in /sys/block/*; do
        [[ -e "${disk}" ]] || continue
        dev_name="$(basename "${disk}")"

        # Filtra apenas unidades físicas reais
        [[ "${dev_name}" =~ ^(sd[a-z]|nvme[0-9]+n[0-9]+|vd[a-z])$ ]] || continue
        found=1

        # Cálculo da capacidade em GB via /sys/block/<dev>/size (blocos de 512 bytes)
        size_gb="N/A"
        if [[ -r "${disk}/size" ]]; then
            size_blocks="$(< "${disk}/size")"
            if [[ "${size_blocks}" -gt 0 ]]; then
                size_gb="$(( size_blocks * 512 / 1073741824 )) GB"
            fi
        fi

        # Rotacional (1 = HDD, 0 = SSD/NVMe)
        rot="n/a"
        [[ -r "${disk}/queue/rotational" ]] && rot="$(< "${disk}/queue/rotational")"

        if [[ "${dev_name}" =~ ^nvme ]]; then
            type="${GREEN}NVMe SSD${RST}"
        elif [[ "${rot}" == "0" ]]; then
            type="${CYAN}SATA SSD${RST}"
        elif [[ "${rot}" == "1" ]]; then
            type="${YELLOW}HDD (Rot)${RST}"
        else
            type="Desconhecido"
        fi

        # Modelo do Dispositivo
        model="Genérico / Virtual"
        if [[ -r "${disk}/device/model" ]]; then
            model="$(_trim_str "$(< "${disk}/device/model")")"
        elif [[ -r "${disk}/device/name" ]]; then
            model="$(_trim_str "$(< "${disk}/device/name")")"
        fi

        # Status do Dispositivo
        state="ativo"
        if [[ -r "${disk}/device/state" ]]; then
            state="$(< "${disk}/device/state")"
            [[ "${state}" == "running" || "${state}" == "live" ]] && state="${GREEN}${state}${RST}" || state="${RED}${state}${RST}"
        else
            state="${DIM}ativo${RST}"
        fi

        printf "  %-12s  %-10s  %-24b  %-21b  %-20s\n" \
            "/dev/${dev_name}" "${size_gb}" "${type}" "${state}" "${model:0:22}"
    done

    [[ "${found}" -eq 0 ]] && printf "  ${DIM}Nenhum disco físico reconhecido em /sys/block.${RST}\n"
    _sep
}

# ── 4. Placa de Vídeo & GPU Diagnostics ────────────────────────────────────
_check_gpu() {
    _sep
    printf "  ${BOLD}${CYAN}🎮  Placa de Vídeo & Acelerador Gráfico${RST}\n\n"

    local card vendor_id device_id vendor_name found=0

    for card in /sys/class/drm/card[0-9]; do
        [[ -r "${card}/device/vendor" ]] || continue
        found=1
        vendor_id="$(< "${card}/device/vendor")"
        device_id="$(< "${card}/device/device")"

        case "${vendor_id}" in
            0x10de|10de) vendor_name="${GREEN}NVIDIA Corporation${RST}" ;;
            0x1002|1002) vendor_name="${RED}AMD / ATI Technologies${RST}" ;;
            0x8086|8086) vendor_name="${CYAN}Intel Corporation${RST}" ;;
            *)           vendor_name="Vendor ID: ${vendor_id}" ;;
        esac

        printf "  • ${BOLD}Interface:${RST} %s\n" "$(basename "${card}")"
        printf "    ${BOLD}Fabricante:${RST} %b\n" "${vendor_name}"
        printf "    ${BOLD}Device ID:${RST}  %s\n\n" "${device_id}"
    done

    [[ "${found}" -eq 0 ]] && printf "  ${DIM}Nenhum acelerador gráfico detectado via /sys/class/drm.${RST}\n"
    _sep
}

# ── 5. Placa-Mãe & DMI Info ────────────────────────────────────────────────
_check_board_dmi() {
    _sep
    printf "  ${BOLD}${CYAN}🖥️   Placa-Mãe, BIOS & Informações DMI${RST}\n\n"

    local vendor="n/a" product="n/a" bios="n/a"
    [[ -r /sys/class/dmi/id/sys_vendor ]] && vendor="$(_trim_str "$(< /sys/class/dmi/id/sys_vendor)")"
    [[ -r /sys/class/dmi/id/product_name ]] && product="$(_trim_str "$(< /sys/class/dmi/id/product_name)")"
    [[ -r /sys/class/dmi/id/bios_version ]] && bios="$(_trim_str "$(< /sys/class/dmi/id/bios_version)")"

    printf "  ${BOLD}Fabricante:${RST}  %s\n" "${vendor}"
    printf "  ${BOLD}Produto:${RST}     %s\n" "${product}"
    printf "  ${BOLD}Versão BIOS:${RST}  %s\n" "${bios}"
    _sep
}

# ── Central de Menu do Módulo Hardware ──────────────────────────────────────
menu_hardware_central() {
    local choice
    while true; do
        clear 2>/dev/null || true
        printf "${CYAN}${BOLD}"
        printf '  ╔═══════════════════════════════════════════╗\n'
        printf '  ║     🔧  CENTRAL DE DIAGNÓSTICO HARDWARE   ║\n'
        printf '  ╚═══════════════════════════════════════════╝\n'
        printf "${RST}\n"
        printf "  ${BOLD}SELECIONE O DIAGNÓSTICO:${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  ⚙️   CPU Performance, Clocks & Suporte KVM\n"
        printf "  ${CYAN}[2]${RST}  💾  Mídia de Armazenamento (NVMe, SSD, HDD & Tamanho)\n"
        printf "  ${CYAN}[3]${RST}  🎮  Placa de Vídeo & GPU (DRM Diagnostics)\n"
        printf "  ${CYAN}[4]${RST}  🖥️   Placa-Mãe, BIOS & Memória RAM\n"
        printf "  ${CYAN}[5]${RST}  📊  Relatório Hardware Completo\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  Selecione [0-5]: " choice

        case "${choice}" in
            1)
                clear 2>/dev/null || true
                check_cpu_perf
                _check_kvm_support
                read -rp "  Pressione [ENTER] para voltar..." _
                ;;
            2)
                clear 2>/dev/null || true
                _check_storage
                read -rp "  Pressione [ENTER] para voltar..." _
                ;;
            3)
                clear 2>/dev/null || true
                _check_gpu
                read -rp "  Pressione [ENTER] para voltar..." _
                ;;
            4)
                clear 2>/dev/null || true
                _check_board_dmi
                read -rp "  Pressione [ENTER] para voltar..." _
                ;;
            5)
                clear 2>/dev/null || true
                check_cpu_perf
                _check_kvm_support
                _check_storage
                _check_gpu
                _check_board_dmi
                read -rp "  Pressione [ENTER] para voltar..." _
                ;;
            0) break ;;
            *) printf "${YELLOW}[!] Opção inválida!${RST}\n" && sleep 1 ;;
        esac
    done
}
