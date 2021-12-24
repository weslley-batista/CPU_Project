module MuxH_Rt (
    input wire seletor, //101
    input wire [31:0] rt,
    input wire [31:0] rtDivM,
    output wire [31:0] saida
);

assign saida = (seletor == 1'b0) ? rt : rtDivM;
endmodule