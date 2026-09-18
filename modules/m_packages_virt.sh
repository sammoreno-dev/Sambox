#!/usr/bin/env bash
# Sambox - Central Isolada de Hipervisor e Máquinas Virtuais (QEMU-KVM)
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_exec_install_kvm() {
    local with_gui="$1" pkgs=(qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virtinst bridge-utils)
    [[ "${with_gui}" == "1" ]] && pkgs+=("virt-manager")
    
    printf "\n${YELLOW}[+]${RST} Analisando o seu processador... \n"
    
    # Detecção viva com UX humana e acolhedor
    if egrep -q 'vmx|svm' /proc/cpuinfo; then
        printf "    ${GREEN}🚀 Excelente! Extensões de virtualização (VT-x/AMD-V) ativas na BIOS.${RST}\n"
        printf "       Sua máquina está prontinha para rodar VMs em velocidade bare-metal pura.\n\n"
    else
        _warn "Epa! Suporte VT-x/AMD-V ausente ou desativado na BIOS."
        printf "      O KVM vai funcionar, mas em modo de emulação lenta. Vale a pena ativar depois! ⚙️\n\n"
    fi

    printf "${YELLOW}[+]${RST} Sincronizando com os espelhos do Debian e erguendo a pilha KVM via APT...\n"
    if sudo apt-get update -y && sudo apt-get install -y "${pkgs[@]}"; then
        printf "    ${DIM}Configurando permissões locais e injetando seu usuário nos grupos libvirt/kvm...${RST}\n"
        sudo adduser "${USER}" libvirt 2>/dev/null || true
        sudo adduser "${USER}" kvm 2>/dev/null || true
        
        printf "    ${DIM}Acionando os daemons do motor Libvirtd em background...${RST}\n"
        sudo systemctl enable --now libvirtd 2>/dev/null || true
        
        _msg "Infraestrutura KVM totalmente pronta e blindada! ツ"
        printf "\n  ${GREEN}🎉 Parabéns! Suas máquinas virtuais agora têm passe livre direto para o hardware.${RST}\n"
        printf "     ${BOLD}[Nota]${RST} Lembre-se de reiniciar sua sessão de usuário para aplicar as permissões de grupo.\n"
    else
        _err "Puxa, ocorreu uma falha na instalação dos pacotes do KVM."
        printf "     Verifique sua conexão com a internet ou os espelhos do APT e tente novamente. 🛠️\n"
    fi
}

menu_virt_central() {
    local v_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🖥️   CENTRAL DE VIRTUALIZAÇÃO KVM      ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}    🧱  Instalar QEMU-KVM Bare-Metal (Headless/Servidor)\n"
        printf "  ${GREEN}[2]${RST}    🖥️   Instalar QEMU-KVM + Virt-Manager (Interface Gráfica)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  Selecione uma opção [0-2]: " v_choice
        [[ "${v_choice}" == "0" || -z "${v_choice}" ]] && break

        case "${v_choice}" in
            1) _exec_install_kvm 0 ;;
            2) _exec_install_kvm 1 ;;
            *) _warn "Opção inválida." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# Auto-registro independente no painel mestre
register_sambox_module "🖥️   Central de Virtualização (QEMU-KVM)" "menu_virt_central"
