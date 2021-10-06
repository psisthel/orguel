#include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function STHORG05(cProjeto, cSeq)

    Local _cArea    := getArea()
    Local cNum      := ""
    Local lret      := .t.
    Local _cTESNDC  := getNewPar("IT_TESNDC","935")
    // Local _cNatNDC  := getNewPar("IT_NATRET","40301N")
    Local _cSerNDC  := getNewPar("IT_SERNDC","ND")
    Local aCab	    	:= {}
    Local aLinha    	:= {}
    Local aItens    	:= {}

	Private lMsHelpAuto		:= .F.
	Private lMsErroAuto 	:= .F.
    Private lAutoErrNoFile	:= .T.

    SA1->( DbSetOrder(1))
    SA1->(MsSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))

    cNum   := NXTSX5NOTA(_cSerNDC, NIL, GetNewPar("MV_TPNRNFS","1"))

    AAdd( aCab, { "F2_TIPO"         ,"N"	           			, Nil } )  
    AAdd( aCab, { "F2_CLIENTE"      ,FP0->FP0_CLI				, Nil } )	
    AAdd( aCab, { "F2_LOJA"         ,FP0->FP0_LOJA				, Nil } )	
    AAdd( aCab, { "F2_SERIE"        ,_cSerNDC					, Nil } )	 
    AAdd( aCab, { "F2_DOC"          ,cNum           			, Nil } )	  		 
    AAdd( aCab, { "F2_COND"         ,FPG->FPG_XCONPG			, Nil } )	 
    AAdd( aCab, { "F2_EMISSAO"      ,dDataBase					, Nil } )	   
    AAdd( aCab, { "F2_ESPECIE"      ,"NF"	              		, Nil } ) 
    AAdd( aCab, { "F2_PREFIXO"      ,_cSerNDC          			, Nil } ) 
    AAdd( aCab, { "F2_FORMUL"       ,"S"               			, Nil } ) 
    
    aLinha := {}
    
    AAdd( aLinha, { "D2_COD"    	, FPG->FPG_PRODUT	 		, Nil } )
    AAdd( aLinha, { "D2_QUANT"  	, FPG->FPG_QUANT			, Nil } )					
    AAdd( aLinha, { "D2_PRCVEN"  	, FPG->FPG_VLUNIT			, Nil } )					
    // AAdd( aLinha, { "D2_TOTAL"  	, 9000						, Nil } )
    AAdd( aLinha, { "D2_TES" 		, _cTESNDC 					, Nil } )
    // AAdd( aLinha, { "D2_UM"     	, "UN" 						, Nil } )
    AAdd( aLinha, { "D2_ESPECIE"    , "NF"   					, Nil } )

    AAdd( aItens, aLinha)
    
    // MSExecAuto( { |x,y,z| Mata465n(x,y,z) }, aCab, aItens, 3 ) 
    MSExecAuto( { |x,y,z| Mata467n(x,y,z) }, aCab, aItens, 3 ) 
    
    If lMsErroAuto
        MsgStop("Erro na gravação.")
        MostraErro()
    Else
        MsgAlert("Nota de debito incluida com sucesso!")
    EndIf

    restArea(_cArea)
    
Return(lret)
