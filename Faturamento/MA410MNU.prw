#Include "TOTVS.CH"

/*/{Protheus.doc} MA410MNU

Este ponto de entrada pode ser utilizado para inserir novas opções no array aRotina.

@type function
@author TOTVS NORDESTE
@since 21/09/2021

@history 
/*/
User Function MA410MNU()
	  If !IsBlind() 
               aAdd(aRotina,{'Importar Pedido','U_IMPPEDIDO',0,3,0,NIL})
     EndIf 

Return Nil 
