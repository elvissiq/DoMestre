#include "rwmake.ch"
#include "topconn.ch

/*/{Protheus.doc} M030INC
	Ponto de Entrada após a inclusão do cliente
	@type  Function
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 07/01/2022
	@version 1.0
	@param 
	@return 
	@example
	(examples)
	@see https://tdn.totvs.com/pages/viewpage.action?pageId=6784136
/*/          

User Function M030INC           
    Local _nOp     := PARAMIXB
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaCTD := CTD->(GetArea())
	
	if _nOp <> 3
		DbSelectArea("CTD")                                	
		CTD->(DbSetOrder(1))
		
		If !(CTD->(DbSeek(xFilial("CTD")+"C"+SA1->A1_COD+SA1->A1_LOJA)))	                     
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xFilial("CTD")
			CTD->CTD_ITEM  	:= "C"+SA1->A1_COD+SA1->A1_LOJA
			CTD->CTD_CLASSE	:= "2"
			CTD->CTD_DESC01	:= SA1->A1_NOME
			CTD->CTD_BLOQ	:= "2"
		   	CTD->CTD_DTEXIS := CTOD("01/01/1980")
		   	CTD->CTD_ITLP   := "C"+SA1->A1_COD+SA1->A1_LOJA
		   	SA1->A1_XITEMCC  := "C"+SA1->A1_COD+SA1->A1_LOJA
			CTD->(MsUnLock())	     
		EndIF

		//Grava Perfil Cliente na empresa Transmate
		If ((ExistBlock("MY_TMSA480G")))
			ExecBlock("MY_TMSA480G",.F.,.F.)			
		Endif

		//Grava Contrato do Cliente na empresa Transmate
		/*
		If ((ExistBlock("MYTA250B")))
			ExecBlock("MYTA250B",.F.,.F.)			
		Endif
		*/
	endif
	
RestArea(aAreaSA1)
RestArea(aAreaCTD)

Return


