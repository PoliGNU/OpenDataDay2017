#!/bin/bash
#
###############################################################################
# Copyright (C) 2016 Diego Rabatone Oliveira
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

# Este script serve para agregar arquivos de candidato advindos diretamente
# da base do TSE:
# http://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais
#
# Para executá-lo chame o script passando os argumentos requisitados. e.g.:
# ./agregador_candidatos_por_ano candidatos 2016 candidatos-agregado
#
# O primeiro argumento é o diretório aonde estão os arquivos do TSE separados
# por estado.
# O segundo argumento é o ano ao qual a eleição se refere.
# O terceiro argumento é o nome do arquivo que você quer na saída.
#
# Este script considera os arquivos do TSE separados por estado e sem cabeçalho
# com o nome das colunas/variáveis.
#
# O arquivo de saída também já converte os dados para UTF-8.

if [[ $# -lt 3 ]] ; then
    echo 'Argumentos: <diretorio> <ano> <nome>'
    exit 1
fi

DIR=$1
ANO=$2
NOME="$3-$2.csv"

# Get the list of csv files on the current folder that would be read
cd $1
FILES=`ls *.txt`

# Convert all CSV files from ISO-8859-1 to UTF-8, generating new files
#    wich names began with 'utf8_'
for FILE in $FILES;
  do
    iconv -f 'ISO-8859-1' -t 'UTF-8' $FILE > utf8_$FILE;
done

# For each CSV copy the content, without the header, to the final file
for FILE in $FILES;
  do
    cat utf8_$FILE >> $NOME;
done
