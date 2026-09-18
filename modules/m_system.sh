#!/usr/bin/env bash
# Sambox - Central Unificada de Manutenção, Purga e Debloat do Sistema
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

menu_system_central() {
    local sys_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║        🗑️   MANUTENÇÃO & PURGA DE DISCO    ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}  🧼  Limpar Cache do APT e Pacotes Órfãos\n"
        printf "  ${GREEN}[2]${RST}  📝  Expurgar Configurações Residuais (Status rc)\n"
        printf "  ${GREEN}[3]${RST}  ⚡  Truncar Journald e Faxinar Logs Mortos (/var/log)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione a ação de faxina [0-3]:$(printf "${RST}") " sys_choice
        [[ "${sys_choice}" == "0" || -z "${sys_choice}" ]] && break

        case "${sys_choice}" in
            1) _exec_apt_clean 0 ;;     # Chamada protegida para m_system_apt.sh
            2) _exec_apt_clean 1 ;;     # Chamada protegida para m_system_apt.sh
            3) clean_system_logs ;;     # Chamada protegida para m_system_logs.sh
            *) _warn "Opção inválida para o barramento de manutenção." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para retornar ao painel de manutenção..." _
    done
}

# Auto-registro na árvore de módulos vivos do Sambox mestre
register_sambox_module "🗑️   Manutenção e Faxina de Disco" "menu_system_central"
