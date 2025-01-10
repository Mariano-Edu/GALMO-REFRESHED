public class MockHttpResponseAPIOLX implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"Lead criado com sucesso."}');  
        res.setStatusCode(200);
        return res;
    }
}