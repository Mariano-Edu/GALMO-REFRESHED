public class MockHttpResponseAPIOLX_Success implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"message":"Lead enviado com sucesso."}');
        res.setStatusCode(200);
        return res;
    }
}