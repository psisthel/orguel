#include 'protheus.ch'
#include 'parmtype.ch'

#Define MAXGETDAD 99999							// Usado em todos os MsNewGetDados
#Define PASTA_ORCAMENTO 3

User Function LC001ROT()

	local aRotina  := {}
	local aSubRotina := ParamIXB[2]

	MV_LOCX020 := GETMV("MV_LOCX020") 

	IF CNIVEL >= 5

		AADD(AROTINA      , {"Pesquisar"                                             , "AXPESQUI"     , 0 , 1})
		AADD(AROTINA      , {"Visualizar"                                            , "LOCA00110"    , 0 , 2})
		AADD(AROTINA      , {"Gráfico/Status"                                        , "LOCA072"    , 0 , 6})
		AADD(AROTINA      , {"Incluir"                                               , "LOCA00104"    , 0 , 3})
		AADD(AROTINA      , {"Alterar"                                               , "LOCA00103"    , 0 , 6})
		AADD(AROTINA      , {"Legenda"                                               , "LOCA00101"    , 0 , 6})
		AADD(AROTINA      , {"Manutenção"                                            , "LOCA00105(4)" , 0 , 6})
		AADD(AROTINA      , {"Cancelar"                                              , "LOCA00162"    , 0 , 6})
		IF MV_LOCX020
			AADD(AROTINA  , {"Em aprovação"                                          , "LOCA00161"   , 0 , 6})
		ENDIF
		AADD(AROTINA      , {"Cadastros"                                             , aSubRotina      , 0 , 6})
		AADD(AROTINA      , {"Gera Contrato"                                         , "LOCA00173"   , 0 , 6})
		IF SUPERGETMV("MV_LOCX008",.F.,.F.)
			AADD(AROTINA  , {"Gera NF Remessa"                                       , "LOCA010(.F.)"   , 0 , 6})
		ENDIF
		IF SUPERGETMV("MV_LOCX223",,"N") == "S"
			AADD(AROTINA  , {"Emitir Proposta"                                       , "U_LOCI100"    , 0 , 6})
		ENDIF
		IF SUPERGETMV("MV_LOCX206",.F.,.T.)		
		AADD(AROTINA   , {"Copiar"                                                , "LOCA00105(5)" , 0 , 6})
		ENDIF
	ELSE

		AADD(AROTINA      , {"Pesquisar"                                             , "AXPESQUI"     , 0 , 1}) 
		AADD(AROTINA      , {"Visualizar"                                            , "LOCA00110"    , 0 , 2}) 
		AADD(AROTINA      , {"Legenda"                                               , "LOCA00101"    , 0 , 6}) 

	ENDIF

 	aAdd(aRotina      , {"Orcamento"					, "U_ORGLOC05(4)"  , 0 , 6})
 	aAdd(aRotina      , {"Fixar Tabela de Preço" , "U_ORGLOC16()"   , 0 , 6})
 	aAdd(aRotina      , {"Controle de Contrato"	, "U_ORGLOC19()"   , 0 , 6})
 	
	If __cUserID $ SuperGetMV("IT_IMPCNT", .F., "")
		aAdd(aRotina      , {"Imprimir Contrato" 		, "U_ORGLOC24()"   , 0 , 6})
	EndIf

Return aRotina


