#include "PROTHEUS.CH"

/*
Programa    : STHORG01
Descricao   : Generar Pedido de venda 
Cliente     : ORGUEL
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG01

	Local _aArea	:= getArea()
	Local dNovaData	:= dDataBase
	Local _nOpc		:= 0
	Local oDlg
	Local cTitulo	:= "Gerar Anticipos"
	Local lRet		:= .t.

    Private oFont6  := NIL

	Define FONT oFont6 NAME "Arial"

	DEFINE MSDIALOG oDlg FROM 264,182 TO 441,613 TITLE cTitulo OF oDlg PIXEL
		
	@ 004,010 TO 082,157 LABEL "" OF oDlg PIXEL
			
	@ 015,017 SAY "Esta rotina tem por objetivo gerar anticipos"	OF oDlg PIXEL Size 150,010 FONT oFont6 
	@ 025,017 SAY "de los documentos electronicos."	                OF oDlg PIXEL Size 150,010 FONT oFont6 
			
	@ 12,167 BUTTON "&Continuar"	SIZE 036,012 ACTION (_nOpc:=1,oDlg:END())	OF oDlg PIXEL
	@ 32,167 BUTTON "Sai&r"     	SIZE 036,012 ACTION (_nOpc:=2,oDlg:END())	OF oDlg PIXEL
			
	ACTIVATE MSDIALOG oDlg CENTERED

    if _nOpc==1

        ZDZ->( DbSetOrder(1))
    	If ZDZ->(MsSeek(xFilial("ZDZ")+FP0->FP0_CLI+FP0->FP0_LOJA+FP0->FP0_PROJET))
            MsgRun( "Aguarde, procurando documentos..." ,, {|| lRet := u_stExecuta(FP0->FP0_CLI,FP0->FP0_LOJA,FP0->FP0_PROJET,dNovaData) } )
        else
            MsgAlert("Projeto nro "+alltrim(FP0->FP0_PROJET)+" não encontrado!", "ORGUEL")
        endif

    endif

	RestArea( _aArea )

Return



User Function stExecuta(cCliente,cLoja,cNroProjeto,dNovaData)

    MsgRun( "Aguarde, gerando pedido de venda..." ,, {|| lRet := stGeraSC5( cCliente,cLoja,cNroProjeto,dNovaData ) } )

Return



Static Function stGeraSC5(cCliente,cLoja,cNroProjeto,dNovaData)

    local _aHeader  := {}
    local _aItems   := {}
    local _aDetalhe := {}
    local _cEspecie	:= getNewPar("IT_ESPECIE","SPED")
    local _cNaturez := getNewPar("IT_NATUREZ","41605N")
    local _cTES     := getNewPar("IT_TES","501")
    local _nItem    := 1
    
	Private lMsHelpAuto		:= .F.
	Private lMsErroAuto 	:= .F.
    Private lAutoErrNoFile	:= .T.

    SA1->( DbSetOrder(1))
    SB1->( DbSetOrder(1))
    ZDZ->( DbSetOrder(1))
	FP1->( DbSetOrder(1))

	If ZDZ->(MsSeek(xFilial("ZDZ")+cCliente+cLoja+cNroProjeto))

        SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
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

        while ZDZ->( !EOF() .And. ZDZ->ZDZ_CLIENT+ZDZ->ZDZ_LOJA==cCliente+cLoja .and.  ZDZ->ZDZ_CONTRA==cNroProjeto )

			if SB1->( MsSeek( xFilial("SB1") + ZDZ->ZDZ_PRODUT ) )

				_aItems := {}

                aAdd(_aItems,{"C6_FILIAL"		, xFilial("SC6")										, nil})
                aAdd(_aItems,{"C6_CLI"	    	, SA1->A1_COD											, nil})
                aAdd(_aItems,{"C6_LOJA"		    , SA1->A1_LOJA											, nil})
                aAdd(_aItems,{"C6_ITEM"  		, _nItem												, nil})
                aAdd(_aItems,{"C6_PRODUTO"	    , SB1->B1_COD											, nil})
                aAdd(_aItems,{"C6_DESCRI"		, SB1->B1_DESC											, nil})
                aAdd(_aItems,{"C6_LOCAL"	   	, SB1->B1_LOCPAD										, nil})
                aAdd(_aItems,{"C6_UM"			, SB1->B1_UM											, nil})
                aAdd(_aItems,{"C6_QTDVEN"		, ZDZ->ZDZ_QUANT										, nil})
                aAdd(_aItems,{"C6_DESCONT"	    , 0     												, nil})
                aAdd(_aItems,{"C6_PRUNIT"		, ZDZ->ZDZ_VALTOT  										, nil})
                aAdd(_aItems,{"C6_PRCVEN"		, ZDZ->ZDZ_VALTOT										, nil})
                aAdd(_aItems,{"C6_TES"   		, _cTES     											, nil})
                
                _nItem++
                aAdd(_aDetalhe,_aItems)

            Endif

			ZDZ->( dbSkip() )

        end

        MSExecAuto({|x,y,z|Mata410(x,y,z)},_aHeader,_aDetalhe,3,.f.)

        If lMSErroAuto

            MostraErro()
        else
            
            MsgInfo("Pedido gerado con sucesso!","ORGUEL")

        endif

    endif

Return


// User Function stlinha()

// 	local lret := .f.

// 	if n <= len(aCols)
// 		lret := .t.
// 	endif

// Return(lret)
