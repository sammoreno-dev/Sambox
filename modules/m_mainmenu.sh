#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Submódulo Isolado de Interface Visual e Navegação Principal
# Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.
# Distribuído sob os termos estáveis da licença BSD 2-Clause.
# -----------------------------------------------------------------------------

_render_banner() {
    clear 2>/dev/null || true
    printf "\n"
    printf "${GREEN}${BOLD}  ██████╗  █████╗ ███╗   ███╗██████╗  ██████╗ ██╗  ██╗\n"
    printf "  ██╔════╝ ██╔══██╗████╗ ████║██╔══██╗██╔═══██╗╚██╗██╔╝\n"
    printf "  ███████╗ ███████║██╔████╔██║██████╔╝██║   ██║ ╚███╔╝ \n"
    printf "  ╚════██║ ██╔══██║██║╚██╔╝██║██╔══██╗██║   ██║ ██╔██╗ \n"
    printf "  ███████║ ██║  ██║██║ ╚═╝ ██║██████╔╝╚██████╔╝██╔╝ ██╗\n"
    printf "  ╚══════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝${RST}\n"
    printf "        ${DIM}Central SysAdmin Pragmática • 100%% Bash Puro • v1.0${RST}\n\n"
}

menu_principal_tui() {
    local choice="" idx=1 target_func="" total_funcs=0

    while true; do
        _render_banner
        total_funcs=${#SAMBOX_MODULE_FUNCS[@]}

        printf "  ${BOLD}Olá, Administrador! Pronto para auditar o ecossistema? 🛠️${RST}\n\n"

        # 1. Renderização Automática Baseada no Registro Vivo dos Módulos Admin
        if [[ ${total_funcs} -gt 0 ]]; then
            idx=1
            for i in "${!SAMBOX_MODULE_NAMES[@]}"; do
                printf "  ${GREEN}[%d]${RST}    %s\n" "${idx}" "${SAMBOX_MODULE_NAMES[$i]}"
                idx=$(( idx + 1 ))
            done
        else
            _warn "Nenhum submódulo administrativo ativo indexado na memória."
        fi

        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Encerrar sessão no Sambox\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o painel desejado [0-${total_funcs}]:$(printf "${RST}") " choice

        [[ "${choice}" == "0" || -z "${choice}" ]] && { printf "\n  Até logo, Administrador! Sessão encerrada de forma limpa. ツ\n\n"; break; }

        if [[ "${choice}" =~ ^[1-9][0-9]*$ ]] && (( choice <= total_funcs )); then
            target_func="${SAMBOX_MODULE_FUNCS[$(( choice - 1 ))]}"
            
            if declare -f "${target_func}" >/dev/null 2>&1; then
                ${target_func}
            else
                printf "\n  ${RED}[✗] Erro de barramento: A rotina '${target_func}' não responde em memória.${RST}\n"
                printf "      Dê um Hot-Reload ou certifique-se de que o arquivo não tem erros de sintaxe.\n"
            fi
        else
            _warn "Opção inválida para o barramento do painel."
        fi
        printf "\n"; read -rp "  Pressione [ENTER] para retornar à central principal..." _
    done
}
