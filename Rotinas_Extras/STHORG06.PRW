#include "PROTHEUS.CH"

/*
Programa    : STHORG6A
Descricao   : Gatilho para definir o preco unitario por projeto a partir da ZD5
Cliente     : ORGUEL
Campo       : FPA_PRCUNI
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6A()

    local _aArea    := getArea()
    local nDias     := 1

    ZD5->( DbSetOrder(1) )
    if ZD5->( MsSeek(xFilial("ZD5")+FP0->FP0_PROJET, .f.))

        if ZD5->ZD5_TIPLOC=="M"
            nDias := 30
        elseif ZD5->ZD5_TIPLOC=="Q"
            nDias := 15
        elseif ZD5->ZD5_TIPLOC=="S"
            nDias := 7
        endif

    endif

    restArea(_aArea)

Return(nDias)

/*
Programa    : STHORG6B
Descricao   : Gatilho para definir o preco unitario por projeto a partir da ZD5
Cliente     : ORGUEL
Campo       : FPA_DTINI
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6B()

    local _aArea := getArea()
    local _dDtInicio := space(TamSX3("FPA_DTINI")[1])

    ZD5->( DbSetOrder(1) )
    if ZD5->( MsSeek(xFilial("ZD5")+FP0->FP0_PROJET, .f.))

        if ZD5->ZD5_INICOB=="1"
            _dDtInicio := M->FPA_DTREM
        else
            _dDtInicio := ZD5->ZD5_PRVMON
        endif

        _ultFat := U_STHORG6D()
        _dataMon := U_STHORG6C()
        _dataRem := U_STHORG6E()

        FP0->(RecLock('FP0',.F.))
        FP0->FP0_XMEDIN := _dDtInicio
        FP0->FP0_XMEDFI := _dDtInicio + U_STHORG6A()
        FP0->FP0_XDTMON := _dataMon
        FP0->FP0_XPRFAT := _ultFat
        FP0->FP0_XDTREM := _dataRem
        FP0->(MsUnlock())

    endif

    restArea(_aArea)

Return(_dDtInicio)

/*
Programa    : STHORG6C
Descricao   : Gatilho para preenche a Data de Montagem a partir da tabela ZD5
Cliente     : ORGUEL
Campo       : FP0_XDTMON
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6C()

    local _aArea := getArea()
    local _dDtMontagem := space(TamSX3("ZD5_PRVMON")[1])

    ZD5->( DbSetOrder(1) )
    if ZD5->( MsSeek(xFilial("ZD5")+FP0->FP0_PROJET, .f.))

        if !empty(ZD5->ZD5_PRVMON)
            _dDtMontagem := ZD5->ZD5_PRVMON
        endif

        // FP0->(RecLock('FP0',.F.))
        // FP0->FP0_XDTMON := _dDtMontagem
        // FP0->(MsUnlock())

    endif

    restArea(_aArea)

Return(_dDtMontagem)

/*
Programa    : STHORG6D
Descricao   : Gatilho para preenche o periodo de faturamento FP0 a partir da tabela FPA (FPA_ULTFAT)
Cliente     : ORGUEL
Campo       : FP0_XPRFAT
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6D()

    local _aArea := getArea()
    local _dDtUltFaturamento := stod(space(8))
    local cQuery := ""
    local cnewAlias := getNextAlias()

	cQuery := "SELECT FPA_PROJET,MAX(FPA_ULTFAT) FPA_ULTFAT"
	cQuery += "  FROM " + RetSQLName("FPA")
	cQuery += " WHERE FPA_FILIAL ='" + xFilial("FPA") + "'" 
	cQuery += "   AND D_E_L_E_T_= ''"
    cQuery += "   AND FPA_ULTFAT<>''"
    cQuery += "   AND FPA_PROJET='"+FP0->FP0_PROJET+"'"
    cQuery += " GROUP BY FPA_PROJET"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cnewAlias,.T.,.T.)

	if (cnewAlias)->( !eof() )
        if !empty((cnewAlias)->FPA_ULTFAT)
            _dDtUltFaturamento := stod((cnewAlias)->FPA_ULTFAT)
        endif
    endif

    (cnewAlias)->(DBCloseArea())

    restArea(_aArea)

Return(_dDtUltFaturamento)


/*
Programa    : STHORG6E
Descricao   : Gatilho para preenche o periodo de faturamento FP0 a partir da tabela FPA (FPA_DNFREM)
Cliente     : ORGUEL
Campo       : FP0_XDTREM
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6E()

    local _aArea := getArea()
    local _dDtUltRemision := stod(space(8))
    local cQuery := ""
    local xnewAlias := getNextAlias()

	cQuery := "SELECT FPA_PROJET,MAX(FPA_DNFREM) FPA_DNFREM"
	cQuery += "  FROM " + RetSQLName("FPA")
	cQuery += " WHERE FPA_FILIAL ='" + xFilial("FPA") + "'" 
	cQuery += "   AND D_E_L_E_T_= ''"
    cQuery += "   AND FPA_DNFREM<>''"
    cQuery += "   AND FPA_PROJET='"+FP0->FP0_PROJET+"'"
    cQuery += " GROUP BY FPA_PROJET"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),xnewAlias,.T.,.T.)

	if (xnewAlias)->( !eof() )
        if !empty((xnewAlias)->FPA_DNFREM)
            _dDtUltRemision := stod((xnewAlias)->FPA_DNFREM)
        endif
    endif

    (xnewAlias)->(DBCloseArea())

    restArea(_aArea)

Return(_dDtUltRemision)


/*
Programa    : STHORG6F
Descricao   : Gatilho para preencher o campo FPA_CONPAG a partir da ZD5 (ZD5_CONPAG)
Cliente     : ORGUEL
Campo       : FPA_CONPAG
Author      : Percy Arias
Data        : 6/10/2021
*/

User Function STHORG6F()

    local _aArea := getArea()
    local cCondPag := CriaVar("ZD5_CONPAG")
    local cProjeto := FP0->FP0_PROJET

    ZD5->( DbSetOrder(1) )
    if ZD5->( MsSeek(xFilial("ZD5")+cProjeto, .f.))
        cCondPag := ZD5->ZD5_CONPAG
    endif

    if !empty(cCondPag)
        FPA->( DbSetOrder(4) )
        if FPA->( MsSeek(xFilial("FPA")+cProjeto, .f.))
            
            while FPA->( xFilial("FPA")+cProjeto == FPA->FPA_FILIAL+FPA->FPA_PROJET )

                FPA->(RecLock("FPA",.f.))
                FPA->FPA_CONPAG := cCondPag
                FPA->(MsUnlock())

                FPA->(DBSkip())
            end

        endif
    endif

    restArea(_aArea)

Return(.T.)
