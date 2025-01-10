@isTest
public class ComparativoServiceTest {
    
    @TestSetup
    static void makeData(){

        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        empreendimento.MetragemPrivativaTotal__c = 100;
        insert empreendimento;

        TabelaVendas__c tabela = TestDataFactory.gerarTabelaVendas();
        tabela.Empreendimento__c = empreendimento.id;
        insert tabela;

        SeriePagamentos__c serie = TestDataFactory.gerarSeriePagamento(tabela.Id);
        insert serie;
    }

    @isTest
    public static void testCalcularComparacao() {
        TabelaVendas__c tabela = [SELECT Id, Name FROM TabelaVendas__c LIMIT 1];
        List<SeriePagamentos__c> series = [SELECT Id, Name,InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        Map<String, Object> valoresMatriz = new Map<String, Object>{
            'nominalProposta' => 100000, 
            'nominalTabela' => 200000, 
            'valorVplProposta' => 80000};
    
        Test.startTest();
        List<ComparativoService.ComparacaoResultado> comparativo = ComparativoService.calcularComparacao(tabela.Id, series, valoresMatriz);
        Test.stopTest();

        Assert.areEqual(true, (comparativo.size() > 0), 'A lista não pode estar vazia');
    }
}