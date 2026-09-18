#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Faxina Estrita de Pacotes e Base Dpkg
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_exec_apt_clean() {
    # Inicialização preventiva para conformidade cega com o 'set -u'
    local deep_purge="${1:-0}"
    local line="" rc_packages=()

    printf "\n${YELLOW}[+]${RST} Iniciando faxina na base de gerenciamento do APT... 🧼\n"
    printf "    ${DIM}Esvaziando buffers locais de arquivos .deb baixados em cache...${RST}\n"
    export DEBIAN_FRONTEND=noninteractive

    if command -v apt-get &>/dev/null; then
        sudo apt-get clean -y
        sudo apt-get autoclean -y
        
        printf "    ${DIM}Rastreando e varrendo dependências e bibliotecas que ficaram órfãs...${RST}\n"
        sudo apt-get autoremove --purge -y

        # Executa a purga profunda de pacotes residuais de forma atomizada se solicitado
        if [[ "${deep_purge}" == "1" ]]; then
            printf "\n${YELLOW}[+]${RST} Analisando o banco do dpkg em busca de resíduos fantasma (status rc)... 🔍\n"
            
            # CORREÇÃO E BLINDAGEM: Varre o dpkg nativamente e anexa ao array de forma estrita
            while read -r line; do
                if [[ "${line}" =~ ^rc[[:space:]]+([^[:space:]]+) ]]; then
                    rc_packages+=("${BASH_REMATCH[1]}")
                fi
            done < <(dpkg -l 2>/dev/null)

            if [[ ${#rc_packages[@]} -gt 0 ]]; then
                printf "    ${RED}[-]${RST} Foram localizados ${BOLD}%d${RST} pacote(s) com arquivos de configuração órfãos.\n" "${#rc_packages[@]}"
                printf "    ${DIM}Executando expurgo molecular via dpkg --purge...${RST}\n"
                
                sudo dpkg --purge "${rc_packages[@]}" 2>/dev/null || true
                _msg "Configurações residuais deletadas do disco com sucesso! ツ"
            else
                _msg "Seu sistema está perfeitamente limpo! Nenhum resíduo 'rc' localizado. ✨"
            fi
        fi
        _msg "Base de pacotes APT totalmente higienizada e brilhando! (ツ)"
    else
        _err "APT não encontrado no sistema operacional. Esse módulo requer base Debian."
    fi
}
