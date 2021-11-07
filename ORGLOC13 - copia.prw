#include 'protheus.ch'
#include 'parmtype.ch'

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | ORGLOC13  | Autor: | Alexandre Circenis | Data: | Dezembro/20    |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para importar a lista dos trechos		                    |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                             	               		        |
+------------+------------------------------------------------------------------+
*/
User Function ORGLOC13(oGetDados)
Local nPosFam  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_FAMILI" } ) //Familia
Local nPosTre  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_TRECHO" } ) //Trecho
Local cTipFam  := ""

Private _cPasta   := ""
Private _cNomArq  := ""
Private lTreRef   := .F.

/*
If FP0->FP0_XSTAT2 <> '3'
	Help(" ",1,"LIB_LISTA_2",,"Contrato não encontra-se no status 'Lançar lista definitiva do Trecho Referência'.",1,0)
	Return .F.
EndIf
*/

If oFolder:nOption <> nFolderPla
	Help(" ",1,"IMP_LISTA_5",,"Necessário estar na aba 'Locações'.",1,0)
	Return .F.
EndIf

If FP0->FP0_DEMAND == "2"
	If !U_fValFunc()
		Return .F.
	EndIf
EndIf

cTipFam := U_fInfoFam(1, oDlgPla:aCols[oDlgPla:nAt, nPosFam])

If cTipFam == '1'
	Help(" ",1,"IMP_LISTA_1",,"Não é permitido importar listas de produtos para famílias do tipo Máquinas/Equipamento.",1,0)
	Return .F.
EndIf

lTreRef := U_fTreRef(1, FP0->FP0_PROJET, oDlgPla:aCols[oDlgPla:nAt, nPosFam], oDlgPla:aCols[oDlgPla:nAt, nPosTre] )

If !lTreRef
	If !U_fTreRef(2, FP0->FP0_PROJET, oDlgPla:aCols[oDlgPla:nAt, nPosFam], oDlgPla:aCols[oDlgPla:nAt, nPosTre] )
		Help(" ",1,"IMP_LISTA_2",,"Já foi realizada a importação da lista de produtos do trecho " + AllTrim(oDlgPla:aCols[oDlgPla:nAt, nPosTre]) + ".",1,0)
		Return .F.
	EndIf

	If !U_fTabCnt(1, FP0->FP0_FILIAL, FP0->FP0_PROJET )
		Help(" ",1,"IMP_LISTA_3",,"Não localizada a tabela de preço do contrato.",1,0)
		Return .F.
	EndIf
Else
	// Verificar se o Trecho já teve a Lista definitiva Liberadas
	If !U_fTreRef(3, FP0->FP0_PROJET, oDlgPla:aCols[oDlgPla:nAt, nPosFam], oDlgPla:aCols[oDlgPla:nAt, nPosTre] )
		Help(" ",1,"IMP_LISTA_4",,"Já foi realizada a liberação da lista definitiva dos trechos referencia, não será permitida qualquer alteração.",1,0)
		Return .F.
	EndIf
EndIf

cRetArq := SEL_ARQ() // Seleciona o Arquivo

If !Empty(cRetArq)
	_cPasta := Substr(cRetArq,1,3)
	_cNomArq := Alltrim(Substr(cRetArq,4,103))

	If !VerArquivo()
		Return()
	EndIf

	Processa( {|| Importa(oGetDados) }, "Aguarde...", "Carregando arquivo de Tabela de Preço...",.F.)
Else
	MsgStop("Operação cancelada!")
EndIf

Return
////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SEL_ARQ   ºAutor  ³Marçal de Campos    º Data ³  17/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Abre tela no servidor para o usuario localizar o arquivo   º±±
±±º          ³ que será utilizado.                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SEL_ARQ()

Local cNewPathArq   := cGetFile( "Arquivo CSV (*.CSV)|*.CSV|", "Selecione o Arquivo",,, .T., GETF_NETWORKDRIVE + GETF_LOCALHARD)

Return(cNewPathArq)

///////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³VerArquivoºAutor  ³ Paulo Eduardo - Consisa  º Data ³  11/01/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para verificar a existencia do arquivo a ser gerado para   º±±
±±º          ³evitar duplicidades.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Trump Realty Brazil                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerArquivo()

Local _lRet := .t.

_cNomArq := Alltrim (_cNomArq)

If ! Empty (_cNomArq)
	If At ("." , _cNomArq) == 0
		_cNomArq := _cNomArq + ".CSV"
	EndIf

	If Upper(Right (_cNomArq , 4)) <> ".CSV"
		MsgInfo ("O arquivo precisa ter extensao CSV. Por favor , verifique.")
		_lRet := .f.
	ElseIf !File (_cPasta + _cNomArq)
		Alert("Arquivo " + _cPasta + _cNomArq + " não encontrado! Verifique se o caminho e nome do arquivo estão corretos.")
		_lRet := .f.
	EndIf
Else
	MsgInfo ("Por favor , informe o nome do arquivo.")
	_lRet := .f.
EndIf

Return (_lRet)


/*/{Protheus.doc} Str2Array
//Converter CSV para Array
@author IT UP
@since 09/11/2020
@version 1.0
@return ${return}, ${return_description}
@param cString, characters, descricao
@param cDelim, characters, descricao
@type function
/*/
Static Function Str2Array(cString, cDelim)

Local aPieces := {}
Local nProc

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atribui valores default aos parametros                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Default cString := ""
//Default cDelim  := "/"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona um delimitador ao final da string - pos while       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cString += if( len(cString)==0, "", cDelim )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ - Procura a posicao do delimitador                           ³
//³ - Adiciona a matriz o elemento delimitado                    ³
//³ - Elimina da string o elemento acima                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
do while ! empty( cString )

	if ! ( nProc := at( cDelim, cString ) ) == 0

		aadd( aPieces, substr( cString, 1, nProc - 1 ) )
		cString := substr( cString, nProc + len( cDelim ) )

	endif

enddo

Return aPieces

///////////////////////////////////////////

/*/{Protheus.doc} Importa
//Cria o arry com a Tabela de Preço
@author IT UP
@since 09/11/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Importa(oGetDados)
Local nLinhas   := 0
Local nCount 	 := 0
Local aDados 	 := {}
Local aImport   := {}

Private lValid  := .T.

__cFileLog := Nil

// Primeiro prepara array com os dados do cabecalho
FT_FUSE(_cPasta+_cNomArq)
FT_FSKIP()
nLinhas := FT_FLASTREC()

// Vai para o Topo do Arquivo
FT_FGOTOP()

ProcRegua(nLinhas)
cLinha := FT_FREADLN()// Salta Linah de Cabeçalho
FT_FSKIP()

While !FT_FEOF()
	nCount++
	IncProc("Tabela de Preco: Lendo linha " + cValToChar(nCount) + " de " + cValToChar(nLinhas) )

	// Le dados da linha corrente
	cLinha := FT_FREADLN()

	aDados    := Str2Array(cLinha,";")
	aDados[2] := Val(StrTran(Alltrim(aDados[2]),',','.'))

	nPosImp := aScan( aImport, { | x | AllTrim( x[1] ) == AllTrim(aDados[1]) } ) 

	If nPosImp == 0
		aAdd(aImport,aClone(aDados))
	Else
		aImport[nPosImp][2] += aDados[2]
	EndIf

	// Vai para a proxima linha
	FT_FSKIP()
End

// Fecha arquivo de Cabecalho
FT_FUSE()

Processa({|| ValidaGrid(aImport)})

if lValid

	If MsgYesNo("Confirma a importação da lista selecionada?")
		Processa({|| ImpGrid(aImport, oGetDados)})
	EndIf

else
	DispLog()
endif

Return


Static Function ValidaGrid(aImport)
Local nLinha
Local nLinhas := len(aImport)
Local nPosFam  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_FAMILI" } ) //Familia

lMsFinalAuto := .F.
lMsHelpAuto  := .F.

For nLinha := 1 To Len(aImport)

	IncProc("Tabela Preco: Validando linha "+AllTrim( Alltrim(Str(nLinha)) )+" de "+AllTrim( Str(nLinhas) ))

    // Cada Linha deve ter 2 campos
	if Len(aImport[nLinha]) <> 2
		AutoGrLog( "Linha " + Alltrim(Str(nLinha)) + " não possui 2 campos. Verifique a planilha, grave ela novamente e tente reimportar." )
		lValid := .F.
	Else
		// A Primeira Coluna esta Preenchida dever estar cadastrada na SB1

		if !Empty(aImport[nLinha,1])
			cCodPrd 				:= "0" + cValToChar(Val(aImport[nLinha,1]))
			aImport[nLinha,1] := cCodPrd

			dbSelectArea("SB1")
			dbSetOrder(1)
			if dbSeek(xFilial("SB1")+AllTrim(aImport[nLinha,1]))

				cTipFam := U_fInfoSub(1, AllTrim(oDlgPla:aCols[oDlgPla:nAt, nPosFam]))

				//Produto deve ser da familia posicionada no grid ou ser multifamilia
				If AllTrim(oDlgPla:aCols[oDlgPla:nAt, nPosFam]) <> AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP) .And. SB1->B1_XPRECIF <> "2"
					AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " Produto "+AllTrim(aImport[nLinha,1])+" - "+Alltrim(SB1->B1_DESC)+" não pertence a família " + AllTrim(oDlgPla:aCols[oDlgPla:nAt, nPosFam]) + " e não é multifamília." )
				 	lValid := .F.
				EndIf

				//Tipo de Equipamento deve ser estrutura
				If SB1->B1_XTIPEQU <> "2"
					AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " Produto "+AllTrim(aImport[nLinha,1])+" - "+Alltrim(SB1->B1_DESC)+" não é do tipo 'Estrutura'." )
				 	lValid := .F.
				EndIf

				//Deve ter peso cadastrado
				If cTipFam <> '4'
					if SB1->B1_PESO <= 0
						AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " Produto "+AllTrim(aImport[nLinha,1])+" - "+Alltrim(SB1->B1_DESC)+" não possui possui peso cadastrado, para usar cadastre o peso antes ." )
					 	lValid := .F.
					endif
				Else
					//Se for por valor de indenização, deve ter o valor cadastrado
					dbSelectArea("SBZ")
					dbSetOrder(1)
					if dbSeek(xFilial("SBZ")+Alltrim(aImport[nLinha,1]))
						if SBZ->BZ_INDENIZ <= 0
							AutoGrLog( "Linha " + AllTrim(Str(nLinha)) + " Produto " + Alltrim(aImport[nLinha,1]) + " - " + Alltrim(SB1->B1_DESC) + " não possui 'Valor de Indenização' cadastrado." )
							lValid := .F.
						endif
					else
						AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " Produto "+Alltrim(aImport[nLinha,1])+" - "+Alltrim(SB1->B1_DESC)+" não possui possui cadastrado de Indicadores de Produtos, cadastre as informaçoes antes de usar esse produto." )
						lValid := .F.
					endif
				endif
			else
				AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " Produto "+Alltrim(aImport[nLinha,1])+" Produto não Cadastrado, cadastre o produto ou use um produto já cadastrado." )
				lValid := .F.
			endif
		endif

		// A Terceira Coluna deve estar Preenchida e ser maio que zero
		/*
		aImport[nLinha,2] := StrTran(Alltrim(aImport[nLinha,2]),',','.')// Trocar a Virgula por Ponto decimal
		if Empty(aImport[nLinha,2])
			AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " quantidade não preenchida." )
			lValid := .F.
		elseif Val(aImport[nLinha,2])<=0
			AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " quantidade deve ser maior que Zero." )
			lValid := .F.
		endif
		*/
		if aImport[nLinha,2] <= 0
			AutoGrLog( "Linha "+Alltrim(Str(nLinha))+ " quantidade deve ser maior que Zero." )
			lValid := .F.
		endif
	endif

next

if len(aImport) =0
		AutoGrLog( "Lista vazia, informe uma lista valida." )
		lValid := .F.
endif

return

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*/{Protheus.doc} ImpGrid
// Grava a Tabela de Preço
@author IT UP
@since 09/11/2020
@version 1.0
@return ${return}, ${return_description}
@param aImport, array, descricao
@type function
/*/

Static Function ImpGrid(aImport, oGetDados)
Local nX:=0
Local nLinhas  := Len(aImport)
Local nPosObr  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_OBRA"   } ) //Obra
Local nPosSeq  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_SEQGRU" } ) //Seq Gru
Local nPosFam  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_FAMILI" } ) //Familia
Local nPosDFam := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_XDFAMI" } ) //Desc Familia
Local nPosTre  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_TRECHO" } ) //Trecho
Local nPosRef  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_XTRERE" } ) //Trecho
Local nPosPrd  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_PRODUT" } ) //Produto
Local nPosDsc  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_DESPRO" } ) // Descrição do Produto
Local nPOsQtd  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_QUANT"  } )  // Quantidade
Local nPosPes  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_PESPAD" } ) // Peso Padrão
Local nPOsPto  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_PESTOT" } ) // Peso Total
Local nPosInd  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_VLINPA" } ) // Valor Idenizacao Padrao
Local nPOsTin  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_INDTOT" } ) // Valor de Indenização Total
Local nPOsUni  := aScan( oGetDados:aHeader, { | x | Trim( x[2] ) == "FPA_UNIDIA" } ) // Valor Unit Dia7
Local nPosGuiM  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_TPGUIM" } ) //Resp Frete Ida
Local nPosGuiD  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_TPGUID" } ) //Resp Frete Volta
Local nPosSaba  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_SABADO" } ) //Sabado
Local nPosDomi  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_DOMING" } ) //Domingo
Local nPosUltF  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_ULTFAT" } ) //Ult Fat
Local nPosDNFR  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_DNFRET" } ) //Dt NF Ret
Local nPosDIni  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_DTINI"  } ) //Dt Inicio
Local nPosDFim  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_DTENRE" } ) //Dt Fim
Local nPosDFat  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_DTFIM"  } ) //Prox Fat
Local nPosLDia  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_LOCDIA" } ) //Loc Dias
Local nPosOrig  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_XORITE" } ) //Origem Item
Local ny
Local nAtual   := 0
Local cSeqGru  := ""
Local lReimp   := .F.
Local aReimp   := {}
Local nDias    := 0
Local aRegCom  := U_fRegCome(FP0->FP0_PROJET)
Local nPosTpL  := aScan( aRegCom, { | x | Trim( x[1] ) == "ZD5_TIPLOC"   } ) //Tipo de Locação

/* variaveis iniciadas - PA */
Local nPosVlFa	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_VLBRUT"} )
Local nPosPUni 	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_PRCUNI"} )
Local nPosCond	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_CONPAG"} )
Local nPosFilR	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_FILEMI"} )
Local nPosVlBs	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_VRHOR"} )

 
If aRegCom[nPosTpL][2] == "D"
	nDias := 1
ElseIf aRegCom[nPosTpL][2] == "S"
	nDias := 7
ElseIf aRegCom[nPosTpL][2] == "Q"
	nDias := 15
ElseIf aRegCom[nPosTpL][2] == "M"
	nDias := 30
EndIf

nX := 1
nY := 1

lReimp := fReimp(oDlgPla, 1)

If lReimp
	aReimp := fReimp(oDlgPla, 2)

	If Len(aReimp) > 0
		For nY := 1 To Len(aReimp)
			oDlgPla:aCols[aReimp[nY][1], Len(oDlgPla:aHeader) + 1] := .T. //Marca como deletado os registros já importados
		Next nY
	EndIf
EndIf

For nX:=1 to Len(aImport)

	IncProc("Lista Produtos: Importando linha " + AllTrim( Str(nX) ) + " de " + AllTrim( Str(nLinhas) ))

	If Len(aReimp) == 0
		If nX > 1
			cSeqGru := U_fRetSeq(oGetDados)

			oGetDados:AddLine (.f., .f.)
			nAtual := Len(oGetDados:aCols)
			oGetDados:aCols[nAtual, nPosSeq]  := cSeqGru
		Else
			nAtual := oDlgPla:nAt
		EndIf
	Else
		If Len(aImport) <= Len(aReimp)
			nAtual  := aReimp[nX][1]
		Else
			If nX <= Len(aReimp)
				nAtual  := aReimp[nX][1]
			Else
				cSeqGru := U_fRetSeq(oGetDados)

				oGetDados:AddLine (.f., .f.)
				nAtual := Len(oGetDados:aCols)
				oGetDados:aCols[nAtual, nPosSeq]  := cSeqGru
			EndIf
		EndIf
	EndIf

	oGetDados:aCols[nAtual, nPosObr]  := oDlgPla:aCols[oDlgPla:nAt, nPosObr]
	oGetDados:aCols[nAtual, nPosFam]  := oDlgPla:aCols[oDlgPla:nAt, nPosFam]
	oGetDados:aCols[nAtual, nPosDFam] := oDlgPla:aCols[oDlgPla:nAt, nPosDFam]
	oGetDados:aCols[nAtual, nPosTre]  := oDlgPla:aCols[oDlgPla:nAt, nPosTre]
	oGetDados:aCols[nAtual, nPosPrd]  := aImport[nX, 1]

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+aImport[nX,1])
	oGetDados:aCols[nAtual, nPosDsc] := SB1->B1_DESC
	oGetDados:aCols[nAtual, nPOsQtd] := aImport[nX, 2]
	oGetDados:aCols[nAtual, nPosPes] := SB1->B1_PESO // Peso Padrão
	oGetDados:aCols[nAtual, nPOsPto] := SB1->B1_PESO * aImport[nX, 2]  // Peso Total
	oGetDados:aCols[nAtual, nPosGuiM] := Space(TamSx3("FPA_TPGUIM")[1])
   oGetDados:aCols[nAtual, nPosGuiD] := Space(TamSx3("FPA_TPGUID")[1])
   oGetDados:aCols[nAtual, nPosSaba] := Space(TamSx3("FPA_SABADO")[1])
   oGetDados:aCols[nAtual, nPosDomi] := Space(TamSx3("FPA_DOMING")[1])
   oGetDados:aCols[nAtual, nPosUltF] := StoD("")
   oGetDados:aCols[nAtual, nPosDNFR] := StoD("")
   oGetDados:aCols[nAtual, nPosDIni] := dDataBase
   oGetDados:aCols[nAtual, nPosDFat] := DaySum(dDataBase,nDias)
   oGetDados:aCols[nAtual, nPosDFim] := DaySum(dDataBase,nDias)
   oGetDados:aCols[nAtual, nPosLDia] := nDias
   //oGetDados:aCols[nAtual, nPosStru] := StrZero(nX,19)

	If nPosOrig > 0	.and. oGetDados:aCols[nAtual, nPosOrig] <> "0" 
		oGetDados:aCols[nAtual, nPosOrig] := "1" //Importado Lista
	EndIf

	cTipFam := U_fInfoSub(1, AllTrim(oDlgPla:aCols[oDlgPla:nAt, nPosFam]))

	If cTipFam == "4"
		dbSelectArea("SBZ")
		dbSetOrder(1)
		If dbSeek(xFilial("SBZ")+aImport[nx,1])
			oGetDados:aCols[nAtual, nPosInd] := SBZ->BZ_INDENIZ
			oGetDados:aCols[nAtual, nPOsTin] := SBZ->BZ_INDENIZ * aImport[nX, 2]
		EndIf
	EndIf

	If !lTreRef
		nRet := U_fTabCnt(2, FP0->FP0_FILIAL, FP0->FP0_PROJET, oDlgPla:aCols[oDlgPla:nAt, nPosFam], SB1->B1_COD )
		oGetDados:aCols[nAtual, nPOsUni] := nRet
		oGetDados:aCols[nAtual, nPosRef] := "2"

		// --------------------------------------------------------------- //
		// adicionamos los actualizadores de los campos abajo listados - PA//
		// --------------------------------------------------------------- //
		oGetDados:aCols[nAtual][nPosPUni] := (oGetDados:aCols[nAtual][nPOsUni] * nDias )
		oGetDados:aCols[nAtual][nPosVlFa] := (oGetDados:aCols[nAtual][nPosPUni] * oGetDados:aCols[nAtual][nPOsQtd])
		oGetDados:aCols[nAtual][nPosVlBs] := (oGetDados:aCols[nAtual][nPosPUni] * oGetDados:aCols[nAtual][nPOsQtd])

	Else
		oGetDados:aCols[nAtual, nPosRef] := "1"
	EndIf

	If oGetDados:aCols[nAtual, Len(oGetDados:aHeader) + 1] // Linha esta deletada desdeletar
		oGetDados:aCols[nAtual, Len(oGetDados:aHeader) + 1] := .F.
	EndIf

	// ---------------------------------------------------------------- //
	// adicionamos los actualizadores de los campos abajo listados - PA //
	// ---------------------------------------------------------------- //
	oGetDados:aCols[nAtual][nPosCond] := Posicione("ZD5",1,xFilial("ZD5")+FP0->FP0_PROJET,"ZD5->ZD5_CONPAG")
	if empty(oGetDados:aCols[nAtual][nPosFilR])
		oGetDados:aCols[nAtual][nPosFilR] := xFilial("FPA")
	endif

Next nX

aSort(oGetDados:aCols,,,{|x,y| x[nPosObr] + x[nPosFam] + x[nPosRef] + x[nPosTre] + x[nPosSeq] < y[nPosObr] + y[nPosFam] + y[nPosRef] + y[nPosTre] + y[nPosSeq] })

oGetDados:ForceRefresh ( )
oGetDados:Refresh()

//atualiza rodape
If ExistBlock("LC001LOC")
	ExecBlock("LC001LOC",.F.,.T.,{ "ATUALIZA"})
EndIf

Return



Static Function DispLog()

Local cTexto := LeLog()
Local cMask  := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cFile   := ""
Local cArqu  := NomeAutoLog()
Local oDlgLog

Define Font oFont Name "Mono AS" Size 6, 12

Define MsDialog oDlgLog Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlgLog Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 175 Type  1 Action oDlgLog:End() Enable Of oDlgLog Pixel // Apaga
Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cTexto ) ) ) Enable Of oDlgLog Pixel

Activate MsDialog oDlgLog Center

fErase(cArqu)

Return


Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet

Static Function fReimp(oDlgPla, nTipo)
Local xRet
Local nPosObr  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_OBRA" 	} ) //Obra
Local nPosFam  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_FAMILI" } ) //Familia
Local nPosTre  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_TRECHO" } ) //Trecho
Local nPosPrd  := aScan( oDlgPla:aHeader, { | x | Trim( x[2] ) == "FPA_PRODUT" } ) //Produto
Local cCodObra := oDlgPla:aCols[oDlgPla:nAt, nPosObr]
Local cFamilia := oDlgPla:aCols[oDlgPla:nAt, nPosFam]
Local cTrecho  := oDlgPla:aCols[oDlgPla:nAt, nPosTre]
Local nI 		:= 0
Local lPrim    := .T.

For nI := 1 To Len(oDlgPla:aCols)
	If AllTrim(cCodObra) == AllTrim(oDlgPla:aCols[nI, nPosObr]) .And.;
		AllTrim(cFamilia) == AllTrim(oDlgPla:aCols[nI, nPosFam]) .And.;
		AllTrim(cTrecho)  == AllTrim(oDlgPla:aCols[nI, nPosTre])

		If nTipo == 1
			If lPrim
				xRet 	:= .F.
				lPrim := .F.
			EndIf

			If !Empty(oDlgPla:aCols[nI, nPosPrd])
				xRet := .T.
				Exit
			EndIf

		ElseIf nTipo == 2
			If lPrim
				xRet  := {}
				lPrim := .F.
			EndIf
			aAdd(xRet, { nI })
		EndIf
	EndIf
Next nI

Return xRet
