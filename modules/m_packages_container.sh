#!/usr/bin/env bash
# Sambox - Central Isolada de Engenharia de Contêineres (Podman & Distrobox)
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_exec_install_podman() {
    local with_dbox="$1" pkgs=(podman uidmap)
    [[ "${with_dbox}" == "1" ]] && pkgs+=("distrobox")

    printf "\n${YELLOW}[+]${RST} Preparando o terreno para isolar seus processos com segurança... 🛡️\n"
    printf "    ${DIM}Conectando aos espelhos oficiais do Debian para buscar pacotes rootless...${RST}\n"

    if sudo apt-get update -y && sudo apt-get install -y "${pkgs[@]}"; then
        _msg "Ambiente de contêineres instalado com sucesso! ツ"
        
        printf "\n  ${GREEN}🚀 Ótima escolha técnico-arquitetural!${RST}\n"
        printf "     Você agora roda contêineres isolados em espaço de usuário, sem root e sem daemons.\n"
        
        if [[ "${with_dbox}" == "1" ]]; then
            printf "     ${BOLD}[Distrobox Ativo]${RST} Sinta-se livre para acoplar qualquer distro (Arch, Fedora, Ubuntu)\n"
            printf "     direto no terminal do seu Debian estável sem peso nenhum na máquina.\n"
        fi
        
        printf "\n  ${GREEN}🎉 Tudo pronto! Podman integrado e pronto para o deploy rápido.${RST}\n"
    else
        _err "Puxa, ocorreu um contratempo ao baixar os pacotes de contêiner."
        printf "     Dê uma checada na sua conexão de rede ou chaves do repositório e tente novamente. 🛠️\n"
    fi
}

menu_container_central() {
    local c_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🐳  CENTRAL DE CONTÊINERES ROOTLESS   ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}${RST}    📦  Instalar apenas Podman (Engine Nativa)\n"
        printf "  ${GREEN}${RST}    🚀  Instalar Podman + Distrobox (Ambientes Híbridos)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}${RST}    ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  Selecione uma opção [0-2]: " c_choice
        [[ "${c_choice}" == "0" || -z "${c_choice}" ]] && break

        case "${c_choice}" in
            1) _exec_install_podman 0 ;;
            2) _exec_install_podman 1 ;;
            *) _warn "Opção inválida." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# Auto-registro independente no painel mestre
register_sambox_module "🐳  Central de Contêineres (Podman/Distrobox)" "menu_container_central"

