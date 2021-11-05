#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} ORGLOC09
//Efetivação da Proposta transformado assim em Contrato.
@author IT UP
@since 08/02/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ORGLOC09()
Local aAreaCurr := getArea()
Local lRet 		:= .T.
Local cCodObra := ""
Local cSeqMax  := ""
Local cCodFami := ""
Local cDesFami := ""
Local cTrecho  := ""
Local cCodPro  := ""
Local cLote    := ""
Local cPerLoc  := ""
Local nQuant   := 0
Local nVlrUni  := 0
Local cRegTra  := ""
Local nDias    := 0
Local aRegCom  := U_fRegCome(FP0->FP0_PROJET)
Local nPosTpL  := aScan( aRegCom, { | x | Trim( x[1] ) == "ZD5_TIPLOC"   } ) //Tipo de Locação

Local cTipVel := GetNewPar("IT_TIPVEL","1")
Local cCliOri := GetNewPar("IT_CLIORI","000002")
Local cLojOri := GetNewPar("IT_LOJORI","01")
Local nX	  := 1

If aRegCom[nPosTpL][2] == "D"
	nDias := 1
ElseIf aRegCom[nPosTpL][2] == "S"
	nDias := 7
ElseIf aRegCom[nPosTpL][2] == "Q"
	nDias := 15
ElseIf aRegCom[nPosTpL][2] == "M"
	nDias := 30
EndIf


ZD7->(dbSetOrder(1))
If ZD7->(dbSeek(xFilial("ZD7") + FP0->FP0_PROJET))
	While ZD7->(!Eof()) .And. ZD7->(ZD7_FILIAL + ZD7_PROJET) == xFilial("ZD7") + FP0->FP0_PROJET
		If ZD7->ZD7_GERLOC <> '1'
			cCodObra := ZD7->ZD7_OBRA
			cSeqMax  := U_fRetSeq(, 2, cCodObra)
			cCodFami := ZD7->ZD7_GRUPO
			cDesFami := ""
			cTrecho  := ""

			ZD2->(dbSetOrder(1))
			If ZD2->(dbSeek(xFilial("ZD2") + Left(cCodFami,3))) .and. ZD2->ZD2_TIPO <> '3'
				// Nao sendo servico pode ir para o contrato
				ZD3->(dbSetOrder(1))
				If ZD3->(dbSeek(xFilial("ZD3") + cCodFami))
					cDesFami := ZD3->ZD3_DESCRI
				endif
						//Quer dizer que é estrutura
				If Empty(ZD7->ZD7_CODIGO)
					ZD8->(dbSetOrder(1))
						If ZD8->(dbSeek(xFilial("ZD8") + FP0->FP0_PROJET + cCodFami))
						cTrecho := ZD8->ZD8_TRECHO
					EndIf
				EndIf

				cCodPro  := ZD7->ZD7_CODIGO
				cLote    := ZD7->ZD7_LOTE
				cPerLoc  := ZD7->ZD7_PERLOC
				nQuant   := ZD7->ZD7_QTDORC
				nVlrUni  := ZD7->ZD7_PRCORC
				cRegTra  := ZD7->ZD7_REGTRA

				U_fAddFPA(cCodObra, cSeqMax, cCodFami, cDesFami, cTrecho, cCodPro, cLote, cPerLoc, nQuant, nVlrUni, cRegTra, nDias, "0")
			endif
			ZD7->(RecLock("ZD7", .F.))
			ZD7->ZD7_GERLOC := '1'
			ZD7->(MsUnlock())
		EndIf
		ZD7->(dbSkip())
	EndDo
EndIf

/* Gerar dois conjuntos transportadores */
SA1->(dbSetOrder(1))
FP1->(dbSetOrder(1))

FP1->( MsSeek(xFilial("FP1")+FP0->FP0_PROJET) )
SA1->( MsSeek(xFilial("SA1")+cCliOri+cLojOri) )

// Ao Efetivar Gerar Dois conjuntos transportadores de ida e de Volta.
// REgToMemory("FQ7", .T.)

for nX := 1 to 2

	FQ7->( RecLock("FQ7",.t.))

	FQ7->FQ7_FILIAL := xFilial("FQ7")
	FQ7->FQ7_PROJET := FP0->FP0_PROJET
	FQ7->FQ7_OBRA   := FP1->FP1_OBRA
	FQ7->FQ7_SEQGUI := '001'
	FQ7->FQ7_ITEM   := strzero(nX,2)
	FQ7->FQ7_X5COD  := alltrim(cTipVel)
	FQ7->FQ7_DESCRI := Posicione("DUT",1, xFilial("DUT")+cTipVel,"DUT_DESCRI" )
	FQ7->FQ7_LCCORI := iif(nX==1,cCliOri,FP0->FP0_CLI)
	FQ7->FQ7_LCLORI := iif(nX==1,cLojOri,FP0->FP0_LOJA)
	FQ7->FQ7_LOCCAR := iif(nX==1,SA1->A1_NOME,FP0->FP0_CLINOM)
	FQ7->FQ7_ENDORI := iif(nX==1,SA1->A1_END,FP0->FP0_CLIEND)
	FQ7->FQ7_BRRORI := iif(nX==1,SA1->A1_BAIRRO,FP0->FP0_CLIBAI)
	FQ7->FQ7_MUNORI := iif(nX==1,SA1->A1_MUN,FP0->FP0_CLIMUN)
	FQ7->FQ7_UFORI  := iif(nX==1,SA1->A1_EST,FP0->FP0_CLIEST)
	FQ7->FQ7_CEPORI := iif(nX==1,SA1->A1_CEP,FP0->FP0_CLICEP)

	FQ7->FQ7_DTLIM  := dDataBase

	FQ7->FQ7_LCCDES := iif(nX==1,FP0->FP0_CLI,cCliOri)
	FQ7->FQ7_LCLDES := iif(nX==1,FP0->FP0_LOJA,cLojOri)
	FQ7->FQ7_LOCDES := iif(nX==1,FP0->FP0_CLINOM,SA1->A1_NOME)
	FQ7->FQ7_ENDEST := iif(nX==1,FP0->FP0_CLIEND,SA1->A1_END)
	FQ7->FQ7_BRRDES := iif(nX==1,FP0->FP0_CLIBAI,SA1->A1_BAIRRO)
	FQ7->FQ7_MUNDES := iif(nX==1,FP0->FP0_CLIMUN,SA1->A1_MUN)
	// FQ7->FQ7_CIDEST := iif(nX==1,SA1->A1_MUN,
	FQ7->FQ7_UFDEST := iif(nX==1,FP0->FP0_CLIEST,SA1->A1_EST)
	FQ7->FQ7_CEPDES := iif(nX==1,FP0->FP0_CLICEP,SA1->A1_CEP)

	FQ7->FQ7_TPROMA := iif(nX==1,'0','1') 		// Ida
	FQ7->FQ7_TPOPE  := iif(nX==1,'00','01') 	// 00 - ENTREGA - 01 - RETIRADA
	FQ7->FQ7_CLASS  := Posicione("SX5",1, xFilial("SX5")+"_Z"+iif(nX==1,'00','01'),"SX5->X5_DESCRI" )

	FQ7->(MsUnlock())

next nX

// Primeiro Criar Conjunto Transportador de Ida
// RegLock("FG7", .T.)

restArea(aAreaCurr)

Return lRet

/*/{Protheus.doc} ValRegras
// Verificar se Houve alteração nas Regras por parte do Usuario
@author IT UP
@since 08/02/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/


User Function ValRegras(aRegpad)
Local aArea := GetArea()
Local nField
Local cCampoZD5
Local xVlZDA
Local xVlZD5
Local xDescZDA
Local xDescZD5
Local cNoComp := "ZDA_FILIAL ZDA_FRETE ZDA_VLRART ZDA_VLRSEG ZDA_APRMED ZDA_COMCON ZDA_TIPLOC"
Local aRet := {}
Local nPosCmp := 0 

dbSelectArea("ZDA")
dbSetOrder(1)
dbSeek(xFilial("ZDA") + M->FP0_PROJET)

for nField := 1 to fCount()

	if !(FieldName( nField))$ cNoComp

		cCampoZDA := FieldName( nField)
		cCampoZD5 := "ZD5_"+SubStr(FieldName( nField),5)
		nPosCmp := aScan(aRegPad, {|x| x[1] = cCampoZDA})
		if nPosCmp > 0
			xVlZD5 := &("ZD5->"+cCampoZD5)
			// Verificar se o Valor campo Digitado é diferente do valor padrão
			if aRegPad[nPosCmp, 2] <> xVlZD5
				dbSelectArea("SX3")
				dbSetOrder(2)
				dbSeek( cCampoZD5 )

				MsgAlert("A regra comercial "+ alltrim(X3DescriC())  +" está fora do padrão e deverá ser submetida à aprovação.","Regra Comercial fora do Padrão")

				if !Empty(SX3->X3_CBOX)
					Aadd( aRet, {cCampoZD5, AllTrim(X3DescriC()), U_fX3CBOX(cCampoZD5, aRegPad[nPosCmp, 2]), U_fX3CBOX(cCampoZD5, xVlZD5)})
				elseif cCampoZD5 = "ZD5_CONPAG"
					xDescZDA := Alltrim(Posicione("SE4",1,xFilial("SE4")+aRegPad[nPosCmp, 2],"E4_DESCRI"))
					xDescZD5 := Alltrim(Posicione("SE4",1,xFilial("SE4")+xVlZD5,"E4_DESCRI"))
					Aadd( aRet, {cCampoZD5, AllTrim(X3DescriC()),;
					 	if (Empty(xDescZDA),"N/D",xDescZDA),;
					 	if (Empty(xDescZD5),"N/D",xDescZD5)})
				else
					Aadd( aRet, {cCampoZD5, AllTrim(X3DescriC()), aRegPad[nPosCmp, 2], xVlZD5})
				endif
			endif

		endif
	endif
	
	dbSelectArea("ZDA")

	next nField

if ZD5->ZD5_TPFRET = "C" .and. ZD5->ZD5_FRETE > 0 .and. ZD5->ZD5_FRETE <> ZDA->ZDA_FRETE
	Aadd( aRet, {"ZD5_FRETE", "Valor do Frete", If (ZDA->ZDA_FRETE = 0 ,"N/D",ZDA->ZDA_FRETE), Transform(ZD5->ZD5_FRETE,"@ER R$ 999,999,999.99")})
endif

if ZD5->ZD5_ART  = "1" .and. ZD5->ZD5_VLRART > 0 .and. ZD5->ZD5_VLRART <> ZDA->ZDA_VLRART
	Aadd( aRet, {"ZD5_VLRART", "Valor do ART", If (ZDA->ZDA_VLRART = 0 ,"N/D",ZDA->ZDA_VLRART), Transform(ZD5->ZD5_VLRART,"@ER R$ 999,999,999.99")})
endif

if ZD5->ZD5_SEGEQU = "1" .and. ZD5->ZD5_VLRSEG > 0 .and. ZD5->ZD5_VLRSEG <> ZDA->ZDA_VLRSEG
	Aadd( aRet, {"ZD5_FRETE", "Valor do Frete", If (ZDA->ZDA_VLRSEG = 0 ,"N/D",ZDA->ZDA_VLRSEG), Transform(ZD5->ZD5_VLRSEG,"@ER R$ 999,999,999.99")})
endif

RestArea(aArea)

Return aRet

/*/{Protheus.doc} DlgJusOr
// Dialogo de Justificativa para a Alteração de Regra
// ou de aplicação de Descontos
@author IT UP
@since 07/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function DlgJusOr(aDif, aSolucoes, cOrigem, aRegras)
Local lRet := .T.

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
PRIVATE oDlg1
Private oSay1
Private oSay2
Private oSay3
Private oSay4
Private oSay5
Private oSay6
Private oGet1
Private oMGet1
Private oGet2
Private oGet3

Private oMGet2
Private oBtn1



/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 088,232,560,795,"Necessidade de Avaliação",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 004,008,{||"Prezado(a), não foi possível  concluir esta operação devido ao motivo descrito nos campos abaixo. Caso deseje submeter esta operação para avaliação, preencha os campos de justificativa  e clique no botão 'Solicitar'."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,260,028)
oSay2      := TSay():New( 040,008,{||"Motivo do Bloqueio"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oSay3      := TSay():New( 056,008,{||"Detalhes do bloqueio:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
oSay4      := TSay():New( 124,008,{||"Justificativa"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay5      := TSay():New( 140,008,{||"Detalhe a justificativa selecionada:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
oGet1      := TGet():New( 040,068,{|u| If(PCount()>0,cMotivo:=u,cMotivo)},oDlg1,200,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
oMGet1     := TMultiGet():New( 068,008,{|u| If(PCount()>0,cDetBlo:=u,cDetBlo)},oDlg1,260,048,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
oGet2      := TGET():New( 124,044,{|u| If(PCount()>0,cJustif:=u,cJustif)},oDlg1,024,008,'',{|| U_ValJust()},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cJustif",,)
oGet2:cF3 := "ZDF"
oGet3      := TGet():New( 124,084,{|u| If(PCount()>0,cDescJu:=u,cDescJu)},oDlg1,184,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"","cDescJu",,)
oMGet2     := TMultiGet():New( 148,008,{|u| If(PCount()>0,cDetJus:=u,cDetJus)},oDlg1,260,044,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

oSay5      := TSay():New( 200,008,{||"Aplicação do Equipamento:"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,088,008)
@ 200,084 COMBOBOX oGet3  Var cApliEq ITEMS aApliEq  Size 100,008 Of oDlg1 Pixel


oBtn1      := TButton():New( 220,184,"Solicitar",oDlg1,{|| WfRegrDesc(aDif, aRegras , aSolucoes, cOrigem),oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 220,232,"Cancelar",oDlg1,{|| lRet := .F., oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return lRet

/*/{Protheus.doc} ValJust
//Valida a Justificativa.
@author IT UP
@since 21/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ValJust()
Local lRet := .T.

dbSelectArea("ZDF")
dbSetOrder(1)

if dbSeek(xFilial("ZDF")+cJustif)
	cDescJu := ZDF->ZDF_DESCRI
	oGet3:Refresh()
else
	Help(" ",1,"JUSTIFICATIVA",,"Justificatica não cadastrada, informar uma justificativa valida.",1,0)
	lRet := .F.
endif

Return lRet

/*/{Protheus.doc} SolicApro
// Verifica se precisa Solicitar a Aprovação de Gerentes e Diretores
@author IT UP
@since 21/04/2021
@version 1.0
@return ${return}, ${return_description}
@param lContrato, logical, descricao
@type function
/*/
User Function SolicApro(lOrca, cOrigem)
Local aDif
Local nX
Local lRet := .T.
Local cAux
Local lFirst := .T.
Local lAprovado := .F.
Local aRegPad := U_RegPdOrc()
Local nRegZDB := 0
Local cStatus := ""

Private cMotivo := ""
Private cJustif := Space(3)
Private cDescJu := ""
Private cDetBlo := ""
Private cDetJus := " "
Private aApliEq := {"Operacao Limpa","Operacao Agressiva"}
Private cApliEq := ""
Private aSolucoes := {}
Private aRegras   := {}
DEFAULT cOrigem := '1'
DEFAULT lOrca := .T.

// Há uma Solicitação em Aberto para esse contrato
dbSelectArea("ZDB")
dbSetOrder(1)
dbSeek(xFilial("ZDB")+FP0->FP0_PROJET)

while !Eof() .and. ZDB->(ZDB_FILIAl+ZDB_CONTRA) = xFilial("ZDB")+FP0->FP0_PROJET
	
	cStatus := ZDB->ZDB_STATUS
	nRegZDB := Recno()
	dbSkip()
	
enddo

if cStatus $ "13" // Ainda está em aprovação
	lRet := .F.
elseif cStatus $ "4"
	// Verifcar se o que foi Aprovado bate com o que está no contrato.
	lAprovado := .T.
elseif cStatus $ "2"
	if MsgYesNo("Solicitação de Aprovação rejeitada, quer submeter a nova aprovação ?.","Solicitação rejeitada" )
		lRet := .T.
	else
		Return .F.
	endif
endif

if nRegZDB > 0
	dbGoto(nRegZDB)
endif

if !lRet
	MsgAlert("Há uma solicitação de Aprovação em aberto para esse contrato. Aguarde o termino da analise.","Solicitação em Aberto" )
	Return .F. //somente para os testes não bloquearem
endif

// Gerar o Array com as Soluçoes do Orçamento
U_SolCont(lOrca) // Chamar com .T. quando está na tela do Orçamento.

dbSelectArea("ZDA")
dbSetOrder(1)
dbSeek(xFilial("ZDA")+FP0->FP0_PROJET)

ArrayRegras( aRegras, "ZDA" )

// Se Ultima solicitação está aprovada e o Orcamento foi mantidao pode Efetivar 
if lAprovado 
	if ManteveOrc(aRegras) 
		Return .T.
	else  
		MsgAlert("Orçamento foi alterado e será analizado e ,se necessario, deverá passar por nova aprovação","Orçamento Alterado" )
	endif
endif


dbSelectArea("ZD5")  //  Regras Comerciais do Contrato
dbSetOrder(1)
dbSeek(xFilial("ZD5")+FP0->FP0_PROJET)

dbSelectArea("ZDA")  // Regras Comerciais padrão/anteriores
dbSetOrder(1)
dbSeek(xFilial("ZDA")+FP0->FP0_PROJET)

//Verifica se o preço de referencia de cada item está preenchido, senao aborta
cMsg := ""

aSX3 := SX3->(GetArea())

SX3->(dbSetOrder(2))
SX3->(dbSeek("ZD7_PERLOC"))
cCombo1 := X3CBox()
aCombo1 := StrTokArr(cCombo1, ";")

SX3->(dbSeek("ZD7_REGTRA"))
cCombo2 := X3CBox()
aCombo2 := StrTokArr(cCombo2, ";") 

RestArea(aSX3)

For nX := 1 To Len(aSolucoes)
	cAux 		:= ""
	cTipFami := ""

	If aSolucoes[nX,6] == 0 // Não tem preço referencia
		If Empty(aSolucoes[nX,2]) 
			cTipFami := U_fInfoFam(1, aSolucoes[nX,1])

			If cTipFami == '2' //Apenas estruturas. Serviços não valida
				cAux := "Família: " + Alltrim(Posicione("ZD3", 1, xFilial("ZD3") + aSolucoes[nX,1], "ZD3_DESCRI"))
			EndIf
		Else
			cTipFami := U_fInfoFam(1, aSolucoes[nX,1])

			If cTipFami == '1' //Apenas maquinas. Serviços não valida
				nPerLoc := aScan(aCombo1,{|x| AllTrim(aSolucoes[nX,10]) + "=" $ AllTrim(x) } )
				nRegTra := aScan(aCombo2,{|x| AllTrim(aSolucoes[nX,11]) + "=" $ AllTrim(x) } )
				cAux 	  := "Produto: " + Alltrim(aSolucoes[nX,2]) + " / Tipo Locação: " + AllTrim(aCombo1[nPerLoc]) + " / Reg. Trab: " + AllTrim(aCombo2[nRegTra])
			EndIf
		EndIf

		If !Empty(cAux)
			cMsg += cAux + CRLF
		EndIf
	EndIf
Next nX

If !Empty(cMsg)
	MsgStop("Não localizado preço referência para as famílias/itens abaixo, necessário ajustar antes de efetivar: " + CRLF  + CRLF + AllTrim(cMsg),"Preço Referência" )
	Return .F.
EndIf

// Valida as Regras Comerciais
aDif  := U_ValRegras(aRegPad)

if Len(aDif) > 0
	lRet := .F.
	cMotivo := "Regras Comerciais fora do padrão"
	for nX := 1 to Len (aDif)
		if Nx > 1
			cDetBlo += ", "
		endif
		cDetBlo += aDif[nX,2]
	next
endif

for nX := 1 To len(aSolucoes)

	If aSolucoes[nX,7] > aSolucoes[nX,9]// Passou do limite de desconto do Vendedor
		cAux := Alltrim(Posicione("ZD3",1,xFilial("ZD3")+aSolucoes[nX,1],"ZD3_DESCRI"))
		MsgAlert("O preço de "+ cAux  +;
		" está abaixo do valor referencia e deverá ser submetido à aprovação.", "Preco Invalido" )
		if lFirst
			cDetBlo += " Desconto : "
			lFirst := .F.
		else
			if !Empty(cDetBlo)
				cDetBlo += ", "
			endif
		endif
		cDetBlo += cAux

	endif
	if !Empty(cAux)
		if !Empty(cMotivo)
			cMotivo += " / "
		endif
		cMotivo += "Desconto"
	endif
next nX  

if !Empty(cMotivo)
	lRet := .F.
	U_DlgJusOr(aDif , aSolucoes, cOrigem, aRegras)
endif

Return lRet

Static function WfRegrDesc(aDif, aRegras, aSolucoes, cOrigem )
Local aCardData := {}
Local aAtachs
Local cProcess
Local cId      := ""
Local nSoluc   := 0
Local cSoluc   := ""
Local cDesc    := ""
Local cCodigo  := ""
Local nDescMax := 0
Local nDif     := 0
Local cNRegra  := ""
Local nTotal   := 0
Local aEmail   := {}
Local cXml     := ""
Local cEmaUser := Alltrim(UsrRetMail(RetCodUsr()))

if cEmaUSer = "acircenis@itup.com.br"
	cEmaUser := "fpessoa@itup.com.br"
endif

// Prepara os dados do Card do Fluig
aadd(aCardData ,{"emailSolicitante" , cEmaUser }) //"patricia.reis@grupoorguel.com.br"
aadd(aCardData ,{"dataSolicitacao" ,  Dtoc(dDataBase)})
aadd(aCardData ,{"codFilial" ,  cFilAnt})
aadd(aCardData ,{"codVendedor1" , FP0->FP0_VENDED})
aadd(aCardData ,{"nomeVendedor1" ,  FP0->FP0_NOMVEN})
aadd(aCardData ,{"codVendedor2" ,  FP0->FP0_XVIPRO})
aadd(aCardData ,{"nomeVendedor2" , Posicione("SA3",1,xFilial("SA3")+ FP0->FP0_XVIPRO,"A3_NOME")})
aadd(aCardData ,{"codCliente" ,  FP0->FP0_CLI   })
aadd(aCardData ,{"lojaCliente" , FP0->FP0_LOJA  })
aadd(aCardData ,{"tipoOperacao" ,  "Proposta"})
aadd(aCardData ,{"sequencial" ,  FP0->FP0_PROJET})
aadd(aCardData ,{"tipoLocacao" ,  U_fX3CBOX("ZD5_TIPLOC", ZD5->ZD5_TIPLOC)})
aadd(aCardData ,{"detalhesBloqueio" ,  FwNoAccent(cDetBlo)})
aadd(aCardData ,{"aplicacaoEquipamento" ,  FwNoAccent(cApliEq)})

// Regras Comerciais
for nDif := 1 to Len(aDif)
	cNRegra := AllTrim(Str(nDif,2,0))
	aadd(aCardData ,{"numRegra___"+cNRegra, cNRegra})
	aadd(aCardData ,{"descRegra___"+cNRegra, FwNoAccent(aDif[nDif, 2])})
	aadd(aCardData ,{"regraPadrao___"+cNRegra, FwNoAccent(aDif[nDif, 3])})
	aadd(aCardData ,{"regraContrato___"+cNRegra, FwNoAccent(aDif[nDif, 4])})
Next nDif

aadd(aCardData ,{"tipoJustificativa" , FwNoAccent( Trim(cDescJu))})
aadd(aCardData ,{"justificativa" ,  FwNoAccent(cDetJus)})

aadd(aCardData ,{"aplicacaoEquipamento" ,  cApliEq})

// Soluções do Contrato
For nSoluc := 1 to Len( aSolucoes)
	cSoluc := Alltrim(Str(nSoluc,3,0))

	if !Empty(aSolucoes[nSoluc, 2]) // é Equipamento usar codigo de Produto
		cCodigo := aSolucoes[nSoluc, 2]
		cDesc := Posicione("SB1",1,xFilial("SB1")+cCodigo,"B1_DESC")
	else //   USar a Familia+SubFamilia
		cCodigo := aSolucoes[nSoluc, 1]
		cDesc := Posicione("ZD3",1,xFilial("ZD3")+cCodigo,"ZD3_DESCRI")
	endif

	aadd(aCardData ,{"numSolucao___"+cSoluc ,  cSoluc})
//	aadd(aCardData ,{"codEquipamento___"+cSoluc , cCodigo })
	aadd(aCardData ,{"descSolucao___"+cSoluc , Alltrim(cDesc) })
	aadd(aCardData ,{"unidade___"+cSoluc ,  Posicione("ZD3",1,xFilial("ZD3")+aSolucoes[nSoluc, 1],"ZD3_UNIDAD")})
	aadd(aCardData ,{"volume___"+cSoluc , Alltrim( Str(aSolucoes[nSoluc, 3]))})
	aadd(aCardData ,{"valorLocacao___"+cSoluc , Alltrim( Str(aSolucoes[nSoluc,4]))})
	aadd(aCardData ,{"precoOrcado___"+cSoluc ,  Alltrim(Str(aSolucoes[nSoluc,5]))})
	aadd(aCardData ,{"precoReferencia___"+cSoluc ,  Alltrim(Str(aSolucoes[nSoluc,6]))})
	aadd(aCardData ,{"desconto___"+cSoluc ,  Alltrim(str(aSolucoes[nSoluc,7]))})
	aadd(aCardData ,{"valorDesconto___"+cSoluc , Alltrim(str(aSolucoes[nSoluc,8]))})
	nDescMax := Max(nDescMax, aSolucoes[nSoluc,7] )
	nTotal += aSolucoes[nSoluc,4]
next nSoluc

aadd(aCardData ,{"valorTotalSolicitacao", Alltrim(str(nTotal))})

// Aprovadores
dbSelectArea("ZZT")
dbSetOrder(2)
dbSeek(xFilial("ZZT")+cFilAnt)
while ! Eof() .and. ZZT->(ZZT_FILIAl+ZZT_FILALD) == xFilial("ZZT")+cFilAnt
	if ZZT->ZZT_TIPO = "DES"
		if nDescmax >= ZZT->ZZT_LIMINI .or. Len(aDif) > 0 // .and. nDescMax <= ZZT->ZZT_LIMFIM
			if ZZT->ZZT_NIVEL = '01'
				aadd(aCardData ,{"emailAprovacaoGerente" , UsrRetMail(ZZT->ZZT_APROV)}) //edinete.silveira@grupoorguel.com.br" /*UsrRetMail(ZZT->ZZT_APROV)*/ })
				aadd(aEmail, UsrRetMail(ZZT->ZZT_APROV) )
			else
				aadd(aCardData ,{"emailAprovacaoDiretor" , UsrRetMail(ZZT->ZZT_APROV)})//patricia.reis@grupoorguel.com.br" /*UsrRetMail(ZZT->ZZT_APROV)*/ })
				aadd(aEmail, UsrRetMail(ZZT->ZZT_APROV) )
			endif
		endif
	endif
	dbSkip()
enddo
cProcess := "regrasComerciaisDesconto"

// Tantar gerar um novo processo de Analise de Cedito no Fluig
if U_OGR10WF(cProcess, aCardData, aAtachs, @cId, @cXml)
	// Gravar pois o processo foi bem sucedido
	lRet := .T.

else
	lRet := .F.
endif

cRegras  := StrRegras(aRegras)
cSolucao := StrSolu(aSolucoes)

if lRet
	U_IncZDB(cID, cMotivo, cDetBlo, cJustif, cDescJu, cDetJus, cApliEq, aEmail, cXml, cRegras, cSolucao)
	U_fGrvZDD(1, AllTrim(M->FP0_PROJET) , cProcess, cXMl, {{lRet, Alltrim(cId),"","ZDB", ZDB->(RECNO()) } } )
endif

Return lRet


/*/{Protheus.doc} SolCont
// Retorna um array com as Soluções do Contrato
// Usado para enviar os dados para a aprovação
// Está Versão será usada dentro do Contrato
@author Alexandre Circenis
@since 06/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function SolCont(lContrato)

Local   aArea := GetArea()
Local   nPos
Local   nX

Local   nPosFami
Local   nPosProd
Local   nPosQtde
Local   nPostPer
Local   nPosRegi

Local   nPosVUnt
Local   nPosVBru
Local   aColsAux
Local   aHeadAux
Local   cFamilia := ""
Local	nCntFam
Default lContrato := .T.


aSolucoes := {}

if lContrato

	for nCntFam := 1 to Len(aFamFold)

		if aFamFold[nCntFam, 3]
			cFamilia := aFamFold[nCntFam,1]
			aHeadAux  := aObjFech[nCntFam]:aHeader
			aColsAux  := aObjFech[nCntFam]:aCols

			nPosProd  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_CODIGO"} )
			nPosQtde  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_QTDORC" } )

			nPosVUnt  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_PRCORC"} )
			nPosVBru  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_VLRORC"} )
			nPosTPer  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_PERLOC"} )
			nPosRegi  := aScan(aHeadAux,{|x| AllTrim(x[2]) == "ZD7_REGTRA"} )

 			for nX := 1 to Len(aColsAux)
				if !aTail(aColsAux[nX])
					cTipFam := U_fInfoFam(1, cFamilia)
					if cTipFam = "2" // Estruturas
						nPos := if(Len(aSolucoes) =0 ,0, Ascan(aSolucoes, {|x| x[1] = cFamilia}))
						if nPos = 0
							//              Familia ,Produto    ,volume,Vlr Locacao, Preco Orca ,Prc Ref,% Desc, Valor Desc, Limite Desconto
							Aadd(aSolucoes,{cFamilia,""         , 0    ,0          , 0         , 0     ,0     , 0         , 0               ,""})
							nPos := Len(aSolucoes)

					    endif
					elseif cTipFam = '1' // Maquinas
						nPos := if(Len(aSolucoes) =0 ,0, nPos :=Ascan(aSolucoes, {|x| x[2] = Alltrim(aColsAux[nX, nPosProd])}))
						if nPos = 0
							//	             Familia  ,Produto                 ,volume,Vlr Locacao, Preco Orca ,Prc Ref,% Desc, Valor Desc, Limite Desconto,Tipo Per                       , Regime de Trabalho
							if nPosRegi > 0
					     		Aadd(aSolucoes,{ cFamilia , aColsAux[nX, nPosProd] , 0    ,0          , 0          , 0     ,0     , 0         ,   0            ,Alltrim(aColsAux[nX, nPosTper]), Alltrim(aColsAux[nX, nPosRegi]) })
							else
								Aadd(aSolucoes,{ cFamilia , aColsAux[nX, nPosProd] , 0    ,0          , 0          , 0     ,0     , 0         ,   0            ,Alltrim(aColsAux[nX, nPosTper]),"" })
							endif
					     	nPos := Len(aSolucoes)

					     endif

					endif
					if cTipFam $ "12"
						aSolucoes[nPos, 3] += aColsAux[nX, nPosQtde] // Volume
						aSolucoes[nPos, 4] += aColsAux[nX, nPosVBru] // Valor Locação
					endif
				EndIf
			Next nX
		EndIf

	Next nCntFam

else

	dbSelectArea("ZD7")
	dbSeek(xFilial("ZD7")+FP0->FP0_PROJET)
	while !Eof() .and. ZD7->(ZD7_FILIAL + ZD7_PROJET) = xFilial("ZD7")+FP0->FP0_PROJET

		cTipFam := U_fInfoFam(1, ZD7->ZD7_GRUPO)

		if cTipFam = "2" // Estruturas
			nPos := if(Len(aSolucoes) =0 ,0, Ascan(aSolucoes, {|x| x[1] = ZD7->ZD7_GRUPO}))
			if nPos = 0
				//              Familia ,Produto    ,volume,Vlr Locacao, Preco Orca ,Prc Ref,% Desc, Valor Desc, Limite Desconto
				Aadd(aSolucoes,{cFamilia,""         , 0    ,0          , 0         , 0     ,0     , 0         , 0               ,""})
				nPos := Len(aSolucoes)

			endif
		elseif cTipFam = '1' // Maquinas
			nPos := if(Len(aSolucoes) =0 ,0, nPos :=Ascan(aSolucoes, {|x| x[2] = ZD7->ZD7_CODIGO}))
			if nPos = 0
				//	             Familia  ,Produto          ,volume,Vlr Locacao, Preco Orca ,Prc Ref,% Desc, Valor Desc, Limite Desconto,Tipo Per        , Regime de Trabalho
				Aadd(aSolucoes,{ cFamilia , ZD7->ZD7_CODIGO , 0    ,0          , 0          , 0     ,0     , 0         ,   0            , ZD7->ZD7_PERLOC, ZD7->ZD7_REGTRA })
				nPos := Len(aSolucoes)

		     endif

		endif

		if cTipFam $ "12"
			aSolucoes[nPos, 3] += ZD7->ZD7_QTDORC // Volume
			aSolucoes[nPos, 4] += ZD7->ZD7_VLRORC // Valor Locação
		endif

		dbSelectArea("ZD7")
		dbSkip()
	enddo
endif

for nx := 1 to Len(aSolucoes)
	if aSolucoes[nX,3] = 0
		aSolucoes[nX,3] := 1
	endif
	if aSolucoes[nX,4] = 0
		aSolucoes[nX,4] := 1
	endif
	if aSolucoes[nX,5] = 0
		aSolucoes[nX,5] := aSolucoes[nx, 4]/aSolucoes[nx, 3]
	endif

	// Definir Preco de Referencia

	if Empty(aSolucoes[nX,2]) // Familia

		aSolucoes[nX,6] := Posicione("ZD1",1,xFilial("ZD1")+aSolucoes[nX,1],"ZD1_PRCREF")
		aSolucoes[nX,9] := Posicione("ZD1",1,xFilial("ZD1")+aSolucoes[nX,1],"ZD1_PERVEN")

	else

		aSolucoes[nX,6] := Posicione("ZD1",2,xFilial("ZD1")+aSolucoes[nX,2]+aSolucoes[nX,10],"ZD1_PRCREF")
		aSolucoes[nX,9] := Posicione("ZD1",2,xFilial("ZD1")+aSolucoes[nX,2]+aSolucoes[nX,10],"ZD1_PERVEN")

	endif

	nDesconto := aSolucoes[nX,6] - aSolucoes[nX,5]
	if nDesconto > 0
		aSolucoes[nX,7] := (nDesconto / aSolucoes[nX,6]) * 100
		aSolucoes[nX,8] := nDesconto * aSolucoes[nPos, 3]
	else
		nDesconto := 0
	endif

next

RestArea(aArea)

Return aSolucoes

/*/{Protheus.doc} ArrayPad
Preenche um array com as regaras padrões da Familia
Se Houver mais de uma familia somente as regras coincidentes serão mantidas
@type function
@version  1.0
@author IT UP
@since 31/05/2021
@param aPadrao, array, Array com as regras padrão da familia
@param cFamilia, character, Codigo da familia para preencher o arrqy com as regras
@return return_type, return_description
/*/
Static Function ArrayPad( aPadrao, cFamilia)
Local aArea := GetArea()
Local nField
Local cCampoZDA
Local nPosCampo

dbSelectArea("ZD6")
if dbSeek(xFilial("ZD6")+cFamilia)

	for nField := 1 to fCount()

		if !(FieldName( nField))$ "ZD6_FILIAL ZD6_GRUPO"

			cCampoZDA := "ZDA_"+SubStr(FieldName( nField),5)
			//cCampoZD5 := "ZD5_"+SubStr(FieldName( nField),5)
			if Len(aPadrao) = 0  .or. (nPosCampo := AScan( aPadrao , {|x| x[1] = cCampoZDA} )) = 0
				Aadd(aPadrao,{cCampoZDA, FieldGet(nField)})
			elseif FieldGet(nField) <> aPadrao[nPosCampo , 2] 
				aPadrao[nPosCampo, 2] := CriaVar(cCampoZDA ,.T.)
			endif
			//M->&(cCampoZD5) := FieldGet(nField)

		endif
	next

endif

RestArea(aArea)

Return
/*/{Protheus.doc} ArrayRegras
Preenche Array com as Regras garvadas
@type function
@version  1.0
@author IT UP
@since 31/05/2021
@param aRet, array, Array com as regras
@param cArq, character, Tabela onde estão gravadas a regras do Arquivo
@return return_type, Nil
/*/
Static Function ArrayRegras( aRet, cArq )
Local aArea := GetArea()
Local nField
Local cCampo
Local nPosCampo

dbSelectArea("ZDA")

for nField := 1 to fCount()

	if !(FieldName( nField))$ "ZDA_FILIAL ZDA_PROJET"

		cCampo := FieldName( nField)
		Aadd(aRet,{cCampo, ZDA->(&cCampo)})

	endif

next

RestArea(aArea)

Return



STATIC function strregras(aPadrao)
Local nX 
Local cRet := ""
Local cAux
for nX := 1 to Len(aPadrao)
	if ValType(aPadrao[nX,2]) = "C"
		cAux := aPadrao[nX,2]
	Elseif ValType(aPadrao[nX,2]) = "N"
		cAux := Str(aPadrao[nX,2])
	Elseif ValType(aPadrao[nX,2]) = "D"
		cAux := Ctod(aPadrao[nX,2])
	Elseif ValType(aPadrao[nX,2]) = "L"
		cAux := if(aPadrao[nX,2] , "TRUE", "FALSE")
	endif

	cRet += aPadrao[nX,1]+";"+cAux+CRLF

next

Return cRet

STATIC function StrSolu( aSolucao)
Local nX 
Local cRet := ""

For nX := 1 to Len(aSolucao)

	cRet += aSolucao[nX,1]+";" // Familia
	cRet += aSolucao[nX,2]+";" // Produto
	cRet += Str(aSolucao[nX,3])+";" // Valume
	cRet += Str(aSolucao[nX,4])+";"	// Vlr Locacao
	cRet += Str(aSolucao[nX,5])+";"	// Preco Orcado
	cRet += Str(aSolucao[nX,6])+CRLF // Prc Referencia

next nX

Return cRet

/*/{Protheus.doc} RegPdOrc
Retorno o Array com as regras padrão do Orçamento
@type function
@version  1.0
@author IT UP
@since 31/05/2021
@return return_type, Array com as regras Padrão do Orçamento
/*/
User Function RegPdOrc()
Local aRet := {}
Local nContFam 

for nContFam := 1 to Len(aFamFold) 

	if aFamFold[nContFam, 3 ]
		ArrayPad(aRet , Left(aFamFold[nContFam,1],3)) // Set as Regras Padrão na Efetivação
	endif

next

Return aRet



User Function AprovxRegras(aRegras)

Local cRegras := ""
Local lRet := .T.

cRegras := StrRegras(aRegras)

lRet := Alltrim(ZDB->ZDB_REGRAS) = Alltrim(cRegras)
	
Return lRet


Static Function AprovxSoluc(aSolucoes)

Local cSolucao := ""
Local lRet

cSolucao := StrSolu(aSolucoes)

lRet := Alltrim(ZDB->ZDB_SOLUCA) = alltrim(cSolucao)
	
Return lRet

Static Function ManteveOrc(aRegras)
Local lRet := .T.

// Comparar a Regra Aprovada com regra atual e
// Aprovada com Regra Padrão 
if !U_AprovxRegras(aRegras) 
	lRet := .F.
endif

// Comparar Solução Atual com Aprovada

if lRet .and. !AprovxSoluc(aSolucoes) 
	lRet := .F.
endif

Return lRet
