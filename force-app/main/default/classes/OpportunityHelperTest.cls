@isTest
private class OpportunityHelperTest {

    @TestSetup
    static void setup(){
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'Contact' AND Name = 'Corretor'
        ];
        
        Account acc = TestDataFactory.gerarConta();
        insert acc;

        Contact ctt = TestDataFactory.gerarContato(acc, rt.Id);
        insert ctt;

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento(acc);
        insert empreendimento;
        
        Bloco__c bloco = TestDataFactory.gerarBloco(empreendimento);
        insert bloco;

        Product2 product = TestDataFactory.gerarProduto(empreendimento, bloco);
        insert product;
        Pricebook2 pricebook = TestDataFactory.gerarPricebook();
        insert pricebook;

        
        Opportunity opp1 = TestDataFactory.gerarOportunidade();
        opp1.AccountId = acc.Id;
        opp1.Pricebook2Id = pricebook.Id;
        Opportunity opp2 = TestDataFactory.gerarOportunidade();
        opp2.AccountId = acc.Id;
        opp2.Pricebook2Id = pricebook.Id;
        opp2.StageName = 'Ficha Cadastral';
        Opportunity opp3 = TestDataFactory.gerarOportunidade();
        opp3.AccountId = acc.Id;
        opp3.StageName = 'Pré-análise';
        insert new List<Opportunity> { opp1, opp2, opp3 };

        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opp3);
        insert analise;

        Documentacao__c doc = TestDataFactory.gerarDocumentacao();
        insert doc;

        Checklist_de_Documentos__c cklist = TestDataFactory.gerarChecklistDocumentos(opp1, doc);
        insert cklist;

        Quote cotacao = TestDataFactory.gerarCotacao(opp1);
        insert cotacao;
        
        PricebookEntry pricebookEntry = TestDataFactory.gerarPricebookEntry(product);
        pricebookEntry.Pricebook2Id = cotacao.Pricebook2Id;
        insert pricebookEntry;
        
        QuoteLineItem quoteLI = TestDataFactory.gerarQuoteLineItem(cotacao, pricebookEntry);
        insert quoteLI;
    
        OpportunityContactRole ocr = TestDataFactory.gerarOpportunityContactRole(opp1, ctt);
        insert ocr;
    }

    @isTest
    static void testSetDefaultCloseDate() {
        Opportunity opp = [
            SELECT Id, Name, StageName, CloseDate
            FROM Opportunity        
            WHERE StageName = 'Negociação'
        ];
        opp.CloseDate = null;

        List<Opportunity> opps = new List<Opportunity>{ opp };
        OpportunityHelper.addDaysToCloseDateOnCreation(opps);

        for (Opportunity o : opps) {
            System.assertEquals(Date.today().addDays(5), o.CloseDate, 'CloseDate should be set to today + 5 days');
        }
    }

    @IsTest
    static void testGetPicklistValues() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Negociação'];
        Schema.sObjectField field = Opportunity.StageName;
        System.debug(OpportunityHelper.getPickListValues(field));
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_AllFieldsFilled() {        
        List<Opportunity> opps = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
        ];
        Quote cotacao = [
            SELECT Id
            FROM Quote
            WHERE OpportunityId = :opps.get(0).Id
        ];
        opps.get(0).SyncedQuoteId = cotacao.Id;
        
        Opportunity firstOpp = opps.get(0).clone(true, true, false, false);
        firstOpp.StageName = 'Ficha Cadastral';
        
        Opportunity secondOpp = opps.get(1).clone(true, true, false, false);
        secondOpp.StageName = 'Pré-análise';
        secondOpp.FarolChecklistDocumento__c = 'Verde';

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp, secondOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opps.get(0).Id => opps.get(0), opps.get(1).Id => opps.get(1) });
        Test.stopTest();

        for (Opportunity o : newOpps) {
            System.assert(!o.getErrors().isEmpty(), 'Não deveria ter erros');
        }
    }

    @isTest
    static void testValidateTransitionToFichaCadastral_MissingRequiredFields() {
        Opportunity opp = [
            SELECT Id, Name, AccountId, Corretor__c, StageName, CloseDate
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];

        List<Opportunity> opps = new List<Opportunity>{ opp };
        
        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(opps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();
    }

    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoValid() {
        Opportunity opp = TestDataFactory.gerarOportunidade();
        opp.StageName = 'Pré-análise';
        insert opp;

        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opp);
        insert analise;

        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        update opp;
        Test.stopTest();

        System.assertEquals('Geração de Contrato', opp.StageName, 'StageName da Oportunidade deveria ser "Geração de Contrato"');
    }
    
    @isTest
    static void testHasBuyersWithBuyers() {
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE StageName = 'Negociação'];
        
        OpportunityContactRole oppContactRole = [SELECT Id, Role FROM OpportunityContactRole];
        oppContactRole.Role = 'Comprador';
        update oppContactRole;

    
        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(oportunidade.Id);
        Test.stopTest();

        
        System.assertEquals(true, result, 'há compradores associadoss.');
    }

    @isTest
    static void testHasBuyersWithoutBuyers() {
        Opportunity oportunidade = [SELECT Id FROM Opportunity WHERE StageName = 'Negociação'];


        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(oportunidade.Id);
        Test.stopTest();


        System.assertEquals(true, result, 'não há compradores associados');
    }

    @isTest
    static void testHasBuyersWithException() {
        Test.startTest();
        Boolean result = OpportunityHelper.hasBuyers(null); 
        Test.stopTest();

        
        System.assertEquals(false, result, 'Exceção.');
    }



    @IsTest
    static void testHandlePreAnaliseForAnaliseCreditoInvalid() {
        Opportunity opp = TestDataFactory.gerarOportunidade();
        opp.StageName = 'Pré-análise';
        insert opp;
        
        opp.StageName = 'Geração de Contrato';
        Test.startTest();
        try {
            update opp;
            System.assert(false, 'Deveria lançar um erro devido que a oportunidade não tem Análise de Crédito associado.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Por favor, associe uma Análise de Crédito para avançar de fase.'));
        }
        Test.stopTest();

        Opportunity oppTestada = [
            SELECT Id, StageName 
            FROM Opportunity
            WHERE Id = :opp.Id
        ];

        System.assertEquals('Pré-análise', oppTestada.StageName, 'StageName da Oportunidade deveria ser "Pré-análise"');
    }


    @IsTest
    static void testHandleBeforeUpdate() {
        Opportunity opp = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
            LIMIT 1
        ];
        Quote cotacao = [
            SELECT Id
            FROM Quote
            WHERE OpportunityId = :opp.Id
        ];
        opp.SyncedQuoteId = cotacao.Id;
        
        Opportunity firstOpp = opp.clone(true, true, false, false);

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : newOpps) {
            System.assert(o.getErrors().isEmpty(), 'Não deveria ter erros');
        }       
    }

    @IsTest
    static void testImpedirAlteracaoProbability() {
        Opportunity opp = [
            SELECT Id, Name, StageName, FarolChecklistDocumento__c, CanalAtendimento__c, TipoVenda__c, Probability, AccountId, Amount, SyncedQuoteId, Corretor__c
            FROM Opportunity
            LIMIT 1
        ];

        Opportunity firstOpp = opp.clone(true, true, false, false);

        List<Opportunity> newOpps = new List<Opportunity> { firstOpp };

        Test.startTest();
        OpportunityHelper.validateTransitionToFichaCadastral(newOpps, new Map<Id, Opportunity>{ opp.Id => opp });
        Test.stopTest();

        for (Opportunity o : newOpps) {
            System.assert(o.getErrors().isEmpty(), 'Não deveria ter erros');
        }  
    }

    @IsTest
    static void testGetByAnaliseCreditoId() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];
 
        Test.startTest();
        List<Opportunity> results = OpportunityHelper.getByAnaliseCreditoId(new Set<Id>{ analise.Id });
        Test.stopTest();

        Opportunity expected = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Pré-análise'
        ];

        System.assertEquals(expected.Id, results[0].Id, 'Ids incorreto');
    }

    @IsTest
    static void testGetByIds() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];
 
        Test.startTest();
        List<Opportunity> result = OpportunityHelper.getByIds(new Set<Id>{ opp.Id });
        Test.stopTest();

        Opportunity expected = [
            SELECT Id, StageName
            FROM Opportunity
            WHERE StageName = 'Negociação'
        ];

        System.assertEquals(expected.Id, result[0].Id, 'Ids incorreto');
    }

    @IsTest
    static void testHandleStageFichaCadastralChangeFarolColorValid() {
        Opportunity opp = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Pré-análise'];

        Opportunity cloneOpp = opp.clone(true, true, false, false);
        cloneOpp.StageName = 'Ficha Cadastral';

        Test.startTest();
        OpportunityHelper.handleStageFichaCadastralChangeFarolColor(new List<Opportunity>{opp}, new Map<Id, Opportunity>{cloneOpp.Id => cloneOpp});
        Test.stopTest();

        System.assertEquals(opp.FarolChecklistDocumento__c, 'Vermelho', 'FarolChecklist deveria ser Vermelho');
    }
    
    @IsTest
    static void testHandleStageFichaCadastralValid() {
        Opportunity opps = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Negociação'];
        
        Test.startTest();
        OpportunityHelper.handleStageFichaCadastral(new List<Opportunity>{ opps });
        Test.stopTest();

        System.assert(opps.getErrors().isEmpty(), 'Não deveria conter erros.');
    }

    @IsTest
    static void testHandleStageFichaCadastralInvalid() {
        Opportunity opps = [SELECT Id, StageName, FarolChecklistDocumento__c FROM Opportunity WHERE StageName = 'Pré-análise'];
        opps.FarolChecklistDocumento__c = 'Vermelho';

        Test.startTest();
        OpportunityHelper.handleStageFichaCadastral(new List<Opportunity>{ opps });
        Test.stopTest();

        System.assert(!opps.getErrors().isEmpty(), 'Deveria conter erros.');
    }
    
}