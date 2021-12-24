module SignExtend_26_28 (
    input wire [25:0] bitsInstrucoes,
    output wire [31:0] saida
);                                       

wire [27:0] DoisOitoBits;
assign DoisOitoBits = bitsInstrucoes;

assign saida = (bitsInstrucoes[25] == 1'b1) ? { {4{1'b1}}, {DoisOitoBits<<2} }: { {4'b0}, {DoisOitoBits<<2}};
endmodule