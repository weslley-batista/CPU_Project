module Div (
    input clock,
    input sinalStartDiv,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] hi, lo,
    output reg sinalParadaDiv
    
);

reg [5:0] contagemDeCiclos; // b'100000
reg [31:0] soma; 
reg [31:0] auxilioA;
reg [31:0] AuxilioB, auxilioBB, auxilioBBB;  
reg negativo;


initial begin       //garantir valores iniciais padroes
    contagemDeCiclos = 31; //diminuir os bits
    auxilioA = 0;
    AuxilioB = 0;
    negativo = 0;
    auxilioBB = 0;
    hi = 0;
    lo = 0;
    soma = 0;
    sinalParadaDiv = 0;
end
// o sinal "~" faz complemento de 2
always @(posedge clock) begin
    if(sinalStartDiv == 1) begin //controle positivo
        contagemDeCiclos = 32;
        auxilioA = a;
        AuxilioB = 0;
        auxilioBB = b;
        hi = 0;
        lo = 0;
        soma = 0;
        sinalParadaDiv = 0;
        
        //verificando sinal dos valores de entrada
        if((a[31] == 1) && (b[31] == 1)) begin //inverto os dois para tornar a conta normal(sem precisar usar complemento2 depois)
            negativo = 0;
            auxilioA = ~auxilioA+1;
            auxilioBB = ~auxilioBB+1;
            auxilioBBB = ~auxilioBBB+1;
        end 
        else if ((a[31] == 1) && (b[31] == 0)) begin
            negativo = 1;   //sinal para complemento2
            auxilioA = ~auxilioA+1;
        end
        else if ((a[31] == 0) && (b[31] == 1)) begin
            negativo = 1;   //sinal para complemento2
            auxilioBB = ~auxilioBB+1; 
            auxilioBBB = ~auxilioBBB+1; 
        end
    end 
    contagemDeCiclos = contagemDeCiclos-1;

   if((auxilioBB<<contagemDeCiclos) < {{32{1'b0}},2147483648})begin
        AuxilioB = auxilioBB<<contagemDeCiclos;
   end
        auxilioBBB = auxilioBB<<contagemDeCiclos;
    //passagem de ciclos
    if((AuxilioB<=auxilioA) && (contagemDeCiclos>=0) && (AuxilioB>0)) begin
        soma = soma+{1<<contagemDeCiclos};
        auxilioA = auxilioA - AuxilioB;
    end
    if (contagemDeCiclos == 0) begin
        hi = auxilioA;          //resto
        lo = soma;              //resultado (quociente)
        sinalParadaDiv = 1;
    if(negativo == 1)begin      //revertendo quociente se caso tenha acontecido operacoes com negativos
        lo = {~lo}+1;
    end
end

end 
endmodule