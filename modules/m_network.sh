#!/usr/bin/env bash
# ============================================================================
# BSD 2-Clause License (Simplified)
#
# Copyright (c) 2026, Sam Moreno
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# ============================================================================
#
# Módulo: Network — SSH Manager, Diagnóstico de Hardware, Portas & Firmwares
# Função Orquestradora: ssh_fast_connect
#

# Caminho seguro para o banco de aliases SSH
readonly _SSH_ALIASES_FILE="${SAMBOX_DIR:-${HOME}/.sambox}/.ssh_aliases"

# Inicialização e proteção de permissões do arquivo
if [[ ! -f "${_SSH_ALIASES_FILE}" ]]; then
    mkdir -p "$(dirname "${_SSH_ALIASES_FILE}")" 2>/dev/null || true
    touch "${_SSH_ALIASES_FILE}"
    chmod 600 "${_SSH_ALIASES_FILE}" 2>/dev/null || true
fi

# ── Helper Interno de Sanitize / Trim ───────────────────────────────────────
_net_trim() {
    local str="$1"
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "${str}"
}

# ── Orquestrador Geral do Módulo ───────────────────────────────────────────
ssh_fast_connect() {
    local net_choice
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║             🌐  GERENCIADOR DE REDE       ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  🔑  SSH Fast Connect & Manager de Chaves\n"
        printf "  ${CYAN}[2]${RST}  🔍  Interfaces de Rede, Status & Tráfego I/O\n"
        printf "  ${CYAN}[3]${RST}  🌐  Auditor de IP Público, DNS & Latência\n"
        printf "  ${CYAN}[4]${RST}  🛡️   Inspetor de Portas & Soquetes em Escuta\n"
        printf "  ${CYAN}[5]${RST}  📡  Instalar Firmwares de Rede Proprietários\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-5]:$(printf "${RST}") " net_choice

        case "${net_choice}" in
            1) _menu_ssh_manager ;;
            2) detect_network_cards ;;
            3) _check_public_ip_dns ;;
            4) _check_listening_ports ;;
            5) install_network_firmware ;;
            0) break ;;
            *) _warn "Opção inválida no menu de rede." ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Sub-menu do Gerenciador SSH ─────────────────────────────────────────────
_menu_ssh_manager() {
    local choice
    while true; do
        clear 2>/dev/null || true
        _sep
        printf "  ${BOLD}${CYAN}🔑  SSH Fast Connect & Key Manager${RST}\n"
        _sep
        printf "  ${CYAN}[1]${RST}  📋  Listar conexões salvas\n"
        printf "  ${CYAN}[2]${RST}  🚀  Conectar a um alias\n"
        printf "  ${CYAN}[3]${RST}  ➕  Adicionar novo alias\n"
        printf "  ${CYAN}[4]${RST}  🗑️   Remover alias\n"
        printf "  ${CYAN}[5]${RST}  🔐  Gerenciador de Chaves SSH (keygen / ssh-copy-id)\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao menu de rede\n\n"

        read -rp "  $(printf "${BOLD}")Opção:$(printf "${RST}") " choice

        case "${choice}" in
            1) _ssh_list ;;
            2) _ssh_connect ;;
            3) _ssh_add ;;
            4) _ssh_remove ;;
            5) _ssh_key_manager ;;
            0) break ;;
            *) _warn "Opção inválida." && sleep 1 ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Funções do SSH Manager ──────────────────────────────────────────────────

_ssh_list() {
    printf "\n"
    if [[ ! -s "${_SSH_ALIASES_FILE}" ]]; then
        _warn "Nenhuma conexão SSH salva no banco de aliases."
        return
    fi

    printf "  ${BOLD}%-16s  %-30s  %-6s${RST}\n" "ALIAS" "USUÁRIO & HOST" "PORTA"
    _sep

    local alias_name user host port
    while IFS='|' read -r alias_name user host port; do
        [[ -n "${alias_name}" ]] || continue
        printf "  ${CYAN}%-16s${RST}  %s@%-24s  %s\n" "${alias_name}" "${user}" "${host}" "${port}"
    done < "${_SSH_ALIASES_FILE}"
}

_ssh_connect() {
    _ssh_list
    printf "\n"

    local alias_name
    read -rp "  Nome do alias para conectar: " alias_name
    alias_name="$(_net_trim "${alias_name}")"

    local line
    line="$(grep "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null || true)"

    if [[ -z "${line}" ]]; then
        _err "Alias '${alias_name}' não encontrado."
        return
    fi

    local user host port
    IFS='|' read -r _ user host port <<< "${line}"

    _msg "Iniciando sessão SSH em ${user}@${host}:${port}..."
    ssh -p "${port}" "${user}@${host}"
}

_ssh_add() {
    printf "\n"
    local alias_name user host port

    read -rp "  Nome do alias (ex: prod-web01): " alias_name
    read -rp "  Usuário SSH (ex: root): " user
    read -rp "  Host/IP de destino: " host
    read -rp "  Porta SSH [22]: " port

    alias_name="$(_net_trim "${alias_name}")"
    user="$(_net_trim "${user}")"
    host="$(_net_trim "${host}")"
    port="$(_net_trim "${port:-22}")"

    if [[ -z "${alias_name}" || -z "${user}" || -z "${host}" ]]; then
        _err "Alias, usuário e host são de preenchimento obrigatório."
        return
    fi

    if grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
        _warn "O alias '${alias_name}' já existe. Remova-o antes de recriar."
        return
    fi

    printf '%s|%s|%s|%s\n' "${alias_name}" "${user}" "${host}" "${port}" >> "${_SSH_ALIASES_FILE}"
    _msg "Alias '${alias_name}' adicionado com sucesso!"
}

_ssh_remove() {
    _ssh_list
    printf "\n"

    local alias_name
    read -rp "  Nome do alias para remover: " alias_name
    alias_name="$(_net_trim "${alias_name}")"

    if ! grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
        _err "Alias '${alias_name}' não foi encontrado."
        return
    fi

    sed -i "/^${alias_name}|/d" "${_SSH_ALIASES_FILE}"
    _msg "Alias '${alias_name}' removido da lista."
}

_ssh_key_manager() {
    clear 2>/dev/null || true
    _sep
    printf "  ${BOLD}${CYAN}🔐  Gerenciador de Chaves SSH & Autenticação${RST}\n"
    _sep
    printf "  ${CYAN}[1]${RST}  Gerar nova chave SSH (ED25519 - Recomendado)\n"
    printf "  ${CYAN}[2]${RST}  Copiar chave pública para servidor remoto (ssh-copy-id)\n"
    printf "  ${CYAN}[3]${RST}  Listar chaves existentes em ~/.ssh/\n"
    _sep
    printf "  ${CYAN}[0]${RST}  Voltar\n\n"

    local key_opt
    read -rp "  Opção: " key_opt

    case "${key_opt}" in
        1)
            local email
            read -rp "  Digite seu e-mail para identificação da chave: " email
            if [[ -n "${email}" ]]; then
                ssh-keygen -t ed25519 -C "${email}"
                _msg "Chave ED25519 gerada em ~/.ssh/"
            fi
            ;;
        2)
            local remote_target remote_port
            read -rp "  Alvo remoto (ex: user@192.168.1.100): " remote_target
            read -rp "  Porta SSH [22]: " remote_port
            remote_port="${remote_port:-22}"

            if [[ -n "${remote_target}" ]]; then
                ssh-copy-id -p "${remote_port}" "${remote_target}"
            fi
            ;;
        3)
            printf "\n  ${BOLD}Chaves encontradas em ~/.ssh/:${RST}\n"
            ls -la ~/.ssh/*.pub 2>/dev/null || _warn "Nenhuma chave .pub encontrada."
            ;;
        *) return ;;
    esac
}

# ── Diagnóstico de Interfaces e Estatísticas de Tráfego ─────────────────────
detect_network_cards() {
    clear 2>/dev/null || true
    printf "\n"
    printf "${CYAN}${BOLD}  🔍  Hardware de Rede & Estatísticas de Tráfego${RST}\n"
    _sep

    # 1. Barramento PCI
    printf "  ${BOLD}Componentes Físicos (PCI):${RST}\n"
    if command -v lspci &>/dev/null; then
        local net_pci
        net_pci="$(lspci | grep -iE 'network|ethernet|wireless|wi-fi' || true)"
        if [[ -n "${net_pci}" ]]; then
            printf "%s\n" "${net_pci}" | sed 's/^/  • /'
        else
            _warn "Nenhum adaptador PCI detectado."
        fi
    else
        printf "  ${DIM}lspci indisponível. Lendo sysfs do kernel...${RST}\n"
    fi
    _sep

    # 2. Interfaces Lógicas e Estatísticas I/O
    printf "  ${BOLD}Interfaces & Volume de Tráfego:${RST}\n\n"
    printf "  %-12s  %-18s  %-12s  %-12s\n" "Interface" "Status" "Download" "Upload"
    _sep

    local iface state rx_bytes tx_bytes rx_mb tx_mb
    for iface_path in /sys/class/net/*; do
        [[ -e "${iface_path}" ]] || continue
        iface="$(basename "${iface_path}")"
        [[ "${iface}" == "lo" ]] && continue

        # Status da Interface
        state="down"
        [[ -r "${iface_path}/operstate" ]] && state="$(< "${iface_path}/operstate")"

        local status_str="${RED}DESCONECTADO${RST}"
        [[ "${state}" == "up" ]] && status_str="${GREEN}CONECTADO / UP${RST}"

        # Cálculo de Download/Upload em Megabytes
        rx_mb="0 MB"
        tx_mb="0 MB"
        if [[ -r "${iface_path}/statistics/rx_bytes" ]]; then
            rx_bytes="$(< "${iface_path}/statistics/rx_bytes")"
            tx_bytes="$(< "${iface_path}/statistics/tx_bytes")"
            rx_mb="$(( rx_bytes / 1048576 )) MB"
            tx_mb="$(( tx_bytes / 1048576 )) MB"
        fi

        printf "  %-12s  %-27b  %-12s  %-12s\n" "${iface}" "${status_str}" "${rx_mb}" "${tx_mb}"
    done
    _sep
}

# ── Auditor de IP Público, DNS & Teste de Latência ─────────────────────────
_check_public_ip_dns() {
    clear 2>/dev/null || true
    _sep
    printf "  ${BOLD}${CYAN}🌐  Auditor de IP Público, DNS & Latência${RST}\n"
    _sep

    # IP Público
    printf "  ${BOLD}Buscando IP Público de Saída...${RST}\n"
    local pub_ip="Inacessível / Offline"
    if command -v curl &>/dev/null; then
        pub_ip="$(curl -s --max-time 3 https://ifconfig.me 2>/dev/null || true)"
    elif command -v wget &>/dev/null; then
        pub_ip="$(wget -qO- -T 3 https://ifconfig.me 2>/dev/null || true)"
    fi
    printf "  • ${BOLD}IP Público:${RST} ${GREEN}%s${RST}\n\n" "${pub_ip:-Indisponível}"

    # Servidores DNS Ativos
    printf "  ${BOLD}Servidores DNS Configurados (/etc/resolv.conf):${RST}\n"
    if [[ -r /etc/resolv.conf ]]; then
        grep '^nameserver' /etc/resolv.conf | awk '{print "  • " $2}' || _warn "Sem DNS mapeado."
    fi
    printf "\n"

    # Teste de Latência aos Resolvers Globais
    printf "  ${BOLD}Benchmark de Latência (ICMP Ping):${RST}\n"
    local target target_name ping_res
    declare -A targets=(
        ["1.1.1.1"]="Cloudflare DNS"
        ["8.8.8.8"]="Google Public DNS"
        ["9.9.9.9"]="Quad9 DNS"
    )

    for target in "${!targets[@]}"; do
        target_name="${targets[${target}]}"
        if ping -c 1 -W 2 "${target}" &>/dev/null; then
            ping_res="$(ping -c 1 -W 2 "${target}" | awk -F'/' 'END {print $5}')"
            printf "  • %-20s (%s) -> ${GREEN}%s ms${RST}\n" "${target_name}" "${target}" "${ping_res}"
        else
            printf "  • %-20s (%s) -> ${RED}TIMEOUT / FALHA${RST}\n" "${target_name}" "${target}"
        fi
    done
    _sep
}

# ── Inspetor de Portas e Soquetes em Escuta ─────────────────────────────────
_check_listening_ports() {
    clear 2>/dev/null || true
    _sep
    printf "  ${BOLD}${CYAN}🛡️   Inspetor de Portas & Serviços em Escuta (LISTEN)${RST}\n"
    _sep

    if command -v ss &>/dev/null; then
        printf "  ${BOLD}%-8s  %-8s  %-22s  %-20s${RST}\n" "Proto" "Porta" "Endereço Bind" "Processo"
        _sep
        ss -tuln -p 2>/dev/null | grep LISTEN | awk '{
            split($5, a, ":");
            port = a[length(a)];
            printf "  %-8s  %-8s  %-22s  %-20s\n", $1, port, $5, $7
        }'
    else
        _warn "Utilitário 'ss' não encontrado. Exibindo resumo via procfs:"
        grep -v "sl" /proc/net/tcp 2>/dev/null | awk '{print "  • Local Address (Hex): " $2 " -> State: " $4}'
    fi
    _sep
}

# ── Instalação de Firmwares Proprietários de Rede ───────────────────────────
install_network_firmware() {
    clear 2>/dev/null || true
    printf "\n${BLUE}[=]${RST} Analisando adaptadores de rede e repositórios...\n"

    local net_info=""
    if command -v lspci &>/dev/null; then
        net_info="$(lspci | grep -iE 'network|ethernet|wireless|wi-fi' || true)"
    fi

    if echo "${net_info}" | grep -iq "realtek"; then
        printf "${YELLOW}[+]${RST} Chipset Realtek detectado. Instalando firmware-realtek...\n"
        sudo apt update && sudo apt install -y firmware-realtek
    elif echo "${net_info}" | grep -iq "intel"; then
        printf "${YELLOW}[+]${RST} Chipset Intel detectado. Instalando firmware-iwlwifi...\n"
        sudo apt update && sudo apt install -y firmware-iwlwifi
    elif echo "${net_info}" | grep -iqE "broadcom|bcm"; then
        printf "${YELLOW}[+]${RST} Chipset Broadcom detectado. Instalando firmware-brcm80211...\n"
        sudo apt update && sudo apt install -y firmware-brcm80211 bcmwl-kernel-source
    elif echo "${net_info}" | grep -iq "mediatek"; then
        printf "${YELLOW}[+]${RST} Chipset MediaTek detectado. Instalando firmware-misc-nonfree...\n"
        sudo apt update && sudo apt install -y firmware-misc-nonfree
    else
        _warn "Firmwares nativos do Kernel já carregados ou fabricante não requer drivers proprietários."
    fi
}
