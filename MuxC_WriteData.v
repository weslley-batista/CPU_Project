module MuxC_WriteData(
    input wire [3:0] seletor, // 1001
    input wire [31:0] aluOut_result,
    input wire [31:0] loadSize,
    input wire [31:0] saidaRegistradorDeslocamento,
    input wire [31:0] alu_result,
    input wire [31:0] hi,
    input wire [31:0] lo,
    input wire [31:0] MRD_out,
    input wire [31:0] singExtend_1_32,
    output wire [31:0] saida
);

parameter duzentosVinteSete = 32'b00000000000000000000000011100011;

wire [31:0] w1;
wire [31:0] w2;
wire [31:0] w3;
wire [31:0] w4;
wire [31:0] w5;
wire [31:0] w6;
wire [31:0] w7;

assign w7 = (seletor == 4'b1000) ? duzentosVinteSete : singExtend_1_32;
assign w6 = (seletor == 4'b0111) ? MRD_out : w7;
assign w5 = (seletor == 4'b0110) ? lo : w6;
assign w4 = (seletor == 4'b0101) ? hi : w5;
assign w3 = (seletor == 4'b0100) ? alu_result : w4;
assign w2 = (seletor == 4'b0011) ? saidaRegistradorDeslocamento : w3;
assign w1 = (seletor == 4'b0010) ? loadSize: w2;
assign saida = (seletor == 4'b0001) ? aluOut_result : w1;

endmodule