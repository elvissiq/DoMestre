#Include "RwMake.ch"

/*/{Protheus.doc} VOLUME
Função para calcular o Peso e volume no Pedido de Venda
@author TOTVS NORDESTE
@since 03/11/2021
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_VOLUME()
    @obs Não se pode executar função MVC dentro do fórmulas
/*/

User Function VOLUME()

Local nVolume 	:= 0
Local nVol	    := 0
Local nPosProd  := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local nPosQTD   := Ascan(aHeader , { |x| Alltrim(x[2]) = "C6_QTDVEN"})
Local i, x

For i:=1 to len(aCols)
	cTipo := POSICIONE("SB1",1,FWxFilial("SB1")+aCols[i][nPosProd],"B1_TIPCONV")
	cConv := POSICIONE("SB1",1,FWxFilial("SB1")+aCols[i][nPosProd],"B1_CONV") 

		IF cTipo == 'M' .And. !Empty(cConv)
			nVolume	:= int(aCols[i,nPosQTD] *cConv)
			
				nVol += iif(nVolume <> aCols[i,nPosQTD] *cConv,nVolume+1,nVolume)

		ELSEIF cTipo == 'D' .And. !Empty(cConv)
			nVolume	:= int(aCols[i,nPosQTD] /cConv)
				
				nVol += iif(nVolume <> aCols[i,nPosQTD] /cConv,nVolume+1,nVolume)

		ELSEIF Empty(nVol)
			
			For x:=1 to len(aCols)
				nVol += aCols[x,nPosQTD]
			Next x

		ENDIF
Next i

		B1PESO()
		PESOB()

Return nVol

Static Function B1PESO()

Local nPeso	    := 0
Local nPosQtd	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})
Local nPosProd  := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local y 

For y:=1 to len(aCols)

		nPeso += aCols[y][nPosQtd]*POSICIONE("SB1",1,FWxFilial("SB1")+aCols[y][nPosProd],"B1_PESO")

Next y

		M->C5_PESOL := nPeso

Return 

Static Function PESOB()

Local nPeso	    := 0
Local nPosQtd	:= Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_QTDVEN"})
Local nPosProd  := Ascan(aHeader, {|x| AllTrim(x[2]) == "C6_PRODUTO"})
Local y

For y:=1 to len(aCols)

		nPeso += aCols[y][nPosQtd]*POSICIONE("SB1",1,FWxFilial("SB1")+aCols[y][nPosProd],"B1_PESBRU")

Next y

		M->C5_PBRUTO := nPeso

Return 
