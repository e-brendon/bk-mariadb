#!/bin/bash
###################################################################
# Nome : db_backup.sh
# Autor: Brendon
# Testado: Ubuntu 22.04
# Shell: bash 
###################################################################

# Changelog
# Iniciando o script

##### Variáveis 
declare DATA=`date +%Y%m%d_%H%M%S`
declare DIR_BACKUP="/your_dir/"  # Define o diretório de backup
declare SENHA="your_password"	 # Define a senha do seu sistema 
declare USER="root"
DIR_DEST_BACKUP=$DIR_BACKUP$DATA
###################################################################

##### Rotinas secundárias
mkdir -p $DIR_BACKUP/$DATA # Cria o diretório de backup diário
echo "MYSQL"
echo "Iniciando backup do banco de dados"
##################################################################

# Função que executa o backup
executa_backup(){
    echo "Início do backup $DATA"
    # Recebe os nomes dos bancos de dados na máquina destino
    BANCOS=$(mysql -u $USER -p$SENHA -e "show databases")

    declare CONT=0

    # Inicia o laço de execução dos backups
    for banco in $BANCOS
    do
        if [ $CONT -ne 0 ]; then    # Ignora o primeiro item do array, cujo conteúdo é "databases"
            NOME="backup_my_"$banco"_"$DATA".sql"

            echo "Iniciando backup do banco de dados [$banco]"
            # Comando que realmente executa o dump do banco de dados 
            mysqldump --hex-blob --lock-all-tables -u $USER -p$SENHA --databases $banco > $DIR_DEST_BACKUP/$NOME

            # Verifica se o comando foi bem-sucedido
            if [ $? -eq 0 ]; then
                echo "Backup Banco de dados [$banco] completo"
            else
                echo "ERRO ao realizar o Backup do Banco de dados [$banco]"
            fi
        fi
        CONT=`expr $CONT + 1`
    done

    DATA=`date +%Y%m%d_%H%M%S`
    echo "Final do backup: $DATA"
}

# Função para remover backups antigos, mantendo apenas as últimas 4 versões
remove_antigos(){
    echo "Removendo backups antigos"
    
    # Lista os diretórios de backup, ordena por data e remove os mais antigos
    BACKUPS=$(ls -dt $DIR_BACKUP*/)
    COUNT=$(echo "$BACKUPS" | wc -l)

    # Verifica se o número de backups é maior que 4
    if [ $COUNT -gt 4 ]; then
        REMOVE_COUNT=$(expr $COUNT - 4)	#define a quantidade de versões que deseja ter 
        BACKUPS_REMOVER=$(echo "$BACKUPS" | tail -n $REMOVE_COUNT)

        # Remove os backups antigos
        for OLD_BACKUP in $BACKUPS_REMOVER
        do
            echo "Removendo backup antigo: $OLD_BACKUP"
            rm -rf $OLD_BACKUP
        done
    else
        echo "Nenhum backup antigo para remover."
    fi
}

# Executa o backup e redireciona o log para o diretório de backup
executa_backup 2>> $DIR_BACKUP/$DATA/dbdump.log 1>> $DIR_BACKUP/$DATA/dbdump.log

# Remove backups antigos
remove_antigos

###################################################################
