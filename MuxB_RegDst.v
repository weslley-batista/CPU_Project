module MuxB_RegDst(
    input wire [2:0] seletor, //011 
    input wire [4:0] rt,
    input wire [4:0] rd,
    output wire [4:0] saida
    
);
wire [4:0] w1;
wire [4:0] w2;

assign w2 =  (seletor == 3'b011 ) ? 5'b11111 : 5'b11101; //29 ou 31
assign w1 =  (seletor == 3'b001 ) ? rd : w2;
assign saida =  (seletor == 3'b000 ) ? rt : w1;

endmodule