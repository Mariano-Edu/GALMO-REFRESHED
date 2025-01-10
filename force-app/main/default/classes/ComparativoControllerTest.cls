@isTest
public with sharing class ComparativoControllerTest {
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

   // @isTest
  //  public static void testCalcularComparacao() {
        // Busca um registro de TabelaVendas__c para ser usado no teste
       // TabelaVendas__c tabela = [SELECT Id FROM TabelaVendas__c LIMIT 1];
        
        // Busca uma lista de registros de SeriePagamentos__c com os campos necessários
        // List<SeriePagamentos__c> series = [SELECT Id, Name, InicioPagamento__c, QuantidadeParcelas__c, ValorTotal__c, TabelaVenda__c, TipoCondicao__c, AposHabiteSe__c FROM SeriePagamentos__c];
        
        // Test.startTest(); // Inicia o escopo de teste para capturar limites de execução
        // List<Object> comparativo = ComparativoController.calcularComparacao(tabela.Id, series); // Chama o método a ser testado
        // Test.stopTest(); // Finaliza o escopo de teste para avaliar o comportamento
        
        // Verifica se o retorno do método não é uma lista vazia
        //Assert.areEqual(true, (comparativo.size() > 0), 'A lista não pode estar vazia');
   //  }
    
}