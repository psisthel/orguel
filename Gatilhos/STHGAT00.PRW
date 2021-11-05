#include 'protheus.ch'

/*
Origem: ZD5_INICOB
Destino: FP0_XMEDIN
*/

User Function STHGAT01

    local cAreaCurr := getArea()
    local cContrato := FP0->FP0_PROJET
    local cInicioCobranza := ZD5->ZD5_INICOB

    FPA->(DbSetOrder(4))
    if FPA->(MsSeek(xFilial('FPA')+cContrato))

        FP0->(RecLock('FP0',.f.))

        if cInicioCobranza=='1'
            FP0->FP0_XMEDIN := FPA->FPA_DNFREM
        endif
        if cInicioCobranza=='2'
            FP0->FP0_XMEDIN := FP0->FP0_XDTMON
        endif

        FP0->(MsUnlock())

    endif
    
    restArea(cAreaCurr)

Return

/*
Origem: ZD5_INICOB
Destino: FP0_XMEDFI
*/
User Function STHGAT02

    local cAreaCurr := getArea()
    local cTipoCobranza := ZD5->ZD5_TIPLOC
    local nDias := 1

    If cTipoCobranza == "S"
        nDias := 7
    ElseIf cTipoCobranza == "Q"
        nDias := 15
    ElseIf cTipoCobranza == "M"
        nDias := 30
    EndIf

    FP0->(RecLock('FP0',.f.))
    FP0->FP0_XMEDFI := FP0->FP0_XMEDIN+nDias
    FP0->(MsUnlock())

    restArea(cAreaCurr)

Return
