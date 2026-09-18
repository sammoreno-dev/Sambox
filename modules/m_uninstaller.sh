#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Sambox - Central Unificada de Purga e Remoção Limpa de Softwares
# Copyright (c) 2026, Sam Moreno. Todos os direitos reservados.
# Distribuído sob os termos estáveis da licença BSD 2-Clause.
# -----------------------------------------------------------------------------

menu_uninstall_central() {
    local un_opt=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🗑️   REMOÇÃO & PURGA DE SOFTWARES      ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}  ☕  Remover Stack Java (OpenJDK, Maven & Gradle)\n"
        printf "  ${GREEN}[2]${RST}  📝  Remover VSCodium & Repositórios/Chaves GPG\n"
        printf "  ${GREEN}[3]${RST}  ⚙️   Remover Ambiente Wine & Bibliotecas 32-bit\n"
        printf "  ${GREEN}[4]${RST}  🌐  Remover Navegador Web Chromium\n"
        printf "  ${GREEN}[5]${RST}  🖥️   Remover Hipervisor KVM, QEMU & Virt-Manager\n"
        printf "  ${GREEN}[6]${RST}  🐳  Remover Engine de Contêineres (Podman & Distrobox)\n"
        printf "  ${GREEN}[7]${RST}  🧼  Executar Limpeza Profunda do Sistema (APT/Dpkg)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu Principal\n\n"

        read -rp "  $(printf "${BOLD}")Selecione o software para expurgo [0-7]:$(printf "${RST}") " un_opt
        [[ "${un_opt}" == "0" || -z "${un_opt}" ]] && break

        if [[ "${un_opt}" =~ ^[1-7]$ ]]; then
            # Dispara o motor inteligente do m_uninstall_core.sh
            _exec_software_purge "${un_opt}" 
        else
            _warn "Opção inválida para o barramento de desinstalação."
        fi
        printf "\n"; read -rp "  Pressione [ENTER] para retornar ao painel de remoção..." _
    done
}

# Auto-registro na árvore dinâmica do motor mestre do Sambox clássico
register_sambox_module "🗑️   Central de Desinstalação de Softwares" "menu_uninstall_central"
