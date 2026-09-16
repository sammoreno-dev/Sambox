#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Módulo de Gerenciamento de Pacotes e Repositórios (APT)
# Copyright (c) 2026, Sam Moreno
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# -----------------------------------------------------------------------------

# [1] Função para ativar repositórios contrib, non-free e non-free-firmware
enable_non_free_repos() {
    printf "\n${YELLOW}[+]${RST} Ativando componentes contrib, non-free e non-free-firmware...\n"
    
    local modified=0

    # 1. Formato DEB822 (Debian 12+ em /etc/apt/sources.list.d/debian.sources)
    if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
        sudo cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak 2>/dev/null
        
        # Insere os componentes na linha 'Components:' apenas se ainda não existirem
        sudo sed -i '/^Components:/ {
            /contrib/! s/$/ contrib/
            /\bnon-free\b/! s/$/ non-free/
            /non-free-firmware/! s/$/ non-free-firmware/
        }' /etc/apt/sources.list.d/debian.sources
        
        modified=1
    fi

    # 2. Formato Tradicional (/etc/apt/sources.list)
    if [[ -f /etc/apt/sources.list ]]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null
        
        # Localiza linhas ativas do APT e injeta os componentes faltantes logo após 'main'
        sudo sed -i -E '/^deb(-src)? / {
            /contrib/! s/\bmain\b/main contrib/
            /\bnon-free\b/! s/\bmain\b/main non-free/
            /non-free-firmware/! s/\bmain\b/main non-free-firmware/
        }' /etc/apt/sources.list
        
        # Limpa eventuais espaços duplos residuais
        sudo sed -i 's/  */ /g' /etc/apt/sources.list
        
        modified=1
    fi

    # 3. Validação e Atualização
    if [[ $modified -eq 1 ]]; then
        _msg "Repositórios atualizados com sucesso (backup criado em .bak)."
        printf "${YELLOW}[+]${RST} Atualizando índices do APT...\n"
        sudo apt-get update -qq && _msg "Índices do APT sincronizados."
    else
        _err "Erro: Nenhum arquivo de fontes (/etc/apt/sources.list ou debian.sources) foi encontrado."
        return 1
    fi
}

# [2] Função para instalar drivers de vídeo baseados no hardware detectado
install_gpu_drivers() {
    printf "\n${BLUE}[=]${RST} Detectando placa de vídeo instalada via lspci...\n"
    local gpu_info
    gpu_info=$(lspci | grep -iE 'vga|3d')
    printf "Hardware detectado: ${CYAN}%s${RST}\n" "${gpu_info}"

    if echo "${gpu_info}" | grep -iq "nvidia"; then
        printf "${YELLOW}[+]${RST} GPU NVIDIA detectada. Instalando drivers proprietários e libs 32-bit para Wine...\n"
        sudo apt install -y linux-headers-amd64 nvidia-driver nvidia-graphics-drivers-libs:i386 nvidia-vulkan-icd nvidia-vulkan-icd:i386
    elif echo "${gpu_info}" | grep -iqE "amd|ati"; then
        printf "${YELLOW}[+]${RST} GPU AMD detectada. Instalando firmware oficial aberto...\n"
        sudo apt install -y firmware-amd-graphics mesa-vulkan-drivers mesa-vulkan-drivers:i386
    elif echo "${gpu_info}" | grep -iq "intel"; then
        printf "${YELLOW}[+]${RST} Gráficos Intel detectados. Instalando firmware complementar...\n"
        sudo apt install -y firmware-misc-nonfree intel-media-va-driver mesa-vulkan-drivers mesa-vulkan-drivers:i386
    else
        _warn "Nenhuma GPU comum (NVIDIA/AMD/Intel) identificada para automação."
    fi
}

# [3] Função para instalar o ambiente Wine de forma limpa (sem firulas)
install_wine_clean() {
    printf "\n${YELLOW}[+]${RST} Habilitando arquitetura de 32-bits (i386)...\n"
    sudo dpkg --add-architecture i386
    sudo apt update -y
    
    printf "${YELLOW}[+]${RST} Instalando Wine estável e dependências mínimas do sistema...\n"
    sudo apt install -y wine wine32 wine64 libwine libwine:i386
    _msg "Ambiente Wine estruturado com sucesso."
}

# [4] Instalação do Chromium Web Browser de forma 100% Nativa e Open-Source
install_chromium_native() {
    printf "\n${YELLOW}[+]${RST} Instalando Chromium Web Browser via APT nativo...\n"
    sudo apt install -y chromium chromium-l10n
    _msg "Chromium instalado com sucesso e sem dependências ocultas!"
}

# [5] Instalação de Interfaces Leves (GNOME e KDE banidos)
install_lightweight_de() {
    local de_opt
    clear 2>/dev/null || true
    _sep
    printf "         ${BOLD}SAMBOX - Interfaces Lightweight${RST}     \n"
    _sep
    printf "  ${CYAN}[1]${RST}  LXQt Desktop (Mínimo e Ultra-rápido)\n"
    printf "  ${CYAN}[2]${RST}  XFCE4 Desktop (Clássico e Estável)\n"
    printf "  ${CYAN}[3]${RST}  Cinnamon Desktop (Moderno e Tradicional)\n"
    _sep
    printf "  ${CYAN}[0]${RST}  Voltar ao menu de pacotes\n\n"
    read -rp "  $(printf "${BOLD}")Escolha a interface:$(printf "${RST}") " de_opt

    case "${de_opt}" in
        1)
            printf "${YELLOW}[+]${RST} Instalando ambiente LXQt mínimo...\n"
            sudo apt install -y lxqt-core openbox xorg lightdm
            ;;
        2)
            printf "${YELLOW}[+]${RST} Instalando ambiente XFCE4 estável...\n"
            sudo apt install -y xfce4 xfce4-goodies xorg lightdm
            ;;
        3)
            printf "${YELLOW}[+]${RST} Instalando ambiente Cinnamon...\n"
            sudo apt install -y cinnamon-core xorg lightdm
            ;;
        0) return ;;
        *) _warn "Opção inválida." && sleep 1 ;;
    esac
}

# [6] Atualização de Pacotes APT
update_system_packages() {
    printf "\n${BLUE}[+]${RST} Sincronizando índices de pacotes do APT...\n"
    sudo apt update -y

    printf "${RED}[+]${RST} Atualizando pacotes instalados (Safe Upgrade)...\n"
    sudo apt upgrade -y

    printf "${GREEN}[✔]${RST} Sistema atualizado com sucesso.\n"
}

# [7] Instalação do QEMU + Aditivos
install_qemu_virt() {
    printf "\n${BLUE}[+]${RST} Instalando e Adicionando Virtualização...\n"
    sudo apt install -y qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virt-manager
    printf "\n${YELLOW}[+]${RST} Instalado QEMU + Aditivos com sucesso.\n"
}

# [8] Instalação Nativa do File Roller
install_file_roller_native() {
    printf "\n${YELLOW}[+]${RST} Instalando File Roller e ferramentas de compressão via APT...\n"
    sudo apt install -y file-roller p7zip-full unzip zip unrar-free
    _msg "File Roller impecável instalado de forma 100% nativa!"
}

# [9] Instalação do Acelerador de Downloads CLI Axel
install_axel_accelerator() {
    printf "\n${BLUE}[+]${RST} Instalando acelerador de downloads CLI Axel via APT...\n"
    sudo apt install -y axel
    _msg "Axel instalado com sucesso. Prontinho para downloads multi-threaded ultra-rápidos!"
}

# [10] Sub-menu para Instalação de IDEs e Ambientes de Programação
install_ides_and_languages() {
    local dev_menu
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf " ║     💻  IDEs E LINGUAGENS DE PROGRAMAÇÃO  ║\n"
        printf " ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  ⚡  C/C++ Stack (build-essential, gcc, g++, make, cmake, gdb)\n"
        printf "  ${CYAN}[2]${RST}  🐍  Python 3 Stack (python3-full, pip, venv)\n"
        printf "  ${CYAN}[3]${RST}  🟢  Node.js + npm (Runtime JS/TS Nativo APT)\n"
        printf "  ${CYAN}[4]${RST}  🦫  Go / Golang (Compiler & Tools via APT)\n"
        printf "  ${CYAN}[5]${RST}  🦀  Rust & Cargo (Toolchain Nativa APT)\n"
        printf "  ${CYAN}[6]${RST}  📐  Geany (IDE Ultra-Leve GTK - Excelente para Debian)\n"
        printf "  ${CYAN}[7]${RST}  💻  VSCodium (VS Code Open-Source sem Telemetria via APT)\n"
        printf "  ${CYAN}[8]${RST}  📝  Neovim + Git + Tmux + Curl (Ambiente Dev CLI)\n"
        printf "  ${CYAN}[9]${RST}  🚀  Instalar Kit Dev Completo (Todas as Linguagens + IDEs)\n"
        printf "  ${CYAN}[10]${RST} ☕  Java Stack (OpenJDK + Maven + Gradle)\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar à Central de Pacotes\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-10]:$(printf "${RST}") " dev_menu

        case "${dev_menu}" in
            1)
                printf "\n${YELLOW}[+]${RST} Instalando toolchain C/C++ via APT...\n"
                sudo apt update -y && sudo apt install -y build-essential gcc g++ make cmake gdb
                _msg "Ferramentas C/C++ instaladas com sucesso."
                ;;
            2)
                printf "\n${YELLOW}[+]${RST} Instalando suporte a Python 3 e venv...\n"
                sudo apt update -y && sudo apt install -y python3 python3-full python3-pip python3-venv
                _msg "Python 3 Stack instalado com sucesso."
                ;;
            3)
                printf "\n${YELLOW}[+]${RST} Instalando Node.js e npm via APT...\n"
                sudo apt update -y && sudo apt install -y nodejs npm
                _msg "Node.js e npm instalados."
                ;;
            4)
                printf "\n${YELLOW}[+]${RST} Instalando compilador Go/Golang...\n"
                sudo apt update -y && sudo apt install -y golang
                _msg "Go instalado com sucesso."
                ;;
            5)
                printf "\n${YELLOW}[+]${RST} Instalando Rust e Cargo...\n"
                sudo apt update -y && sudo apt install -y rustc cargo
                _msg "Rustc e Cargo instalados."
                ;;
            6)
                printf "\n${YELLOW}[+]${RST} Instalando IDE Geany e plugins...\n"
                sudo apt update -y && sudo apt install -y geany geany-plugins
                _msg "Geany IDE instalado."
                ;;
            7)
                printf "\n${BLUE}[+]${RST} Configurando repositório oficial APT do VSCodium (Sem Telemetria)...\n"
                sudo apt update -y && sudo apt install -y wget gpg ca-certificates
                wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/vscodium-archive-keyring.gpg > /dev/null
                echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
                sudo apt update -y && sudo apt install -y codium
                _msg "VSCodium instalado com sucesso e sem rastreamento."
                ;;
            8)
                printf "\n${YELLOW}[+]${RST} Instalando ambiente de desenvolvimento em terminal...\n"
                sudo apt update -y && sudo apt install -y neovim git tmux curl
                _msg "Ambiente Dev CLI pronto para uso."
                ;;
            9)
                printf "\n${BLUE}[+]${RST} Instalando Kit Dev Completo...\n"
                export DEBIAN_FRONTEND=noninteractive
                sudo apt update -y && sudo apt install -y build-essential gcc g++ make cmake gdb python3 python3-full python3-pip python3-venv nodejs npm golang rustc cargo geany geany-plugins neovim git tmux curl ca-certificates-java default-jdk default-jre maven gradle
                _msg "Kit Dev Completo implantado no sistema!"
                ;;
            10)
                printf "\n${BLUE}[+]${RST} Instalando OpenJDK, Maven e Gradle via APT...\n"
                export DEBIAN_FRONTEND=noninteractive
                if sudo apt update -y && sudo apt install -y ca-certificates-java default-jre default-jdk maven gradle; then
                    _msg "Java (JDK/JRE), Maven e Gradle instalados com sucesso! 😁"
                else
                    _err "Falha ao instalar a Java Stack."
                fi
                ;;
            0) break ;;
            *) _warn "Opção inválida no sub-menu de desenvolvimento." ;;
        esac

        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Função Orquestradora Principal do Módulo (Sempre no final) ──────────────
menu_packages_central() {
    local p_menu
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf " ║          📦  CENTRAL DE PACOTES           ║\n"
        printf " ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}   🔄  Ativar Repositórios (Contrib/Non-Free)\n"
        printf "  ${CYAN}[2]${RST}   🎮  Auto-Detectar & Instalar Drivers de GPU\n"
        printf "  ${CYAN}[3]${RST}   🍷  Configurar Ambiente Wine (i386/Limpo)\n"
        printf "  ${CYAN}[4]${RST}   🌐  Instalar Chromium Web Browser (Nativo/Open-Source)\n"
        printf "  ${CYAN}[5]${RST}   🖥️   Instalar Interfaces Gráficas Leves\n"
        printf "  ${CYAN}[6]${RST}   🚀  Atualizar Pacotes do Sistema (APT Upgrade)\n"
        printf "  ${CYAN}[7]${RST}   💻  Instalar QEMU + Aditivos de Virtualização\n"
        printf "  ${CYAN}[8]${RST}   🗜️   Instalar File Roller (Compactador Nativo)\n"
        printf "  ${CYAN}[9]${RST}   ⚡   Instalar Axel (Acelerador de Downloads CLI)\n"
        printf "  ${CYAN}[10]${RST}  🛠️   Instalar IDEs e Linguagens de Programação\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}   ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-10]:$(printf "${RST}") " p_menu
        
        case "${p_menu}" in
            1) enable_non_free_repos ;;
            2) install_gpu_drivers   ;;
            3) install_wine_clean    ;;
            4) install_chromium_native ;;
            5) install_lightweight_de   ;;
            6) update_system_packages   ;;
            7) install_qemu_virt        ;;
            8) install_file_roller_native ;;
            9) install_axel_accelerator   ;;
            10) install_ides_and_languages ;;
            0) break ;;
            *) _warn "Opção inválida no sub-menu." ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}
