module SignExtend_16_32 (
    input wire [15:0] fazerExtencao, //15_0
    output wire [31:0] saida
);
    assign saida = (fazerExtencao[15] == 1'b1) ? { {16{1'b1}}, fazerExtencao} : { {16{1'b0}}, fazerExtencao};
endmodule