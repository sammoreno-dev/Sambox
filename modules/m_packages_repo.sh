#!/usr/bin/env bash
# Sambox - Central de Repositórios Essenciais e Multiarch
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_ensure_i386_arch() {
    if ! dpkg --print-foreign-architectures | grep -q "i386"; then
        printf "\n${YELLOW}[+]${RST} Registrando arquitetura i386 no dpkg...\n"
        if sudo dpkg --add-architecture i386; then
            printf "${YELLOW}[+]${RST} Atualizando índices do APT pós-multiarch...\n"
            sudo apt-get update -y && _msg "Arquitetura i386 registrada e sincronizada com sucesso!" || _err "Falha ao atualizar o APT pós-i386."
        else
            _err "Falha crítica ao adicionar arquitetura estrangeira i386."
        fi
    else
        _msg "Arquitetura Multiarch i386 já está presente no sistema."
    fi
}

enable_non_free_repos() {
    printf "\n${YELLOW}[+]${RST} Ativando componentes contrib, non-free e non-free-firmware...\n"
    local modified=0

    if [[ -f /etc/apt/sources.list.d/debian.sources ]]; then
        sudo cp /etc/apt/sources.list.d/debian.sources /etc/apt/sources.list.d/debian.sources.bak 2>/dev/null || true
        sudo sed -i -E '/^Components:/ {
            /(^|[[:space:]])contrib([[:space:]]|$)/! s/$/ contrib/
            /(^|[[:space:]])non-free([[:space:]]|$)/! s/$/ non-free/
            /(^|[[:space:]])non-free-firmware([[:space:]]|$)/! s/$/ non-free-firmware/
        }' /etc/apt/sources.list.d/debian.sources
        modified=1
    fi

    if [[ -f /etc/apt/sources.list ]]; then
        sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak 2>/dev/null || true
        sudo sed -i -E '/^[[:space:]]*deb(-src)?[[:space:]]+/ {
            /(^|[[:space:]])contrib([[:space:]]|$)/! s/$/ contrib/
            /(^|[[:space:]])non-free([[:space:]]|$)/! s/$/ non-free/
            /(^|[[:space:]])non-free-firmware([[:space:]]|$)/! s/$/ non-free-firmware/
        }' /etc/apt/sources.list
        modified=1
    fi

    if [[ ${modified} -eq 1 ]]; then
        _msg "Repositórios atualizados com sucesso (backup criado em .bak)."
        printf "${YELLOW}[+]${RST} Sincronizando índices do APT...\n"
        sudo apt-get update -y && _msg "Índices do APT sincronizados com sucesso!" || _err "Falha ao atualizar os índices do APT."
    else
        _err "Nenhum arquivo de fontes (/etc/apt/sources.list ou debian.sources) foi encontrado."
        return 1
    fi
}

menu_repo_central() {
    local r_menu=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🔧  GERENCIADOR DE REPOSITÓRIOS BASE  ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}    🔧  Ativar Componentes Não-Livres (contrib/non-free)\n"
        printf "  ${GREEN}[2]${RST}    🎮  Habilitar Arquitetura 32-bits (Multiarch i386)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}    ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  Selecione uma opção [0-2]: " r_menu
        [[ "${r_menu}" == "0" || -z "${r_menu}" ]] && break

        case "${r_menu}" in
            1) enable_non_free_repos ;;
            2) _ensure_i386_arch ;;
            *) _warn "Opção inválida." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# Registra de forma limpa como uma opção focada no menu mestre do Sambox
register_sambox_module "🔧  Gerenciador de Repositórios e Base OS" "menu_repo_central"

