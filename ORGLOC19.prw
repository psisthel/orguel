#Include "Protheus.ch"
#Include 'FWMVCDef.ch'

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | ORGLOC19  | Autor: | Guilherme Coronado | Data: | Maio/20        |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Tela Controle de Contratos                                       |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                                           		           |
+------------+------------------------------------------------------------------+
*/ 
User Function ORGLOC19  
Local lRet      := .F.       
Local cTitulo   := "Controle de Contratos"
Local cContrato := "Contrato: " + AllTrim(FP0->FP0_PROJET) + " - Cliente: " + AllTrim(FP0->FP0_CLINOM)
Local oFtTitulo := TFont():New("Arial",,018,,.T.,,,,,.F.,.F.)
Local oFont1    := TFont():New("Arial Black",,024,,.T.,,,,,.F.,.F.)
Local oDlg
Local bOk       := .F.
Local nOpcA     := 0
Local oButton01, oButton02, oButton03, oButton04, oButton05, oButton06, oButton07, oButton08, oButton09, oButton10
Local oButton11, oButton12, oButton13, oButton14, oButton15, oButton16, oButton17, oButton18, oButton19
Local cLstBlq    := Getmv("IT_LSTUBLQ")

if FP0->FP0_XSTAT2 < "6" //  Contrato ainda não está liberado para ser Gerido
   Alert('Contrato ainda não está apto a ser gerido. Aguarde o termino das etapas anteriores.') 
   Return lRet
endif

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 630, 730 /*COLORS 0, 16777215*/ PIXEL

@ 004, 004 SAY cContrato SIZE 342, 010 OF oDlg FONT oFtTitulo COLORS 0, 16777215 PIXEL
@ 012, 000 SAY REPLICATE("_",121) SIZE 360, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 022, 085 SAY "Qual tipo de ação deseja realizar?" SIZE 200, 023 OF oDlg FONT oFont1 COLORS 0, 16777215 PIXEL

@ 045, 020 BUTTON oButton01 PROMPT "Encerrar Contrato"                 SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=1, fExecBtn(nOpcA) }) )
@ 045, 210 BUTTON oButton02 PROMPT "Gerar Remessa"                     SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=2, fExecBtn(nOpcA) }) )
                
@ 070, 020 BUTTON oButton03 PROMPT "Consultar Contrato"                SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=3, fExecBtn(nOpcA) }) )
@ 070, 210 BUTTON oButton04 PROMPT "Gerar Fatura/RPS"                  SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=4, fExecBtn(nOpcA) }) )
                
@ 095, 020 BUTTON oButton05 PROMPT "Consultar Cliente"                 SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=5, fExecBtn(nOpcA) }) )
@ 095, 210 BUTTON oButton06 PROMPT "Gerar Devolução"                   SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=6, fExecBtn(nOpcA) }) )

@ 120, 020 BUTTON oButton07 PROMPT "Consultar Notas Fiscais"           SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=7, fExecBtn(nOpcA) }) ) 
@ 120, 210 BUTTON oButton08 PROMPT "Gerar Indenização"                 SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=8, fExecBtn(nOpcA) }) ) 

@ 145, 020 BUTTON oButton09 PROMPT "Imprimir/Enviar Notas Fiscais"     SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=9 , fExecBtn(nOpcA) }) ) 
@ 145, 210 BUTTON oButton10 PROMPT "Consultar Tabela Preço"            SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=10, fExecBtn(nOpcA) }) ) 

@ 170, 020 BUTTON oButton11 PROMPT "Custos Extras"                     SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=11, fExecBtn(nOpcA) }) ) 
@ 170, 210 BUTTON oButton12 PROMPT "Imprimir/Enviar Medição"           SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=12, fExecBtn(nOpcA) }) ) 

@ 195, 020 BUTTON oButton13 PROMPT "Liberar Contrato para Faturamento" SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=13, fExecBtn(nOpcA) }) )
@ 195, 210 BUTTON oButton14 PROMPT "Gerar Previa Credito"              SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=14, fExecBtn(nOpcA) }) )

@ 220, 020 BUTTON oButton15 PROMPT "Analisar Crédito"                  SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=15, fExecBtn(nOpcA) }) )
@ 220, 210 BUTTON oButton16 PROMPT "Bloqueio Contrato"                 SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=16, fExecBtn(nOpcA) }) )

@ 245, 020 BUTTON oButton17 PROMPT "Desbloqueio Contrato"              SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=17, fExecBtn(nOpcA) }) )
@ 245, 210 BUTTON oButton18 PROMPT "Gestão Contrato"                   SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=18, fExecBtn(nOpcA) }) )

@ 270, 020 BUTTON oButton19 PROMPT "Gerar Romaneio"                    SIZE 120, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=19, fExecBtn(nOpcA) }) )


oButton16:bWhen := {|| RetCodUsr() $ cLstBlq .AND. FP0->FP0_XSTAT2 <> "A" } 
oButton17:bWhen := {|| RetCodUsr() $ cLstBlq .AND. FP0->FP0_XSTAT2 = "A" }

@ 285, 000 SAY REPLICATE("_",120) SIZE 360, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 295, 300 BUTTON oButton4 PROMPT "Sair " SIZE 50, 015 OF oDlg PIXEL Action( Eval({|| bOk:=.T. , nOpcA:=0, oDlg:End() }) )

ACTIVATE MSDIALOG oDlg CENTERED
    
If nOpcA <> 0
	fExecBtn(nOpcA) 
   nOpcA := 0 
EndIf

Return lRet             


/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | fExecBtn  | Autor: | Guilherme Coronado | Data: | Maio/20        |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Tela Controle de Contratos                                       |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                                           		           |
+------------+------------------------------------------------------------------+
*/ 

Static Function fExecBtn(nVez)

If nVez == 1 //Encerra Contrato
   Alert('Em desenvolvimento - Sprint 06')  

ElseIf  nVez == 2 // Gerar Remessa
   U_OrgLoc31(.T.)  

ElseIf  nVez == 3 //Consultar contrato
   Alert('Será desenvolvida pela Orguel. - Sprint 06 / Faturamento') 

ElseIf  nVez == 4 //Gerar Fatura/RPS
   //Alert('Em desenvolvimento')   
   u_STHORG01()

ElseIf  nVez == 5 //Consulta Cliente
   U_PosiCli()  

ElseIf  nVez == 6 //Gerar Devolução
   U_OrgLoc33(.T.)  

ElseIf  nVez == 7 //Consultar Notas Fiscais
   Alert('Em desenvolvimento - Sprint 06 / Faturamento')   

ElseIf  nVez == 8 //Gerar Indenização
   // Alert('Será desenvolvida pela Orguel. - MIT046')  
   U_sthorg03()

ElseIf  nVez == 9
   Alert('Em desenvolvimento - Sprint 06 / Faturamento') 

ElseIf  nVez == 10 // Consultar Tabela de Preço
   U_ORGLOC17() 

ElseIf  nVez == 11 //Custo Extras
   LOCA007() 

ElseIf  nVez == 12 //Imprimir/Enviar Medição
   U_ORGLOC26()

ElseIf  nVez == 13 // Liberar para faturamento
   If FP0->FP0_XSTAT2 == "6" 
      If MsgYesNo("Confirma a liberação do contrato " + AllTrim(FP0->FP0_PROJET) + " para faturamento?")
         FP0->(RecLock("FP0",.F.))
         FP0->FP0_XSTAT2 := "9" //Liberado para Faturar
         FP0->(MsUnlock())
         MsgInfo("Contrato liberado para faturamento")
      EndIf
   Else
      MsgAlert("Somente contratos com Status 'Gerir Contratos' podem ser liberados para faturamento.")
   EndIf

ElseIf  nVez == 14 //Prévia de Crédito
   U_DspLimCr(FP0->FP0_CLI, FP0->FP0_LOJA)
   
   If !Empty(FP0->FP0_XCLIIN) .And. !Empty(FP0->FP0_XLOJIN)
      U_DspLimCr(FP0->FP0_XCLIIN, FP0->FP0_XLOJIN)
   EndIf

ElseIf  nVez == 15 //Analise de credito
   U_AnCredEf()

ElseIf  nVez == 16 // Bloqueio de Contrato
   
   BlqCont()

ElseIf  nVez == 17 // Desbloqueio de Contrato
   DesBlqCont()  

ElseIf  nVez == 18 // Gestão Contrato
   Alert('Será desenvolvida pela Orguel.')   

ElseIf  nVez == 19 // Gerar Romaneio
   U_OrgLoc28()
EndIf

Return


/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | PosiCli   | Autor: | Guilherme Coronado | Data: | Abril/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para buscar a posição financeira do cliente               |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/

User Function PosiCli()
Local oDlg1
Local oSay1
Local oRMenu1
Local oSBtn1
Local oSBtn2
Local lOk
Local nOpc := 1
Local cCliente
Local lPergunte 

Private cCadastro := ""

If !Empty(FP0->FP0_XCLIIN) .And. !Empty(FP0->FP0_XLOJIN)
   /*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
   ±± Definicao do Dialog e todos os seus componentes.                        ±±
   Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
   oDlg1           := MSDialog():New( 088,232,292,581,"Consultar Cliente",,,.F.,,,,,,.T.,,,.T. )
   oSay1           := TSay():New( 004,004,{||"Selecione o cliente que deseja consultar"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,012)
   oRMenu1         := TGroup():New( 016,004,072,164,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
   oRMenu1         := TRadMenu():New( 020,010,{"Principal","Interveniente"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,140,18,,.F.,.F.,.T. )
   oRMenu1:bSetGet := {|u|Iif (PCount()==0,nOpc,nOpc:=u)}

   oSBtn1     := SButton():New( 080,104,1,{|| lOk := .T.,oDlg1:End() },oDlg1,,"", )
   oSBtn2     := SButton():New( 080,136,2,{|| lOk := .F.,oDlg1:End() },oDlg1,,"", )

   oDlg1:Activate(,,,.T.)

   If !lOk
   	Return
   EndIf

   If nOpc == 1 
      cCliente := FP0->FP0_CLI + FP0->FP0_LOJA
   ElseIf nOpc == 2
      cCliente := FP0->FP0_XCLIIN + FP0->FP0_XLOJIN
   EndIf
Else
   cCliente := FP0->FP0_CLI + FP0->FP0_LOJA
EndIf

SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1") + cCliente))
   lPergunte := Pergunte("FIC010",.T.)
   If lPergunte
      Fc010Con("SA1", SA1->(Recno()), 2)
   EndIf   
Else
   MsgAlert("Cliente selecionado não localizado no cadastro.")
EndIf

Return


/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | GerNFOrg  | Autor: | Guilherme Coronado | Data: | Abril/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para gerar nota fiscal de remessa                         |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/
User Function GerNFOrg(nTipo)
Local   aArea        := GetArea()
Local   lRet         := .F.
Local   cPesq	      := Space(50)
Local   nRecno	      := 0
Local   bRet	      := {|| lRet := .T., nRecno := aTail(oLstBx:aArray[oLstBx:nAt]), oDlg:End() }
Local   bVisual      := {|| nRecno := aTail(oLstBx:aArray[oLstBx:nAt]), FQ2->(dbGoTo(nRecno)), AxVisual("FQ2",nRecno,2) }
Local   oDlg, oPesq, oLstBx
Local   oOk          :=	LoadBitMap(GetResources(),"LBOK")
Local   oNo          :=	LoadBitMap(GetResources(),"LBNO")

Private aItens       := {}
Private lUmaOpcao  	:=	.T.
Private lMarcaItem 	:=	.T.
Private cCadastro    := "Romaneio"

aItens := fPesqFQ2(cPesq, nTipo)

If Len(aItens) == 0
   If nTipo == 1
	   MsgAlert("Não há romaneios de expedição gerados para o contrato: " + AllTrim(FP0->FP0_PROJET) , "GERNFORG.prw")
	Else
      MsgAlert("Não há romaneios de retorno gerados para o contrato: " + AllTrim(FP0->FP0_PROJET) , "GERNFORG.prw")
   EndIf

	RestArea( aArea )
	Return .F.
EndIf

DEFINE MSDIALOG oDlg TITLE "Contrato: " + AllTrim(FP0->FP0_PROJET) + " - Romaneios " + Iif(nTipo == 1, "Expedição", "Retorno") FROM 268,260 TO 630,796 PIXEL //"Consulta"
	// Texto de pesquisa
	@ 003,002 MsGet oPesq Var cPesq Size 219,009 COLOR CLR_BLACK PIXEL OF oDlg 
	
	// Interface para selecao de indice e filtro
	@ 003,228 Button "Pesquisar" Size 037,012 PIXEL OF oDlg	 Action (aItens := fPesqFQ2(cPesq), oLstBx:SetArray(aItens),;
	oLstBx:bLine := {|| { If(	aItens[oLstBx:nAt,01],oOk,oNo), aItens[oLstBx:nAt,02] , aItens[oLstBx:nAt,03] , aItens[oLstBx:nAt,04] , aItens[oLstBx:nAt,05]}},oLstBx:Refresh())
	
	// ListBox
	@ 20,03 LISTBOX oLstBx FIELDS HEADER "", "Romaneio", "Data", "ASF", "Viagem" SIZE 264,139; 
   On DblClick (aItens  := MarcaItem(oLstBx:nAt,aItens,lUmaOpcao,lMarcaItem),;
	oLstBx:Refresh()) OF oDlg PIXEL
	
	// Botoes inferiores
	DEFINE SBUTTON FROM 162,002 TYPE 1	ENABLE OF oDlg Action(Eval(bRet)) 		// OK
	DEFINE SBUTTON FROM 162,035 TYPE 2	ENABLE OF oDlg Action(oDlg:End()) 		// Cancelar
	DEFINE SBUTTON FROM 162,068 TYPE 15	ENABLE OF oDlg Action(Eval(bVisual)) 	// Visualizar
	
	// Metodos da ListBox
	oLstBx:SetArray(aItens)
	oLstBx:bLine := {|| { If(	aItens[oLstBx:nAt,01],oOk,oNo), aItens[oLstBx:nAt,02] , aItens[oLstBx:nAt,03] , aItens[oLstBx:nAt,04] , aItens[oLstBx:nAt,05]}}
	
ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

If lRet
	For nX:=1 to Len(aItens)
	   If aItens[nX,01]
         U_LOC051A("FQ2", aItens[nX,06], 2) //Emissão NF
         Exit
	   EndIf
	Next
EndIf

Return lRet

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | MarcaItem | Autor: | Guilherme Coronado | Data: | Abril/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para gerar nota fiscal de remessa                         |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/
Static Function MarcaItem(nAt,_aArray,lUmaOpcao,lMarcaItem)

	If lUmaOpcao
		For nX:=1 to Len(_aArray)
		   If _aArray[nX,1] .And. nX <> nAt
		   	_aArray[nX,01] := !_aArray[nX,01]
		   EndIf
	   Next
	EndIf

	If _aArray[nAt,Len(_aArray[nAt])]
		_aArray[nAt,01] := !_aArray[nAt,01]
	EndIf

Return _aArray

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | fPesqFQ2  | Autor: | Guilherme Coronado | Data: | Abril/21       |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para gerar nota fiscal de remessa                         |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/
Static Function fPesqFQ2(cBusca, nTipo)

Local cQuery 		:= ""
Local cAliasQry 	:= GetNextAlias()
Local aItens    	:= {}

cQuery := " SELECT FQ2.FQ2_NUM, FQ2.FQ2_DATA, FQ2.FQ2_ASF, FQ2.FQ2_VIAGEM, FQ2.R_E_C_N_O_ FQ2REC " + CRLF
cQuery += " FROM " + RetSqlName("FQ2") + " FQ2 " + CRLF
cQuery += " WHERE  FQ2.FQ2_FILIAL = '" + xFilial("FQ2")  + "'" + CRLF
cQuery += "   AND  FQ2.FQ2_PROJET = '" + FP0->FP0_PROJET + "'" + CRLF

If !Empty(cBusca)
	cQuery += "    AND (FQ2.FQ2_NUM  	LIKE '%" + Upper(StrTran(StrTran(Alltrim(cBusca)," ","%"),"'","%")) + "%'" + CRLF
	cQuery += "     OR  FQ2.FQ2_DATA 	LIKE '%" + Upper(StrTran(StrTran(Alltrim(cBusca)," ","%"),"'","%")) + "%'" + CRLF
	cQuery += "     OR  FQ2.FQ2_ASF 	   LIKE '%" + Upper(StrTran(StrTran(Alltrim(cBusca)," ","%"),"'","%")) + "%'" + CRLF
	cQuery += "     OR  FQ2.FQ2_VIAGEM 	LIKE '%" + Upper(StrTran(StrTran(Alltrim(cBusca)," ","%"),"'","%")) + "%')" + CRLF
EndIf

If nTipo == 1 //Expedição
   cQuery += "   AND  FQ2.FQ2_TPROMA = '0'" + CRLF
ElseIf nTipo == 2 //Retorno
   cQuery += "   AND  FQ2.FQ2_TPROMA = '1'" + CRLF
EndIf

cQuery += "   AND  FQ2.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " ORDER BY FQ2.FQ2_NUM "


dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

While (cAliasQry)->(!Eof())
	aAdd( aItens, {.F., (cAliasQry)->FQ2_NUM , StoD((cAliasQry)->FQ2_DATA) , (cAliasQry)->FQ2_ASF , (cAliasQry)->FQ2_VIAGEM , (cAliasQry)->FQ2REC})
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(dbCloseArea())

Return aItens

STATIC FUNCTION BlqCont()

Local nOpcao := MODEL_OPERATION_INSERT
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Bloquear"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
Private lBloq := .T.
// Verifcar o Credito do Cliente Principal
if FWExecView('Bloqueio de Contrato','ORGLOC20', nOpcao, , { || .T. }, , .3, aButtons) = 0 // Confirmou
   MsgInfo("Contrato Bloqueado com Sucesso!")
endif

Return


STATIC FUNCTION DesBlqCont()

Local nOpcao := MODEL_OPERATION_UPDATE
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Desbloquear"},{.T.,"Cancelar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
Private lBloq := .F.

// Verifcar o Credito do Cliente Principal
if FWExecView('Desbloqueio de Contrato','ORGLOC20', nOpcao, , { || .T. }, , .3, aButtons ) = 0 // Confirmou
   MsgInfo("Contrato Desbloqueado com Sucesso!")
endif

Return
