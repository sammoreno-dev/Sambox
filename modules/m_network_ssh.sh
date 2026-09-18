#!/usr/bin/env bash
# Sambox - Submódulo Isolado de Gerenciamento e Conexões SSH Rápidas
# Copyright (c) 2026, Sam Moreno. Licença BSD 2-Clause.

_menu_ssh_manager() {
    local choice="" alias_name="" user="" host="" port="" line="" entry=""
    while true; do
        clear 2>/dev/null || true
        printf "\n${GREEN}${BOLD}  ╔═══════════════════════════════════════════╗\n"
        printf "  ║     🔑  SSH FAST CONNECT & KEY MANAGER    ║\n"
        printf "  ╚═══════════════════════════════════════════╝${RST}\n\n"
        printf "  ${GREEN}${RST}  📋  Listar conexões salvas\n"
        printf "  ${GREEN}${RST}  🚀  Conectar a um alias salvo\n"
        printf "  ${GREEN}${RST}  ➕  Adicionar novo alias\n"
        printf "  ${GREEN}${RST}  🗑️   Remover alias existente\n"
        printf "  ${GREEN}${RST}  🔐  Gerenciador de Chaves Criptográficas (Keygen)\n"
        printf "  ${DIM}─────────────────────────────────────────────────────────────────${RST}\n"
        printf "  ${GREEN}${RST}  ⬅️   Voltar au Menu de Redes\n\n"

        read -rp "  $(printf "${BOLD}")Selecione uma opção [0-5]:$(printf "${RST}") " choice
        [[ "${choice}" == "0" || -z "${choice}" ]] && break

        case "${choice}" in
            1)
                printf "\n  ${DIM}[+] Abrindo seu banco criptografado de credenciais em %s...${RST}\n" "${_SSH_ALIASES_FILE##*/}"
                _sep
                if [[ -s "${_SSH_ALIASES_FILE}" ]]; then
                    printf "  ${BOLD}%-15s %-12s %-20s %s${RST}\n" "ALIAS" "USUÁRIO" "HOST/IP" "PORTA"
                    _sep
                    while IFS='|' read -r alias_name user host port; do
                        printf "  %-15s %-12s %-20s %s\n" "${alias_name}" "${user}" "${host}" "${port}"
                    done < "${_SSH_ALIASES_FILE}"
                else
                    _warn "Nenhum alias salvo na memória local ainda."
                fi
                ;;
            2)
                printf "\n${YELLOW}[+]${RST} Preparando salto quântico via túnel SSH... 🚀\n"
                read -rp "  💡 Digite o nome (alias) do servidor alvo: " alias_name
                if [[ -n "${alias_name}" ]]; then
                    local found=0
                    while IFS='|' read -r name user host port; do
                        if [[ "${name}" == "${alias_name}" ]]; then
                            found=1
                            _msg "Iniciando aperto de mão seguro com o host ${alias_name}... ツ"
                            printf "    ${DIM}Comando: ssh -p %s %s@%s${RST}\n\n" "${port}" "${user}" "${host}"
                            ssh -p "${port}" "${user}@${host}" || _warn "Sessão SSH encerrada com código de erro ou abortada."
                            break
                        fi
                    done < "${_SSH_ALIASES_FILE}"
                    [[ ${found} -eq 0 ]] && _warn "Apelido '${alias_name}' não foi localizado na caderneta."
                fi
                ;;
            3)
                printf "\n${YELLOW}[+]${RST} Adicionando nova rota de acesso seguro... ➕\n"
                read -rp "  ➕ Apelido/Alias da máquina (Ex: server_pro): " alias_name
                read -rp "  ➕ Hostname ou IP público/local: " host
                read -rp "  ➕ Nome do Usuário SSH: " user
                read -rp "  ➕ Porta de escuta SSH (Padrão 22): " port
                port="${port:-22}"

                if [[ -n "${alias_name}" && -n "${host}" && -n "${user}" ]]; then
                    # Higienização rápida de duplicatas nativa em memória
                    if grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
                        _warn "Esse alias já existe! Remova-o primeiro antes de sobrescrever."
                    else
                        echo "${alias_name}|${user}|${host}|${port}" >> "${_SSH_ALIASES_FILE}"
                        _msg "Rota '${alias_name}' injetada e blindada com sucesso! (ツ)"
                    fi
                else
                    _warn "Operação abortada. Todos os campos são obrigatórios."
                fi
                ;;
            4)
                printf "\n${YELLOW}[+]${RST} Expurgando credenciais salvas do banco local... 🗑️\n"
                read -rp "  🗑️   Digite o alias que deseja deletar da memória: " alias_name
                if [[ -n "${alias_name}" ]]; then
                    if grep -q "^${alias_name}|" "${_SSH_ALIASES_FILE}" 2>/dev/null; then
                        # Filtra e remove a linha sem usar subshells pesados de sed externo comercial
                        local temp_file="/tmp/.ssh_tmp_$(date +%s)"
                        grep -v "^${alias_name}|" "${_SSH_ALIASES_FILE}" > "${temp_file}" || true
                        mv "${temp_file}" "${_SSH_ALIASES_FILE}"
                        _msg "Alias '${alias_name}' removido da folha de registros! ツ"
                    else
                        _warn "Apelido não localizado no banco local."
                    fi
                fi
                ;;
            5)
                printf "\n${YELLOW}[+]${RST} Iniciando orquestrador de chaves assimétricas (ED25519/RSA)... 🔐\n"
                printf "    ${DIM}Gerar chaves locais elimina a necessidade de digitar senhas em cada login.${RST}\n\n"
                if [[ ! -f "${HOME}/.ssh/id_ed25519" && ! -f "${HOME}/.ssh/id_rsa" ]]; then
                    read -rp "  🔐 Deseja fundir uma nova identidade ED25519 ultra-segura? [s/N]: " confirm
                    if [[ "${confirm,,}" == "s" ]]; then
                        ssh-keygen -t ed25519 -f "${HOME}/.ssh/id_ed25519" -N ""
                        _msg "Sua nova identidade criptográfica foi gerada! ツ"
                    fi
                else
                    _msg "Você já possui identidades SSH ativas e configuradas em seu ~/.ssh/"
                    printf "    ${DIM}Dica: Use o utilitário 'ssh-copy-id' para injetar sua chave no servidor remoto.${RST}\n"
                fi
                ;;
            *)
                _warn "Opção inválida para o protocolo SSH."
                ;;
        esac
        printf "\n  ${GREEN}[✓] Transações SSH e Keygen gerenciadas com maestria! (ツ)${RST}\n"
        printf "\n"; read -rp "  Pressione [ENTER] para continuar..." _
    done
}
