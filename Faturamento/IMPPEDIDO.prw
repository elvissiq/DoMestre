#INCLUDE 'totvs.ch'

/*/{Protheus.doc} IMPPEDIDO
Importação de Pedido de Venda
@type function
@version 
@author TOTVS Nordeste
@since 07/12/2021
@return
/*/
User Function IMPPEDIDO()

	Private  aPedido := {}
	Private  aItem   := {}
	Private  lMsErroAuto    := .F.
    Private  lAutoErrNoFile := .F.
	
	
	Processa( {|lEnd| RunProcA()}, "Aguarde...","Lendo Arquivo - Pedido de Venda", .T. )
	
	If Len(aItem) > 0
		FWMsgRun(, {|oSay| RunProcB(oSay) }, "Aguarde", "Gravando Pedido de Venda...")
	Endif
Return Nil

/*/{Protheus.doc} RunProcA
Ler arquivo .CSV
@type function
@version 
@author TOTVS Nordeste
@since 07/12/2021
@return 
/*/

Static Function RunProcA()

	Local aLinC     := {} 
	Local aLinI     := {}
	Local aCbAux    := {}
	Local aItAux    := {}
	Local aLinha    := {}
	Local aRetX3    := {}
	Local cArq      := ".txt"
	Local cLinha    := ""
	Local cLog      := ""
	Local cCampo    := ""
	Local cTipoX3   := ""
	Local cCtd      := ""
	Local nIgual    := 0
	Local nAux      := 0
	Local x
	
	Private aErro   := {}
	Private cTipo   := "Database (*.txt) | *.txt | "

	cArq := cGetFile(cTipo,"TOTVS - Pedido de Venda",,"C:\TOTVS")
	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","ATENCAO")
		Return
	EndIf
	cLog += "PEDIDO"  + CHR(13)+CHR(10)
	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	
		While !FT_FEOF()
			
			cLinha := FT_FREADLN()
			
			If !Empty(cLinha) .And. SUBSTR(cLinha,1,2) == "C5"  //Monta SC5 - Cabeçalho do Pedido
				aCbAux := {}
				++nAux

					aLinC := Separa(cLinha,";",.T.)
					
					For x := 1 To Len(aLinC)
					 aLinha := {}
						nIgual := AT( "=", aLinC[x] )

						cCampo  := SUBSTR(aLinC[x],1,nIgual-1)
						aRetX3  := TamSX3(cCampo)
						cTipoX3 := aRetX3[3]

						//Converte de Caracter para o tipo do campo da SX3
						If cTipoX3 == "N"
							cCtd := Val(SUBSTR(aLinC[x],nIgual+1,Len(aLinC[x]))) //Converte p/ Númerico
						 ElseIf cTipoX3 == "D"
							cCtd := CToD(SUBSTR(aLinC[x],nIgual+1,Len(aLinC[x]))) //Converte p/ Data
						 ElseIf cTipoX3 $ ('C,M')
						 	cCtd := SUBSTR(aLinC[x],nIgual+1,Len(aLinC[x])) //Não converte
						EndIf 
						
						aAdd( aLinha, { cCampo,; //Campo
										 cCtd,; //Conteúdo
										 Nil } ) 
					 aAdd(aCbAux, aLinha)
					Next x
					
				aAdd(aPedido, aCbAux)	
					
			 ElseIf !Empty(cLinha) .And. SUBSTR(cLinha,1,2) == "C6" //Monta SC6 - Itens do Pedido
				aItAux := {}

				aLinI := Separa(cLinha,";",.T.)
				
				For x := 1 To Len(aLinI)
					 aLinha := {}
						nIgual := AT( "=", aLinI[x] )
						
						cCampo  := SUBSTR(aLinI[x],1,nIgual-1)
						aRetX3  := TamSX3(cCampo)
						cTipoX3 := aRetX3[3]

						//Converte de Caracter para o tipo do campo da SX3
						If cTipoX3 == "N"
							cCtd := Val(SUBSTR(aLinI[x],nIgual+1,Len(aLinI[x]))) //Converte p/ Númerico
						 ElseIf cTipoX3 == "D"
							cCtd := CToD(SUBSTR(aLinI[x],nIgual+1,Len(aLinI[x]))) //Converte p/ Data
						 ElseIf cTipoX3 $ ('C,M')
						 	cCtd := SUBSTR(aLinI[x],nIgual+1,Len(aLinI[x])) //Não converte
						EndIf 

						aAdd(aLinha,{ cCampo,; //Campo
									  cCtd,; //Conteúdo
									  Nil } ) 
					 aadd(aItAux, aLinha) 
				Next x

					aadd(aItem, aItAux)

			Endif
		 FT_FSKIP()
		EndDo

	FT_FUSE()
Return

/*/{Protheus.doc} RunProcB
Inclui Pedido de Venda via MSExecAuto (MATA410)
@type function
@version 
@author TOTVS Nordeste
@since 07/12/2021
@return 
/*/

Static Function RunProcB(oSay)
  Local aCab      := {}
  Local aItAux    := {}
  Local aItens    := {}
  Local cNumPed   := ""
  Local cNumPedIt := ""
  Local nPosPed   := 0
  Local nPosPedIt := 0
  Local x, i, y


   	For x := 1 To Len(aPedido)

		aCab   := {}
		aItens := {}

			nPosPed := aScan(aPedido[x],{|x| AllTrim(x[1][1]) == "C5_NUM"})
			cNumPed := aPedido[x][nPosPed][1][2]

			For i := 1 To Len (aPedido[x])
				
				aadd(aCab, aPedido[x][i][1])

			Next i
				
			For y := 1 To Len(aItem)
				
				aItAux := {}
				
					nPosPedIt := aScan(aItem[y],{|x| AllTrim(x[1][1]) == "C6_NUM"})
					cNumPedIt := aItem[y][nPosPedIt][1][2]

					if cNumPed == cNumPedIt
						For i := 1 To Len(aItem[y])
							aadd(aItAux, aItem[y][i][1])
						Next i  
						aadd(aItens, aItAux)
					EndIf 

			Next y

		MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCab, aItens, 3, .F.)
			If lMsErroAuto
				MostraErro()
			EndIf	

	Next x

Return
