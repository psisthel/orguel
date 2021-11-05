#include 'protheus.ch'
#include 'parmtype.ch'

/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | ORGLOC15  | Autor: | Guilherme Coronado | Data: | Fevereiro/21   |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Liberação das listas definitivas dos trechos referencia          |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                                            			        |
+------------+------------------------------------------------------------------+
*/ 
User Function ORGLOC15(oDlgPla)
Local lRet  		:= .T.       
Local nI    		:= 0
Local nX    		:= 0
Local nZ    		:= 0
Local nRet  		:= 0
Local cCodObr		:= ""
Local cTipFam		:= ""
Local cCodFam		:= ""
Local cCodProd		:= ""
Local cCodPrj     	:= FP0->FP0_PROJET	
Local aFamEqu     	:= {}
Local aTreRef     	:= {}
Local aAllProd    	:= {}
Local aDupProd    	:= {}
Local nPesoPad  	:= 0
Local nPesoFam  	:= 0
Local nIndPad   	:= 0
Local nIndFam   	:= 0
Local nQtdLis   	:= 0
Local nMedRef   	:= 0
Local nPosArr   	:= 0
Local nMultFam   	:= 0
Local nQuant   		:= 0
Local nPosCFam   	:= 0
Local lTemTab  		:= .F.
Local lAditivo  	:= .F.
Local aCodFami    	:= {}
Local aAdtFami    	:= {}
Local lHaZerado     := .F.
Local nDias			:= 1
Local cCondPag		:= CriaVar("FPA_CONPAG")

Private cPrcMen		:= SuperGetMv("IT_PRCMEN", .F., "001")
Private nPosObra  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_OBRA"  } )	
Private nPosSeq   	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_SEQGRU"} )	
Private nPosFami  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_FAMILI"} )	
Private nPosTrec  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_TRECHO"} )
Private nPosProd  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_PRODUT"} )	
Private nPosQtde  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_QUANT" } )	
Private nPosPPad  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_PESPAD"} )	
Private nPosPTot  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_PESTOT"} )
Private nPosIPad  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_VLINPA"} )	
Private nPosITot  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_INDTOT"} )	
Private nPosUniD  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_UNIDIA"} )	
Private nPosVlFa  	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_VLBRUT"} )
Private nPosPUni 	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_PRCUNI"} )
Private nPosCond	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_CONPAG"} )
Private nPosFilR	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_FILEMI"} )
Private nPosVlBs	:= aScan(oDlgPla:aHeader,{|x| AllTrim(x[2]) == "FPA_VRHOR"} )



If oFolder:nOption <> nFolderPla
	Help(" ",1,"LIB_LISTA_1",,"Necessário estar na aba 'Locações'.",1,0)
	Return .F.
EndIf

If FP0->FP0_XSTAT2 <> '3'
	Help(" ",1,"LIB_LISTA_2",,"Contrato não encontra-se no status 'Lançar lista definitiva do Trecho Referência'.",1,0)
	Return .F.
EndIf

//Verifica se há trechos referencia que não estão processados
For nI := 1 To Len(oDlgPla:aCols)
	If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	
		cCodPrd := oDlgPla:aCols[nI][nPosProd]
		cCodFam := oDlgPla:aCols[nI][nPosFami]
		cTipFam := U_fInfoFam(1, cCodFam)

		If cTipFam == "2"
			If !Empty(cCodPrd)
				lProc := .F.
	   			ZD8->(dbSetOrder(2))
      			If ZD8->(dbSeek(xFilial("ZD8") + FP0->FP0_PROJET))
					While ZD8->(!Eof()) .And. ZD8->(ZD8_FILIAL + ZD8_PROJET) == xFilial("ZD8") + FP0->FP0_PROJET
						If ZD8->ZD8_TREREF == "S" .And. ZD8->ZD8_LIBLIS <> 'S'
							lProc := .T.
							Exit
						EndIf
						ZD8->(dbSkip())
					EndDo

					If !lProc
						Help(" ",1,"LIB_LISTA_5",,"Já foi realizada a liberação da lista definitiva de todos os trechos referencia desse contrato.",1,0)
						Return .F.
					EndIf
				EndIf
			Else
				Help(" ",1,"LIB_LISTA_6",,"Para realizar a liberação da lista definitiva é necessário que todas as linhas dos trechos referencia de todas as famílias estejam com produtos preenchidos.",1,0)
				Return .F.
			EndIf
		EndIf	
	EndIf
Next nI

If !MsgYesNo("Confirma a liberação das listas definitivas dos trechos referência?")
	MsgAlert("Processo abortado.")
	Return .F.
EndIf


//Encontra as famílias que estão no contrato
For nI := 1 To Len(oDlgPla:aCols)
	If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	
		nPosCFam := aScan( aCodFami, { | x | AllTrim( x[1] ) == AllTrim(oDlgPla:aCols[nI][nPosFami]) } ) 

		If nPosCFam == 0
			aAdd(aCodFami, { oDlgPla:aCols[nI][nPosFami], oDlgPla:aCols[nI][nPosTrec], oDlgPla:aCols[nI][nPosObra] })
		EndIf
	EndIf
Next nI

If Len(aCodFami) > 0
	lTemTab := U_fTabCnt(1, FP0->FP0_FILIAL, FP0->FP0_PROJET )
	If lTemTab
		For nI := 1 To Len(aCodFami)
			lAditivo := U_fTabCnt(5, FP0->FP0_FILIAL, FP0->FP0_PROJET, aCodFami[nI][1] )
			If lAditivo
				aAdd(aAdtFami, { aCodFami[nI][1], aCodFami[nI][2], aCodFami[nI][3] })
			EndIf
		Next nI
	EndIf
Else
	Help(" ",1,"LIB_LISTA_2",,"Não localizada as famílias do contrato.",1,0)
EndIF

//Encontra os trechos referencia
For nI := 1 To Len(oDlgPla:aCols)
	If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	
		cCodObr := oDlgPla:aCols[nI][nPosObra]
		cSeqGru := oDlgPla:aCols[nI][nPosSeq]
		cCodFam := oDlgPla:aCols[nI][nPosFami]
		
		cTipFam := U_fInfoFam(1, cCodFam)
	
		If cTipFam == '2'
			ZD8->(dbSetOrder(1))
			//If ZD8->(dbSeek(xFilial("ZD8") + cCodPrj + cCodObr + cCodFam))
			If ZD8->(dbSeek(xFilial("ZD8") + cCodPrj + cCodFam))
				If ZD8->ZD8_TREREF == "S"
					nPosArr := aScan(aTreRef, { |x| AllTrim(x[1]) + AllTrim(x[2]) == cCodObr + ZD8->ZD8_FAMILI } )	
					If nPosArr == 0
						//aAdd(aTreRef, { ZD8->ZD8_OBRA, ZD8->ZD8_FAMILI, ZD8->ZD8_TRECHO, ZD8->ZD8_LIBLIS, ZD8->(Recno()) })
						aAdd(aTreRef, { cCodObr, ZD8->ZD8_FAMILI, ZD8->ZD8_TRECHO, ZD8->ZD8_LIBLIS, ZD8->(Recno()) })
					EndIf
				EndIf
			EndIf
		Else
			//aAdd(aFamEqu, { cCodObr, cSeqGru, cCodFam })
		EndIf	
	EndIf
Next nI

If Len(aTreRef) > 0
	For nX := 1 To Len(aTreRef)
		nPesoFam := 0
		nIndFam  := 0
		nQtdLis  := 0
		nMedRef  := 0
		nMultFam := 0

		//If aTreRef[nX][4] == "N"
			For nI := 1 To Len(oDlgPla:aCols)
				If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	
					If aTreRef[nX][1] == oDlgPla:aCols[nI][nPosObra] .And.; 
						aTreRef[nX][2] == oDlgPla:aCols[nI][nPosFami] .And.;  
						aTreRef[nX][3] == oDlgPla:aCols[nI][nPosTrec]

						nPesoFam += oDlgPla:aCols[nI][nPosPTot]
						nIndFam  += oDlgPla:aCols[nI][nPosITot]

						cCodFam  := oDlgPla:aCols[nI][nPosFami]
						cCodProd := oDlgPla:aCols[nI][nPosProd]
						nQuant   := oDlgPla:aCols[nI][nPosQtde]
						nPesoPad := oDlgPla:aCols[nI][nPosPPad]
						nIndPad  := oDlgPla:aCols[nI][nPosIPad]

						cTipCalc := U_fInfoSub(1, cCodFam)

						nPosAll  := aScan(aAllProd, {|x| AllTrim(x[2]) == AllTrim(cCodProd)} )	

						If nPosAll == 0
							aAdd(aAllProd, { AllTrim(cCodFam), AllTrim(cCodProd), nQuant, nPesoPad, nIndPad, 0  })
						Else
							If AllTrim(cCodFam) <> AllTrim(aAllProd[nPosAll][1])

								nPosDup := aScan(aDupProd, {|x| AllTrim(x[2]) == AllTrim(cCodProd)} )	

								If nPosDup == 0
									aAdd(aDupProd, { AllTrim(aAllProd[nPosAll][1]), AllTrim(aAllProd[nPosAll][2]), aAllProd[nPosAll][3], aAllProd[nPosAll][4], aAllProd[nPosAll][5], 0 })
								EndIf

								aAdd(aDupProd, { AllTrim(cCodFam), AllTrim(cCodProd), nQuant, nPesoPad, nIndPad, 0 })
							EndIf
						EndIf

						SB1->(dbSetOrder(1))
						If SB1->(dbSeek(xFilial("SB1") + cCodProd))
							If cTipCalc $ "2"
								If cCodFam == AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP)
									nMedRef += SB1->B1_XMEDREF * nQuant //QTD REAL   	 - RODAPÉ
								EndIf

								//Se for multifamilia
								If SB1->B1_XPRECIF == "2"
									nMultFam += SB1->B1_XMEDREF * nQuant //QTD REAL   	 - RODAPÉ
								EndIf	
							ElseIf cTipCalc $ "4"
								If SB1->B1_XPRDREF == "1"
									nQtdLis += nQuant
								EndIf

								//Se for multifamilia
								If SB1->B1_XPRECIF == "2"
									nMultFam += oDlgPla:aCols[nI][nPosITot]
								EndIf
							Else
								//Se for multifamilia
								If SB1->B1_XPRECIF == "2"
									nMultFam += oDlgPla:aCols[nI][nPosPTot]
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nI

			//If Len(aDupProd) > 0
				nMultFam := 0
			//EndIf

			For nI := 1 To Len(oDlgPla:aCols)
				If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	
					If aTreRef[nX][1] == oDlgPla:aCols[nI][nPosObra] .And.; 
						aTreRef[nX][2] == oDlgPla:aCols[nI][nPosFami] .And.;  
						aTreRef[nX][3] == oDlgPla:aCols[nI][nPosTrec]

						lMult 	:= .F.
						cCodFam  := oDlgPla:aCols[nI][nPosFami]
						//nPrcLoc  := U_fVlrFech(cCodPrj, oDlgPla:aCols[nI][nPosObra], cCodFam, "ZD7_PRCORC")
						nPrcLoc  := U_fVlrRed(5, aTreRef[nX], oDlgPla, nI)
						
						If Len(aAdtFami) == 0
							lCont := .T.
						Else
							nPosAdt := aScan( aAdtFami, { | x | AllTrim( x[1] ) == AllTrim(cCodFam) } ) 

							If nPosAdt > 0
								lCont := .T.
							Else
								lCont := .F.
							EndIf
						EndIf

						If lCont
							cCodProd := oDlgPla:aCols[nI][nPosProd]
							SB1->(dbSetOrder(1))
							If SB1->(dbSeek(xFilial("SB1") + cCodProd))
								//Se for multifamilia
								If SB1->B1_XPRECIF == "2"
									lMult := .T.
								Else
									lMult := .F.	
								EndIf
							EndIf

							cTipCalc  := U_fInfoSub(1, cCodFam)
							
							//Calculo formula 1 ou 2 - Qtd Real Peso ou Med Ref
							If cTipCalc $ "1;2"
								If !lMult .Or. Len(aAdtFami) == 0
									//Medida Referencia
									If cTipCalc $ "2"
										nQtdReal := nMedRef
									Else
										nQtdReal := nPesoFam 													
									EndIf										
									nVlrFam  := nQtdReal * nPrcLoc 											

									nPesoPad := oDlgPla:aCols[nI][nPosPPad]
									nQtdePad := oDlgPla:aCols[nI][nPosQtde]
								
									nRet := U_fCalFor2(nPesoPad, nPesoFam - nMultFam, nVlrFam)
									oDlgPla:aCols[nI][nPosUniD] := nRet
									if nRet <= 0
										lHaZerado := .T.
									endif
									//oDlgPla:aCols[nI][nPosVlFa] := nQtdePad * nRet * 30
								Else
									//Se existir tabela de preço do contrato
									If U_fTabCnt(1, FP0->FP0_FILIAL, FP0->FP0_PROJET )
										//Se não existir na tabela, a familia em questão
										If U_fTabCnt(5, FP0->FP0_FILIAL, FP0->FP0_PROJET, cCodFam )
											nRet := U_fTabCnt(6, FP0->FP0_FILIAL, FP0->FP0_PROJET, , cCodProd )
											oDlgPla:aCols[nI][nPosUniD] := nRet
											if nRet <= 0
												lHaZerado := .T.
											endif
										EndIf

									EndIf
								EndIf	

							//Calculo formula 3 - Preço de locação / 30
							ElseIf cTipCalc $ "3"
								If !lMult .Or. Len(aAdtFami) == 0
									nRet 		:= U_fPrcLoc(nPrcLoc)
									nQtdePad := oDlgPla:aCols[nI][nPosQtde]

									oDlgPla:aCols[nI][nPosUniD] := nRet
									if nRet <= 0
										lHaZerado := .T.
									endif
									//oDlgPla:aCols[nI][nPosVlFa] := nQtdePad * nRet * 30
								Else
									//Se existir tabela de preço do contrato
									If U_fTabCnt(1, FP0->FP0_FILIAL, FP0->FP0_PROJET )
										//Se não existir na tabela, a familia em questão
										If U_fTabCnt(5, FP0->FP0_FILIAL, FP0->FP0_PROJET, cCodFam )
											nRet := U_fTabCnt(6, FP0->FP0_FILIAL, FP0->FP0_PROJET, , cCodProd )
											oDlgPla:aCols[nI][nPosUniD] := nRet
											if nRet <= 0
												lHaZerado := .T.
											endif
										EndIf
									EndIf
								EndIf

							//Calculo formula 4 - Vlr Indeniz
							ElseIf cTipCalc $ "4"
								If !lMult .Or. Len(aAdtFami) == 0
									nQtdReal := nQtdLis
									//nQtdReal := U_fVlrFech(cCodPrj, oDlgPla:aCols[nI][nPosObra], cCodFam, "ZD7_QTDORC")	//QTD ORÇADA   - RODAPÉ
									nVlrFam  := nQtdReal * nPrcLoc
									nIndPad  := oDlgPla:aCols[nI][nPosIPad]
									nQtdePad := oDlgPla:aCols[nI][nPosQtde]
						
									nRet 	   := U_fCalFor3(nIndPad, nIndFam - nMultFam, nVlrFam)
									oDlgPla:aCols[nI][nPosUniD] := nRet
									if nRet <= 0
										lHaZerado := .T.
									endif
									//oDlgPla:aCols[nI][nPosVlFa] := nQtdePad * nRet * 30			
								Else
									//Se existir tabela de preço do contrato
									If U_fTabCnt(1, FP0->FP0_FILIAL, FP0->FP0_PROJET )
										//Se não existir na tabela, a familia em questão
										If U_fTabCnt(5, FP0->FP0_FILIAL, FP0->FP0_PROJET, cCodFam )
											nRet := U_fTabCnt(6, FP0->FP0_FILIAL, FP0->FP0_PROJET, , Padr(cCodProd, TamSx3("ZDE_PRODUT")[1]) )
											oDlgPla:aCols[nI][nPosUniD] := nRet
											if nRet <= 0
												lHaZerado := .T.
											endif
										EndIf
									EndIf
								EndIf	
							EndIf	
						EndIf	
					EndIf
				EndIf
			Next nI
		//EndIf
	Next nX

	//Se houver itens comuns em familias diferentes
	If Len(aDupProd) > 0
		//Encontra o menor valor unitario dia, calculado para os itens comuns
		For nI := 1 To Len(aDupProd)
			For nZ := 1 To Len(oDlgPla:aCols)
				If !oDlgPla:aCols[nZ, Len(oDlgPla:aHeader) + 1]	
					If AllTrim(aDupProd[nI][2]) == AllTrim(oDlgPla:aCols[nZ][nPosProd])
						If aDupProd[nI][6] > oDlgPla:aCols[nZ][nPosUniD] .Or. aDupProd[nI][6] == 0
							aDupProd[nI][6] := oDlgPla:aCols[nZ][nPosUniD]
						EndIf
					EndIf 
				EndIf 
			Next nZ
		Next nI

		//Para redistribuir os valores dos itens comuns em familias diferentes
		For nX := 1 To Len(aTreRef)
			//If aTreRef[nX][4] == "N"
				
			For nZ := 1 To Len(oDlgPla:aCols)
				If !oDlgPla:aCols[nZ, Len(oDlgPla:aHeader) + 1]	
					If AllTrim(aTreRef[nX][1]) == AllTrim(oDlgPla:aCols[nZ][nPosObra]) .And.; 
						AllTrim(aTreRef[nX][2]) == AllTrim(oDlgPla:aCols[nZ][nPosFami]) .And.;  
						AllTrim(aTreRef[nX][3]) == AllTrim(oDlgPla:aCols[nZ][nPosTrec]) 

						If Len(aAdtFami) == 0
							lCont := .T.
						Else
							nPosAdt := aScan( aAdtFami, { | x | AllTrim( x[1] ) == AllTrim(oDlgPla:aCols[nZ][nPosFami]) } ) 

							If nPosAdt > 0
								lCont := .T.
							Else
								lCont := .F.
							EndIf
						EndIf

						If lCont
							nPosDup := aScan(aDupProd, {|x| AllTrim(x[1]) + AllTrim(x[2]) == AllTrim(aTreRef[nX][2]) + AllTrim(oDlgPla:aCols[nZ][nPosProd])} )				

							If nPosDup == 0
								cTipCalc  := U_fInfoSub(1, AllTrim(oDlgPla:aCols[nZ][nPosFami]))

								nVarIte  := U_fVlrRed(1, aTreRef[nX], oDlgPla, nZ)
								nVarFam  := U_fVlrRed(2, aTreRef[nX], oDlgPla, nZ)
								nVlrLoc  := U_fVlrRed(3, aTreRef[nX], oDlgPla, nZ)

								nRet 	  := U_fCalFor4(nVarIte, nVarFam, nVlrLoc, aDupProd, cTipCalc, AllTrim(oDlgPla:aCols[nZ][nPosFami]))
								oDlgPla:aCols[nZ][nPosUniD] := nRet
								if nRet <= 0
									lHaZerado := .T.
								endif
							Else
								oDlgPla:aCols[nZ][nPosUniD] := aDupProd[nPosDup][6]
							EndIf	
						EndIf	
					EndIf	
				EndIf	
			Next nZ
				
			//EndIf
			/*
			ZD8->(dbGoTo(aTreRef[nX][5]))
			ZD8->(RecLock("ZD8", .F.))
			ZD8->ZD8_LIBLIS := "S"
			ZD8->(MsUnlock())
			*/
		Next nX
	Else
		//Para marcar que já foi liberada a lista desses trechos
		For nX := 1 To Len(aTreRef)
			If aTreRef[nX][4] == "N"
				/*
				ZD8->(dbGoTo(aTreRef[nX][5]))
				ZD8->(RecLock("ZD8", .F.))
				ZD8->ZD8_LIBLIS := "S"
				ZD8->(MsUnlock())
				*/
			EndIf
		Next nX
	EndIf
EndIf

If Len(aFamEqu) > 0
	For nI := 1 To Len(aFamEqu)
		nPosPla := aScan(oDlgPla:aCols, {|x| AllTrim(x[nPosObra]) + AllTrim(x[nPosSeq]) + AllTrim(x[nPosFami]) == AllTrim(aFamEqu[nI][1]) + AllTrim(aFamEqu[nI][2]) + AllTrim(aFamEqu[nI][3]) } )				
		
		If nPosPla > 0
			nVlrLoc := oDlgPla:aCols[nPosPla][nPosVlFa]
			nRet 	  := nVlrLoc / 30
			oDlgPla:aCols[nPosPla][nPosUniD] := nRet
			if nRet <= 0
				lHaZerado := .T.
			endif
		EndIf
	Next nI
EndIf

// ------------------------------------------------------- //
// actualiza algunos campos que no permiten ser gatilhados //
// ------------------------------------------------------- //
nDias := u_STHORG6A()

ZD5->( DbSetOrder(1) )
if ZD5->( MsSeek(xFilial("ZD5")+cCodPrj, .f.))
	cCondPag := ZD5->ZD5_CONPAG
endif

for nI := 1 to len(oDlgPla:aCols)

	If !oDlgPla:aCols[nI, Len(oDlgPla:aHeader) + 1]	

		if oDlgPla:aCols[nI][nPosUniD] > 0
			oDlgPla:aCols[nI][nPosPUni] := ( oDlgPla:aCols[nI][nPosUniD] * nDias )
			oDlgPla:aCols[nI][nPosVlFa] := (oDlgPla:aCols[nI][nPosPUni] * oDlgPla:aCols[nI][nPosQtde])
			oDlgPla:aCols[nI][nPosVlBs] := (oDlgPla:aCols[nI][nPosPUni] * oDlgPla:aCols[nI][nPosQtde])

			// M->FPA_QUANT := oDlgPla:aCols[nI][nPosQtde]
			// M->FPA_PRCUNI := oDlgPla:aCols[nI][nPosPUni]

			// RunTrigger(2,nI,,,"FPA_PRCUNI")
		endif

		oDlgPla:aCols[nI][nPosCond] := cCondPag
		if empty(oDlgPla:aCols[nI][nPosFilR])
			oDlgPla:aCols[nI][nPosFilR] := xFilial("FPA")
		endif

	endif

next nI

//FP0->(RecLock("FP0",.F.))
//FP0->FP0_XSTAT2 := '4' //Fixar tabela de preço do contrato
//FP0->(MsUnlock())

if lHaZerado // Ha item com preço unitario Zerado 
	msgAlert("Há itens com valor unitário zerado, analise os dados dos itens para verficar a Origem. ")
else
	MsgInfo("Liberação das listas dos trechos referência liberada com sucesso.")
endif

Return lRet 


/*
+------------+-----------+--------+--------------------+-------+----------------+
| Programa:  | fVlrRed   | Autor: | Guilherme Coronado | Data: | Fevereiro/21   |
+------------+-----------+--------+--------------------+-------+----------------+
| Descrição: | Função para buscar valores para redistribuição			           |
+------------+------------------------------------------------------------------+
| Uso:       | Orguel                                            			        |
+------------+------------------------------------------------------------------+
*/ 
User Function fVlrRed(nTipo, aTreAux, aArrAux, nAtual, lTab)
Local nAux 		 := 0
Local nI			 := 0
Local nMedRef	 := 0
Local nPesoFam	 := 0
Local nIndFam 	 := 0
Local cCodPrj 	 := ""
Local cCodFam 	 := ""
Local cCodProd	 := ""
Local nQuant  	 := 0
Local nQtdReal  := 0
Local nQtdLis   := 0

Default nTipo   := 0
Default aTreAux := {}
Default aArrAux := {}
Default nAtual  := 0
Default lTab    := .F.

//Retorna o peso ou valor de indenização padrão do item posicionado
If nTipo == 1
	If !lTab
		cTipCalc  := U_fInfoSub(1, AllTrim(aArrAux:aCols[nAtual][nPosFami]) )
		If cTipCalc $ "4"
			nAux := aArrAux:aCols[nAtual][nPosIPad] // Indenização
		Else
			nAux := aArrAux:aCols[nAtual][nPosPPad] // Peso
		EndIf
	Else
		cTipCalc  := U_fInfoSub(1, AllTrim(FPA->FPA_FAMILI) )
		If cTipCalc $ "4"
			nAux := FPA->FPA_VLINPA
		Else
			nAux := FPA->FPA_PESPAD
		EndIf
	EndIf	

//Retorna o peso total da familia ou valor total de indenização
ElseIf nTipo == 2
	If !lTab
		For nI := 1 To Len(aArrAux:aCols)
			If !aArrAux:aCols[nI, Len(aArrAux:aHeader) + 1]	
				If aTreAux[1] == aArrAux:aCols[nI][nPosObra] .And.; 
					aTreAux[2] == aArrAux:aCols[nI][nPosFami] .And.;  
					aTreAux[3] == aArrAux:aCols[nI][nPosTrec]

					cTipCalc  := U_fInfoSub(1, AllTrim(aArrAux:aCols[nI][nPosFami]) )

					If cTipCalc $ "4"
						nAux  += aArrAux:aCols[nI][nPosITot] // Indenização Total
					Else
						nAux += aArrAux:aCols[nI][nPosPTot] // Peso Total
					EndIf
				EndIf
			EndIf
		Next nI
	Else
		aAreaFPA := FPA->(GetArea())
		FPA->(dbSetOrder(1))
		If FPA->(dbSeek(FP0->FP0_FILIAL + FP0->FP0_PROJET))
			While FPA->(!Eof()) .And. FPA->(FPA_FILIAL + FPA_PROJET) == FP0->(FP0_FILIAL+FP0_PROJET)
				If AllTrim(aTreAux[1]) == AllTrim(FPA->FPA_OBRA)	.And.; 
					AllTrim(aTreAux[2]) == AllTrim(FPA->FPA_FAMILI) .And.;  
					AllTrim(aTreAux[3]) == AllTrim(FPA->FPA_TRECHO)

					cTipCalc  := U_fInfoSub(1, AllTrim(FPA->FPA_FAMILI) )
					If cTipCalc $ "4"
						nAux += FPA->FPA_INDTOT
					Else
						nAux += FPA->FPA_PESTOT
					EndIf
				EndIf

				FPA->(dbSkip())
			EndDo
		EndIf
		RestArea(aAreaFPA)
	EndIf

//Retorna o valor de locação da familia 
ElseIf nTipo == 3
	If !lTab
		For nI := 1 To Len(aArrAux:aCols)
			If !aArrAux:aCols[nI, Len(aArrAux:aHeader) + 1]	
				If aTreAux[1] == aArrAux:aCols[nI][nPosObra] .And.; 
					aTreAux[2] == aArrAux:aCols[nI][nPosFami] .And.;  
					aTreAux[3] == aArrAux:aCols[nI][nPosTrec]

					nPesoFam += aArrAux:aCols[nI][nPosPTot]
					nIndFam  += aArrAux:aCols[nI][nPosITot]

					cCodFam  := aArrAux:aCols[nI][nPosFami]
					cCodProd := aArrAux:aCols[nI][nPosProd]
					nQuant   := aArrAux:aCols[nI][nPosQtde]

					cTipCalc  := U_fInfoSub(1, cCodFam)

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1") + cCodProd))
						If cTipCalc $ "2"
							If cCodFam == AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP)
								nMedRef += SB1->B1_XMEDREF * nQuant //QTD REAL   	 - RODAPÉ
							EndIf	
						ElseIf cTipCalc $ "4"
							If SB1->B1_XPRDREF == "1"
								nQtdLis += nQuant
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI

		For nI := 1 To Len(aArrAux:aCols)
			If !aArrAux:aCols[nI, Len(aArrAux:aHeader) + 1]	
				If aTreAux[1] == aArrAux:aCols[nI][nPosObra] .And.; 
					aTreAux[2] == aArrAux:aCols[nI][nPosFami] .And.;  
					aTreAux[3] == aArrAux:aCols[nI][nPosTrec]

					cCodPrj  := FP0->FP0_PROJET
					cCodFam  := aArrAux:aCols[nI][nPosFami]
					nQtdOrc  := U_fVlrFech(cCodPrj, aArrAux:aCols[nI][nPosObra], cCodFam, "ZD7_QTDORC")
					nPrcOrc  := U_fVlrFech(cCodPrj, aArrAux:aCols[nI][nPosObra], cCodFam, "ZD7_PRCORC")
					nVlrOrc  := U_fVlrFech(cCodPrj, aArrAux:aCols[nI][nPosObra], cCodFam, "ZD7_VLRORC")

					cTipCalc  := U_fInfoSub(1, cCodFam)

					//Calculo formula 1 ou 2 - Qtd Real Peso ou Med Ref
					If cTipCalc $ "1;2"
						//Medida Referencia
						If cTipCalc $ "2"
							nQtdReal := nMedRef
						Else
							nQtdReal := nPesoFam 													
						EndIf										

						If nQtdReal > 0
							If (Left(cCodFam,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtdOrc <= nQtdReal)
								nAux := nQtdReal * nPrcOrc									//VLR REAL   	 - RODAPÉ
							Else
								//Se a quantidade orçada, for maior que a real
								//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
								If nQtdOrc > nQtdReal
									nAux := nVlrOrc
								EndIf
							EndIf
						EndIf

					//Calculo formula 3 - Preço de locação / 30
					ElseIf cTipCalc $ "3"
						nAux 		:= nVlrOrc	//VLR ORÇADO   - RODAPÉ

					//Calculo formula 4 - Vlr Indeniz
					ElseIf cTipCalc $ "4"
						nQtdReal := nQtdLis

						If nQtdReal > 0
							If (Left(cCodFam,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtdOrc <= nQtdReal)
								nAux := nQtdReal * nPrcOrc									//VLR REAL   	 - RODAPÉ
							Else
								//Se a quantidade orçada, for maior que a real
								//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
								If nQtdOrc > nQtdReal
									nAux := nVlrOrc
								EndIf
							EndIf
						EndIf
					EndIf	
				EndIf
			EndIf
		Next nI
	Else
		aAreaFPA := FPA->(GetArea())
		FPA->(dbSetOrder(1))
		If FPA->(dbSeek(FP0->FP0_FILIAL + FP0->FP0_PROJET))
			While FPA->(!Eof()) .And. FPA->(FPA_FILIAL + FPA_PROJET) == FP0->(FP0_FILIAL+FP0_PROJET)
				If AllTrim(aTreAux[1]) == AllTrim(FPA->FPA_OBRA)	.And.; 
					AllTrim(aTreAux[2]) == AllTrim(FPA->FPA_FAMILI) .And.;  
					AllTrim(aTreAux[3]) == AllTrim(FPA->FPA_TRECHO)

					nPesoFam += FPA->FPA_PESTOT
					nIndFam  += FPA->FPA_INDTOT

					cCodFam  := FPA->FPA_FAMILI
					cCodProd := FPA->FPA_PRODUT
					nQuant   := FPA->FPA_QUANT

					cTipCalc  := U_fInfoSub(1, cCodFam)

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1") + cCodProd))
						If cTipCalc $ "2"
							If cCodFam == AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP)
								nMedRef += SB1->B1_XMEDREF * nQuant //QTD REAL   	 - RODAPÉ
							EndIf
						ElseIf cTipCalc $ "4"
							If SB1->B1_XPRDREF == "1"
								nQtdLis += nQuant
							EndIf
						EndIf
					EndIf
				EndIf

				FPA->(dbSkip())
			EndDo
		EndIf

		FPA->(dbSetOrder(1))
		If FPA->(dbSeek(FP0->FP0_FILIAL + FP0->FP0_PROJET))
			While FPA->(!Eof()) .And. FPA->(FPA_FILIAL + FPA_PROJET) == FP0->(FP0_FILIAL+FP0_PROJET)
				If AllTrim(aTreAux[1]) == AllTrim(FPA->FPA_OBRA)	.And.; 
					AllTrim(aTreAux[2]) == AllTrim(FPA->FPA_FAMILI) .And.;  
					AllTrim(aTreAux[3]) == AllTrim(FPA->FPA_TRECHO)

					cCodPrj  := FP0->FP0_PROJET
					cCodFam  := FPA->FPA_FAMILI
					nQtdOrc  := U_fVlrFech(cCodPrj, FPA->FPA_OBRA, cCodFam, "ZD7_QTDORC")
					nPrcOrc  := U_fVlrFech(cCodPrj, FPA->FPA_OBRA, cCodFam, "ZD7_PRCORC")
					nVlrOrc  := U_fVlrFech(cCodPrj, FPA->FPA_OBRA, cCodFam, "ZD7_VLRORC")
					cTipCalc := U_fInfoSub(1, cCodFam)

					//Calculo formula 1 ou 2 - Qtd Real Peso ou Med Ref
					If cTipCalc $ "1;2"
						//Medida Referencia
						If cTipCalc $ "2"
							nQtdReal := nMedRef
						Else
							nQtdReal := nPesoFam 													
						EndIf										

						If nQtdReal > 0
							If (Left(cCodFam,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtdOrc <= nQtdReal)
								nAux := nQtdReal * nPrcOrc									//VLR REAL   	 - RODAPÉ
							Else
								//Se a quantidade orçada, for maior que a real
								//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
								If nQtdOrc > nQtdReal
									nAux := nVlrOrc
								EndIf
							EndIf
						EndIf

					//Calculo formula 3 - Preço de locação / 30
					ElseIf cTipCalc $ "3"
						nAux 		:= nVlrOrc	//VLR ORÇADO   - RODAPÉ

					//Calculo formula 4 - Vlr Indeniz
					ElseIf cTipCalc $ "4"
						nQtdReal := nQtdLis

						If nQtdReal > 0
							If (Left(cCodFam,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtdOrc <= nQtdReal)
								nAux := nQtdReal * nPrcOrc									//VLR REAL   	 - RODAPÉ
							Else
								//Se a quantidade orçada, for maior que a real
								//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
								If nQtdOrc > nQtdReal
									nAux := nVlrOrc
								EndIf
							EndIf
						EndIf
					EndIf	
				EndIf
				FPA->(dbSkip())
			EndDo
		EndIf

		RestArea(aAreaFPA)
	EndIf

//Retorna o preço de locação da familia
ElseIf nTipo == 5
	If !lTab
		For nI := 1 To Len(aArrAux:aCols)
			If !aArrAux:aCols[nI, Len(aArrAux:aHeader) + 1]	
				If aTreAux[1] == aArrAux:aCols[nI][nPosObra] .And.; 
					aTreAux[2] == aArrAux:aCols[nI][nPosFami] .And.;  
					aTreAux[3] == aArrAux:aCols[nI][nPosTrec]

					nPesoFam += aArrAux:aCols[nI][nPosPTot]
					nIndFam  += aArrAux:aCols[nI][nPosITot]
					cCodPrj  := FP0->FP0_PROJET
					cCodObra := aArrAux:aCols[nI][nPosObra]
					cCodFami := aArrAux:aCols[nI][nPosFami]
					cCodProd := aArrAux:aCols[nI][nPosProd]
					nQuant   := aArrAux:aCols[nI][nPosQtde]
					cTipCalc := U_fInfoSub(1, cCodFami)

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1") + cCodProd))
						If cTipCalc $ "2"
							If cCodFami == AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP)
								nMedRef += SB1->B1_XMEDREF * nQuant 					//QTD REAL   	 - RODAPÉ
							EndIf

						ElseIf cTipCalc $ "4"
							If SB1->B1_XPRDREF == "1"
								nQtdLis  += nQuant
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Next nI

		nQtd1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_QTDORC")	//QTD ORÇADA   - RODAPÉ
		nPrc1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_PRCORC")	//PREÇO ORÇADO - RODAPÉ
		nVlr1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_VLRORC")	//VLR ORÇADO   - RODAPÉ
		nQtd2  	 := 0
		nPrc2  	 := 0
		nVlr2  	 := 0
		cTipCalc  := U_fInfoSub(1, cCodFami)

		//Calculo formula 1 ou 2 - Qtd Real Peso ou Med Ref
		If cTipCalc $ "1;2"
			//Medida Referencia
			If cTipCalc $ "2"
				nQtd2 := nMedRef
			Else
				nQtd2 := nPesoFam 
			EndIf	

			If nQtd2 > 0
				If (Left(cCodFami,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtd1 <= nQtd2)
					nPrc2 := nPrc1
				Else
					//Se a quantidade orçada, for maior que a real
					//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
					If nQtd1 > nQtd2
						nVlr2 := nVlr1
						nPrc2 := nVlr2 / nQtd2
					EndIf
				EndIf
			EndIf
			
		//Calculo formula 3 - Preço de locação / 30
		ElseIf cTipCalc $ "3"
			nQtd2 := nQuant
			If nQtd2 > 0
				nPrc2 := nPrc1
			EndIf

		//Calculo formula 4 - Vlr Indeniz
		ElseIf cTipCalc $ "4"
			nQtd2 := nQtdLis
			If nQtd2 > 0
				If (Left(cCodFami,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtd1 <= nQtd2)
					nPrc2 := nPrc1
				Else
					//Se a quantidade orçada, for maior que a real
					//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
					If nQtd1 > nQtd2
						nVlr2 := nVlr1
						nPrc2 := nVlr2 / nQtd2
					EndIf
				EndIf
			EndIf
		EndIf

		nAux := nPrc2
	Else
		aAreaFPA := FPA->(GetArea())
		FPA->(dbSetOrder(1))
		If FPA->(dbSeek(FP0->FP0_FILIAL + FP0->FP0_PROJET))
			While FPA->(!Eof()) .And. FPA->(FPA_FILIAL + FPA_PROJET) == FP0->(FP0_FILIAL+FP0_PROJET)
				If AllTrim(aTreAux[1]) == AllTrim(FPA->FPA_OBRA)	.And.; 
					AllTrim(aTreAux[2]) == AllTrim(FPA->FPA_FAMILI) .And.;  
					AllTrim(aTreAux[3]) == AllTrim(FPA->FPA_TRECHO)

					nPesoFam += FPA->FPA_PESTOT
					nIndFam  += FPA->FPA_INDTOT
					cCodPrj  := FP0->FP0_PROJET
					cCodObra := FPA->FPA_OBRA
					cCodFami := FPA->FPA_FAMILI
					cCodProd := FPA->FPA_PRODUT
					nQuant   := FPA->FPA_QUANT
					cTipCalc := U_fInfoSub(1, cCodFami)

					SB1->(dbSetOrder(1))
					If SB1->(dbSeek(xFilial("SB1") + cCodProd))
						If cTipCalc $ "2"
							If cCodFami == AllTrim(SB1->B1_XGRPORG) + AllTrim(SB1->B1_XSUBGRP)
								nMedRef += SB1->B1_XMEDREF * nQuant 					//QTD REAL   	 - RODAPÉ
							EndIf
						ElseIf cTipCalc $ "4"
							If SB1->B1_XPRDREF == "1"
								nQtdLis  += nQuant
							EndIf

						EndIf
					EndIf					
				EndIf

				FPA->(dbSkip())
			EndDo
		EndIf

		nQtd1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_QTDORC")	//QTD ORÇADA   - RODAPÉ
		nPrc1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_PRCORC")	//PREÇO ORÇADO - RODAPÉ
		nVlr1  	 := U_fVlrFech(cCodPrj, cCodObra, cCodFami, "ZD7_VLRORC")	//VLR ORÇADO   - RODAPÉ
		nQtd2  	 := 0
		nPrc2  	 := 0
		nVlr2  	 := 0
		cTipCalc  := U_fInfoSub(1, cCodFami)

		//Calculo formula 1 ou 2 - Qtd Real Peso ou Med Ref
		If cTipCalc $ "1;2"
			//Medida Referencia
			If cTipCalc $ "2"
				nQtd2 := nMedRef
			Else
				nQtd2 := nPesoFam 
			EndIf	

			If nQtd2 > 0
				If (Left(cCodFami,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtd1 <= nQtd2)
					nPrc2 := nPrc1
				Else
					//Se a quantidade orçada, for maior que a real
					//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
					If nQtd1 > nQtd2
						nVlr2 := nVlr1
						nPrc2 := nVlr2 / nQtd2
					EndIf
				EndIf
			EndIf
			
		//Calculo formula 3 - Preço de locação / 30
		ElseIf cTipCalc $ "3"
			nQtd2 := nQuant
			If nQtd2 > 0
				nPrc2 := nPrc1
			EndIf

		//Calculo formula 4 - Vlr Indeniz
		ElseIf cTipCalc $ "4"
			nQtd2 := nQtdLis
			If nQtd2 > 0
				If (Left(cCodFami,TamSx3("ZD2_CODGRP")[1]) $ cPrcMen) .Or. (nQtd1 <= nQtd2)
					nPrc2 := nPrc1
				Else
					//Se a quantidade orçada, for maior que a real
					//O valor total da locação fica igual ao valor orçado e o preço orçado aumenta
					If nQtd1 > nQtd2
						nVlr2 := nVlr1
						nPrc2 := nVlr2 / nQtd2
					EndIf
				EndIf
			EndIf
		EndIf

		nAux := nPrc2

		RestArea(aAreaFPA)
	EndIf
EndIf

Return nAux
