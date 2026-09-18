#!/usr/bin/env bash
# Sambox - Central de Auditoria e Sistema (Interface Leve & Humanizada)
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

show_system_info() {
    local sys_opt=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║        ℹ️   SISTEMA & AUDITORIA            ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        
        # Chama o dashboard isolado para renderizar o resumo do SO em tempo real
        _sysinfo_dashboard
        
        printf "  ${BOLD}OPÇÕES DE ANÁLISE & AUDITORIA CORRELAÇÃO:${RST}\n\n"
        printf "  ${GREEN}[1]${RST}  🧩  Inspetor Detalhado de Hardware & Virtualização\n"
        printf "  ${GREEN}[2]${RST}  ⚡  Processos em Foco (Top Consumidores CPU/RAM)\n"
        printf "  ${GREEN}[3]${RST}  📝  Consolidar Source Dump Localmente (/tmp)\n"
        printf "  ${GREEN}[4]${RST}  🚀  Exportar Source Dump para Nuvem (Link Seguro)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o diagnóstico [0-4]:$(printf "${RST}") " sys_opt
        [[ "${sys_opt}" == "0" || -z "${sys_opt}" ]] && break

        case "${sys_opt}" in
            1) _hardware_inspect ;;
            2) _top_processes ;;
            3) _generate_source_dump "local" ;;
            4) _generate_source_dump "cloud" ;;
            *) _warn "Opção inválida para o barramento de auditoria." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para retornar ao painel de análise..." _
    done
}

# Auto-registro nativo e instantâneo no motor mestre do Sambox clássico
register_sambox_module "📊  Informações e Diagnóstico do Sistema" "show_system_info"
