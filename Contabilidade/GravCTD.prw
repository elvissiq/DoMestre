#INCLUDE "TOTVS.CH" 

#DEFINE TIPO_CLIENTE		"CLI"
#DEFINE TIPO_FORNECEDOR		"FOR"
#DEFINE OPCAO_SINTETICO		"1"
#DEFINE OPCAO_ANALITICO		"2"
#DEFINE OPCAO_SIM			"1"
#DEFINE OPCAO_NAO			"2"

/*/{Protheus.doc} GravCTD

Esta rotina tem como objetivo criar de forma autom�tica os itens contab�is quando o cliente ou fornecedor n�o
tiver item contabil associado ao mesmo. A Rotina � utilizada nos lan�amentos padr�es.
	
@type function
@author Analista CSA
@since 22/05/2012
@version P11,P12
@database MSSQL,Oracle

@history 13/04/2015, Helcio e Heittor - MAFRA, Revis�o para atualiza��o do nome do cliente qdo classe de valor j� existe 
@history 16/01/2017, Maur�cio Urbinati de P�dua, convers�o MSSQL -> Oracle | P11 -> P12 | Ajuste ProtheusDoc
@history 07/06/2017, Carlos Eduardo Niemeyer Rodrigues, Tratamentos CleanCode + Ajustes quando o Cliente/Fornecedor n�o encontrado + Ajustes de Performance Busca de Cliente/Fornecedor + Ajustes Retorno da Fun��o + Tamanho do C�digo+Loja do Cliente conforme dicion�rio de dados do Protheus (AvKey)
@history 27/06/2017, Carlos Eduardo Niemeyer Rodrigues, Ajustes Par�metros de Entrada e Ajustes dbSeek

@todo Usar Rotina Autom�tica CTBA040 para Inclus�o/Altera��o do Item Cont�bil

@param cTipoCliFor, String, Tipo de Cliente/Fornecedor - Op��es: CLI / FOR - Padr�o: ""
@param cCodCliFor, String, C�digo da Chave do Cliente/Fornecedor - C�digo+Loja - Padr�o: ""

@return cRet C�digo do Item Cont�bil Inclu�do/Alterado
/*/
User Function GravCTD(cTipoCliFor,cCodCliFor)
	Local cAliasSav		:= Alias()
	Local aAreas		:= Lj7GetArea({"SA1","SA2","CTD"})
	Local cRet			:= ""
		
	Default cTipoCliFor	:= ""
	Default cCodCliFor	:= ""	
	
	cRet := adicionaItemContabil(cCodCliFor,cTipoCliFor)
	
	Lj7RestArea(aAreas)
	dbSelectArea(cAliasSav)
	
Return cRet

/*
	Adiciona/Atualiza Item Cont�bil na Tabela Padr�o do Protheus
*/
Static Function adicionaItemContabil(cCodCliFor,cTipoCliFor)	
	Local cItemContabil	:= ""
	Local cNomeCliFor	:= ""
	Local lFindCliFor	:= .F.
	Local nTamCliFor	:= 0
	Local cRet			:= ""
	
	If !Empty(cCodCliFor) .And. !Empty(cTipoCliFor)
		nTamCliFor 		:= Len(Avkey("","A1_COD"))
		nTamCliFor 		+= Len(Avkey("","A1_LOJA"))
		cCodCliFor 		:= SubStr(cCodCliFor,01,nTamCliFor)		
		
		If cTipoCliFor == TIPO_CLIENTE
			dbSelectArea("SA1")
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If ( lFindCliFor := SA1->(MsSeek(xFilial("SA1")+cCodCliFor)) )
				cNomeCliFor 	:= SA1->A1_NOME
				cItemContabil	:= "C" + cCodCliFor
			Endif
			
		ElseIf cTipoCliFor == TIPO_FORNECEDOR
			dbSelectArea("SA2")
			SA2->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			If ( lFindCliFor := SA2->(MsSeek(xFilial("SA2")+cCodCliFor)) )
				cNomeCliFor 	:= SA2->A2_NOME
				cItemContabil	:= "F" + cCodCliFor
			Endif
		Endif

		If lFindCliFor
			dbSelectArea("CTD")
			CTD->(dbSetOrder(1)) //CTD_FILIAL+CTD_ITEM
			If !( CTD->(dbSeek(xFilial("CTD")+cItemContabil)) )
				RecLock("CTD",.T.)
					CTD->CTD_FILIAL    := xFilial("CTD")
					CTD->CTD_ITEM	   := cItemContabil
					CTD->CTD_CLASSE    := OPCAO_ANALITICO //Classe - 1=Sintetico;2=Analitico
					CTD->CTD_DESC01    := cNomeCliFor
					CTD->CTD_BLOQ      := OPCAO_NAO //Item Bloqueado
					CTD->CTD_CLOBRG    := OPCAO_NAO //Classe de Valor Obrigat.
					CTD->CTD_ACCLVL    := OPCAO_SIM //Aceita Classe de Valor
					//CTD->CTD_DTEXIS := DDATABASE
					//CTD->CTD_ITLP   := cItemContabil
				CTD->(MsUnlock())
				
				cRet := AvKey(cItemContabil,"CTD_ITEM")
			Else
				RecLock("CTD",.F.)
					CTD->CTD_DESC01	:= cNomeCliFor
				CTD->(MsUnlock())
				
				cRet := CTD->CTD_ITEM
			EndIf
		Else
			ConOut("[GRAVCTD] Chave Informada de Cliente/Fornecedor n�o existe - Chave: '" + cCodCliFor + "' - Tipo '" + cTipoCliFor + "'")
		Endif
	Endif

Return cRet
