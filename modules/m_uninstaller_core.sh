#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Alto Rendimento para Purga de Pacotes e Caches
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_exec_software_purge() {
    # Inicialização estrita de variáveis locais para satisfazer a flag 'set -u'
    local target_id="${1:-0}"
    local current="" id="" label="" pkg_list=""
    export DEBIAN_FRONTEND=noninteractive

    # 1. Catálogo Único de Metadados: ID | Nome Comercial | Lista de Pacotes APT
    local catalog=(
        "1|Stack Java|default-jdk default-jre maven gradle ca-certificates-java"
        "2|VSCodium|codium"
        "3|Ambiente Wine|wine wine32 wine64 libwine libwine:i386"
        "4|Chromium Web Browser|chromium chromium-l10n"
        "5|Pilha QEMU/KVM|qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients virt-manager"
        "6|Pilha de Contêineres|podman distrobox"
        "7|Limpeza Profunda do Sistema|__deep_clean_trigger__"
    )

    # 2. Resolução da escolha via parsing nativo e instantâneo em memória (CORRIGIDO: IFS local)
    for current in "${catalog[@]}"; do
        if IFS='|' read -r id label pkg_list <<< "${current}"; then
            [[ "${id}" == "${target_id}" ]] && break
        fi
    done

    # Segurança: Se o ID digitado for inválido ou não mapeado, aborta pacificamente
    [[ -z "${label}" ]] && { _warn "Identificador de software inválido no barramento."; return 1; }

    # 3. Tratamento e Execução da Limpeza Profunda do APT (Opção 7)
    if [[ "${pkg_list}" == "__deep_clean_trigger__" ]]; then
        printf "\n${YELLOW}[+]${RST} Iniciando faxina profunda nos buffers do sistema... 🧼\n"
        printf "    ${DIM}Expurgando bibliotecas órfãs e configurações residuais acumuladas...${RST}\n"
        sudo apt-get autoremove --purge -y
        
        printf "    ${DIM}Esvaziando repositórios locais e caches do /var/cache/apt/archives...${RST}\n"
        sudo apt-get clean -y && sudo apt-get autoclean -y
        
        _msg "Sua base do sistema foi totalmente higienizada! Espaço em disco recuperado. ツ"
        return 0
    fi

    # 4. Executor de Purga de Softwares (Opções 1 a 6)
    printf "\n${RED}[-]${RST} Descomprimindo e removendo %s do sistema operacional... 🗑️\n" "${label}"
    printf "    ${DIM}Aguardando liberação do bloqueio do APT (/var/lib/dpkg/lock-frontend)...${RST}\n"
    
    # Executa a purga unificada expandindo as strings em pacotes individuais
    if sudo apt-get purge -y ${pkg_list}; then
        
        # Exceção de Arquitetura: Limpa repositórios e assinaturas GPG do VSCodium se ele for o alvo
        if [[ "${target_id}" == "2" ]]; then
            printf "    ${DIM}Eliminando espelhos de fontes e chaves GPG órfãs do Codium...${RST}\n"
            sudo rm -f /etc/apt/sources.list.d/vscodium.list /usr/share/keyrings/vscodium-archive-keyring.gpg
            printf "    ${DIM}Sincronizando índices do APT pós-remoção de repositório de terceiros...${RST}\n"
            sudo apt-get update -y
        fi

        # Higienização automática unificada pós-remoção para manter o sistema leve
        printf "    ${DIM}Passando o rodo nas dependências que ficaram órfãs no sistema...${RST}\n"
        sudo apt-get autoremove --purge -y
        
        _msg "%s removido e expurgado com sucesso absoluta! (ツ)" "${label}"
        printf "    ${GREEN}🎉 Parabéns! Menos inchaço no disco do seu Debian.${RST}\n"
    else
        _err "Puxa, ocorreu uma falha crítica ao tentar purgar as dependências de: ${label}."
        printf "     Verifique se o gerenciador do APT não está travado por outra sessão do dpkg. 🛠️\n"
    fi
}
