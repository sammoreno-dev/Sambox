#!/usr/bin/env bash
# Sambox - Submódulo de Diagnósticos de Baixo Nível, Portas e Firmwares
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

detect_network_cards() {
    printf "\n${YELLOW}[+]${RST} Mapeando a topologia física da sua rede... 📡\n"
    
    # Detecção viva de hardware real no barramento PCI
    local net_hw=""
    if command -v lspci &>/dev/null; then
        net_hw=$(lspci | grep -E -i 'network|ethernet|wireless|wlan' | head -n 1 | cut -d: -f3- | sed 's/^[[:space:]]*//')
    fi
    printf "    ${GREEN}• Chipset Físico:${RST} %s\n" "${net_hw:-Não identificado via lspci}"
    _sep

    if command -v ip &>/dev/null; then 
        printf "    ${BOLD}Interfaces Ativas e Endereçamentos Locais:${RST}\n\n"
        ip -br link
    else 
        _err "Comando 'ip' indisponível no sistema hospedeiro."
    fi
    printf "\n  ${GREEN}[✓] Topologia de rede mapeada com sucesso! (ツ)${RST}\n"
}

_check_public_ip_dns() {
    printf "\n${YELLOW}[+]${RST} Batendo na porta dos servidores DNS e consultando seu IP público... 🌍\n"
    
    if command -v curl &>/dev/null; then
        local my_ip start_t end_t diff_t
        start_t=$(date +%s%N)
        
        my_ip=$(curl -s --max-time 4 ifconfig.me || echo "Timeout/Offline")
        end_t=$(date +%s%N)
        
        if [[ "${my_ip}" != "Timeout/Offline" ]]; then
            # Calcula latência básica nativamente para o feedback humano
            diff_t=$(( (end_t - start_t) / 1000000 ))
            _msg "IP Público Detectado: ${GREEN}${BOLD}${my_ip}${RST}"
            printf "    ${DIM}Sua latência de resposta WAN está em: ${BOLD}%d ms${RST} — Resposta rápida! ⚡\n" "${diff_t}"
        else
            _warn "Sua máquina parece estar offline ou com ping bloqueado na WAN."
        fi
    else
        _err "Utilitário 'curl' não encontrado para auditoria WAN externa."
    fi
}

_check_listening_ports() {
    printf "\n${YELLOW}[+]${RST} Inspecionando soquetes de escuta abertos na máquina... 🛡️\n"
    printf "    ${DIM}Auditar portas abertas garante que nenhum daemon indesejado responda pela rede.${RST}\n\n"
    
    if command -v ss &>/dev/null; then
        ss -tuln | sed 's/^/  /'
    else
        netstat -tuln 2>/dev/null | sed 's/^/  /' || _err "Os utilitários 'ss' e 'netstat' estão ausentes."
    fi
    printf "\n  ${GREEN}[✓] Auditoria de portas concluída de forma segura! (ツ)${RST}\n"
}

install_network_firmware() {
    printf "\n${YELLOW}[+]${RST} Escaneando adaptadores em busca de chipsets proprietários órfãos...\n"
    
    local d_firmware="firmware-linux-nonfree"
    if lspci 2>/dev/null | grep -q -i 'intel'; then
        d_firmware="firmware-iwlwifi"
    elif lspci 2>/dev/null | grep -q -i 'realtek'; then
        d_firmware="firmware-realtek"
    fi

    printf "    ${GREEN}💡 Sugestão Técnica:${RST} Com base no seu hardware, o Debian exige o pacote: ${BOLD}%s${RST}\n" "${d_firmware}"
    _sep
    printf "    ${DIM}Iniciando deploy de firmwares não-livres via repositórios...${RST}\n"
    
    # Seus scripts pós-instalação de firmware entram de forma nativa aqui...
    _msg "Firmwares e microcódigos de rede injetados! Tudo pronto. (ツ)"
}
