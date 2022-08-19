#Include "TOTVS.CH"

/*/{Protheus.doc} TM480MNU

Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.

@type function
@author TOTVS NORDESTE
@since 13/12/2021

@history 
/*/
User Function TM480MNU()
	  If !IsBlind() 
               aAdd(aRotina,{'Gerar Perfil','U_MYTMSA480',0,3,0,NIL})
     EndIf 

Return Nil 
