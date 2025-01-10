@isTest
private class OLXLeadWebhookServiceTest {

    
    @isTest
    static void testProcessarLead_Success() {

        LeadWrapper leadWrapperTest = new LeadWrapper();
        leadWrapperTest.name = 'Test Lead';
        leadWrapperTest.email = 'testlead@example.com';
        leadWrapperTest.phone = '123456789';
        leadWrapperTest.mobilePhone = null;
        leadWrapperTest.CanalAtendimento = 'Chat';
        leadWrapperTest.message = 'Mensagem de Teste';
        leadWrapperTest.adId = 'ad123';
        leadWrapperTest.listId = 'list123';
        leadWrapperTest.linkAd = 'http://testlink.com';
        leadWrapperTest.externalId = 'ext123';


       
        String corpoRequisicao = JSON.serialize(leadWrapperTest);

        
        Test.setMock(HttpCalloutMock.class, new OLXHttpMock());

      
        RestResponse res = new RestResponse();

      
        Test.startTest();
        OLXLeadWebhookService.processarLead(corpoRequisicao, res);
        Test.stopTest();

      
        System.assertEquals(200, res.statusCode);
        System.assertEquals('Lead criado com sucesso.', res.responseBody.toString());
    }

    private class OLXHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message": "Lead criado com sucesso."}');
            return res;
        }
    }
}