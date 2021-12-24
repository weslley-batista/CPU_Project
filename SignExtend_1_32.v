module SignExtend_1_32 (
    input wire menorQue,
    output wire [31:0] saida
);
    
    assign saida = (menorQue == 1'b1) ? { {31{1'b0}}, menorQue} : { {31{1'b0}}, menorQue};

endmodule