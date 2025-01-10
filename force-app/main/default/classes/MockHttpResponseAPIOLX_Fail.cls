public class MockHttpResponseAPIOLX_Fail implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"error":"Erro ao enviar o lead."}');
        res.setStatusCode(500); 
        return res;
    }
}