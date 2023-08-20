-- Consultas 
WITH cad_pessoa_cte AS
  (SELECT Cnpj_an,
          Data_credenciamento,
          Data_cancelamento,
          Data_abertura_cnpj,
          Regiao,
          Estado,
          Faturamento_informado,
          Ramo_atividade,
          Porte_Carteira
   FROM spec.cad_pessoa),
     cad_pessoa_enr_cte AS
  (SELECT Cnpj_an,
          Status_receita_federal
   FROM spec.cad_pessoa_enr),
     cad_pessoa_contrato_cte AS
  (SELECT Cnpj_an,
          Numero_terminais,
          Transacionado_mes,
          Aluguel
   FROM spec.cad_pessoa_contrato),
     cad_transacao_cte AS
  (SELECT Cnpj_an,
          COUNT(*) OVER (PARTITION BY Cnpj_an) AS Qtde_transacoes,
                        MEAN(Taxa_MDR) OVER (PARTITION BY Cnpj_an) AS Media_Taxa_MDR
   FROM spec.cad_transacao),
     cad_pessoa_atendimento_cte AS
  (SELECT Cnpj_an,
          MAX(dth_atendimento) OVER (PARTITION BY Cnpj_an) AS Atendimento_rec,
                                    COUNT(*) OVER (PARTITION BY Cnpj_an) AS Atendimento_freq
   FROM spec.cad_pessoa_atendimento) 
-- SELECT DOS DADOA NECESSÁRIOS
SELECT SHA2(cad_pessoa_cte.Cnpj_an, 256) AS Cnpj_an,
       Data_credenciamento,
       Data_cancelamento,
       Data_abertura_cnpj,
       Regiao,
       Estado,
       Faturamento_informado,
       Ramo_atividade,
       Porte_Carteira,
       cad_pessoa_enr_cte.Status_receita_federal,
       cad_pessoa_contrato_cte.Numero_terminais,
       cad_pessoa_contrato_cte.Transacionado_mes,
       cad_pessoa_contrato_cte.Aluguel,
       cad_transacao_cte.Qtde_transacoes,
       cad_transacao_cte.Media_Taxa_MDR,
       cad_pessoa_atendimento_cte.Atendimento_rec,
       cad_pessoa_atendimento_cte.Atendimento_freq,
       CASE
           WHEN Data_cancelamento IS NOT NULL THEN 1
           ELSE 0
       END AS Churn
FROM cad_pessoa_cte
LEFT JOIN cad_pessoa_enr_cte ON cad_pessoa_cte.Cnpj_an = cad_pessoa_enr_cte.Cnpj_an
LEFT JOIN cad_pessoa_contrato_cte ON cad_pessoa_cte.Cnpj_an = cad_pessoa_contrato_cte.Cnpj_an
LEFT JOIN cad_transacao_cte ON cad_pessoa_cte.Cnpj_an = cad_transacao_cte.Cnpj_an
LEFT JOIN cad_pessoa_atendimento_cte ON cad_pessoa_cte.Cnpj_an = cad_pessoa_atendimento_cte.Cnpj_an;
