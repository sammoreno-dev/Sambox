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
# Módulo: Network — SSH Manager, Diagnóstico de Hardware & Firmwares de Rede
# Função Orquestradora: ssh_fast_connect (Mantida para compatibilidade com o motor)
#

# Arquivo de aliases SSH (persistente, no diretório do Sambox)
readonly _SSH_ALIASES_FILE="${SAMBOX_DIR}/.ssh_aliases"

# Garante que o arquivo de aliases exista
[[ -f "${_SSH_ALIASES_FILE}" ]] || touch "${_SSH_ALIASES_FILE}"

# ── Orquestrador Geral do Módulo (Chamado pela Opção 3 do motor) ──────────────
ssh_fast_connect() {
    local net_choice
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║           🌐  GERENCIADOR DE REDE         ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  🔑  Acessar o SSH Fast Connect Manager\n"
        printf "  ${CYAN}[2]${RST}  🔍  Detectar Placas de Rede & Status Lógico\n"
        printf "  ${CYAN}[3]${RST}  📡  Instalar Firmwares de Rede Proprietários (APT)\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-3]:$(printf "${RST}") " net_choice

        case "${net_choice}" in
            1) _menu_ssh_original      ;; # Abre o seu gerenciador original de SSH
            2) detect_network_cards    ;; # Roda o diagnóstico de interfaces lógicas
            3) install_network_firmware ;; # Instala firmwares Realtek/Intel/Broadcom
            0) break                   ;; # Retorna ao sambox.sh de forma pacífica
            *) _warn "Opção inválida no menu de rede." ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Sub-menu do SSH Original Preservado ─────────────────────────────────────
_menu_ssh_original() {
    local choice
    while true; do
        clear 2>/dev/null || true
        _sep
        printf "  ${BOLD}${CYAN}🔑  SSH Fast Connect Manager${RST}\n"
        _sep
        printf "  ${CYAN}[1]${RST}  Listar conexões salvas\n"
        printf "  ${CYAN}[2]${RST}  Conectar a um alias\n"
        printf "  ${CYAN}[3]${RST}  Adicionar novo alias\n"
        printf "  ${CYAN}[4]${RST}  Remover alias\n"
        _sep
        printf "  ${CYAN}[0]${RST}  Voltar ao menu de rede\n\n"

        read -rp "  $(printf "${BOLD}")Opção:$(printf "${RST}") " choice

        case "${choice}" in
            1) _ssh_list    ;;
            2) _ssh_connect ;;
            3) _ssh_add     ;;
            4) _ssh_remove  ;;
            0) break        ;;
            *) _warn "Opção inválida." && sleep 1 ;;
        esac
        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}

# ── Funções de Diagnóstico e Firmwares de Rede (100% Bash Puro) ──────────────

detect_network_cards() {
    clear 2>/dev/null || true
    printf "\n"
    printf "${CYAN}${BOLD}  🔍  Diagnóstico de Hardware de Rede${RST}\n"
    _sep
    
    # 1. Varredura física direto no barramento PCI
    printf "  ${BOLD}Componentes Físicos (PCI):${RST}\n"
    local net_pci
    net_pci=$(lspci | grep -iE 'network|ethernet|wireless|wi-fi')
    if [[ -n "${net_pci}" ]]; then
        echo "${net_pci}" | sed 's/^/  • /'
    else
        _warn "Nenhuma placa de rede detectada no barramento PCI."
    fi
    _sep

    # 2. Varredura de status lógico direto do Kernel (/sys/class/net)
    printf "  ${BOLD}Interfaces Ativas no Sistema:${RST}\n"
    local iface state
    for iface in /sys/class/net/*; do
        [[ -e "${iface}" ]] || continue
        iface=$(basename "${iface}")
        [[ "${iface}" == "lo" ]] && continue # Ignora o loopback local
        
        if [[ -f "/sys/class/net/${iface}/operstate" ]]; then
            state=$(cat "/sys/class/net/${iface}/operstate")
        else
            state="unknown"
        fi
        
        if [[ "${state}" == "up" ]]; then
            printf "  • %-10s -> [${GREEN}CONECTADO / UP${RST}]\n" "${iface}"
        else
            printf "  • %-10s -> [${RED}DESCONECTADO / DOWN${RST}]\n" "${iface}"
        fi
    done
    _sep
}

install_network_firmware() {
    printf "\n${BLUE}[=]${RST} Analisando fabricante do hardware de rede...\n"
    local net_info
    net_info=$(lspci | grep -iE 'network|ethernet|wireless|wi-fi')
    
    if echo "${net_info}" | grep -iq "realtek"; then
        printf "${YELLOW}[+]${RST} Chipset Realtek detectado. Instalando firmware-realtek proprietário...\n"
        sudo apt install -y firmware-realtek
    elif echo "${net_info}" | grep -iq "intel"; then
        printf "${YELLOW}[+]${RST} Chipset Intel detectado. Instalando firmware-iwlwifi...\n"
        sudo apt install -y firmware-iwlwifi
    elif echo "${net_info}" | grep -iqE "broadcom|bcm"; then
        printf "${YELLOW}[+]${RST} Chipset Broadcom detectado. Instalando firmware-brcm80211...\n"
        sudo apt install -y firmware-brcm80211 bcmwl-kernel-source
    elif echo "${net_info}" | grep -iq "mediatek"; then
        printf "${YELLOW}[+]${RST} Chipset MediaTek detectado. Instalando firmware-misc-nonfree...\n"
        sudo apt install -y firmware-misc-nonfree
    else
        _warn "Fabricante não mapeada ou drivers já embutidos nativamente no Kernel."
    fi
}

# ── Sub-funções internas do SSH Original ────────────────────────────────────

_ssh_list() {
    printf "\n"
    if [[ ! -s "${_SSH_ALIASES_FILE}" ]]; then
        _warn "Nenhuma conexão salva."
        return
    fi

    printf "  ${BOLD}%-16s  %-30s  %-6s${RST}\n" "ALIAS" "HOST" "PORTA"
    _sep

    while IFS='|' read -r alias_name user host port; do
        printf "  ${CYAN}%-16s${RST}  %s@%-24s  %s\n" "${alias_name}" "${user}" "${host}" "${port}"
    done < "${_SSH_ALIASES_FILE}"
}

_ssh_connect() {
    _ssh_list
    printf "\n"

    local alias_name
    read -rp "  Nome do alias para conectar: " alias_name

    local line
    line="$(grep "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null || true)"

    if [[ -z "${line}" ]]; then
        _err "Alias '${alias_name}' não encontrado."
        return
    fi

    local user host port
    IFS='|' read -r _ user host port <<< "${line}"

    _msg "Conectando: ssh -p ${port} ${user}@${host}"
    ssh -p "${port}" "${user}@${host}"
}

_ssh_add() {
    printf "\n"
    local alias_name user host port

    read -rp "  Nome do alias (ex: prod-web01): " alias_name
    read -rp "  Usuário SSH: " user
    read -rp "  Host/IP: " host
    read -rp "  Porta: " port
    port="${port:-22}"

    # Validação mínima
    if [[ -z "${alias_name}" || -z "${user}" || -z "${host}" ]]; then
        _err "Alias, usuário e host são obrigatórios."
        return
    fi

    # Verifica duplicata
    if grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
        _warn "Alias '${alias_name}' já existe. Remova-o primeiro."
        return
    fi

    printf '%s|%s|%s|%s\n' "${alias_name}" "${user}" "${host}" "${port}" \
        >> "${_SSH_ALIASES_FILE}"

    _msg "Alias '${alias_name}' salvo com sucesso."
}

_ssh_remove() {
    _ssh_list
    printf "\n"

    local alias_name
    read -rp "  Nome do alias para remover: " alias_name

    if ! grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
        _err "Alias '${alias_name}' não encontrado."
        return
    fi

    # Remove a linha correspondente (portável via sed -i)
    sed -i "/^${alias_name}|/d" "${_SSH_ALIASES_FILE}"
    _msg "Alias '${alias_name}' removido."
}
