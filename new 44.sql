USE [ERP_BH_TEST]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
									
CREATE PROCEDURE [ERP.Inventory].[SaveSalesInvoice]
	@SPStatus								INT				OUTPUT, 
	@SalesInvoiceId							BIGINT			OUTPUT,
	@InvoiceNo      						NVARCHAR(50)	OUTPUT,
	@BranchId								INT,
	@SalesInvoiceDate						DATE, 
	@SalesOrderId							BIGINT,
	@ReferenceNo							NVARCHAR(MAX), 
	@CustomerId								BIGINT,
	@CurrencyId								INT,
	@TotalAmount							DECIMAL(24,5),
	@TotalDiscount							DECIMAL(24,5),
	@TotalChargeAmount  					DECIMAL(24,5),
	@NetAmount								DECIMAL(24,5),
	@IsCredit								BIT,
	@TotalAdvanceAmount						DECIMAL(24,5),
	@PaidFromAdvance						DECIMAL(24,5),
	@PaidAmount								DECIMAL(24,5),
	@TermsAndConditionId					INT,
	@StaffId 								INT,
	@InvoiceTypeId							INT,
	@SalesStatusId							VARCHAR(2),
	@PaymentTermsId							INT,
	@DueDate								DATE,
	@DeliveryMethodId						INT,
	@PriceListId							INT,
	@Remarks								NVARCHAR(MAX),  
	@Notes									NVARCHAR(MAX), 
	@CreatedBy								BIGINT,
	@CreatedDate							DATETIME,
	@PaymentMethodId						INT,
	@ChequeNo								VARCHAR(50), 
	@ChequeDate								DATE=NULL,
	@ChequeDetails							VARCHAR(250), 
	@CardNo									VARCHAR(50), 
	@ReceiptAccountId						BIGINT,
	@BankAccountId							BIGINT,
	@ReceiptNotes							VARCHAR(MAX),
	@AccountTransStatus						VARCHAR(1), 
	@IsDirectInvoice						BIT,
	@CostCenterId							INT,
	@ShipmentAddress1						NVARCHAR(500),
	@TaxId									INT,
	@TotalTaxAmount							DECIMAL(24,5),
	@TotalTaxableAmount						DECIMAL(24,5),
	@DeliveryDate							VARCHAR(50),
	@XMLDetails								NVARCHAR(MAX),
	@XMLChargeDetails						NVARCHAR(MAX),
	@XMLGDNs								VARCHAR(MAX),
	@XMLAdvance								VARCHAR(MAX),
	@XMLGDNDetails							NVARCHAR(MAX),
	@XMLGDNBundleDetails					NVARCHAR(MAX),
	@XMLGDNStockDetails						NVARCHAR(MAX),
	--@XMLBatchDetails						NVARCHAR(MAX),
	@XMLGDNBatchDetails						NVARCHAR(MAX),
	@SalesManUserId							BIGINT ,
	@ContactPerson							NVARCHAR(300)='',
	@XMLSalesInvoiceBundleDetails			NVARCHAR(MAX),
	@DiscountType							INT,
	@DiscountPercentage						DECIMAL(24,5),
	@RoundOff								DECIMAL(24,5),
	@PONo									VARCHAR(50),
	@DeliveryPeriod							VARCHAR(200),
	@Type									VARCHAR(2), 
	@CSOId									BIGINT,
	@CSODescription							VARCHAR(MAX),
	@XMLServiceDetails						NVARCHAR(MAX),
	@CurrencyRate							DECIMAL	(24,6),
	@TotalAmountInCustCurrency				DECIMAL	(24,5),
	@TotalDiscountInCustCurrency			DECIMAL	(24,5),
	@TotalChargeAmountInCustCurrency		DECIMAL	(24,5),
	@TotalTaxAmountInCustCurrency			DECIMAL	(24,5),
	@RoundOffInCustCurrency					DECIMAL	(24,5),
	@NetAmountInCustCurrency				DECIMAL	(24,5),
	@TotalAdvanceAmountInCustCurrency		DECIMAL	(24,5),
	@PaidFromAdvanceInCustCurrency			DECIMAL	(24,5),
	@PaidAmountInCustCurrency				DECIMAL	(24,5),
	@VATExempt								BIT,
	--@XMLBOMStockDetails						VARCHAR(MAX),
	@CashCustomerName						NVARCHAR(1000),
	@CashCustomerVATNo						VARCHAR(500),
	@ContractInvoiceId						BIGINT=0,
	@TimeSheetInvoiceId						BIGINT=0,
	@CustAutomobileDetailsId				BIGINT,
	@IsAdjustment							BIT,
	@SubmissionDate							DATETIME,
	@IsMobileAppEntry						BIT=0,
	@XMLMixedReceiptDetails					NVARCHAR(MAX)='',
	@PODate									DATE='',
	@ImpSalesInvoiceId						BIGINT=0,
	@ProjectId								INT=0,
	@XMLProjectDetails						NVARCHAR(MAX)='',
	@IsVATInclusivePrice					BIT=0,
	@AppSerialNo							VARCHAR(500)='',
	@RetentionPercentage					DECIMAL(24,5)=0,
	@RetentionAmount						DECIMAL(24,5)=0,
	@RetentionAmountCustCurrency			DECIMAL(24,5)=0,
	@XMLProjectBillDetails					NVARCHAR(MAX)='',
	@XMLRetentionInvoice					NVARCHAR(MAX)='',
	@InvoiceTypeSlno						INT=0,
	@XMLTimesheet							XML='',
	@DepartmentId							INT=NULL,
	@BankCurrencyId							INT=NULL,
	@BankCurrencyRate						DECIMAL(24,5)=0,
	@TotalAmountInBankCurrency				DECIMAL(24,5)=0,
	@IsSummary								BIT=0,
	@Description							VARCHAR(MAX)='',
	@DescriptionArabic						NVARCHAR(MAX)='',
	@XMLAdvanceInvoice						VARCHAR(MAX)='',
	@CompanyBankAccountId					INT=NULL,
	@LastIndex								INT=NULL,
	@IndexSettingsId						INT=NULL,
	@UUID									NVARCHAR(2000)='',
	@InvoiceSequence						BIGINT=0	,
	@InvoiceXml								NVARCHAR(1000)='',
	@PdfFilePath							NVARCHAR(1000)='',
	@XMLAddOnsDetails						NVARCHAR(MAX)='',
	@InvoiceSubmittedDate					DATETime=NULL,
	@CustContactPersonDetailsId				BIGINT=NULL,
	@ReceiptNo								VARCHAR(50)=NULL,
	@ReceiptLastIndex						INT=NULL,
	@ReceiptIndexSettingsId					INT=NULL,
	@IsSubmit								BIT=0,
	@TemplateId								INT=NULL,
	@PageSessionId							BIGINT,
	@PerformanceBondPercentage				DECIMAL(24,5)=0,
	@PerformanceBondAmount					DECIMAL(24,5)=0,
	@PerformanceBondAmountCustCurrency		DECIMAL(24,5)=0,
	@IsDraft								BIT=0,
	@IsOutOfScopeInvoice					BIT=0
	--@DAA INT =0
AS
SET NOCOUNT ON
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		
		SET @InvoiceSubmittedDate=GETDATE();


		IF	@CustomerId=0						SET @CustomerId=NULL;
		IF	@CurrencyId=0						SET @CurrencyId=NULL;
		IF	@PaymentTermsId=0					SET @PaymentTermsId=NULL;
		IF	@TermsAndConditionId=0				SET @TermsAndConditionId=NULL;
		IF	@StaffId=0							SET @StaffId=NULL;
		IF	@InvoiceTypeId=0					SET @InvoiceTypeId=NULL;
		IF	@PaymentTermsId=0					SET @PaymentTermsId=NULL;
		IF	@DeliveryMethodId=0					SET @DeliveryMethodId=NULL;
		IF	@PriceListId=0						 SET @PriceListId=NULL;
		IF  @SalesOrderId=''					OR @SalesOrderId=0				SET @SalesOrderId=NULL;
		IF  @CostCenterId IS NULL				OR @CostCenterId=''				SET @CostCenterId=0;
		IF  @CSOId=0							SET @CSOId=NULL
		IF  @ContractInvoiceId=0				SET @ContractInvoiceId=NULL
		IF  @TimeSheetInvoiceId=0				SET @TimeSheetInvoiceId=NULL
		IF  @CustAutomobileDetailsId=0			SET @CustAutomobileDetailsId=NULL
		IF  @ReceiptAccountId=0					SET @ReceiptAccountId = NULL
		IF  @DepartmentId=0 OR @DepartmentId=''					SET @DepartmentId=NULL
		IF  @SalesManUserId=0 OR @SalesManUserId=''				SET @SalesManUserId=NULL
		IF  @BankCurrencyId=0	OR @BankCurrencyId=''			SET @BankCurrencyId=NULL
		IF  @CompanyBankAccountId=0 OR @CompanyBankAccountId='' SET @CompanyBankAccountId=NULL;
		IF  @CustContactPersonDetailsId=0						SET @CustContactPersonDetailsId=NULL

		DECLARE @XMLD							XML,
				@XMLC							XML,
				@XMlBatch						XML,
				@XMLSIBundle					XML,
				@RecordCount					INT,
				@CRecordCount					INT,
				@BatchRecordCount				INT,
				@RowNumber						INT,
				@SettingsId						INT=17,	 	-- Settings id- sales invoice=17 
				@FinYear						INT,		
				@XMLAccounts					NVARCHAR(MAX)='',
				@NewInsert						BIT=0,
				@XMLG							XML,
				@OrderedQty						DECIMAL(24,5),
				@InvoicedQty					DECIMAL(24,5),
				@ServiceTotalAmount				DECIMAL(24,5),
				@SalesTotalAmount				DECIMAL(24,5),
				@ServiceAccounting				INT=0,
				@ServiceAccountId				INT,
				@ServiceProductName				VARCHAR(300),
				@SalesInvoiceDetailsId			BIGINT,
				@LocationType					VARCHAR(1),
				@PreviousCustomerReceiptId		BIGINT,
				@PreviousAccountTransId			BIGINT,
				@PreviousAdvanceCount			INT,
				@BOMStockId						BIGINT,
				@BOMStockRecordCount			INT,
				@XMLBOMStock					XML,
				@TimeSheetTabulationId			BIGINT,
				@InvoicedCount					INT,		
				@ContractInvoiceTabulationId	BIGINT,
				@ContractInvoiceSettingsId		INT=42,	 	-- Settings id- cotract Invoice
				@ContractInvoiceNo				NVARCHAR(100),
				@InvoiceFromSalesOrder			BIT,
				@MixedModeRecordCount			INT,
				@MixedModeXML					XML,
				@MixedAmount					DECIMAL(24,5)	,
				@MixBankAccountId				INT,
				@MixPaymentMethodId				INT,
				@MixRowNumber					INT,
				@MixAccountId					INT,
				@IsReceiptFromInvoice			BIT=0,
				@XMLProjectBill					XML,
				@ProjectBillCount				INT,
				@TranTaxId						INT,
				@XMLRetention					XML,
				@RetentionCount					INT,
				@XMLAI							XML,
				@AdvanceInvoiceCount			INT,
				@MixedAmountInCustCurrency		DECIMAL(24,5),
				--@ReceiptNo						VARCHAR(50),
				@CustomerReceiptId				BIGINT,
				@VatAdvanceAccountId			INT,
				@PayAmount						DECIMAL(24,5)=0,
				@InvoiceSequenceNo				BIGINT=0,
				@PrevoiusInvoiceHash			NVARCHAR(2000),
				@IsBatchOverRide				BIT,
				@EnableBatch					INT,
				@AutogenerateBatchNo			INT,
				@EnableSerial					INT,
				@AutogenerateSerialNo			INT,
				@CountXMLGDNs					INT=0,
				@BRecordCount					INT,
				@SalesInvoiceBundleId			BIGINT,
				@PerformanceBondAccountId		BIGINT,
				@DraftSalesInvoiceNo				VARCHAR(50)

	    -- Declare varaibles for accounts
		DECLARE @AccountTransId							BIGINT=0,
				@VoucherNo								VARCHAR(50),
				@TransactionTypeId						INT	=6,				-- transaction type id- 6 for SalesInvoice
				@CRTransactionTypeId					INT	=8,
				@Remarks1								VARCHAR(MAX)='',
				@TransStatus							VARCHAR(1)='A',
				@SpStatus1								INT	,
				@SalesAccountId							INT,
				@SPStatus2								INT,
				@SalesDiscountAccountId					INT,
				@CustomerAccountId						INT,
				@CustomerName							VARCHAR(350),
				@CustomerNameArabic						NVARCHAR(350)='',
				@TransactionType						VARCHAR(1)='S'	,	-- customer transaction Type- S for Sales
				@RecordCountAccountEntry				INT,
				@AccountString							NVARCHAR(MAX),
				@OutputTaxAccountId						INT,
				@TaxAmount								DECIMAL(24,5),
				@TaxAmountCustCurrency					DECIMAL(24,5),
				@RoundOffAccountId						INT,
				@CustomerServiceAccountId				INT,
				@IsSubCustomer							BIT,
				@AccountPostTo							VARCHAR(2),
				@InventoryAssetAccountId				INT,
				@CostOfSalesAccountId					INT,
				@TotalAccountAmount						DECIMAL(24,5),
				@ACRowNumber							INT,
				@ACRecordCount							INT,
				@ACTotalAmount							DECIMAL(24,5),
				@ACAccountId							INT,
				@EntryName								VARCHAR(300),
				@ProgressiveInvoiceAmount				DECIMAL(24,5),
				@ProgressiveInvoiceAmountCustCurrency	DECIMAL(24,5),
				@ProgressiveNetAmount					DECIMAL(24,5),
				@ProgressiveRetensionAmount				DECIMAL(24,5),
				@ProgressiveRetensionAmountCustCurrency DECIMAL(24,5),
				@RetensionAmount						DECIMAL(24,5),
				@ProjectAccountId						INT,
				@RetentionAccountId						INT,
				@CashSaleAccountId						INT,
				@TotalInventoryAssetAmount				DECIMAL(24,5),
				@UnbilledSalesAccountId					INT,
				@ChequeTransId							BIGINT=0,
				@ChequeAmount							DECIMAL(24,5),
				@AccountPaymentMethodId					INT,
				@ChequeNarration						NVARCHAR(MAX),
				@AccountChequeStatus					VARCHAR(1),
				@AccountBankAccountId					INT,
				@AccountChequeDate						DATE,
				@AccountChequeNo						VARCHAR(50),
				@FreeItemAccountID						INT=0,
				@FreeItemTotalAmount					DECIMAL(24,5),
			    @ProjectInvoiceTotal					DECIMAL(24,5),
				@SeparateAccountForPDC					BIT,
				@ACTotalAmountCustCurrency				DECIMAL(24,5),
				@XMLAddOns								XML,
				@AddOnrecordCount						INT,
				@SpecialDiscount						DECIMAL(24,5),
				@SpecialDiscountCustCurrency			DECIMAL(24,5),
				@SpecialDiscountAccountId				BIGINT,
				@XMLAlreadySelected						VARCHAR(MAX)
		
		DECLARE @InvoiceSOId				BIGINT,
				@SOOrderedQty				DECIMAL(24,6),
				@TotalInvoicedQty			DECIMAL(24,6)
	
		---- GDN items variable
		DECLARE	@GDNId						BIGINT,
				@GDNNo						VARCHAR(50),
				@GDNSettingsId				INT=16,
				@GDNStockTransactionTypeId	INT=2,
				@StockId					BIGINT,
				@GDNTotalQuantity			DECIMAL(24,5),
				@ProductID1					BIGINT,
				@UOMId1						INT,
				@PurchaseRate1				DECIMAL(24,5),
				@SalesRate					DECIMAL(24,5),
				@BatchNo					VARCHAR(50),
				@ConversionValue			DECIMAL(24,5),
				@SIRowNumber				INT,
				@IsNonServiceCount			INT,
				@RowId						INT,
				@XMLGDN						XML,
				@XMLBundle					XML,
				@XMLStock					XML,
				@XMlGDNBatch				XML,
				@XMlS						XML,
				@SRecordCount				INT,
				@GDNStockRecordCount		INT,
				@GDNRecordCount				INT,
				@BundleRecordCount			INT,
				@GDNBatchCount				INT,
				@GDNDetailsId				BIGINT,
				@SpStatus3					INT,
				@XMLProject					XML,
				@ProjectRecordCount			INT,
				@AdvanceCount				INT,
				@TakenTaxAmount				DECIMAL(24,5)=0,
				@TakenTaxAmountCustCurrency	DECIMAL(24,5)=0,
				@XMLTransactionsToConsider  NVARCHAR(MAX),
				@SalesOrderDetailsId		BIGINT,
				@CostPrice					DECIMAL(24,5)

		DECLARE @NumberFormat INT=[ERP.Config].Fun_GetGeneralSettingsValue(@BranchId,'NumberFormat')
		DECLARE @TblProductStock  [TYPEProductStock]  ;
		DECLARE @InvoiceRetentionDetailsId	BIGINT,
				@RetentionSlNo				INT			,
				@TimesheetCount				INT,
				@BranchCurrencyId			INT=[ERP.Config].Fun_GetGeneralSettingsValue(@BranchId,'Currency'),
				@XMLFetchBatchNo			NVARCHAR(MAX),
				@XMLFetchBatchSerialNo		NVARCHAR(MAX),
				@XMLSentProductBatchNos		NVARCHAR(MAX),		
				@MaxRowDetailsId			INT,
				@SpStatus4					INT,
				@BatchCount					INT=0,
				@XMLBatchSerialNo			XML,
				@BatchSerialNoCount			INT,
				@IsEdit						SMALLINT

		DECLARE @TempDetails TABLE
		(	
			RowNumber							BIGINT	IDENTITY(1,1),
			SalesInvoiceDetailsId  				BIGINT,
			InvRowId							INT,
			ProductId							BIGINT,
			BundleId							BIGINT,
			AccountId							INT,
			InvoiceType							VARCHAR(1), 
			SalesOrderDetailsId					BIGINT,
			LocatorId							INT,
			Quantity							DECIMAL(24,5),
			UOMId								INT ,
			SalesRate							DECIMAL(24,5),
			DiscountAmount						DECIMAL(24,5),
			DiscountPercentage					DECIMAL(24,5),
			DiscountType						INT,	
			TaxId								INT,
			TaxAmount							DECIMAL(24,5),			
			TotalAmount							DECIMAL(24, 5),
			DeliveryDate						NVARCHAR(50),
			[Description]						VARCHAR(MAX),
			DescriptionArabic					NVARCHAR(MAX),
			Narration							VARCHAR(MAX),
			WarehouseId							INT,
			SalesRateInCustCurrency				DECIMAL	(24,5),
			DiscountAmountInCustCurrency		DECIMAL	(24,5),
			TaxAmountInCustCurrency				DECIMAL	(24,5),
			TotalAmountInCustCurrency			DECIMAL	(24,5),
			IsComponent							BIT ,
			BOMId								INT,
			GDNId								BIGINT,
			GDNDetailsId						BIGINT,
			PaymentMethodId						INT ,
			BankAccountId						INT ,
			CardNo								VARCHAR(50) ,
			ChequeNo							VARCHAR(50) ,
			ChequeDate							DATE,
			IsFreeItem							BIT ,
			IsTotalAmountEdited					BIT,
			SalesRateIncludVAT					DECIMAL(24,5) ,
			SalesRateIncludVATCustCurrency		DECIMAL(24,5),
			CostPrice							DECIMAL(24,5),
			BankCurrencyId						INT,
			BankCurrencyRate					DECIMAL(24,5),
			TotalAmountInBankCurrency			DECIMAL(24,5),
			TradeDiscountPercentage				DECIMAL	(24,5),
			TradeDiscountAmount					DECIMAL	(24,5),
			POLineNo							VARCHAR(20),
			SpecialDiscountType					INT	,
			SpecialDiscountPercentage			DECIMAL	(24,5),
			SpecialDiscountAmount				DECIMAL	(24,5),	
			SpeciaDiscountAmountInCustCurrency	DECIMAL	(24,5),
			IsBatchOverRide						BIT
		) 
		DECLARE @TempChargeDetails TABLE
		(
			RowNumber					INT IDENTITY(1,1),
			SalesInvoiceChargeId		BIGINT, 
			ChargeId					INT,
			Amount						DECIMAL(24,5),
			AmountInCustCurrency    	DECIMAL(24,5)
		) 
		DECLARE  @TempIncomeEntries TABLE 
		(
			RowNumber			INT IDENTITY(1,1), 
			IncomeAccountId		INT,
			Amount				DECIMAL(24,5),
			AmountCustCurrency	DECIMAL(24,5)
		)

		DECLARE @TempACEntries TABLE
		(		
			RowNumber				INT IDENTITY(1,1),
			ExpenseAccountId		INT,
			InventoryAssetAccountId	INT,
			TotalCostPrice			DECIMAL(24,5) 
		) 

		DECLARE @TempService TABLE
		(		
			ProductId			INT,
			ServiceProductName  VARCHAR(300),
			ServiceAccountId	BIGINT, 		
			ServiceTotalAmount	DECIMAL(24,5) 
		) 

		DECLARE @TempServiceDetails TABLE
		(
			RowNumber						BIGINT	IDENTITY(1,1),
			SlNo							INT,
			PartNo							VARCHAR(50),
			[Description]					VARCHAR(MAX),
			ServiceId						INT,
			Quantity						DECIMAL(24,5),
			Unit							VARCHAR(50),
			SalesRate						DECIMAL(24,5),
			DiscountAmount					DECIMAL(24,5),
			TotalAmount						DECIMAL(24,5),
			TaxId							INT,
			TaxAmount						DECIMAL(24,5),
			NetAmount						DECIMAL(24,5),
			DiscountType					INT,
			DiscountPercentage				DECIMAL(24,5),
			InvoicePercentage				DECIMAL(24,5),
			RetentionPercentage				DECIMAL(24,5),
			RetentionAmount					DECIMAL(24,5),
			ContractInvoiceId				BIGINT,
			SalesRateIncludVAT				DECIMAL(24,5) ,
			SalesRateIncludVATCustCurrency	DECIMAL(24,5)
		) 
		DECLARE @TempGDNItems  TABLE
		(
			RowNumber					INT	IDENTITY(1,1),
			GDNRowId					INT,
			ProductId					BIGINT,
			BundleId					BIGINT,
			WarehouseId					INT,
			LocatorId					INT,
			Quantity					DECIMAL(24,5),
			UOMId						INT ,
			SalesRate					DECIMAL(24,5),
			DiscountAmount				DECIMAL(24,5),
			DiscountPercentage			DECIMAL(24,5),
			DiscountType				INT,		
			TaxId						INT,
			TaxAmount					DECIMAL(24,5),		
			TotalAmount					DECIMAL(24,5),
			DeliveryDate				VARCHAR(50),
			Description					VARCHAR(MAX),
			IsService					BIT DEFAULT 0,
			IsComponent					BIT,
			BOMId						INT,
			IsFreeItem					BIT,
			IsTotalAmountEdited			BIT,
			GDNDetailsId				BIGINT
		)
		
		DECLARE @TempGDNBundles TABLE
		(
			RowNumber		INT IDENTITY(1,1),
			GDNRowId		INT,
			GDNDetailsId	BIGINT DEFAULT 0,
			BundleId		INT,
			ProductId		BIGINT,
			WarehouseId		INT,
			LocatorId		INT,
			Quantity		DECIMAL(24,5),
			UOMId			INT,
			SalesRate		DECIMAL(24,5),
			BundleQty		DECIMAL(24,5)
		)
		DECLARE @TempSIBundles TABLE
		(
			RowNumber						INT IDENTITY(1,1),
			SIRowId							INT,
			SIDetailsId						BIGINT DEFAULT 0,
			BundleId						INT,
			ProductId						BIGINT,
			WarehouseId						INT,
			LocatorId						INT,
			Quantity						DECIMAL(24,5),
			UOMId							INT,
			SalesRate						DECIMAL(24,5),
			SalesRateInCustCurrency			DECIMAL	(24,5),
			CostPrice						DECIMAL(24,5),
			SalesRateIncludVAT				DECIMAL(24,5) ,
			SalesRateIncludVATCustCurrency	DECIMAL(24,5),
			BundleQty						DECIMAL(24,5)
		)

		DECLARE @TempGDNBatches TABLE
		(
			RowNumber		BIGINT,
			GDNDetailsId	BIGINT,
			GDNRowId		INT,
			ProductId		BIGINT,
			StockBatchNo	VARCHAR(50),
			Quantity		DECIMAL(24,5),
			SalesRate		DECIMAL(24,5),
			CostPrice		DECIMAL(24,5),
			UOMId			INT,
			ExpiryDate		DATE
		)

		DECLARE @TempAc TABLE
		(
			EntryName					VARCHAR(50),
			IncomeAccountId				INT,
			ExpenseAccountId			INT,
			InventoryAssetAccountId		INT,
			TotalCostPrice				DECIMAL(24,5),
			TotalSalesPrice				DECIMAL(24,5),
			IsFreeItem					BIT,
			TotalSalesPriceCustCurrency	DECIMAL(24,5)
		)

		DECLARE @TempGDNs TABLE (GDNId BIGINT)

		DECLARE @TempAccountEntries TABLE
		(
			RowNumber					INT IDENTITY(1,1),
			AccountId					INT,
			Amount						DECIMAL(24,5),
			Narration					VARCHAR(MAX),
			PaymentMethodId				INT,
			BankAccountId				INT,
			cardNo						VARCHAR(50),
			ChequeNo					VARCHAR(50),
			ChequeDate					DATE,
			TaxAmount					DECIMAL(24,5),
			BankCurrencyId				INT,
			BankCurrencyRate			DECIMAL(24,5),
			TotalAmountInBankCurrency	DECIMAL(24,5),
			TotalAmountInCustCurrency	DECIMAL(24,5),
			SpecialDiscount				DECIMAL(24,5)	
		)
		
		DECLARE @TempBatchAndSerialDetails TABLE
		(
			RowNumber				BIGINT  IDENTITY(1,1),
			BranchId				INT,
			PageSessionId			BIGINT,
			SalesInvoiceDetailsId	BIGINT,
			ProductId				BIGINT,
			UOMId					INT,
			StockBatchNo			VARCHAR(1000),
			BatchNo					VARCHAR(1000),
			BatchSerialNo			VARCHAR(1000),
			ManufacturingDate		DATE,
			ExpiryDate				DATE,
			Quantity				DECIMAL(24,5),
			CostPrice				DECIMAL(24,5),
			RowId					INT,
			IsBatchOverRide			BIT,
			BOMId						BIGINT
		)

		DECLARE @OldSIBatchAndSerialDetails TABLE
		(
			RowNumber				BIGINT  IDENTITY(1,1),
			SalesInvoiceDetailsId	BIGINT,
			ProductId				BIGINT,
			UOMId					INT,
			StockBatchNo			VARCHAR(1000),
			BatchNo					VARCHAR(1000),
			BatchSerialNo			VARCHAR(1000),
			ManufacturingDate		DATE,
			ExpiryDate				DATE,
			Quantity				DECIMAL(24,5),
			CostPrice				DECIMAL(24,5),
			RowId					INT,
			IsBatchOverRide			BIT,
			GdnDetailsId			BIGINT,
			BOMId						BIGINT,
			SalesOrderDetailsId  BIGINT
		)

		DECLARE @TempTaxes TABLE
		(	
			RowNumber				INT IDENTITY(1,1),
			TaxId					INT,
			TaxAmount				DECIMAL(24,5),
			TotalAmount				DECIMAL(24,5),
			TaxAmountCustCurrency	DECIMAL(24,5),
			TotalAmountCustCurrency	DECIMAL(24,5)
		)
		DECLARE @TempPreviousAdvance TABLE 
		(
			RowNumber					INT IDENTITY(1,1),
			CustAdvanceTransId			BIGINT,
			AdvanceAmount				DECIMAL(24,5),
			AdvanceAmountCusCurrency	DECIMAL(24,5),
			AdvanceTaxAmount			DECIMAL(24,5),
			AdvanceTaxAmountCusCurrency	DECIMAL(24,5),
			ProjectId							BIGINT
		)		
		DECLARE @TaxRecordCount	INT

		CREATE TABLE #TempGDNStatusRollback 
		(	
			RowNumber			INT IDENTITY(1,1),
			GDNId				BIGINT,
			SalesOrderId		BIGINT,
			InvoicedQTy			DECIMAL(24,6),
			DeliveredQty		DECIMAL(24,6),
			OrderedQty			DECIMAL(24,6),
			OrderedInvoicedQty	DECIMAL(24,6),
			OrderStatus			VARCHAR(5),
			GDNStatus			VARCHAR(5) 
		)
		DECLARE @TempCustomerMixedReceiptDetails TABLE
		(
			RowNumber				INT IDENTITY(1,1),
			PaymentMethodId			INT,
			ChequeNo				VARCHAR(50),
			ChequeDate				DATE,
			ChequeDetails			NVARCHAR(500),
			AccountId				INT,
			BankAccountId			INT,
			CardNo					VARCHAR(50),
			Remarks					NVARCHAR(1000),
			Amount					DECIMAL(24,5),
			AmountInCustCurrency	DECIMAL(24,5),
			BankCurrencyId			INT,
			BankCurrencyRate		DECIMAL(24,5),
			AmountInBankCurrency	DECIMAL(24,5)
		)
		DECLARE @TempProjectDetails TABLE
		(
			SerialNo						INT,
			CSOId							BIGINT,
			Description						NVARCHAR(MAX),
			DescriptionArabic				NVARCHAR(MAX),
			InvoiceAmount					DECIMAL(24, 5),
			DiscountAmount					DECIMAL(24, 5),
			DiscountPercentage				DECIMAL(24, 5),
			DiscountType					INT,
			TaxId							INT,
			TaxAmount						DECIMAL(24, 5),
			TotalAmount						DECIMAL(24, 5),
			InvoiceAmountInCustCurrency		DECIMAL(24, 5),
			DiscountAmountInCustCurrency	DECIMAL(24, 5),
			TaxAmountInCustCurrency			DECIMAL(24, 5),
			TotalAmountInCustCurrency		DECIMAL(24, 5),
			ProjectJobId					BIGINT,
			CompletionPercentage			DECIMAL(24,5),
			QtyInScope						DECIMAL(24,5),
			UOMId							INT
		)
		DECLARE @TempProjectBillDetails TABLE
		(
			 SerialNo						INT,
			 ProjectJobId					BIGINT,
			 WorkType						VARCHAR (2),
			 ItemDescription				NVARCHAR (MAX),
			 Quantity						DECIMAL (24, 5),
			 UOM							VARCHAR (100),
			 Rate							DECIMAL (24, 5),
			 InvoiceAmount					DECIMAL (24, 5),
			 DiscountAmount					DECIMAL (24, 5),
			 DiscountPercentage				DECIMAL (24, 5),
			 DiscountType					INT,
			 TaxId							INT,
			 TaxAmount						DECIMAL (24, 5),
			 TotalAmount					DECIMAL (24, 5),
			 RateInCustCurrency				DECIMAL (24, 5),
			 InvoiceAmountInCustCurrency	DECIMAL (24, 5),
			 DiscountAmountInCustCurrency   DECIMAL (24, 5),
			 TaxAmountInCustCurrency		DECIMAL (24, 5),
			 TotalAmountInCustCurrency		DECIMAL (24, 5),
			 ProjectJobBillDetailsId		BIGINT,
			 Remarks						VARCHAR (MAX),
			ItemName						VARCHAR(1000),
			ItemNameArabic					NVARCHAR(1000),
			ItemDescriptionArabic			NVARCHAR(MAX)
		)

		DECLARE  @TempRetentionInvoice TABLE
		(
			 RowNumber							INT IDENTITY(1,1)		,
			 RetentionInvoiceDetailsId			BIGINT  ,
			 SerialNo							INT  ,
			 RetentionAccountId					BIGINT  ,
			 Description						VARCHAR (MAX) ,
			 DescriptionArabic					NVARCHAR (1000) ,
			 TotalContractValue					DECIMAL (24, 5) ,
			 TotalInvoicedAmount				DECIMAL (24, 5) ,
			 RetentionPercentage				DECIMAL (24, 5) ,
			 RetentionAmount					DECIMAL (24, 5) ,
			 CumulativeAmount					DECIMAL (24, 5) ,
			 BalanceRetentionAmount				DECIMAL (24, 5) ,
			 ReceivedAmount						DECIMAL (24, 5) ,
			 DiscountType						INT  ,
			 DiscountPercentage					DECIMAL (24, 5) ,
			 DiscountAmount						DECIMAL (24, 5) ,
			 TotalAmount						DECIMAL (24, 5) ,
			 TotalContractValueCustCurrency		DECIMAL (24, 5) ,
			 TotalInvoicedAmountCustCurrency	DECIMAL (24, 5) ,
			 RetentionAmountCustCurrency		DECIMAL (24, 5) ,
			 CumulativeAmountCustCurrency		DECIMAL (24, 5) ,
			 BalanceRetentionAmountCustCurrency DECIMAL (24, 5) ,
			 ReceivedAmountCustCurrency			DECIMAL (24, 5) ,
			 DiscountAmountCustCurrency			DECIMAL (24, 5) ,
			 TotalAmountCustCurrency			DECIMAL (24, 5) ,
			 Remarks							NVARCHAR(MAX),
			 Name								VARCHAR(500),
			 NameArabic							NVARCHAR(500)
		)
		DECLARE @TempTimesheet TABLE
		(
			SalesInvoiceTimeSheetId			BIGINT, 
			TimeSheetTabulationId			BIGINT, 
			TimeSheetTabulationDetailsId	BIGINT, 
			EmployeeId						BIGINT, 
			SalaryCalculationType			VARCHAR(1), 
			ProjectJobId					BIGINT, 
			LocationId						INT, 
			WorkedHr						DECIMAL(24,5), 
			TotalAmount						DECIMAL(24,5), 
			WorkedOTHr						DECIMAL(24,5), 
			TotalOTAmount					DECIMAL(24,5), 
			NetAmount						DECIMAL(24,5), 
            Remarks							NVARCHAR(MAX),
			DiscountType					INT	,
			DiscountPercentage				DECIMAL(24,5),
			DiscountAmount					DECIMAL(24,5)
		)
		
		DECLARE @TempAdvanceInvoice TABLE
		(
			RowNumber						INT IDENTITY(1,1),
			CustAdvanceTransId				BIGINT,
			AdvanceAmount					DECIMAL(24,5),
			AllottedAmount					DECIMAL(24,5),
			Description						VARCHAR(500),
			CurrencyRate					DECIMAL(24,5),
			AdvanceAmountCustCurrency		DECIMAL(24,5),
			AllottedAmountCustCurrency		DECIMAL(24,5),
			SalesInvoiceId					BIGINT,
			TaxId							INT,
			TaxAmount						DECIMAL(24,5),
			TotalAmount						DECIMAL(24,5),
			AllottedTaxAmount				DECIMAL(24,5),
			TaxAmountCustCurrency			DECIMAL(24,5),
			TotalAmountCustCurrency			DECIMAL(24,5),
			AllottedTaxAmountCustCurrency	DECIMAL(24,5)
		)

		DECLARE @TempAdvance TABLE
		(
			RowNumber					INT IDENTITY(1,1),
			CustAdvanceTransId			BIGINT,
			CustomerReceiptId			BIGINT,
			CustOpeningBalanceId		BIGINT,
			TakenAmount					DECIMAL(24,5),
			CreditNoteId				BIGINT,
			TakenAmountCustCurrency		DECIMAL(24,5), 
			TakenTaxAmount				DECIMAL(24,5),
			TakenTaxAmountCustCurrency	DECIMAL(24,5),
			CostCenterId				INT
		)

		DECLARE @TempAddOnsDetails TABLE
		(
			AddOnsSettingsId			INT,
			AddOnsSettingsValue			NVARCHAR(2000),
			AddOnsSettingsValueArabic	NVARCHAR(2000)

		)
		
		DECLARE @TempSIBatchSerialNos TABLE
		(
			RowNumber							INT IDENTITY(1,1),
			SalesInvoiceBatchSerialNumbersId	BIGINT,
			SalesInvoiceBatchId					BIGINT,
			BatchNo								VARCHAR(1000),
			BatchSerialNo						VARCHAR(1000),
			ManufacturingDate					DATE,
			ExpiryDate							DATE,
			Qty									DECIMAL(24,5),
			StockDescription					VARCHAR(MAX),
			Remarks								VARCHAR(MAX),
			RowDetailsId						INT
		)
		-------------------------------------------------
		--Params for Saving Log 
		Declare @LogId					INT,
				@LogDate				DATETIME=GETDATE(),
				@PageName				VARCHAR(250),
				@UserId					BIGINT=@CREATEDBY,
				@Action					VARCHAR(1),
				@ReferenceId			BIGINT,	
				@ReferenceNum			VARCHAR(20),	
				@EditedBy				INT,
				@EntryStatus			VARCHAR(1)='A'
		-------------------------------------------------
		IF @XMLSalesInvoiceBundleDetails='<RowSet></RowSet>' SET @XMLSalesInvoiceBundleDetails=''
		IF @XMLGDNBundleDetails='<RowSet></RowSet>' SET @XMLGDNBundleDetails=''

		SELECT @IsEdit=CASE WHEN @SalesInvoiceId>0 THEN 1 ELSE 0 END

		IF @XMLDetails<>'' AND @XMLDetails is NOT NULL
		BEGIN
			SET @XMLD = CAST(@XMLDetails as XML);
			INSERT INTO @TempDetails
			SELECT  
				ISNULL(TEMP.I.value('(SalesInvoiceDetailsId/text())[1]', 'bigint'),0)				 AS SalesInvoiceDetailsId,
				ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)									 AS InvRowId, 
				ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)							 AS ProductId,
				ISNULL(TEMP.I.value('(BundleId/text())[1]', 'bigint'),0)							 AS BundleId, 
				ISNULL(TEMP.I.value('(AccountId/text())[1]', 'int'),0)								 AS AccountId,
				ISNULL(TEMP.I.value('(InvoiceType/text())[1]', 'varchar(1)'),0)						 AS InvoiceType,
				ISNULL(TEMP.I.value('(SalesOrderDetailsId/text())[1]', 'bigint'),0)					 AS SalesOrderDetailsId,	
				ISNULL(TEMP.I.value('(LocatorId/text())[1]', 'Int'),0)								 AS LocatorId,
				ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)						 AS Quantity,
				ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            			 AS UOMId,		
				ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)					 AS SalesRate,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)				 AS DiscountAmount,
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)			 AS DiscountPercentage,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)							 AS DiscountType,
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)									 AS TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)					 AS TaxAmount ,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)					 AS TotalAmount ,
				ISNULL(TEMP.I.value('(DeliveryDate/text())[1]', 'nvarchar(50)'),'')			         AS DeliveryDate,	
				ISNULL(TEMP.I.value('(Description/text())[1]', 'nvarchar(MAX)'),'')					 AS [Description],	
				ISNULL(TEMP.I.value('(DescriptionArabic/text())[1]', 'nvarchar(MAX)'),'')			 AS DescriptionArabic ,
				ISNULL(TEMP.I.value('(Narration/text())[1]', 'nvarchar(MAX)'),'')					 AS Narration 	,
				ISNULL(TEMP.I.value('(WarehouseId/text())[1]', 'int'),null)							 AS WarehouseId ,
				ISNULL(TEMP.I.value('(SalesRateInCustCurrency/text())[1]', 'decimal(24,5)'),0)		 AS SalesRateInCustCurrency,
				ISNULL(TEMP.I.value('(DiscountAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)  AS DiscountAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TaxAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		 AS TaxAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TotalAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	 AS TotalAmountInCustCurrency,
				ISNULL(TEMP.I.value('(IsComponent/text())[1]', 'bit'),'')							 AS IsComponent,
				ISNULL(TEMP.I.value('(BOMId/text())[1]', 'int'),0)									 AS BOMId,
				ISNULL(TEMP.I.value('(GDNId/text())[1]', 'bigint'),0)								 AS GDNId,
				ISNULL(TEMP.I.value('(GDNDetailsId/text())[1]', 'bigint'),0)						 AS GDNDetailsId,
				ISNULL(TEMP.I.value('(PaymentMethodId/text())[1]', 'int'),0)						 AS PaymentMethodId,	 
				ISNULL(TEMP.I.value('(BankAccountId/text())[1]', 'int'),0)							 AS BankAccountId,
				ISNULL(TEMP.I.value('(CardNo/text())[1]', 'varchar(50)'),'')						 AS CardNo,
				ISNULL(TEMP.I.value('(ChequeNo/text())[1]', 'varchar(50)'),'')						 AS ChequeNo,
				ISNULL(TEMP.I.value('(ChequeDate/text())[1]', 'Date'),'')							 AS ChequeDate,
				ISNULL(TEMP.I.value('(IsFreeItem/text())[1]', 'bit'),'')							 AS IsFreeItem,
				ISNULL(TEMP.I.value('(IsTotalAmountEdited/text())[1]', 'bit'),'')					 AS IsTotalAmountEdited,
				ISNULL(TEMP.I.value('(SalesRateIncludVAT/text())[1]', 'decimal(24,5)'),0)			 AS SalesRateIncludVAT,
				ISNULL(TEMP.I.value('(SalesRateIncludVATCustCurrency/text())[1]', 'decimal(24,5)'),0)AS SalesRateIncludVATCustCurrency,
				0 as CostPrice,
				ISNULL(TEMP.I.value('(BankCurrencyId/text())[1]', 'int'),0)							 AS BankCurrencyId,
				ISNULL(TEMP.I.value('(BankCurrencyRate/text())[1]', 'decimal(24,5)'),0)				 AS BankCurrencyRate,
				ISNULL(TEMP.I.value('(TotalAmountInBankCurrency/text())[1]', 'decimal(24,5)'),0)	 AS TotalAmountInBankCurrency,
				ISNULL(TEMP.I.value('(TradeDiscountPercentage/text())[1]', 'decimal(24,5)'),0)		 AS TradeDiscountPercentage,
				ISNULL(TEMP.I.value('(TradeDiscountAmount/text())[1]', 'decimal(24,5)'),0)			 AS TradeDiscountAmount,
				ISNULL(TEMP.I.value('(POLineNo/text())[1]', 'varchar(20)'),'')						 AS POLineNo,
				ISNULL(TEMP.I.value('(SpecialDiscountType/text())[1]', 'int'),0)					 AS SpecialDiscountType,
				ISNULL(TEMP.I.value('(SpecialDiscountPercentage/text())[1]', 'decimal(24,5)'),0)	 AS SpecialDiscountPercentage,
				ISNULL(TEMP.I.value('(SpecialDiscountAmount/text())[1]', 'decimal(24,5)'),0)		 AS SpecialDiscountAmount,
				ISNULL(TEMP.I.value('(SpecialDiscountAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		AS SpecialDiscountAmountInCustCurrency,
				ISNULL(TEMP.I.value('(IsBatchOverRide/text())[1]', 'BIT'),0)						 AS IsBatchOverRide 
			FROM @XMLD.nodes('/RowSet/Row') TEMP(I);
		END
	
		SELECT @RecordCount=COUNT(*) FROM @TempDetails;

		IF @XMLServiceDetails<>'' AND @XMLServiceDetails is NOT NULL
		BEGIN
			--------------------------Added on 2020-06-25 ----------------
			SET @XMLServiceDetails=REPLACE(@XMLServiceDetails,'&','&amp;')
			--------------------------------------------------------------
			SET @XMlS = CAST(@XMLServiceDetails as XML);
			INSERT INTO @TempServiceDetails
			SELECT
			    ISNULL(TEMP.I.value('(SlNo/text())[1]', 'int'),0)									 AS SlNo,
				ISNULL(TEMP.I.value('(PartNo/text())[1]', 'varchar(50)'),'')						 AS PartNo,
				ISNULL(TEMP.I.value('(Description/text())[1]', 'nvarchar(max)'),'')					 AS [Description],
				ISNULL(TEMP.I.value('(ServiceId/text())[1]', 'int'),0)								 AS ServiceId,
				ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)						 AS Quantity,
				ISNULL(TEMP.I.value('(Unit/text())[1]', 'varchar(50)'),'')							 AS Unit,
				ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)					 AS SalesRate,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)				 AS DiscountAmount,  
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)					 AS TotalAmount,  
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)			            			 AS TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)					 AS TaxAmount,
				ISNULL(TEMP.I.value('(NetAmount/text())[1]', 'decimal(24,5)'),0)					 AS NetAmount,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)			       			 AS DiscountType,	 
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)			 AS DiscountPercentage,
				ISNULL(TEMP.I.value('(InvoicePercentage/text())[1]', 'decimal(24,5)'),0)			 AS InvoicePercentage,
				ISNULL(TEMP.I.value('(RetentionPercentage/text())[1]', 'decimal(24,5)'),0)			 AS RetentionPercentage,
				ISNULL(TEMP.I.value('(RetentionAmount/text())[1]', 'decimal(24,5)'),0)				 AS RetentionAmount,
				ISNULL(TEMP.I.value('(ContractInvoiceId/text())[1]', 'bigint'),0)					 AS ContractInvoiceId,
				ISNULL(TEMP.I.value('(SalesRateIncludVAT/text())[1]', 'decimal(24,5)'),0)			 AS SalesRateIncludVAT,
				ISNULL(TEMP.I.value('(SalesRateIncludVATCustCurrency/text())[1]', 'decimal(24,5)'),0)AS SalesRateIncludVATCustCurrency
			FROM @XMLS.nodes('/RowSet/Row') TEMP(I);
		END
		SELECT @SRecordCount=COUNT(*) FROM @TempServiceDetails;

		--charge xml
		IF @XMLChargeDetails<>'' AND @XMLChargeDetails is NOT NULL
		BEGIN
			SET @XMLC = CAST(@XMLChargeDetails as XML);
			INSERT INTO @TempChargeDetails
			SELECT
			    ISNULL(TEMP.I.value('(SalesInvoiceChargeId/text())[1]', 'bigint'),0)			AS SalesInvoiceChargeId, 
				ISNULL(TEMP.I.value('(ChargeId/text())[1]', 'Int'),0)				    		AS ChargeId, 
				ISNULL(TEMP.I.value('(Amount/text())[1]', 'decimal(24,5)'),0)		    		AS Amount,
				ISNULL(TEMP.I.value('(AmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		AS Amount 
			FROM @XMLC.nodes('/RowSet/Row') TEMP(I);
		END
		SELECT @CRecordCount=COUNT(*) FROM @TempChargeDetails;

		--IF @XMLBatchDetails<>'' AND @XMLBatchDetails IS NOT NULL  
		--BEGIN
		--	SET @XMLBatch = CAST(@XMLBatchDetails as XML); 

		--	INSERT INTO @TempBatches
		--	(
		--		SalesInvoiceBatchId,SalesInvoiceDetailsId,ProductId,UOMId,BatchNo,StockBatchNo,
		--		ManufacturingDate,ExpiryDate,Quantity,StockDescription,Remarks,RowId,RowDetailsId
		--	)
		--	SELECT
		--		ISNULL(TEMP.I.value('(SalesInvoiceBatchId/text())[1]', 'bigint'),0)		AS SalesInvoiceBatchId,
		--		ISNULL(TEMP.I.value('(SalesInvoiceDetailsId/text())[1]', 'bigint'),0)	AS SalesInvoiceDetailsId,
		--		ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)				AS ProductId,
		--		ISNULL(TEMP.I.value('(UOMId/text())[1]', 'INT'),0)						AS UOMId,
		--		ISNULL(TEMP.I.value('(BatchNo/text())[1]', 'varchar(1000)'),'')			AS BatchNo,	
		--		ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'varchar(1000)'),'')	AS StockBatchNo,
		--		ISNULL(TEMP.I.value('(ManufacturingDate/text())[1]', 'date'),'')		AS ManufacturingDate,
		--		ISNULL(TEMP.I.value('(ExpiryDate/text())[1]', 'date'),'')				AS ExpiryDate,
		--		ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)			AS Quantity,
		--		ISNULL(TEMP.I.value('(StockDescription/text())[1]', 'varchar(max)'),'')	AS StockDescription,
		--		ISNULL(TEMP.I.value('(Remarks/text())[1]', 'varchar(max)'),'')			AS Remarks,
		--		ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)						AS RowId,
		--		ISNULL(TEMP.I.value('(RowDetailsId/text())[1]', 'int'),0)				AS RowDetailsId
		--	FROM @XMLBatch.nodes('/RowSet/Row') TEMP(I)
		--	WHERE ISNULL(TEMP.I.value('(IsBatchOverRide/text())[1]', 'int'),0)=1			
		--END 

		IF @XMLGDNs<>'' AND @XMLGDNs is NOT NULL
		BEGIN
			SET @XMLG = CAST(@XMLGDNs as XML);
			INSERT INTO @TempGDNs
			SELECT ISNULL(TEMP.I.value('(GDNId/text())[1]', 'bigint'),0)		AS GDNId 
			FROM @XMLG.nodes('/RowSet/Row') TEMP(I);
		END
		ELSE
		BEGIN
			INSERT INTO @TempGDNs
			SELECT 
				ISNULL([GDNId],0) AS GDNId 
			FROM [ERP.Inventory].[GoodsDeliveryNote]
			WHERE [ERP.Inventory].[GoodsDeliveryNote].CSOId=@CSOId 
				AND [ERP.Inventory].[GoodsDeliveryNote].CSOId IS NOT NULL;
		END
		DELETE FROM @TempGDNs WHERE GDNId=0;

		SELECT @CountXMLGDNs=COUNT(*) FROM @TempGDNs

		IF @XMLGDNDetails<>'' AND @XMLGDNDetails is NOT NULL
		BEGIN
			SET @XMLGDN = CAST(@XMLGDNDetails as XML); 
			INSERT INTO @TempGDNItems
			SELECT
			    --identity(int,1,1) as RowNumber,
				ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)							AS GDNRowId, 
				ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)					AS ProductId,
				ISNULL(TEMP.I.value('(BundleId/text())[1]', 'bigint'),0)	 				AS BundleId, 
				TEMP.I.value('(WarehouseId/text())[1]', 'int')								AS WarehouseId  ,	 
				TEMP.I.value('(LocatorId/text())[1]', 'int')								AS LocatorId  ,			
				ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)				AS Quantity,
				ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            	AS UOMId,	
				ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)			AS SalesRate,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)	    AS DiscountAmount, 
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)	AS DiscountPercentage,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)			       	AS DiscountType, 
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)							AS TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)			AS TaxAmount ,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)			AS TotalAmount ,
				ISNULL(TEMP.I.value('(DeliveryDate/text())[1]', 'varchar(50)'),'')			AS DeliveryDate ,
				ISNULL(TEMP.I.value('(Description/text())[1]', 'varchar(MAX)'),'')			AS Description ,
				0																			AS IsService ,
				ISNULL(TEMP.I.value('(IsComponent/text())[1]', 'bit'),'')					AS IsComponent,
				ISNULL(TEMP.I.value('(BOMId/text())[1]', 'int'),0)							AS BOMId,
				ISNULL(TEMP.I.value('(IsFreeItem/text())[1]', 'bit'),0)						AS IsFreeItem,
				ISNULL(TEMP.I.value('(IsTotalAmountEdited/text())[1]', 'bit'),0)			AS IsTotalAmountEdited,
				0																			AS GDNDetailsId
			FROM @XMLGDN.nodes('/RowSet/Row') TEMP(I); 
		END 
 		SELECT @GDNRecordCount=COUNT(*) FROM @TempGDNItems; 
		SET @GDNRecordCount=ISNULL(@GDNRecordCount,0);

		IF @XMLGDNStockDetails<>'' AND @XMLGDNStockDetails is NOT NULL
		BEGIN
			SET @XMLStock = CAST(@XMLGDNStockDetails as XML); 
			SELECT  identity(int,1,1)														AS RowNumber,
			    ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)					AS ProductId,
				ISNULL(TEMP.I.value('(WarehouseId/text())[1]', 'Int'),0)					AS WarehouseId, 
				ISNULL(TEMP.I.value('(LocatorId/text())[1]', 'Int'),0)						AS LocatorId,
				ISNULL(TEMP.I.value('(BatchNo/text())[1]', 'varchar(50)'),0)	 			AS BatchNo, 
				ISNULL(TEMP.I.value('(InStock/text())[1]', 'decimal(24,5)'),null)			AS InStock  ,			
				ISNULL(TEMP.I.value('(OutStock/text())[1]', 'decimal(24,5)'),0)				AS OutStock,
				ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)							AS UOMId,	
				ISNULL(TEMP.I.value('(ConversionValue/text())[1]', 'decimal(24,5)'),0)		AS ConversionValue,
				ISNULL(TEMP.I.value('(PurchaseRate/text())[1]', 'decimal(24,5)'),0)			AS PurchaseRate, 
				ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)			AS SalesRate,
				ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)	   		AS CostPrice, 
				ISNULL(TEMP.I.value('(ReferencNo/text())[1]', 'varchar(50)'),0)				AS ReferencNo ,
				ISNULL(TEMP.I.value('(StockDescription/text())[1]','varchar(MAX)'),0)		AS StockDescription ,
				ISNULL(TEMP.I.value('(Remarks/text())[1]', 'varchar(MAX)'),0)				AS Remarks,
				ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'varchar(50)'),'')			AS StockBatchNo,
				TEMP.I.value('(ExpiryDate/text())[1]', 'Date')								AS ExpiryDate,
				ISNULL(TEMP.I.value('(RowId/text())[1]', 'Int'),0)							as RowId,
				CONVERT(bigint ,0)															as StockDetailsId
			INTO #TempSDetails FROM @XMLStock.nodes('/RowSet/Row') TEMP(I); 
		END 
 		IF OBJECT_ID(N'tempdb..#TempSDetails') IS NOT NULL SELECT @GDNStockRecordCount=COUNT(*) FROM #TempSDetails; 
				
		INSERT INTO @TempGDNBundles
		(
			GDNRowId,BundleId,ProductId,WarehouseId,LocatorId,Quantity,UOMId,SalesRate,BundleQty
		)
		SELECT	
			TB.ProductRowId,TB.BundleId,TB.ProductId,TB.WarehouseId,	 
			TB.LocatorId,TB.Quantity,TB.UOMId,TB.SalesRate,TD.Quantity		
		FROM [ERP.Inventory].TempSalesInvoiceBundleDetails TB
			JOIN @TempDetails TD ON TB.ProductRowId=TD.InvRowId AND TB.BundleId=TD.BundleId
		WHERE TB.BranchId=@BranchId AND TB.PageSessionId=@PageSessionId AND TD.IsBatchOverRide=1
		
		SET @XMLBundle = CAST(@XMLGDNBundleDetails as XML); 

		INSERT INTO @TempGDNBundles(GDNRowId,BundleId,ProductId,WarehouseId,LocatorId,Quantity,UOMId,SalesRate,BundleQty)
		SELECT	
			ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)					as GDNRowId, 
			ISNULL(TEMP.I.value('(BundleId/text())[1]', 'bigint'),0)	 		as BundleId, 
			ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)			as ProductId,
			ISNULL(TEMP.I.value('(WarehouseId/text())[1]', 'int'),null)			as WarehouseId  ,	 
			ISNULL(TEMP.I.value('(LocatorId/text())[1]', 'int'),null)			as LocatorId  ,			
			ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)		as Quantity,
			ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			        as UOMId,	
			ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)	as SalesRate,
			TD.Quantity															as BundleQty
		FROM @XMLBundle.nodes('/RowSet/Row') TEMP(I)
			JOIN @TempDetails TD ON TEMP.I.value('(RowId/text())[1]', 'int')=TD.InvRowId AND TD.IsBatchOverRide=0
		 
		INSERT INTO @TempSIBundles
		(
			SIRowId,BundleId,ProductId,WarehouseId,LocatorId,Quantity,UOMId,SalesRate,
			SalesRateInCustCurrency,SalesRateIncludVAT,SalesRateIncludVATCustCurrency,BundleQty
		)
		SELECT	
			TB.ProductRowId,TB.BundleId,TB.ProductId,TB.WarehouseId,TB.LocatorId,TB.Quantity,TB.UOMId,TB.SalesRate,
			TB.SalesRateCustCurrency,TB.SalesRateIncludVAT,TB.SalesRateIncludVATCustCurrency,TD.Quantity
		FROM [ERP.Inventory].TempSalesInvoiceBundleDetails TB
			JOIN @TempDetails TD ON TB.ProductRowId=TD.InvRowId AND TB.BundleId=TD.BundleId 
		WHERE TB.BranchId=@BranchId AND TB.PageSessionId=@PageSessionId AND TD.IsBatchOverRide=1
		
		SET @XMLSIBundle = CAST(@XMLSalesInvoiceBundleDetails as XML); 

		INSERT INTO @TempSIBundles
		(
			SIRowId,BundleId,ProductId,WarehouseId,LocatorId,Quantity,UOMId,SalesRate,
			SalesRateInCustCurrency,SalesRateIncludVAT,SalesRateIncludVATCustCurrency,BundleQty
		)
		SELECT	
			ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)					as SIRowId, 
			ISNULL(TEMP.I.value('(BundleId/text())[1]', 'bigint'),0)	 		as BundleId, 
			ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)			as ProductId,
			ISNULL(TEMP.I.value('(WarehouseId/text())[1]', 'int'),null)			as WarehouseId  ,	 
			ISNULL(TEMP.I.value('(LocatorId/text())[1]', 'int'),null)			as LocatorId  ,			
			ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)		as Quantity,
			ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			        as UOMId,	
			ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)	as SalesRate,
			ISNULL(TEMP.I.value('(SalesRateInCustCurrency/text())[1]', 'decimal(24,5)'),0)			as SalesRateInCustCurrency,
			ISNULL(TEMP.I.value('(SalesRateIncludVAT/text())[1]', 'decimal(24,5)'),0)				as SalesRateIncludVAT,
			ISNULL(TEMP.I.value('(SalesRateIncludVATCustCurrency/text())[1]', 'decimal(24,5)'),0)	as SalesRateIncludVATCustCurrency,
			TD.Quantity															as BundleQty													
		FROM @XMLSIBundle.nodes('/RowSet/Row') TEMP(I)
			JOIN @TempDetails TD ON TEMP.I.value('(RowId/text())[1]', 'int')=TD.InvRowId AND TD.IsBatchOverRide=0
		 		
		SELECT @BRecordCount= COUNT(*) FROM @TempSIBundles
		
		IF @XMLGDNBatchDetails<>'' AND @XMLGDNBatchDetails is NOT NULL
		BEGIN
			SET @XMlGDNBatch = CAST(@XMLGDNBatchDetails as XML); 
			INSERT INTO @TempGDNBatches
			(
				GDNRowId,ProductId,StockBatchNo,Quantity,SalesRate,CostPrice,UOMId,ExpiryDate
			)
			SELECT	
				ISNULL(TEMP.I.value('(RowId/text())[1]', 'int'),0)					as GDNRowId, 
				ISNULL(TEMP.I.value('(ProductId/text())[1]', 'bigint'),0)	 		as ProductId, 
				ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'varchar(50)'),0)	as StockBatchNo,
				ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)		as Quantity,
				ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)	as SalesRate,
				ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)	as CostPrice,
				ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)	as UOMId,
				TEMP.I.value('(ExpiryDate/text())[1]', 'date')	as ExpiryDate
			FROM @XMLGDNBatch.nodes('/RowSet/Row') TEMP(I); 
		END 
		---------------------------BOM products--------------------------------
		--IF @XMLBOMStockDetails<>'' AND @XMLBOMStockDetails is NOT NULL
		--BEGIN
		--	SET @XMLBOMStock = CAST(@XMLBOMStockDetails as XML); 
		--	SELECT  identity(int,1,1)													as RowNumber,
		--	    ISNULL(TEMP.I.value('(BOMId/text())[1]', 'bigint'),0)					as BOMId,
		--		ISNULL(TEMP.I.value('(WarehouseId/text())[1]', 'Int'),0)				as WarehouseId, 
		--		ISNULL(TEMP.I.value('(LocatorId/text())[1]', 'Int'),0)					as LocatorId,
		--		ISNULL(TEMP.I.value('(ManufacturingDate/text())[1]', 'Date'),'')	 	as ManufacturingDate, 
		--		ISNULL(TEMP.I.value('(InStock/text())[1]', 'decimal(24,5)'),0)			as InStock  ,			
		--		ISNULL(TEMP.I.value('(OutStock/text())[1]', 'decimal(24,5)'),0)			as OutStock,
		--		ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            as UOMId,	
		--		ISNULL(TEMP.I.value('(PurchaseRate/text())[1]', 'decimal(24,5)'),0)		as PurchaseRate, 
		--		ISNULL(TEMP.I.value('(SalesRate/text())[1]', 'decimal(24,5)'),0)		as SalesRate,
		--		ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)	   	as CostPrice, 
		--		ISNULL(TEMP.I.value('(ReferenceNo/text())[1]', 'varchar(50)'),'')		as ReferenceNo ,
		--		ISNULL(TEMP.I.value('(StockDescription/text())[1]','varchar(500)'),'')	as StockDescription ,
		--		ISNULL(TEMP.I.value('(Remarks/text())[1]', 'varchar(500)'),'')			as Remarks --,
		--		--CONVERT(DECIMal(24,5),0) as RequiredQty,
		--		--CONVERT(Decimal(24,5),0) as DeliveredQty
		--	INTO #TempBOMStockDetails FROM @XMLBOMStock.nodes('/RowSet/Row') TEMP(I); 
		--END 
 	--	IF OBJECT_ID(N'tempdb..#TempBOMStockDetails') IS NOT NULL SELECT @BOMStockRecordCount=COUNT(*) FROM #TempBOMStockDetails; 

		--- convert Xl to table
		IF @XMLMixedReceiptDetails<>'' AND @XMLMixedReceiptDetails is NOT NULL
		BEGIN
			SET @MixedModeXML = CAST(@XMLMixedReceiptDetails as XML);
			INSERT INTO @TempCustomerMixedReceiptDetails
			SELECT	
				ISNULL(TEMP.I.value('(PaymentMethodId/text())[1]', 'int'),0)					as PaymentMethodId,
				ISNULL(TEMP.I.value('(ChequeNo/text())[1]', 'varchar(50)'),'')					as ChequeNo,
				ISNULL(TEMP.I.value('(ChequeDate/text())[1]', 'Date'),'')						as ChequeDate,
				ISNULL(TEMP.I.value('(ChequeDetails/text())[1]', 'nvarchar(500)'),'')			as ChequeDetails,
				ISNULL(TEMP.I.value('(AccountId/text())[1]', 'int'),0)							as AccountId,
				ISNULL(TEMP.I.value('(BankAccountId/text())[1]', 'int'),0)						as BankAccountId,
				ISNULL(TEMP.I.value('(CardNo/text())[1]', 'varchar(50)'),'')					as CardNo,
				ISNULL(TEMP.I.value('(Remarks/text())[1]', 'nvarchar(1000)'),'')				as Remarks,
				ISNULL(TEMP.I.value('(Amount/text())[1]', 'decimal(24,5)'),0)					as Amount,
				ISNULL(TEMP.I.value('(AmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		as AmountInCustCurrency,
				ISNULL(TEMP.I.value('(BankCurrencyId/text())[1]', 'int'),0)						as BankCurrencyId,
				ISNULL(TEMP.I.value('(BankCurrencyRate/text())[1]', 'decimal(24,5)'),0)			as BankCurrencyRate,
				ISNULL(TEMP.I.value('(AmountInBankCurrency/text())[1]', 'decimal(24,5)'),0)		as AmountInBankCurrency
			FROM @MixedModeXML.nodes('/RowSet/Row') TEMP(I);
		END
		SELECT @MixedModeRecordCount=COUNT(*) FROM @TempCustomerMixedReceiptDetails;

		----------------Project ----------------
		IF @XMLProjectDetails<>'' AND @XMLProjectDetails is NOT NULL
		BEGIN
			SET @XMLProject = CAST(@XMLProjectDetails as XML);
			INSERT INTO @TempProjectDetails
			SELECT	
				ISNULL(TEMP.I.value('(SerialNo/text())[1]', 'int'),0)								as SerialNo,
				ISNULL(TEMP.I.value('(CSOId/text())[1]', 'bigint'),0)								as CSOId,
				ISNULL(TEMP.I.value('(Description/text())[1]', 'nvarchar(MAX)'),'')					as Description,
				ISNULL(TEMP.I.value('(DescriptionArabic/text())[1]', 'nvarchar(MAX)'),'')			as DescriptionArabic,
				ISNULL(TEMP.I.value('(InvoiceAmount/text())[1]', 'decimal(24,5)'),0)				as InvoiceAmount,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)				as DiscountAmount,
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)			as DiscountPercentage,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)							as DiscountType,
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)									as TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)					as TaxAmount,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)					as TotalAmount,
				ISNULL(TEMP.I.value('(InvoiceAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as InvoiceAmountInCustCurrency,
				ISNULL(TEMP.I.value('(DiscountAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as DiscountAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TaxAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TaxAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TotalAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as TotalAmountInCustCurrency,
				ISNULL(TEMP.I.value('(ProjectJobId/text())[1]', 'bigint'),0)						as ProjectJobId,
				ISNULL(TEMP.I.value('(CompletionPercentage/text())[1]', 'decimal(24,5)'),0)			as CompletionPercentage,
				ISNULL(TEMP.I.value('(QtyInScope/text())[1]', 'decimal(24,5)'),0)					as QtyInScope,
				ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)									as UOMId
			FROM @XMLProject.nodes('/RowSet/Row') TEMP(I);
			UPDATE @TempProjectDetails SET UOMId= NULL WHERE UOMId =0
		END
		SELECT @ProjectRecordCount=COUNT(*) FROM @TempProjectDetails;
	
		----------------Project bill ----------------
		IF @XMLProjectBillDetails<>'' AND @XMLProjectBillDetails is NOT NULL
		BEGIN
			SET @XMLProjectBill = CAST(@XMLProjectBillDetails as XML);
			INSERT INTO @TempProjectBillDetails
			SELECT	
				ISNULL(TEMP.I.value('(SerialNo/text())[1]', 'int'),0)								as SerialNo,
				ISNULL(TEMP.I.value('(ProjectJobId/text())[1]', 'bigint'),0)						as ProjectJobId,
				ISNULL(TEMP.I.value('(WorkType/text())[1]', 'varchar(2)'),'')						as WorkType,
				ISNULL(TEMP.I.value('(ItemDescription/text())[1]', 'nvarchar (max)'),'')			as ItemDescription,
				ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)						as Quantity,
				ISNULL(TEMP.I.value('(UOM/text())[1]', 'varchar(100)'),0)							as UOM,
				ISNULL(TEMP.I.value('(Rate/text())[1]', 'decimal(24,5)'),0)							as Rate,
				ISNULL(TEMP.I.value('(InvoiceAmount/text())[1]', 'decimal(24,5)'),0)				as InvoiceAmount,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)				as DiscountAmount,
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)			as DiscountPercentage,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)							as DiscountType,
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)									as TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)					as TaxAmount,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)					as TotalAmount,
				ISNULL(TEMP.I.value('(RateInCustCurrency/text())[1]', 'decimal(24,5)'),0)			as RateInCustCurrency,
				ISNULL(TEMP.I.value('(InvoiceAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as InvoiceAmountInCustCurrency,
				ISNULL(TEMP.I.value('(DiscountAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as DiscountAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TaxAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TaxAmountInCustCurrency,
				ISNULL(TEMP.I.value('(TotalAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)	as TotalAmountInCustCurrency,
				ISNULL(TEMP.I.value('(ProjectJobBillDetailsId/text())[1]', 'bigint'),0)				as ProjectJobBillDetailsId,
				ISNULL(TEMP.I.value('(Remarks/text())[1]', 'varchar (max)'),0)						as Remarks,
				ISNULL(TEMP.I.value('(ItemName/text())[1]', 'varchar (1000)'),'')					as ItemName,
				ISNULL(TEMP.I.value('(ItemNameArabic/text())[1]', 'nvarchar (1000)'),'')				as ItemNameArabic,
				ISNULL(TEMP.I.value('(ItemDescriptionArabic/text())[1]', 'nvarchar (max)'),'')		as ItemDescriptionArabic
			FROM @XMLProjectBill.nodes('/RowSet/Row') TEMP(I);
		END
		SELECT @ProjectBillCount=COUNT(*) FROM @TempProjectBillDetails;

		
		IF @XMLRetentionInvoice<>'' AND @XMLRetentionInvoice is NOT NULL
		BEGIN
			SET @XMLRetention = CAST(@XMLRetentionInvoice as XML);
			INSERT INTO @TempRetentionInvoice
			SELECT  
				ISNULL(TEMP.I.value('(RetentionInvoiceDetailsId/text())[1]', 'bigint'),0)					as RetentionInvoiceDetailsId,
				ISNULL(TEMP.I.value('(SerialNo/text())[1]', 'int'),0)										as SerialNo, 
				ISNULL(TEMP.I.value('(RetentionAccountId/text())[1]', 'bigint'),0)							as RetentionAccountId,
				ISNULL(TEMP.I.value('(Description/text())[1]', 'varchar(MAX)'),'')							as Description, 
				ISNULL(TEMP.I.value('(DescriptionArabic/text())[1]', 'nvarchar(MAX)'),'')					as DescriptionArabic,
				ISNULL(TEMP.I.value('(TotalContractValue/text())[1]', 'Decimal(24,5)'),0)					as TotalContractValue,
				ISNULL(TEMP.I.value('(TotalInvoicedAmount/text())[1]', 'Decimal(24,5)'),0)					as TotalInvoicedAmount,	
				ISNULL(TEMP.I.value('(RetentionPercentage/text())[1]', 'Decimal(24,5)'),0)					as RetentionPercentage,
				ISNULL(TEMP.I.value('(RetentionAmount/text())[1]', 'decimal(24,5)'),0)						as RetentionAmount,
				ISNULL(TEMP.I.value('(CumulativeAmount/text())[1]', 'Decimal(24,5)'),0)			            as CumulativeAmount,		
				ISNULL(TEMP.I.value('(BalanceRetentionAmount/text())[1]', 'decimal(24,5)'),0)				as BalanceRetentionAmount,
				ISNULL(TEMP.I.value('(ReceivedAmount/text())[1]', 'decimal(24,5)'),0)						as ReceivedAmount,
				ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)									as DiscountType,
				ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)					as DiscountPercentage,
				ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)						as DiscountAmount,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)							as TotalAmount ,
				ISNULL(TEMP.I.value('(TotalContractValueCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TotalContractValueCustCurrency,	
				ISNULL(TEMP.I.value('(TotalInvoicedAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TotalInvoicedAmountCustCurrency,	
				ISNULL(TEMP.I.value('(RetentionAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)			as RetentionAmountCustCurrency ,
				ISNULL(TEMP.I.value('(CumulativeAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)		as CumulativeAmountCustCurrency 	,
				ISNULL(TEMP.I.value('(BalanceRetentionAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)	as BalanceRetentionAmountCustCurrency,
				ISNULL(TEMP.I.value('(ReceivedAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)			as ReceivedAmountCustCurrency,
				ISNULL(TEMP.I.value('(DiscountAmountInCustCurrency/text())[1]', 'decimal(24,5)'),0)			as DiscountAmountCustCurrency,
				ISNULL(TEMP.I.value('(TotalAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)				as TotalAmountCustCurrency,
				ISNULL(TEMP.I.value('(Remarks/text())[1]', 'nvarchar(MAX)'),'')								as Remarks,
				ISNULL(TEMP.I.value('(Name/text())[1]', 'varchar(500)'),'')									as Name,
				ISNULL(TEMP.I.value('(NameArabic/text())[1]', 'nvarchar(500)'),'')							as NameArabic
			FROM @XMLRetention.nodes('/RowSet/Row') TEMP(I);
		END
	
		SELECT @RetentionCount=COUNT(*) FROM @TempRetentionInvoice;
		
		INSERT INTO @TempTimesheet
		SELECT	
			ISNULL(TEMP.I.value('(SalesInvoiceTimeSheetId/text())[1]', 'bigint'),0)			as SalesInvoiceTimeSheetId, 
			ISNULL(TEMP.I.value('(TimeSheetTabulationId/text())[1]', 'bigint'),0)	 		as TimeSheetTabulationId, 
			ISNULL(TEMP.I.value('(TimeSheetTabulationDetailsId/text())[1]', 'bigint'),'')	as TimeSheetTabulationDetailsId,
			ISNULL(TEMP.I.value('(EmployeeId/text())[1]', 'bigint'),0)						as EmployeeId,
			ISNULL(TEMP.I.value('(SalaryCalculationType/text())[1]', 'varchar(1)'),'')		as SalaryCalculationType,
			ISNULL(TEMP.I.value('(ProjectJobId/text())[1]', 'bigint'),0)					as ProjectJobId,
			ISNULL(TEMP.I.value('(LocationId/text())[1]', 'int'),0)							as LocationId,
			ISNULL(TEMP.I.value('(WorkedHr/text())[1]', 'decimal(24,5)'),0)					as WorkedHr,
			ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)				as TotalAmount,
			ISNULL(TEMP.I.value('(WorkedOTHr/text())[1]', 'decimal(24,5)'),0)				as WorkedOTHr,
			ISNULL(TEMP.I.value('(TotalOTAmount/text())[1]', 'decimal(24,5)'),0)			as TotalOTAmount,
			ISNULL(TEMP.I.value('(NetAmount/text())[1]', 'decimal(24,5)'),0)				as NetAmount,
			ISNULL(TEMP.I.value('(Remarks/text())[1]', 'nvarchar(MAX)'),'')					as Remarks,
			ISNULL(TEMP.I.value('(DiscountType/text())[1]', 'int'),0)						as DiscountType,
			ISNULL(TEMP.I.value('(DiscountPercentage/text())[1]', 'decimal(24,5)'),0)		as DiscountPercentage,
			ISNULL(TEMP.I.value('(DiscountAmount/text())[1]', 'decimal(24,5)'),0)			as DiscountAmount
		FROM @XMLTimesheet.nodes('/RowSet/Row') TEMP(I); 

		SELECT @TimesheetCount=COUNT(*) FROM @TempTimesheet

		-----------------------Invoice Advance---------------------------------

		IF @XMLAdvanceInvoice<>'' AND @XMLAdvanceInvoice is NOT NULL
		BEGIN
			SET @XMLAI = CAST(@XMLAdvanceInvoice as XML);
			INSERT INTO @TempAdvanceInvoice
			SELECT
			    ISNULL(TEMP.I.value('(CustAdvanceTransId/text())[1]', 'bigint'),0)					as CustAdvanceTransId, 
				ISNULL(TEMP.I.value('(AdvanceAmount/text())[1]', 'decimal(24,5)'),0)				as AdvanceAmount, 
				ISNULL(TEMP.I.value('(AllottedAmount/text())[1]', 'decimal(24,5)'),0)				as AllottedAmount,
				ISNULL(TEMP.I.value('(Description/text())[1]', 'varchar(500)'),'')					as Description, 
				ISNULL(TEMP.I.value('(CurrencyRate/text())[1]', 'decimal(24,5)'),0)					as CurrencyRate,
				ISNULL(TEMP.I.value('(AdvanceAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)	as AdvanceAmountCustCurrency,
				ISNULL(TEMP.I.value('(AllottedAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)	as AllottedAmountCustCurrency,
				ISNULL(TEMP.I.value('(SalesInvoiceId/text())[1]', 'bigint'),0)						as SalesInvoiceId,
				ISNULL(TEMP.I.value('(TaxId/text())[1]', 'int'),0)									as TaxId,
				ISNULL(TEMP.I.value('(TaxAmount/text())[1]', 'decimal(24,5)'),0)					as TaxAmount,
				ISNULL(TEMP.I.value('(TotalAmount/text())[1]', 'decimal(24,5)'),0)					as TotalAmount,
				ISNULL(TEMP.I.value('(AllottedTaxAmount/text())[1]', 'decimal(24,5)'),0)			as AllottedTaxAmount,
				ISNULL(TEMP.I.value('(TaxAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TaxAmountCustCurrency,
				ISNULL(TEMP.I.value('(TotalAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TotalAmountCustCurrency,
				ISNULL(TEMP.I.value('(AllottedTaxAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)as AllottedTaxAmountCustCurrency
			FROM @XMLAI.nodes('/RowSet/Row') TEMP(I)
		END
		SELECT @AdvanceInvoiceCount=COUNT(*) FROM @TempAdvanceInvoice

		IF @XMLAdvance<>'' AND @XMLAdvance is NOT NULL
		BEGIN
			SET @XMLD = CAST(@XMLAdvance as XML);
			INSERT INTO @TempAdvance
			SELECT	
				ISNULL(TEMP.I.value('(CustAdvanceTransId/text())[1]', 'bigint'),0)					as CustAdvanceTransId,
				TEMP.I.value('(CustomerReceiptId/text())[1]', 'bigint'	)							as CustomerReceiptId,
				TEMP.I.value('(CustOpeningBalanceId/text())[1]', 'bigint')							as CustOpeningBalanceId,
				ISNULL(TEMP.I.value('(TakenAmount/text())[1]', 'decimal(24,5)'),0)					as TakenAmount,
				TEMP.I.value('(CreditNoteId/text())[1]', 'bigint'	)								as CreditNoteId,
				ISNULL(TEMP.I.value('(TakenAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)		as TakenAmountCustCurrency,
				ISNULL(TEMP.I.value('(TakenTaxAmount/text())[1]', 'decimal(24,5)'),0)				as TakenTaxAmount,
				ISNULL(TEMP.I.value('(TakenTaxAmountCustCurrency/text())[1]', 'decimal(24,5)'),0)	as TakenTaxAmountCustCurrency,
				TEMP.I.value('(CostCenterId/text())[1]', 'int'	)									as CostCenterId
			FROM @XMLD.nodes('/RowSet/Row') TEMP(I);
		END
		
		SELECT @AdvanceCount=COUNT(*) FROM @TempAdvance

		IF @XMLAddOnsDetails<>'' AND @XMLAddOnsDetails is NOT NULL
		BEGIN
			SET @XMLAddOns = CAST(@XMLAddOnsDetails as XML);
			INSERT INTO @TempAddOnsDetails
			SELECT	
				ISNULL(TEMP.I.value('(AddOnsSettingsId/text())[1]', 'int'),0)						as AddOnsSettingsId,
				ISNULL(TEMP.I.value('(AddOnsSettingsValue/text())[1]', 'nvarchar(2000)'),'')			as AddOnsSettingsValue,
				ISNULL(TEMP.I.value('(AddOnsSettingsValueArabic/text())[1]', 'nvarchar(2000)'),'')	as AddOnsSettingsValueArabic
			FROM @XMLAddons.nodes('/RowSet/Row') TEMP(I);
		END
		SELECT @AddOnrecordCount=COUNT(*) FROM @TempAddOnsDetails

		---------------------check InvoiceFromSalesOrder-----------------------
		SET @InvoiceFromSalesOrder=CONVERT(BIT,(ISNULL(([ERP.Config].Fun_GetGeneralSettingsValue(@BranchId,'InvoiceFromSalesOrder')),0)));

		--IF @BOMStockRecordCount>0
		--BEGIN
		--	UPDATE #TempBOMStockDetails SET CostPrice= ISNULL((SELECT CostPrice FROM [ERP.Inventory].BillOfMaterial WHERE  (BOMId = #TempBOMStockDetails.BOMId)),0)
		--END

		------------Update bankaccount value if Any BankAccountExist-----------
		IF @RecordCount>0
		BEGIN
			UPDATE @TempDetails SET BankAccountId=ISNULL([ERP.Finance].BankAccounts.BankAccountId,0)
			FROM @TempDetails as Temp 
			INNER JOIN [ERP.Finance].BankAccounts ON Temp.AccountId=[ERP.Finance].BankAccounts.AccountId
			WHERE Temp.PaymentMethodId IN (2,3,4) AND Temp.AccountId>0

			UPDATE @TempDetails SET CostPrice=ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate](Temp.ProductId,@SalesInvoiceDate),0)*PUOM.ConversionValue
			FROM @TempDetails as Temp 
			INNER JOIN [ERP.Inventory].ProductUOM as PUOM ON Temp.ProductId=PUOM.ProductId  AND Temp.UOMId=PUOM.UOMId
		END
		--select * from @tempDetails


		--------- add Currency Rate  (If there is no currency rate with effective date) ---------------------
		DECLARE @CurrencyRecordCount int
		SELECT @CurrencyRecordCount= COUNT(*) FROM [ERP.Config].CurrencyRate 
		WHERE (BranchId=@BranchId) AND (EffectiveDate <= @SalesInvoiceDate) AND (CurrencyId=@CurrencyId) AND (IsActive = 1)
		IF @CurrencyRecordCount = 0 OR @CurrencyRecordCount IS NULL
		BEGIN
			INSERT INTO [ERP.Config].CurrencyRate
            (
				BranchId, CurrencyId, EffectiveDate, Rate, IsActive
			)
			VALUES 
			(
				@BranchId,@CurrencyId,@SalesInvoiceDate,@CurrencyRate, 1
			)	
		END
		
		----------------------------------------------------------------------------------------------

		-------------- create new GDN if new items are there in SI details
	
		IF @SalesInvoiceId>0 AND @IsDirectInvoice=1
		BEGIN
			SELECT TOP(1) @GDNId=GDNId 	FROM [ERP.Inventory].SalesInvoiceGDNs 
			WHERE (SalesInvoiceId = @SalesInvoiceId) ORDER BY SalesInvoiceGDNId DESC;
		END
		ELSE 
			SET @GDNId=0

		---For MobileApp entry
		IF @IsMobileAppEntry=1
		BEGIN
			SELECT @DepartmentId= DepartmentId  
			FROM [ERP.Config].[AppUserDepartments]
			WHERE UserId=@CreatedBy and IsDefault=1
		END
		
		IF @GDNRecordCount>0 AND @IsDirectInvoice=1
		BEGIN
			SET @GDNTotalQuantity=ISNULL((SELECT SUM(Quantity) FROM @TempGDNItems),0);
			
			-----  update XML whether products are service or not
			UPDATE @TempGDNItems SET IsService=Product.IsService	
			FROM [ERP.Inventory].Product as Product INNER JOIN @TempGDNItems as TempGDNItems 
			ON (Product.ProductId = TempGDNItems.ProductId)
			
			SELECT @IsNonServiceCount=COUNT(*) FROM @TempGDNItems WHERE IsService=0;
		 
			IF @GDNId=0
			BEGIN
				SET @FinYear=[ERP.Config].[Fun_GetFinancialYearCombination](@BranchId,@SalesInvoiceDate);				--- get financial year	
				
				-- generate GDNNo 
				EXEC [ERP.Config].[GenerateNewNumber] @GDNNo OUT,@GDNSettingsId,@BranchId,@FinYear;
				
				IF @GDNNo<>''
				BEGIN
					INSERT INTO [ERP.Inventory].GoodsDeliveryNote
					(
						BranchId, GDNDate, GDNNo, ReferenceNo, CustomerId, TotalQuantity, DeliveryMethodId, 
						ShipmentAddress1,  Note, DeliveredBy, SalesStatusId, CreatedBy, CreatedDate, EditedBy, 
						EditedDate, EntryStatus,SalesManUserId,DeliveryPeriod,[Type], CSOId,CSODescription,
						CashCustomerName,CashCustomerVATNo,PODate,DepartmentId
					)
					VALUES 
					(
						@BranchId,@SalesInvoiceDate,@GDNNo,@ReferenceNo,@CustomerId,@GDNTotalQuantity,@DeliveryMethodId,
						@ShipmentAddress1,'Direct GDN From salesInvoice',@CreatedBy,'I',@CreatedBy, GETDATE(),@CreatedBy, 
						GETDATE(), 'A',@SalesManUserId,@DeliveryPeriod,@Type,@CSOId,@CSODescription,@CashCustomerName,
						@CashCustomerVATNo,@PODate,@DepartmentId
					)

					SET @GDNId=SCOPE_IDENTITY();    
				
					IF @IsNonServiceCount>0 AND @GDNStockRecordCount>0 AND @SalesStatusId<>'O'
					BEGIN
						---insert into stock
						INSERT INTO [ERP.Inventory].Stock 
						(
							BranchId,StockDate, StockTransactionTypeId,TransactionId, StockStatus,ReferencNo, 
							Notes,Remarks, CreatedBy,CreatedDate,EditedBy,EditedDate,EntryStatus
						)
						VALUES 
						(
							@BranchId,@SalesInvoiceDate,@GDNStockTransactionTypeId,@GDNId,'A',@ReferenceNo,
							@Notes,'',@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A'
						)   
					
						SET @StockId=SCOPE_IDENTITY();   
					END		--- end of @SalesStatusId<>'O'
				END			--- End of @GDNNo<>'0'
			END					-- end of @SalesInvoiceId>0
			ELSE
			BEGIN
				----------update deleted BOMId status as I - requirement by Manju on 20/05/2020-done by Lathika-------------
				UPDATE [ERP.Inventory].BillOfMaterial SET DeliveryStatus='I' 
				FROM [ERP.Inventory].BillOfMaterial WHERE BOMId IN (SELECT BOMId FROM [ERP.Inventory].GoodsDeliveryNoteDetails WHERE GDNId=@GDNId)
				AND BOMId NOT IN (SELECT BOMId FROM @TempDetails WHERE BOMId>0) 
				
			   ----- delete and insert Goods Delivery Note BundleDetails
				DELETE FROM [ERP.Inventory].GoodsDeliveryNoteBundleDetails WHERE GDNDetailsId IN
				(SELECT GDNDetailsId FROM  [ERP.Inventory].GoodsDeliveryNoteDetails WHERE  (GDNId = @GDNId))

				----- delete and insert Goods Delivery Note batch
				DELETE FROM [ERP.Inventory].GDNBatchAndSerialDetails WHERE GDNDetailsId IN
				(SELECT GDNDetailsId FROM  [ERP.Inventory].GoodsDeliveryNoteDetails WHERE  (GDNId = @GDNId))

		        --for update delete and reinsert details table data
			 	DELETE FROM  [ERP.Inventory].GoodsDeliveryNoteDetails WHERE  (GDNId = @GDNId);	

				--- to get GDN No for log
				SELECT @GDNNo=GDNNo FROM [ERP.Inventory].GoodsDeliveryNote WHERE (GDNId = @GDNId);

				UPDATE [ERP.Inventory].GoodsDeliveryNote
				SET BranchId = @BranchId, GDNDate = @SalesInvoiceDate, GDNNo = @GDNNo, ReferenceNo = @ReferenceNo, 
					CustomerId = @CustomerId, TotalQuantity = @GDNTotalQuantity, DeliveryMethodId = @DeliveryMethodId, 
                    ShipmentAddress1 = @ShipmentAddress1,  
					Note = 'Direct GDN From salesInvoice', DeliveredBy = @CreatedBy, 
					SalesStatusId = 'I', EditedBy = @CreatedBy, EditedDate = GETDATE(),SalesManUserId=@SalesManUserId,
					DeliveryPeriod=@DeliveryPeriod,[Type]=@Type,CSOId=@CSOId,CSODescription=@CSODescription,
					CashCustomerName=@CashCustomerName,CashCustomerVATNo=@CashCustomerVATNo,PODate=@PODate,
					DepartmentId=@DepartmentId
			    WHERE (GDNId = @GDNId);

				SET @EditedBy=@CreatedBy
				SET @Action='E'
				
				IF @SalesStatusId<>'O'				--- update stock only id Invoice status is SubMit or received
				BEGIN
					SET @StockId = ISNULL((select StockId from [ERP.Inventory].Stock 
					where TransactionId=@GDNId AND StockTransactionTypeId=@GDNStockTransactionTypeId),0)

					IF @StockId =0 AND @IsNonServiceCount>0 AND @GDNStockRecordCount>0  
					BEGIN
						---insert into stock
						INSERT INTO [ERP.Inventory].Stock 
						(
							BranchId,StockDate, StockTransactionTypeId,TransactionId, StockStatus,
							ReferencNo, Notes,Remarks, CreatedBy,CreatedDate,EditedBy,EditedDate,EntryStatus
						)
						VALUES 
						(
							@BranchId,@SalesInvoiceDate,@GDNStockTransactionTypeId,@GDNId,'A',@ReferenceNo,
							@Notes,'',@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A'
						)   
					
						SET @StockId=SCOPE_IDENTITY(); 
					END
					ELSE IF @StockId>0  
					BEGIN
						IF @IsNonServiceCount=0 OR @GDNStockRecordCount=0
						BEGIN
							UPDATE [ERP.Inventory].Stock SET EntryStatus='D' WHERE (StockId = @StockId);
						END
						ELSE
						BEGIN
							 --- fetch productId from Product summary update
							INSERT INTO @TblProductStock(ProductId)
							SELECT ProductId FROM [ERP.Inventory].StockDetails  WHERE  (StockId = @StockId);

							--for update delete and reinsert details stock details table data

							DELETE FROM [ERP.Inventory].StockBatchAndSerialDetails WHERE StockDetailsId IN (SELECT StockDetailsId FROM  [ERP.Inventory].StockDetails WHERE  (StockId = @StockId))

			 				DELETE FROM  [ERP.Inventory].StockDetails WHERE  (StockId = @StockId);	

							UPDATE [ERP.Inventory].Stock
							   SET StockDate = @SalesInvoiceDate,Notes = @Notes, ReferencNo=@ReferenceNo, EditedBy=@CreatedBy,EditedDate=GETDATE(),EntryStatus='A'
							WHERE (StockId = @StockId);
						END
					END---- end of StockId>0
				END----- end of @SalesStatusId<>'O'
			END
						
			IF @GDNId>0 --AND @StockId >0
			BEGIN	  
				SET @RowNumber=1
				WHILE @RowNumber<=@RecordCount
				BEGIN
					SELECT @RowId=GDNRowId FROM @TempGDNItems WHERE RowNumber=@RowNumber;
					
					INSERT INTO [ERP.Inventory].GoodsDeliveryNoteDetails
					(
						GDNId,ProductId,BundleId,WarehouseId,LocatorId,Quantity,UOMId,SalesRate,DiscountAmount,
						DiscountPercentage,DiscountType,TotalAmount,DeliveryDate, [Description],DescriptionArabic,
						IsActive,TaxId,TaxAmount,SerialNumber,IsComponent,BOMId,IsFreeItem,IsTotalAmountEdited
					)
					SELECT 
						@GDNId,
						case when  ProductId='' OR ProductId=0 then NULL else ProductId end,		
						case when  BundleId='' OR BundleId=0 then NULL else BundleId end ,
						case when  WarehouseId='' OR WarehouseId=0 then null else WarehouseId end,	
						case when LocatorId='' OR LocatorId=0 then NULL else LocatorId end,
						Quantity,case when  UOMId='' then null else UOMId end, SalesRate,DiscountAmount, 
						DiscountPercentage,DiscountType,TotalAmount,DeliveryDate,[Description], [Description],1 ,
						case when TaxId='' OR TaxId=0 then NULL else TaxId end ,
						TaxAmount,RowNumber,IsComponent,
						case when  BOMId='' OR BOMId=0 then NULL else BOMId end,IsFreeItem,IsTotalAmountEdited
					FROM @TempGDNItems  WHERE RowNumber=@RowNumber;

					SET @GDNDetailsId=SCOPE_IDENTITY();

					UPDATE @TempGDNBundles SET GDNDetailsId=@GDNDetailsId WHERE GDNRowId=@RowId;
					UPDATE @TempGDNBatches SET GDNDetailsId=@GDNDetailsId WHERE GDNRowId=@RowId;
					UPDATE @TempGDNItems SET GDNDetailsId=@GDNDetailsId WHERE GDNRowId=@RowId

					SET @RowNumber=@RowNumber+1;
				END
				
				----------- bundle details
				DELETE FROM @TempGDNBundles WHERE GDNDetailsId=0 OR GDNDetailsId IS NULL;
				DELETE FROM @TempGDNBatches WHERE GDNDetailsId=0 OR GDNDetailsId IS NULL;

				SELECT @BundleRecordCount=COUNT(*) FROM @TempGDNBundles;
				IF @BundleRecordCount>0
				BEGIN
					INSERT INTO [ERP.Inventory].GoodsDeliveryNoteBundleDetails
                    (
						GDNDetailsId, BundleId, ProductId, WarehouseId, LocatorId, Quantity, UOMId, SalesRate
					)
					SELECT 
						GDNDetailsId, BundleId, ProductId, 
						case when  WarehouseId='' OR WarehouseId=0 then null else WarehouseId end ,
						case when LocatorId='' OR LocatorId=0 then NULL else LocatorId end, 
						Quantity, UOMId, SalesRate
					FROM @TempGDNBundles
				END

				

				IF @GDNStockRecordCount>0
				BEGIN  
					IF(@StockId>0)
					BEGIN 
						--- Update Purchaseprice and costprice
						UPDATE #TempSDetails SET PurchaseRate=ISNULL((SELECT TOP 1 PurchasePrice FROM [ERP.Inventory].ProductPrices 
							WHERE ProductPrices.ProductId=#TempSDetails.ProductId and ProductPrices.UOMId=#TempSDetails.UOMId
							ORDER BY ProductPriceId DESC),0)
						
						--UPDATE #TempSDetails SET CostPrice=ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate](#TempSDetails.ProductId,@SalesInvoiceDate),0)
						--						*#TempSDetails.ConversionValue
						--ISNULL((select top 1 CostPrice from [ERP.Inventory].ProductPrices 
						--					where ProductPrices.ProductId=#TempSDetails.ProductId and ProductPrices.UOMId=#TempSDetails.UOMId
						--					ORDER BY ProductPriceId DESC),0)   
					
						UPDATE #TempSDetails SET CostPrice=ISNULL([ERP.Inventory].[Fun_RunningAverageCostPriceOfProductAsOnDate]
						(ProductId,UOMId,@SalesInvoiceDate,@StockId),0)

						INSERT INTO [ERP.Inventory].StockDetails
						(
							StockId, ProductId, WarehouseId, LocatorId, InStock, OutStock,UOMId, 
							ConversionValue, PurchaseRate, SalesRate, CostPrice,ReferencNo, StockDescription, 
							Remarks,StockStatus,ManufacturingDate,ExpiryDate,RowId
						)
						SELECT 
							@StockId,TPStock.ProductId, TPStock.WarehouseId, TPStock.LocatorId,
							TPStock.InStock,TPStock.OutStock,TPStock.UOMId,TPStock.ConversionValue,
							TPStock.PurchaseRate, TPStock.SalesRate, TPStock.CostPrice,@GDNNo,TPStock.StockDescription, 
							TPStock.Remarks,'A' ,NULL,NULL,TPStock.RowId
						FROM #TempSDetails as TPStock 
							INNER JOIN [ERP.Inventory].Product as Product ON TPStock.ProductId=Product.ProductId 
						WHERE Product.IsService=0 AND Product.IsProductionItem=0 AND Product.IsBOmItem=0

						UPDATE #TempSDetails SET StockDetailsId=SD.StockDetailsId
						FROM #TempSDetails as Temp 
							INNER JOIN [ERP.Inventory].StockDetails as SD ON Temp.RowId =SD.RowId
							INNER JOIN [ERP.Inventory].Stock as S ON SD.StockId=S.StockId
						WHERE S.StockId=@StockId

						------------- FETCH Product details for Product Summary update
						DELETE FROM @TblProductStock WHERE ProductId IN (SELECT ProductId FROM #TempSDetails);
						INSERT INTO @TblProductStock(ProductId,WarehouseId,LocatorId) 
						(SELECT 
							TPStock.ProductId ,TPStock.WarehouseId,TPStock.LocatorId
						FROM #TempSDetails as TPStock 
							INNER JOIN [ERP.Inventory].Product as Product ON TPStock.ProductId=Product.ProductId 
						WHERE Product.IsService=0 AND Product.IsProductionItem=0)

						EXEC [ERP.Inventory].[CalculateProductStock] @SpStatus3,@TblProductStock
						-----------------------
					END
				END													---- end of StockId>0

				INSERT INTO @TempGDNs VALUES(@GDNId);
			END	

	   ------------------------------------
		-- for Saving GDN Log 
		BEGIN 
			SET @ReferenceId		=@GDNId
			SET @ReferenceNum=@GDNNo;
			IF @Action='E'
				 BEGIN
					 SET @CreatedBy=NULL
				 END
				 ELSE
				 BEGIN
					 SET @Action='S'
				 END
				SET @PageName='GoodsDeliveryNote'
				EXEC [ERP.Admin].[SaveLog] @Spstatus output,@LogId output,@BranchId,@LogDate,@PageName,@UserId,@Action,@ReferenceId,@ReferenceNum,@CreatedBy,@EditedBy, @EntryStatus
			END


			SET @Action=''
			SET @CreatedBy=@UserId
			 -------------------------------------
		END 
		ELSE IF @GDNId>0
		BEGIN
			EXEC [ERP.Inventory].[CancelGDN] @SpStatus1,@GDNId, @CreatedBy	-- no items . cancel previous GRN
		END
		
		--------------------------------------------------------------------------------------
		
	    --select @RecordCount ,@CRecordCount
         --SELECT @OrgId=OrgId FROM [ERP.Config].OrganizationBranch WHERE (BranchId = @BranchId);
		--IF @RecordCount>0

		--BEGIN
	
			IF @SalesInvoiceId=0 OR @SalesInvoiceId IS NULL OR @SalesInvoiceId='' 
		    BEGIN
	
				SET @NewInsert=1;

			    -- get  financial year 
			    SET @FinYear=[ERP.Config].[Fun_GetFinancialYearCombination](@BranchId,@SalesInvoiceDate);				--- get financial year	
				
				IF @InvoiceNo='' OR @InvoiceNo IS NULL OR @InvoiceNo='0'
				BEGIN
					IF @IsDraft=1 
					BEGIN
						SET @SettingsId=85
						-- generate SalesInvoice No 
						EXEC [ERP.Config].[GenerateNewNumber] @DraftSalesInvoiceNo OUT,@SettingsId,@BranchId,@FinYear;
						SET @InvoiceNo=''
					END
					ELSE
					BEGIN
						IF @IsAdjustment=1 SET @SettingsId=46		-------Sales invoice Adjustment
						-- generate SalesInvoice No 
						EXEC [ERP.Config].[GenerateNewNumber] @InvoiceNo OUT,@SettingsId,@BranchId,@FinYear;
						SET @DraftSalesInvoiceNo=''
					END
				END

				IF @InvoiceNo<>'' OR @IsDraft=1
				BEGIN
					IF @IsMobileAppEntry=1
					BEGIN
						UPDATE [ERP.Config].[AppUserNumberGenerationSettings]  SET LastIndex=@LastIndex
						WHERE AppUserId=@CreatedBy AND SettingsId=@IndexSettingsId and BranchId=@BranchId
					END

						SELECT @InvoiceTypeSlno=MAX(ISNULL(InvoiceTypeSlno,0)) FROM [ERP.Inventory].SalesInvoice WHERE IsCredit=@IsCredit AND BranchId=@BranchId
						SET @InvoiceTypeSlno=ISNULL(@InvoiceTypeSlno,0)+1;
						
						SELECT @InvoiceSequenceNo=MAX(ISNULL(InvoiceSequence,0)) FROM [ERP.Inventory].SalesInvoice WHERE BranchId=@BranchId
						SET @InvoiceSequenceNo=ISNULL(@InvoiceSequenceNo,0)+1;
						IF @IsOutOfScopeInvoice=1
						BEGIN
							SET @InvoiceSequenceNo=0
						END

						SELECT 	TOP 1 @PrevoiusInvoiceHash=InvoiceHash FROM [ERP.Inventory].SalesInvoice 
						WHERE BranchId=@BranchId  AND InvoiceHash IS NOT NULL
						ORDER BY SalesInvoiceId DESC
						IF @PrevoiusInvoiceHash IS NULL SET @PrevoiusInvoiceHash='NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzIzOWRkNGU5MWI0NjcyOWQ3M2EyN2ZiNTdlOQ=='
					
						INSERT INTO [ERP.Inventory].SalesInvoice
						(
							BranchId,SalesInvoiceDate,SalesOrderId,InvoiceNo,ReferenceNo,CustomerId,CurrencyId,TotalAmount,TotalDiscount,
							TotalChargeAmount,TotalTaxAmount,NetAmount,IsCredit,TotalAdvanceAmount,PaidFromAdvance,PaidAmount,TermsAndConditionId,
							StaffId, InvoiceTypeId,SalesStatusId,PaymentTermsId,DueDate,DeliveryMethodId,PriceListId, Remarks,Notes,
							IsDirectInvoice,CostCenterId,CreatedBy,CreatedDate,EditedBy,EditedDate,EntryStatus,DeliveryDate,SalesManUserId,
							ContactPerson,ReturnStatus, DiscountType, DiscountPercentage,RoundOff,PONo,DeliveryPeriod,[Type],CSOId,CSODescription, 
							BillingAddress,CurrencyRate,TotalAmountInCustCurrency,TotalDiscountInCustCurrency,TotalChargeAmountInCustCurrency,
							TotalTaxAmountInCustCurrency,RoundOffInCustCurrency,NetAmountInCustCurrency,TotalAdvanceAmountInCustCurrency,
							PaidFromAdvanceInCustCurrency,PaidAmountInCustCurrency,VATExempt,CashCustomerName,CashCustomerVATNo,PaymentMethodId,
							ChequeNo,ChequeDate,ChequeDetails,AccountId,BankAccountId,CardNo,CustAutomobileDetailsId,CostcentreSequenceNo, 
							ContractInvoiceId, TimeSheetInvoiceId,IsAdjustment,SubmissionDate,IsMobileAppEntry,PODate,ProjectId,
							IsVATInclusivePrice,AppSerialNo,RetentionPercentage,RetentionAmount,RetentionAmountCustCurrency,TaxId,
							InvoiceTypeSlno,DepartmentId,BankCurrencyId,BankCurrencyRate,TotalAmountInBankCurrency,IsSummary,[Description],
							DescriptionArabic,CompanyBankAccountId,UUID,InvoiceXml,PdfFilePath,InvoiceSubmittedDate,
							CustContactPersonDetailsId,TemplateId,InvoiceSequence,PrevoiusInvoiceHash,
							PerformanceBondPercentage,PerformanceBondAmount,PerformanceBondAmountCustCurrency,DraftInvoiceNo,
							IsOutOfScopeInvoice
						)               
						VALUES 
						(
							@BranchId,@SalesInvoiceDate,@SalesOrderId,@InvoiceNo,@ReferenceNo,@CustomerId,@CurrencyId,@TotalAmount,@TotalDiscount,
							@TotalChargeAmount,@TotalTaxAmount,@NetAmount,@IsCredit,@TotalAdvanceAmount,@PaidFromAdvance,@PaidAmount,@TermsAndConditionId,
							@StaffId,@InvoiceTypeId,@SalesStatusId,@PaymentTermsId,@DueDate ,@DeliveryMethodId,@PriceListId,@Remarks,@Notes,
							@IsDirectInvoice,@CostCenterId,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A',@DeliveryDate,@SalesManUserId,@ContactPerson,'', 
							@DiscountType, @DiscountPercentage,@RoundOff,@PONo,@DeliveryPeriod,@Type,@CSOId,@CSODescription, @ShipmentAddress1,
							@CurrencyRate,@TotalAmountInCustCurrency,@TotalDiscountInCustCurrency,@TotalChargeAmountInCustCurrency,@TotalTaxAmountInCustCurrency,
							@RoundOffInCustCurrency,@NetAmountInCustCurrency,@TotalAdvanceAmountInCustCurrency,@PaidFromAdvanceInCustCurrency,
							@PaidAmountInCustCurrency, @VATExempt,@CashCustomerName,@CashCustomerVATNo,
							CASE WHEN @PaymentMethodId=0 THEN NULL ELSE @PaymentMethodId END,
							@ChequeNo,@ChequeDate,@ChequeDetails,@ReceiptAccountId,@BankAccountId,@CardNo,@CustAutomobileDetailsId,
							[ERP.Inventory].[Fun_GetCostCenterWiseSequenceNo](@SalesInvoiceDate,@CostCenterId,@BranchId),
							@ContractInvoiceId, @TimeSheetInvoiceId,@IsAdjustment,@SubmissionDate,@IsMobileAppEntry,@PODate,
							CASE WHEN @ProjectId=0 THEN NULL ELSE @ProjectId END,@IsVATInclusivePrice,@AppSerialNo,@RetentionPercentage,
							@RetentionAmount,@RetentionAmountCustCurrency,@TaxId,@InvoiceTypeSlno,@DepartmentId,@BankCurrencyId,
							@BankCurrencyRate,@TotalAmountInBankCurrency,@IsSummary,@Description,@DescriptionArabic,@CompanyBankAccountId,
							@UUID,@InvoiceXml,@PdfFilePath,@InvoiceSubmittedDate,
							@CustContactPersonDetailsId,@TemplateId,@InvoiceSequenceNo,@PrevoiusInvoiceHash,
							@PerformanceBondPercentage,@PerformanceBondAmount,@PerformanceBondAmountCustCurrency,@DraftSalesInvoiceNo,
							@IsOutOfScopeInvoice
						)

					    SET @SalesInvoiceId=SCOPE_IDENTITY(); 
						
						IF @DraftSalesInvoiceNo<>'' SET @InvoiceNo=@DraftSalesInvoiceNo  --Bug #27212 IF Case Added
				END
				ELSE 
				SET @SPStatus=-3;		
		    END
		    ELSE

		    BEGIN
				SET @NewInsert=0
				---------------- Rollback GDN item status -------------Added on 14-11-2019--Lathika------
				IF @IsDirectInvoice=0 --AND @InvoiceFromSalesOrder=0
				BEGIN
					
					INSERT INTO #TempGDNStatusRollBack(GDNId) SELECT GDNId FROM [ERP.Inventory].SalesInvoiceGDNs WHERE SalesInvoiceId=@SalesInvoiceId
					UPDATE #TempGDNStatusRollBack SET SalesOrderId=ISNULL((SELECT TOP(1) SalesOrderId FROM [ERP.Inventory].GoodsDeliveryNote WHERE (GDNId = #TempGDNStatusRollBack.GDNId)),0)
				
					UPDATE #TempGDNStatusRollBack SET DeliveredQTy=ISNULL((SELECT TotalQuantity FROM [ERP.Inventory].GoodsDeliveryNote WHERE (GDNId = #TempGDNStatusRollBack.GDNId)),0)
					--print 'a'
					UPDATE #TempGDNStatusRollBack SET InvoicedQTy=ISNULL((SELECT SUM([ERP.Inventory].SalesInvoiceDetails.Quantity)
						FROM [ERP.Inventory].SalesInvoiceDetails INNER JOIN [ERP.Inventory].SalesInvoice 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesInvoiceId = [ERP.Inventory].SalesInvoice.SalesInvoiceId
						WHERE ([ERP.Inventory].SalesInvoiceDetails.GDNId = #TempGDNStatusRollBack.GDNId) 
						AND ([ERP.Inventory].SalesInvoice.EntryStatus <> 'D') 
						AND ([ERP.Inventory].SalesInvoice.SalesInvoiceId<>@SalesInvoiceId)
						AND ([ERP.Inventory].SalesInvoice.SalesStatusId <> 'CN')
						AND ([ERP.Inventory].SalesInvoiceDetails.InvoiceType <> 'A')),0)

					UPDATE #TempGDNStatusRollBack SET GDNStatus=CASE WHEN InvoicedQTy>0 AND  InvoicedQTy<DeliveredQTy THEN  'PI' 
					WHEN InvoicedQTy>=DeliveredQTy THEN 'I'  ELSE 'D' END

					UPDATE [ERP.Inventory].GoodsDeliveryNote SET SalesStatusId=Temp.GDNStatus 
						FROM #TempGDNStatusRollBack as Temp INNER JOIN [ERP.Inventory].GoodsDeliveryNote
						ON Temp.GDNId=[ERP.Inventory].GoodsDeliveryNote.GDNId

					UPDATE #TempGDNStatusRollBack SET OrderedQty=CASE WHEN SalesOrderId=0 THEN 0 ELSE ISNULL((SELECT SUM(Quantity) 
					FROM [ERP.Inventory].SalesOrderDetails WHERE (SalesOrderId = #TempGDNStatusRollBack.SalesOrderId)),0) END
					UPDATE #TempGDNStatusRollBack SET OrderedInvoicedQTy=ISNULL((SELECT SUM([ERP.Inventory].SalesInvoiceDetails.Quantity)
						FROM [ERP.Inventory].SalesInvoiceDetails INNER JOIN [ERP.Inventory].SalesInvoice 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesInvoiceId = [ERP.Inventory].SalesInvoice.SalesInvoiceId
						INNER JOIN [ERP.Inventory].SalesOrderDetails 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesOrderdetailsId=[ERP.Inventory].SalesOrderDetails.SalesOrderDetailsId
						WHERE ([ERP.Inventory].SalesOrderDetails.SalesOrderId = #TempGDNStatusRollBack.SalesOrderId) 
						AND ([ERP.Inventory].SalesInvoice.EntryStatus <> 'D') 
						AND ([ERP.Inventory].SalesInvoice.SalesInvoiceId<>@SalesInvoiceId)
						AND ([ERP.Inventory].SalesInvoice.SalesStatusId <> 'CN')),0)
				
					UPDATE #TempGDNStatusRollBack SET OrderStatus=CASE WHEN OrderedInvoicedQTy=0 THEN 'NI' ELSE 'PI' END WHERE OrderedQty>0

					UPDATE [ERP.Inventory].SalesOrder SET InvoiceStatusId=Temp.OrderStatus 
					FROM #TempGDNStatusRollBack as Temp INNER JOIN [ERP.Inventory].SalesOrder
					ON Temp.SalesOrderId=[ERP.Inventory].SalesOrder.SalesOrderId
					WHERE Temp.OrderedQty>0

				END

				----------------------------------------------------------------------------------------
				INSERT INTO @OldSIBatchAndSerialDetails
				(
					SalesInvoiceDetailsId,ProductId,UOMId,StockBatchNo,BatchNo,BatchSerialNo,ManufacturingDate,ExpiryDate,Quantity,
					CostPrice,RowId,IsBatchOverRide,GdnDetailsId,BOMId,SalesOrderDetailsId 						
				)
				SELECT 
					SISD.SalesInvoiceDetailsId,SISD.ProductId,SISD.UOMId,SISD.StockBatchNo,SISD.BatchNo,SISD.BatchSerialNo,
					SISD.ManufacturingDate,SISD.ExpiryDate,SISD.Quantity,SISD.CostPrice,SISD.RowId,SD.IsBatchOverRide,
					SD.GDNDetailsId	,SISD.BOMId,SD.SalesOrderDetailsId
				 FROM [ERP.Inventory].SalesInvoiceBatchAndSerialDetails SISD
					JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
				WHERE SD.SalesInvoiceId=@SalesInvoiceId

				IF @IsDirectInvoice=1
				BEGIN
					UPDATE BS SET OutStock=OutStock-SISD.Quantity FROM [ERP.Inventory].BatchwiseStockSummary BS
						JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails SISD ON BS.ProductId=SISD.ProductId AND BS.StockBatchNo=SISD.StockBatchNo
						JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
					WHERE SD.SalesInvoiceId=@SalesInvoiceId

					UPDATE BS 
							SET IsClosedBatch=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN 0 ELSE 1 END,
								BatchClosedDate=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN NULL ELSE BatchClosedDate END
					FROM [ERP.Inventory].BatchwiseStockSummary BS
						JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails SISD ON BS.ProductId=SISD.ProductId AND BS.StockBatchNo=SISD.StockBatchNo
						JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
					WHERE SD.SalesInvoiceId=@SalesInvoiceId

					--- Bundle Item
					UPDATE BS SET OutStock=OutStock-SISD.Quantity FROM [ERP.Inventory].BatchwiseStockSummary BS
						JOIN [ERP.Inventory].SalesInvoiceBundleBatchAndSerialDetails SISD ON BS.ProductId=SISD.ProductId AND BS.StockBatchNo=SISD.StockBatchNo
						JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
					WHERE SD.SalesInvoiceId=@SalesInvoiceId

					UPDATE BS 
							SET IsClosedBatch=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN 0 ELSE 1 END,
								BatchClosedDate=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN NULL ELSE BatchClosedDate END
					FROM [ERP.Inventory].BatchwiseStockSummary BS
						JOIN [ERP.Inventory].SalesInvoiceBundleBatchAndSerialDetails SISD ON BS.ProductId=SISD.ProductId AND BS.StockBatchNo=SISD.StockBatchNo
						JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
					WHERE SD.SalesInvoiceId=@SalesInvoiceId
				END

				----- delete and insert Sales invoice batch-

				DELETE FROM SIBS FROM [ERP.Inventory].SalesInvoiceBundleBatchAndSerialDetails SIBS
				JOIN [ERP.Inventory].SalesInvoiceDetails SD ON SIBS.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
				WHERE SD.SalesInvoiceId=@SalesInvoiceId

				DELETE FROM [ERP.Inventory].SalesInvoiceBundleDetails WHERE SalesInvoiceDetailsId IN
				(SELECT SalesInvoiceDetailsId FROM  [ERP.Inventory].SalesinvoiceDetails WHERE (SalesInvoiceId = @SalesInvoiceId))				

				DELETE FROM SISD FROM [ERP.Inventory].SalesInvoiceBatchAndSerialDetails SISD
					JOIN [ERP.Inventory].SalesinvoiceDetails SD ON SISD.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
				WHERE SD.SalesInvoiceId=@SalesInvoiceId

		        --for update delete and reinsert details table data
			 	DELETE FROM  [ERP.Inventory].SalesinvoiceDetails WHERE (SalesInvoiceId = @SalesInvoiceId);

				---for update delete and reinsert details table data
				DELETE FROM [ERP.Inventory].SalesInvoiceServiceDetails WHERE  (SalesInvoiceId = @SalesInvoiceId);

				--for update delete and reinsert details CustomerTransaction table data
				DELETE FROM  [ERP.Inventory].CustomerTransaction WHERE (SalesInvoiceId = @SalesInvoiceId) AND (TransactionType=@TransactionType) ;	
				
				---delete mixed mode receipts if any in cash customer case
				DELETE FROM [ERP.Inventory].SalesInvoiceMixedReceiptDetails WHERE SalesInvoiceId=@SalesInvoiceId

				--for update delete and reinsert charge table data
			 	DELETE FROM  [ERP.Inventory].SalesInvoiceCharges WHERE (SalesInvoiceId = @SalesInvoiceId);

				------ delete from projectdetails
				DELETE FROM [ERP.Inventory].SalesInvoiceProjectDetails WHERE SalesInvoiceid=@SalesInvoiceId

				----------------ProjectJobBillDetails Invoice Status Updation - Bug #24890--------------
				UPDATE [ERP.Service].ProjectJobBillDetails SET InvoiceStatus='N'
					FROM [ERP.Inventory].SalesInvoiceProjectBillDetails as SIPBD INNER JOIN [ERP.Service].ProjectJobBillDetails as PJBD 
					ON SIPBD.ProjectJobBillDetailsId=PJBD.ProjectJobBillDetailsId
					WHERE SIPBD.SalesInvoiceId=@SalesInvoiceId

				------ delete from project bill details
				DELETE FROM [ERP.Inventory].SalesInvoiceProjectBillDetails WHERE SalesInvoiceid=@SalesInvoiceId

				DELETE FROM [ERP.Inventory].RetentionInvoiceDetails WHERE SalesInvoiceid=@SalesInvoiceId
						AND RetentionInvoiceDetailsId NOT IN (SELECT RetentionInvoiceDetailsId 
						FROM @TempRetentionInvoice WHERE ISNULL(RetentionInvoiceDetailsId,0)>0)

				------ UPDATE invoice Customer Advance
				UPDATE [ERP.Finance].CustomerAdvance SET AdvanceStatus='C' WHERE SalesInvoiceid=@SalesInvoiceId

				UPDATE CR SET CR.ReceiptStatus='C' FROM [ERP.Inventory].CustomerReceipts CR
					JOIN [ERP.Finance].CustomerAdvance CA ON CR.CustomerReceiptId=CA.CustomerReceiptId
				WHERE CA.SalesInvoiceId=@SalesInvoiceId
				
				IF ISNULL(@InvoiceNo,'')='' AND @IsDraft=0
				BEGIN
					IF @IsAdjustment=1 SET @SettingsId=46		-------Sales invoice Adjustment
					-- generate SalesInvoice No 
					EXEC [ERP.Config].[GenerateNewNumber] @InvoiceNo OUT,@SettingsId,@BranchId,@FinYear;
				END

			    UPDATE [ERP.Inventory].SalesInvoice
			    SET SalesInvoiceDate = @SalesInvoiceDate,InvoiceNo=@InvoiceNo,SalesOrderId=@SalesOrderId,ReferenceNo=@ReferenceNo, 
					CustomerId = @CustomerId,CurrencyId = @CurrencyId, TotalAmount=@TotalAmount,
					TotalDiscount=@TotalDiscount,TotalChargeAmount=@TotalChargeAmount,TotalTaxAmount=@TotalTaxAmount,
					NetAmount = @NetAmount,IsCredit=@IsCredit,TotalAdvanceAmount=@TotalAdvanceAmount,
					PaidFromAdvance=@PaidFromAdvance,PaidAmount=@PaidAmount,TermsAndConditionId=@TermsAndConditionId,
					StaffId=@StaffId, InvoiceTypeId=@InvoiceTypeId,SalesStatusId=@SalesStatusId,
					PaymentTermsId=@PaymentTermsId,	DueDate = @DueDate,DeliveryMethodId=@DeliveryMethodId,
					PriceListId=@PriceListId,Remarks=@Remarks,Notes=@Notes,IsDirectInvoice=@IsDirectInvoice,
					CostCenterId=@CostCenterId,EditedBy=@CreatedBy,EditedDate=@CreatedBy,EntryStatus='A',
					DeliveryDate=@DeliveryDate,SalesManUserId =@SalesManUserId ,ContactPerson=@ContactPerson,
					DiscountType = @DiscountType, DiscountPercentage  = @DiscountPercentage,RoundOff=@RoundOff,
					PONo=@PONo,DeliveryPeriod=@DeliveryPeriod,[Type]=@Type,CSOId=@CSOId,@CSODescription=CSODescription,
					BillingAddress = @ShipmentAddress1,CurrencyRate=@CurrencyRate,TotalAmountInCustCurrency=@TotalAmountInCustCurrency,
					TotalDiscountInCustCurrency=@TotalDiscountInCustCurrency,
					TotalChargeAmountInCustCurrency=@TotalChargeAmountInCustCurrency,
					TotalTaxAmountInCustCurrency=@TotalTaxAmountInCustCurrency,RoundOffInCustCurrency=@RoundOffInCustCurrency,
					NetAmountInCustCurrency=@NetAmountInCustCurrency,TotalAdvanceAmountInCustCurrency=@TotalAdvanceAmountInCustCurrency,
					PaidFromAdvanceInCustCurrency=@PaidFromAdvanceInCustCurrency,PaidAmountInCustCurrency=@PaidAmountInCustCurrency,
					VATExempt = @VATExempt,CashCustomerName=@CashCustomerName, CashCustomerVATNo=@CashCustomerVATNo,
					PaymentMethodId=CASE WHEN @PaymentMethodId=0 THEN NULL ELSE @PaymentMethodId END,ChequeNo=@ChequeNo,ChequeDate=@ChequeDate,ChequeDetails=@ChequeDetails,
					AccountId=@ReceiptAccountId,BankAccountId=@BankAccountId,CardNo=@CardNo,
					ContractInvoiceId =@ContractInvoiceId,TimeSheetInvoiceId = @TimeSheetInvoiceId,
					CustAutomobileDetailsId=@CustAutomobileDetailsId,
					CostcentreSequenceNo=CASE WHEN CostCenterId=@CostCenterId AND SalesInvoiceDate=@SalesInvoiceDate THEN CostcentreSequenceNo 
					ELSE [ERP.Inventory].[Fun_GetCostCenterWiseSequenceNo](@SalesInvoiceDate,@CostCenterId,@BranchId) END,
					IsAdjustment=@IsAdjustment,SubmissionDate=@SubmissionDate,PODate=@PODate,ProjectId=CASE WHEN @ProjectId=0 THEN NULL ELSE @ProjectId END,
					IsVATInclusivePrice=@IsVATInclusivePrice,AppSerialNo=@AppSerialNo,RetentionPercentage=@RetentionPercentage,
					RetentionAmount=@RetentionAmount,RetentionAmountCustCurrency=@RetentionAmountCustCurrency,TaxId=@TaxId,
					InvoiceTypeSlno=@InvoiceTypeSlno,DepartmentId=@DepartmentId,BankCurrencyId=@BankCurrencyId,
					BankCurrencyRate=@BankCurrencyRate,TotalAmountInBankCurrency=@TotalAmountInBankCurrency,
					IsSummary=@IsSummary,[Description]=@Description,DescriptionArabic=@DescriptionArabic,
					CompanyBankAccountId=@CompanyBankAccountId,InvoiceXml=@InvoiceXml,
					PdfFilePath=@PdfFilePath,InvoiceSubmittedDate=@InvoiceSubmittedDate,
					CustContactPersonDetailsId=@CustContactPersonDetailsId,TemplateId=@TemplateId,UUID=@UUID,
					PerformanceBondPercentage=@PerformanceBondPercentage,PerformanceBondAmount=@PerformanceBondAmount,
					PerformanceBondAmountCustCurrency=@PerformanceBondAmountCustCurrency,
					IsOutOfScopeInvoice=@IsOutOfScopeInvoice
		     	WHERE (SalesInvoiceId = @SalesInvoiceId)
				
				SET @EditedBy=@CreatedBy

				IF @SalesStatusId IN ('I','PR','R') AND @IsSubmit=1
				BEGIN
					SET @Action='M'
				END
				ELSE
					SET @Action='E'

				select @InvoiceNo = InvoiceNo From [ERP.Inventory].SalesInvoice WHERE ( SalesInvoiceId = @SalesInvoiceId);

				-- remove already existing ChequeTransaction
				UPDATE  C SET EntryStatus = 'D'
				FROM [ERP.Finance].ChequeTransactions C
				JOIN [ERP.Finance].AccountTrans A ON C.AccountTransID=A.AccountTransID
				WHERE (A.TransactionTypeId = @TransactionTypeId) AND (A.TransactionId = @SalesInvoiceId)

				-- remove already existing Account trans
				UPDATE  [ERP.Finance].AccountTrans SET EntryStatus = 'D'
				WHERE (TransactionTypeId = @TransactionTypeId) AND (TransactionId = @SalesInvoiceId)

				DELETE FROM [ERP.Inventory].SalesInvoiceGDNs WHERE SalesInvoiceId=@SalesInvoiceId

				--IF @IsSubmit=1
				--BEGIN
				--	SELECT @InvoiceSequenceNo=MAX(InvoiceSequence)+1 FROM [ERP.Inventory].SalesInvoice WHERE BranchId=@BranchId
					
				--	SELECT 
				--		TOP 1 @PrevoiusInvoiceHash=InvoiceHash FROM [ERP.Inventory].SalesInvoice 
				--	WHERE BranchId=@BranchId AND SalesInvoiceId<@SalesInvoiceId AND InvoiceHash IS NOT NULL
				--	ORDER BY SalesInvoiceId DESC

				--	UPDATE [ERP.Inventory].SalesInvoice SET 
				--		InvoiceSequence=@InvoiceSequenceNo,
				--		PrevoiusInvoiceHash=@PrevoiusInvoiceHash
				--	WHERE SalesInvoiceId=@SalesInvoiceId AND InvoiceSequence=0

				--END
		    END
			
		    IF @SalesInvoiceId>0
			BEGIN
				INSERT INTO [ERP.Inventory].SalesInvoiceGDNs(SalesInvoiceId,GDNId) SELECT DISTINCT @SalesInvoiceId,GDNId FROM @TempGDNs; 
				
				------------------------add on details-----------------------
				DELETE FROM [ERP.Inventory].SalesInvoiceAddOnsDetails WHERE SalesInvoiceId=@SalesInvoiceId
				INSERT INTO [ERP.Inventory].SalesInvoiceAddOnsDetails
					 (SalesInvoiceId, AddOnsSettingsId, AddOnsSettingsValue, AddOnsSettingsValueArabic)
				SELECT @SalesInvoiceId, AddOnsSettingsId, AddOnsSettingsValue, AddOnsSettingsValueArabic
				FROM @TempAddOnsDetails
				-----------------------------------------------------------------------------------------

				IF @Type='PR'
				BEGIN
					INSERT INTO [ERP.Inventory].SalesInvoiceProjectDetails
					(
						SalesInvoiceId, SerialNo, CSOId, Description, DescriptionArabic, InvoiceAmount, DiscountAmount, 
						 DiscountPercentage, DiscountType, TaxId, TaxAmount, TotalAmount, InvoiceAmountInCustCurrency, 
						 DiscountAmountInCustCurrency, TaxAmountInCustCurrency, TotalAmountInCustCurrency,ProjectJobId,
						 CompletionPercentage,QtyInScope,UOMId
					)
					SELECT 
						@SalesInvoiceId, SerialNo, CSOId, Description, DescriptionArabic, InvoiceAmount, DiscountAmount, 
						DiscountPercentage, DiscountType, TaxId, TaxAmount, TotalAmount, InvoiceAmountInCustCurrency, 
						DiscountAmountInCustCurrency, TaxAmountInCustCurrency, TotalAmountInCustCurrency,ProjectJobId,
						CompletionPercentage,QtyInScope,UOMId
					FROM @TempProjectDetails

					INSERT INTO [ERP.Inventory].SalesInvoiceProjectBillDetails
					(
						SalesInvoiceId, SerialNo, ProjectJobId, WorkType, ItemDescription, Quantity, UOM, Rate, InvoiceAmount, 
						DiscountAmount, DiscountPercentage, DiscountType, TaxId, TaxAmount, TotalAmount, RateInCustCurrency, 
						InvoiceAmountInCustCurrency, DiscountAmountInCustCurrency, TaxAmountInCustCurrency, TotalAmountInCustCurrency, 
						ProjectJobBillDetailsId, Remarks, CreatedBy, CreatedDate, EditedBy, EditedDate, EntryStatus,ItemName,
						ItemNameArabic,ItemDescriptionArabic
					)
					SELECT 
						@SalesInvoiceId, SerialNo, ProjectJobId, WorkType, ItemDescription, Quantity, UOM, Rate, InvoiceAmount, 
						DiscountAmount, DiscountPercentage, DiscountType, TaxId, TaxAmount, TotalAmount, RateInCustCurrency, 
						InvoiceAmountInCustCurrency, DiscountAmountInCustCurrency, TaxAmountInCustCurrency, TotalAmountInCustCurrency, 
						ProjectJobBillDetailsId, Remarks,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A',ItemName,ItemNameArabic,
						ItemDescriptionArabic
					FROM @TempProjectBillDetails

					UPDATE [ERP.Service].ProjectJobBillDetails SET InvoiceStatus='I'
					FROM [ERP.Inventory].SalesInvoiceProjectBillDetails as SIPBD INNER JOIN [ERP.Service].ProjectJobBillDetails as PJBD 
					ON SIPBD.ProjectJobBillDetailsId=PJBD.ProjectJobBillDetailsId
					WHERE SIPBD.SalesInvoiceId=@SalesInvoiceId
					
				END
				ELSE IF @Type='RI'
				BEGIN
					INSERT INTO [ERP.Inventory].RetentionInvoiceDetails
					(
						SalesInvoiceId, SerialNo, RetentionAccountId, Description, DescriptionArabic, TotalContractValue, 
						TotalInvoicedAmount, RetentionPercentage, RetentionAmount, CumulativeAmount, BalanceRetentionAmount, 
						ReceivedAmount, DiscountType, DiscountPercentage, DiscountAmount, TotalAmount, TotalContractValueCustCurrency, 
						TotalInvoicedAmountCustCurrency, RetentionAmountCustCurrency, CumulativeAmountCustCurrency, 
						BalanceRetentionAmountCustCurrency, ReceivedAmountCustCurrency, DiscountAmountCustCurrency, 
						TotalAmountCustCurrency, Remarks, CreatedBy, CreatedDate, EditedBy, EditedDate, EntryStatus,Name,NameArabic
					)
					SELECT 
						@SalesInvoiceId, SerialNo, RetentionAccountId, Description, DescriptionArabic, TotalContractValue, 
						TotalInvoicedAmount, RetentionPercentage, RetentionAmount, CumulativeAmount, BalanceRetentionAmount, 
						ReceivedAmount, DiscountType, DiscountPercentage, DiscountAmount, TotalAmount, TotalContractValueCustCurrency, 
						TotalInvoicedAmountCustCurrency, RetentionAmountCustCurrency, CumulativeAmountCustCurrency, 
						BalanceRetentionAmountCustCurrency, ReceivedAmountCustCurrency, DiscountAmountCustCurrency, 
						TotalAmountCustCurrency, Remarks,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A',Name,NameArabic
					FROM @TempRetentionInvoice WHERE ISNULL(RetentionInvoiceDetailsId,0)=0

					UPDATE [ERP.Inventory].RetentionInvoiceDetails SET
						SerialNo=T.SerialNo, RetentionAccountId=T.RetentionAccountId, Description=T.Description, DescriptionArabic=T.DescriptionArabic, 
						TotalContractValue=T.TotalContractValue, TotalInvoicedAmount=T.TotalInvoicedAmount, RetentionPercentage=T.RetentionPercentage, 
						RetentionAmount=T.RetentionAmount, CumulativeAmount=T.CumulativeAmount, BalanceRetentionAmount=T.BalanceRetentionAmount, 
						ReceivedAmount=T.ReceivedAmount, DiscountType=T.DiscountType, DiscountPercentage=T.DiscountPercentage, DiscountAmount=T.DiscountAmount, 
						TotalAmount=T.TotalAmount, TotalContractValueCustCurrency=T.TotalContractValueCustCurrency, TotalInvoicedAmountCustCurrency=T.TotalInvoicedAmountCustCurrency, 
						RetentionAmountCustCurrency=T.RetentionAmountCustCurrency, CumulativeAmountCustCurrency=T.CumulativeAmountCustCurrency, 
						BalanceRetentionAmountCustCurrency=T.BalanceRetentionAmountCustCurrency, ReceivedAmountCustCurrency=T.ReceivedAmountCustCurrency, 
						DiscountAmountCustCurrency=T.DiscountAmountCustCurrency, TotalAmountCustCurrency=T.TotalAmountCustCurrency, 
						Remarks=T.Remarks, EditedBy=@CreatedBy, EditedDate=GETDATE(),Name=T.Name,NameArabic=T.NameArabic
					FROM @TempRetentionInvoice as T INNER JOIN [ERP.Inventory].RetentionInvoiceDetails as RID
					ON T.RetentionInvoiceDetailsId=RID.RetentionInvoiceDetailsId
					WHERE ISNULL(T.RetentionInvoiceDetailsId,0)>0 AND RID.SalesInvoiceId=@SalesInvoiceId

					DELETE FROM [ERP.Inventory].SalesInvoiceRetentionDetails WHERE  (SalesInvoiceId = @SalesInvoiceId)
					SELECT @RetentionSlNo=MAX(SlNo) FROM [ERP.Inventory].SalesInvoiceRetentionDetails WHERE  (ProjectId = @ProjectId)
					SET @RetentionSlNo=ISNULL(@RetentionSlNo,0)+1;
					INSERT INTO [ERP.Inventory].SalesInvoiceRetentionDetails
					(	
						SalesInvoiceId, SlNo, ProjectId, RetentionAmount, InvoicedAmount,RetentionAmountCustCurrency,
						InvoicedAmountCustCurrency
					)
					VALUES 
					(
						@SalesInvoiceId,@RetentionSlNo,@ProjectId,0,@NetAmount,0,@NetAmountinCustCurrency
					)		
				END
				ELSE IF @Type='S' OR @Type = 'P' OR @Type ='TI' OR @Type ='CI'
				BEGIN
				
					INSERT INTO [ERP.Inventory].SalesInvoiceServiceDetails
					(
						SalesInvoiceId, SlNo, PartNo, Description, ServiceId, Quantity, Unit, SalesRate, 
						DiscountAmount, TotalAmount, TaxId,TaxAmount, NetAmount, DiscountType, DiscountPercentage,
						InvoicePercentage,RetentionPercentage,RetentionAmount,SalesRateIncludVAT,SalesRateIncludVATCustCurrency
					)
					SELECT 
						@SalesInvoiceId, SlNo, PartNo, Description, ServiceId, Quantity, Unit, SalesRate, 
						DiscountAmount, TotalAmount, TaxId, TaxAmount, NetAmount, DiscountType, DiscountPercentage,
						InvoicePercentage,RetentionPercentage,RetentionAmount,SalesRateIncludVAT,SalesRateIncludVATCustCurrency
					FROM @TempServiceDetails
					IF @Type = 'S'
					  UPDATE [ERP.Service].CustomerServiceOrder SET ServiceStatusId = 'I' WHERE (CSOId = @CSOId);						  
					IF @Type = 'P'
					  UPDATE [ERP.Service].CustomerServiceOrder SET ServiceStatusId = 'O' WHERE (CSOId = @CSOId);						
					IF @Type = 'CI'
					BEGIN
						SET @FinYear=[ERP.Config].[Fun_GetFinancialYearCombination](@BranchId,@SalesInvoiceDate);
						EXEC [ERP.Config].[GenerateNewNumber] @ContractInvoiceNo OUT,@ContractInvoiceSettingsId,@BranchId,@FinYear;
						------------------------added on 2019-10-03---------------------------------------------
						UPDATE [ERP.HRMS].ContractInvoice SET InvoiceDate = @SalesInvoiceDate, InvoiceNo=@ContractInvoiceNo,
						EditedDate=GETDATE(),EditedBy = @EditedBy, AuthorizedStatus = 'A',DueDate = @DueDate 
						 
						WHERE  [ERP.HRMS].ContractInvoice.ContractInvoiceId IN (SELECT ContractInvoiceId FROM @TempServiceDetails)
						--------------------------------------------------------------------------------------------------
						UPDATE [ERP.HRMS].ContractInvoice SET InvoiceStatus = 'I', SalesInvoiceId =@SalesInvoiceId,
						SalesInvoiceNo =@InvoiceNo  
						WHERE (ContractInvoiceId IN (SELECT ContractInvoiceId FROM @TempServiceDetails) );
						
						SELECT @ContractInvoiceTabulationId = ContractInvoiceTabulationId FROM [ERP.HRMS].ContractInvoice 
						WHERE ContractInvoiceId = @ContractInvoiceId
						SELECT @RecordCount = COUNT(1) FROM [ERP.HRMS].ContractInvoice WHERE ContractInvoiceTabulationId = @ContractInvoiceTabulationId 
						SELECT @InvoicedCount = COUNT(1) FROM [ERP.HRMS].ContractInvoice 
						WHERE ContractInvoiceTabulationId = @ContractInvoiceTabulationId AND ISNULL(InvoiceStatus,'') = 'I'		
						IF(@RecordCount=@InvoicedCount) 
						BEGIN
							UPDATE [ERP.HRMS].ContractInvoiceTabulation SET InvoiceStatus = 'I' WHERE ContractInvoiceTabulationId= @ContractInvoiceTabulationId
						END	
						ELSE IF(@InvoicedCount<@RecordCount AND @InvoicedCount>0)
						BEGIN
							UPDATE [ERP.HRMS].ContractInvoiceTabulation SET InvoiceStatus = 'P' WHERE ContractInvoiceTabulationId= @ContractInvoiceTabulationId	
						END 					
					END
					IF @Type = 'TI'
					BEGIN
						IF @TimesheetCount>0
						BEGIN
							INSERT INTO [ERP.Inventory].SalesInvoiceTimeSheetDetails
							(
								SalesInvoiceId, TimeSheetTabulationId, TimeSheetTabulationDetailsId, EmployeeId, SalaryCalculationType, 
								  ProjectJobId, LocationId, WorkedHr, TotalAmount, WorkedOTHr, TotalOTAmount, NetAmount, Remarks,
								  DiscountType,DiscountPercentage,DiscountAmount
							)
							SELECT 
								@SalesInvoiceId, TimeSheetTabulationId, TimeSheetTabulationDetailsId, EmployeeId, SalaryCalculationType, 
								ProjectJobId, LocationId, WorkedHr, TotalAmount, WorkedOTHr, TotalOTAmount, NetAmount, Remarks,
								DiscountType,DiscountPercentage,DiscountAmount
							FROM @TempTimesheet WHERE SalesInvoiceTimeSheetId=0

							UPDATE [ERP.Inventory].SalesInvoiceTimeSheetDetails SET 
								TimeSheetTabulationId =tp.TimeSheetTabulationId, TimeSheetTabulationDetailsId =tp.TimeSheetTabulationDetailsId, 
								EmployeeId =tp.EmployeeId, SalaryCalculationType =tp.SalaryCalculationType, ProjectJobId =tp.ProjectJobId, 
								LocationId =tp.LocationId, WorkedHr =tp.WorkedHr, TotalAmount =tp.TotalAmount, WorkedOTHr =tp.WorkedOTHr, 
								TotalOTAmount =tp.TotalOTAmount, NetAmount =tp.NetAmount,  Remarks =tp.Remarks,
								DiscountType=tp.DiscountType,DiscountPercentage=tp.DiscountPercentage,DiscountAmount=tp.DiscountAmount
							FROM @TempTimesheet as tp INNER JOIN [ERP.Inventory].SalesInvoiceTimeSheetDetails as SITD 
							ON tp.SalesInvoiceTimeSheetId=SITD.SalesInvoiceTimeSheetId AND tp.EmployeeId=SITD.EmployeeId
							WHERE  (tp.SalesInvoiceTimeSheetId >0) AND (SITD.SalesInvoiceId=@SalesInvoiceId)
							
							UPDATE TTD
							SET TTD.InvoiceStatus = 'I' 
							FROM [ERP.HRMS].TimeSheetTabulationDetails TTD
							JOIN @TempTimesheet T ON TTD.TimeSheetTabulationDetailsId=T.TimeSheetTabulationDetailsId AND TTD.EmployeeId=T.EmployeeId

							UPDATE [ERP.HRMS].TimeSheetTabulation 
							SET TabulationStatus =CASE ISNULL((SELECT COUNT(*) FROM [ERP.HRMS].TimeSheetTabulationDetails 
																WHERE InvoiceStatus='N' AND TimeSheetTabulationId=[ERP.HRMS].TimeSheetTabulation.TimeSheetTabulationId),0) 
												WHEN 0 THEN 'I' ELSE 'P' END
							WHERE TimeSheetTabulationId IN (SELECT TimeSheetTabulationId FROM @TempTimesheet)
						END

					END
					ELSE
						UPDATE [ERP.Inventory].SalesOrder SET InvoiceStatusId = 'I' WHERE (SalesOrderId = @SalesOrderId);
					
				END
				ELSE IF (@Type='AI' AND @IsCredit=0)
				BEGIN

					SET @SettingsId=79 -- Customer Receipt Invoice	

					 EXEC [ERP.Config].[GenerateNewNumber] @ReceiptNo OUT,@SettingsId,@BranchId,@FinYear

					IF @ReceiptNo<>''
					BEGIN
						-----insert into Supplier payment
						INSERT INTO [ERP.Inventory].CustomerReceipts
						(
							CustomerId, ReceiptDate, ReceiptNo, ReferenceNo, PaymentMethodId, ChequeNo, 
							ChequeDate,ChequeDetails, CardNo,AccountId, BankAccountId,IsInvoicewise,IsAdvance, 
							ReceivedAmount, Notes, CreatedBy, CreatedDate, EditedBy, EditedDate, EntryStatus, 
							DiscountAmount, NetAmount,CurrencyId,CurrencyRate,ReceivedAmountCustCurrency,
							DiscountAmountCustCurrency , NetAmountCustCurrency, IsAdjustment,CostCenterId,
							BankCurrencyId,BankCurrencyRate,NetAmountInBankCurrency,ReceiptStatus,RoundOffAmount,
							RoundOffAmountInCustCurrency
						)
						SELECT
							@CustomerId,@SalesInvoiceDate, @ReceiptNo, @ReferenceNo, @PaymentMethodId,@ChequeNo, 
							@ChequeDate,@ChequeDetails, @CardNo, @ReceiptAccountId,@BankAccountId,0,1,@NetAmount, 
							@Notes, @CreatedBy, GETDATE(), @CreatedBy, GETDATE(), 'A', 0, @NetAmount,@CurrencyId,@CurrencyRate,
							@NetAmountInCustCurrency,0,@NetAmountInCustCurrency, 0,
							CASE WHEN @CostCenterId=0 THEN NULL ELSE @CostCenterId END,
							@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,
							CASE WHEN @SalesStatusId='O' THEN 'O' ELSE 'A' END,@RoundOff,
							@RoundOffInCustCurrency
						FROM @TempAdvanceInvoice
				
						SET @CustomerReceiptId=SCOPE_IDENTITY()

						INSERT INTO [ERP.Inventory].CustomerReceiptDetails
						(
							CustomerReceiptId,SalesInvoiceId, RecievedAmount, Narration,CustOpeningBalanceId, 
							RecievedAmountCustCurrency,SlNo,CostCenterId
						)
						SELECT 
							@CustomerReceiptId, @SalesInvoiceId, @NetAmount, @Remarks,
							NULL,@NetAmountInCustCurrency,RowNumber,CASE WHEN @CostCenterId=0 THEN NULL ELSE @CostCenterId END
						FROM @TempAdvanceInvoice
					END
					IF (@Type='AI' AND @IsCredit=0)
					BEGIN
						INSERT INTO [ERP.Finance].CustomerAdvance
						(
							CustomerId,CustomerReceiptId,TransDate,AdvanceAmount,AllottedAmount,Description,AdvanceStatus,CurrencyRate,
							AdvanceAmountCustCurrency,AllottedAmountCustCurrency,CostCenterId,SalesInvoiceId,TaxId,TaxAmount,
							TotalAmount,AllottedTaxAmount,TaxAmountCustCurrency,TotalAmountCustCurrency,AllottedTaxAmountCustCurrency,ProjectId
						)
						SELECT 
							@CustomerId,@CustomerReceiptId,@SalesInvoiceDate,AdvanceAmount,AllottedAmount,Description,
							CASE WHEN @SalesStatusId='O' THEN 'O' ELSE 'A' END,
							CurrencyRate,AdvanceAmountCustCurrency,AllottedAmountCustCurrency,@CostCenterId,@SalesInvoiceId,
							CASE WHEN TaxId=0 THEN NULL ELSE TaxId END,TaxAmount,TotalAmount,AllottedTaxAmount,TaxAmountCustCurrency,
							TotalAmountCustCurrency,AllottedTaxAmountCustCurrency,@ProjectId
						FROM @TempAdvanceInvoice
					END				
				END
				ELSE
				BEGIN
					IF @IsEdit=1
					BEGIN
							UPDATE [ERP.Inventory].SalesOrderBatchAndSerialDetails 
							SET InvoicedQuantity=ISNULL((SELECT SUM(SIBSD.Quantity)	FROM   [ERP.Inventory].SalesInvoice AS SInv 
									INNER JOIN [ERP.Inventory].SalesInvoiceDetails AS SID ON SInv.SalesInvoiceId = SID.SalesInvoiceId 
									INNER JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails AS SIBSD ON SID.SalesInvoiceDetailsId = SIBSD.SalesInvoiceDetailsId
									WHERE (SInv.SalesInvoiceId <> @SalesInvoiceId) AND (SInv.SalesStatusId <> 'CN') 
									AND (SInv.EntryStatus <> 'D') AND (SID.SalesOrderDetailsId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.SalesOrderDetailsId) 
									AND ((SIBSD.StockBatchNo =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.StockBatchNo AND ISNULL(SIBSD.StockBatchNo,'')<>'') 
										OR (SIBSD.BOMId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.BOMId AND ISNULL(SIBSD.BOMId,0)>0) )
									AND (SIBSD.ProductId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.ProductId)),0)
							WHERE SalesOrderDetailsId IN (SELECT SalesOrderDetailsId FROM @OldSIBatchAndSerialDetails)

							UPDATE [ERP.Inventory].GDNBatchAndSerialDetails 
							SET InvoicedQuantity=ISNULL((SELECT SUM(SIBSD.Quantity)	FROM   [ERP.Inventory].SalesInvoice AS SInv 
									INNER JOIN [ERP.Inventory].SalesInvoiceDetails AS SID ON SInv.SalesInvoiceId = SID.SalesInvoiceId 
									INNER JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails AS SIBSD ON SID.SalesInvoiceDetailsId = SIBSD.SalesInvoiceDetailsId
									WHERE (SInv.SalesInvoiceId <> @SalesInvoiceId) AND (SInv.SalesStatusId <> 'CN') 
									AND (SInv.EntryStatus <> 'D') AND (SID.GDNDetailsId =  [ERP.Inventory].GDNBatchAndSerialDetails.GDNDetailsId) 
									AND ((SIBSD.StockBatchNo =  [ERP.Inventory].GDNBatchAndSerialDetails.StockBatchNo AND ISNULL(SIBSD.StockBatchNo,'')<>'') 
										OR (SIBSD.BOMId =  [ERP.Inventory].GDNBatchAndSerialDetails.BOMId AND ISNULL(SIBSD.BOMId,0)>0) )
									AND (SIBSD.ProductId =  [ERP.Inventory].GDNBatchAndSerialDetails.ProductId)),0)
							WHERE GDNDetailsId IN (SELECT GDNDetailsId FROM @OldSIBatchAndSerialDetails)
					END
					SET @RowNumber=1
					IF @PageSessionId=0 SET @PageSessionId=-1
					WHILE @RowNumber<=@RecordCount
					BEGIN
						SELECT @XMLTransactionsToConsider='',@XMLSentProductBatchNos='',@XMLFetchBatchNo='',@XMLBatch=''

						SELECT 
							@RowId=InvRowId,@ProductID1=ProductId,@IsBatchOverRide=IsBatchOverRide,
							@SalesOrderDetailsId=SalesOrderDetailsId,@GdnDetailsId=GdnDetailsId,
							@UOMId1=UOMId,@CostPrice=CostPrice,@SalesInvoiceDetailsId=SalesInvoiceDetailsId
						FROM @TempDetails WHERE RowNumber=@RowNumber
						
						SELECT 
							@EnableBatch=EnableBatchWiseStock, @AutogenerateBatchNo=AutogenerateBatchNo,
							@EnableSerial= EnableSerializedStock,@AutogenerateSerialNo= AutogenerateSerialNo
						FROM  [ERP.Inventory].Product WHERE  ProductId = @ProductID1

						

						INSERT INTO [ERP.Inventory].SalesInvoiceDetails
						(
							SalesInvoiceId, ProductId,BundleId,AccountId,InvoiceType,SalesOrderDetailsId,LocatorId,  
							Quantity, UOMId,SalesRate,DiscountAmount,DiscountPercentage,DiscountType,TaxId,TaxAmount,
							TotalAmount ,DeliveryDate,Description,DescriptionArabic,IsActive,Narration,SerialNumber,
							SalesRateInCustCurrency,DiscountAmountInCustCurrency,TaxAmountInCustCurrency,
							TotalAmountInCustCurrency,IsComponent,BOMId,GDNId,GDNDetailsId,PaymentMethodId,
							BankAccountId,CardNo,ChequeNo,ChequeDate,IsFreeItem,IsTotalAmountEdited,SalesRateIncludVAT,
							SalesRateIncludVATCustCurrency,CostPrice,BankCurrencyId,BankCurrencyRate,TotalAmountInBankCurrency,
							TradeDiscountPercentage,TradeDiscountAmount,POLineNo,SpecialDiscountType,SpecialDiscountPercentage,
							SpecialDiscountAmount,SpeciaDiscountAmountInCustCurrency,IsBatchOverRide,RowId
						)
						SELECT 
							@SalesInvoiceId,
							CASE WHEN ProductId IS NULL OR ProductId = ''	OR ProductId=0 then NULL		else ProductId end,
							CASE WHEN BundleId = 0		OR BundleId = ''	OR BundleId IS NULL then NULL	else BundleId end,
							CASE WHEN AccountId IS NULL OR AccountId = ''	OR AccountId=0 then NULL		else AccountId end,
							InvoiceType,CASE WHEN SalesOrderDetailsId=0 OR SalesOrderDetailsId='' OR SalesOrderDetailsId IS NULL 
							THEN NULL ELSE SalesOrderDetailsId END,
							CASE WHEN LocatorId = 0 OR LocatorId = '' then NULL else LocatorId end , 
							Quantity,
							CASE WHEN UOMId = 0 OR UOMId = '' then NULL else UOMId end, 
							SalesRate,DiscountAmount,DiscountPercentage,DiscountType,TaxId,TaxAmount,TotalAmount,
							DeliveryDate,[Description],DescriptionArabic,1,Narration ,RowNumber,
							SalesRateInCustCurrency,DiscountAmountInCustCurrency,TaxAmountInCustCurrency,
							TotalAmountInCustCurrency,IsComponent,
							CASE WHEN BOMId IS NULL OR BOMId='' OR BOMId=0 THEN NULL ELSE BOMId END,
							case when  GDNId='' OR GDNId=0 then NULL else GDNId end  ,
							CASE WHEN GDNDetailsId='' OR GDNDetailsId=0 THEN NULL ELSE GDNDetailsId END,
							CASE WHEN PaymentMethodId=0 THEN NULL ELSE PaymentMethodId END,
							CASE WHEN BankAccountId=0 THEN NULL ELSE BankAccountId END,
							CardNo,ChequeNo,ChequeDate,IsFreeItem,IsTotalAmountEdited,
							SalesRateIncludVAT,SalesRateIncludVATCustCurrency,CostPrice,
							CASE WHEN BankCurrencyId=0 THEN NULL ELSE BankCurrencyId END,
							BankCurrencyRate,TotalAmountInBankCurrency,TradeDiscountPercentage,TradeDiscountAmount,
							POLineNo,SpecialDiscountType,SpecialDiscountPercentage,
							SpecialDiscountAmount,SpeciaDiscountAmountInCustCurrency,
							IsBatchOverRide,InvRowId
						FROM @TempDetails WHERE RowNumber=@RowNumber;

						SET @SalesInvoiceDetailsId=SCOPE_IDENTITY(); 

						UPDATE @TempSIBundles	SET SIDetailsId=@SalesInvoiceDetailsId		WHERE SIRowId=@RowId;

						IF @IsBatchOverRide=1
						BEGIN
							INSERT INTO @TempBatchAndSerialDetails
							(	
								BranchId,PageSessionId,SalesInvoiceDetailsId,ProductId,UOMId,StockBatchNo,BatchNo,
								BatchSerialNo,ManufacturingDate,ExpiryDate,Quantity,CostPrice,RowId,IsBatchOverRide	,BOMId			
							)
							SELECT 
								@BranchId,@PageSessionId,@SalesInvoiceDetailsId,@ProductID1,TSO.UOMId,TSO.StockBatchNo,TSO.BatchNo,
								TSO.BatchSerialNo,TSO.ManufacturingDate,TSO.ExpiryDate,TSO.Quantity,TSO.CostPrice,
								--[ERP.Inventory].[Fun_RunningAverageCostPriceOfProductAsOnDate](@ProductID1,TSO.UOMId,@SalesInvoiceDate,0),
								InvRowId,T.IsBatchOverRide,
								TSO.BOMId
							FROM [ERP.Inventory].TempSalesInvoiceBatchAndSerialDetails TSO
								JOIN @TempDetails T ON TSO.ProductRowId=T.InvRowId 
							WHERE T.RowNumber=@RowNumber
							AND TSO.PageSessionId=@PageSessionId AND TSO.BranchId=@BranchId
							AND T.ProductId=@ProductID1
						END
						ELSE
						BEGIN
							IF (@SalesOrderDetailsId>0 OR @GDNDetailsId>0)
							BEGIN

								SET @XMLSentProductBatchNos = (SELECT  ProductId, UOMId, Quantity,WarehouseId,LocatorId,InvRowId AS RowId,IsBatchOverRide	
												FROM @TempDetails WHERE RowNumber=@RowNumber
												FOR XML PATH('Row'), ROOT('RowSet') )
											
								SET @XMLSentProductBatchNos=REPLACE(@XMLSentProductBatchNos,'&','&amp;')
							
								IF @GDNDetailsId>0
								BEGIN
									SELECT @XMLTransactionsToConsider='<RowSet><Row><TransactionId>'+CONVERT(VARCHAR,@GDNDetailsId)+'</TransactionId></Row></RowSet>'
								END
								ELSE IF @CountXMLGDNs>0
								BEGIN
									SELECT @XMLTransactionsToConsider='<RowSet><Row><TransactionId>'+CONVERT(VARCHAR,SOD.SalesOrderDetailsId)+'</TransactionId></Row></RowSet>'
									FROM @TempGDNs TGDN
										JOIN [ERP.Inventory].GoodsDeliveryNote GDN ON TGDN.GDNId=GDN.GDNId
										JOIN [ERP.Inventory].SalesOrder SO ON GDN.SalesOrderId=SO.SalesOrderId
										JOIN [ERP.Inventory].SalesOrderDetails SOD ON SO.SalesOrderId=SOD.SalesOrderId
									WHERE SOD.SalesOrderDetailsId=@SalesOrderDetailsId AND GDN.EntryStatus<>'D' AND SO.EntryStatus<>'D'
								END
								ELSE
								BEGIN
									SELECT @XMLTransactionsToConsider='<RowSet><Row><TransactionId>'+CONVERT(VARCHAR,@SalesOrderDetailsId)+'</TransactionId></Row></RowSet>'
								END

								SET @XMLAlreadySelected =(SELECT T.ProductId,T.StockBatchNo,(T.Quantity*PUOM.ConversionValue) As QuantityInBase 
										FROM @TempBatchAndSerialDetails as T INNER JOIN [ERP.Inventory].ProductUOM as PUOM 
										ON T.ProductId=PUOM.ProductId AND T.UOMId=PUOM.UOMId
										WHERE T.ProductId=@ProductID1
									FOR XML PATH('Row'), ROOT('RowSet') )--Shefii
								
								IF @GDNDetailsId>0
								BEGIN
									EXEC [ERP.Inventory].[FetchProductDetailsBatchWise] @SpStatus4,@XMLFetchBatchNo OUT,
									@XMLSentProductBatchNos,'SIDGDN',@SalesInvoiceId,@MaxRowDetailsId,@XMLTransactionsToConsider,@SalesInvoiceDate,@XMLAlreadySelected,@StockId
								END
								ELSE
								BEGIN
									EXEC [ERP.Inventory].[FetchProductDetailsBatchWise] @SpStatus4,@XMLFetchBatchNo OUT,
									@XMLSentProductBatchNos,'SI',@SalesInvoiceId,@MaxRowDetailsId,@XMLTransactionsToConsider,@SalesInvoiceDate,@XMLAlreadySelected,@StockId
								END

								SET @XMLBatch = CAST(@XMLFetchBatchNo as XML)

								INSERT INTO @TempBatchAndSerialDetails
								(	
									BranchId,PageSessionId,SalesInvoiceDetailsId,ProductId,UOMId,StockBatchNo,BatchNo,
									BatchSerialNo,ManufacturingDate,ExpiryDate,Quantity,CostPrice,RowId,IsBatchOverRide	,
									BOMId
								)
								SELECT
									@BranchId,
									@PageSessionId,
									@SalesInvoiceDetailsId,
									@ProductID1,
									ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            	as UOMId,
									ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'nvarchar(1000)'),'')		as StockBatchNo,
									ISNULL(TEMP.I.value('(BatchNo/text())[1]', 'nvarchar(1000)'),'')			as BatchNo,
									ISNULL(TEMP.I.value('(BatchSerialNo/text())[1]', 'nvarchar(1000)'),'')		as BatchSerialNo,
									TEMP.I.value('(ManufacturingDate/text())[1]', 'Date')						as ManufacturingDate,
									TEMP.I.value('(ExpiryDate/text())[1]', 'Date')						        as ExpiryDate,
									ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)				as Quantity,
									ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)			as CostPrice,
									@RowId,
									@IsBatchOverRide,
									ISNULL(TEMP.I.value('(BOMId/text())[1]', 'bigint'),0)			            	as BOMId
								FROM @XMLBatch.nodes('/RowSet/Row') TEMP(I) 
							END
							ELSE
							BEGIN
								SET @XMLSentProductBatchNos = (SELECT  ProductId, UOMId, Quantity,WarehouseId,LocatorId,InvRowId AS RowId,IsBatchOverRide	
															FROM @TempDetails WHERE RowNumber=@RowNumber
															FOR XML PATH('Row'), ROOT('RowSet') )
							
								SET @XMLSentProductBatchNos=REPLACE(@XMLSentProductBatchNos,'&','&amp;')

								SET @XMLAlreadySelected =(SELECT T.ProductId,T.StockBatchNo,(T.Quantity*PUOM.ConversionValue) As QuantityInBase 
									FROM @TempBatchAndSerialDetails as T INNER JOIN [ERP.Inventory].ProductUOM as PUOM 
									ON T.ProductId=PUOM.ProductId AND T.UOMId=PUOM.UOMId
									WHERE T.ProductId=@ProductID1
								FOR XML PATH('Row'), ROOT('RowSet') ) --Shefii

								EXEC [ERP.Inventory].[FetchProductDetailsBatchWise] @SpStatus4,@XMLFetchBatchNo OUT,
								@XMLSentProductBatchNos,'SI',@SalesInvoiceId,@MaxRowDetailsId,'',@SalesInvoiceDate,@XMLAlreadySelected,@StockId

								SET @XMLBatch = CAST(@XMLFetchBatchNo as XML)

								INSERT INTO @TempBatchAndSerialDetails
								(	
									BranchId,PageSessionId,SalesInvoiceDetailsId,ProductId,UOMId,StockBatchNo,BatchNo,
									BatchSerialNo,ManufacturingDate,ExpiryDate,Quantity,CostPrice,RowId,IsBatchOverRide	,
									BOMId
								)
								SELECT
									@BranchId,
									@PageSessionId,
									@SalesInvoiceDetailsId,
									@ProductID1,
									ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            	as UOMId,	
									ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'nvarchar(1000)'),'')		as StockBatchNo,
									ISNULL(TEMP.I.value('(BatchNo/text())[1]', 'nvarchar(1000)'),'')			as BatchNo,
									ISNULL(TEMP.I.value('(BatchSerialNo/text())[1]', 'nvarchar(1000)'),'')		as BatchSerialNo,
									TEMP.I.value('(ManufacturingDate/text())[1]', 'Date')						as ManufacturingDate,
									TEMP.I.value('(ExpiryDate/text())[1]', 'Date')						        as ExpiryDate,
									ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)				as Quantity,
									ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)			as CostPrice,
									@RowId		            													as RowId,
									@IsBatchOverRide														    as IsBatchOverRide,
									ISNULL(TEMP.I.value('(BOMId/text())[1]', 'bigint'),0)			            	as BOMId
								FROM @XMLBatch.nodes('/RowSet/Row') TEMP(I) 
							END
						END
					
						SELECT @BatchCount=COUNT(*) FROM @TempBatchAndSerialDetails

						INSERT INTO [ERP.Inventory].SalesInvoiceBatchAndSerialDetails
						(
							SalesInvoiceDetailsId,StockBatchNo,BatchNo,BatchSerialNo,ManufacturingDate,
							ExpiryDate,Quantity,StockDescription,Remarks,RowId,ProductId,UOMId,CostPrice,BOMId
						)
						SELECT 
							@SalesInvoiceDetailsId,StockBatchNo,BatchNo,BatchSerialNo,ManufacturingDate,
							ExpiryDate,Quantity,'','',RowId,ProductId,UOMId,CostPrice,BOMId
						FROM @TempBatchAndSerialDetails WHERE ProductId=@ProductID1 AND RowId=@RowId

						UPDATE [ERP.Inventory].SalesOrderBatchAndSerialDetails 
							SET InvoicedQuantity=ISNULL((SELECT SUM(SIBSD.Quantity)	FROM   [ERP.Inventory].SalesInvoice AS SInv 
									INNER JOIN [ERP.Inventory].SalesInvoiceDetails AS SID ON SInv.SalesInvoiceId = SID.SalesInvoiceId 
									INNER JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails AS SIBSD ON SID.SalesInvoiceDetailsId = SIBSD.SalesInvoiceDetailsId
									WHERE (SInv.SalesStatusId <> 'CN') 
									AND (SInv.EntryStatus <> 'D') AND (SID.SalesOrderDetailsId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.SalesOrderDetailsId) 
									AND ((SIBSD.StockBatchNo =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.StockBatchNo AND ISNULL(SIBSD.StockBatchNo,'')<>'') 
										OR (SIBSD.BOMId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.BOMId AND ISNULL(SIBSD.BOMId,0)>0) )
									AND (SIBSD.ProductId =  [ERP.Inventory].SalesOrderBatchAndSerialDetails.ProductId)),0)
							WHERE SalesOrderDetailsId IN (SELECT SalesOrderDetailsId FROM @TempDetails)

							UPDATE [ERP.Inventory].GDNBatchAndSerialDetails 
							SET InvoicedQuantity=ISNULL((SELECT SUM(SIBSD.Quantity)	FROM   [ERP.Inventory].SalesInvoice AS SInv 
									INNER JOIN [ERP.Inventory].SalesInvoiceDetails AS SID ON SInv.SalesInvoiceId = SID.SalesInvoiceId 
									INNER JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails AS SIBSD ON SID.SalesInvoiceDetailsId = SIBSD.SalesInvoiceDetailsId
									WHERE (SInv.SalesStatusId <> 'CN') 
									AND (SInv.EntryStatus <> 'D') AND (SID.GDNDetailsId =  [ERP.Inventory].GDNBatchAndSerialDetails.GDNDetailsId) 
									AND ((SIBSD.StockBatchNo =  [ERP.Inventory].GDNBatchAndSerialDetails.StockBatchNo AND ISNULL(SIBSD.StockBatchNo,'')<>'') 
										OR (SIBSD.BOMId =  [ERP.Inventory].GDNBatchAndSerialDetails.BOMId AND ISNULL(SIBSD.BOMId,0)>0) )
									AND (SIBSD.ProductId =  [ERP.Inventory].GDNBatchAndSerialDetails.ProductId)),0)
							WHERE GDNDetailsId IN (SELECT GDNDetailsId FROM @TempDetails)
						
						IF @BatchCount>0
						BEGIN
							UPDATE SD SET SD.CostPrice=
							(
								SELECT 
									SUM(ISNULL(SB.CostPrice,0)*ISNULL(SB.Quantity,0))/SUM(ISNULL(SB.Quantity,0))  
								FROM [ERP.Inventory].SalesInvoiceDetails D
									JOIN [ERP.Inventory].SalesInvoiceBatchAndSerialDetails SB ON D.SalesInvoiceDetailsId=SB.SalesInvoiceDetailsId
								WHERE D.SalesInvoiceDetailsId=SD.SalesInvoiceDetailsId
							) 
							FROM [ERP.Inventory].SalesInvoiceDetails SD WHERE SD.SalesInvoiceId=@SalesInvoiceId AND SD.RowId=@RowId
						END
						SET @RowNumber=@RowNumber+1;

					END	 

					DELETE FROM [ERP.Inventory].TempSalesInvoiceBatchAndSerialDetails WHERE BranchId=@BranchId AND PageSessionId=@PageSessionId 

					IF(@Type='AI' AND @IsCredit=1)
					BEGIN
						INSERT INTO [ERP.Inventory].SalesInvoiceDetails
						(
							SalesInvoiceId, ProductId,BundleId,AccountId,InvoiceType,SalesOrderDetailsId,LocatorId,  
							Quantity,UOMId,SalesRate,DiscountAmount,DiscountPercentage,DiscountType,TaxId,TaxAmount,
							TotalAmount ,DeliveryDate,Description,DescriptionArabic,IsActive,Narration,SerialNumber,
							SalesRateInCustCurrency,DiscountAmountInCustCurrency,TaxAmountInCustCurrency,
							TotalAmountInCustCurrency,IsComponent,BOMId,GDNId,GDNDetailsId,PaymentMethodId,
							BankAccountId,CardNo,ChequeNo,ChequeDate,IsFreeItem,IsTotalAmountEdited,SalesRateIncludVAT,
							SalesRateIncludVATCustCurrency,CostPrice,BankCurrencyId,BankCurrencyRate,TotalAmountInBankCurrency,
							TradeDiscountPercentage,TradeDiscountAmount,POLineNo,SpecialDiscountType,SpecialDiscountPercentage,
							SpecialDiscountAmount,SpeciaDiscountAmountInCustCurrency
						)
						SELECT @SalesInvoiceId,NULL,0,0,NULL,NULL,NULL,
								0,NULL,AdvanceAmount,0,0,NULL,TaxId,TaxAmount,
								TotalAmount,GETDATE(),Description,NULL,1,NULL,1,
								AdvanceAmountCustCurrency,0,TaxAmountCustCurrency,
								TotalAmountCustCurrency,0,NULL,0,0,0,
								0,NULL,NULL,GETDATE(),0,0,0,
								0,0,NULL,0,0,
								0,0,NULL,0,0,
								0,0
						FROM @TempAdvanceInvoice
					END
				
					SET @RowNumber=1
					IF @BRecordCount>0
					BEGIN
						DELETE FROM @TempBatchAndSerialDetails

						WHILE @RowNumber<=@BRecordCount
						BEGIN
							SELECT 
								@RowId=SIRowId,@ProductID1=ProductId,@SalesInvoiceDetailsId=SIDetailsId
							FROM @TempSIBundles 
							WHERE RowNumber=@RowNumber

							SELECT @SalesOrderDetailsId=ISNULL(SalesOrderDetailsId,0) FROM [ERP.Inventory].SalesInvoiceDetails WHERE SalesInvoiceDetailsId=@SalesInvoiceDetailsId

							SET @XMLSentProductBatchNos = (SELECT  ProductId, UOMId, Quantity*BundleQty AS Quantity,WarehouseId,LocatorId,SIRowId AS RowId,0 AS IsBatchOverRide	
														FROM @TempSIBundles WHERE ProductId=@ProductID1 AND SIRowId=@RowId
														FOR XML PATH('Row'), ROOT('RowSet') )
							

							SET @XMLSentProductBatchNos=REPLACE(@XMLSentProductBatchNos,'&','&amp;')

							IF @SalesOrderDetailsId>0
							BEGIN
								SELECT @XMLTransactionsToConsider='<RowSet><Row><TransactionId>'+CONVERT(VARCHAR,@SalesOrderDetailsId)+'</TransactionId></Row></RowSet>'

								EXEC [ERP.Inventory].[FetchProductDetailsBatchWise] @SpStatus4,@XMLFetchBatchNo OUT,
								@XMLSentProductBatchNos,'SIB',@SalesInvoiceId,@MaxRowDetailsId,@XMLTransactionsToConsider,@SalesInvoiceDate,'',@StockId
							END
							ELSE
							BEGIN
								EXEC [ERP.Inventory].[FetchProductDetailsBatchWise] @SpStatus4,@XMLFetchBatchNo OUT,
								@XMLSentProductBatchNos,'SI',@SalesInvoiceId,@MaxRowDetailsId,'',@SalesInvoiceDate,'',@StockId
							END

							SET @XMLBatch = CAST(@XMLFetchBatchNo as XML)

							INSERT INTO @TempBatchAndSerialDetails
							(	
								BranchId,PageSessionId,SalesInvoiceDetailsId,ProductId,UOMId,StockBatchNo,BatchNo,
								BatchSerialNo,ManufacturingDate,ExpiryDate,Quantity,CostPrice,RowId,IsBatchOverRide,BOMId			
							)
							SELECT
								@BranchId,
								@PageSessionId,
								@SalesInvoiceDetailsId,
								@ProductID1,
								ISNULL(TEMP.I.value('(UOMId/text())[1]', 'int'),0)			            	as UOMId,	
								ISNULL(TEMP.I.value('(StockBatchNo/text())[1]', 'nvarchar(1000)'),'')		as StockBatchNo,
								ISNULL(TEMP.I.value('(BatchNo/text())[1]', 'nvarchar(1000)'),'')			as BatchNo,
								ISNULL(TEMP.I.value('(BatchSerialNo/text())[1]', 'nvarchar(1000)'),'')		as BatchSerialNo,
								TEMP.I.value('(ManufacturingDate/text())[1]', 'Date')						as ManufacturingDate,
								TEMP.I.value('(ExpiryDate/text())[1]', 'Date')						        as ExpiryDate,
								ISNULL(TEMP.I.value('(Quantity/text())[1]', 'decimal(24,5)'),0)				as Quantity,
								ISNULL(TEMP.I.value('(CostPrice/text())[1]', 'decimal(24,5)'),0)			as CostPrice,
								@RowId		            													as RowId,
								@IsBatchOverRide														    as IsBatchOverRide,
								ISNULL(TEMP.I.value('(BOMId/text())[1]', 'bigint'),0)			            	as BOMId
							FROM @XMLBatch.nodes('/RowSet/Row') TEMP(I) 

							----- Update with cost price---------
							--UPDATE @TempSIBundles 
							--	SET CostPrice=ISNULL([ERP.Inventory].[Fun_CostPriceOfProductAsOnDate](TSIB.ProductId,TSIB.UOMId,@SalesInvoiceDate,@SalesInvoiceDate),0)*PUOM.ConversionValue
							--FROM @TempSIBundles as TSIB INNER JOIN [ERP.Inventory].ProductUOM as PUOM 
							--ON TSIB.ProductId=PUOM.ProductId AND TSIB.UOMId=PUOM.UOMId
							
							UPDATE TB 
								SET CostPrice=ISNULL((SELECT SUM(ISNULL(TBSD.CostPrice,0)*ISNULL(TBSD.Quantity,0))/SUM(ISNULL(TBSD.Quantity,0))
								FROM @TempBatchAndSerialDetails TBSD WHERE TBSD.RowId=TB.SIRowId AND TBSD.ProductId=TB.ProductId),0)
							FROM @TempSIBundles TB
							WHERE TB.ProductId=@ProductID1 AND TB.SIDetailsId=@SalesInvoiceDetailsId

							INSERT INTO [ERP.Inventory].SalesInvoiceBundleDetails
							(
								SalesInvoiceDetailsId, BundleId, ProductId, WarehouseId, LocatorId, 
								Quantity, UOMId, SalesRate,SalesRateInCustCurrency,CostPrice,SalesRateIncludVAT,SalesRateIncludVATCustCurrency
							)
							SELECT 
								SIDetailsId, BundleId, ProductId, 
								CASE WHEN WarehouseId=0 THEN NULL ELSE WarehouseId END,
								CASE WHEN LocatorId=0 THEN NULL ELSE LocatorId END, 
								Quantity, CASE WHEN UOMId=0 THEN NULL ELSE UOMId END, 
								SalesRate,SalesRateInCustCurrency,CostPrice,
								SalesRateIncludVAT,SalesRateIncludVATCustCurrency
							FROM @TempSIBundles WHERE SIRowId=@RowId AND ProductId=@ProductID1 AND RowNumber=@RowNumber
							
							SET @SalesInvoiceBundleId=SCOPE_IDENTITY()

							INSERT INTO [ERP.Inventory].SalesInvoiceBundleBatchAndSerialDetails
							(	
								SalesInvoiceBundleId,SalesInvoiceDetailsId,StockBatchNo,BatchNo,BatchSerialNo,
								ManufacturingDate,ExpiryDate,Quantity,StockDescription,Remarks,RowId,ProductId,UOMId
							)
							SELECT 
								@SalesInvoiceBundleId,@SalesInvoiceDetailsId,StockBatchNo,BatchNo,BatchSerialNo,
								ManufacturingDate,ExpiryDate,Quantity,'','',RowId,ProductId,UOMId
							FROM @TempBatchAndSerialDetails WHERE ProductId=@ProductID1 AND RowId=@RowId

							SET @RowNumber=@RowNumber+1
						END
					END
					
					IF @StockId>0
					BEGIN
						INSERT INTO [ERP.Inventory].StockBatchAndSerialDetails
						(
							StockDetailsId,ProductId,WarehouseId,LocatorId,StockBatchNo,BatchNo,BatchSerialNo,
							ManufacturingDate,ExpiryDate,InStock,OutStock,UOMId,ConversionValue,PurchaseRate,
							SalesRate,CostPrice,StockStatus,ReferencNo,StockDescription,Remarks,RowId
						)
						SELECT 
							TSD.StockDetailsId,TSD.ProductId,TSD.WarehouseId,TSD.LocatorId,TBN.StockBatchNo,TBN.BatchNo,TBN.BatchSerialNo, 
							TBN.ManufacturingDate,TBN.ExpiryDate,0,TBN.Quantity,TBN.UOMId,TSD.ConversionValue,TSD.PurchaseRate, 
							TSD.SalesRate,TBN.CostPrice,'A',@InvoiceNo,'Sales Invoice',TSD.Remarks,TBN.RowId
						FROM #TempSDetails TSD
							INNER JOIN @TempBatchAndSerialDetails TBN ON TSD.RowId =TBN.RowId
						WHERE ISNULL(TBN.BOMId,0)=0

						INSERT INTO [ERP.Inventory].GDNBatchAndSerialDetails
						(
							GDNDetailsId,StockBatchNo,BatchNo,BatchSerialNo,ManufacturingDate,ExpiryDate,
							Quantity,StockDescription,Remarks,RowId,ProductId,UOMId,CostPrice,BOMId
						)
						SELECT 
							TS.GDNDetailsId,BS.StockBatchNo,BS.BatchNo,BS.BatchSerialNo,BS.ManufacturingDate,
							BS.ExpiryDate,BS.Quantity,'','',BS.RowId,BS.ProductId,BS.UOMId,BS.CostPrice,BS.BOMId
						FROM @TempBatchAndSerialDetails BS 
							JOIN @TempGDNItems TS ON BS.RowId=TS.GDNRowId 
						WHERE ISNULL(BS.BOMId,0)=0

						UPDATE [ERP.Inventory].BatchwiseStockSummary 
							SET OutStock =ISNULL((SELECT SUM(ISNULL(SBSD.OutStock,0) * ISNULL(SBSD.ConversionValue,1))
							FROM [ERP.Inventory].Stock S
								INNER JOIN 	[ERP.Inventory].StockDetails ST ON S.StockId = ST.StockId
								INNER JOIN [ERP.Inventory].StockBatchAndSerialDetails SBSD ON ST.StockDetailsId=SBSD.StockDetailsId 
								AND BS.StockBatchNo=SBSD.StockBatchNo AND ST.ProductId=SBSD.ProductId
							WHERE  (S.StockStatus = 'A') 
							AND (S.EntryStatus <> 'D') 
							AND (ST.ProductId = SD.ProductId) 
							AND (ST.StockStatus = 'A')),0)
						FROM  [ERP.Inventory].BatchwiseStockSummary BS 
							INNER JOIN [ERP.Inventory].StockBatchAndSerialDetails SBSD1 ON BS.ProductId=SBSD1.ProductId AND BS.StockBatchNo=SBSD1.StockBatchNo
							INNER JOIN [ERP.Inventory].StockDetails SD ON SBSD1.StockDetailsId=SD.StockDetailsId 
						WHERE SD.StockId=@StockId

						UPDATE [ERP.Inventory].BatchwiseStockSummary 
						SET IsClosedBatch=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN 0 ELSE 1 END,
							BatchClosedDate=CASE WHEN ISNULL(BS.InStock,0)-ISNULL(BS.OutStock,0)>0 THEN NULL ELSE @SalesInvoiceDate END
						FROM  [ERP.Inventory].BatchwiseStockSummary BS 
							INNER JOIN [ERP.Inventory].StockBatchAndSerialDetails SBSD ON BS.ProductId=SBSD.ProductId AND BS.StockBatchNo=SBSD.StockBatchNo
							INNER JOIN [ERP.Inventory].StockDetails SD ON SBSD.StockDetailsId=SD.StockDetailsId 
						WHERE SD.StockId=@StockId

						IF @BatchCount>0
						BEGIN
							UPDATE SD SET SD.CostPrice=
							(
								SELECT 
									SUM(SB.CostPrice*SB.OutStock)/SUM(SB.OutStock) 
								FROM [ERP.Inventory].StockBatchAndSerialDetails SB 
									JOIN [ERP.Inventory].StockDetails SD1 ON SD1.StockDetailsId=SB.StockDetailsId
								WHERE SD1.StockDetailsId=SD.StockDetailsId
							) 
							FROM [ERP.Inventory].StockDetails SD WHERE SD.StockId=@StockId
						END
						UPDATE [ERP.Inventory].StockDetails SET AverageCostPrice=CostPrice WHERE StockId=@StockId
					END
					IF @IsDirectInvoice=1 AND @SalesStatusId<>'O'
					BEGIN
						SELECT TOP(1) @BOMStockId=ISNULL(BOMStockId,0) FROM [ERP.Inventory].BOMStock 
						WHERE StockTransactionTypeId=@GDNStockTransactionTypeId AND TransactionId=@GDNId AND EntryStatus<>'D'
						ORDER BY BOMStockId DESC
						SET @BOMStockId=ISNULL(@BOMStockId,0)

						SELECT @BOMStockRecordCount=COUNT(*) FROM @TempBatchAndSerialDetails WHERE ISNULL(BOMId,0)>0
						IF @BOMStockRecordCount>0
						BEGIN
							IF @BOMStockId=0		 
							BEGIN
								INSERT INTO [ERP.Inventory].BOMStock
								(
									BranchId, StockDate, StockTransactionTypeId, TransactionId, StockStatus, ReferencNo, 
									Notes, Remarks, CreatedBy, CreatedDate, EditedBy, EditedDate, EntryStatus
								)
								VALUES 
								(
									@BranchId,@SalesInvoiceDate,@GDNStockTransactionTypeId,@GDNId, 'A',@GDNNo,@Notes,
									'BOM Stock insertion from GDN',@CreatedBy, GETDATE(),@CreatedBy, GETDATE(), 'A'
								)
								SET @BOMStockId=SCOPE_IDENTITY();
							END
							ELSE
							BEGIN
								UPDATE [ERP.Inventory].BOMStock
								SET BranchId = @BranchId, StockDate = @SalesInvoiceDate, StockTransactionTypeId = @GDNStockTransactionTypeId, 
									TransactionId = @GDNId, StockStatus = 'A', ReferencNo = @GDNNo, Notes = @Notes, Remarks = 'BOM Stock insertion from GDN', 
									EditedBy = @CreatedBy, EditedDate = GETDATE()
								WHERE BOMStockId=@BOMStockId

								DELETE FROM [ERP.Inventory].BOMStockDetails where BOMSTockId=@BOMStockId
							END
							INSERT INTO [ERP.Inventory].BOMStockDetails
							(
								BOMStockId, BOMId, WarehouseId, LocatorId, ManufacturingDate, Instock, OutStock, UOMId, 
								PurchaseRate, SalesRate, CostPrice, StockStatus, ReferenceNo, StockDescription, Remarks,BatchNo,RowId,ProductId
							)
							SELECT 
								@BOMStockId, TB.BOMId, WarehouseId, LocatorId, ManufacturingDate, 0, TB.Quantity, TB.UOMId, 
								0, SalesRate, TB.CostPrice, 'A', @InvoiceNo, '', '',BatchNo,RowId,TB.ProductId
							FROM @TempBatchAndSerialDetails as TB INNER JOIN @TempGDNItems  as T ON TB.RowId=T.GDNRowId

							INSERT INTO [ERP.Inventory].GDNBatchAndSerialDetails
							(
								GDNDetailsId,StockBatchNo,BatchNo,BatchSerialNo,ManufacturingDate,ExpiryDate,
								Quantity,StockDescription,Remarks,RowId,ProductId,UOMId,CostPrice,BOMId
							)
							SELECT 
								TS.GDNDetailsId,BS.StockBatchNo,BS.BatchNo,BS.BatchSerialNo,BS.ManufacturingDate,
								BS.ExpiryDate,BS.Quantity,'','',BS.RowId,BS.ProductId,BS.UOMId,BS.CostPrice,BS.BOMId
							FROM @TempBatchAndSerialDetails BS 
								JOIN @TempGDNItems TS ON BS.RowId=TS.GDNRowId
							WHERE ISNULL(BS.BOMId,0)>0
							END
							ELSE
							BEGIN
								DELETE FROM [ERP.Inventory].BOMStockDetails where BOMSTockId=@BOMStockId
								UPDATE [ERP.Inventory].BOMStock SET EntryStatus='D' WHERE BOMStockId=@BOMStockId
							END	
					
				----------------------------BOM Status--------------------------
				--ALTER TABLE #TempBOMStockDetails ADD RequiredQty decimal(24,5),DeliveredQty Decimal(24,5)

				--UPDATE #TempBOMStockDetails SET RequiredQty=ISNULL((SELECT SUM([ERP.Inventory].BOMStockDetails.Instock) AS Expr1
				--		FROM [ERP.Inventory].BOMStock INNER JOIN [ERP.Inventory].BOMStockDetails 
				--		ON [ERP.Inventory].BOMStock.BOMStockId = [ERP.Inventory].BOMStockDetails.BOMStockId
				--		WHERE  ([ERP.Inventory].BOMStockDetails.BOMId = #TempBOMStockDetails.BOMId) 
				--		AND ([ERP.Inventory].BOMStock.StockStatus = 'A') 
				--		AND ([ERP.Inventory].BOMStock.EntryStatus <> 'D') 
				--		AND ([ERP.Inventory].BOMStockDetails.StockStatus = 'A') ),0),
				--		DeliveredQty=ISNULL((SELECT SUM([ERP.Inventory].BOMStockDetails.OutStock) AS Expr1
				--		FROM [ERP.Inventory].BOMStock INNER JOIN [ERP.Inventory].BOMStockDetails 
				--		ON [ERP.Inventory].BOMStock.BOMStockId = [ERP.Inventory].BOMStockDetails.BOMStockId
				--		WHERE  ([ERP.Inventory].BOMStockDetails.BOMId = #TempBOMStockDetails.BOMId) 
				--		AND ([ERP.Inventory].BOMStock.StockStatus = 'A') 
				--		AND ([ERP.Inventory].BOMStock.EntryStatus <> 'D') 
				--		AND ([ERP.Inventory].BOMStockDetails.StockStatus = 'A') ),0)
					UPDATE [ERP.Inventory].BillOfMaterial SET DeliveryStatus= CASE WHEN 
							ISNULL((SELECT SUM([ERP.Inventory].BOMStockDetails.Instock) -SUM([ERP.Inventory].BOMStockDetails.OutStock) 
							FROM [ERP.Inventory].BOMStock INNER JOIN [ERP.Inventory].BOMStockDetails 
							ON [ERP.Inventory].BOMStock.BOMStockId = [ERP.Inventory].BOMStockDetails.BOMStockId
							WHERE  ([ERP.Inventory].BOMStockDetails.BOMId = Temp.BOMId) 
							AND ([ERP.Inventory].BOMStock.StockStatus = 'A') 
							AND ([ERP.Inventory].BOMStock.EntryStatus <> 'D') 
							AND ([ERP.Inventory].BOMStockDetails.StockStatus = 'A') ),0)=0 THEN 'D' 
						ELSE 
							CASE WHEN 
								ISNULL((SELECT SUM([ERP.Inventory].BOMStockDetails.OutStock) 
								FROM [ERP.Inventory].BOMStock INNER JOIN [ERP.Inventory].BOMStockDetails 
								ON [ERP.Inventory].BOMStock.BOMStockId = [ERP.Inventory].BOMStockDetails.BOMStockId
								WHERE  ([ERP.Inventory].BOMStockDetails.BOMId = Temp.BOMId) 
								AND ([ERP.Inventory].BOMStock.StockStatus = 'A') 
								AND ([ERP.Inventory].BOMStock.EntryStatus <> 'D') 
								AND ([ERP.Inventory].BOMStockDetails.StockStatus = 'A') ),0)>0
								THEN 'P'
								ELSE 'I' 
							END
						END
				FROM [ERP.Inventory].BillOfMaterial INNER JOIN @TempBatchAndSerialDetails AS Temp
				ON [ERP.Inventory].BillOfMaterial.BOMId=Temp.BOMId
				WHERE [ERP.Inventory].BillOfMaterial.BOMId IN (SELECT BOMId FROm @TempBatchAndSerialDetails WHERE IsNULL(BOMId,0)>0)

					--UPDATE [ERP.Inventory].BillOfMaterial 
					--	SET DeliveryStatus= CASE WHEN RequiredQty>DeliveredQty AND DeliveredQty>0 THEN 'P' 
					--	WHEN RequiredQty>DeliveredQty AND DeliveredQty=0 THEN 'I' ELSE 'D' END
					--FROM [ERP.Inventory].BillOfMaterial 
					--	INNER JOIN #TempBOMStockDetails as Temp ON [ERP.Inventory].BillOfMaterial.BOMId=Temp.BOMId
					END
				END

				DELETE FROM [ERP.Inventory].TempSalesOrderBundleDetails WHERE BranchId=@BranchId AND PageSessionId=@PageSessionId

				SET @SPStatus=1

				 --insert charge details
				IF  @CRecordCount>0
			    BEGIN
					INSERT INTO [ERP.Inventory].SalesInvoiceCharges
					(
						SalesInvoiceId, ChargeId,Amount, AmountInCustCurrency
					)
					SELECT  
						@SalesInvoiceId,ChargeId, Amount, AmountInCustCurrency 
					FROM @TempChargeDetails; 
				END
				
				IF @Type NOT IN ('C')
				BEGIN
					IF(@IsCredit=1 AND @Type='AI')
					BEGIN
						IF @AdvanceCount>0
						BEGIN
							SELECT 
								@TakenTaxAmount=SUM(TakenTaxAmount),@TakenTaxAmountCustCurrency=SUM(TakenTaxAmountCustCurrency) 
							FROM @TempAdvance
						END
						-----Customer Transaction
						INSERT INTO [ERP.Inventory].CustomerTransaction
						(
							CustomerId,TransDate,CreditedAmount,DebitedAmount,SalesInvoiceId,TransactionType,[Description],
							Remarks,CreatedBy,CreatedDate,EditedBy,EditedDate,EntryStatus, CurrencyRate,CreditedAmountCustCurrency, 
							DebitedAmountCustCurrency,CostCenterId,CreditedTaxAmount,DebitedTaxAmount,CreditedTaxAmountCustCurrency,
							DebitedTaxAmountCustCurrency,ProjectId,SalesManUserId
						)
						VALUES 
						(
							@CustomerId,@SalesInvoiceDate,0,@NetAmount-ISNULL(@TakenTaxAmount,0),@SalesInvoiceId,@TransactionType,'Sales Invoice',
							@Remarks,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A',@CurrencyRate, 0,
							@NetAmountInCustCurrency-ISNULL(@TakenTaxAmountCustCurrency,0),
							CASE WHEN @CostCenterId=0 THEN NULL ELSE @CostCenterId END,0,@TakenTaxAmount,0,@TakenTaxAmountCustCurrency,
							@ProjectId,@SalesManUserId
						)
					END
					ELSE
					BEGIN
						IF @AdvanceCount>0
						BEGIN
							SELECT 
								@TakenTaxAmount=SUM(TakenTaxAmount),@TakenTaxAmountCustCurrency=SUM(TakenTaxAmountCustCurrency) 
							FROM @TempAdvance
						END
						-----Customer Transaction
						INSERT INTO [ERP.Inventory].CustomerTransaction
						(
							CustomerId,TransDate,CreditedAmount,DebitedAmount,SalesInvoiceId,TransactionType,[Description],
							Remarks,CreatedBy,CreatedDate,EditedBy,EditedDate,EntryStatus, CurrencyRate,CreditedAmountCustCurrency, 
							DebitedAmountCustCurrency,CostCenterId,CreditedTaxAmount,DebitedTaxAmount,CreditedTaxAmountCustCurrency,
							DebitedTaxAmountCustCurrency,ProjectId,SalesManUserId
						)
						VALUES 
						(
							@CustomerId,@SalesInvoiceDate,0,@NetAmount-ISNULL(@TakenTaxAmount,0),@SalesInvoiceId,@TransactionType,'Sales Invoice',
							@Remarks,@CreatedBy,GETDATE(),@CreatedBy,GETDATE(),'A',@CurrencyRate, 0,
							@NetAmountInCustCurrency-ISNULL(@TakenTaxAmountCustCurrency,0),
							CASE WHEN @CostCenterId=0 THEN NULL ELSE @CostCenterId END,0,@TakenTaxAmount,0,@TakenTaxAmountCustCurrency,
							@ProjectId,@SalesManUserId
						)
					END
				END	 
				IF @Type='C' --OR @Type='P'
				BEGIN
					IF @MixedModeRecordCount>0 AND @PaymentMethodId=5
					BEGIN
						INSERT INTO [ERP.Inventory].[SalesInvoiceMixedReceiptDetails]
						(
							SalesInvoiceId, PaymentMethodId, ChequeNo, ChequeDate, ChequeDetails, 
							AccountId, BankAccountId, CardNo, Remarks,Amount,AmountInCustCurrency,
							BankCurrencyId,BankCurrencyRate,AmountInBankCurrency
						)
						SELECT 
							@SalesInvoiceId,PaymentMethodId, ChequeNo, ChequeDate, ChequeDetails, 
							AccountId, BankAccountId, CardNo, Remarks,Amount,AmountInCustCurrency,
							CASE WHEN BankCurrencyId=0 THEN NULL ELSE BankCurrencyId END,
							BankCurrencyRate,AmountInBankCurrency
						FROM @TempCustomerMixedReceiptDetails
					END
				END
				

				IF @SalesOrderId>0 AND @Type<>'S' AND @Type<>'P' AND @Type<>'C' AND @InvoiceFromSalesOrder=1
				BEGIN
				
					----------------------- change sales order status ----- altered by lathika on 23-12-2016-----------
					SELECT @OrderedQty=SUM(Quantity) FROM [ERP.Inventory].SalesOrderDetails WHERE (SalesOrderId = @SalesOrderId);
					SELECT @InvoicedQty=SUM([ERP.Inventory].SalesInvoiceDetails.Quantity)
					FROM [ERP.Inventory].SalesInvoiceDetails INNER JOIN [ERP.Inventory].SalesInvoice 
					ON [ERP.Inventory].SalesInvoiceDetails.SalesInvoiceId = [ERP.Inventory].SalesInvoice.SalesInvoiceId
					WHERE ([ERP.Inventory].SalesInvoice.SalesOrderId = @SalesOrderId) 
					AND ([ERP.Inventory].SalesInvoice.EntryStatus <> 'D') 
					AND ([ERP.Inventory].SalesInvoiceDetails.IsActive = 1) 
					AND ([ERP.Inventory].SalesInvoice.SalesStatusId <> 'CN')
					AND ([ERP.Inventory].SalesInvoiceDetails.InvoiceType <> 'A')
					IF @OrderedQty=@InvoicedQty  
					BEGIN
						UPDATE [ERP.Inventory].SalesOrder SET InvoiceStatusId = 'I', ShippingAddress1 =@ShipmentAddress1  WHERE (SalesOrderId = @SalesOrderId)
					END
					ELSE
					BEGIN
						UPDATE [ERP.Inventory].SalesOrder SET InvoiceStatusId = 'PI' , ShippingAddress1 =@ShipmentAddress1 WHERE (SalesOrderId = @SalesOrderId)
					END
				END
				IF @SalesStatusId<>'O'
				BEGIN
					SET @XMLAccounts='<RowSet>';

					IF(@ContractInvoiceId IS NOT NULL)
					BEGIN
						SET @SalesAccountId=CONVERT(BIGINT,[ERP.HRMS].[Fun_GetHRMSGLSettingsValue](@BranchId,'4'))
					
						SET @XMLAccounts=@XMLAccounts+'<Row>
						<AccountId>'+CONVERT(VARCHAR,@SalesAccountId)+'</AccountId>
						<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
						<CreditAmount>'+CONVERT(VARCHAR,@TotalAmount)+'</CreditAmount>
						<DebitAmount>0</DebitAmount> 
						<Description>Contract Invoice</Description>
						<Narration>Contract Invoice</Narration>
						<CustomerId>'+ CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
						<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
						<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
						<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@TotalAmountInCustCurrency)+'</CreditAmountTransCurrency>
						<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
						</Row>'
					END
					ELSE IF(@Type='TI')
					BEGIN
						SELECT @ProjectAccountId=ProjectIncomeAccountId--,@RetentionAccountId=RetentionAccountId 
						FROM  [ERP.Service].ProjectAccountSettings 	WHERE ProjectId=@ProjectId
					
						SET @XMLAccounts=@XMLAccounts+'<Row>
						<AccountId>'+CONVERT(VARCHAR,@ProjectAccountId)+'</AccountId>
						<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
						<CreditAmount>'+CONVERT(VARCHAR,@TotalAmount)+'</CreditAmount>
						<DebitAmount>0</DebitAmount>
						<Description>TimeSheet Invoice</Description>
						<Narration>TimeSheet Invoice</Narration>
						<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
						<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
						<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
						<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@TotalAmountInCustCurrency)+'</CreditAmountTransCurrency>
						<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
						</Row>'
					END
					ELSE
						SET @SalesAccountId=CONVERT(BIGINT,ISNULL([ERP.Finance].[Fun_GetFinancialSettingsValue](@BranchId,'SalesAccount'),0));
						SET @SalesDiscountAccountId=CONVERT(BIGINT,ISNULL([ERP.Finance].[Fun_GetFinancialSettingsValue](@BranchId,'SalesDiscountAccount'),0));
						SET @RoundOffAccountId=CONVERT(BIGINT,ISNULL([ERP.Finance].[Fun_GetFinancialSettingsValue](@BranchId,'RoundOffAccount'),0));
						SET @CustomerServiceAccountId=CONVERT(BIGINT,ISNULL([ERP.Finance].[Fun_GetFinancialSettingsValue](@BranchId,'ServiceAccount'),0));
						SET @UnbilledSalesAccountId=CONVERT(INT,ISNULL([ERP.Finance].Fun_GetFinancialSettingsValue(@BranchId,'UnbilledSalesAccount'),0))
						SET @FreeItemAccountID=CONVERT(BIGINT,ISNULL([ERP.Config].[Fun_GetGeneralSettingsValue](@BranchId,'FreeItemPostToAccount'),0))
						SET @SeparateAccountForPDC=CONVERT(BIT,ISNULL([ERP.Config].Fun_GetGeneralSettingsValue(@BranchId,'SeparateAccountForPDC'),0));
						SET @VatAdvanceAccountId=CONVERT(BIGINT,ISNULL([ERP.Finance].[Fun_GetFinancialSettingsValue](@BranchId,'VATAdvanceAccount'),0));
						SET @SpecialDiscountAccountId=CONVERT(BIGINT,ISNULL([ERP.Config].Fun_GetGeneralSettingsValue(@BranchId,'SpecialDiscountPostToAccount'),0));
						--select @SpecialDiscountAccountId as SpecialDiscountAccountId
						IF @Type<>'C'
						BEGIN
							SELECT @CustomerAccountId=AccountId, @CustomerName=[ERP.Inventory].Customer.CustomerName,
								   @CustomerNameArabic=ISNULL([ERP.Inventory].Customer.CustomerNameArabic,''),
								   @IsSubCustomer=IsSubCustomer,@AccountPostTo=AccountPostTo 
							FROM [ERP.Inventory].Customer WHERE (CustomerId = @CustomerId);

							IF @IsSubCustomer=1 AND @AccountPostTo='P'
							BEGIN
								SELECT  @CustomerAccountId=ParentCustomer.AccountId 
								FROM [ERP.Inventory].Customer INNER JOIN [ERP.Inventory].Customer AS ParentCustomer 
								ON [ERP.Inventory].Customer.ParentCustomerId = ParentCustomer.CustomerId
								WHERE ([ERP.Inventory].Customer.CustomerId = @CustomerId)
							END
						END
						ELSE SET @CustomerName=@CashCustomerName;

						SET @CustomerName=ISNULL(@CustomerName,'');

						IF @Type='S' 
						BEGIN
							SET @XMLAccounts=@XMLAccounts+'<Row>
									<AccountId>'+CONVERT(VARCHAR,@CustomerServiceAccountId)+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>'+CONVERT(VARCHAR,@TotalAmount)+'</CreditAmount>
									<DebitAmount>0</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N' حساب الخدمات'+'</Description>
									<Narration>'+@CustomerName+'-Service account</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@TotalAmountInCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency></Row>';
						END
						ELSE IF @Type='P'
						BEGIN
							SELECT 
								@ProgressiveInvoiceAmount=SUM(ISNULL(TotalAmount,0)),
								@ProgressiveInvoiceAmountCustCurrency=SUM(ISNULL(TotalAmount,0)/ISNULL(@CurrencyRate,0)),
								@ProgressiveNetAMount=SUM(ISNULL(NetAmount,0)),
								@ProgressiveRetensionAmount=SUM(ISNULL(RetentionAmount,0)),
								@ProgressiveRetensionAmountCustCurrency=SUM(ISNULL(RetentionAmount,0)/ISNULL(@CurrencyRate,0))
							FROM @TempServiceDetails
					
							SELECT @ProjectAccountId=[ERP.Service].Project.AccountId, @RetentionAccountId=[ERP.Service].Project.RetentionAccountId
							FROM [ERP.Service].CustomerServiceOrder INNER JOIN [ERP.Service].Project 
							ON [ERP.Service].CustomerServiceOrder.ProjectId = [ERP.Service].Project.ProjectId 
							WHERE  ([ERP.Service].CustomerServiceOrder.CSOId = @CSOId)
							--select @ProgressiveInvoiceAmount,@ProgressiveNetAMount,@ProgressiveRetensionAmount,@ProjectAccountId,@RetentionAccountId

							--SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@CustomerAccountId)+
							--		'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
							--		'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,@ProgressiveNetAMount)+
							--		'</DebitAmount><Description>Progressive Net Amount</Description>'
							--		+'<Narration>'+@CustomerName+'-Progressive Net Amount</Narration><CustomerId>'+
							--		CONVERT(VARCHAR,@CustomerId)+'</CustomerId></Row>';

							SET @XMLAccounts=@XMLAccounts+'<Row>
									<AccountId>'+CONVERT(VARCHAR,@ProjectAccountId)+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>'+CONVERT(VARCHAR,@ProgressiveInvoiceAmount)+'</CreditAmount>
									<DebitAmount>0</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N' مبلغ الفاتورة التدريجية'+'</Description>
									<Narration>'+@CustomerName+'-Progressive Invoice Amount</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@ProgressiveInvoiceAmountCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency></Row>';

							IF @RetentionAccountId > 0 
							BEGIN
							SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@RetentionAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>0</CreditAmount>
									<DebitAmount>'+CONVERT(VARCHAR,@ProgressiveRetensionAmount)+'</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N' مبلغ التأمين التدريجي'+'</Description>
									<Narration>'+@CustomerName+'-Progressive Retension Amount</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@ProgressiveRetensionAmountCustCurrency)+'</DebitAmountTransCurrency>
									</Row>';
							END
						END
						ELSE IF @Type='PR'
						BEGIN
							--------Insert into sales invoice retension
							IF @RetentionAmount>0
							BEGIN
								SELECT @InvoiceRetentionDetailsId=ISNULL(InvoiceRetentionDetailsId,0) FROM [ERP.Inventory].SalesInvoiceRetentionDetails WHERE  (SalesInvoiceId = @SalesInvoiceId)
								SELECT @RetentionSlNo=MAX(SlNo) FROM [ERP.Inventory].SalesInvoiceRetentionDetails WHERE  (ProjectId = @ProjectId)
								SET @RetentionSlNo=ISNULL(@RetentionSlNo,0)+1;
								IF @InvoiceRetentionDetailsId IS NULL OR @InvoiceRetentionDetailsId=0
								BEGIN
									INSERT INTO [ERP.Inventory].SalesInvoiceRetentionDetails
									(SalesInvoiceId, SlNo, ProjectId, RetentionAmount, InvoicedAmount,RetentionAmountCustCurrency,InvoicedAmountCustCurrency)
									VALUES (@SalesInvoiceId,@RetentionSlNo,@ProjectId,@RetentionAmount,0,@RetentionAmountCustCurrency,0)
								END
								ELSE
								BEGIN
									UPDATE [ERP.Inventory].SalesInvoiceRetentionDetails
									SET SalesInvoiceId = @SalesInvoiceId, SlNo = @RetentionSlNo, ProjectId = @ProjectId, RetentionAmount = @RetentionAmount ,
									RetentionAmountCustCurrency=@RetentionAmountCustCurrency
									WHERE  (InvoiceRetentionDetailsId = @InvoiceRetentionDetailsId)
								END
							END
							SELECT @ProjectAccountId=ProjectIncomeAccountId,@RetentionAccountId=RetentionAccountId ,
									@PerformanceBondAccountId=PerformanceBondAccountId
							FROM     [ERP.Service].ProjectAccountSettings 	WHERE ProjectId=@ProjectId
							--SELECT @ProjectInvoiceTotal=SUM(TotalAmount) FROm @TempProjectDetails
							--SET @RetensionAmount=@ProjectInvoiceTotal*ISNULL((SELECT RetentionPercentage FROM [ERP.Service].Project WHERE ProjectId=@ProjectId),0)/100
							--SELECT @ProjectInvoiceTotal=SUM(InvoiceAmount) FROm @TempProjectDetails

							SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@ProjectAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>'+CONVERT(VARCHAR,@TotalAmount)+
									'</CreditAmount><DebitAmount>0</DebitAmount><Description>'+@CustomerNameArabic+'</Description>'
									+'<Narration>'+@CustomerName+'-Project Invoice Amount</Narration><CustomerId>'+
									CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@TotalAmountInCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency></Row>';
					
							IF @RetentionAccountId > 0 AND @RetentionAmount>0
							BEGIN
								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@RetentionAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,@RetentionAmount)+
									'</DebitAmount><Description>'+@CustomerNameArabic+''+N' مبلغ التأمين التدريجي'+'</Description>'
									+'<Narration>'+@CustomerName+'-Progressive Retension Amount</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+ CONVERT(VARCHAR,@RetentionAmountCustCurrency)+'</DebitAmountTransCurrency>
									</Row>';
							END

							IF @PerformanceBondAccountId > 0 AND @PerformanceBondAccountId>0
							BEGIN
								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@PerformanceBondAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,@PerformanceBondAmount)+
									'</DebitAmount><Description>'+@CustomerNameArabic+''+N' التأمينات النهائية'+'</Description>'
									+'<Narration>'+@CustomerName+'-Performance Bond Amount</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+ CONVERT(VARCHAR,@PerformanceBondAmountCustCurrency)+'</DebitAmountTransCurrency>
									</Row>';
							END
						END
						ELSE IF @Type='RI'
						BEGIN
							SELECT @RetentionCount=COUNT(*) FROM @TempRetentionInvoice
							SET @ACRowNumber=1
							WHILE @ACRowNumber <=@RetentionCount
							BEGIN
								SELECT 
									@RetentionAccountId=RetentionAccountId,@AcTotalAmount=TotalAmount ,
									@ACTotalAmountCustCurrency=TotalAmountCustCurrency
								FROm @TempRetentionInvoice WHERE RowNumber=@ACRowNumber

								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@RetentionAccountId)+'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>'+CONVERT(VARCHAR,@AcTotalAmount)+'</CreditAmount>
										<DebitAmount>0</DebitAmount>
										<Description>'+@CustomerNameArabic+''+N'مبلغ التقاعد'+'</Description>
										<Narration>'+@CustomerName+'-Retension Amount</Narration>
										<CustomerId>'+ CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
										<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
										<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@ACTotalAmountCustCurrency)+'</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
										</Row>';
								SET @ACRowNumber=@ACRowNumber+1;
							END
						END
						ELSE 
						BEGIN
							--product items-- 
							INSERT INTO @TempAc 
							SELECT 
								'Product'								as EntryName,
								PD.IncomeAccountId						as IncomeAccountId,
								PD.ExpenseAccountId						as ExpenseAccountId,
								PD.InventoryAssetAccountId				as InventoryAssetAccountId,
								--T.Quantity*(ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate]
								--(T.ProductId,@SalesInvoiceDate),0)*PUOM.ConversionValue) as TotalCostPrice,
								CASE WHEN PD.IsBOMItem=1 AND PD.CostCalculationMethod='A' THEN
									T.Quantity*[ERP.Inventory].[Fun_RunningAverageCostPriceOfProductAsOnDate](T.ProductId,T.UOMId,@SalesInvoiceDate,0)
								ELSE
								CASE WHEN @BatchCount>0 THEN 
								ISNULL((
									SELECT 
										SUM(TB.Quantity*TB.CostPrice) 
									FROM @TempBatchAndSerialDetails TB
									WHERE TB.ProductId=T.ProductId AND TB.RowId=T.InvRowId 
								),0)
								ELSE
								T.Quantity*(ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate]
								(T.ProductId,@SalesInvoiceDate),0)*PUOM.ConversionValue) END 
								END as TotalCostPrice,


								CASE WHEN T.IsTotalAmountEdited=1 THEN T.TotalAmount-T.TaxAmount ELSE
								CASE WHEN IsFreeItem=1 THEN (T.Quantity*T.SalesRate) 
								ELSE (T.Quantity*ISNULL(T.SalesRate,0))-T.DiscountAmount END END as TotalSalesPrice,
								T.IsFreeItem ,
								CASE WHEN IsFreeItem=1 THEN (T.Quantity*T.SalesRateinCustCurrency) 
								ELSE (T.Quantity*ISNULL(T.SalesRateInCustCurrency,0))-T.DiscountAmountInCustCurrency END as TotalSalesPriceCustCurrency						 
							FROM @TempDetails T 
								LEFT JOIN [ERP.Inventory].[Product] PD ON PD.ProductId=T.ProductId
								INNER JOIN [ERP.Inventory].ProductUOM PUOM ON T.ProductId=PUOM.ProductId AND T.UOMId =PUOM.UOMId
							WHERE PD.IsService=0 AND PD.IsProductionItem=0
								AND IsComponent=0 AND T.ProductId>0

							INSERT INTO @TempAc 
							SELECT 
								'Product'															as EntryName,
								[ERP.Inventory].[Product].IncomeAccountId							as IncomeAccountId,
								[ERP.Inventory].[Product].ExpenseAccountId							as ExpenseAccountId,
								[ERP.Inventory].[Product].InventoryAssetAccountId					as InventoryAssetAccountId,
								--(T.Quantity*TSIB.Quantity*ROUND((ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate]
								--(TSIB.ProductId,@SalesInvoiceDate),0)*PUOM.ConversionValue),@NumberFormat))		as TotalCostPrice,
								
								--CASE WHEN [ERP.Inventory].[Product].IsService=1 THEN
								--0
								--ELSE
								--(T.Quantity*TSIB.Quantity*(ISNULL([ERP.Inventory].[Fun_BaseCostPriceOfProductAsOnDate]
								--(TSIB.ProductId,@SalesInvoiceDate),0)*PUOM.ConversionValue))	
								--END																	as TotalCostPrice,

								CASE WHEN [ERP.Inventory].[Product].IsService=1 THEN 0
								ELSE (T.Quantity*TSIB.Quantity*(ISNULL(TSIB.CostPrice,0)*PUOM.ConversionValue))	END	as TotalCostPrice,

								(T.Quantity*TSIB.Quantity*ISNULL(TSIB.SalesRate,0))	as TotalSalesPrice,
								T.IsFreeItem,
								(T.Quantity*TSIB.Quantity*ISNULL(TSIB.SalesRateInCustCurrency,0)) as TotalSalesPriceCustCurrency
							FROM @TempDetails T 
								INNER JOIN @TempSIBundles as TSIB ON T.BundleId=TSIB.BundleId AND T.InvRowId=TSIB.SIRowId
								LEFT OUTER JOIN [ERP.Inventory].[Product] ON TSIB.ProductId=[ERP.Inventory].[Product].ProductId
								INNER JOIN [ERP.Inventory].ProductUOM as PUOM ON TSIB.ProductId=PUOM.ProductId AND TSIB.UOMId =PUOM.UOMId
							WHERE IsComponent=0 AND T.BundleId>0 
							
							----product items-- 
							INSERT INTO @TempAc 
							SELECT 
								'Component'														as EntryName,
								[ERP.Inventory].[Product].IncomeAccountId						as IncomeAccountId,
								[ERP.Inventory].[Product].ExpenseAccountId						as ExpenseAccountId,
								[ERP.Inventory].[Product].InventoryAssetAccountId				as InventoryAssetAccountId,
								T.Quantity*ISNULL((SELECT TOP(1) --ISNULL([ERP.Inventory].BillOfMaterial.Quantity,0)*
								ISNULL([ERP.Inventory].BillOfMaterial.CostPrice,0)
								FROM [ERP.Inventory].BillOfMaterial 
								WHERE  ([ERP.Inventory].BillOfMaterial.IsActive = 1) 
								AND ([ERP.Inventory].BillOfMaterial.EntryStatus <> 'D') 
								AND ([ERP.Inventory].BillOfMaterial.ProductId = T.ProductId) 
								AND ([ERP.Inventory].BillOfMaterial.BOMId = T.BOMId)),0)							as TotalCostPrice,
								(T.Quantity*ISNULL(T.SalesRate,0))-T.DiscountAmount									as TotalSalesPrice,
								T.IsFreeItem ,
								(T.Quantity*ISNULL(T.SalesRateInCustCurrency,0))-T.DiscountAmountInCustCurrency		as TotalSalesPriceCustCurrency
							FROM @TempDetails T 
								LEFT JOIN [ERP.Inventory].[Product] ON [ERP.Inventory].[Product].ProductId=T.ProductId
								INNER JOIN [ERP.Inventory].ProductUOM as PUOM ON T.ProductId=PUOM.ProductId AND T.UOMId =PUOM.UOMId
							Where [ERP.Inventory].[Product].IsService=0 
								AND IsComponent=1 AND T.ProductId>0

			 				INSERT INTO @TempAc 
							SELECT 
								'Service'														as EntryName,
								[ERP.Inventory].[Product].IncomeAccountId						as IncomeAccountId,
								[ERP.Inventory].[Product].ExpenseAccountId						as ExpenseAccountId,
								[ERP.Inventory].[Product].InventoryAssetAccountId				as InventoryAssetAccountId,
								--0			as InventoryAssetAccountId,
								ISNULL(TotalAmount,0)-ISNULL(TaxAmount,0)						as TotalCostPrice,
								--0					as TotalCostPrice,
								(T.Quantity*ISNULL(T.SalesRate,0))-T.DiscountAmount				as TotalSalesPrice,
								T.IsFreeItem,
								ISNULL(TotalAmountInCustCurrency,0)-ISNULL(TaxAmountInCustCurrency,0)						as TotalSalesPriceCustCurrency
							FROM @TempDetails T LEFT JOIN [ERP.Inventory].[Product] ON [ERP.Inventory].[Product].ProductId=T.ProductId
							WHERE [ERP.Inventory].[Product].IsService=1  
							
							---Production Item----
							INSERT INTO @TempAc 
							SELECT 
								'Product'														as EntryName,
								[ERP.Inventory].[Product].IncomeAccountId						as IncomeAccountId,
								[ERP.Inventory].[Product].ExpenseAccountId						as ExpenseAccountId,
								[ERP.Inventory].[Product].InventoryAssetAccountId				as InventoryAssetAccountId,
								T.Quantity*(PS.CostPrice/PS.InStockQty)*PUOM.ConversionValue	as TotalCostPrice,
								CASE WHEN IsFreeItem=1 THEN (T.Quantity*SalesRate) 
								ELSE (T.Quantity*ISNULL(T.SalesRate,0))-T.DiscountAmount END	as TotalSalesPrice,
								T.IsFreeItem ,
								CASE WHEN IsFreeItem=1 THEN (T.Quantity*SalesRateinCustCurrency) 
								ELSE (T.Quantity*ISNULL(T.SalesRateInCustCurrency,0))-T.DiscountAmountInCustCurrency END	as TotalSalesPriceCustCurrency						 
							FROM @TempDetails T 
								LEFT JOIN [ERP.Inventory].[Product] ON [ERP.Inventory].[Product].ProductId=T.ProductId
								INNER JOIN [ERP.Inventory].ProductUOM as PUOM ON T.ProductId=PUOM.ProductId AND T.UOMId =PUOM.UOMId
								JOIN [ERP.Inventory].ProductionStock PS ON T.ProductId=PS.ProductionItemId
								JOIN [ERP.Inventory].ProductionOrder PO ON PS.ProductionOrderId=PO.ProductionOrderId
								JOIN [ERP.Inventory].SalesOrder SO ON PO.SalesOrderId=SO.SalesOrderId
							WHERE [ERP.Inventory].[Product].IsProductionItem=1 AND T.ProductId>0
								AND SO.SalesOrderId=@SalesOrderId AND PS.InStockQty>0
							
							--- income entries
							INSERT INTO @TempIncomeEntries
							SELECT 
								IncomeAccountId ,
								SUM(TotalSalesPrice)-ISNULL((SELECT SUM(DiscountAmount) FROM @TempDetails WHERE BundleId>0),0) ,
								SUM(TotalSalesPriceCustCurrency)-ISNULL((SELECT SUM(DiscountAmountInCustCurrency) FROM @TempDetails WHERE BundleId>0),0)
							FROM @TempAc WHERE IsFreeItem=0
							GROUP BY IncomeAccountId

							--select * from @TempIncomeEntries
							SELECT @ACRecordCount=COUNT(*) FROM @TempIncomeEntries
							SET @ACRowNumber=1
							WHILE @ACRowNumber <=@ACRecordCount
							BEGIN
								SELECT @ACAccountId=IncomeAccountId,@AcTotalAmount=Amount,@ACTotalAmountCustCurrency=AmountCustCurrency 
								FROM @TempIncomeEntries WHERE RowNumber=@AcRowNumber

								SET @XMLAccounts=@XMLAccounts+'<Row>
									<AccountId>'+CONVERT(VARCHAR,@ACAccountId)+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>'+CASE WHEN @AcTotalAmount>=0 THEN CONVERT(VARCHAR,@AcTotalAmount) ELSE '0' END+'</CreditAmount>
									<DebitAmount>'+CASE WHEN @AcTotalAmount<0 THEN CONVERT(VARCHAR,ABS(@AcTotalAmount)) ELSE '0' END+'</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N' مدخلات الدخل'+'</Description>
									<Narration>'+@CustomerName+'-Income entries</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,@ACTotalAmountCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency>							
									</Row>';

								SET @ACRowNumber=@ACRowNumber+1;
							END
							--SELECT * FROM @TempAc
					
							--------------------------------Direct Invoice-----------------------

							Declare @IsAccountsEntry bit = 0; -------------For Checking GDN Entry Exists or Not -----------Shiju M
							If((Select Count(AccounttransId) from [ERP.Finance].AccountTrans where TransactionTypeId = 37 and TransactionId = @GDNId) > 0)
								SET @IsAccountsEntry = 1;
							Else
								SET @IsAccountsEntry = 0;

							--select @GDNId
							IF (@IsDirectInvoice=1 OR @IsAccountsEntry = 1)
							BEGIN
								------------------expense account------------
								INSERT INTO @TempACEntries 
								SELECT ExpenseAccountId,MAX(InventoryAssetAccountId),SUM(TotalCostPrice) FROM @TempAc
								WHERE EntryName<>'Service' AND IsfreeItem=0
								GROUP BY ExpenseAccountId --,InventoryAssetAccountId

								SELECT @ACRecordCount=COUNT(*) FROM @TempACEntries
								SET @ACRowNumber=1
								WHILE @ACRowNumber <=@ACRecordCount
								BEGIN
									SELECT @ACAccountId=ExpenseAccountId,@AcTotalAmount=TotalCostPrice 
									FROM @TempACEntries WHERE RowNumber=@AcRowNumber

									SET @XMLAccounts=@XMLAccounts+'<Row>
										<AccountId>'+CONVERT(VARCHAR,@ACAccountId)+'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>0</CreditAmount>
										<DebitAmount>'+CONVERT(VARCHAR,@AcTotalAmount)+'</DebitAmount>
										<Description>'+@CustomerNameArabic+''+N' حساب المصروفات - فاتورة المبيعات'+'</Description>
										<Narration>'+@CustomerName+'-Expense account -sales invoice</Narration>
										<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@BranchCurrencyId)+'</CurrencyId>
										<CurrencyRate>1</CurrencyRate>
										<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@AcTotalAmount)+'</DebitAmountTransCurrency>
									</Row>';

									SET @ACRowNumber=@ACRowNumber+1;
								END
								---------------------------- inventory asset--------------------
								DELETE FROM @TempACEntries
								INSERT INTO @TempACEntries 
								SELECT 
									MAX(ExpenseAccountId),(InventoryAssetAccountId),SUM(TotalCostPrice) 
								FROM @TempAc
								WHERE EntryName<>'Service' GROUP BY InventoryAssetAccountId
					
								SET @ACRowNumber=@ACRecordCount+1
								SELECT @ACRecordCount=ISNULL(@ACRecordCount,0)+COUNT(*) FROM @TempACEntries
								WHILE @ACRowNumber <=@ACRecordCount
								BEGIN
									SELECT @InventoryAssetAccountId=InventoryAssetAccountId,@AcTotalAmount=TotalCostPrice 
									FROM @TempACEntries WHERE RowNumber=@AcRowNumber

									SET @XMLAccounts=@XMLAccounts+'<Row>
										<AccountId>'+CONVERT(VARCHAR,@InventoryAssetAccountId)+'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>'+CONVERT(VARCHAR,@AcTotalAmount)+'</CreditAmount>
										<DebitAmount>0</DebitAmount>
										<Description>'+@CustomerNameArabic+' '+N'حساب المخزون'+'</Description>'+
										'<Narration>'+@CustomerName+'-Inventory asset account</Narration>
										<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@BranchCurrencyId)+'</CurrencyId>
										<CurrencyRate>1</CurrencyRate>
										<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@AcTotalAmount)+'</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
										</Row>';
									SET @ACRowNumber=@ACRowNumber+1;
								END

							END
							ELSE
							--------------------------Indirect Invoice-----------------------------------
							BEGIN
								INSERT INTO @TempACEntries 
								SELECT 
									ExpenseAccountId,MAX(InventoryAssetAccountId),
									SUM(TotalCostPrice) FROM @TempAc
								WHERE EntryName<>'Service' 
								AND IsFreeItem=CASE WHEN @IsDirectInvoice=0 THEN 0 ELSE IsFreeItem END
								GROUP BY ExpenseAccountId --,InventoryAssetAccountId

								SELECT @TotalInventoryAssetAmount=SUM(TotalCostPrice) FROM @TempACEntries
						

								SET @TotalInventoryAssetAmount=@TotalInventoryAssetAmount
						
								IF @TotalInventoryAssetAmount>0
								BEGIN

									SET @XMLAccounts=@XMLAccounts+'<Row>
										<AccountId>'+CONVERT(VARCHAR,@UnbilledSalesAccountId)+'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>'+CONVERT(VARCHAR,@TotalInventoryAssetAmount)+'</CreditAmount>
										<DebitAmount>0</DebitAmount>
										<Description>'+@CustomerNameArabic+	N'حساب المبيعات الغير مفوترة'+'</Description>
										<Narration>'+@CustomerName+'-Unbilled sales account</Narration>
										<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@BranchCurrencyId)+'</CurrencyId>
										<CurrencyRate>1</CurrencyRate>
										<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@AcTotalAmount)+'</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
										</Row>';
								END

								SELECT @ACRecordCount=COUNT(*) FROM @TempACEntries
								SET @ACRowNumber=1
								WHILE @ACRowNumber <=@ACRecordCount
								BEGIN
									SELECT @ACAccountId=ExpenseAccountId,--@InventoryAssetAccountId=InventoryAssetAccountId,
											@AcTotalAmount=TotalCostPrice 
									FROM @TempACEntries WHERE RowNumber=@AcRowNumber

									SET @XMLAccounts=@XMLAccounts+'<Row>
										<AccountId>'+CONVERT(VARCHAR,@ACAccountId)+	'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>0</CreditAmount>
										<DebitAmount>'+CONVERT(VARCHAR,@AcTotalAmount)+'</DebitAmount>
										<Description>'+@CustomerNameArabic+''+N' حساب المصروفات - فاتورة المبيعات'+'</Description>
										<Narration>'+@CustomerName+'-Expense account -sales invoice</Narration>
										<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@BranchCurrencyId)+'</CurrencyId>
										<CurrencyRate>1</CurrencyRate>
										<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@AcTotalAmount)+'</DebitAmountTransCurrency>
										</Row>';

									SET @ACRowNumber=@ACRowNumber+1;
								END
							END
					
							--- get account entries of details to a new temp table
							INSERT INTO @TempAccountEntries
							SELECT 
								AccountId,ISNULL(TotalAmount,0)-ISNULL(TaxAmount,0)+ISNULL(SpecialDiscountAmount,0),
								Narration,PaymentMethodId,
								BankAccountId,CardNo,ChequeNo,ChequeDate ,
								ISNULL(TaxAmount,0),
								CASE BankCurrencyId WHEN 0 THEN NULL ELSE BankCurrencyId END,
								ISNULL(BankCurrencyRate,0),
								ISNULL(TotalAmountInBankCurrency,0),
								ISNULL(TotalAmountInCustCurrency,0),
								ISNULL(SpecialDiscountAmount,0)
							FROM @TempDetails WHERE AccountId>0
					
							---get record count of account entries
							SELECT @RecordCountAccountEntry=COUNT(*) FROM @TempAccountEntries
							SET @RecordCountAccountEntry=ISNULL(@RecordCountAccountEntry,0);

							IF @RecordCountAccountEntry>0
							BEGIN
								SET @RowNumber=1;
								WHILE (@RowNumber<=@RecordCountAccountEntry)	
								BEGIN	
									SELECT @AccountString='<Row>
									<AccountId>'+CONVERT(VARCHAR,TAE.AccountId)+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>'+CASE WHEN TAE.Amount>=0 THEN CONVERT(VARCHAR,TAE.Amount) ELSE '0' END+'</CreditAmount>
									<DebitAmount>'+CASE WHEN TAE.Amount<0 THEN CONVERT(VARCHAR,ABS(TAE.Amount)) ELSE '0' END+'</DebitAmount>
									<Description>'+	CONVERT(VARCHAR,Accounts.DisplayAccountNameArabic)+ ' - ' +CONVERT(VARCHAR,@CustomerNameArabic) +'</Description>
									<Narration>'+CASE WHEN TAE.Narration='' THEN CONVERT(VARCHAR,Accounts.DisplayAccountName) +' - ' +CONVERT(VARCHAR,@CustomerName)
										ELSE CONVERT(VARCHAR,TAE.Narration) END	+'</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+ CONVERT(VARCHAR,TAE.TotalAmountInCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
									</Row>'  
									FROM [ERP.Finance].Accounts as Accounts INNER JOIN @TempAccountEntries as TAE
									ON Accounts.AccountId=TAE.AccountId WHERE TAE.RowNumber=@RowNumber;

									SET @XMLAccounts=@XMLAccounts+@AccountString;

									SET @RowNumber=@RowNumber+1;
								END
							END

							SELECT 
								@FreeItemTotalAmount= SUM(TotalCostPrice)
							FROM @TempAc WHERE IsFreeItem=1

							IF @FreeItemTotalAmount>0 AND @IsDirectInvoice=1
							BEGIN
								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@FreeItemAccountID)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>0</CreditAmount>
									<DebitAmount>'+CONVERT(VARCHAR,@FreeItemTotalAmount)+'</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N''+'</Description>' +
									'<Narration>'+@CustomerName+'-FreeItem</Narration><CustomerId>0</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@BranchCurrencyId)+'</CurrencyId>
									<CurrencyRate>1</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@FreeItemTotalAmount)+'</DebitAmountTransCurrency>
									</Row>';
							END
					 
						END
						IF @TotalDiscount>0
						BEGIN
							SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@SalesDiscountAccountId)+
								'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
								'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,@TotalDiscount)+
								'</DebitAmount><Description>'+@CustomerNameArabic+''+N'الخصم'+'</Description>' +
								'<Narration>'+@CustomerName+'-Discount</Narration><CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
								<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
								<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
								<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
								<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@TotalDiscountInCustCurrency)+'</DebitAmountTransCurrency>
								</Row>';
						END
						IF (SELECT SUM(ISNULL(SpecialDiscountAmount,0)) FROM @TempDetails)>0
						BEGIN
							SELECT  @SpecialDiscount=SUM(ISNULL(SpecialDiscountAmount,0)),
									@SpecialDiscountCustCurrency=SUM(ISNULL(SpeciaDiscountAmountInCustCurrency,0)) 
							FROM @TempDetails
							
							IF @SpecialDiscountAccountId>0
							BEGIN
								SET @XMLAccounts=@XMLAccounts+'<Row>
									<AccountId>'+CONVERT(VARCHAR,@SpecialDiscountAccountId)+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>0</CreditAmount>
									<DebitAmount>'+CONVERT(VARCHAR,@SpecialDiscount)+'</DebitAmount>
									<Description>'+@CustomerNameArabic+''+N'الخصم'+'</Description>' +
									'<Narration>'+@CustomerName+'-Discount</Narration>
									<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@SpecialDiscountCustCurrency)+'</DebitAmountTransCurrency>
									</Row>';
							END
						END
						IF @RoundOff<>0
						BEGIN
							IF @RoundOff>0
							BEGIN
								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@RoundOffAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>'+CONVERT(VARCHAR,@RoundOff)+
									'</CreditAmount><DebitAmount>0</DebitAmount><Description>'+@CustomerNameArabic+''+N' تقريب المبلغ'+'</Description>' +
									'<Narration>'+@CustomerName+'-Round Off</Narration><CustomerId>'+
									CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@RoundOffInCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
									</Row>';
							END
							ELSE
							BEGIN
							SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@RoundOffAccountId)+
								'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
								'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+
								CONVERT(VARCHAR,(@RoundOff*-1))+'</DebitAmount><Description>'+@CustomerNameArabic+''+N' تقريب المبلغ'+'</Description>' +
								'<Narration>'+@CustomerName+'-Round Off</Narration><CustomerId>'+
								CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
								<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
								<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
								<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
								<DebitAmountTransCurrency>'+CONVERT(VARCHAR,(@RoundOffInCustCurrency*-1))+'</DebitAmountTransCurrency>
								</Row>';
						END
					END
					IF @CRecordCount>0
					BEGIN
						DECLARE @ChargeString varchar(MAX)
						SET @RowNumber=1;
						WHILE (@RowNumber<=@CRecordCount)	
						BEGIN	
							SELECT @ChargeString='<Row><AccountId>'+CONVERT(VARCHAR, [ERP.Config].Charge.AccountId )+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>'
									+CONVERT(VARCHAR,TCD.Amount)+'</CreditAmount><DebitAmount>0</DebitAmount><Description>'+
									CONVERT(NVARCHAR(MAX),[ERP.Config].Charge.ChargeNameArabic)+'</Description><Narration>'+
									CONVERT(VARCHAR,[ERP.Config].Charge.ChargeName)+
									'</Narration><CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>'+CONVERT(VARCHAR,TCD.AmountInCustCurrency)+'</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
									</Row>'  
							FROM [ERP.Config].Charge INNER JOIN @TempChargeDetails as TCD
							ON [ERP.Config].Charge.ChargeId=TCD.ChargeId WHERE TCD.RowNumber=@RowNumber;

							SET @XMLAccounts=@XMLAccounts+@ChargeString;

							SET @RowNumber=@RowNumber+1;
						END
					END
				
				
					DELETE FROM [ERP.Inventory].TaxTransactions WHERE TransactionType='S' AND ReferenceNo=@SalesInvoiceId;
					
					INSERT INTO @TempTaxes 
					SELECT TaxId,SUM(TaxAmount),SUM(TotalAmount),SUM(TaxAmountInCustCurrency),SUM(TotalAmountInCustCurrency)  FROM @TempDetails GROUP BY TaxId
					UNION ALL
					SELECT TaxId,SUM(TaxAmount),SUM(TotalAmount),SUM(TaxAmount/@CurrencyRate),SUM(TotalAmount/@CurrencyRate)  FROM @TempServiceDetails GROUP BY TaxId
					UNION ALL
					SELECT TaxId,SUM(TaxAmount),SUM(TotalAmount),SUM(TaxAmountInCustCurrency),SUM(TotalAmountInCustCurrency)  FROM @TempProjectDetails GROUP BY TaxId
					UNION ALL
					SELECT TaxId,SUM(TaxAmount),SUM(TotalAmount),SUM(TaxAmountInCustCurrency),SUM(TotalAmountInCustCurrency)  FROM @TempProjectBillDetails GROUP BY TaxId

					IF @TaxId>0 AND @Type<>'AI'
					BEGIN
						INSERT INTO @TempTaxes VALUES (@TaxId,@TotalTaxAmount,@TotalAmount,@TotalTaxAmountInCustCurrency,@TotalAmountInCustCurrency )
					END
					SELECT @TaxRecordCount=COUNT(*) FROM @TempTaxes;
					SET @TaxRecordCount=ISNULL(@TaxRecordCount,0);
					
					IF @TotalTaxAmount<>0
					BEGIN
						IF @CustomerId>0
							SELECT @LocationType=CustomerLocationType FROM [ERP.Inventory].Customer	WHERE (CustomerId = @CustomerId);
						ELSE SET @LocationType=NULL

						SET @RowNumber=1;
						WHILE @RowNumber<=@TaxRecordCount
						BEGIN
							SELECT @TranTaxId=TaxId,@TotalTaxableAmount=TotalAmount,@TaxAmount=TaxAmount,@TaxAmountCustCurrency=TaxAmountCustCurrency 
							FROM @TempTaxes WHERE RowNumber=@RowNumber;
							IF @TranTaxId>0 
							BEGIN
								SELECT @OutputTaxAccountId=OutputTaxAccountId FROM [ERP.Config].Tax WHERE (TaxId = @TranTaxId);
								IF @OutputTaxAccountId>0
								BEGIN
								IF ISNULL(@TaxAmount,0) <> 0
									BEGIN
									SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@OutputTaxAccountId)+'</AccountId>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmount>'+CASE WHEN @TaxAmount>=0 THEN CONVERT(VARCHAR,@TaxAmount) ELSE '0' END+'</CreditAmount>
										<DebitAmount>'+CASE WHEN @TaxAmount<0 THEN CONVERT(VARCHAR,ABS(@TaxAmount)) ELSE '0' END+'</DebitAmount>
										<Description>'+@CustomerNameArabic+''+N' مبلغ الضريبة'+'</Description>
										<Narration>'+@CustomerName+'- Tax Amount </Narration>
										<CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
										<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
										<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
										<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
										<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@TaxAmountCustCurrency)+'</CreditAmountTransCurrency>
										<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
									</Row>'
									END	
									--- insert into tax transaction
									INSERT INTO [ERP.Inventory].TaxTransactions
										(BranchId, TransactionDate, TaxId, LocationType, TransactionType, ReferenceNo, 
										InputTaxAmount, OutputTaxAmount, TotalTaxableAmount)
									VALUES (@BranchId,@SalesInvoiceDate,@TranTaxId,@LocationType, 'S',@SalesInvoiceId, 0,
										@TotalTaxAmount,@TotalTaxableAmount)
								END
							END
							SET @RowNumber=@RowNumber+1;
						END
					END	
				
					IF @Type='C'  
					BEGIN
						IF @PaymentMethodId=5				-------Mixed mode
						BEGIN
							SELECT @MixedModeRecordCount=COUNT(*) FROM  @TempCustomerMixedReceiptDetails
							SET @MixRowNumber=1;
							WHILE @MixRowNumber<=@MixedModeRecordCount
							BEGIN
								SELECT @MixAccountId=CASE WHEN @SeparateAccountForPDC=1 AND PaymentMethodId>1 THEN 
									CONVERT(INT,ISNULL([ERP.Finance].Fun_GetFinancialSettingsValue(@BranchId,'PDC Receivable'),0))
									ELSE AccountId END,@MixedAmount=Amount,@MixedAmountInCustCurrency=AmountInCustCurrency
								FROM @TempCustomerMixedReceiptDetails WHERE RowNumber=@MixRowNumber

								SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@MixAccountId)+'</AccountId>
									<CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,@MixedAmount)+'</DebitAmount>
									<Description>'+N' سند استلام العميل عن طريق البنك أو النقد'+ISNULL(@CashCustomerName,'') +
									'</Description><Narration>-Cash Sales - Cash Entry'+ISNULL(@CashCustomerName,'') +
									'</Narration><CustomerId></CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@MixedAmountInCustCurrency)+'</DebitAmountTransCurrency>
									</Row>'
				
								SET @MixRowNumber=@MixRowNumber+1;
							END
						END
						ELSE
						BEGIN
							IF @ReceiptAccountId>0
							BEGIN
								IF @SeparateAccountForPDC=1 AND @PaymentMethodId>1 
									SET @ReceiptAccountId=CONVERT(INT,ISNULL([ERP.Finance].Fun_GetFinancialSettingsValue(@BranchId,'PDC Receivable'),0));
								SET @XMLAccounts=@XMLAccounts+'<Row>
									<AccountId>'+CONVERT(VARCHAR,ISNULL(@ReceiptAccountId,0))+'</AccountId>
									<CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+'</CostCenterId>
									<CreditAmount>0</CreditAmount>
									<DebitAmount>'+CONVERT(VARCHAR,@NetAmount)+'</DebitAmount>
									<Description>'+N' سند استلام العميل عن طريق البنك أو النقد'+''	+ISNULL(@CustomerNameArabic,'') +'</Description>
									<Narration>-Cash Sales - Cash Entry'+ISNULL(@CashCustomerName,'') +'</Narration>
									<CustomerId></CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@NetAmountInCustCurrency)+'</DebitAmountTransCurrency>
									</Row>'
							END
						END
					END
					ELSE IF @Type='AI' AND @IsCredit=0
					BEGIN					
						SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,ISNULL(@ReceiptAccountId,0))
						+'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))
						+'</CostCenterId><CreditAmount>0</CreditAmount>
						<DebitAmount>'+CONVERT(VARCHAR,@NetAmount)+'</DebitAmount><Description>'+N' سند استلام العميل عن طريق البنك أو النقد'+''
						+ISNULL(@CustomerNameArabic,'') +'</Description><Narration>-Advance Invoice - Cash Entry'+ISNULL(@CashCustomerName,'') 
						+'</Narration><CustomerId></CustomerId>
						<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
						<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
						<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
						<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@NetAmountInCustCurrency)+'</DebitAmountTransCurrency>
						</Row>'

						SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@CustomerAccountId)+
						'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
						'</CostCenterId><CreditAmount>'+CONVERT(VARCHAR,@TotalAdvanceAmount)+
						'</CreditAmount><DebitAmount>0</DebitAmount><Description>' +@InvoiceNo +'-'+ @CustomerNameArabic +'</Description>' +
						'<Narration>' +@InvoiceNo +'-'+ @CustomerName +
						'</Narration><CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
						<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
						<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
						<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@TotalAdvanceAmountInCustCurrency)+'</CreditAmountTransCurrency>
						<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
						</Row>'

						SELECT 
							@TranTaxId=TaxId,@TotalTaxableAmount=AdvanceAmount,@TaxAmount=TaxAmount,@TaxAmountCustCurrency=TaxAmountCustCurrency
						FROM @TempAdvanceInvoice 

						IF @TranTaxId>0 AND @VatAdvanceAccountId>0
						BEGIN
							IF ISNULL(@TaxAmount,0) <> 0
							BEGIN
							SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@VatAdvanceAccountId)+
								'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
								'</CostCenterId><CreditAmount>'+CONVERT(VARCHAR,@TaxAmount)+'</CreditAmount>
								<DebitAmount>0</DebitAmount><Description>'+@CustomerNameArabic+''+N' مبلغ الضريبة'+'</Description>' +
								'<Narration>'+@CustomerName+'- Tax Amount </Narration><CustomerId>'+
								CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
								<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
								<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
								<CreditAmountTransCurrency>'+CONVERT(VARCHAR,@TaxAmountCustCurrency)+'</CreditAmountTransCurrency>
								<DebitAmountTransCurrency>0</DebitAmountTransCurrency>
								</Row>'
							END	
							--- insert into tax transaction
							INSERT INTO [ERP.Inventory].TaxTransactions
							(
								BranchId,TransactionDate,TaxId,LocationType,TransactionType,ReferenceNo, 
								InputTaxAmount,OutputTaxAmount,TotalTaxableAmount
							)
							VALUES 
							(
								@BranchId,@SalesInvoiceDate,@TranTaxId,@LocationType, 'S',@SalesInvoiceId, 
								0,@TotalTaxAmount,@TotalTaxableAmount
							)
						END
					END
					ELSE
					BEGIN
						IF @AdvanceCount>0
						BEGIN
							SELECT 
								@TakenTaxAmount=SUM(TakenTaxAmount),@TakenTaxAmountCustCurrency=SUM(TakenTaxAmountCustCurrency) 
							FROM @TempAdvance

							IF @TakenTaxAmount>0 AND @VatAdvanceAccountId>0
							BEGIN
								IF ISNULL(@TaxAmount,0) <> 0
								BEGIN
									SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@VatAdvanceAccountId)+
									'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
									'</CostCenterId><CreditAmount>0</CreditAmount>
									<DebitAmount>'+CONVERT(VARCHAR,@TakenTaxAmount)+'</DebitAmount><Description>'+@CustomerNameArabic+''+N' مبلغ الضريبة'+'</Description>' +
									'<Narration>'+@CustomerName+'- Tax Amount </Narration><CustomerId>'+
									CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
									<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
									<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
									<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
									<DebitAmountTransCurrency>'+CONVERT(VARCHAR,@TakenTaxAmountCustCurrency)+'</DebitAmountTransCurrency>
									</Row>'
								END	
								--- insert into tax transaction
								INSERT INTO [ERP.Inventory].TaxTransactions
								(
									BranchId,TransactionDate,TaxId,LocationType,TransactionType,ReferenceNo, 
									InputTaxAmount,OutputTaxAmount,TotalTaxableAmount
								)
								VALUES 
								(
									@BranchId,@SalesInvoiceDate,@TranTaxId,@LocationType, 'S',@SalesInvoiceId, 
									@TotalTaxAmount,0,@TotalTaxableAmount
								)
							END
						END

						IF @XMLAccounts IS NULL SET @XMLAccounts = '<RowSet>'
						SET @XMLAccounts=@XMLAccounts+'<Row><AccountId>'+CONVERT(VARCHAR,@CustomerAccountId)+
						'</AccountId><CostCenterId>'+CONVERT(VARCHAR,ISNULL(@CostCenterId,0))+
						'</CostCenterId><CreditAmount>0</CreditAmount><DebitAmount>'+CONVERT(VARCHAR,(@NetAmount-ISNULL(@TakenTaxAmount,0)))+
						'</DebitAmount><Description>' +@InvoiceNo +'-'+ @CustomerNameArabic +'</Description>' +
						'<Narration>' +@InvoiceNo +'-'+ @CustomerName +
						'</Narration><CustomerId>'+CONVERT(VARCHAR,ISNULL(@CustomerId,'0'))+'</CustomerId>
						<CurrencyId>'+ CONVERT(VARCHAR,@CurrencyId)+'</CurrencyId>
						<CurrencyRate>'+ CONVERT(VARCHAR,@CurrencyRate)+'</CurrencyRate>
						<CreditAmountTransCurrency>0</CreditAmountTransCurrency>
						<DebitAmountTransCurrency>'+CONVERT(VARCHAR,(@NetAmountInCustCurrency-ISNULL(@TakenTaxAmountCustCurrency,0)))+'</DebitAmountTransCurrency>
						</Row>';

					END		
					SET @XMLAccounts=@XMLAccounts+'</RowSet>';
					SET @XMLAccounts=REPLACE(@XMLAccounts,'&','&amp;')
					
					--insert into ErrorChecking values ('SI',1,@XMLAccounts);

					IF (SELECT COUNT(*) FROM @TempDetails WHERE PaymentMethodId<>1 AND AccountId>0)>0 
					BEGIN
						SET @TransStatus='R'
							
					END
					ELSE IF @PaymentMethodId=1
						SET @TransStatus='A'
					ELSE 
						SET @TransStatus='R'

					IF @Type='AI' AND @IsCredit=0
					BEGIN
						----- call account trans procedure
						EXEC [ERP.Finance].[SaveAccountTrans] @SpStatus1 output,@AccountTransId	output,@BranchId,@VoucherNo output,
						    @SalesInvoiceDate,@TransactionTypeId,@SalesInvoiceId,@InvoiceNo,@Notes,@Remarks1,@TransStatus,@CreatedBy,
							@XMLAccounts,0,@ReferenceNo 

					END
					ELSE IF  @Type<>'AI'
					BEGIN	
						----- call account trans procedure
						EXEC [ERP.Finance].[SaveAccountTrans] @SpStatus1 output,@AccountTransId	output,@BranchId,@VoucherNo output,
						    @SalesInvoiceDate,@TransactionTypeId,@SalesInvoiceId,@InvoiceNo,@Notes,@Remarks1,@TransStatus,@CreatedBy,
							@XMLAccounts,0,@ReferenceNo
							
					END

					IF @Type='AI' AND @IsCredit=1
					BEGIN
						SET @SpStatus1=1
					END
					
					IF @Type IN ('C','AI') and @PaymentMethodId <> 1 AND @PaymentMethodId <> 5
					BEGIN 
						IF @Type='AI' 
						BEGIN
							SET @CashCustomerName=@CustomerName
							SET @PayAmount=@NetAmount
						END
						ELSE
						BEGIN
							SET @PayAmount=@PaidAmount
						END

						IF @Type='AI' AND @IsCredit=0
						BEGIN
							EXEC [ERP.Inventory].[SaveChequeTransaction] @SPStatus1 output, @ChequeTransId,@AccountTransId,@SalesInvoiceDate,@BranchId,@BankAccountId,
								 @ChequeNo,@ChequeDate,@PayAmount,@InvoiceNo,'Cash Receipt-Direct','R',NULL ,@CashCustomerName,'P',@CreatedBy,@PaymentMethodId,
								 'R',0,@CustomerId,@CashCustomerName,@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,@ReferenceNo,@TransactionTypeId,
								 @SalesInvoiceId 
						END
						ELSE IF  @Type<>'AI'
						BEGIN	
							EXEC [ERP.Inventory].[SaveChequeTransaction] @SPStatus1 output, @ChequeTransId,@AccountTransId,@SalesInvoiceDate,@BranchId,@BankAccountId,
								 @ChequeNo,@ChequeDate,@PayAmount,@InvoiceNo,'Cash Receipt-Direct','R',NULL ,@CashCustomerName,'P',@CreatedBy,@PaymentMethodId,
								 'R',0,@CustomerId,@CashCustomerName,@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,@ReferenceNo,@TransactionTypeId,
								 @SalesInvoiceId 
								
						END

					END
					

					--- cash customer mixed mode
					ELSE IF @Type = 'C' AND @PaymentMethodId =5 AND @SPStatus1=1	
					BEGIN
						SET @RowNumber=1
						WHILE @RowNumber<=@MixedModeRecordCount
						BEGIN
						SELECT 
							@MixBankAccountId=BankAccountId,@MixedAmount=Amount,@ChequeDate=ChequeDate,
							@ChequeNo=ChequeNo,@MixPaymentMethodId=PaymentMethodId,
							@BankCurrencyId=BankCurrencyId,
							@BankCurrencyRate=BankCurrencyRate,
							@TotalAmountInBankCurrency=AmountInBankCurrency
						FROM @TempCustomerMixedReceiptDetails WHERE RowNumber=@RowNumber

						IF @MixBankAccountId>0 AND @MixPaymentMethodId>1
						BEGIN
							SET @ChequeTransId=0
				
							EXEC [ERP.Inventory].[SaveChequeTransaction] @SPStatus1 output, @ChequeTransId,@AccountTransId,@SalesInvoiceDate,@BranchId,@MixBankAccountId,
							@ChequeNo,@ChequeDate,@MixedAmount, @InvoiceNo,'Cash Receipt-Direct','R',NULL,@CashCustomerName,'P',@CreatedBy,@MixPaymentMethodId,
							'R',0, 0, @CashCustomerName,@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,@ReferenceNo,@TransactionTypeId,@SalesInvoiceId

						
						END
						SET @RowNumber=@RowNumber+1;
						END
					END

				
					------------------------------For Account Entries in details table------------------------------------
					IF @SPStatus1>0 AND @RecordCountAccountEntry>0 
					BEGIN
						SET @RowNumber=1
						WHILE @RowNumber<=@RecordCountAccountEntry
						BEGIN
						SELECT 
							@AccountBankAccountId=BankAccountId,@ChequeAmount=ISNULL(Amount,0)+ISNULL(TaxAmount,0),@ChequeNarration=Narration,@AccountChequeDate=ChequeDate,
							@AccountChequeNo=ChequeNo,@AccountPaymentMethodId=PaymentMethodId,
							@BankCurrencyId=BankCurrencyId,@BankCurrencyRate=BankCurrencyRate,
							@TotalAmountInBankCurrency=TotalAmountInBankCurrency
						FROM @TempAccountEntries WHERE RowNumber=@RowNumber

					
						IF @AccountBankAccountId>0 AND @AccountPaymentMethodId>1
						BEGIN
							SET @AccountChequeStatus='I'
							SET @ChequeTransId=0
							EXEC [ERP.Inventory].[SaveChequeTransaction] @SPStatus1 output, @ChequeTransId,@AccountTransId,@SalesInvoiceDate,@BranchId	,@AccountBankAccountId,
							@AccountChequeNo,@AccountChequeDate,@ChequeAmount,@InvoiceNo,@ChequeNarration,@AccountChequeStatus,NULL,@ReferenceNo,'P',@CreatedBy,
							@AccountPaymentMethodId,'P',0,@CustomerId,'Adjutment Invoice',@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,@ReferenceNo,@TransactionTypeId,@SalesInvoiceId
						END
						SET @RowNumber=@RowNumber+1;
						END
					END
					
					-------------------------------------------------------------------------------------------

					IF @SPStatus1=1 SET @SPStatus=1;									    -- Success
					ELSE SET @SPStatus=(@SPStatus1+100)*-1;									-- Account trans save error
				END
				
				---------------------------------------------------------------------------------------------------------------
				-- Update GDN status as Invoiced					
				--UPDATE [ERP.Inventory].GoodsDeliveryNote SET SalesStatusId ='I' WHERE GDNId IN (SELECT GDNId FROM @TempGDNs)
				------------------------------GDN status-----------------------------
				IF  @IsDirectInvoice=0 --AND @InvoiceFromSalesOrder=0
				BEGIN
				
					TRUNCATE TABLE #TempGDNStatusRollBack
					INSERT INTO #TempGDNStatusRollBack(GDNId) SELECT DISTINCT GDNId FROM @TempGDNs
					UPDATE #TempGDNStatusRollBack SET SalesOrderId=ISNULL((SELECT SalesOrderId FROM [ERP.Inventory].GoodsDeliveryNote WHERE (GDNId = #TempGDNStatusRollBack.GDNId)),0)
					UPDATE #TempGDNStatusRollBack SET DeliveredQTy=ISNULL((SELECT TotalQuantity FROM [ERP.Inventory].GoodsDeliveryNote WHERE (GDNId = #TempGDNStatusRollBack.GDNId)),0)
					UPDATE #TempGDNStatusRollBack SET InvoicedQTy=ISNULL((SELECT SUM([ERP.Inventory].SalesInvoiceDetails.Quantity)
						FROM [ERP.Inventory].SalesInvoiceDetails INNER JOIN [ERP.Inventory].SalesInvoice 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesInvoiceId = [ERP.Inventory].SalesInvoice.SalesInvoiceId
						WHERE ([ERP.Inventory].SalesInvoiceDetails.GDNId = #TempGDNStatusRollBack.GDNId) 
						AND ([ERP.Inventory].SalesInvoice.EntryStatus <> 'D') 
						AND ([ERP.Inventory].SalesInvoice.SalesStatusId <> 'CN')),0)

					UPDATE #TempGDNStatusRollBack SET GDNStatus=CASE  
					WHEN InvoicedQTy>0 AND InvoicedQTy< DeliveredQty  THEN 'PI' 
					WHEN InvoicedQTy>=DeliveredQty THEN 'I'  
					ELSE 'D'  END

					UPDATE [ERP.Inventory].GoodsDeliveryNote SET SalesStatusId=Temp.GDNStatus 
						FROM #TempGDNStatusRollBack as Temp INNER JOIN [ERP.Inventory].GoodsDeliveryNote
						ON Temp.GDNId=[ERP.Inventory].GoodsDeliveryNote.GDNId

					UPDATE #TempGDNStatusRollBack SET OrderedQty=CASE WHEN SalesOrderId=0 THEN 0 
						ELSE ISNULL((SELECT SUM(Quantity) FROM [ERP.Inventory].SalesOrderDetails WHERE (SalesOrderId = #TempGDNStatusRollBack.SalesOrderId)),0) END
					UPDATE #TempGDNStatusRollBack SET OrderedInvoicedQTy=ISNULL((SELECT SUM([ERP.Inventory].SalesInvoiceDetails.Quantity)
						FROM [ERP.Inventory].SalesInvoiceDetails INNER JOIN [ERP.Inventory].SalesInvoice 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesInvoiceId = [ERP.Inventory].SalesInvoice.SalesInvoiceId
						INNER JOIN [ERP.Inventory].SalesOrderDetails 
						ON [ERP.Inventory].SalesInvoiceDetails.SalesOrderdetailsId=[ERP.Inventory].SalesOrderDetails.SalesOrderDetailsId
						WHERE ([ERP.Inventory].SalesOrderDetails.SalesOrderId = #TempGDNStatusRollBack.SalesOrderId) 
						AND ([ERP.Inventory].SalesInvoice.EntryStatus <> 'D') 
						AND ([ERP.Inventory].SalesInvoice.SalesStatusId <> 'CN')),0)
					UPDATE #TempGDNStatusRollBack SET OrderStatus=CASE WHEN OrderedInvoicedQTy=0 THEN 'NI' 
											WHEN OrderedQty>OrderedInvoicedQTy AND OrderedInvoicedQTy>0 THEN 'PI' ELSE 'I' END 
					WHERE OrderedQty>0

					UPDATE [ERP.Inventory].SalesOrder SET InvoiceStatusId=Temp.OrderStatus 
					FROM #TempGDNStatusRollBack as Temp INNER JOIN [ERP.Inventory].SalesOrder
					ON Temp.SalesOrderId=[ERP.Inventory].SalesOrder.SalesOrderId
					WHERE Temp.OrderedQty>0
				END
	

				---- call direct receipt
				IF @IsCredit=0 ANd (@PaidAmount>0 OR @PaidFromAdvance>0 ) AND @IsAdjustment<>1 AND @CustomerId>0
				BEGIN
					IF @IsMobileAppEntry=1
					BEGIN
						UPDATE [ERP.Config].[AppUserNumberGenerationSettings]  SET LastIndex=@LastIndex
						WHERE AppUserId=@CreatedBy AND SettingsId=@IndexSettingsId and BranchId=@BranchId
		            END

					SET @IsReceiptFromInvoice=1		

					EXEC [ERP.Finance].[SaveDirectSalesReceipt]	@SPStatus2 output,@CustomerId,@SalesInvoiceId,@SalesInvoiceDate,
						 @NetAmount,@PaidAmount,@InvoiceNo,@PaymentMethodId,@ChequeNo,@ChequeDate,@ChequeDetails	,
						 @CardNo,@ReceiptAccountId,@BankAccountId,@ReceiptNotes,@AccountTransStatus,@CreatedBy,
						 @CostCenterId,@XMLAdvance,@CurrencyId,@CurrencyRate, @PaidAmountInCustCurrency, @NetAmountInCustCurrency,
						 @XMLMixedReceiptDetails,@IsReceiptFromInvoice,@BankCurrencyId,@BankCurrencyRate,@TotalAmountInBankCurrency,
						 @SalesStatusId,@ReceiptNo,@ReceiptLastIndex,@ReceiptIndexSettingsId,@IsMobileAppEntry,@ProjectId,@SalesManUserId			
		 
				END 
				ELSE IF @IsCredit=1
				BEGIN
					SET @SPStatus2=1;
					SELECT @PreviousCustomerReceiptId=CustomerReceiptId FROM [ERP.Inventory].SalesInvoice WHERE (SalesInvoiceId = @SalesInvoiceId)
					----------------------- Rollback if any previous entry exist--------------------------------------
					---Get previous advance
					INSERT INTO @TempPreviousAdvance
					SELECT 
						CustAdvanceTransId,CreditedAmount, CreditedAmountCustCurrency,
						CreditedTaxAmount,CreditedTaxAmountCustCurrency,ProjectId
					FROM [ERP.Inventory].CustomerTransaction
					WHERE (TransactionType <> 'CN') AND (SalesInvoiceId = @SalesInvoiceId)
					AND (CustAdvanceTransId IS NOT NULL OR CustAdvanceTransId=0)

					SELECT @PreviousAdvanceCount=COUNT(*) FROM  @TempPreviousAdvance
					IF @PreviousAdvanceCount>0
					BEGIN
						--- rollback Customer advance
						UPDATE [ERP.Finance].CustomerAdvance 
						SET AllottedAmount = CustomerAdvance.AllottedAmount-TempAdvance.AdvanceAmount,
							AdvanceStatus=CASE WHEN CustomerAdvance.AllottedAmount-TempAdvance.AdvanceAmount= 0 THEN 'A' ELSE 'P' END,
							--AllottedAmountCustCurrency = CustomerAdvance.AllottedAmountCustCurrency-(TempAdvance.AdvanceAmount/@CurrencyRate),
							AllottedAmountCustCurrency = CustomerAdvance.AllottedAmountCustCurrency-(TempAdvance.AdvanceAmountCusCurrency),
							AllottedTaxAmount = CustomerAdvance.AllottedTaxAmount-TempAdvance.AdvanceTaxAmount,
							AllottedTaxAmountCustCurrency = CustomerAdvance.AllottedTaxAmountCustCurrency-TempAdvance.AdvanceTaxAmountCusCurrency,
							ProjectId=TempAdvance.ProjectId
						FROM [ERP.Finance].CustomerAdvance as CustomerAdvance 
							INNER JOIN @TempPreviousAdvance as TempAdvance 
						ON  CustomerAdvance.CustAdvanceTransId = TempAdvance.CustAdvanceTransId;

						--- remove customer transaction entry
						DELETE FROM [ERP.Inventory].CustomerTransaction
						WHERE (SalesInvoiceId = @SalesInvoiceId) AND (CustAdvanceTransId IN 
						(SELECT CustAdvanceTransId FROM @TempPreviousAdvance))

						---- remove customer receipt details
						DELETE FROM [ERP.Inventory].CustomerReceiptDetails
						WHERE (SalesInvoiceId=@SalesInvoiceId) AND  (CustomerReceiptId IN 
						(SELECT CustomerReceiptId FROM [ERP.Finance].CustomerAdvance WHERE CustAdvanceTransId IN
							(SELECT CustAdvanceTransId FROM @TempPreviousAdvance)))

						-- Update Advance Value of sales invoice
						UPDATE  [ERP.Inventory].SalesInvoice SET  PaidFromAdvance = 0 WHERE (SalesInvoiceId = @SalesInvoiceId)
				END

				IF @PreviousCustomerReceiptId IS NOT NULL AND @PreviousCustomerReceiptId>0
				BEGIN
					---- delete customer receipt details 
					DELETE FROM [ERP.Inventory].CustomerReceiptDetails 
					WHERE (CustomerReceiptId=@PreviousCustomerReceiptId) AND (SalesInvoiceId=@SalesInvoiceId);

					-- rollback sales invoice
					UPDATE  [ERP.Inventory].SalesInvoice SET  CustomerReceiptId = NULL WHERE (SalesInvoiceId = @SalesInvoiceId)

					-- rollback account transaction
					DELETE FROM [ERP.Inventory].CustomerTransaction 
					WHERE (CustomerReceiptId=@PreviousCustomerReceiptId) AND (SalesInvoiceId = @SalesInvoiceId)

					-- delete CustomerReceipt
					UPDATE [ERP.Inventory].CustomerReceipts SET ReceiptStatus = 'C', EntryStatus = 'D' 
					WHERE (CustomerReceiptId = @PreviousCustomerReceiptId)

					-- fetch customer transaction id
					SELECT TOP (1) @PreviousAccountTransId=AccountTransId FROM [ERP.Finance].AccountTrans
					WHERE (TransactionTypeId = @CRTransactionTypeId) AND (TransactionId = @PreviousCustomerReceiptId) AND (EntryStatus <> 'D')

					IF @PreviousAccountTransId>0
					BEGIN
						-- remove cheque transaction
						DELETE FROM [ERP.Finance].ChequeTransactions WHERE (AccountTransId = @PreviousAccountTransId)
				
						--removed account trans details
						DELETE FROM [ERP.Finance].AccountTransDetails WHERE (AccountTransId = @PreviousAccountTransId)

						-- remove accountTrans
						UPDATE [ERP.Finance].AccountTrans SET EntryStatus='D' WHERE (AccountTransId = @PreviousAccountTransId)

					END
				END
		--------------------------------------------------------------------------------------------------------------

				END
				ELSE SET @SPStatus2=1
				
			END
			ELSE
			BEGIN
				SET @SPStatus=0;									-- XML error
			END
	--   END
	--ELSE
	--BEGIN
	--SET @SPStatus=0;									-- XML error
	--END 
	 
	 /*=========================Bulk import from Import sales Order==================*/
		IF @ImpSalesInvoiceId>0
		BEGIN
			UPDATE [ERP.Inventory].ImportSalesInvoice SET ImportStatus='I' WHERE ImpSalesInvoiceId=@ImpSalesInvoiceId
		END
	  /*=============================================================================*/

		  ------------------------------------
		-- for Saving Sales Invoice Log 
		IF @SPStatus=1
		BEGIN 
			SET @ReferenceId		=@SalesInvoiceId				 
			SET @ReferenceNum=@InvoiceNo;

			IF @Action='E'
			BEGIN
				SET @CreatedBy=NULL
			END
			ELSE IF @Action='M'
			BEGIN
				SET @Action='M'
			END
			ELSE IF @IsDraft=1
			BEGIN
				SET @Action='D'
				SET @ReferenceNum=@DraftSalesInvoiceNo;
			END
			ELSE
			BEGIN
				SET @Action='S'
			END

			SET @PageName='SalesInvoice'
			EXEC [ERP.Admin].[SaveLog] @Spstatus output,@LogId output,@BranchId,@LogDate,@PageName,@UserId,@Action,@ReferenceId,@ReferenceNum,@CreatedBy,@EditedBy, @EntryStatus
		END

	IF @SPStatus2=1 AND @SPStatus=1 COMMIT ELSE ROLLBACK

	END TRY
	BEGIN CATCH
		ROLLBACK
		SET @SPStatus=-1;									-- Error
		PRINT ERROR_MESSAGE();
		EXEC LogError;
	END CATCH
	IF OBJECT_ID(N'tempdb..#TempSDetails') IS NOT NULL  DROP TABLE #TempSDetails;
	IF OBJECT_ID(N'tempdb..#TempBOMStockDetails') IS NOT NULL DROP TABLE  #TempBOMStockDetails; 
	IF OBJECT_ID(N'tempdb..#TempGDNStatusRollBack') IS NOT NULL DROP TABLE  #TempGDNStatusRollBack; 
END


GO


