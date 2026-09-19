#!/usr/bin/env bash
# Sambox - Módulo de Termalização Bare-Metal
# License: BSD 2-Clause

check_sensors() {
    _sep
    printf "  ${BOLD}${CYAN}🌡️   Auditoria de Sensores Térmicos${RST}\n\n"
    
    local found=0
    
    # Varre a árvore de dispositivos térmicos do Kernel (Linux/Android)
    # Isso é muito mais estável do que depender do pacote 'sensors'
    if [[ -d "/sys/class/thermal" ]]; then
        for zone in /sys/class/thermal/thermal_zone*; do
            if [[ -f "$zone/temp" && -f "$zone/type" ]]; then
                local type
                local temp_raw
                read -r type < "$zone/type"
                read -r temp_raw < "$zone/temp"
                
                # Converte milicelsius para Celsius
                local temp=$(( temp_raw / 1000 ))
                
                # Filtra apenas o que parece ser CPU ou zone importante
                # Evita imprimir lixo como "acpitz" ou zones irrelevantes se preferir
                printf "  ${BOLD}• %-20s${RST}: %d°C\n" "$type" "$temp"
                found=1
            fi
        done
    fi

    if [[ $found -eq 0 ]]; then
        _err "Rotina de sensores indisponível (Kernel não expôs thermal_zones)."
    else
        printf "\n  ${GREEN}[✓] Auditoria térmica concluída com sucesso! (ツ)${RST}\n"
    fi
}

# Registra a função no motor principal
register_sambox_module "🌡️   Auditoria de Sensores" "check_sensors"
