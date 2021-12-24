module MuxD_ula(
    input wire seletor,
    input wire [31:0] pc,
    input wire [31:0] rs,
    output wire [31:0] saida
);

assign saida = (seletor == 1'b0) ? pc : rs;
endmodule