#include "PROTHEUS.CH"

User Function STHORG00

    local _cAlias02 := getNextAlias()
    local cQuery := ""

    ZE1->( DbSetOrder(2) )

   	cQuery := "SELECT *"
	cQuery += "  FROM " + RetSQLName("FPA")
	cQuery += " WHERE FPA_FILIAL ='" + xFilial("FPA") + "'" 
	cQuery += "   AND D_E_L_E_T_= ' '"
	cQuery += "   AND FPA_PROJET='" + FP0->FP0_PROJET + "'"
	cQuery += "   AND FPA_XQTRET>0"

	dbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), _cAlias02, .F., .T.)
				
	If (_cAlias02)->( !Eof() )

		While (_cAlias02)->( !Eof() )

			if ZE1->( DBSeek(xFilial("ZE1")+FP0->FP0_PROJET+(_cAlias02)->FPA_PRODUT+(_cAlias02)->FPA_SEQGRU))
				ZE1->(RecLock('ZE1',.f.))
			else
				ZE1->(RecLock('ZE1',.t.))
				ZE1->ZE1_FILIAL	:= xFilial("ZE1")
				ZE1->ZE1_PROJET	:= FP0->FP0_PROJET
				ZE1->ZE1_PRODUT	:= (_cAlias02)->FPA_PRODUT
				ZE1->ZE1_SEQ	:= (_cAlias02)->FPA_SEQGRU
			endif

			ZE1->ZE1_QTDENV	:= (_cAlias02)->FPA_QUANT
			ZE1->ZE1_QTDDEV	:= (_cAlias02)->FPA_XQTRET
			ZE1->ZE1_SALDO	:= ((_cAlias02)->FPA_QUANT - (_cAlias02)->FPA_XQTRET)
			ZE1->ZE1_QTDRET	:= ((_cAlias02)->FPA_QUANT - (_cAlias02)->FPA_XQTRET)
			ZE1->ZE1_VALPRD	:= (_cAlias02)->FPA_PRCUNI
			ZE1->ZE1_VLINDE	:= (_cAlias02)->FPA_VLINPA
			ZE1->ZE1_ACRESC	:= (_cAlias02)->FPA_ACRESC
			ZE1->ZE1_DESCON := (_cAlias02)->FPA_XVLDES

			ZE1->(MsUnlock())

			(_cAlias02)->(dbSkip())

        end

    endif

    (_cAlias02)->(DBCloseArea())

return(.T.)
