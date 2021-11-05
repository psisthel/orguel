#Include "Totvs.ch"

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | LC001GRV  | Autor: | Guilherme Coronado | Data: | Março/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | PE na gravação do projeto              		                    |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/ 
User Function LC001GRV()
Local aHead   := ParamIxb[1]
Local aCols   := ParamIxb[2]
Local nPosFPA := 0
Local nPosFam := 0
Local nPosTre := 0
Local nPosRef := 0
Local nPosPro := 0
Local nPosUni := 0
Local cCodFam := ""
Local cDesTre := ""
Local cTreRef := ""
Local cCodPro := ""
Local nVlrUni := 0
Local oSay
Local nI
Local lHaZerado := .F.

nPosFPA := aScan( aHead, { | x | Trim( x[2] ) == "FPA_OBRA"   } )

If nPosFPA > 0
   nPosFam  := aScan( aHead, { | x | Trim( x[2] ) == "FPA_FAMILI" } )
   nPosDFam := aScan( aHead, { | x | Trim( x[2] ) == "FPA_XDFAMI" } )
   nPosTre  := aScan( aHead, { | x | Trim( x[2] ) == "FPA_TRECHO" } )
   nPosRef  := aScan( aHead, { | x | Trim( x[2] ) == "FPA_XTRERE" } )
   nPosPro  := aScan( aHead, { | x | Trim( x[2] ) == "FPA_PRODUT" } )
   nPosUni  := aScan( aHead, { | x | Trim( x[2] ) == "FPA_UNIDIA" } )

   For nI := 1 To Len(aCols)
      cCodFam := aCols[nI][nPosFam]
      cDesTre := aCols[nI][nPosTre]
      cTreRef := aCols[nI][nPosRef]
      cCodPro := aCols[nI][nPosPro]
      nVlrUni := aCols[nI][nPosUni]

      if nVlrUni <= 0
         lHaZerado := .T.
      endif

      If !Empty(cDesTre)
	      ZD8->(dbSetOrder(2))
         If !ZD8->(dbSeek(xFilial("ZD8") + FP0->FP0_PROJET + cCodFam + cDesTre))
         	ZD8->(RecLock("ZD8",.T.))
	      	ZD8->ZD8_FILIAL := xFilial("ZD8")
	      	ZD8->ZD8_PROJET := FP0->FP0_PROJET
	      	ZD8->ZD8_FAMILI := cCodFam
	      	ZD8->ZD8_TRECHO := cDesTre
	      	ZD8->ZD8_TREREF := Iif(cTreRef == "1", "S", "N")
	      	ZD8->ZD8_LIBLIS := 'N'
	      	ZD8->ZD8_IMPLIS := Iif(!Empty(cCodPro), "S", "N")
	      	ZD8->(MsUnlock())
         Else
            ZD8->(RecLock("ZD8",.F.))            
            If !lHaZerado .And. cTreRef == "1"
	      	   ZD8->ZD8_LIBLIS := 'S'
            Else
               ZD8->ZD8_LIBLIS := 'N'
            EndIf

	      	ZD8->ZD8_IMPLIS := Iif(!Empty(cCodPro), "S", "N")
	      	ZD8->(MsUnlock())
         EndIf      

         // ---------------------------------------------------------------------------------------------- //
         // Atualiza status do projeto para evitar que sea enrado manualmente a toda e qualquer manutencao //
         // ---------------------------------------------------------------------------------------------- //
         FP0->(RecLock("FP0",.F.))
         FP0->FP0_STATUS := '5'
         If FP0->FP0_XSTAT2 == '3' .And. !lHaZerado .And. cTreRef == "1"
            // FP0->(RecLock("FP0",.F.))
            FP0->FP0_XSTAT2 := '4' //Fixar tabela de preço do contrato
            // FP0->(MsUnlock())
         EndIf
         FP0->(MsUnlock())

      EndIf      
   Next nI

   _aAltera := fAltCols(oDlgPla)

   If Len(_aAltera) > 0
      FwMsgRun(NIL, {|oSay| U_fEmaCnt(_aAltera, oSay) }, "Processando", "Enviando e-mail de alteração de contrato...")
   EndIf
EndIf

Return aCols


/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | fAltCols  | Autor: | Guilherme Coronado | Data: | Junho/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para verificar se houve alteração no acols                |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/ 
Static Function fAltCols(oDlgPla)
Local _aRet     := {}
Local _cObra    := ""
Local _cSeqGru  := ""
Local _cFamAlt  := ""
Local _cTreAlt  := ""
Local _nPosObr  := aScan( oDlgPla:aHeader, { | x | AllTrim( x[2] ) == "FPA_OBRA" } )
Local _nPosSeq  := aScan( oDlgPla:aHeader, { | x | AllTrim( x[2] ) == "FPA_SEQGRU" } )
Local _nPosFam  := aScan( oDlgPla:aHeader, { | x | AllTrim( x[2] ) == "FPA_FAMILI" } )
Local _nPosDFam := aScan( oDlgPla:aHeader, { | x | AllTrim( x[2] ) == "FPA_XDFAMI" } )
Local _nPosTre  := aScan( oDlgPla:aHeader, { | x | AllTrim( x[2] ) == "FPA_TRECHO" } )
Local _nI       := 0
Local _nZ       := 0
Local _nPosAlt  := 0
Local _aAreaFPA := FPA->(GetArea())
Local _lAlterou := .F.
Local _cCampo   := ""

FPA->(dbSetOrder(1))
For _nI := 1 To Len(oDlgPla:aCols)
   _lAlterou := .F.
   _cObra    := AllTrim(oDlgPla:aCols[_nI, _nPosObr])
   _cSeqGru  := AllTrim(oDlgPla:aCols[_nI, _nPosSeq])
   _cFamAlt  := AllTrim(oDlgPla:aCols[_nI, _nPosFam]) + ' - ' + AllTrim(oDlgPla:aCols[_nI, _nPosDFam])
   _cTreAlt  := AllTrim(oDlgPla:aCols[_nI, _nPosTre])

   If !FPA->(dbSeek(xFilial("FPA") + FP0->FP0_PROJET + _cObra + _cSeqGru))
      _lAlterou := .T.
   Else
      For _nZ := 1 To Len(oDlgPla:aHeader)
         _cCampo := AllTrim(oDlgPla:aHeader[_nZ, 2])
         
         //Se o que estiver gravado for menor que o que ta no acols
         If _cCampo $ "FPA_QUANT;FPA_PESTOT;FPA_INDTOT;"
            If &("FPA->" + _cCampo) < oDlgPla:aCols[_nI, _nZ]
               _lAlterou := .T.
               Exit
            EndIf
         EndIf
      Next _nZ
   EndIf
   
   If _lAlterou
      If !Empty(_cFamAlt) .And. !Empty(_cTreAlt)
         _nPosAlt := aScan( _aRet, { | x | AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(_cFamAlt) + AllTrim(_cTreAlt) })

         If _nPosAlt == 0
            aAdd(_aRet, { _cFamAlt, _cTreAlt })
         EndIf
      EndIf
   EndIf
Next _nI

RestArea(_aAreaFPA)

Return _aRet
