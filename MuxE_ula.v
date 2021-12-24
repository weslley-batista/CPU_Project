module MuxE_ula(
    input wire [1:0]seletor, // 1000
    input wire [31:0] rt,
    input wire [31:0] offset,
    input wire [31:0] siftLeft2,
    input wire [31:0] RegDeslocamento,
    output wire [31:0] saida

);
wire [31:0] w1;
wire [31:0] w2;
wire [31:0] w3;

assign w3 = (seletor == 2'b11) ? siftLeft2 : RegDeslocamento;
assign w2 = (seletor == 2'b10) ? offset : w3;
assign w1 = (seletor == 2'b01) ? 3'b100 : w2;
assign saida = (seletor == 2'b00) ? rt : w1;
endmodule