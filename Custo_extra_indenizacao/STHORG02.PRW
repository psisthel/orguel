#include "PROTHEUS.CH"

/*
Programa    : STHORG02
Descricao   : Tela de registro dos custos de indenizacao cuando seleccionada a opcao de 
                Produtos Faltantes, gera nova tabela ZE1 para ter o controle do que foi 
                registrado separado da tabela FPA.
Cliente     : ORGUEL
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG02

	Local _aArea	:= getArea()
    Local oDlg
    Local oGetDB
	Local cProjeto  := FP0->FP0_PROJET
	Local olFont    := TFont():New('Courier new',,-12,.T.)
	Local olFont2   := TFont():New('Courier new',,-14,.T.)
    Local nOpc		:= 4
	Local bWhile   	:= {|| }
	Local aTravas	:= {}			// Campos que foram travados
	Local lTravas	:= .T.			// Se todos os campos foram travados com sucesso

    if M->FPG_XTEMPF=='N'
        Return
    endif
    
    private aHeader := {}
    private aCols   := {}

	private ntot_indenizacao := 0
	private ntot_desconto := 0
    private ntot_acrescimo := 0
	private ntot_geral := 0

    private oSay1
    private oSay2
    private oSay3

    _preencheZE1(cProjeto)

	cQuery := "SELECT *"
	cQuery += "  FROM " + RetSQLName("ZE1")
	cQuery += " WHERE ZE1_FILIAL ='" + xFilial("ZE1") + "'" 
	cQuery += "   AND D_E_L_E_T_= ' '"
	cQuery += "   AND ZE1_PROJET='" + cProjeto + "'"

	aHeader	:= {}
	aCols	:= {}

	cSeek		:= xFilial("ZE1")+cProjeto
	bWhile		:= {|| ZE1->ZE1_FILIAL+ZE1->ZE1_PROJET}

    aNoFields := {"ZE1_DESCRI"} 

	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		
        If !FillGetDados(	nOpc			,"ZE1"			,4				,cSeek  		,;
						bWhile      	,{|| .T. }		,aNoFields		,/*aYesFields*/	,; 
						/*lOnlyYes*/	,cQuery 		,/*bMontCols*/	,/*lEmpty*/ 	,;
						/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,{|| AtTravaReg("ZE1", aTravas) } )

            lTravas := .f.
        endif

	Endif


    DEFINE MSDIALOG oDlg TITLE "Custo Extra - Peças Faltantes" FROM 00,00 TO 500,1300 PIXEL

	TSay():New( 05,05,{|| "Projeto: "+cProjeto },oDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)

    // oGetDB := MsGetDB():New(15, 05, 220, 650, 4, "U_LINHAOK1(cCriaTrab)", "U_TUDOOK1", "+ZE1_SEQ", .T., {"ZE1_QTDRET","ZE1_ACRESC","ZE1_DESCON"}, 1, .F., , cCriaTrab, "U_FIELDOK1(cCriaTrab)", , .F., oDlg, .T., ,"U_DELOK1", "U_SUPERDEL1")

    oGetDB := MsGetDados():New(15,05,220,650,4,"u_VALINEA","U_VALTODO","+ZE1_SEQ",.F.,{"ZE1_QTDRET","ZE1_ACRESC","ZE1_DESCON"},,,,"U_VALCAMPO")

    oSplitter := tSplitter():New( 230,05,oDlg,450,015 )

    oPanel1:= tPanel():New(230,05,"",oSplitter,,,,,CLR_HGRAY,60,60)
    oPanel2:= tPanel():New(230,05,"",oSplitter,,,,,CLR_HGRAY,60,60)
    oPanel3:= tPanel():New(230,05,"",oSplitter,,,,,CLR_HGRAY,60,60)
    oPanel4:= tPanel():New(230,05,"",oSplitter,,,,,CLR_HGRAY,60,60)

	oSay1 := TSay():New( 002,002,{|| "Tot.Indenização: " + alltrim(Transform(ntot_indenizacao,"@E 999,999,999.99")) },oPanel1,,olFont2,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	oSay2 := TSay():New( 002,002,{|| "Tot.Acrescimo: " + alltrim(Transform(ntot_acrescimo,"@E 999,999,999.99")) },oPanel2,,olFont2,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	oSay3 := TSay():New( 002,002,{|| "Tot.Desconto: " + alltrim(Transform(ntot_desconto,"@E 999,999,999.99")) },oPanel3,,olFont2,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	oSay4 := TSay():New( 002,002,{|| "Tot.Inden+Acre-Desc: " + alltrim(Transform(ntot_geral,"@E 999,999,999.99")) },oPanel4,,olFont2,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,400,020)


	olPanel := TPanel():New(230,500,'',oDlg,,.T.,.T.,,,150,015,.F.,.F. )
			
	olBtn1		 := TButton():New( 002, 002, "Confirmar", olPanel,{|| u_stExec02(cProjeto),oDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	olBtn1:Align := CONTROL_ALIGN_RIGHT
				
	olSplitter1 := TSplitter():New( 01,01,olPanel,005,01 )
	olSplitter1:Align := CONTROL_ALIGN_RIGHT

	olBtn2		 := TButton():New( 002, 002, "Fechar", olPanel,{|| oDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	olBtn2:Align := CONTROL_ALIGN_RIGHT

	olSplitter2	:= TSplitter():New( 01,01,olPanel,005,01 )
    olSplitter2:Align := CONTROL_ALIGN_RIGHT


    ACTIVATE MSDIALOG oDlg CENTERED
    
	RestArea( _aArea )

Return


User Function stExec02(cNroProjeto)

	local aParamBox := {}
	local _aRet     := {}
    local lRet      := .f.
    local nX        := 1
    local aVends    := {}

    aAdd(aParamBox,{1,"Vendedor 1",space(TamSX3("A3_COD")[1]),"@!","NaoVazio()","SA3","",0,.F.}) 
    aAdd(aParamBox,{1,"Vendedor 2",space(TamSX3("A3_COD")[1]),"@!","NaoVazio()","SA3","",0,.F.}) 
    aAdd(aParamBox,{1,"Vendedor 3",space(TamSX3("A3_COD")[1]),"@!","","SA3","",0,.F.}) 
    aAdd(aParamBox,{1,"Vendedor 4",space(TamSX3("A3_COD")[1]),"@!","","SA3","",0,.F.}) 
    aAdd(aParamBox,{1,"Vendedor 5",space(TamSX3("A3_COD")[1]),"@!","","SA3","",0,.F.}) 

    If ParamBox( aParamBox,"Parametros",_aRet)

        for nX := 1 to len(aParamBox)
            Aadd(aVends,_aRet[nX])
        next nX

    endif

    MsgRun( "Aguarde, salvando informações de retorno..." ,, {|| lRet := stAtuFPA( cNroProjeto,aVends ) } )

Return

Static Function stAtuFPA(cNroProjeto,aVends)

    local nX := 1
    Local nPosQtRet := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_QTDRET"})
    Local nPosVlDes := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_DESCON"})
    Local nPosAcres  := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_ACRESC"})
    Local nPosProd  := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_PRODUT"})
    Local nPosSequ  := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_SEQ"})

    ZE1->( DbSetOrder(2))

    for nX := 1 to len(aCols)

    	If ZE1->(MsSeek(xFilial("ZE1")+cNroProjeto+aCols[nX][nPosProd]+aCols[nX][nPosSequ]))

            ZE1->(RecLock("ZE1",.f.))
            ZE1->ZE1_QTDRET := aCols[nX][nPosQtRet]
            ZE1->ZE1_DESCON := aCols[nX][nPosVlDes]
            ZE1->ZE1_ACRESC := aCols[nX][nPosAcres]
            if len(aVends) > 0
                ZE1->ZE1_VEND1  := aVends[1]
                ZE1->ZE1_VEND2  := aVends[2]
                ZE1->ZE1_VEND3  := aVends[3]
                ZE1->ZE1_VEND4  := aVends[4]
                ZE1->ZE1_VEND5  := aVends[5]
            endif
            ZE1->(MsUnlock())

        endif

    next nX

    M->FPG_XPFIND := ntot_geral
    M->FPG_VLUNIT := ntot_geral
    M->FPG_PRODUT := GETNEWPAR("MV_ITPRPEC","0612000037")
    M->FPG_DESCRI := POSICIONE("SB1",1,XFILIAL("SB1")+M->FPG_PRODUT,"SB1->B1_DESC")
    M->FPG_VALOR  := M->FPG_VLUNIT * M->FPG_QUANT

Return


User Function VALINEA()

    local nX := 0
    local lret := .t.
    Local nPosQtRet := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_QTDRET"}) 
    Local nPosVlInd := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_VLINDE"}) 
    Local nPosQtEnv := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_SALDO"}) 
    Local nPosVlDes := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_DESCON"}) 
    Local nPosVlUni := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_VALPRD"}) 
    Local nPosVlAcr := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_ACRESC"}) 
    
    if aCols[n][nPosQtRet] > aCols[n][nPosQtEnv]
        lret := .f.
        MsgAlert('Quantidade retornada nao pode ser maior que o saldo!', 'ORGUEL')
    endif

    if lret

        ntot_indenizacao := 0
        ntot_desconto := 0
        ntot_acrescimo := 0
        ntot_geral := 0

        for nX := 1 to len(aCols)
            if aCols[nX][nPosQtRet] > 0
                if aCols[nX][nPosVlInd]>0
                    // ntot_indenizacao += ( (aCols[nX][nPosQtEnv]-aCols[nX][nPosQtRet]) * aCols[nX][nPosVlInd] )
                    ntot_indenizacao += ( aCols[nX][nPosQtRet] * aCols[nX][nPosVlInd] )
                else
                    // ntot_indenizacao += ( (aCols[nX][nPosQtEnv]-aCols[nX][nPosQtRet]) * aCols[nX][nPosVlUni] )
                    ntot_indenizacao += ( aCols[nX][nPosQtRet] * aCols[nX][nPosVlUni] )
                endif
            endif
            ntot_desconto += aCols[nX][nPosVlDes]
            ntot_acrescimo += aCols[nX][nPosVlAcr]
        next nX

        // if ntot_indenizacao > 0
            ntot_geral := ( ( ntot_indenizacao + ntot_acrescimo) - ntot_desconto )
        // endif

        oSay1:Refresh()
        oSay2:Refresh()
        oSay3:Refresh()
        oSay4:Refresh()

    endif

Return(lret)

User Function VALTODO()

    local nX := 0
    local lret := .t.
    Local nPosQtRet := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_QTDRET"}) 
    Local nPosVlInd := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_VLINDE"}) 
    Local nPosQtEnv := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_SALDO"}) 
    Local nPosVlDes := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_DESCON"}) 
    Local nPosVlUni := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_VALPRD"}) 
    Local nPosVlAcr := aScan(aHeader,{|x| AllTrim(x[2])=="ZE1_ACRESC"}) 
    
    ntot_indenizacao := 0
    ntot_desconto := 0
    ntot_acrescimo := 0
    ntot_geral := 0

    for nX := 1 to len(aCols)
        if aCols[nX][nPosQtRet] > 0
            if aCols[nX][nPosVlInd]>0
                ntot_indenizacao += ( (aCols[nX][nPosQtEnv]-aCols[nX][nPosQtRet]) * aCols[nX][nPosVlInd] )
            else
                ntot_indenizacao += ( (aCols[nX][nPosQtEnv]-aCols[nX][nPosQtRet]) * aCols[nX][nPosVlUni] )
            endif
        endif
        ntot_desconto += aCols[nX][nPosVlDes]
        ntot_acrescimo += aCols[nX][nPosVlAcr]
    next nX

    // if ntot_indenizacao > 0
        ntot_geral := ( ( ntot_indenizacao + ntot_acrescimo) - ntot_desconto )
    // endif

    oSay1:Refresh()
    oSay2:Refresh()
    oSay3:Refresh()
    oSay4:Refresh()

Return(lRet)

User Function VALCAMPO()
Return(.t.)


Static Function _preencheZE1(pProject)

    local _aArea    := getArea()
	local _cAlias01	:= getNextAlias()
	local _cAlias02	:= getNextAlias()
	local cQuery	:= ""
	local cQry	    := ""
	local lret		:= .t.

	SB1->( DbSetOrder(1) )
    ZE1->( DbSetOrder(2) )

	cQuery := "SELECT *"
	cQuery += "  FROM " + RetSQLName("FPA")
	cQuery += " WHERE FPA_FILIAL ='" + xFilial("FPA") + "'" 
	cQuery += "   AND D_E_L_E_T_= ' '"
	cQuery += "   AND FPA_PROJET='" + pProject + "'"

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), _cAlias01, .F., .T.)
				
	If (_cAlias01)->( !Eof() )

		While (_cAlias01)->( !Eof() )

			SB1->( MsSeek(xFilial("SB1")+(_cAlias01)->FPA_PRODUT) )

            cQry := "SELECT FQ3_PROJET,FQ3_PROD,SUM(FQ3_QTD) AS FQ3_QTD"
            cQry += "  FROM " + RetSQLName("FQ3")
            cQry += " WHERE FQ3_FILIAL ='" + xFilial("FQ3") + "'" 
            cQry += "   AND D_E_L_E_T_= ' '"
            cQry += "   AND FQ3_PROJET='" + pProject + "'"
            cQry += "   AND FQ3_PROD='" + (_cAlias01)->FPA_PRODUT + "'"
            cQry += "   AND FQ3_NFREM<>''"
            cQry += "   AND FQ3_NFRET=''"
            cQry += " GROUP BY FQ3_PROJET,FQ3_PROD"

            dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), _cAlias02, .F., .T.)
                        
            nQtdEnviada := (_cAlias02)->FQ3_QTD

            (_cAlias02)->( DBCloseArea() )

            cQry := "SELECT FQ3_PROJET,FQ3_PROD,SUM(FQ3_QTD) AS FQ3_QTD"
            cQry += "  FROM " + RetSQLName("FQ3")
            cQry += " WHERE FQ3_FILIAL ='" + xFilial("FQ3") + "'" 
            cQry += "   AND D_E_L_E_T_= ' '"
            cQry += "   AND FQ3_PROJET='" + pProject + "'"
            cQry += "   AND FQ3_PROD='" + (_cAlias01)->FPA_PRODUT + "'"
            cQry += "   AND FQ3_NFREM=''"
            cQry += "   AND FQ3_NFRET<>''"
            cQry += " GROUP BY FQ3_PROJET,FQ3_PROD"

            dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), _cAlias02, .F., .T.)
                        
            nQtdRetornada := (_cAlias02)->FQ3_QTD

            (_cAlias02)->( DBCloseArea() )

            if ZE1->( dbSeek( xFilial("ZE1")+pProject+(_cAlias01)->FPA_PRODUT+(_cAlias01)->FPA_SEQGRU ))
                ZE1->(RecLock("ZE1",.f.))
            else
                ZE1->(RecLock("ZE1",.t.))
            endif

            ZE1->ZE1_FILIAL	:= XFILIAL("ZE1")
            ZE1->ZE1_PROJET	:= pProject
            ZE1->ZE1_SEQ	:= (_cAlias01)->FPA_SEQGRU
            ZE1->ZE1_PRODUT	:= (_cAlias01)->FPA_PRODUT
            ZE1->ZE1_VALPRD	:= SB1->B1_PRV1
            ZE1->ZE1_VLINDE	:= SB1->B1_PRV1
            ZE1->ZE1_QTDENV	:= nQtdEnviada
            ZE1->ZE1_SALDO	:= (nQtdEnviada-nQtdRetornada)
            ZE1->ZE1_QTDDEV := nQtdRetornada
            // ZE1->ZE1_ACRESC	:= 0
            // ZE1->ZE1_DESCON := 0
            // ZE1->ZE1_QTDRET := 0

            ZE1->(MsUnlock())
            
			(_cAlias01)->(dbSkip())
		End

	endif

	(_cAlias01)->(DBCloseArea())

    RestArea(_aArea)
	
Return lret

