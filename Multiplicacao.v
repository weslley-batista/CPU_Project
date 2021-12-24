module Multiplicacao (//clock,sinalControle,Rt,Rs,Flag,Ciclos
    input wire clock, sinalStartMult,
    input wire [31:0] a,
    input wire [31:0] b,
    output reg [31:0] hi, lo,
    output reg sinalParadaMult
);

reg [5:0] contagemCiclos;   // b'100000
reg [63:0] auxilioA, auxilioB, somaPorCiclo;

initial begin   //garantir valores iniciais padroes
    somaPorCiclo = 0;
    contagemCiclos = 0;
    hi = 0;
    lo = 0;
    sinalParadaMult = 0;
    auxilioA = a; //guarda A e B para alterar valores
    auxilioB = b;
end

always @(posedge clock) begin
    if(sinalStartMult == 1) begin
        auxilioA = a;
        auxilioB = b;
        somaPorCiclo = 0;
        sinalParadaMult = 0;
        contagemCiclos = 0;
    end

    if((auxilioB[contagemCiclos]==1) && (contagemCiclos<=31)) begin
            somaPorCiclo = somaPorCiclo + {auxilioA<<contagemCiclos}; //mudança de bit a cada ciclo
    end

    else if (contagemCiclos == 32) begin
        hi = somaPorCiclo[63:32];       //parte1
        lo = somaPorCiclo[31:0];        //parte2
        sinalParadaMult = 1;
    end
    contagemCiclos = contagemCiclos+1; //somaPorCiclo ciclos (32 ciclos (bits))
end
endmodule