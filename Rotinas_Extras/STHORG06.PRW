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
    if ZD5->( MsSeek(xFilial("ZD5")+FPA->FPA_PROJET, .f.))

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
    if ZD5->( MsSeek(xFilial("ZD5")+FPA->FPA_PROJET, .f.))

        if ZD5->ZD5_INICOB=="1"
            _dDtInicio := FPA->FPA_DTREM
        else
            _dDtInicio := ZD5->ZD5_PRVMON
        endif

    endif

    restArea(_aArea)

Return(_dDtInicio)
