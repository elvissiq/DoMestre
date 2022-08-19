#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Fwmvcdef.ch"
#INCLUDE "Tbiconn.ch"

/*/{Protheus.doc} MYTA250 
Rotina Gera Contrato Cliente
@type function
@version 
@author TOTVS Nordeste
@since 06/01/2022
@return
/*/

User Function MYTA250()

    // GERA A TELA DE PROCESSAMENTO
	Processa( {|| MYTA250A() },"Aguarde...", "Processando inclusões de Contrato de Prestação de Serviço...",.T.)

Return 

/*/{Protheus.doc} MYTA250A
	Função para consultar clientes que não possuem contrato criado
	@type  Static Function
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 06/01/2022
	@version 1.0
	@param 
	@return 
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function MYTA250A()
Local cQry    := ""
Local nAtual  := 0
Local nTotal  := 0

   cQry := " SELECT SA1.A1_FILIAL, SA1.A1_COD, SA1.A1_LOJA " +CRLF
   cQry += " FROM " + RetSqlName("SA1") + " SA1 " +CRLF
   cQry += " WHERE SA1.D_E_L_E_T_ <> '*' " +CRLF
   cQry += "   AND SA1.A1_FILIAL = '"+FwxFilial("SA1")+"' " +CRLF
   cQry += "   AND SA1.A1_COD  NOT IN (SELECT AAM.AAM_CODCLI FROM " + RetSqlName("AAM") + " AAM "
   cQry += " WHERE AAM.D_E_L_E_T_ <> '*') "

   cQry := ChangeQuery(cQry)

   IF Select("TMPQRY") > 0
        TMPQRY->(DbCloseArea())
   EndIf

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPQRY",.T.,.T.)

	While !TMPQRY->(EoF()) //Quantidade de clientes
		nTotal++
	  TMPQRY->(dbSkip())
	EndDo

	ProcRegua(nTotal)
	TMPQRY->(DbGoTop())

	While ! TMPQRY->(EoF()) 
		
		nAtual++
		
		IncProc("Analisando Cliente x Contrato " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ".")
		Sleep(300)
		ProcessMessage() //FORÇA O DESCONGELAMENTO DO SMARTCLIENT

			U_MYTA250B() //Função do ExecAuto TECA250

	  TMPQRY->(dbSkip())
    EndDo

	TMPQRY->(DbCloseArea())
	FWAlertSuccess("Processo de inclusão finalizado!", "Contrato de Prestação de Serviço")

Return

/*/{Protheus.doc} MYTA250B
	Função que executa a Rotina Automática TECA250 - Contrato Cliente
	@type  User Function
	@author TOTVS Nordeste (Elvis Siqueira)
	@since 06/01/2022
	@version 1.0
	@param 
	@return 
	@example
	(examples)
	@see (https://tdn.totvs.com/display/PROT/1721369+DLOGTMS02-475+DT+Execauto+TECA250+-+Contrato+do+Cliente)
/*/
User Function MYTA250B()
Local aArea       := GetArea()
Local aErro       := {}
Local oMdlTeca250 := nil
Local oMdl250     := nil
Local oMdGridDDA  := nil
Local oMdGridDDC  := nil
Local cContrato   := ""
Local cErro       := ""
Local cCodCli     := ""
Local cLojCli     := ""
Local nId         := 0

Private INCLUI := .T.
Private ALTERA := .F.

	oMdlTeca250 := FwLoadModel("TECA250")

	oMdl250 := oMdlTeca250:GetModel("MdFieldCAAM")
	oMdGridDDC := oMdlTeca250:GetModel("MdGridIDDC")
	oMdGridDDA := oMdlTeca250:GetModel("MdGridIDDA")

	oMdlTeca250:SetOperation(3)
	oMdlTeca250:activate()

	If FunName() == 'TECA250'
		cCodCli  := TMPQRY->A1_COD
		cLojCli  := TMPQRY->A1_LOJA
	 Else	
		cCodCli  := SA1->A1_COD
		cLojCli  := SA1->A1_LOJA
		cFilAnt  := "020101" //Loga na Filial Transmate
	EndIf 

	DbSelectArea("AAM")                                	
		AAM->(DbSetOrder(2)) //AAM_FILIAL+AAM_CODCLI+AAM_LOJA+AAM_CLASSI 
		If !(AAM->(DbSeek(FWxFilial("AAM")+cCodCli+cLojCli)))

			cContrato := GetSxeNum("AAM","AAM_CONTRT")

			oMdl250:setValue("AAM_CONTRT" , cContrato )
			oMdl250:setValue("AAM_CODCLI" , cCodCli   )
			oMdl250:setValue("AAM_LOJA"   , cLojCli   )
			oMdl250:setValue("AAM_TPCONT" , "1"       )
			oMdl250:setValue("AAM_CLASSI" , "006"     )
			oMdl250:setValue("AAM_ABRANG" , "1"       )
			oMdl250:setValue("AAM_STATUS" , "1"       )
			oMdl250:setValue("AAM_INIVIG" , Date()    )
			oMdl250:setValue("AAM_CPAGPV" , "006"     )
			oMdl250:setValue("AAM_TIPFRE" , "3"       )
			oMdl250:setValue("AAM_NFCTR"  , 1         )
			
			M->DDC_NCONTR := cContrato

			oMdGridDDC:setValue("DDC_ITEM"   , strZero(1, TamSx3("DDC_ITEM")[1]) )
			oMdGridDDC:setValue("DDC_CODNEG" , "01"   )
			oMdGridDDC:setValue("DDC_TPCONT" , "1"    )
			oMdGridDDC:setValue("DDC_INIVIG" , Date() )
			
			M->DDA_CODNEG := "01"
			M->DDA_NCONTR := cContrato
			For nId := 1 To 2
				oMdGridDDA:setValue("DDA_ITEM"   , StrZero(nId, tamSx3("DDA_ITEM")[1]) )
				oMdGridDDA:setValue("DDA_SERVIC" , IF(nId==1,"018","019") )
				oMdGridDDA:setValue("DDA_FATCUB" , 300 )
				oMdGridDDA:setValue("DDA_TABFRE" , "0002" )
				oMdGridDDA:setValue("DDA_TIPTAB" , "01"  )
				oMdGridDDA:setValue("DDA_SRVCOL" , "009" )
				If nId < 2
					oMdlTeca250:GetModel("MdFieldCAAM"):AddLine()
				EndIF 
			Next nId 

			If oMdlTeca250:vldData()
				If !oMdlTeca250:commitData()
						
						RollBackSX8() //Função que estorna a numeração usada pelo GetSXENum
						
						cErro := ""
						aErro := oMdlTeca250:getErrorMessage()
						For nId := 1 To Len(aErro)
							If !Empty(cErro)
								cErro += CRLF
							EndIf
							If aErro[nId] <> Nil
								cErro += aErro[nId]
							EndIf
						Next nId
						
						FWAlertError(cErro,"Erro durante a gravação!"+CRLF+"Cliente Cód./Loja: "+cCodCli+"/"+cLojCli)

				EndIf
			 Else
			 	
				RollBackSX8() //Função que estorna a numeração usada pelo GetSXENum
			 	
				cErro := ""
				aErro := oMdlTeca250:getErrorMessage()
				For nId := 1 To Len(aErro)
					If !Empty(cErro)
						cErro += CRLF
					EndIf
					If aErro[nId] <> Nil
						cErro += aErro[nId]
					EndIf 
				Next nId
				
				FWAlertError(cErro,"Erro durante a validacão!"+CRLF+"Cliente Cód./Loja: "+cCodCli+"/"+cLojCli)

			EndIf

		EndIF

RestArea(aArea)

Return
