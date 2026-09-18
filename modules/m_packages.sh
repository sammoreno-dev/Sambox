#!/usr/bin/env bash
# Sambox - Mini-Orquestrador de Gerenciamento de Software e Ambientes
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

# [Submenu] Pilha de Contêineres DevOps (Podman & Distrobox)
_submenu_containers() {
    local c_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🐳  CENTRAL DE CONTÊINERES ROOTLESS   ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}    📦  Instalar apenas Podman (Engine Nativa Sem Daemon)\n"
        printf "  ${GREEN}[2]${RST}    🚀  Instalar Podman + Distrobox (Qualquer Distro na CLI)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Voltar ao Menu de Pacotes\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o ambiente desejado [0-2]:$(printf "${RST}") " c_choice
        [[ "${c_choice}" == "0" || -z "${c_choice}" ]] && break

        case "${c_choice}" in
            # CORREÇÃO CRÍTICA: Removidos os colchetes desnecessários que travavam o motor
            1) if declare -f _exec_install_podman >/dev/null 2>&1; then _exec_install_podman 0; else install_podman_devops 0; fi ;;
            2) if declare -f _exec_install_podman >/dev/null 2>&1; then _exec_install_podman 1; else install_podman_devops 1; fi ;;
            *) _warn "Opção inválida para a pilha devops." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# [Submenu] Pilha de Hipervisor (QEMU-KVM com Escolha de Interface)
_submenu_virtualization() {
    local v_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🖥️   CENTRAL DE VIRTUALIZAÇÃO KVM      ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}    🧱  Instalar QEMU-KVM Bare-Metal (Modo Headless de Servidor)\n"
        printf "  ${GREEN}[2]${RST}    🖥️   Instalar QEMU-KVM + Virt-Manager (Gerenciador Gráfico TUI/GUI)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Voltar ao Menu de Pacotes\n\n"

        read -rp "  $(printf "${BOLD}")Selecione a infraestrutura [0-2]:$(printf "${RST}") " v_choice
        [[ "${v_choice}" == "0" || -z "${v_choice}" ]] && break

        case "${v_choice}" in
            # CORREÇÃO CRÍTICA: Removidos os colchetes desnecessários que travavam o motor
            1) if declare -f _exec_install_kvm >/dev/null 2>&1; then _exec_install_kvm 0; else install_qemu_kvm_infra 0; fi ;;
            2) if declare -f _exec_install_kvm >/dev/null 2>&1; then _exec_install_kvm 1; else install_qemu_kvm_infra 1; fi ;;
            *) _warn "Opção inválida para a pilha hipervisor." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# Menu Principal do Módulo de Pacotes
menu_packages_central() {
    local p_menu=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     📦  GERENCIADOR DE PACOTES & INFRA    ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}    🔧  Ativar Repositórios Não-Livres (contrib/non-free)\n"
        printf "  ${GREEN}[2]${RST}    🎮  Habilitar Arquitetura Multiarch i386 (Wine/Jogos Nativos)\n"
        printf "  ${GREEN}[3]${RST}    🖥️   Central de Virtualização Hypervisor (QEMU-KVM de Alta Performance)\n"
        printf "  ${GREEN}[4]${RST}    🐳  Central de Contêineres e DevOps Sem Raiz (Podman/Distrobox)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o deploy desejado [0-4]:$(printf "${RST}") " p_menu
        [[ "${p_menu}" == "0" || -z "${p_menu}" ]] && break

        case "${p_menu}" in
            # CORREÇÃO CRÍTICA: Substituído o operador '&&' inline por um bloco 'if' puro para evitar vazamento de saída
            1) if declare -f enable_non_free_repos >/dev/null 2>&1; then enable_non_free_repos; else _warn "Módulo repositório indisponível."; fi ;;
            2) if declare -f _ensure_i386_arch >/dev/null 2>&1; then _ensure_i386_arch; else _warn "Módulo multiarch indisponível."; fi ;;
            3) _submenu_virtualization ;;
            4) _submenu_containers ;;
            *) _warn "Opção inválida para o painel de softwares." ;;
        esac
    done
}

# Auto-registro independente no painel mestre
register_sambox_module "📦  Gerenciador de Pacotes e Infraestrutura" "menu_packages_central"
