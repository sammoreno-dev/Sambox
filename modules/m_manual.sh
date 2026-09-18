#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SAMBOX — Módulo Manual & Documentação Interativa (modules/m_manual.sh)
# Licença: BSD 2-Clause
# -----------------------------------------------------------------------------

_show_manual_header() {
    clear 2>/dev/null || true
    printf "${GREEN}${BOLD}"
    printf '  ╔═══════════════════════════════════════════╗\n'
    printf '  ║     📖  SAMBOX MANUAL & DOCUMENTAÇÃO     ║\n'
    printf '  ╚═══════════════════════════════════════════╝\n'
    printf "${RST}\n"
    printf "  Documentação oficial e guia dos módulos integrados no sistema.\n\n"
}

show_manual_menu() {
    local opt=""
    while true; do
        _show_manual_header
        printf "  ${GREEN}[1]${RST}  📜  Capítulo 1 — Filosofia, Licença BSD & Zero Copyleft\n"
        printf "  ${GREEN}[2]${RST}  ⚙️   Capítulo 2 — Guia Completo dos Módulos Integrados\n"
        printf "  ${GREEN}[3]${RST}  📚  Manual Completo (Modo Pager Avançado)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione uma opção [0-3]:$(printf "${RST}") " opt
        [[ "${opt}" == "0" || -z "${opt}" ]] && break

        case "${opt}" in
            1) _load_manual_text "1" ;; # Dispara o gatilho dinâmico do m_manual_text.sh
            2) _load_manual_text "2" ;; # Dispara o gatilho dinâmico do m_manual_text.sh
            3) _load_manual_text "3" ;; # Dispara o gatilho dinâmico do m_manual_text.sh
            *) _warn "Opção inválida." ;;
        esac
    done
}

# Auto-registro na árvore dinâmica do motor mestre do Sambox
register_sambox_module "📖  Manual de Instruções e Diretrizes" "show_manual_menu"

