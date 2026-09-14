#!/usr/bin/env bash
# ============================================================================
# Sambox - Módulo de Desinstalação e Limpeza do Sistema
# BSD 2-Clause License (Simplified)
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

# [1] Limpeza Geral de Pacotes Órfãos e Cache do APT
system_deep_clean() {
    printf "\n${YELLOW}[+]${RST} Executando limpeza profunda do sistema...\n"
    export DEBIAN_FRONTEND=noninteractive

    printf "${YELLOW}[+]${RST} Removendo pacotes orfãos e configurações residuais...\n"
    sudo apt autoremove --purge -y

    printf "${YELLOW}[+]${RST} Limpando cache de pacotes baixados em /var/cache/apt/archives...\n"
    sudo apt clean -y
    sudo apt autoclean -y

    _msg "Limpeza de sistema concluída! Espaço em disco liberado."
}

# [2] Remoção da Stack Java (OpenJDK + Maven + Gradle)
purge_java_stack() {
    printf "\n${RED}[-]${RST} Removendo Java OpenJDK, Maven e Gradle...\n"
    export DEBIAN_FRONTEND=noninteractive

    if sudo apt purge -y default-jdk default-jre maven gradle ca-certificates-java; then
        sudo apt autoremove --purge -y
        _msg "Stack Java removida com sucesso!"
    else
        _err "Falha ao remover pacotes da Stack Java."
    fi
}

# [3] Remoção do VSCodium e limpeza de Repositório/Chave GPG
purge_vscodium() {
    printf "\n${RED}[-]${RST} Removendo VSCodium e seus arquivos de repositório...\n"
    export DEBIAN_FRONTEND=noninteractive

    # Purga o pacote do sistema
    sudo apt purge -y codium

    # Apaga arquivos de lista e chave GPG importada
    sudo rm -f /etc/apt/sources.list.d/vscodium.list
    sudo rm -f /usr/share/keyrings/vscodium-archive-keyring.gpg

    sudo apt update -y
    sudo apt autoremove --purge -y

    _msg "VSCodium e chaves de repositório removidos completamente!"
}

# [4] Remoção do Ambiente Wine
purge_wine_stack() {
    printf "\n${RED}[-]${RST} Removendo ambiente Wine...\n"
    export DEBIAN_FRONTEND=noninteractive

    sudo apt purge -y wine wine32 wine64 libwine libwine:i386
    sudo apt autoremove --purge -y

    _msg "Ambiente Wine desinstalado."
}

# [5] Remoção do Chromium Web Browser
purge_chromium() {
    printf "\n${RED}[-]${RST} Removendo Chromium Web Browser...\n"
    export DEBIAN_FRONTEND=noninteractive

    sudo apt purge -y chromium chromium-l10n
    sudo apt autoremove --purge -y

    _msg "Chromium removido."
}

# ── Função Orquestradora do Módulo de Desinstalação ────────────────────────
menu_uninstall_central() {
    local rm_menu
    while true; do
        clear 2>/dev/null || true
        printf "\n"
        printf "${CYAN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf " ║      🗑️  CENTRAL DE REMOÇÃO E LIMPEZA     ║\n"
        printf " ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${CYAN}[1]${RST}  ☕  Remover Java Stack (JDK, JRE, Maven, Gradle)\n"
        printf "  ${CYAN}[2]${RST}  💻  Remover VSCodium + Repositório APT & Chave GPG\n"
        printf "  ${CYAN}[3]${RST}  🍷  Remover Ambiente Wine\n"
        printf "  ${CYAN}[4]${RST}  🌐  Remover Chromium Web Browser\n"
        printf "  ${CYAN}[5]${RST}  🧹  Executar Limpeza Profunda (autoremove --purge + clean)\n"
        printf "  ${DIM}────────────────────────────────────────────────${RST}\n"
        printf "  ${CYAN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione [0-5]:$(printf "${RST}") " rm_menu

        case "${rm_menu}" in
            1) purge_java_stack ;;
            2) purge_vscodium ;;
            3) purge_wine_stack ;;
            4) purge_chromium ;;
            5) system_deep_clean ;;
            0) break ;;
            *) _warn "Opção inválida no menu de remoção." ;;
        esac

        printf "\n"
        read -rp "  Pressione [ENTER] para continuar..." _
    done
}