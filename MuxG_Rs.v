module MuxG_Rs (
    input wire seletor,
    input wire [31:0] rs,
    input wire [31:0] rsDivM,
    output wire [31:0] saida
);

assign saida = (seletor == 1'b0) ? rs : rsDivM;
endmodule