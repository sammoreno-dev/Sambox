#!/usr/bin/env bash
# Sambox - Central de Diagnóstico de Hardware (Interface Leve)
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

menu_hardware_central() {
    local h_opt=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║        📊  DIAGNÓSTICO DE HARDWARE        ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        
        printf "  ${GREEN}[1]${RST}  ⚡  Relatório de Performance (Clocks, RAM & Governors)\n"
        printf "  ${GREEN}[2]${RST}  🌡️   Auditar Sensores e Temperatura Física\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione uma opção [0-2]:$(printf "${RST}") " h_opt
        [[ "${h_opt}" == "0" || -z "${h_opt}" ]] && break

        case "${h_opt}" in
            1) check_cpu_perf ;; # Dispara a rotina enxuta do m_hardware_perf.sh
            2) if declare -f check_sensors >/dev/null 2>&1; then check_sensors; else _warn "Rotina de sensores indisponível."; fi ;;
            *) _warn "Opção inválida." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# Auto-registro vivo na mesa do motor dinâmico do Sambox original
register_sambox_module "📊  Diagnóstico de Hardware do Sistema" "menu_hardware_central"

