module MuxK_RegDeslocamento (
    input wire [1:0] seletor,
    input wire [31:0] rt,
    input wire [31:0] imediatoExtend,
    input wire [31:0] rs,
    output wire [31:0] saida
);
wire [31:0] w1;

assign w1 = (seletor == 1'b1) ? imediatoExtend : rs;
assign saida = (seletor == 1'b0) ? rt : w1;
    
endmodule