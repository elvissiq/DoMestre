#INCLUDE 'totvs.ch'

/*/{Protheus.doc} MYTMSA480 
Rotina Automática TMSA480 - Perfil do Cliente
@type function
@version 
@author TOTVS Nordeste (Elvis Siqueira)
@since 13/12/2021
@return
/*/

User Function MYTMSA480()
Local oSay := NIL // CAIXA DE DIÁLOGO GERADA

    // GERA A TELA DE PROCESSAMENTO
    FwMsgRun(NIL, {|oSay| MYTMSA480(oSay)}, "Aguarde...", "Processando inclusões de Perfil do Cliente ...")

Return 

/*/{Protheus.doc} MYTMSA480 
Rotina Automática TMSA480 - Perfil do Cliente
@type Static function
@version 1.0
@author TOTVS Nordeste (Elvis Siqueira)
@since 13/12/2021
@return
/*/

Static Function MYTMSA480(oSay)

  Local cQry  := ""
	
   cQry := " SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA " +CRLF
   cQry += " FROM " + RetSqlName("SA1") + " SA1 " +CRLF
   cQry += " WHERE SA1.D_E_L_E_T_ <> '*' " +CRLF
   cQry += "   AND SA1.A1_FILIAL = '"+FwxFilial("SA1")+"' " +CRLF
   cQry += "   AND SA1.A1_COD  NOT IN (SELECT DUO.DUO_CODCLI FROM " + RetSqlName("DUO") + " DUO "
   cQry += " WHERE DUO.D_E_L_E_T_ <> '*') "

   cQry := ChangeQuery(cQry)

   IF Select("TMPQRY") > 0
        TMPQRY->(DbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPQRY",.T.,.T.)

	// SIMULA A PREPARAÇÃO PARA EXECUÇÃO
    Sleep(2000)

	While ! TMPQRY->(EoF()) 

		U_MY_TMSA480G() //Função que gravar o Perfil do Cliente

	  TMPQRY->(dbSkip())
    EndDo

	TMPQRY->(DbCloseArea())
	FWAlertSuccess("Processo finalizado!", "Perfil do Cliente")
Return

/*/{Protheus.doc} MY_TMSA480G
	Rotina Automática TMSA480 - Perfil do Cliente
	@type  MY_TMSA480G
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 07/01/2022
	@version 1.0
/*/

User Function MY_TMSA480G()

Local cCodCli     := ""
Local cLojCli     := ""	

	If FunName() == 'TMSA480'
		cCodCli  := TMPQRY->A1_COD
		cLojCli  := TMPQRY->A1_LOJA
	 Else	
		cCodCli  := SA1->A1_COD
		cLojCli  := SA1->A1_LOJA
		cFilAnt  := "020101" //Loga na Filial Transmate
	EndIf 

		DbSelectArea("DUO")                                	
		DUO->(DbSetOrder(1))
		If !(DUO->(DbSeek(FWxFilial("DUO")+cCodCli+cLojCli)))	                     
			RecLock("DUO",.T.)
				//Aba Comercial
				DUO->DUO_FILIAL := FWxFilial("DUO")
				DUO->DUO_CODCLI := cCodCli
				DUO->DUO_LOJCLI := cLojCli
				DUO->DUO_CNDFRE := "01"
				DUO->DUO_FOBDIR := "2"
				DUO->DUO_CUBAGE := "1"
				DUO->DUO_TAXCTR := "1"
				DUO->DUO_PESCTR := 999999.9999
				DUO->DUO_NFCTR  := 99999
				DUO->DUO_AJUOBR := "2"
				DUO->DUO_AGRNFC := "2"
				DUO->DUO_RECFRE := "1"
				DUO->DUO_TPDIAS := "2"
				DUO->DUO_PRCPRD := "1"
				DUO->DUO_ESTAGR := "1"
				DUO->DUO_RRE    := "0"
				//Aba Financeiro
				DUO->DUO_BASFAT := "2"
				DUO->DUO_TIPFAT := "02"
				DUO->DUO_QTDCTR := 99999
				DUO->DUO_SEPPRO := "2"
				DUO->DUO_SEPTRA := "2"
				DUO->DUO_SEPFRE := "2"
				DUO->DUO_SEPREM := "0"
				DUO->DUO_SEPENT := "2"
				DUO->DUO_SEPSRV := "2"
				DUO->DUO_SEPNEG := "2"
				//Aba Reentrega
				DUO->DUO_PGREEN := "2"
				DUO->DUO_BASREE  := "1"
				DUO->DUO_TPCALC  := "1"
				//Aba Refaturamento
				DUO->DUO_PGREFA := "2"
				//Aba Armazenagem
				DUO->DUO_PGARMZ := "2"
				//Aba EDI
				DUO->DUO_EDIAUT := "1"
				DUO->DUO_EDILOT := "1"
				DUO->DUO_EDIFRT := "2"
				DUO->DUO_AGEAUT := "2"
				//Aba Outros
				DUO->DUO_INCOMP := "2"
				DUO->DUO_MULTFA := "2"
		    DUO->(MsUnLock())
		EndIF

Return

