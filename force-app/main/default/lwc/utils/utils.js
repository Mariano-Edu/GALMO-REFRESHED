export function formatData(data){
    const partes = data.split('-');
    if (partes.length !== 3) {return null;}

    const ano = parseInt(partes[0], 10);
    const mes = parseInt(partes[1], 10);
    const dia = parseInt(partes[2], 10);

    if (isNaN(ano) || isNaN(mes) || isNaN(dia)) {return null;}

    return `${dia}/${mes}/${ano}`;
}

export function calcularInicioPagamentoSeriePagamentos(serieDePagamentos){
    let mesesParaInicio = serieDePagamentos.InicioPagamento__c != null ? serieDePagamentos.InicioPagamento__c : 0;


    let dataInicio = new Date();

    "2024-10-24"

    dataInicio.setMonth(dataInicio.getMonth() + mesesParaInicio);

    let day = String(dataInicio.getDate()).padStart(2, '0');
    let month = String(dataInicio.getMonth() + 1).padStart(2, '0'); 
    let year = dataInicio.getFullYear();
    
    let dataInicioFormatada = `${year}-${month}-${day}`;


    return dataInicioFormatada;
}

export function calcularPorcParcelaSeriePagamento(porcValorTotal, qtdParcela){
    return porcValorTotal / qtdParcela;
}

export function calcularValorParcelaSeriePagamento(porcParcela, valorNominal){
    return porcParcela / 100 * valorNominal;
}

export function calcularValorTotalSeriePagamento(porcTotal, valorNominal){
    return porcTotal / 100 * valorNominal;
}

export function calcularDiferencaMeses(data) {
    let partes = data.split("/");
    let dataIso = `${partes[2]}-${partes[1]}-${partes[0]}`;
    
    let dataObjetoFinal = new Date(dataIso);
    let dataAtual = new Date(); 
    
    let anoInicio = dataAtual.getFullYear();
    let mesInicio = dataAtual.getMonth(); 
    
    let anoFim = dataObjetoFinal.getFullYear();
    let mesFim = dataObjetoFinal.getMonth();
    
    let diferencaMeses = (anoFim - anoInicio) * 12 + (mesFim - mesInicio);

    if (dataObjetoFinal.getDate() < dataAtual.getDate()) {
        diferencaMeses -= 1; 
    }

    return diferencaMeses;
}