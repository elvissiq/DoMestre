#Include "TOTVS.CH"

/*/{Protheus.doc} AT250ROT

Esse ponto de entrada é utilizado para a adição de itens no menu principal (aRotina)
 da rotina de Contrato de Prestação de Serviços (TECA250).

Retorno
aRet(vetor)
Array com os itens a serem adicionados no menu principal (aRotina).

@type function
@author TOTVS NORDESTE
@since 06/01/2022

@history 
/*/
User Function AT250ROT()
Local aRet := {}

     aAdd(aRet, {'Gerar Contrato','U_MYTA250', 0 , 2} )

Return aRet
