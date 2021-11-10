/*/{PROTHEUS.DOC} LOCA010.PRW
ITUP BUSINESS - TOTVS RENTAL
ROTINA PARA GERAR PEDIDO DE VENDA E NOTA FISCAL DE REMESSA
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/12/2020
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

USER FUNCTION OrgLoc31(LROMANEIO)
	LOCAL   AAREA      := GETAREA()

//PRIVATE _LROMANEIO := .F. 
	PRIVATE _LTUDOOK   := .F.
	PRIVATE CAVISO     := ""
	PRIVATE CPROJET    := FP0->FP0_PROJET
	PRIVATE _CFILAUX   // FRANK 07/10/2020 - FILIAL PARA GERACAO DA NOTA DE REMESSA SEM SER VIA ROMANEIO

	DEFAULT LROMANEIO  := .F.

// --> SÓ GERA QUANDO O TIPO DE SERVIÇO É LOCAÇÃO.
	IF FP0->FP0_TIPOSE != "L"
		CAVISO := "ESTA ROTINA É PARA GERAR REMESSA DO contrato  DE LOCAÇÃO !"
		MSGINFO(CAVISO , OEMTOANSI("RENTAL - ORGLOC31.PRW"))
		RETURN
	ENDIF

// --> VALIDA SE EXISTE MESMO O CLIENTE PADRÃO DO PROJETO.
	SA1->(DBSETORDER(1))
	IF !SA1->( DBSEEK(XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA) )
		CAVISO := "ATENÇÃO: NÃO ENCONTRADO CLIENTE: "+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA
		MSGINFO(CAVISO , OEMTOANSI("RENTAL - ORGLOC31.PRW"))
		RETURN
	ENDIF

	_LROMANEIO := LROMANEIO
	IF MSGYESNO(OEMTOANSI("DESEJA GERAR NF DE REMESSA PARA ESTE PROJETO ?"),"GERA REMESSA")
		PROCESSA({|| GERPED() } , "PROCESSANDO..." , "AGUARDE..." , .T.)
		IF _LTUDOOK
			MSGINFO(CAVISO , OEMTOANSI("RENTAL - ORGLOC31.PRW"))
		ELSE
			MSGALERT(CAVISO , OEMTOANSI("RENTAL - ORGLOC31.PRW"))
		ENDIF
	ENDIF
	RestArea(aArea)
RETURN NIL





// ======================================================================= \\
STATIC FUNCTION NFREMLB(_aRemessa)
// ======================================================================= \\
// --> ROTINA PARA MOVIMENTAÇÃO DE BEM EM LOTE.

	LOCAL CRECNO    := ""
	LOCAL LRET      := .F.

	CRECNO := VERFAM(_AREMESSA)
	IF ITENSPED(CRECNO,.T.)
		LRET := .T.
	ENDIF

RETURN {LRET , CRECNO}



// ======================================================================= \\
STATIC FUNCTION VERFAM(_AARRAY)
// ======================================================================= \\

	LOCAL NX     := 0
	LOCAL CRECNO := "("

	FOR NX:=1 TO LEN(_AARRAY)
			CRECNO += IIF(LEN(CRECNO)<=1 , ALLTRIM(STR(_AARRAY[NX])), ","+ALLTRIM(STR(_AARRAY[NX])))
	NEXT NX
	CRECNO += ")"

RETURN CRECNO



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GERPED    º AUTOR ³ IT UP BUSINESS     º DATA ³ 01/09/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ PROGRAMA QUE GERA PEDIDO E FATURA O PROJETO DA ZA0         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GERPED()

	LOCAL AAREASC5   := SC5->(GETAREA())
	LOCAL AAREASC6   := SC6->(GETAREA())
	LOCAL AAREADA3   := DA3->(GETAREA())
	LOCAL AAREASA1	 := SA1->(GETAREA())
	LOCAL _NX        := 0
	LOCAL AAREAATU   := {}
	LOCAL AAREAST9   := {}
	Local _cAviso2   := ""
	Local aRemessa   := {}

	PRIVATE _CPEDIDO	:= ""
	PRIVATE _CNOTA		:= ""
	PRIVATE	LNFREMLB    := SUPERGETMV("MV_LOCX216",.F.,.T.) 	// PARÂMETRO PARA ATIVAR O LISTBOX QUE PERMITE SELECIONAR OS ITENS PARA REMESSA
	PRIVATE	LNFREMBE	:= SUPERGETMV("MV_LOCX215",.F.,.F.)
	PRIVATE	_CDESTIN 	:= SUPERGETMV("MV_LOCX059",.F.,"")		// LISTA DOS E-MAILS QUE RECEBERÃO A SOLICITAÇÃO DE TRANSMISSÃO DA DANFE
	PRIVATE	LMSERROAUTO := .F.
	PRIVATE CPROJETO	:= SUPERGETMV("MV_LOCX248",.F.,"PROJETO")
	PRIVATE LCLIOBRA	:= SUPERGETMV("MV_LOCX204",.F.,.T.)
	PRIVATE ADADOSNF	:= {}
	PRIVATE CNUMSC5     := ""
    PRIVATE aListFQ3       := {}

	LNFREMBE := .T. // FIXO POR FRANK PARA FUNCIONAMENTO DA TROCA DE FILIAIS 07/10/2020

	_LTUDOOK := .F.

    if GERNFINSU()

		FPA->(dbSetOrder(1))
		FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
		While !FPA->(Eof()) .and. FPA->FPA_PROJET == FP0->FP0_PROJET
			If FPA->FPA_PRCUNI == 0
				If !empty(_cAviso2)
					_cAviso2 += "; "
				ENDIF
				_cAviso2 += alltrim(FPA->FPA_PRODUT)
			EndIF
			FPA->(dbSkip())
		EndDo
		If !empty(_cAviso2)
			MsgAlert("Os seguintes produtos estão com o valor unitário zerado: "+_cAviso2,"Atenção !")
			RETURN
		EndIF
		
	// --> VERIFICA SE EXISTE O STATUS '20' CADASTRADO - MESMA VALIDAÇÃO DO SF2460I.PRW 
		AAREAATU := GETAREA()
		AAREAST9 := ST9->(GETAREA())
		AAREATQY := TQY->(GETAREA())

		DBSELECTAREA("ST9")														// --> TABELA...: BEM
		DBSETORDER(1) 															// --> INDICE 01: T9_FILIAL + T9_CODBEM

		DBSELECTAREA("TQY")														// --> TABELA...: STATUS DO BEM
		DBSETORDER(1) 															// --> INDICE 01: TQY_FILIAL + TQY_STATUS

		RESTAREA(AAREATQY)
		RESTAREA(AAREAST9)
		RESTAREA(AAREAATU)
		// Processar a lista e emitindo uma nota por romaneio Selecionado
		_nX := 1
		cRomaneio := ""
		aRemessa  := {}

		for _nX := 1 to Len(aListFQ3)
			if aListFQ3[_nX, 1] // 	
				Aadd(aRemessa, aListFQ3[_nX, 17 ])
			EndIF
		next 

		if Len(aRemessa) > 0	
			Nota(aRemessa)
		EndIF

	EndIF

RESTAREA(AAREASC5) 
RESTAREA(AAREASC6) 
RESTAREA(AAREADA3) 
RESTAREA(AAREASA1) 


Return

Static Function Nota(aRemessa) // Emitir a nota para o Romaneio Selecionado

LOCAL ACAMPOSSC5 := {}
LOCAL ACAMPOSSC6 := {}
	LOCAL CTESRF     := SUPERGETMV("MV_LOCX084"  ,.F.,"509")
	LOCAL CTESLF     := SUPERGETMV("MV_LOCX083",.F.,"503")
	LOCAL CSERIE     := SUPERGETMV("MV_LOCX201",.F.,"001")
	LOCAL CNATUREZ   := SUPERGETMV("MV_LOCX066",.F.,"300000")
Local cItem := "00"	
LOCAL _LCVAL     := SUPERGETMV("MV_LOCX051",.F.,.T.)
LOCAL CVEICULO   := ""
Local aRecFQ3    := {}
Local nX
Local _NV
Local nY
Local cLocal :=  SuperGetMv("IT_LOCALDL",.F.,"DL")

	IF LNFREMLB
		ANFREMLB := NFREMLB(aRemessa)
		IF ! ANFREMLB[1]
			CAVISO := "EMISSÃO DE NF DE REMESSA CANCELADA!"
			FPATMP->(DBCLOSEAREA())
			RETURN
		ENDIF
	ENDIF
BEGIN TRANSACTION
// Realizar a Quebra da FPA quando a quantidade do Romaneio for menor que a quantidade do Item do Contrato

	U_QbrFpa()

SA1->(dbSetOrder(1))
// FRANK 07/10/20 - TRATAMENTO DA FILIAL PARA GERACAO DO PV E NFS
// O VALOR DEFAULT É A FILIAL ABERTA NO SISTEMA.
	
	DBSELECTAREA("FP1")
	WHILE ! FPATMP->(EOF())

		CTESLF 	 := If( Empty(FPATMP->FPA_XTESRE), CTESLF   , FPATMP->FPA_XTESRE) // TES se existir na FPA usar da FPA
		CNATUREZ := If( Empty(FPATMP->FPA_XNATRE), CNATUREZ , FPATMP->FPA_XNATRE) // Natureza se existir na FPA usar da FPA
		_CARMAZEM := FPATMP->B1_LOCPAD 
		FQ3->(dbGoto(FPATMP->RECNOFQ3))

		// Retirar a Reserva para Poder Faturar
		if !Empty(FQ3->FQ3_XRESERV)
    		U_EmpRoma( FQ3->FQ3_XRESERV, 3,  FQ3->FQ3_NUM, FQ3->FQ3_PROD, cLocal, FQ3->FQ3_QTD )
		endif

		// --> POSICIONA E VALIDA O CADASTRO CLIENTE ATRAVÉS DO CLIENTE.
		FP1->(DBSETORDER(1))
		IF FP1->(MSSEEK( XFILIAL("FP1") + FPATMP->FPA_PROJET + FPATMP->FPA_OBRA)) 			// --> VALIDA SE TEM CLIENTE NA OBRA ATRAVÉS DA FPA
			IF EMPTY(FP1->FP1_CLIORI) .OR. EMPTY(FP1->FP1_LOJORI)
				IF LCLIOBRA 		// --> PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
					CAVISO := "ATENÇÃO: O PROJETO "+ ALLTRIM(FPATMP->FPA_PROJET) + " ESTÁ SEM CLIENTE PARA A OBRA: " + FPATMP->FPA_OBRA
					DisarmTransaction()
					Break
					RETURN
				ELSE
					IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
						CAVISO := "ATENÇÃO: NÃO ENCONTRADO CLIENTE: "+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA
						DisarmTransaction()
						Break
						RETURN
					ENDIF
				ENDIF
			ELSE
				IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP1->FP1_CLIORI + FP1->FP1_LOJORI)) 	// --> VALIDA SE O CLIENTE DA OBRA EXISTE
					IF LCLIOBRA 	// --> PARAMETRO QUE VERIFICA SE FATURA PELO ZA1 OU PELO ZA0
						CAVISO := "ATENÇÃO: NÃO ENCONTRADO CLIENTE: "+ FP1->FP1_CLIORI + "/" + FP1->FP1_LOJORI
						DisarmTransaction()
						Break
						RETURN
					ELSE
						IF ! SA1->(MSSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA))
							CAVISO := "ATENÇÃO: NÃO ENCONTRADO CLIENTE: "+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA
							DisarmTransaction()
							Break
							RETURN
						ENDIF
					ENDIF
				ENDIF
			ENDIF
		ELSE
			CAVISO := "ATENÇÃO: NÃO ENCONTRADA OBRA: " + ALLTRIM(FPATMP->FPA_OBRA)
			DisarmTransaction()
			Break
			RETURN
		ENDIF

		// --> CRIA ARRAY PARA O CABEÇALHO.
		IF LEN(ACAMPOSSC5) == 0 	// .OR. (CFILAUX <> FPATMP->FILTRAB .AND. LNFREMBE)
			_CTXT := "OBRA: "      + ALLTRIM(FP1->FP1_NOMORI) + CRLF
			_CTXT += "ENDERECO: "  + ALLTRIM(FP1->FP1_ENDORI) + CRLF
			_CTXT += "BAIRRO: "    + ALLTRIM(FP1->FP1_BAIORI) + CRLF
			_CTXT += "MUNICIPIO: " + ALLTRIM(FP1->FP1_MUNORI) + CRLF
			_CTXT += "ESTADO: "    + ALLTRIM(FP1->FP1_ESTORI) + CRLF

			IF ! EMPTY(FP1->FP1_CEIORI)
				_CTXT += "CEI: "   + ALLTRIM(FP1->FP1_CEIORI) + CRLF
			ENDIF

			// --> PONTO DE ENTRADA PARA ADICIONAR MAIS TEXTO NA VARIÁVEL _CTXT
			IF EXISTBLOCK("GRVC5OBS")
				_CTXT += EXECBLOCK("GRVC5OBS",.T.,.T.,{_CTXT, IIF(LNFREMBE, FPATMP->FILTRAB,FPATMP->FPA_FILIAL)})
			ENDIF

			_CFILNEW := xFilial("SC5")

			If !empty(FPATMP->FPA_FILEMI)
				_CFILNEW := FPATMP->FPA_FILEMI
			EndIF

			ACAMPOSSC5 := {}
			CNUMSC5 := XSC5NUM()
			
			//AADD(ACAMPOSSC5     , {"C5_FILIAL"  , IIF(LNFREMBE, FPATMP->FILTRAB,FPATMP->FPA_FILIAL), XA1ORDEM("C5_FILIAL"	) } )
			AADD(ACAMPOSSC5     , {"C5_FILIAL"  , _CFILNEW            , XA1ORDEM("C5_FILIAL"	) } ) // FRANK EM 07/10/2020
			AADD(ACAMPOSSC5     , {"C5_NUM"     , CNUMSC5             , XA1ORDEM("C5_NUM")     } )
			AADD(ACAMPOSSC5     , {"C5_TIPO"    , "N"                 , XA1ORDEM("C5_TIPO")    } )
			IF LCLIOBRA
				AADD(ACAMPOSSC5 , {"C5_CLIENTE"	, SA1->A1_COD         , XA1ORDEM("C5_CLIENTE") } )
				AADD(ACAMPOSSC5 , {"C5_LOJACLI"	, SA1->A1_LOJA        , XA1ORDEM("C5_LOJACLI") } )
			ELSE
				AADD(ACAMPOSSC5 , {"C5_CLIENTE" , FP0->FP0_CLI        , XA1ORDEM("C5_CLIENTE") } )
				AADD(ACAMPOSSC5 , {"C5_LOJACLI" , FP0->FP0_LOJA	      , XA1ORDEM("C5_LOJACLI") } )
			ENDIF
			AADD(ACAMPOSSC5     , {"C5_CLIENT"   , SA1->A1_COD	      , XA1ORDEM("C5_CLIENT")  } )
			AADD(ACAMPOSSC5     , {"C5_LOJAENT"  , SA1->A1_LOJA	      , XA1ORDEM("C5_LOJAENT") } )
			AADD(ACAMPOSSC5     , {"C5_TIPOCLI"  , SA1->A1_TIPO	      , XA1ORDEM("C5_TIPOCLI") } )
			AADD(ACAMPOSSC5     , {"C5_DESC1"    , 0			      , XA1ORDEM("C5_DESC1")   } )
			AADD(ACAMPOSSC5     , {"C5_DESC2"    , 0	              , XA1ORDEM("C5_DESC2")   } )
			AADD(ACAMPOSSC5     , {"C5_DESC3"    , 0		          , XA1ORDEM("C5_DESC3")   } )
			AADD(ACAMPOSSC5     , {"C5_DESC4"    , 0		          , XA1ORDEM("C5_DESC4")   } )
			AADD(ACAMPOSSC5     , {"C5_TPCARGA"  , "1"			      , XA1ORDEM("C5_TPCARGA") } )
			AADD(ACAMPOSSC5     , {"C5_CONDPAG"  , FPATMP->FPA_CONPAG , XA1ORDEM("C5_CONDPAG") } )
			AADD(ACAMPOSSC5     , {"C5_TPFRETE"  , "F"   	          , XA1ORDEM("C5_TPFRETE") } )
			AADD(ACAMPOSSC5     , {"C5_VOLUME1"  , 1     	          , XA1ORDEM("C5_VOLUME1") } )
			AADD(ACAMPOSSC5     , {"C5_ESPECI1"  , "MAQUINA"          , XA1ORDEM("C5_ESPECI1") } )
			AADD(ACAMPOSSC5     , {"C5_PESOL"    , 0 			      , XA1ORDEM("C5_PESOL")   } )
			AADD(ACAMPOSSC5     , {"C5_PBRUTO"	 , 0 			      , XA1ORDEM("C5_PBRUTO")  } )
			AADD(ACAMPOSSC5     , {"C5_NATUREZ"  , CNATUREZ           , XA1ORDEM("C5_NATUREZ") } )
			// removido da 94
			//IF SC5->(FIELDPOS("C5_OBSNF"))   > 0
			//	AADD(ACAMPOSSC5 , {"C5_OBSNF"    , _CTXT	          , XA1ORDEM("C5_OBSNF")   } )
			//ENDIF
			IF SC5->(FIELDPOS("C5_XPROJET")) > 0
				AADD(ACAMPOSSC5 , {"C5_XPROJET"  , CPROJET		      , XA1ORDEM("C5_XPROJET") } )
			ENDIF
			IF SC5->(FIELDPOS("C5_XTIPFAT")) > 0
				AADD(ACAMPOSSC5 , {"C5_XTIPFAT"  , "R"		          , XA1ORDEM("C5_XTIPFAT") } )
			ENDIF
			IF SC5->(FIELDPOS("C5_XOBRA"))   > 0
				AADD(ACAMPOSSC5 , {"C5_XOBRA"    , FP1->FP1_OBRA      , XA1ORDEM("C5_XOBRA")   } )
			ENDIF
			IF SC5->(FIELDPOS("C5_OBRA"))    > 0
				AADD(ACAMPOSSC5 , {"C5_OBRA"     , FP1->FP1_OBRA      , XA1ORDEM("C5_OBRA")    } )
			ENDIF
		ENDIF

		// --> CRIA ARRAY PARA OS ITENS DO PEDIDO.
		_CDESCRI := ALLTRIM(FPATMP->B1_DESC)
		_CDESCRI += " ("+ ALLTRIM(FPATMP->FPA_GRUA)
		_CDESCRI += IIF(! EMPTY(FPATMP->T9_SERIE), " - " + ALLTRIM(FPATMP->T9_SERIE) + ")" , ")" )

		AITENS := {}

		CITEM := SOMA1(CITEM)
		CITEM := IIF(LEN(CITEM)==1 , "0"+CITEM , CITEM)
		// --> CRIA ARRAY PARA OS ITENS
		//AADD(AITENS,{"C6_FILIAL"	, IIF(LNFREMBE, FPATMP->FILTRAB, FPATMP->FPA_FILIAL), XA1ORDEM("C6_FILIAL")}) 	// FILIAL
		AADD(AITENS,{"C6_FILIAL"	, _CFILNEW                          , XA1ORDEM("C6_FILIAL")}) 	// FILIAL - FRANK 07/10/2020
		AADD(AITENS,{"C6_ITEM"		, CITEM                             , XA1ORDEM("C6_ITEM"   )}) 					// ITENS
		AADD(AITENS,{"C6_NUM"		, CNUMSC5                           , XA1ORDEM("C6_NUM"    )}) 					// NUMERO DO PEDIDO
		AADD(AITENS,{"C6_PRODUTO"	, SUBSTR(FPATMP->FPA_PRODUT,1,15)	, XA1ORDEM("C6_PRODUTO")}) 					// MATERIAL
		AADD(AITENS,{"C6_UM"		, FPATMP->B1_UM                     , XA1ORDEM("C6_UM"     )}) 					// UNIDADE DE MEDIDA
		AADD(AITENS,{"C6_DESCRI"	, _CDESCRI                          , XA1ORDEM("C6_DESCRI" )}) 					// DESCRIÇÃO DO PRODUTO
		IF EXISTBLOCK("GERREMTES") 						// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
			CTESLF := EXECBLOCK("GERREMTES",.T.,.T.,{CTESLF})
		ENDIF
		AADD(AITENS,{"C6_TES"		, CTESLF                            , XA1ORDEM("C6_TES"    )}) 					// TES
		AADD(AITENS,{"C6_ENTREG"	, DDATABASE 						, XA1ORDEM("C6_ENTREG" )}) 					// DATA DA ENTREGA
		AADD(AITENS,{"C6_DESCONT"	, 0                                 , XA1ORDEM("C6_DESCONT")}) 					// PERCENTUAL DE DESCONTO
		AADD(AITENS,{"C6_COMIS1"	, 0                                 , XA1ORDEM("C6_COMIS1" )}) 					// COMISSAO VENDEDOR
		IF LCLIOBRA
			AADD(AITENS,{"C6_CLI"	, SA1->A1_COD                       , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
			AADD(AITENS,{"C6_LOJA"	, SA1->A1_LOJA                      , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
		ELSE
			AADD(AITENS,{"C6_CLI"	, FP0->FP0_CLI                      , XA1ORDEM("C6_CLI"    )}) 					// CLIENTE
			AADD(AITENS,{"C6_LOJA"	, FP0->FP0_LOJA                     , XA1ORDEM("C6_LOJA"   )}) 					// LOJA DO CLIENTE
		ENDIF
		IF FPATMP->VALREM > 0
			NVALPROD := NOROUND(FPATMP->VALREM ,2)
		ELSE
			IF FPATMP->B1_PRV1 > 0
				NVALPROD := NOROUND(FPATMP->B1_PRV1,2)
			ELSE
				NVALPROD := 0
			ENDIF
		ENDIF
		IF NVALPROD <= 0
			CAVISO := "O ITEM '" + ALLTRIM(FPATMP->FPA_PRODUT) + "' ESTÁ COM O VALOR ZERADO." + CRLF + "FAVOR VERIFICAR O CADASTRO DE PRODUTO (B1_PRV1) OU CADASTRO DO BEM (T9_VALCPA), SE FOR O CASO! "
			DisarmTransaction()
			Break
			RETURN
		ENDIF

		// --> CASO PERTENÇA AO GRUPO QUE É CADASTRADO NO PARÂMETRO PERMITE A OPÇÃO DE SELECIONAR O ARMAZÉM COM SALDO
			_NQTD := FPATMP->FQ3_QTD

			AADD(AITENS,{"C6_QTDVEN"	, _NQTD					, XA1ORDEM("C6_QTDVEN"	)}) // QUANTIDADE
			AADD(AITENS,{"C6_PRCVEN"	, NVALPROD				, XA1ORDEM("C6_PRCVEN"	)}) // PRECO DE VENDA / VALOR FRETE
			AADD(AITENS,{"C6_PRUNIT"	, NVALPROD				, XA1ORDEM("C6_PRUNIT"	)}) // PRECO UNITÁRIO / VALOR FRETE
			AADD(AITENS,{"C6_VALOR"	    , NVALPROD*_NQTD		, XA1ORDEM("C6_VALOR"	)}) // VALOR TOTAL DO ITEM
			AADD(AITENS,{"C6_QTDLIB"	, _NQTD					, XA1ORDEM("C6_QTDLIB"	)}) // QUANTIDADE LIBERADA
			AADD(AITENS,{"C6_LOCAL"		, _CARMAZEM				, XA1ORDEM("C6_LOCAL"	)}) // ARMAZEM PADRAO
		
		IF LEN(ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE")))) > GETSX3CACHE("C6_VALOR","X3_TAMANHO")
			CAVISO := "O TAMANHO DOS CAMPOS DE VALORES DO PEDIDO DE VENDA SÃO INFERIORES A " + CVALTOCHAR(LEN(ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE"))))) + ". NÃO SENDO POSSÍVEL GERAR O PEDIDO DE VENDA COM VALOR " + ALLTRIM(TRANSFORM(NVALPROD*_NQTD,GETSX3CACHE("C6_VALOR","X3_PICTURE"))) + "."
			FPATMP->(DBCLOSEAREA())
			RESTAREA(AAREASC5)
			RESTAREA(AAREASC6)
			RESTAREA(AAREADA3)
			RESTAREA(AAREASA1)
			DisarmTransaction()
			Break
			RETURN
		ENDIF

		IF SC6->(FIELDPOS( "C6_XCCUSTO" )) > 0
			AADD(AITENS,{"C6_XCCUSTO"	, FPATMP->FPA_CUSTO		, XA1ORDEM("C6_XCCUSTO"	)}) // CENTRO DE CENTRO FPA
		ENDIF
		IF SC6->(FIELDPOS("C6_XAS")) > 0
			AADD(AITENS,{"C6_XAS"		, FQ3->FQ3_AS		, XA1ORDEM("C6_XAS"		)})  // AS
		ENDIF
		IF SC6->(FIELDPOS("C6_CLVL")) > 0 .AND. _LCVAL
			AADD(AITENS,{"C6_CLVL"		, FQ3->FQ3_AS 		, XA1ORDEM("C6_CLVL"	)})  // CLASSE DE VALOR
		ENDIF
		IF SC6->(FIELDPOS("C6_XBEM")) > 0
			AADD(AITENS,{"C6_XBEM"		, FPATMP->FPA_GRUA		, XA1ORDEM("C6_XBEM"	)})  // BEM
		ENDIF
		IF SC6->(FIELDPOS("C6_NUMSERI")) > 0
			AADD(AITENS,{"C6_NUMSERI"	,FPATMP->FPA_GRUA       , XA1ORDEM("C6_NUMSERI"	)})  // CHAPA
		ENDIF

		AADD(ACAMPOSSC6, AITENS )

		// --> VERIFICA SE EXISTE UM VEÍCULO NAS LINHAS DA FPA PARA ADICIONAR NO CABEÇALHO.
		IF EMPTY(CVEICULO)  .AND.  !EMPTY(FPATMP->FPA_PLACAI)
			DA3->(DBSETORDER(3))
			IF DA3->( DBSEEK(XFILIAL("DA3") + FPATMP->FPA_PLACAI) )
				CVEICULO := DA3->DA3_COD
			ENDIF
		ENDIF
		
		aadd(aRecFQ3 , FPATMP->RECNOFQ3)

		IF EXISTBLOCK("GERREFLOG") 						// --> PONTO DE ENTRADA PARA ALTERAÇÃO DA TES.
			EXECBLOCK("GERREFLOG",.T.,.T.,{FPATMP->FPA_GRUA, NVALPROD, FPATMP->FPA_PRODUT})
		ENDIF

		FPATMP->(DBSKIP())

	ENDDO

// --> CASO TENHA ALGUM VEÍCULO INSERE NO CABEÇALHO DO PEDIDO. 
	IF ! EMPTY(CVEICULO)
		AADD( ACAMPOSSC5, {"C5_VEICULO"	, CVEICULO, XA1ORDEM("C5_VEICULO") } )
	ENDIF

	IF EXISTBLOCK("GERREMC5")
		ACAMPOSSC5 := U_GERREMC5( ACAMPOSSC5 )
	ENDIF

// --> ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO
	ASORT(ACAMPOSSC5,,,{|X,Y| X[3]<Y[3]})
// --> TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
	FOR _NV := 1 TO LEN(ACAMPOSSC5)
		ACAMPOSSC5[_NV][3] := NIL
	NEXT _NV

// --> ACERTO DO ARRAY DE ITENS
	FOR NY := 1 TO LEN(ACAMPOSSC6)
		// ORDENA O ARRAY DO CABEÇALHO DE ACORDO COM A ORDEM DO CAMPO
		ASORT(ACAMPOSSC6[NY],,,{|X,Y| X[3]<Y[3]})
		// TRANSFORMA A ORDEM DO CAMPO EM NULO PARA RESPEITAR O PADRÃO DO EXECAUTO
		FOR _NV := 1 TO LEN(ACAMPOSSC6[NY])
			ACAMPOSSC6[NY][_NV][3] := NIL
		NEXT _NV
	NEXT NY

// --> TRATATIVAS PARA A GERAÇÃO DO PEDIDO DE VENDA. 
	_NPFILC6 := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_FILIAL"})
	_NPITC6  := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_ITEM"})
	_NPNUMC6 := ASCAN(ACAMPOSSC6[1],{|X| ALLTRIM(X[1])=="C6_NUM"})
	_NPFILC5 := ASCAN(ACAMPOSSC5   ,{|X| ALLTRIM(X[1])=="C5_FILIAL"})
	_NPNUMC5 := ASCAN(ACAMPOSSC5   ,{|X| ALLTRIM(X[1])=="C5_NUM"})
	CFILAUX  := CFILANT
//	BEGIN TRANSACTION

	
	IF ! EMPTY(CNUMSC5)
		// --> GRAVA USANDO O EXECAUTO
		PROCESSA({|| EXECPV(ACAMPOSSC5,ACAMPOSSC6,LNFREMBE) }, "PROCESSANDO PEDIDO DE VENDA " + CNUMSC5, "AGUARDE...", .T.)
		IF EMPTY(_CPEDIDO)
			RollBackSX8()
			CAVISO := "NÃO FOI POSSÍVEL GERAR O PEDIDO DE VENDA PARA O " + SUPERGETMV("MV_LOCX248",.F.,"PROJETO") + " "+ALLTRIM(CPROJET)+" !" + CRLF
			DISARMTRANSACTION()
			Break
		ELSE
			ConfirmSX8()
			CAVISO   := "GERADO O PEDIDO DE REMESSA: ["+_CPEDIDO+"]."
	
			// --> GERA A NOTA
			// A PARTIR DE 23/12/2020 EM ALGUNS CASOS A NOTA FISCAL NÃO DEVE SER GERADA LOGO NA SEQUENCIA DO PEDIDO DE VENDAS
			// FRANK 23/12/2020
			IF SUPERGETMV("MV_GERNFS",,.T.)
				PROCESSA({|| GRAVANFS( _CPEDIDO,CTESRF,CTESLF,CSERIE ) } , "PROCESSANDO NF P/ O PEDIDO DE VENDA " + _CPEDIDO , "AGUARDE..." , .T.)
				IF EMPTY( _CNOTA )
					CAVISO := "NÃO FOI POSSÍVEL FATURAR O PEDIDO DE REMESSA ["+_CPEDIDO+"]"
					DISARMTRANSACTION()
					Break
				ELSE
						// FRANK 04/11/20 - GRAVAR NA FQ3 O NÚMERO DA NOTA DE REMESSA GERADA.
						//_AFPA := FPA->(GETAREA())
						//_AFQ3 := FQ3->(GETAREA())
					_CNOTAX  := SF2->F2_DOC
					_CSERIEX := SF2->F2_SERIE

					for nX := 1 to len(aRecFQ3)
						dbSelectArea("FQ3")
						if aRecFQ3[nX] > 0
							dbGoto(aRecFQ3[nX])
							FQ3->(RECLOCK("FQ3",.F.))
							FQ3->FQ3_NFREM	:= _CNOTAX
							FQ3->FQ3_SERREM	:= _CSERIEX
							FQ3->(MSUNLOCK())
						ENDIF
					next
											
					IF EXISTBLOCK("GERREMFIM") 		// --> PONTO DE ENTRADA NO FINAL DA GERAÇÃO DA NOTA FISCAL DE REMESSA.
						EXECBLOCK("GERREMFIM",.T.,.T.,{_CNOTA,_CPEDIDO,ACAMPOSSC5,ACAMPOSSC6})
					ENDIF
					_LTUDOOK := .T.
					CAVISO   := "GERADO O PEDIDO DE REMESSA: ["+_CPEDIDO+"]." +CRLF + "GERADA A NF DE REMESSA: ["+_CNOTA+"] !"
				ENDIF
			ENDIF
		ENDIF


		CFILANT := CFILAUX
	ELSE
		CAVISO := "NÃO EXISTEM ITENS APTOS A GERAR NF DE REMESSA, FAVOR SELECIONAR OUTRA REMESSA."
	ENDIF

END TRANSACTION
	
ADADOSNF   := {}
ACAMPOSSC5 := {}
ACAMPOSSC6 := {}
AITENS     := {}

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ XSC5NUM   º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VALIDA O PRÓXIMO NUMERO DO PV					          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION XSC5NUM()
Local CNUMSC5

	CNUMSC5	:= GETSXENUM("SC5","C5_NUM")
	WHILE .T.
		IF SC5->( DBSEEK(XFILIAL("SC5") + CNUMSC5) )
			CONFIRMSX8()
			CNUMSC5 := GETSXENUM("SC5","C5_NUM")
			LOOP
		ELSE
			EXIT
		ENDIF
	ENDDO

RETURN CNUMSC5



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ EXECPV    º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ GERA O PEDIDO DE VENDA PARA O PROJETO POSICIONADO          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION EXECPV(_ACABEC , _AITENS , LNFREMBE)

	IF LEN(_ACABEC) > 0 .AND. LEN(_AITENS) > 0
		INCPROC("AGUARDE... GERANDO PEDIDO DE VENDA E FATURANDO...")
		MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)} , _ACABEC , _AITENS , 3)
		IF LMSERROAUTO
			MOSTRAERRO()
			ROLLBACKSX8()
			RETURN .F.
		ELSE
			_CPEDIDO := CNUMSC5
			CONFIRMSX8()
			IF RECLOCK("SC5",.F.)
				SC5->C5_ORIGEM := "GERNFREM"
				SC5->(MSUNLOCK())
			ENDIF
		ENDIF
	ELSE
		MSGSTOP("NAO EXISTEM REGISTROS PARA GERAÇÃO DO CONTRATO!" , "RENTAL - ORGLOC31.PRW")
		RETURN .F.
	ENDIF

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GRAVANFS  º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ LIBERA O PEDIDO E GERA O DOCUMENTO (NOTA FISCAL) DE SAIDA  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GRAVANFS( _CPEDIDO , CTESRF , CTESLF , CSERIE )

	LOCAL AAREAANT  := GETAREA()
	LOCAL AAREASC5  := SC5->(GETAREA())
	LOCAL AAREASC6  := SC6->(GETAREA())
	LOCAL AAREASC9  := SC9->(GETAREA())
	LOCAL AAREASE4  := SE4->(GETAREA())
	LOCAL AAREASB1  := SB1->(GETAREA())
	LOCAL AAREASB2  := SB2->(GETAREA())
	LOCAL AAREASF4  := SF4->(GETAREA())
	LOCAL APVLNFS   := {}
	LOCAL CROT      := ""
	LOCAL CQUERY
	LOCAL CALIASQRY := GETNEXTALIAS()
//LOCAL AITENS  := {}

	CROT := PROCNAME()

	PERGUNTE("MT460A",.F.)

	SC5->( DBSETORDER(1) ) //C5_FILIAL + C5_NUM
	SC6->( DBSETORDER(1) ) //C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	SC9->( DBSETORDER(1) ) //C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO

	CQUERY   := " SELECT DISTINCT C5_NUM "
	CQUERY   += " FROM "+RETSQLNAME("SC5")+" SC5 (NOLOCK) "
	CQUERY   += "        JOIN "+RETSQLNAME("SC6")+ " SC6 (NOLOCK) ON C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM "
	CQUERY   += " WHERE  C5_FILIAL  =  '"+XFILIAL("SC5")+"' "
	CQUERY   += "   AND  C5_NUM     =  '"+ _CPEDIDO +"' "
	CQUERY   += "   AND  C5_XPROJET =  '"+CPROJET+"' "
	CQUERY   += "   AND  C6_NOTA    =  '' "
	CQUERY   += "   AND  C6_BLOQUEI =  '' "
//CQUERY += "   AND  C6_TES     IN ('"+CTESLF+"','"+CTESRF+"') "
	CQUERY   += "   AND  SC5.D_E_L_E_T_ = '' "
	CQUERY   += "   AND  SC6.D_E_L_E_T_ = '' "
	CONOUT("[GERNFREM.PRW] # CQUERY(1): " + CQUERY)
	CQUERY := CHANGEQUERY(CQUERY)
	DBUSEAREA(.T.,"TOPCONN", TCGENQRY(,,CQUERY),CALIASQRY, .F., .T.)

	WHILE ! (CALIASQRY)->( EOF() )
		_CPEDIDO := (CALIASQRY)->C5_NUM
		IF SC5->( MSSEEK(XFILIAL("SC5") + _CPEDIDO, .F. ) )
			IF SC9->( DBSEEK( XFILIAL("SC9")+_CPEDIDO ) )
				WHILE !SC9->(EOF()) .AND. SC9->C9_PEDIDO == _CPEDIDO
					IF SC6->( DBSEEK( XFILIAL("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_PRODUTO ) )

						SE4->(DBSETORDER(1))
						SE4->( MSSEEK(XFILIAL("SE4") + SC5->C5_CONDPAG, .F. ) )

						// --> POSICIONA NO PRODUTO
						SB1->(DBSETORDER(1))
						SB1->( MSSEEK(XFILIAL("SB1") + SC6->C6_PRODUTO, .F. ) )

						// --> POSICIONA NO SALDO EM ESTOQUE
						SB2->(DBSETORDER(1))
						SB2->( MSSEEK(XFILIAL("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL, .F. ) )

						// --> POSICIONA NO TES
						CTES := SC6->C6_TES
						SF4->(DBSETORDER(1))
						SF4->( MSSEEK(XFILIAL("SF4") + CTES, .F. ) )

						_NPRCVEN := SC9->C9_PRCVEN

						// --> MONTA ARRAY PARA GERAR A NOTA FISCAL
						AADD( APVLNFS , { SC9->C9_PEDIDO   , ;
							SC9->C9_ITEM     , ;
							SC9->C9_SEQUEN   , ;
							SC9->C9_QTDLIB   , ;
							_NPRCVEN         , ;
							SC9->C9_PRODUTO  , ;
							.F.              , ;
							SC9->( RECNO() ) , ;
							SC5->( RECNO() ) , ;
							SC6->( RECNO() ) , ;
							SE4->( RECNO() ) , ;
							SB1->( RECNO() ) , ;
							SB2->( RECNO() ) , ;
							SF4->( RECNO() ) } )
					ENDIF
					SC9->(DBSKIP())
				ENDDO
			ENDIF
		ENDIF
		(CALIASQRY)->(DBSKIP())
	ENDDO
	(CALIASQRY)->(DBCLOSEAREA())

	DBSELECTAREA("SC9")

	IF ! EMPTY(APVLNFS)
		CONOUT("GERANDO NOTA FISCAL DE SAIDA")
		_CNOTA := MAPVLNFS(APVLNFS , CSERIE , .F. , .F. , .F. , .T. , .F. , 0 , 0 , .T. , .F.)
		CONOUT("NOTA FISCAL: "+_CNOTA)
		IF SD2->D2_PEDIDO == _CPEDIDO  .AND.  SD2->D2_DOC == _CNOTA
			ADADOSNF := {SD2->D2_PEDIDO , SD2->D2_ITEMPV , SD2->D2_DOC , SD2->D2_SERIE}
		ELSE
			// ADCIONAR UMA BUSCA PARA VERIFICAR SE O PEDIDO EXISTE EM ALGUMA NOTA DA TABELA, CASO DESPOSICIONE....
		ENDIF
	ENDIF

	IF SF2->(FIELDPOS("F2_IT_ROMA")) > 0
		IF RECLOCK("SF2",.F.)
			SF2->F2_IT_ROMA := FQ2->FQ2_NUM	// RECEBE NUMERO DO ROMANEIO.
			SF2->(MSUNLOCK())
		ENDIF
	ENDIF

// --> RETORNA AS AREAS ORIGINAIS
	RESTAREA( AAREASF4 )
	RESTAREA( AAREASB2 )
	RESTAREA( AAREASB1 )
	RESTAREA( AAREASE4 )
	RESTAREA( AAREASC9 )
	RESTAREA( AAREASC6 )
	RESTAREA( AAREASC5 )
	RESTAREA( AAREAANT )

RETURN






/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ XA1ORDEM  º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA A ORDEM DOS CAMPOS NO X3				          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION XA1ORDEM(CCAMPO)

	LOCAL AAREASX3 := SX3->(GETAREA())

	SX3->(DBSETORDER(2))
	SX3->(DBSEEK(CCAMPO))
	CRET := SX3->X3_ORDEM

	RESTAREA(AAREASX3)

RETURN CRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ NFREMBE   º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA AS FILIAIS EXISTENTES NO CAMPO T9_CENTRAB         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION NFREMBE(ANFREMLB)
	LOCAL _AAREA 		:= GETAREA()
	LOCAL AFILS 		:= {}
	LOCAL _LENCONTRA 	:= .F.
	LOCAL _NX
	LOCAL _CTEMP

	_CTEMP := STRTRAN(ANFREMLB[2],"(","")
	_CTEMP := STRTRAN(_CTEMP,")","")
	_CTEMP := VAL(_CTEMP)
	FPA->(DBGOTO(_CTEMP))
	IF FPA->(EOF())
		_CFILAUX := CFILANT
	ELSE
		_CFILAUX := FPA->FPA_FILEMI
	ENDIF
	AADD( AFILS, _CFILAUX)

	RESTAREA(_AAREA)
RETURN AFILS



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ ITENSPED  º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ VERIFICA AS FILIAIS EXISTENTES NO CAMPO T9_CENTRAB         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION ITENSPED(CRECNO , LTRUE)

	LOCAL LRET := .F.

	IF SELECT("FPATMP") > 0
		FPATMP->(DBCLOSEAREA())
	ENDIF

	CQUERY     := " SELECT DISTINCT "
	CQUERY     += "        FPA_PROJET , FPA_FILIAL , FPA_PRODUT , FPA_PREDIA , FPA_VRHOR  , FPA_AS , FPA_FILEMI , " + CRLF
	CQUERY     += "        FPA_VRHOR * FPA_PREDIA HORPREDIA , FPA_XTESRE, FPA_XNATRE, FPA_UNIDIA,"                               + CRLF
	CQUERY     += "        ISNULL(ST9.T9_VALCPA  , 0 )                         VALREM     , " + CRLF
	CQUERY     += "        FPA_GRUA   , FPA_OBRA   , FPA_SEQGRU , FPA_AS     , FPA_CACAMB , FQ3_QTD , FPA_CONPAG  , " + CRLF
	CQUERY     += "        FPA_CARAC  , FPA_CUSTO  , FPA_PLACAI , FPA_NFREM  , FPA_NFRET  , FPA.R_E_C_N_O_ RECNOFPA , " + CRLF
	CQUERY     += "        ISNULL(SUBSTRING(ST9.T9_CENTRAB,1,4),FPA_FILIAL) FILTRAB       , " + CRLF
	CQUERY     += "        ISNULL(ST9.T9_NOME    , B1_DESC)                    T9_NOME    , " + CRLF
	CQUERY     += "        ISNULL(ST9.T9_CODFAMI , '')                         T9_CODFAMI , " + CRLF
	CQUERY     += "        ISNULL(ST9.T9_SERIE   , '')                         T9_SERIE   , " + CRLF
	CQUERY     += "        ISNULL(ST9.T9_VALCPA  , 0 )                         T9_VALCPA  , " + CRLF
	CQUERY     += "        ISNULL(SHB.HB_NOME    , '')                         HB_NOME    , " + CRLF
	CQUERY     += "        B1_DESC    , B1_PRV1    , B1_UM      , B1_LOCPAD  , B1_GRUPO   , " + CRLF
	CQUERY     += "        ISNULL(ST9.T9_CENTRAB , FPA_FILIAL)                 T9_CENTRAB , "   + CRLF
	CQUERY     += "        FQ3.R_E_C_N_O_ RECNOFQ3 "   + CRLF
	CQUERY     += " FROM "+RETSQLNAME("FPA")+" FPA " + CRLF

		CQUERY += "        INNER JOIN "+RETSQLNAME("FQ3")+" FQ3 ON  FQ3.FQ3_FILIAL  = FPA.FPA_FILIAL       AND  FQ3.FQ3_PROJET  =  FPA.FPA_PROJET " + CRLF
	//	CQUERY += "                                             AND FQ3.FQ3_VIAGEM  = FPA.FPA_VIAGEM  "
		CQUERY += "                                             AND  FQ3.FQ3_OBRA    =  FPA.FPA_OBRA   " + CRLF
		CQUERY += "                                             AND FQ3.FQ3_AS      = FPA.FPA_AS           AND  FQ3.D_E_L_E_T_ =  '' "             + CRLF
        CQUERY +=                                       "   AND  FQ3.R_E_C_N_O_ IN "+CRECNO+" "           + CRLF
        CQUERY += "        INNER JOIN "+RETSQLNAME("FQ2")+" FQ2 ON  FQ3.FQ3_FILIAL  = FQ2.FQ2_FILIAL        AND  FQ3.FQ3_NUM     =  FQ2.FQ2_NUM "     + CRLF
		CQUERY += "                                             AND FQ3.FQ3_ASF     = FQ2.FQ2_ASF           AND  FQ2.D_E_L_E_T_ =  '' "             + CRLF

	CQUERY     += "        INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_COD     = FPA.FPA_PRODUT       AND  SB1.D_E_L_E_T_ = '' "              + CRLF
//	CQUERY     += "        INNER JOIN "+RETSQLNAME("FQ5")+" FQ5 ON  FQ5.FQ5_AS     = FPA.FPA_AS           AND  FQ5.FQ5_STATUS =  '6' "            + CRLF
//	CQUERY     += "                                             AND FQ5.FQ5_GUINDA = FPA_GRUA             AND  FQ5.D_E_L_E_T_ =  '' "             + CRLF
	CQUERY     += "        LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 ON  ST9.T9_CODBEM  = FPA.FPA_GRUA         AND  ST9.T9_CODBEM  <> '' "             + CRLF
	CQUERY     += "                                             AND ST9.D_E_L_E_T_ = '' "                                                         + CRLF
	CQUERY     += "        LEFT  JOIN "+RETSQLNAME("SHB")+" SHB ON  SHB.HB_FILIAL  = '"+XFILIAL("SHB")+"' AND  SHB.HB_COD     =  ST9.T9_CENTRAB " + CRLF
	CQUERY     += "                                             AND SHB.D_E_L_E_T_ = '' "                                                         + CRLF
	CQUERY     += " WHERE  FPA.FPA_FILIAL =  '"+XFILIAL("FPA")+"' " + CRLF
	CQUERY     += "   AND  FPA.FPA_PROJET =  '"+CPROJET       +"' " + CRLF
	CQUERY     += "   AND  FPA.FPA_AS     <> ''  "                  + CRLF
	CQUERY     += "   AND  FPA.FPA_TIPOSE =  'L' "                  + CRLF
	CQUERY     += "   AND  FPA.D_E_L_E_T_ =  '' "                   + CRLF
	CQUERY     += " ORDER BY FPA.FPA_OBRA , FPA.FPA_SEQGRU "        + CRLF
	CONOUT("[GERNFREM.PRW] # CQUERY(3): " + CQUERY)
	CQUERY := CHANGEQUERY(CQUERY)
//MEMOWRITE("C:\ERRONANFREM.SQL", CQUERY) 
	TCQUERY CQUERY NEW ALIAS "FPATMP"

	FPATMP->(DBGOTOP())

	IIF( FPATMP->(EOF()) , LRET := .F. , LRET := .T. )

RETURN LRET



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ VLDLPAD   º AUTOR ³ IT UP BUSINESS     º DATA ³ 04/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ IDENTIFICA OS LOCAIS COM SALDO PARA O PRODUTO              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION VLDLPAD( _NQTD )

	LOCAL   ARET      := {}
	LOCAL   LLOCPAD   := SUPERGETMV("MV_LOCX214",.F.,.T.) // .T. = INNER JOIN PARA UTILIZAR APENAS ARMAZÉM PADRÃO OU .F. = LEFT JOIN PARA UTILIZAR QUALQUER ARMAZÉM DISPONÍVEL.
	LOCAL   CLOCPAD   := IIF(LLOCPAD , "INNER" , "LEFT")
	LOCAL   _CARMAZEM := ""

	DEFAULT _NQTD     := FPATMP->FPA_QUANT

	IF SELECT("TRBSB2") > 0
		TRBSB2->(DBCLOSEAREA())
	ENDIF
	_CQUERY := " SELECT ISNULL(B1_LOCPAD,'') B1_LOCPAD , B2_LOCAL , B2_QATU " + CRLF
	_CQUERY += " FROM " + RETSQLNAME("SB2") + " SB2 "                         + CRLF
	_CQUERY += "      "+CLOCPAD+" JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_FILIAL  = '" + XFILIAL("SB1") + "' " + CRLF
	_CQUERY += "                                                 AND SB1.B1_COD     = B2_COD  AND  SB1.B1_LOCPAD = B2_LOCAL " + CRLF
	_CQUERY += "                                                 AND SB1.D_E_L_E_T_ = '' " + CRLF
	_CQUERY += " WHERE  B2_FILIAL = '" + XFILIAL("SB2") + "'      " + CRLF
	_CQUERY += "   AND  B2_COD    = '" + FPATMP->FPA_PRODUT + "'  " + CRLF
	_CQUERY += "   AND  B2_QATU	 >= '" + STR(_NQTD) + "'          " + CRLF
	_CQUERY += "   AND  B2_LOCAL <> ''                            " + CRLF
	_CQUERY += "   AND  SB2.D_E_L_E_T_ = ''                       " + CRLF
	_CQUERY += " ORDER BY B1_LOCPAD DESC , B2_QATU DESC , B2_LOCAL "
	CONOUT("[GERNFREM.PRW] # _CQUERY(4): " + _CQUERY)
	_CQUERY := CHANGEQUERY(_CQUERY)
	TCQUERY _CQUERY NEW ALIAS "TRBSB2"

	TRBSB2->(DBGOTOP())

	IF TRBSB2->(!EOF())
		WHILE TRBSB2->(!EOF())
			IF EMPTY(_CARMAZEM)
				_CARMAZEM := TRBSB2->B2_LOCAL
				EXIT
			ENDIF
			TRBSB2->(DBSKIP())
		ENDDO
		IF ! EMPTY(_CARMAZEM)
			ARET := {.T.,_CARMAZEM}
		ELSE
			ARET := {.F.,_CARMAZEM}
		ENDIF
	ELSE
		ARET := {.F.,_CARMAZEM}
	ENDIF
	TRBSB2->(DBCLOSEAREA())

RETURN ARET



// ======================================================================= \\
STATIC FUNCTION QTDENV( _CAS )
// ======================================================================= \\

	LOCAL   _AAREAOLD := GETAREA()
	LOCAL   _NRET     := .T.
	LOCAL   _CQUERY   := ""

	IF SELECT("TRBQTD") > 0
		TRBQTD->(DBCLOSEAREA())
	ENDIF
	_CQUERY := " SELECT SUM(C6_QTDVEN) QTD" + CRLF
	_CQUERY += " FROM " + RETSQLNAME("SC6") + " SC6 (NOLOCK) " + CRLF
	_CQUERY += "        INNER JOIN " + RETSQLNAME("SC5") + " SC5 (NOLOCK) ON  SC5.C5_FILIAL  = '" + XFILIAL("SC5") + "' "              + CRLF
	_CQUERY += "                                                          AND SC5.C5_NUM     = SC6.C6_NUM  AND  SC5.C5_XTIPFAT = 'R' " + CRLF
	_CQUERY += "                                                          AND SC5.D_E_L_E_T_ = '' "                                    + CRLF
	_CQUERY += " WHERE  SC6.C6_FILIAL  =  '" + XFILIAL("SC6") + "' " + CRLF
	_CQUERY += "   AND  SC6.C6_XAS     =  '" + _CAS + "' "           + CRLF
	_CQUERY += "   AND  SC6.C6_XAS     <> '' "                       + CRLF
	_CQUERY += "   AND  SC6.C6_BLQ NOT IN ('R','S') "                + CRLF
	_CQUERY += "   AND  SC6.D_E_L_E_T_ =  '' "
	CONOUT("[GERNFREM.PRW] # _CQUERY(5): " + _CQUERY)
	_CQUERY := CHANGEQUERY(_CQUERY)
	TCQUERY _CQUERY NEW ALIAS "TRBQTD"

	IF TRBQTD->(!EOF())
		_NRET := TRBQTD->QTD
	ENDIF

	TRBQTD->(DBCLOSEAREA())

	RESTAREA( _AAREAOLD )

RETURN _NRET


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ GERNFINSU º AUTOR ³ IT UP BUSINESS     º DATA ³ 11/04/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ PROGRAMA QUE GERA PEDIDO E FATURA DE INSUMOS               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION GERNFINSU()

LOCAL   AAREASC5	:= SC5->(GETAREA())
LOCAL   AAREASC6	:= SC6->(GETAREA())
LOCAL   AAREADA3	:= DA3->(GETAREA())
LOCAL   AAREASA1	:= SA1->(GETAREA())
LOCAL   ACAMPOSSC5  := {}
LOCAL   ACAMPOSSC6  := {}
LOCAL	CTESRF		:= SUPERGETMV("MV_LOCX084",.F.,"509")
LOCAL	CTESLF		:= SUPERGETMV("MV_LOCX083",.F.,"503")
LOCAL	CSERIE		:= SUPERGETMV("MV_LOCX201",.F.,"001")
LOCAL	CNATUREZ	:= SUPERGETMV("MV_LOCX066",.F.,"300000")
LOCAL	CGRPAND		:= ""
LOCAL 	_CDESCRI	:= ""
LOCAL	NPOS		:= 0
LOCAL	CFILAUX		:= ""
LOCAL   AITENS      := {}
LOCAL   _CQUERY     := ""
LOCAL   CITEM		:= "0"
LOCAL   OOK         := LOADBITMAP(GETRESOURCES(),"LBOK")
LOCAL   ONO         := LOADBITMAP(GETRESOURCES(),"LBNO") 
LOCAL   oConf       := LOADBITMAP(GETRESOURCES(),"BR_VERDE")
LOCAL   oNoConf     := LOADBITMAP(GETRESOURCES(),"BR_VERMELHO")

LOCAL   NJANELAA    := 385 
LOCAL   NJANELAL    := 1103
LOCAL   NLBTAML	    := 540	
LOCAL   NLBTAMA	    := 155	
LOCAL   LMARK       := .F.
LOCAL   NI          := 0 
LOCAL   NV          := 0
LOCAL   NZ          := 0 
LOCAL   NX          := 0 
Local   nOpc        := 0

Local   bLinha 

PRIVATE _CPEDIDO	:= ""
PRIVATE _CNOTA		:= ""
PRIVATE	LNFREMBE	:= SUPERGETMV("MV_LOCX215",.F.,.F.)
PRIVATE	_CDESTIN 	:= SUPERGETMV("MV_LOCX059",.F.,"")		// LISTA DOS E-MAILS QUE RECEBERÃO A SOLICITAÇÃO DE TRANSMISSÃO DA DANFE
PRIVATE	LMSERROAUTO := .F.
PRIVATE CPROJETO	:= SUPERGETMV("MV_LOCX248",.F.,"PROJETO")
PRIVATE LCLIOBRA	:= SUPERGETMV("MV_LOCX204",.F.,.T.)
PRIVATE ADADOSNF	:= {}
PRIVATE CNUMSC5     := ""
PRIVATE OFILOS       
PRIVATE ODLGFIL             
PRIVATE LTODOS      := .F.             

IF SBM->(FIELDPOS("BM_XACESS")) > 0
	CGRPAND := LOCA00189()
ELSE
	CGRPAND := SUPERGETMV("MV_LOCX014",.F.,"")
ENDIF

// --> SÓ GERA QUANDO O TIPO DE SERVIÇO É LOCAÇÃO.
IF FP0->FP0_TIPOSE != "L"
	CAVISO := "ESTA ROTINA É PARA GERAR REMESSA DE " + CPROJETO + " DE LOCAÇÃO !" 
	RETURN
ENDIF

// --> VALIDA SE EXISTE MESMO O CLIENTE PADRÃO DO PROJETO.
SA1->(DBSETORDER(1))
IF !SA1->( DBSEEK( XFILIAL("SA1") + FP0->FP0_CLI + FP0->FP0_LOJA  ) )
	CAVISO := "ATENÇÃO: CLIENTE: "+ FP0->FP0_CLI + "/" + FP0->FP0_LOJA+" NÃO ENCONTRADO !!!" 
	RETURN
ENDIF

SetArrFq2()

IF Len(aListFQ3)  = 0 
	CAVISO := "ATENÇÃO: Não existem itens a serem enviados !" 
	RETURN .f.
endif

bLinha := {|| { IF( aListFQ3[OFILOS:NAT, 1], OOK, ONO),;   // CHECKBOX
						  IF( aListFQ3[OFILOS:NAT,18] = 'S', oConf, oNoConf),;
							  aListFQ3[OFILOS:NAT, 2],;   	 	   // ROMANEIO	
							  aListFQ3[OFILOS:NAT, 3],;            // ASF
							  aListFQ3[OFILOS:NAT, 5],;            // PRODUTO
							  aListFQ3[OFILOS:NAT, 6],;            // DESC. PRODUTO
							  aListFQ3[OFILOS:NAT, 7]}}            // QUANTIDADE

DEFINE MSDIALOG ODLGFIL TITLE "ITENS NF REMESSA ROMANEIO" FROM 010,005 TO NJANELAA,NJANELAL PIXEL//OF OMAINWND
    @ 0.5,0.7 LISTBOX OFILOS FIELDS HEADER  " ","Conf","NUM ROMANEIO","ASF","PRODUTO", "DESC. PRODUTO", "QUANTIDADE" SIZE NLBTAML,NLBTAMA ON DBLCLICK (MARCARREGI(.F.))
    OFILOS:SETARRAY(aListFQ3)
    OFILOS:BLINE := bLInha
	
	@ 170,010 BUTTON OFILBUT PROMPT "Confirma Romaneio" SIZE 55,12 OF ODLGFIL PIXEL ; 
	                 ACTION ( if (U_OrgLoc34(aListFQ3[OFILOS:NAT, 2]), (SetArrFQ2(), OFILOS:SETARRAY(aListFQ3),OFILOS:BLINE := bLInha, oFilos:nAt := 1, oFilos:Refresh()),) ) 
	@ 170,070 BUTTON OFILBUT PROMPT "Gera NF Remessa" SIZE 55,12 OF ODLGFIL PIXEL ; 
	                 ACTION (   NOPC := 1 , ODLGFIL:END() ) 

    @ 170,130 BUTTON   OCANBUT PROMPT "CANCELAR"             SIZE 55,12 OF ODLGFIL PIXEL ACTION (NOPC := 0, ODLGFIL:END())
	   	
	@ 170,190 CHECKBOX LTODOS  PROMPT "MARCA/DESMARCA TODOS" SIZE 80,10 OF ODLGFIL PIXEL ON CLICK MARCARREGI(.T.)
ACTIVATE MSDIALOG ODLGFIL CENTERED
    
IF NOPC == 0
    CAVISO := "EMISSÃO DA NF REMESSA INSUMO CANCELADA PELO USUÁRIO !" + CRLF
    RETURN .F.
ENDIF

if FP0->FP0_STASS $ "A" // Contrato assinado
	IF MSGYESNO(OEMTOANSI("DESEJA MESMO GERAR NF REMESSA PARA OS ITENS SELECIONADOS?") , "GPO - ORGLOC31.PRW")		                            
   		for nX := 1 to Len(aListFQ3)
   	    	if aListFQ3[nX,  1] 
       		    REturn .T. // Há um item para emitir
       		EndIF
   		next
	endif	
else
	cAviso := "Contrato ainda não foi assinado não se pode gerar remessa. Aguarde a assinatura do contrato"
	return .F.
endif

Return .F. // Algo falhou e naõ deverá ser emitida
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPROGRAMA  ³ MARCARREGIº AUTOR ³ IT UP BUSINESS     º DATA ³ 30/06/2007 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDESCRICAO ³ FUNÇÃO AUXILIAR DO LISTBOX, SERVE PARA MARCAR E DESMARCAR  º±±
±±º          ³ OS ITENS.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUSO       ³ ESPECIFICO GPO                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION MARCARREGI(LTODOS)

LOCAL NI        := 0 
LOCAL LMARCADOS := aListFQ3[OFILOS:NAT, 1]
Local cRomaneio := aListFQ3[OFILOS:NAT, 2] 
Local nX
// Desmarcar/Marcar todos os Itens do Romeneio

IF LTODOS
	LMARCADOS := ! LMARCADOS
	FOR NI := 1 TO LEN(aListFQ3)
		if aListFQ3[ni, 18 ] = 'S'
			aListFQ3[NI,1] := LMARCADOS
		endif
	NEXT NI 
ELSE
    for nX := 1 to Len(aListFQ3)
        if aListFQ3[nX , 2] = cRomaneio .and. aListFQ3[nx, 18 ] = 'S'
	        aListFQ3[nX, 1] := !LMARCADOS
        EndIF
		
    next nx
ENDIF

OFILOS:REFRESH()
ODLGFIL:REFRESH()
	
RETURN NIL

/*/{Protheus.doc} QbrFpa
Faz a quebra da FPA conforme as linhas do Romaneio
@type function
@author Alexandre Circenis
@since 28/09/2021
@return nil, Não há retorno esperado
/*/
User Function QbrFpa()
Local nSaldo := 0 
Local nCntFor
Local bCampo  := {|x| FieldName(x) }
Local cItem   :=  U_fRetSeq(, 2, FPATMP->FPA_OBRA)
Local nDiasBase
Local aOrigem :={} // ASS Origem. REcno Destino
Local cASOld
Local nPosOrig := 0

dbSelectArea("ZD5")
dbSeek(xFilial("ZD5")+cProjet)

if ZD5->ZD5_TIPLOC = "D"
	nDiasBase := 1
elseif ZD5->ZD5_TIPLOC = "S"
	nDiasBase := 7
elseif ZD5->ZD5_TIPLOC = "Q"
	nDiasBase := 15
else
	nDiasBase := 30
endif

dbSelectArea("FPATMP")
dbGotop()
While !Eof()

	nPosOrig := 0

	dbSelectArea("FPA")
	dbGoto(FPATMP->RECNOFPA) // Posiciona na FPA - Original do Romaneio
	if Len(aOrigem) > 0 .and. (nPosOrig := Ascan(aOrigem, {|x| x[1] = FPA->FPA_AS})) > 0
		dbGoto(aOrigem[nPosOrig, 2]) // Posiciona na ultima linha da divisão da FPA
	endif
	
	if FPA->FPA_QUANT  > FPATMP->FQ3_QTD  // Quantidade do Contrato acima do Liberado no Romaneio 
		// Preparar para quebra de linha
		nSaldo := FPA->FPA_QUANT - FPATMP->FQ3_QTD
		// Copiar o Registro
		RegtoMemory("FPA", .F.)
		RecLock("FPA",.F.)
		FPA->FPA_QUANT  := FPATMP->FQ3_QTD
		FPA->FPA_PESTOT := FPA->FPA_PESPAD + FPATMP->FQ3_QTD
		FPA->FPA_VRHOR  := FPATMP->FQ3_QTD * FPATMP->FPA_UNIDIA * nDiasBase
		FPA->FPA_XQROMA := FPATMP->FQ3_QTD
		msUnlock()
		cASOld := M->FPA_AS
		// Preparar os dados para Dividir as Linhas da FPA
		M->FPA_XQROMA -= FPATMP->FQ3_QTD // Atualiza a Quantidade em Romaneio
		M->FPA_XASORI := M->FPA_AS  // Preserva no Numero da AS de Origem
		M->FPA_AS     := " "     
		M->FPA_VIAGEM := " "
		M->FPA_QUANT  := nSaldo		
		M->FPA_SEQGRU := cItem
		M->FPA_NFREM  := " "
		M->FPA_DNFREM := Ctod("")		
		M->FPA_PEDIDO := " "
		M->FPA_SERREM := " "
		M->FPA_ITEREM := " "
		M->FPA_PESTOT := M->FPA_PESPAD * nSaldo
		M->FPA_XSALDO := 0
		M->FPA_VRHOR  := nSaldo	* FPATMP->FPA_UNIDIA * nDiasBase
		RecLock("FPA", .T. ) // Incluir um novo item de Comtrato
		For nCntFor := 1 To FCount()
			If ( "FILIAL"$Field(nCntFor) )
				FPA->(FieldPut(nCntFor,xFilial("FPA")))
			Else
				FPA->(FieldPut(nCntFor,M->&(EVAL(bCampo,nCntFor))))
			EndIf

		Next nCntFor
		msUnlock()
		// Armazena qual a nova linha da FPA que substituiu a linha Original

		// Gerar numero da AS para a nova linha	
		aRet := LOCA013AUT(xFilial("FPA"), M->FPA_PROJET, M->FPA_OBRA, cItem, .F., .F., {}, .F.)

		if nPosOrig = 0
			Aadd( aOrigem, {cASOld, FPA->(Recno()), FPA->FPA_AS})
		else
			aOrigem[ nPosOrig, 2] := FPA->(Recno())
			aOrigem[ nPosOrig, 3] := FPA->FPA_AS
		endif

		// Atualiza para a Proxima Linha
		cItem := Soma1(cItem)

	endif
	
	if nPosOrig > 0 // Indica que houve uma quebra anterior atualizar a FQ3 com no numero da AS da linha criada
		dbSelectArea("FQ3")
		dbGoto(FPATMP->RECNOFQ3)
		REcLock("FQ3",.F.)
		FQ3->FQ3_AS := aOrigem[ nPosOrig, 3] // Usar a AS da linha quebrada 
		msUnlock()
	endif
	
	dbSelectArea("FPATMP")
	dbSkip()

enddo

dbSelectArea("FPATMP")
dbGotop()

Return NIL



Static Function SetArrFQ2()
Local _cQuery := ""

// --> FUNÇÃO PARA SELEÇÃO DO ITENS DO PROJETO SELECIONADO.
_CQUERY += " SELECT FQ3.FQ3_FILIAL, FQ3.FQ3_NUM, FQ3_ITEM, FQ3.FQ3_ASF, FQ3.FQ3_ORDEM, FQ3.FQ3_PROD, SB1.B1_COD, FQ3.FQ3_QTD, FQ3.R_E_C_N_O_ FQ3REC "
_CQUERY +=      " , FPA.FPA_PROJET, FPA.FPA_OBRA,  FPA.R_E_C_N_O_ FPAREC , FQ3.FQ3_CODBEM, FQ3.FQ3_DESPRO, SB1.B1_LOCPAD"
_CQUERY +=      " , SB1.B1_UM, SB1.B1_PRV1, FPA.FPA_CUSTO, FPA.FPA_CONPAG,  SB1.R_E_C_N_O_ SB1REC, FQ2_CONFIR"

_CQUERY += " FROM "+RETSQLNAME("FQ3")+" FQ3 " 
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FQ2")+" FQ2 ON FQ2.FQ2_FILIAL = '"+xFilial("FQ2")+"' and FQ3.FQ3_NUM = FQ2.FQ2_NUM  AND FQ2_TPROMA = '0' AND FQ2.D_E_L_E_T_ = '' "
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FQ5")+" FQ5 ON FQ5.FQ5_FILIAL = '"+xFilial("FQ5")+"' and FQ3.FQ3_ASF = FQ5.FQ5_AS   AND FQ5.D_E_L_E_T_ = '' "
_CQUERY +=        " INNER JOIN "+RETSQLNAME("FPA")+" FPA ON FPA.FPA_FILIAL = '"+xFilial("FPA")+"' and FPA.FPA_AS  = FQ3.FQ3_AS   AND FPA.D_E_L_E_T_ = '' " 
_CQUERY +=        " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' and SB1.B1_COD   = FQ3.FQ3_PROD AND SB1.D_E_L_E_T_ = '' " 
_CQUERY += " WHERE FQ3.FQ3_FILIAL = '"+xFilial("FQ3")+"'" 
_CQUERY += "   AND  FQ3.D_E_L_E_T_ =  '' "
_CQUERY += "   AND  FQ3.FQ3_PROJET  =  '"+FP0->FP0_PROJET+"' "
_CQUERY += "   AND  FQ3.FQ3_NFREM   =  '' "
_CQUERY += "   AND  FQ3.FQ3_SERREM  =  '' "
_cQuery += "   AND NOT EXISTS ( SELECT ZDL_STATUS FROM "+RETSQLNAME("ZDL")+" ZDL "
_CQUERY +=                 "   WHERE  ZDL_FILIAL = '"+xFIlial("ZDL")+"'"
_CQUERY +=                 "   AND  ZDL_NUM =  FQ3.FQ3_NUM "
_CQUERY +=                 "   AND  ZDL_STATUS = '1' " // Há solicitações em aberto no Fluig
_CQUERY +=                 "   AND  D_E_L_E_T_ = ' ' "
_CQUERY +=                 "  ) "
_cQuery += " ORDER BY FQ3_FILIAL, FQ3_NUM, FQ3_ITEM"

IF SELECT("TRBFQ3") > 0
	TRBFQ3->(DBCLOSEAREA())
ENDIF
TCQUERY _CQUERY NEW ALIAS "TRBFQ3"

TRBFQ3->(DBGOTOP())

aListFQ3 := {}
WHILE TRBFQ3->(!EOF())
    AADD(aListFQ3, {.F. , TRBFQ3->FQ3_NUM, TRBFQ3->FQ3_ASF   , TRBFQ3->FQ3_ORDEM, TRBFQ3->FQ3_PROD , TRBFQ3->FQ3_DESPRO,; 
                    	  TRBFQ3->FQ3_QTD, TRBFQ3->FPA_PROJET, TRBFQ3->FPA_OBRA , TRBFQ3->FPAREC   , TRBFQ3->B1_UM     ,; 
                    	  TRBFQ3->B1_PRV1, TRBFQ3->B1_LOCPAD , TRBFQ3->SB1REC   , TRBFQ3->FPA_CUSTO, TRBFQ3->FPA_CONPAG,;
				    	  TRBFQ3->FQ3REC , FQ2_CONFIR    })
    TRBFQ3->(DBSKIP())
ENDDO
     
TRBFQ3->(DBCLOSEAREA())

Return 

