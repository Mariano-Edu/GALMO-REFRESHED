@isTest
public class DocumentacaoHelperTest {
    
    @TestSetup
    static void setup() {
        Documentacao__c doc = TestDataFactory.gerarDocumentacao();
        insert doc;
        
        Opportunity opp = TestDataFactory.gerarOportunidade();
        opp.StageName = 'Pré-análise';
        insert opp;
        
        AnaliseCredito__c analise = TestDataFactory.gerarAnaliseCredito(opp);
        insert analise;
        
        Checklist_de_Documentos__c checklists = TestDataFactory.gerarChecklistDocumentos(opp, doc);
        insert checklists;
    }
    
    @IsTest
    static void testCriarDocumentacao() {
        String nomeDocumento = 'Dock Test';
        
        Test.startTest();
        DocumentacaoHelper.criarDocumentacao(nomeDocumento);
        Test.stopTest();
        
        Documentacao__c doc = [
            SELECT Id, Name
            FROM Documentacao__c
            WHERE Name = 'Dock Test'
        ];
        
        System.assertNotEquals(null, doc, 'Deveria existir um Documento salvo.');
        System.assertEquals(nomeDocumento, doc.Name, 'Deveria existir uma Documentação com o nome "Dock Test".');
    }
    
    @IsTest
    static void testGetByAnaliseCreditoValidate() {
        AnaliseCredito__c analise = [
            SELECT Id
            FROM AnaliseCredito__c
        ];
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.getByAnaliseCredito(analise.Id);
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Validado__c, Obrigatorio__c, Entregue__c 
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos.');
    }
    
    @IsTest
    static void testValidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = false;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.validateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos válidos.');
    }
    
    @IsTest
    static void testInvalidateDocuments() {
        Documentacao__c doc = [
            SELECT Id, Validado__c
            FROM Documentacao__c
        ];
        doc.Validado__c = true;
        update doc;
        
        Test.startTest();
        List<Documentacao__c> docs = DocumentacaoHelper.invalidateDocuments(new Set<Id>{ doc.Id });
        Test.stopTest();
        
        List<Documentacao__c> expected = [
            SELECT Id, Name, Contato__c, ContentDocumentId_c__c, Entregue__c, Validado__c
        	FROM Documentacao__c
        ];
        
        System.assertEquals(expected, docs, 'Deveria retornar uma lista de Documentos inválidos.');
    }
    
    @IsTest
    static void testDeleteById() {
        // Criação de dados de teste
        Documentacao__c doc = new Documentacao__c(Name = 'Documento Teste', ContentDocumentId_c__c = 'TestContentDocumentId');
        insert doc;
        
        ContentDocumentLink contentDocLink = new ContentDocumentLink(
            ContentDocumentId = 'TestContentDocumentId',
        LinkedEntityId = doc.Id,
        ShareType = 'V'
            );
        insert contentDocLink;
        
        Checklist_de_Documentos__c cklistDoc = new Checklist_de_Documentos__c(
            Name = 'Checklist Teste',
        Documenta_o__c = doc.Id
            );
        insert cklistDoc;
        
        Test.startTest();
        DocumentacaoHelper.deleteById(doc.Id);
        Test.stopTest();
        
        // Validações
        Documentacao__c fetchedDoc = [
        SELECT Id
        FROM Documentacao__c
        WHERE Id = :doc.Id
        LIMIT 1
    ];
        System.assertEquals(null, fetchedDoc, 'O documento deveria ter sido excluído.');
        
        List<ContentDocumentLink> fetchedContentDocLinks = [
        SELECT Id
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :doc.ContentDocumentId_c__c
    ];
        System.assertEquals(0, fetchedContentDocLinks.size(), 'Os ContentDocumentLinks associados deveriam ter sido excluídos.');
        
        List<Checklist_de_Documentos__c> fetchedChecklistDocs = [
        SELECT Id
        FROM Checklist_de_Documentos__c
        WHERE Documenta_o__c = :doc.Id
    ];
        System.assertEquals(0, fetchedChecklistDocs.size(), 'Os Checklist_de_Documentos associados deveriam ter sido excluídos.');
    }
    
    
    @IsTest
    static void testRecoverById() {
        // Criação de dados de teste
        Documentacao__c doc = new Documentacao__c(Name = 'Documento Teste', ContentDocumentId_c__c = 'TestContentDocumentId');
        insert doc;
        
        // Simular uma versão de conteúdo
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Teste Version',
        PathOnClient = 'teste.pdf',
        VersionData = Blob.valueOf('Conteúdo do documento'),
        ContentDocumentId = 'TestContentDocumentId'
            );
        insert contentVersion;
        
        Test.startTest();
        Map<String, String> result = DocumentacaoHelper.recoverById(doc.Id);
        Test.stopTest();
        
        // Validações
        System.assertNotEquals(null, result, 'O resultado não deveria ser nulo.');
        System.assert(result.containsKey('documentUrl'), 'Deveria conter a chave "documentUrl".');
        System.assert(result.containsKey('base64Data'), 'Deveria conter a chave "base64Data".');
        System.assert(result.containsKey('mimeType'), 'Deveria conter a chave "mimeType".');
        System.assert(result.containsKey('fileName'), 'Deveria conter a chave "fileName".');
        
        // Testar exceção para ID inválido
        try {
            DocumentacaoHelper.recoverById('001000000000000AAA');
            System.assert(false, 'Deveria lançar exceção para ID inválido.');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Documento não encontrado', e.getMessage(), 'A mensagem de erro deveria ser "Documento não encontrado".');
        }
        
        // Testar exceção para versão não encontrada
        Documentacao__c docSemVersao = new Documentacao__c(Name = 'Documento Sem Versão', ContentDocumentId_c__c = 'OutroTestContentId');
        insert docSemVersao;
        
        try {
            DocumentacaoHelper.recoverById(docSemVersao.Id);
            System.assert(false, 'Deveria lançar exceção para versão não encontrada.');
        } catch (IllegalArgumentException e) {
            System.assertEquals('Versão mais recente do documento não encontrada.', e.getMessage(), 'A mensagem de erro deveria ser "Versão mais recente do documento não encontrada."');
        }
    }
    
    
    
}