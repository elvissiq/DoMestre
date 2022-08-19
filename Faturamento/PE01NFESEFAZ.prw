//Bibliotecas
#Include 'totvs.ch'

/*/{Protheus.doc} PE01NFESEFAZ
Ponto de entrada localizado na função XmlNfeSef do rdmake NFESEFAZ. 
Através deste ponto é possível realizar manipulações nos dados do produto, 
mensagens adicionais, destinatário, dados da nota, pedido de venda ou compra, antes da 
montagem do XML, no momento da transmissão da NFe.
@author TOTVS NORDESTE
@since 24/03/2022
@version 1.0
    @return Nil
        PE01NFESEFAZ - Manipulação em dados do produto ( [ aParam ] ) --> aRetorno
    @example
        Nome	 	 	Tipo	 	 	    Descrição	 	 	                        	 
 	    aParam   	 	Array of Record	 	aProd     := PARAMIXB[1]
                                            cMensCli  := PARAMIXB[2]
                                            cMensFis  := PARAMIXB[3]
                                            aDest     := PARAMIXB[4]
                                            aNota     := PARAMIXB[5]
                                            aInfoItem := PARAMIXB[6]
                                            aDupl     := PARAMIXB[7]
                                            aTransp   := PARAMIXB[8]
                                            aEntrega  := PARAMIXB[9]
                                            aRetirada := PARAMIXB[10]
                                            aVeiculo  := PARAMIXB[11]
                                            aReboque  := PARAMIXB[12]
                                            aNfVincRur:= PARAMIXB[13]
                                            aEspVol   := PARAMIXB[14]
                                            aNfVinc   := PARAMIXB[15]
                                            aDetPag   := PARAMIXB[16]
                                            aObsCont  := PARAMIXB[17]
                                            aProcRef  := PARAMIXB[18]
    @obs https://tdn.totvs.com/pages/viewpage.action?pageId=274327446
/*/

User Function PE01NFESEFAZ()
Local aProd     := PARAMIXB[1]
Local cMensCli  := PARAMIXB[2]
Local cMensFis  := PARAMIXB[3]
Local aDest     := PARAMIXB[4] 
Local aNota     := PARAMIXB[5]
Local aInfoItem := PARAMIXB[6]
Local aDupl     := PARAMIXB[7]
Local aTransp   := PARAMIXB[8]
Local aEntrega  := PARAMIXB[9]
Local aRetirada := PARAMIXB[10]
Local aVeiculo  := PARAMIXB[11]
Local aReboque  := PARAMIXB[12]
Local aNfVincRur:= PARAMIXB[13]
Local aEspVol   := PARAMIXB[14]
Local aNfVinc   := PARAMIXB[15]
Local adetPag   := PARAMIXB[16]
Local aObsCont  := PARAMIXB[17]
Local aProcRef  := PARAMIXB[18]
Local aRetorno  := {}
Local aCMPUSR	:= {}
Local aArea		:= GetArea()
Local aAreaSC5  :=''
Local _nI	    := 0

If aNota[4] == "1" // Se for Nota Fiscal de Saída 
    IF !Empty(GetNewPar("MV_CMPUSR",""))
        cMensCli := ""
        aCMPUSR	:= StrTokArr( GetNewPar("MV_CMPUSR",""), "|" )	
    Endif 

    //@ Bloco responsável por alterar a mensagem da NF-e. ///// INICIO /////
    aAreaSC5 := SC5->(GetArea())
    SC5->(dbSelectArea("SC5"))
    SC5->(dbSetOrder(1))
    If SC5->(dbSeek(FWxFilial("SC5")+aProd[1,38]))
        IF len(aCMPUSR) > 0  
            For _nI := 1 To len(aCMPUSR)
                If !Empty(&("SC5->"+aCMPUSR[_nI]))  

                    cMensCli += IIF(_nI > 1,". ","") + alltrim(&("SC5->"+aCMPUSR[_nI]))
                
                Endif 
            Next _nI
        Endif 
    EndIf
    //@ Bloco responsável por alterar a mensagem da NF-e. ///// FIM /////

    RestArea(aAreaSC5)
EndIf 

RestArea(aArea)

aadd(aRetorno,aProd)
aadd(aRetorno,cMensCli)
aadd(aRetorno,cMensFis)
aadd(aRetorno,aDest)
aadd(aRetorno,aNota)
aadd(aRetorno,aInfoItem)
aadd(aRetorno,aDupl)
aadd(aRetorno,aTransp)
aadd(aRetorno,aEntrega)
aadd(aRetorno,aRetirada)
aadd(aRetorno,aVeiculo)
aadd(aRetorno,aReboque)
aadd(aRetorno,aNfVincRur)
aadd(aRetorno,aEspVol)
aadd(aRetorno,aNfVinc)
aadd(aRetorno,AdetPag)
aadd(aRetorno,aObsCont)
aadd(aRetorno,aProcRef) 

Return aRetorno
