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
# Carregando bibliotecas.
# Estas são as bibliotecas necessárias para nossos trabalhos aqui.
library(dplyr)
library(plyr)
library(data.table)

# Escreva na variável abaixo o endereço completo de onde estão os dados que
# serão utilizados. e.g.: '/home/<username>/datafolder/eleicoes2016'
# pasta_aonde_estao_os_dados = '/media/diraol/diraol_ext4/thacker/eleicao2016/'
pasta_aonde_estao_os_dados = NA
if (is.na(pasta_aonde_estao_os_dados)) {
  setwd(getwd())
} else {
  setwd(pasta_aonde_estao_os_dados)
}

# Este pedaço de código comentado foi utilizado para gerar uma "versão final"
# dos dados dos candidatos num arquivo CSV já com cabeçalho.

# cand_names = c(
#                'DATA_GERACAO', 'HORA_GERACAO', 'ANO_ELEICAO', 'NUM_TURNO',
#                'DESCRICAO_ELEICAO', 'SIGLA_UF', 'SIGLA_UE', 'DESCRICAO_UE',
#                'CODIGO_CARGO', 'DESCRICAO_CARGO', 'NOME_CANDIDATO',
#                'SEQUENCIAL_CANDIDATO', 'NUMERO_CANDIDATO', 'CPF_CANDIDATO',
#                'NOME_URNA_CANDIDATO', 'COD_SITUACAO_CANDIDATURA',
#                'DES_SITUACAO_CANDIDATURA', 'NUMERO_PARTIDO', 'SIGLA_PARTIDO',
#                'NOME_PARTIDO', 'CODIGO_LEGENDA', 'SIGLA_LEGENDA',
#                'COMPOSICAO_LEGENDA', 'NOME_LEGENDA', 'CODIGO_OCUPACAO',
#                'DESCRICAO_OCUPACAO', 'DATA_NASCIMENTO',
#                'NUM_TITULO_ELEITORAL_CANDIDATO', 'IDADE_DATA_ELEICAO',
#                'CODIGO_SEXO', 'DESCRICAO_SEXO', 'COD_GRAU_INSTRUCAO',
#                'DESCRICAO_GRAU_INSTRUCAO', 'CODIGO_ESTADO_CIVIL',
#                'DESCRICAO_ESTADO_CIVIL', 'CODIGO_COR_RACA',
#                'DESCRICAO_COR_RACA', 'CODIGO_NACIONALIDADE',
#                'DESCRICAO_NACIONALIDADE', 'SIGLA_UF_NASCIMENTO',
#                'CODIGO_MUNICIPIO_NASCIMENTO', 'NOME_MUNICIPIO_NASCIMENTO',
#                'DESPESA_MAX_CAMPANHA', 'COD_SIT_TOT_TURNO',
#                'DESC_SIT_TOT_TURNO', 'NM_EMAIL'
# )
#
# candidatos <- fread(input='cand-2016.csv', header=FALSE, data.table=FALSE)
# colnames(candidatos) <- cand_names
# write.csv2(candidatos, 'cand-2016_com_header.csv', row.names=FALSE)

# Agora sim vamos ao nosso código....

# Lendo nosso arquivo de candidatos.
candidatos <- fread(input='cand-2016_com_header.csv', data.table=FALSE, sep=';',
                    dec=',', colClasses = list(factor=c('SIGLA_UF', 'SIGLA_UE',
                                                        'DESCRICAO_UE',
                                                        'DESCRICAO_CARGO',
                                                        'DES_SITUACAO_CANDIDATURA',
                                                        'DESCRICAO_SEXO',
                                                        'DESCRICAO_GRAU_INSTRUCAO',
                                                        'DESCRICAO_ESTADO_CIVIL',
                                                        'DESCRICAO_COR_RACA',
                                                        'DESC_SIT_TOT_TURNO')),
                    drop=c('CODIGO_CARGO', 'CPF_CANDIDATO',
                           'COD_SITUACAO_CANDIDATURA', 'CODIGO_OCUPACAO',
                           'CODIGO_SEXO', 'COD_GRAU_INSTRUCAO',
                           'CODIGO_ESTADO_CIVIL', 'CODIGO_COR_RACA',
                           'CODIGO_NACIONALIDADE', 'CODIGO_MUNICIPIO_NASCIMENTO',
                           'COD_SIT_TOT_TURNO'),
                    na.strings='#NULO#')

# Lendo o arquivo de despesas.
despesas <- fread(input='despesas_final.csv', header=TRUE, data.table=FALSE,
                  sep=';', dec=',',
                  select=c('Sequencial Candidato', 'Valor despesa',
                           'Tipo despesa'),
                  colClasses=list(numeric=c('Valor despesa'),
                                  factor=c('Tipo despesa')))

# Apenas ajustando o nome das colunas (variáveis) para ficar igual ou no mesmo
# estilo da base de candidatos(as)
colnames(despesas) <- c('SEQUENCIAL_CANDIDATO', 'VALOR_DESPESA', 'TIPO_DESPESA')

# Eu não sei o motivo, mas o valor receita está sendo importado como string...
# Deve ser por conta da vírgula como separador de decimal, mas deveria funcionar
# mesmo assim. De qualquer forma, vamos substituir as vírgulas por pontos:
despesas$VALOR_DESPESA <- sub(",",".",despesas$VALOR_DESPESA)

# E agora converter para numero mesmo.
despesas$VALOR_DESPESA <- as.numeric(despesas$VALOR_DESPESA)

receitas <- fread(input='receitas.csv', header=TRUE, data.table=FALSE, sep=';',
                  select=c('Sequencial Candidato', 'Valor receita',
                           'Tipo receita', 'Fonte recurso'), dec=',',
                  colClasses=list(numeric=c('Valor receita'),
                                  factor=c('Tipo receita', 'Fonte recurso')))

# Apenas ajustando o nome das colunas (variáveis) para ficar igual ou no mesmo
# estilo da base de candidatos(as)
colnames(receitas) <- c('SEQUENCIAL_CANDIDATO', 'VALOR_RECEITA', 'TIPO_RECEITA',
                        'FONTE_RECURSO')

# Eu não sei o motivo, mas o valor receita está sendo importado como string...
# Deve ser por conta da vírgula como separador de decimal, mas deveria funcionar
# mesmo assim. De qualquer forma, vamos substituir as vírgulas por pontos:
receitas$VALOR_RECEITA <- sub(",",".",receitas$VALOR_RECEITA)

# E agora converter para numero mesmo.
receitas$VALOR_RECEITA <- as.numeric(receitas$VALOR_RECEITA)

# Vamos agora calcular receita e despesa totais e adicionar à base de
# candidatos(as)
candidatos <- candidatos %>% filter(DESCRICAO_CARGO != 'VICE-PREFEITO') %>%
  # Agora adicionando à tabela de candidatos uma coluna com a despesa total
  # daquele(a) candidato(a)
  left_join(despesas %>%
              group_by(SEQUENCIAL_CANDIDATO) %>%
              summarize(DESPESA_TOTAL=sum(VALOR_DESPESA, na.rm=TRUE))
            ) %>%
  # Agora adicionando à tabela de candidatos uma coluna com a receita total
  # daquele(a) candidato(a)
  left_join(receitas %>%
              group_by(SEQUENCIAL_CANDIDATO) %>%
              summarize(RECEITA_TOTAL=sum(VALOR_RECEITA, na.rm=TRUE)))

# Calculando valores por UF, CARGO e SEXO, independente de resultado final. Por
# isso vamos filtra apenas por primeiro turno, assim pegamos todas as pessoas e
# não temos ninguém que se repete para ser contabilizado(a) mais de uma vez.
valores_por_uf_cargo <- candidatos %>%
  filter(NUM_TURNO==1) %>%
  group_by(SIGLA_UF, DESCRICAO_CARGO) %>%
  summarize(DESPESA_UF_CARGO=sum(DESPESA_TOTAL, na.rm=TRUE),
            RECEITA_UF_CARGO=sum(RECEITA_TOTAL, na.rm=TRUE),
            CAND_UNIQ_UF_CARGO=length(unique(SEQUENCIAL_CANDIDATO))) %>% ungroup()

# Calculando valores por UF, CARGO e SEXO, independente de resultado final. Por
# isso vamos filtra apenas por primeiro turno, assim pegamos todas as pessoas e
# não temos ninguém que se repete para ser contabilizado(a) mais de uma vez.
resultados_candidatas <- candidatos %>%
  filter(NUM_TURNO==1) %>%
  group_by(SIGLA_UF, DESCRICAO_CARGO, DESCRICAO_SEXO) %>%
  summarize(DESPESA_UF_CARGO_SEXO=sum(DESPESA_TOTAL, na.rm=TRUE),
            RECEITA_UF_CARGO_SEXO=sum(RECEITA_TOTAL, na.rm=TRUE),
            CAND_UNIQ_UF_CARGO_SEXO=length(unique(SEQUENCIAL_CANDIDATO))) %>%
  # Juntando os valores calculados anteriormente para UF/CARGO
  left_join(valores_por_uf_cargo, by=c('SIGLA_UF', 'DESCRICAO_CARGO')) %>%
  # Agora que temos os dados absolutos por (UF/CARGO) e (UF/CARGO/SEXO),
  # vamos calcular os respectivos percentuais.
  mutate(PERC_DESPESA=round(DESPESA_UF_CARGO_SEXO/DESPESA_UF_CARGO*100,2),
         PERC_RECEITA=round(RECEITA_UF_CARGO_SEXO/RECEITA_UF_CARGO*100,2),
         PERC_CAND=round(CAND_UNIQ_UF_CARGO_SEXO/CAND_UNIQ_UF_CARGO*100,2)) %>%
  ungroup() # %>%
  # Salvano num arquivo externo
  # write.csv2('sumarizacao_pessoas_candidatas.csv', row.names=FALSE)

########################################################
# Agora fazendo o cálculo apenas para quem se elegeu....
########################################################

eleitos <- candidatos %>%
  filter(DESC_SIT_TOT_TURNO %in% c('ELEITO', 'ELEITO POR MÉDIA',
                                   'ELEITO POR QP'))

# Calculando valores por UF, CARGO e SEXO, independente de resultado final. Por
# isso vamos filtra apenas por primeiro turno, assim pegamos todas as pessoas e
# não temos ninguém que se repete para ser contabilizado(a) mais de uma vez.
valores_por_uf_cargo <- eleitos %>%
  filter(NUM_TURNO==1) %>%
  group_by(SIGLA_UF, DESCRICAO_CARGO) %>%
  summarize(DESPESA_UF_CARGO=sum(DESPESA_TOTAL, na.rm=TRUE),
            RECEITA_UF_CARGO=sum(RECEITA_TOTAL, na.rm=TRUE),
            CAND_UNIQ_UF_CARGO=length(unique(SEQUENCIAL_CANDIDATO))) %>% ungroup()

# Calculando valores por UF, CARGO e SEXO, independente de resultado final. Por
# isso vamos filtra apenas por primeiro turno, assim pegamos todas as pessoas e
# não temos ninguém que se repete para ser contabilizado(a) mais de uma vez.
resultados_eleitas <- eleitos %>%
  filter(NUM_TURNO==1) %>%
  group_by(SIGLA_UF, DESCRICAO_CARGO, DESCRICAO_SEXO) %>%
  summarize(DESPESA_UF_CARGO_SEXO=sum(DESPESA_TOTAL, na.rm=TRUE),
            RECEITA_UF_CARGO_SEXO=sum(RECEITA_TOTAL, na.rm=TRUE),
            CAND_UNIQ_UF_CARGO_SEXO=length(unique(SEQUENCIAL_CANDIDATO))) %>%
  # Juntando os valores calculados anteriormente para UF/CARGO
  left_join(valores_por_uf_cargo, by=c('SIGLA_UF', 'DESCRICAO_CARGO')) %>%
  # Agora que temos os dados absolutos por (UF/CARGO) e (UF/CARGO/SEXO),
  # vamos calcular os respectivos percentuais.
  mutate(PERC_DESPESA=round(DESPESA_UF_CARGO_SEXO/DESPESA_UF_CARGO*100,2),
         PERC_RECEITA=round(RECEITA_UF_CARGO_SEXO/RECEITA_UF_CARGO*100,2),
         PERC_CAND=round(CAND_UNIQ_UF_CARGO_SEXO/CAND_UNIQ_UF_CARGO*100,2)) %>%
  ungroup() # %>%
  # Salvano num arquivo externo
  # write.csv2('sumarizacao_pessoas_eleitas.csv', row.names=FALSE)

# Abaixo alguns codigos que ou nao foram utilizados, ou foram checagens pontuais
# ou estão incompletos. Não precisa se preocupar come eles...

###############################################################################
#resultados_candidatas %>% ungroup() %>% filter(DESCRICAO_SEXO=='FEMININO') %>%
#  unite(cargo_sexo, DESCRICAO_CARGO, DESCRICAO_SEXO, sep='-')
#
#cbind(
#  unique(resultados_candidatas$SIGLA_UF),
#  select(resultados_candidatas, SIGLA_UF, DESCRICAO_CARGO, DESCRICAO_SEXO, PERC_CAND) %>% unite(cargo_sexo, DESCRICAO_CARGO, DESCRICAO_SEXO, sep='-') %>% spread(cargo_sexo, PERC_CAND)
#)

#candidatas_roraima <- filter(candidatos, SIGLA_UF=='RR', DESCRICAO_CARGO=='PREFEITO', DESCRICAO_SEXO=='FEMININO')$SEQUENCIAL_CANDIDATO
#candidatos_roraima <- filter(candidatos, SIGLA_UF=='RR', DESCRICAO_CARGO=='PREFEITO', DESCRICAO_SEXO=='MASCULINO')$SEQUENCIAL_CANDIDATO
#despesas_roraima_mulheres <- despesas %>% filter(SEQUENCIAL_CANDIDATO %in% candidatas_roraima) %>% arrange(-VALOR_DESPESA)
#despesas_roraima_homens <- despesas %>% filter(SEQUENCIAL_CANDIDATO %in% candidatos_roraima) %>% arrange(-VALOR_DESPESA)
