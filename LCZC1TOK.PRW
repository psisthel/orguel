#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | LCZC1TOK  | Autor: | Guilherme Coronado | Data: | Junho/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descri��o: | Pontor de Entrada no Custo Extra para validar a tela             |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                                               			     |
+------------+------------------------------------------------------------------+
*/ 
User Function LCZC1TOK(nOpc)
Local   lRet     := .T.
Local   aAreaFPG := FPG->(GetArea())
Local   nRecFPG  := 0
Local   oSay
Local   lWS

Default nOpc     := 0

If nOpc == 3 .Or. nOpc == 4
   If M->FPG_XEQUPA < 0 .And. ( Empty(M->FPG_XPERDE) .Or. Empty(M->FPG_XPERAT) )
      Help(" ",1,"LCZC1TOK_1",,"Necess�rio informar os campos 'Per�odo De' e 'Per�odo Ate' quando houver ajustes de equipamento parado.",1,0)
      lRet := .F.  
   
   ElseIf M->FPG_XPERDE > M->FPG_XPERAT
      Help(" ",1,"LCZC1TOK_2",,"O campo 'Per�odo De' n�o pode ser maior que o 'Per�odo Ate'.",1,0)
      lRet := .F.  

   ElseIf M->FPG_XVALDE > M->FPG_XVALAT
      Help(" ",1,"LCZC1TOK_3",,"O campo 'Validade De' n�o pode ser maior que o 'Validade Ate'.",1,0)
      lRet := .F.  
   
   ElseIf M->FPG_VALOR == 0
      Help(" ",1,"LCZC1TOK_4",,"O campo 'Valor Total' n�o pode ser zero.",1,0)
      lRet := .F.  
   
   ElseIf nOpc == 3 .And. M->FPG_XTIPAJ == 'D' 
      If U_fTemDecre(1, M->FPG_PROJET, M->FPG_XMEDIN, M->FPG_XMEDFI)
         If MsgYesNo("J� existe um ajuste de decrescimo gerado no per�odo, deseja exclu�-lo e enviar esse para aprova��o?")   

            FwMsgRun(NIL, {|oSay| lWS := U_fWSDecre(oSay) }, "Processando", "Enviando ajuste de decrescimo para Fluig...")

            If !lWS
               Help(" ",1,"LCZC1TOK_5",,"N�o foi poss�vel integrar com o fluig.",1,0)
               lRet := .F.  
            Else
               nRecFPG := U_fTemDecre(2, M->FPG_PROJET, M->FPG_XMEDIN, M->FPG_XMEDFI)

               FPG->(dbGoTo(nRecFPG))
               FPG->(RecLock("FPG",.F.))
               FPG->(dbDelete())
               FPG->(MsUnlock())
            EndIf
         Else
            MsgAlert("Processo abortado.")
            lRet := .F. 
         EndIf
      Else
         If MsgYesNo("Confirma o envio do ajuste para aprova��o no Fluig?") 

            FwMsgRun(NIL, {|oSay| lWS := U_fWSDecre(oSay) }, "Processando", "Enviando ajuste de decrescimo para Fluig...")

            If !lWS
               Help(" ",1,"LCZC1TOK_6",,"N�o foi poss�vel integrar com o fluig.",1,0)
               lRet := .F.  
            EndIf
         Else
            MsgAlert("Processo abortado.")
            lRet := .F. 
         EndIf
      EndIf

   ElseIf nOpc == 4 .And. M->FPG_XTIPAJ == 'D' 
      //Verifica se algum campo que deve ser enviado para o fluig foi alterado
      If U_fDiffAlt()
         If MsgYesNo("Confirma o reenvio do ajuste para aprova��o no Fluig?") 

            FwMsgRun(NIL, {|oSay| lWS := U_fWSDecre(oSay) }, "Processando", "Enviando ajuste de decrescimo para Fluig...")

            If !lWS
               Help(" ",1,"LCZC1TOK_7",,"N�o foi poss�vel integrar com o fluig.",1,0)
               lRet := .F.  
            EndIf
         Else
            MsgAlert("Processo abortado.")
            lRet := .F. 
         EndIf
      EndIf

   ElseIf nOpc == 3 .And. M->FPG_XTIPAJ == 'I' 

      // ----------------------------------------------------- //
      // Atualiza informcoes de indenizacao de pecas faltantes //
      // ----------------------------------------------------- //
      // if M->FPG_XTEMPF=='S'
      //    U_STHORG00() 
      // endif

   EndIf
EndIf

RestArea(aAreaFPG)

Return lRet
