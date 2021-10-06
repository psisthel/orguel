#include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function STHORG03

	local clTitulo	:= "Gerar Indenizações - Serviços / Peças Faltantes"
	local olChkLst
	local olPanel
	local olSplitter1
	local olDlg
	local olFont	:= TFont():New('Arial',,-16,.T.)
	local llRet		:= .F.
	local olSplitter2
	local nLsHeader := 0
	local nLsCols   := 0
    local cProjeto  := FP0->FP0_PROJET
    local cPerg     := PADR("STHORG03",Len(SX1->X1_GRUPO))
	
	private aSize    	:= MsAdvSize()
	private aObjects 	:= {}
	private aInfo    	:= {aSize[1],aSize[2],aSize[3],aSize[4],3,2}
	private aPosObj  	:= {}
	private apDatos		:= {}
	private apItens		:= {}
	private nTotPedido	:= 0

    if !Pergunte(cPerg)
        Return
    endif
	
	AADD( aObjects, { 100, 0, .T., .F. } )
	AADD( aObjects, { 100, 100, .T., .T. } )
	AADD( aObjects, { 100, 10, .T., .F. } )
	
	aPosObj := MsObjSize(aInfo,aObjects)	
	
	getDocs(cProjeto)

	if ( len( apDatos ) > 0 )
	
		iif(nLsHeader = 0,nLsHeader := 1,nLsHeader) 
		iif(nLsCols = 0,nLsCols := 1,nLsCols)
	
		olDlg := TDialog():New(aSize[7],0,((aSize[6]/100)*98),((aSize[5]/100)*99),clTitulo,,,,,,,,oMainWnd,.T.)
		
		TSay():New( aPosObj[1,1]-27,aPosObj[1,2],{|| "CLIENTE: "+FP0->FP0_CLINOM },olDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,200,020)
		
		@ aPosObj[2,1]-15, aPosObj[2,2] LISTBOX olChkLst FIELDS COLSIZES 40,15,40,70,150,40,40,15 /*COLOR CLR_YELLOW,CLR_BLUE */ HEADER  "ID","Projeto","Emissão","Produto","Descrição","Qtde","Vl.Unitario","Total","Cond.Pag." SIZE (aPosObj[2,4]-7), (aPosObj[2,3]-10) OF olDlg PIXEL
		
		olChkLst:lUseDefaultColors:=.F.
		olChkLst:setArray( apDatos )
		olChkLst:nAt := nLsHeader
		olChkLst:bLine	:= { || {   apDatos[olChkLst:nAt][1],;
                                    apDatos[olChkLst:nAt][2],;
                                    apDatos[olChkLst:nAt][3],;
                                    apDatos[olChkLst:nAt][4],;
                                    apDatos[olChkLst:nAt][5],;
                                    apDatos[olChkLst:nAt][6],;
                                    apDatos[olChkLst:nAt][7],;
                                    apDatos[olChkLst:nAt][8],;
                                    apDatos[olChkLst:nAt][9];
                                } }
		// olChkLst:BlDblClick := { || MsgRun( "Aguarde, identificando itens ..." ,, {|| u_getInfoItens( apDatos[olChkLst:nAt][1],olChkLst:nAt ) } ), olChkLst:Refresh(), u_PRO002(apDatos[olChkLst:nAt][10],olChkLst:nAt), olChkLst:Refresh() , /*olItens:Refresh()*/ }
			
		olPanel := TPanel():New(aPosObj[1,1]-28,aPosObj[1,2]+100,'',olDlg,, .T., .T.,, ,(aPosObj[3,4]-110),012,.F.,.F. )
		
		// olBtn1		 := TButton():New( 002, 002, "Actualizar", olPanel,{|| llRet := .T.,getInfoGuias(),olChkLst:Refresh()/*,olItens:Refresh(),olDlg:End()*/ }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Ok"
		// olBtn1:Align := CONTROL_ALIGN_RIGHT
			
		// olSplitter1 := TSplitter():New( 01,01,olPanel,005,01 )
		// olSplitter1:Align := CONTROL_ALIGN_RIGHT
				
		oBtn2		:= TButton():New( 002, 002, "Fechar",olPanel,{|| llRet := .F., olDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Retornar"
		oBtn2:Align	:= CONTROL_ALIGN_RIGHT

		olSplitter2	:= TSplitter():New( 01,01,olPanel,005,01 )
		olSplitter1:Align := CONTROL_ALIGN_RIGHT
				
		oBtn3		:= TButton():New( 002, 002, "Gerar NF",olPanel,{|| llRet := stEx003(apDatos[olChkLst:nAt][2],apDatos[olChkLst:nAt][1],MV_PAR01), olDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Retornar"
		oBtn3:Align	:= CONTROL_ALIGN_RIGHT
		
		olDlg:Activate() 		

        if !llRet
            MsgAlert("Não foi possivel criar os documentos de indenização!", "ORGUEL")
        endif
		
	else 
		Alert("Não existem documentos para este projeto!")
	endif


Return


Static Function stEx003(xNroProjeto, xSeq, nOpc)

    // local lRet := .f.
    local lRet := .t.

    if nOpc==2      // genera documento de entrada de las pecas faltantes

        FPG->( DbSetOrder(4))
        If FPG->(MsSeek(xFilial("FPG")+xSeq))

            if alltrim(FPG->FPG_XSERIE)$"DANFE/ND"
                // IF FPG->FPG_XDEVCL=="1" .And. FPG->FPG_XSERIE$"DANFE/ND"
                
                MsgRun( "Aguarde, gerando documento de entrada..." ,, {|| lRet := u_STHORG04(xNroProjeto, xSeq) } )

                if alltrim(FPG->FPG_XSERIE)=="ND"
                    MsgRun( "Aguarde, gerando nota de debito, passo 1..." ,, {|| lRet := stEx003a( xNroProjeto,xSeq,3 ) } )
                endif

                MsgRun( "Aguarde, gerando documento fiscal, passo 1..." ,, {|| lRet := stEx003a( xNroProjeto,xSeq,2 ) } )

            endif

        endif
    
    else
        MsgRun( "Aguarde, gerando pedido de venda..." ,, {|| lRet := stEx003a( xNroProjeto,xSeq,1 ) } )
    endif

Return(lRet)


Static Function stEx003a(cNroProjeto,cSeq,pOpc)

    local _aArea    := getArea()
    local _aHeader  := {}
    local _aItems   := {}
    local _aDetalhe := {}
    local _cEspecie	:= getNewPar("IT_ESPECIE","SPED")
    local _cNaturez := getNewPar("IT_NATUREZ","41605N")
    local _cTESServ := GetMV("MV_ITTESERV")
    Local _cTESNDC  := getNewPar("IT_TESNDC","935")
    local _cSERIND  := getNewPar("MV_ITSERIN","1")
    Local _cSerNDC  := getNewPar("IT_SERNDC","ND")
    local _cTESProd := GetMV("MV_ITTESPEC")
    local _nItem    := 1
    local _cMTA410  := PADR("MTA410",Len(SX1->X1_GRUPO))
    local _nMTAAnt  := 0
    Local _cLocal   := getNewPar("IT_LOCRET","DL")
    Local lRet      := .f.
    // local _cVend1   := space(TamSx3("C5_VEND1")[1])
    // local _cVend2   := space(TamSx3("C5_VEND2")[1])
    // local _cVend3   := space(TamSx3("C5_VEND3")[1])
    // local _cVend4   := space(TamSx3("C5_VEND4")[1])
    // local _cVend5   := space(TamSx3("C5_VEND5")[1])
    
	Private lMsHelpAuto		:= .F.
	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile	:= .T.       

    SA1->( DbSetOrder(1))
    SB1->( DbSetOrder(1))
    FPA->( DbSetOrder(4))
	FP1->( DbSetOrder(1))
	FPG->( DbSetOrder(4))
	ZE1->( DbSetOrder(1))

    _aHeader  := {}
    _aItems   := {}
    _aDetalhe := {}

	If FPG->(MsSeek(xFilial("FPG")+cSeq))

        if SX1->( dbSeek(_cMTA410+"01"))
            _nMTAAnt := SX1->X1_PRESEL
            SX1->(RecLock('SX1',.f.))
            SX1->X1_PRESEL := 1
            SX1->(MsUnlock())
        endif

        SA1->(MsSeek(xFilial("SA1")+FP0->FP0_CLI))
        SB1->(MsSeek(xFilial("SB1")+FPG->FPG_PRODUT) )
		FP1->(MsSeek(xFilial("FP1")+cNroProjeto))
		FPA->(MsSeek(xFilial("FPA")+cNroProjeto))
		ZE1->(MsSeek(xFilial("ZE1")+cNroProjeto))

        aAdd(_aHeader,{"C5_FILIAL"		, xFilial("SC5")							, nil})
        aAdd(_aHeader,{"C5_TIPO"		, "N"										, nil})
        aAdd(_aHeader,{"C5_CLIENTE"		, SA1->A1_COD								, nil})
        aAdd(_aHeader,{"C5_LOJACLI"		, SA1->A1_LOJA								, nil})
        aAdd(_aHeader,{"C5_TIPOCLI"		, SA1->A1_TIPO								, nil})
        aAdd(_aHeader,{"C5_CONDPAG"		, FPG->FPG_XCONPG   						, nil})
        aAdd(_aHeader,{"C5_EMISSAO"		, dDatabase									, nil})
        aAdd(_aHeader,{"C5_TPFRETE"		, "F"           							, nil})
        aAdd(_aHeader,{"C5_ESPECI1"		, _cEspecie									, nil})
        aAdd(_aHeader,{"C5_NATUREZ"		, _cNaturez									, nil})
        aAdd(_aHeader,{"C5_OBRA"		, FPG->FPG_OBRA 	                        , nil})
        aAdd(_aHeader,{"C5_XPROJET" 	, cNroProjeto 								, nil})
        aAdd(_aHeader,{"C5_XTIPFAT"		, FP1->FP1_TPMES 							, nil})
        aAdd(_aHeader,{"C5_VEND1"		, ZE1->ZE1_VEND1 							, nil})
        aAdd(_aHeader,{"C5_VEND2"		, ZE1->ZE1_VEND2 							, nil})
        aAdd(_aHeader,{"C5_VEND3"		, ZE1->ZE1_VEND3 							, nil})
        aAdd(_aHeader,{"C5_VEND4"		, ZE1->ZE1_VEND4 							, nil})
        aAdd(_aHeader,{"C5_VEND5"		, ZE1->ZE1_VEND5 							, nil})

        if pOpc==1 .Or. pOpc==3         // servicos e ND

            _aItems := {}

            aAdd(_aItems,{"C6_FILIAL"		, xFilial("SC6")										, nil})
            aAdd(_aItems,{"C6_CLI"	    	, SA1->A1_COD											, nil})
            aAdd(_aItems,{"C6_LOJA"		    , SA1->A1_LOJA											, nil})
            aAdd(_aItems,{"C6_ITEM"  		, strzero(_nItem,2)										, nil})
            aAdd(_aItems,{"C6_PRODUTO"	    , FPG->FPG_PRODUT										, nil})
            aAdd(_aItems,{"C6_DESCRI"		, FPG->FPG_DESCRI										, nil})
            aAdd(_aItems,{"C6_LOCAL"	   	, SB1->B1_LOCPAD										, nil})
            aAdd(_aItems,{"C6_UM"			, SB1->B1_UM											, nil})
            aAdd(_aItems,{"C6_QTDVEN"		, FPG->FPG_QUANT										, nil})
            aAdd(_aItems,{"C6_DESCONT"	    , 0     												, nil})
            aAdd(_aItems,{"C6_PRUNIT"		, FPG->FPG_VLUNIT  										, nil})
            aAdd(_aItems,{"C6_PRCVEN"		, FPG->FPG_VLUNIT										, nil})
            
            if pOpc==3
                aAdd(_aItems,{"C6_TES"   	, _cTESNDC         										, nil})
            else
                aAdd(_aItems,{"C6_TES"   	, _cTESServ    	    									, nil})
            endif

            aAdd(_aDetalhe,_aItems)

        else        // pecas faltantes - fazer bucle ze1

            SB1->(DbSetOrder(1))
            ZE1->(DbSetOrder(1))

            if ZE1->(dbSeek(xFilial("ZE1")+cNroProjeto))

                // _cVend1 := ZE1->ZE1_VEND1
                // _cVend2 := ZE1->ZE1_VEND2
                // _cVend3 := ZE1->ZE1_VEND3
                // _cVend4 := ZE1->ZE1_VEND4
                // _cVend5 := ZE1->ZE1_VEND5

                while ZE1->(!Eof()) .and. alltrim(ZE1->ZE1_PROJET)==alltrim(cNroProjeto)

                    if ZE1->ZE1_QTDRET>0

                        _aItems := {}

                        SB1->(MsSeek(xFilial("SB1")+ZE1->ZE1_PRODUT))    //FILIAL+PRODUTO

                        aAdd(_aItems,{"C6_FILIAL"		, xFilial("SC6")										, nil})
                        // aAdd(_aItems,{"C6_CLI"	    	, SA1->A1_COD											, nil})
                        // aAdd(_aItems,{"C6_LOJA"		    , SA1->A1_LOJA											, nil})
                        aAdd(_aItems,{"C6_ITEM"  		, STRZERO(_nItem,2)										, nil})
                        aAdd(_aItems,{"C6_PRODUTO"	    , ZE1->ZE1_PRODUT										, nil})
                        // aAdd(_aItems,{"C6_DESCRI"		, SB1->B1_DESC  										, nil})
                        aAdd(_aItems,{"C6_LOCAL"	   	, _cLocal           									, nil})
                        // aAdd(_aItems,{"C6_UM"			, SB1->B1_UM											, nil})
                        aAdd(_aItems,{"C6_QTDVEN"		, ZE1->ZE1_QTDRET										, nil})
                        aAdd(_aItems,{"C6_TES"   		, _cTESProd    											, nil})
                        // aAdd(_aItems,{"C6_DESCONT"	    , ZE1->ZE1_DESCON										, nil})
                        // aAdd(_aItems,{"C6_PRUNIT"		, ZE1->ZE1_VLINDE  										, nil})
                        aAdd(_aItems,{"C6_PRCVEN"		, ZE1->ZE1_VLINDE										, nil})

                        _nItem++
                        aAdd(_aDetalhe,_aItems)

                    endif

                    ZE1->(dbSkip())

                end

            endif

        endif

        if len(_aDetalhe)>0

            DbSelectArea("SC5")

            MSExecAuto({|x,y,z|Mata410(x,y,z)},_aHeader,_aDetalhe,3,.f.)

            If lMSErroAuto
                
                lRet := .f.
                MostraErro()

            else

                // SC5->(RecLock('SC5',.F.))
                // SC5->C5_VEND1 := _cVend1
                // SC5->C5_VEND2 := _cVend2
                // SC5->C5_VEND3 := _cVend3
                // SC5->C5_VEND4 := _cVend4
                // SC5->C5_VEND5 := _cVend5
                // SC5->(MsUnlock())

                // MsgInfo("Pedido gerado con sucesso!","ORGUEL")
                // MsgRun( "Aguarde, gerando documento fiscal ..." ,, {|| lRet := stEx003b(SC5->C5_NUM,FPG->FPG_XSERIE) } )
                if pOpc==3  // NDC
                    MsgRun( "Aguarde, gerando nota de debito, passo 2..." ,, {|| lRet := stEx003b(SC5->C5_NUM,_cSerNDC,cNroProjeto) } )
                else
                    MsgRun( "Aguarde, gerando nota fiscal, passo 2..." ,, {|| lRet := stEx003b(SC5->C5_NUM,_cSERIND,cNroProjeto) } )
                endif

            endif

        else
            
            lRet := .f.
            MsgAlert("Nenhum item encontrado!", "ORGUEL")
        
        endif

        if SX1->( dbSeek(_cMTA410+"01"))
            if _nMTAAnt <> 0
                SX1->(RecLock('SX1',.f.))
                SX1->X1_PRESEL := _nMTAAnt
                SX1->(MsUnlock())
            endif
        endif

    endif

    restArea(_aArea)

Return(lRet)


Static Function getDocs(cProjeto)

	local a_area  := getArea()
	local cQuery  := ""
	local cArqTrb := getNextAlias()

    apDatos := {}

	cQuery := "SELECT FPG_SEQ,FPG_PROJET,FPG_DTENT,FPG_PRODUT,FPG_DESCRI,FPG_QUANT,FPG_VLUNIT,"
	cQuery += "       FPG_VALOR,FPG_XCONPG,R_E_C_N_O_ AS XREC"
	cQuery += "  FROM " + RetSQLName("FPG")
	cQuery += " WHERE FPG_FILIAL ='" + xFilial("FPG") + "'" 
	cQuery += "   AND D_E_L_E_T_= ''"
    cQuery += "   AND FPG_XTIPAJ='I'"
    cQuery += "   AND FPG_PROJET='"+cProjeto+"'"
    if MV_PAR01==1      // servicos
	    cQuery += "   AND FPG_XSERIN>0"
    else
        cQuery += "   AND FPG_XPFIND>0"
    endif

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTrb,.T.,.T.)

	if (cArqTrb)->( !eof() )
	
		While (cArqTrb)->( !eof() )
		
			Aadd( apDatos, {	(cArqTrb)->FPG_SEQ,;
								(cArqTrb)->FPG_PROJET,;
                                stod((cArqTrb)->FPG_DTENT),;
								(cArqTrb)->FPG_PRODUT,;
								(cArqTrb)->FPG_DESCRI,;
								Transform((cArqTrb)->FPG_QUANT,"@E 999,999,999.99"),;
								Transform((cArqTrb)->FPG_VLUNIT,"@E 999,999,999.99"),;
								Transform((cArqTrb)->FPG_VALOR,"@E 999,999,999.99"),;
								(cArqTrb)->FPG_XCONPG,;
								(cArqTrb)->XREC;
								 } )
		
			(cArqTrb)->( dbSkip() )
		End
	
	endif
	
	(cArqTrb)->( dbCloseArea() )
	
	RestArea(a_area)
    
Return .t.



Static Function stEx003b(cC5Num,cSerie,cContrato)

    Local aPvlDocS := {}
    Local nPrcVen := 0
    Local cEmbExp := ""
    Local cDoc    := ""

    SC5->(DbSetOrder(1))
    SC5->(MsSeek(xFilial("SC5")+cC5Num))

    SC6->(dbSetOrder(1))
    SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))

    //É necessário carregar o grupo de perguntas MT460A, se não será executado com os valores default.
    Pergunte("MT460A",.F.)

    // Obter os dados de cada item do pedido de vendas liberado para gerar o Documento de Saída
    While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM

        SC9->(DbSetOrder(1))
        SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))) //FILIAL+NUMERO+ITEM

        SE4->(DbSetOrder(1))
        SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

        SB1->(DbSetOrder(1))
        SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))    //FILIAL+PRODUTO

        SB2->(DbSetOrder(1))
        SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL))) //FILIAL+PRODUTO+LOCAL

        SF4->(DbSetOrder(1))
        SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))   //FILIAL+TES

        nPrcVen := SC9->C9_PRCVEN
        If ( SC5->C5_MOEDA <> 1 )
            nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
        EndIf

        AAdd(aPvlDocS,{ SC9->C9_PEDIDO,;
                        SC9->C9_ITEM,;
                        SC9->C9_SEQUEN,;
                        SC9->C9_QTDLIB,;
                        nPrcVen,;
                        SC9->C9_PRODUTO,;
                        .F.,;
                        SC9->(RecNo()),;
                        SC5->(RecNo()),;
                        SC6->(RecNo()),;
                        SE4->(RecNo()),;
                        SB1->(RecNo()),;
                        SB2->(RecNo()),;
                        SF4->(RecNo())})

        SC6->(DbSkip())

    EndDo
    
    cDoc := MaPvlNfs(  /*aPvlNfs*/         aPvlDocS,;  // 01 - Array com os itens a serem gerados
                       /*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
                       /*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
                       /*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
                       /*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
                       /*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
                       /*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
                       /*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
                       /*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
                       /*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
                       /*lECF*/            .F.,;       // 11 - Cupom Fiscal
                       /*cEmbExp*/         cEmbExp,;   // 12 - Número do Embarque de Exportação
                       /*bAtuFin*/         {|nReg|AtuSE1(nReg,cSerie)},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
                       /*bAtuPGerNF*/      {|nReg|AtuSF2(nReg,cContrato)},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
                       /*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
                       /*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
                       /*dDataMoe*/        dDatabase,; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
                       /*lJunta*/          .F.)        // 18 - Aglutina Pedido Iguais
    
    If !Empty(cDoc)
        Conout("Documento de Saída: " + cSerie + "-" + cDoc + ", gerado com sucesso!!!")
        MsgInfo("Documento de Saída: " + cSerie + "-" + cDoc + ", gerado com sucesso!","ORGUEL")
    EndIf

Return .T.

Static Function AtuSE1(nReg,cOp)

    local _vArea := getArea()

    if alltrim(cOp)=="ND"
        DbSelectArea("SE1")
        DbGoTo(nReg)
        SE1->(RecLock('SE1',.f.))
        SE1->E1_TIPO := "ND"
        SE1->(MsUnlock())
    EndIf

    restArea(_vArea)

Return(.t.)

Static Function AtuSF2(nReg,cContrato)

    local _vArea := getArea()

    SF2->(RecLock('SF2',.f.))
    SF2->F2_MENNOTA := "REF CONTRATO "+cContrato
    SF2->(MsUnlock())

    restArea(_vArea)

Return(.t.)
