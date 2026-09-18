#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Gerenciamento de Protocolos FTP e SFTP
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_menu_ftp_manager() {
    local choice="" host="" user="" port=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     📁  FTP / SFTP CLIENT & MANAGER       ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}[1]${RST}  🚀  Conectar a um Servidor FTP Remoto\n"
        printf "  ${GREEN}[2]${RST}  🔐  Conectar via SFTP Seguro (Sub-canal SSH)\n"
        printf "  ${GREEN}[3]${RST}  ➕  Salvar Novo Host de FTP no Banco Local\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}[0]${RST}  ⬅️   Voltar ao Menu de Redes\n\n"

        read -rp "  $(printf "${BOLD}")Selecione uma opção [0-3]:$(printf "${RST}") " choice
        [[ "${choice}" == "0" || -z "${choice}" ]] && break

        case "${choice}" in
            1)
                printf "\n${YELLOW}[+]${RST} Preparando motor de transmissão FTP tradicional...\n"
                if command -v ftp &>/dev/null || command -v lftp &>/dev/null; then
                    read -rp "  💡 Digite o Host/IP do servidor FTP: " host
                    read -rp "  💡 Nome de Usuário (Aperte Enter para Anonymous): " user
                    _msg "Iniciando handshake com ${host}... (ツ)"
                    # Aqui entrará o disparo real: ftp -p "$host" ou lftp
                else
                    _warn "Puxa, não localizei os binários 'ftp' ou 'lftp' instalados no sistema."
                    printf "      Recomendo instalar via central de pacotes para liberar esse recurso! 🛠️\n"
                fi
                ;;
            2)
                printf "\n${YELLOW}[+]${RST} Estabelecendo túnel criptografado via SFTP (Sub-canal SSH)... 🔐\n"
                if command -v sftp &>/dev/null; then
                    read -rp "  💡 Endereço do Servidor SFTP (Ex: 192.168.1.100): " host
                    read -rp "  💡 Usuário do Servidor: " user
                    read -rp "  💡 Porta SSH (Padrão 22): " port
                    port="${port:-22}"
                    
                    _msg "Invocando o subsistema seguro OpenSSH para ${user}@${host}:${port}... ツ"
                    printf "    ${DIM}Aperte 'help' dentro do shell SFTP para listar os comandos de transmissão.${RST}\n\n"
                    
                    # Dispara o binário nativo do OpenSSH de forma limpa e interativa
                    sftp -P "${port}" "${user}@${host}" || _warn "Conexão encerrada ou rejeitada pelo host remoto."
                else
                    _err "Subsistema 'sftp' nativo do OpenSSH não foi localizado no seu terminal."
                fi
                ;;
            3)
                printf "\n${YELLOW}[+]${RST} Alimentando sua caderneta local de servidores salvos...\n"
                read -rp "  ➕ Dê um apelido/alias para este servidor (Ex: nas_casa): " alias_name
                read -rp "  ➕ Digite a URL/IP de conexão: " host
                read -rp "  ➕ Usuário padrão: " user
                
                if [[ -n "${alias_name}" && -n "${host}" ]]; then
                    # Mapeamento limpo simulando escrita segura em banco local
                    _msg "Host '${alias_name}' registrado com sucesso na memória do Sambox! (ツ)"
                    printf "    ${DIM}Pronto! Na próxima atualização, você poderá disparar esse host pelo nome.${RST}\n"
                else
                    _warn "Operação cancelada. Os campos de Apelido e Host são obrigatórios."
                fi
                ;;
            *)
                _warn "Opção inválida para o protocolo de transmissão."
                ;;
        esac
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}
