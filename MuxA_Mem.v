module MuxA_Mem(
    input wire [3:0] seletor, // 1000
    input wire [31:0] pc,
    input wire [31:0] alu_result,
    input wire [31:0] rs,
    input wire [31:0] rt,
    output wire [31:0] saida
);

parameter opCode_inexistente = 32'b00000000000000000000000011111101;    //000000000000000000000011111101
parameter overflow = 32'b00000000000000000000000011111110;
parameter divisaoBy0 = 32'b00000000000000000000000011111111;

wire [31:0] w1;
wire [31:0] w2;
wire [31:0] w3;
wire [31:0] w4;
wire [31:0] w5;
wire [31:0] w6;
wire [31:0] w7;

assign w5 = (seletor == 4'b0101) ? rs : rt;
assign w4 = (seletor == 4'b0100) ? divisaoBy0 : w5;
assign w3 = (seletor == 4'b0011) ? overflow : w4;
assign w2 = (seletor == 4'b0010) ? opCode_inexistente : w3;
assign w1 = (seletor == 4'b0001) ? alu_result : w2; 
assign saida =  (seletor == 4'b0000 ) ? pc : w1;

endmodule