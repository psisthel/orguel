#INCLUDE "PROTHEUS.CH"

User Function GERREMFIM

    local cArea := getArea()
	local cNroProjeto := ParamIxb[3][22][2]
	local cAliasFPA := getNextAlias()
	local dMedInicial := ctod(space(8))
	local dDtMontagem := ctod(space(8))
	local nDias := 1

	ZD5->(DbSetOrder(1))
	FP0->(DbSetOrder(1))
	FPA->(DbSetOrder(1))

	if ZD5->(MsSeek(xFilial("ZD5")+cNroProjeto))

		dDtMontagem := ZD5->ZD5_PRVMON

		if FP0->(MsSeek(xFilial("FP0")+cNroProjeto))

			if ZD5->ZD5_TIPLOC == "S"
		        nDias := 7
    		Elseif ZD5->ZD5_TIPLOC == "Q"
        		nDias := 15
    		Elseif ZD5->ZD5_TIPLOC == "M"
        		nDias := 30
    		EndIf

			FP0->(RecLock("FP0",.f.))

			if ZD5->ZD5_INICOB=='1'

				csql := "SELECT MAX(FPA_DNFREM) AS FECHA"
				csql += "  FROM " + RetSqlName("FPA")
				csql += " WHERE FPA_PROJET='" + cNroProjeto + "'"
				csql += "   AND FPA_FILIAL='" + xFilial("FPA") + "'"

				csql := CHANGEQUERY(csql)
				DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,csql),cAliasFPA, .F., .T.)

				FP0->FP0_XMEDIN := STOD((cAliasFPA)->FECHA)
				dMedInicial := STOD((cAliasFPA)->FECHA)

				(cAliasFPA)->(DBCloseArea())

			else

				FP0->FP0_XDTMON := dDtMontagem
				FP0->FP0_XMEDIN := dDtMontagem
				dMedInicial := dDtMontagem

			endif

			FP0->FP0_XMEDFI := dMedInicial+nDias

			FP0->(MsUnlock())

		endif

	endif

	restArea(cArea)

Return
