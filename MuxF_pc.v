module MuxF_pc (
    input wire [2:0] seletor, //101
    input wire [31:0] aluResult,
    input wire [31:0] aluOut,
    input wire [31:0] epc_out,
    input wire [31:0] shiftLeft_26_28,
    input wire [31:0] rs,
    input wire [31:0] loadSize,
    output wire [31:0] saida
);
wire [31:0] w1;
wire [31:0] w2;
wire [31:0] w3;
wire [31:0] w4;

assign w4 = (seletor == 3'b100) ? rs : loadSize;
assign w3 = (seletor == 3'b011) ? shiftLeft_26_28 : w4;
assign w2 = (seletor == 3'b010) ? epc_out : w3;
assign w1 = (seletor == 3'b001) ? aluOut : w2;
assign saida = (seletor == 3'b000) ? aluResult : w1;

endmodule