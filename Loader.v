module Loader (
    input  wire[31:0] Mem_data,
    input  wire[1:0]  Load_size,
    output wire[31:0] Data_out
    /// Codigos LoadSize:
    /// 00 -> lw
    /// 01 -> lb
    /// 10 -> lh
    /// 11 -> lbu
);
    wire[31:0] A1;  // Guarda o res intermediário se for lh  ou lw baseado em LS[1]
    wire[31:0] A2;  // Guarda o res intermediário se for lbu ou lb baseado em LS[1]
    
    wire[31:0] Byte_sign; // Guarda o byte menos significativo com sinal extendido   (lb)
    wire[31:0] Half;      // Guarda a metade menos significativa com sinal extendido (lh)

    assign Byte_sign = {{24{1'b0}}, Mem_data[7:0]};
    assign Half      = {{16{1'b0}}, Mem_data[15:0]};

    // Primeiro seleciona as operações possíveis com base em LS[1] e as guarda em A1 e A2
    // Depois, seleciona a operação correta com base em LS[0]
    assign A1 = Load_size[1] ? Half : Mem_data;                         // LS[0] == 0 -> A1 = lh  ou lw 
    assign A2 = Load_size[1] ? {{24{1'b0}}, Mem_data[7:0]} : Byte_sign; // LS[0] == 1 -> A2 = lbu ou lb

    assign Data_out = Load_size[0] ? A2 : A1; // Seleção com base em LS[0]
    
endmodule

