#include "PROTHEUS.CH"

User Function STHORG01

	Local _aArea	:= getArea()
	Local aPosObj   := {} 
	Local aObjects  := {}
	Local aSize     := MsAdvSize( .F. ) 
	Local aNoFields	:= {}
	Local nOpc		:= 4
	local olFont	:= TFont():New('Courier new',,-14,.T.)		//TFont():New('Arial',,-16,.T.)
	Local bWhile    	:= {|| }
	Local aTravas		:= {}			// Campos que foram travados
	Local lTravas		:= .T.			// Se todos os campos foram travados com sucesso
	Local dNovaData		:= dDataBase
    
	Private oGet2	:= Nil
	Private oGetD	:= Nil
	Private oDlg	:= Nil	

    Private aHeader
    Private aCols

	cQuery := "SELECT *"
	cQuery += "  FROM " + RetSQLName("FPA")
	cQuery += " WHERE FPA_FILIAL ='" + xFilial("FPA") + "'" 
	cQuery += "   AND D_E_L_E_T_= ' '"
	cQuery += "   AND FPA_PROJET='" + FP0->FP0_PROJET + "'"

	aHeader	:= {}
	aCols	:= {}

	cSeek		:= xFilial("FPA")+FP0->FP0_PROJET
	bWhile		:= {|| FPA->FPA_FILIAL+FPA->FPA_PROJET}

    aNoFields := {"FPA_FILIAL","FPA_TIPOSE","FPA_SEQSUB","FPA_CODTAB","FPA_DESTAB","FPA_LOCAL","FPA_GRUA","FPA_DESGRU",;
                    "FPA_CARAC","FPA_OBSSER","FPA_PREDIA","FPA_MINDIA","FPA_MINMES","FPA_ACRESC","FPA_CARENC","FPA_VLBRUT",;
                    "FPA_PDESC","FPA_VRHOR","FPA_TPGUIM","FPA_GUIMON","FPA_TPGUID","FPA_GUIDES","FPA_VLPEDA","FPA_HRENRE",;
                    "FPA_VREXCE","FPA_DIARIA","FPA_HORADI","FPA_UTIMES","FPA_DIAFEC","FPA_TPISS","FPA_PERISS","FPA_VRISS",;
                    "FPA_VRSEGU","FPA_HRINI","FPA_HRFIM","FPA_DTENRE","FPA_DTPRRT","FPA_ULTFAT","FPA_SABADO","FPA_DOMING",;
                    "FPA_CONPAG","FPA_TIPPAG","FPA_OBS","FPA_REVNAS","FPA_AS","FPA_VIAGEM","FPA_DTPREN","FPA_MOTENT",;
                    "FPA_NFREM","FPA_DNFREM","FPA_NFENT","FPA_DNFENT","FPA_PLACAI","FPA_REBOQI","FPA_DTSCRT","FPA_MOTRET",;
                    "FPA_NFRET","FPA_DNFRET","FPA_ALEVEN","FPA_CNJ","FPA_COMP","FPA_LARG","FPA_ALTU","FPA_DIAM","FPA_PESO",;
                    "FPA_TPBASE","FPA_HORVIA","FPA_VRHORN","FPA_VRMOB","FPA_VRDES","FPA_PREHOR","FPA_VRHOR1","FPA_VRHOR2",;
                    "FPA_VRMOB1","FPA_VRMOB2","FPA_VRMOBN","FPA_VRDES1","FPA_VRDES2","FPA_VRDESN","FPA_PRENEG","FPA_PREFEC",;
                    "FPA_OBSOBR","FPA_LOCTER","FPA_SAIRET","FPA_QVEICP","FPA_VRKM","FPA_TOTKM","FPA_VRPESO","FPA_TPMEDI",;
                    "FPA_TPSEGU","FPA_PERSEG","FPA_PERMAO","FPA_TIPOCA","FPA_GUIALO","FPA_SEQTRA","FPA_VRUNIT","FPA_VRTOTA",;
                    "FPA_TPVAL","FPA_QTEIXO","FPA_MONTAG","FPA_DESMON","FPA_TELESC","FPA_ANCORA","FPA_OPERAD","FPA_TPMED1",;
                    "FPA_TPMED2","FPA_TPMED3","FPA_TPMED4","FPA_SEQEST","FPA_TPMED5","FPA_TPMED6","FPA_TPMED7","FPA_HEMAQ",;
                    "FPA_HEOPE","FPA_HEFDS","FPA_LANCA","FPA_TORREI","FPA_TORREF","FPA_CAPACI","FPA_CARACT","FPA_VRCARG",;
                    "FPA_TPMOBI","FPA_TPDESM","FPA_CODLCR","FPA_PES","FPA_CONJT","FPA_VLEST","FPA_DTAS","FPA_CHUMBA",;
                    "FPA_DIASM","FPA_DIASD","FPA_DIAST","FPA_TPOPER","FPA_TPMEDB","FPA_FORPG","FPA_RATEIO","FPA_FLMAQ",;
                    "FPA_FLMO","FPA_FORPAG","FPA_DESCON","FPA_DESCON","FPA_VALDES","FPA_HPROD","FPA_HIMPR","FPA_HEXCED",;
                    "FPA_HADICI","FPA_HGREVE","FPA_HCHUVA","FPA_HDISPO","FPA_CABTEN","FPA_VLMOBR","FPA_HEMOBR","FPA_KMROD",;
                    "FPA_HORIME","FPA_JUNKH","FPA_THORAS","FPA_CONFIG","FPA_EMBARC","FPA_CACAMB","FPA_XRETRE","FPA_PARIDA",;
                    "FPA_PARVOL","FPA_SERRET","FPA_PLACAV","FPA_REBOQV","FPA_PEDIDO","FPA_FILREM","FPA_SERREM","FPA_ITEREM",;
                    "FPA_HRFRAQ","FPA_VLHREX","FPA_CUSTO","FPA_ITERET","FPA_NATURE","FPA_FILEMI","FPA_XLOTE","FPA_XPERLO",;
                    "FPA_XRTRAB","FPA_XVLDES","FPA_XTRERE","FPA_XIDSEQ","FPA_PESPAD","FPA_VLINPA","FPA_INDTOT","FPA_UNIDIA",;
					"FPA_FAMILI","FPA_OBRA","FPA_XDFAMI","FPA_TRECHO","FPA_PESPAD","FPA_PESTOT","FPA_QTENV","FPA_XSALDO",;
					"FPA_XOBSDE","FPA_XMOTIV","FPA_XORITE"} 

	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		
        If !FillGetDados(	nOpc			,"FPA"			,4				,cSeek  		,;
						bWhile      	,{|| .T. }		,aNoFields		,/*aYesFields*/	,; 
						/*lOnlyYes*/	,cQuery 		,/*bMontCols*/	,/*lEmpty*/ 	,;
						/*aHeaderAux*/	,/*aColsAux*/	,/*bAfterCols*/	,{|| AtTravaReg("FPA", aTravas) } )

            lTravas := .f.
        endif

	Endif

	AAdd( aObjects, { 100, 20, .t., .F. } )
	AAdd( aObjects, { 100, 100, .t., .t. } )
	AADD( aObjects, { 100, 10, .T., .F. } )

	aInfo   := {0,0,aSize[3],aSize[4],3,3}
	aPosObj := MsObjSize( aInfo, aObjects ) 

	oDlg := TDialog():New(aSize[7],0,((aSize[6]/100)*98),((aSize[5]/100)*99),"Gerar Anticipos",,,,,,,,oMainWnd,.T.)
			
	TSay():New( aPosObj[1,1]+5,aPosObj[1,2],{|| "Projeto : "+FP0->FP0_PROJET },oDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	TSay():New( aPosObj[1,1]+15,aPosObj[1,2],{|| "Cliente : "+FP0->FP0_CLI+" - "+FP0->FP0_CLINOM },oDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	TSay():New( aPosObj[1,1]+25,aPosObj[1,2],{|| "Valor   : "+alltrim(transform(FP0->FP0_VALPRO,"9,999,999.99")) },oDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)

	TSay():New( aPosObj[1,1]+25,aPosObj[3,4]-150,{|| "Nova Data Fat.: " },oDlg,,olFont,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,300,020)
	oGet2 := TGet():New( aPosObj[1,1]+25, aPosObj[3,4]-80, { | u | If( PCount() == 0, dNovaData, dNovaData := u ) },oDlg, 060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dNovaData",,,,.t.)

	oGetd := MsGetDados():New(aPosObj[2,1]+15,aPosObj[2,2],aPosObj[2,3]-20,aPosObj[2,4]-10,2,"AllwaysTrue()","AllwaysTrue()","+FPA_SEQGRU",.T.,{})

	olPanel := TPanel():New(aPosObj[3,1]-15,aPosObj[3,2],'',oDlg,, .T., .T.,, ,(aPosObj[3,4]-10),012,.F.,.F. )
			
	olBtn1		 := TButton():New( 002, 002, "Confirmar", olPanel,{|| u_stExecuta(FP0->FP0_PROJET,dNovaData),oDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	olBtn1:Align := CONTROL_ALIGN_RIGHT
				
	olSplitter1 := TSplitter():New( 01,01,olPanel,005,01 )
	olSplitter1:Align := CONTROL_ALIGN_RIGHT

	olBtn2		 := TButton():New( 002, 002, "Fechar", olPanel,{|| oDlg:End() }, 55,10,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	olBtn2:Align := CONTROL_ALIGN_RIGHT

	olSplitter2	:= TSplitter():New( 01,01,olPanel,005,01 )
    olSplitter1:Align := CONTROL_ALIGN_RIGHT

	Activate MSDialog oDlg Centered

	RestArea( _aArea )

Return


User Function stExecuta(cNroProjeto,dNovaData)

    MsgRun( "Aguarde, gerando pedido de venda..." ,, {|| lRet := stGeraSC5( cNroProjeto,dNovaData ) } )

Return



Static Function stGeraSC5(cNroProjeto,dNovaData)

    local _aHeader  := {}
    local _aItems   := {}
    local _aDetalhe := {}
    local _cEspecie	:= getNewPar("IT_ESPECIE","SPED")
    local _cNaturez := getNewPar("IT_NATUREZ","41605N")
    local _cTES     := getNewPar("IT_TES","501")
    local _nItem    := 1
    
    Private lMSErroAuto := .t.

    SA1->( DbSetOrder(1))
    SB1->( DbSetOrder(1))
    FPA->( DbSetOrder(4))
	FP1->( DbSetOrder(1))

	If FPA->(MsSeek(xFilial("FPA")+cNroProjeto))

        SA1->(MsSeek(xFilial("SA1")+FP0->FP0_CLI))
        ZD5->(MsSeek(xFilial("ZD5")+cNroProjeto))
		FP1->(MsSeek(xFilial("FP1")+cNroProjeto))

        aAdd(_aHeader,{"C5_FILIAL"		, xFilial("SC5")							, nil})
        aAdd(_aHeader,{"C5_TIPO"		, "N"										, nil})
        aAdd(_aHeader,{"C5_CLIENTE"		, SA1->A1_COD								, nil})
        aAdd(_aHeader,{"C5_LOJACLI"		, SA1->A1_LOJA								, nil})
        aAdd(_aHeader,{"C5_TIPOCLI"		, SA1->A1_TIPO								, nil})
        aAdd(_aHeader,{"C5_CONDPAG"		, ZD5->ZD5_CONPAG   						, nil})
        aAdd(_aHeader,{"C5_EMISSAO"		, dNovaData									, nil})
        aAdd(_aHeader,{"C5_TPFRETE"		, ZD5->ZD5_TPFRET							, nil})
        aAdd(_aHeader,{"C5_ESPECI1"		, _cEspecie									, nil})
        aAdd(_aHeader,{"C5_NATUREZ"		, _cNaturez									, nil})
        aAdd(_aHeader,{"C5_OBRA"		, FP1->FP1_XSEGOB	                        , nil})
        aAdd(_aHeader,{"C5_XPROJET" 	, cNroProjeto 								, nil})
        aAdd(_aHeader,{"C5_XTIPFAT"		, FP1->FP1_TPMES 							, nil})

        while FPA->( !EOF() .And. FPA->FPA_PROJET==cNroProjeto )

			if SB1->( MsSeek( xFilial("SB1") + FPA->FPA_PRODUT ) )

				_aItems := {}

                aAdd(_aItems,{"C6_FILIAL"		, xFilial("SC6")										, nil})
                aAdd(_aItems,{"C6_CLI"	    	, SA1->A1_COD											, nil})
                aAdd(_aItems,{"C6_LOJA"		    , SA1->A1_LOJA											, nil})
                aAdd(_aItems,{"C6_ITEM"  		, _nItem												, nil})
                aAdd(_aItems,{"C6_PRODUTO"	    , SB1->B1_COD											, nil})
                aAdd(_aItems,{"C6_DESCRI"		, SB1->B1_DESC											, nil})
                aAdd(_aItems,{"C6_LOCAL"	   	, SB1->B1_LOCPAD										, nil})
                aAdd(_aItems,{"C6_UM"			, SB1->B1_UM											, nil})
                aAdd(_aItems,{"C6_QTDVEN"		, FPA->FPA_QUANT										, nil})
                aAdd(_aItems,{"C6_DESCONT"	    , 0     												, nil})
                aAdd(_aItems,{"C6_PRUNIT"		, FPA->FPA_PRCUNI  										, nil})
                aAdd(_aItems,{"C6_PRCVEN"		, FPA->FPA_PRCUNI										, nil})
                aAdd(_aItems,{"C6_TES"   		, _cTES     											, nil})
                
                _nItem++
                aAdd(_aDetalhe,_aItems)

            Endif

			FPA->( dbSkip() )

        end

		lMSErroAuto := .t.

        MSExecAuto({|x,y,z|Mata410(x,y,z)},_aHeader,_aDetalhe,3,.f.)

        If lMSErroAuto

            MostraErro()
        else
            
            MsgInfo("Pedido gerado con sucesso!","ORGUEL")

        endif

    endif

Return


User Function stlinha()

	local lret := .f.

	if n <= len(aCols)
		lret := .t.
	endif

Return(lret)
