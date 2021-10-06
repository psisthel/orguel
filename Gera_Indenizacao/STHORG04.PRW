#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "TbiConn.ch"

User Function STHORG04(cProjeto, cSeq)

    Local _xArea    := getArea()
    Local aCab      := {}
    Local aItem     := {}
    Local aItens    := {}
    // Local nOpc      := 3
    // Local cNum      := ""
    Local nX        := 1
    Local lret      := .t.
    Local _cLocal   := getNewPar("IT_LOCRET","DL")
    Local _cTESDev  := getNewPar("IT_TESRET","463")
    Local _cNatDev  := getNewPar("IT_NATRET","40301N")

	Private lMsHelpAuto		:= .F.
	Private lMsErroAuto 	:= .F.
    Private lAutoErrNoFile	:= .T.

    // SF4->( DbSetOrder(1))
    // if SF4->( dbSeek( xFilial("SF4")+_cTESDev ) )
    //     if !empty(SF4->F4_TESDV)
    //         _cTESDev := SF4->F4_TESDV
    //     EndIf
    // EndIf

    SA1->( DbSetOrder(1))
    SA1->(MsSeek(xFilial("SA1")+FP0->FP0_CLI+FP0->FP0_LOJA))

    // cNum := GetSxeNum("SF1","F1_DOC")

    // SF1->(dbSetOrder(1))
    // While SF1->(dbSeek(xFilial("SF1")+cNum))
    //     ConfirmSX8()
    //     cNum := GetSxeNum("SF1","F1_DOC")
    // EndDo

    // cNum   := NXTSX5NOTA(FPG->FPG_XSERIE, NIL, GetNewPar("MV_TPNRNFS","1"))

    aadd(aCab,{"F1_TIPO"        ,"D"                    ,NIL})
    aadd(aCab,{"F1_FORMUL"      ,"N"                    ,NIL})
    // aadd(aCab,{"F1_DOC"         ,cNum                   ,NIL})
    aadd(aCab,{"F1_DOC"         ,"000000002"                   ,NIL})
    // aadd(aCab,{"F1_SERIE"       ,FPG->FPG_XSERIE        ,NIL})
    aadd(aCab,{"F1_SERIE"       ,"PCY"        ,NIL})
    aadd(aCab,{"F1_EMISSAO"     ,DDATABASE              ,NIL})
    // aadd(aCab,{"F1_FORNECE"     ,FP0->FP0_CLI           ,NIL})
    aadd(aCab,{"F1_FORNECE"     ,"000003"           ,NIL})
    // aadd(aCab,{"F1_LOJA"        ,FP0->FP0_LOJA          ,NIL})
    aadd(aCab,{"F1_LOJA"        ,"01"          ,NIL})
    // aadd(aCab,{"F1_ESPECIE"     ,FPG->FPG_XSERIE        ,NIL})
    aadd(aCab,{"F1_ESPECIE"     ,"BOL"                  ,NIL})
    // aadd(aCab,{"F1_DTDIGIT"     ,DDATABASE              ,NIL})
    // aadd(aCab,{"F1_COND"        ,FPG->FPG_XCONPG        ,NIL})
    // aadd(aCab,{"F1_EST"         ,SA1->A1_EST            ,NIL})
    // aadd(aCab,{"F1_DESCONT"     ,0                      ,Nil})
    // aadd(aCab,{"F1_SEGURO"      ,0                      ,Nil})
    // aadd(aCab,{"F1_FRETE"       ,0                      ,Nil})
    // aadd(aCab,{"F1_MOEDA"       ,1                      ,Nil})
    // aadd(aCab,{"F1_TXMOEDA"     ,1                      ,Nil})
    // aadd(aCab,{"F1_STATUS"      ,"A"                    ,Nil})



                aItem := {}

                aadd(aItem,{"D1_ITEM"           ,StrZero(nX,4)          ,NIL})
                aadd(aItem,{"D1_COD"            ,"0852010024"        ,NIL})
                // aadd(aItem,{"D1_UM"             ,SB1->B1_UM             ,NIL})
                // aadd(aItem,{"D1_LOCAL"          ,_cLocal                ,NIL})
                aadd(aItem,{"D1_NATUREZ"        ,_cNatDev               ,NIL})
                aadd(aItem,{"D1_TES"            ,_cTESDev               ,NIL})
                // aadd(aItem,{"D1_QUANT"          ,FPA->FPA_XQTRET        ,NIL})
                // aadd(aItem,{"D1_VUNIT"          ,FPA->FPA_PRCUNI        ,NIL})
                aadd(aItem,{"D1_QUANT"          ,1        ,NIL})
                aadd(aItem,{"D1_VUNIT"          ,2500        ,NIL})
                aadd(aItem,{"D1_NFORI"          ,"011444"            ,NIL})
                aadd(aItem,{"D1_SERIORI"        ,"RPS"                    ,NIL})
                aadd(aItem,{"D1_ITEMORI"        ,"01"                   ,NIL})
                
                nX++
                aAdd(aItens,aItem)






    // FPA->( DbSetOrder(4))
    // if FPA->(MsSeek(xFilial("FPA")+cProjeto))

    //     while (xFilial("FPA")+cProjeto==FPA->FPA_FILIAL+FPA->FPA_PROJET) .AND. FPA->(!EOF())

    //         if FPA->FPA_XQTRET>0

    //             SB1->( MsSeek(xFilial("SB1")+FPA->FPA_PRODUT) )

    //             aItem := {}

    //             aadd(aItem,{"D1_ITEM"           ,StrZero(nX,4)          ,NIL})
    //             aadd(aItem,{"D1_COD"            ,FPA->FPA_PRODUT        ,NIL})
    //             aadd(aItem,{"D1_UM"             ,SB1->B1_UM             ,NIL})
    //             aadd(aItem,{"D1_QUANT"          ,FPA->FPA_XQTRET        ,NIL})
    //             aadd(aItem,{"D1_VUNIT"          ,FPA->FPA_PRCUNI        ,NIL})
    //             aadd(aItem,{"D1_LOCAL"          ,_cLocal                ,NIL})
    //             aadd(aItem,{"D1_NATUREZ"        ,_cNatDev               ,NIL})
    //             aadd(aItem,{"D1_TES"            ,_cTESDev               ,NIL})
    //             aadd(aItem,{"D1_NFORI"          ,"000027545"            ,NIL})
    //             aadd(aItem,{"D1_SERIORI"        ,"1"                    ,NIL})
    //             aadd(aItem,{"D1_ITEMORI"        ,"02"                   ,NIL})
                
    //             // aadd(aItem,{"D1_VUNIT"          ,FPA->FPA_VLINPA        ,NIL})
                
    //             nX++
    //             aAdd(aItens,aItem)

    //         EndIf

    //         FPA->(DBSkip())

    //     End

    // EndIf

    lMsErroAuto := .t.

    //3-Inclusão / 4-Classificação / 5-Exclusão
    // MSExecAuto({|x, y, z| MATA103(x, y, z)},aCab,aItens,3)
    MSEXECAUTO({|X,Y| MATA103(X,Y)},aCab,aItens,3,.T.)


    If !lMsErroAuto
        lret := .t.
    Else
        lret := .f.
        MostraErro()
    EndIf

    restArea(_xArea)

Return(lret)
