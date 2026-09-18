#!/usr/bin/env bash
# Sambox - Central Unificada de Redes, Protocolos e Diagnósticos
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

# CORREÇÃO PARA HOT-RELOAD: Define o banco apenas se ele ainda não existir na memória da sessão
if [[ ! -v _SSH_ALIASES_FILE ]]; then
    export _SSH_ALIASES_FILE="${HOME}/.sambox/.ssh_aliases"
fi

# Inicialização segura e proteção estrita de permissões do banco de aliases do Sambox
[[ ! -f "${_SSH_ALIASES_FILE}" ]] && mkdir -p "$(dirname "${_SSH_ALIASES_FILE}")" 2>/dev/null && touch "${_SSH_ALIASES_FILE}" && chmod 600 "${_SSH_ALIASES_FILE}" 2>/dev/null

ssh_fast_connect() {
    local net_choice=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║             🌐  GERENCIADOR DE REDE       ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}  🔑  SSH Fast Connect & Manager de Chaves\n"
        printf "  ${GREEN}[2]${RST}  📁  FTP / SFTP Client & Manager de Conexões\n"
        printf "  ${GREEN}[3]${RST}  🔍  Interfaces de Rede, Status & Tráfego I/O\n"
        printf "  ${GREEN}[4]${RST}  🌐  Auditor de IP Público, DNS & Latência\n"
        printf "  ${GREEN}[5]${RST}  🛡️   Inspetor de Portas & Soquetes em Escuta\n"
        printf "  ${GREEN}[6]${RST}  📡  Instalar Firmwares de Rede Proprietários\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o painel de rede [0-6]:$(printf "${RST}") " net_choice
        [[ "${net_choice}" == "0" || -z "${net_choice}" ]] && break

        case "${net_choice}" in
            1) _menu_ssh_manager ;;      # Função isolada em m_network_ssh.sh
            2) _menu_ftp_manager ;;      # Função isolada em m_network_ftp.sh
            3) detect_network_cards ;;   # Função isolada em m_network_diag.sh
            4) _check_public_ip_dns ;;   # Função isolada em m_network_diag.sh
            5) _check_listening_ports ;; # Função isolada em m_network_diag.sh
            6) install_network_firmware ;; # Função isolada em m_network_diag.sh
            *) _warn "Opção inválida para o barramento de rede." ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para retornar ao painel de redes..." _
    done
}

# Auto-registro na árvore de módulos vivos do Sambox mestre
register_sambox_module "🌐  Gerenciador de Redes, SSH & Protocolos" "ssh_fast_connect"
