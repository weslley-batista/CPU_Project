module MuxL_NRegDeslocamento (
    input wire [2:0]seletor, //n tem 4 bits
    input wire [4:0] rt,
    input wire [4:0] signExtend,
    input wire [4:0] shamt,
    output wire [4:0] saida
);
parameter dezeseis = 5'b10000;

wire [4:0] w1;
wire [4:0] w2;

assign w2 = (seletor == 3'b010) ? signExtend : shamt;
assign w1 = (seletor == 3'b001) ? dezeseis : w2;
assign saida = (seletor == 3'b000) ? rt : w1;
endmodule