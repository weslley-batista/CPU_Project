module unit_processamento (
    input wire clk,
    input wire reset
);
    //opCode e Funct
    wire [5:0] opcode;   
    wire[5:0] funct; 

    //Control wire
    wire pc_write;
    wire mem_write;
    wire mdr_write;
    wire ir_write;
    wire reg_write;
    wire a_write;
    wire b_write;
    wire ula_reg_write;
    wire [2:0]aluOp;
    wire epc_write;
    wire overflow_out;
    wire negativo_out;
    wire igual_out;
    wire maior_out;
    wire menor_out;
    wire z_out;
    wire [2:0] reg_deslocamento_shift;
    wire sinalStartMult;
    wire sinalParadaMult;
    wire flag_start_div;
    wire flag_stop_div;
    wire lo_write;
    wire hi_write;
    wire [1:0] store_size_command;
    wire [1:0] loadSise_write;
    
    //muxs
    wire [3:0] muxA;
    wire [2:0] muxB;
    wire [3:0] muxC;
    wire muxD;
    wire [1:0] muxE;
    wire [2:0] muxF;
    wire muxG;
    wire muxH;
    wire muxIJ;
    wire [1:0] muxK;
    wire [2:0] muxL;
    
    //Data wire
    //Muxs
    wire [31:0] saida_mux_A;
    wire [4:0] saida_mux_B;
    wire [31:0] saida_mux_C;
    wire [31:0] saida_mux_D;
    wire [31:0] saida_mux_E;
    wire [31:0] saida_mux_F;
    wire [31:0] saida_mux_G;
    wire [31:0] saida_mux_H;
    wire [31:0] saida_mux_IJ_hi;
    wire [31:0] saida_mux_IJ_lo;
    wire [31:0] saida_mux_K;
    wire [4:0] saida_mux_L; //entrada N registrados de deslocamenteo 5 bits
    
    //signExtends
    wire [31:0] signExtend_1_31_out;
    wire [31:0] signExtend_16_32_out;
    wire [31:0] signExtend_26_28_out;

    //Pc
    wire [31:0] pc_out;
    
    //ULA
    wire [31:0] aluResult_out;
    wire [31:0] aluOut_result_out;

    //Ula Reg
    wire [31:0] ula_reg_out;

    //EPC
    wire [31:0] epc_out;

    //A e B
    wire [31:0] out_registrador_rs;
    wire [31:0] out_registrador_rt;

    //Registrador de deslocamento
    wire [31:0] registrador_deslocamento_out;

    //Load e store
    wire [31:0] storeSize_out;
    wire [31:0] loadSize_out;

    //memoria
    wire [31:0] mem_out;

    //memory data register
    wire [31:0] mdr_out;

    //Registrador de instruções
    
    wire [5:0] opcode_out;
    wire [4:0] rs_out;
    wire [4:0] rt_out;
    wire [4:0] rd_out;
    wire [15:0] imediato_out;
    wire [25:0] inst_25_0;

    assign funct = imediato_out[5:0];
    assign opcode = opcode_out;

    //Banco Reg
    wire [31:0] reg_data_1_out;
    wire [31:0] reg_data_2_out;

    //Shift Left 2  
    wire [31:0] shiftLeft2_out;

    //Div
    wire [31:0] div_hi_out;
    wire [31:0] div_lo_out;

    //Mult
    wire [31:0] mult_hi_out;
    wire [31:0] mult_lo_out;

    // Hi e Lo
    wire [31:0] hi_out;
    wire [31:0] lo_out;

    Registrador PC(
        clk,
        reset,
        pc_write,
        saida_mux_F,
        pc_out
    );

    MuxA_Mem muxA_mem(
        muxA, //seletor 
        pc_out,
        aluResult_out,
        out_registrador_rs,
        out_registrador_rt,
        saida_mux_A
    );

    Memoria memoria(
        saida_mux_A,
        clk,
        mem_write,
        storeSize_out,
        mem_out
    );

    Registrador mem_data_register(
        clk,
        reset,
        mdr_write,
        mem_out,
        mdr_out
    );

    Instr_Reg instr_reg(
        clk,
        reset,
        ir_write,
        mem_out,
        opcode_out, //31_26
        rs_out, //25_21
        rt_out, //20_16
        imediato_out //15_0
    );

    assign rd_out = imediato_out[15:11];
    MuxB_RegDst muxB_regDst(
        muxB,
        rt_out,
        rd_out, //15_11
        saida_mux_B
    );
    
    MuxC_WriteData muxC_writeData(
        muxC,
        aluOut_result_out,
        loadSize_out,
        registrador_deslocamento_out,
        aluResult_out,
        hi_out,
        lo_out,
        mdr_out,
        signExtend_1_31_out,
        saida_mux_C
    );

    Banco_Reg banco_reg(
        clk,
        reset,
        reg_write,
        rs_out,
        rt_out,
        saida_mux_B,
        saida_mux_C,
        reg_data_1_out,
        reg_data_2_out
    );

    SignExtend_16_32 signExtend_16_32(
        imediato_out,
        signExtend_16_32_out
    );

    ShiftLeft2 shiftLeft2(
        signExtend_16_32_out,
        shiftLeft2_out
    );

    MuxG_Rs muxG_rs(
        muxG,
        reg_data_1_out,
        mdr_out,
        saida_mux_G
    );

    MuxH_Rt muxH_rt(
        muxH,
        reg_data_2_out,
        mdr_out,
        saida_mux_H
    );
    
    Registrador registrador_A_rs(
        clk,
        reset,
        a_write,
        saida_mux_G,
        out_registrador_rs
    );
    Registrador registrador_B_rT(
        clk,
        reset,
        b_write,
        saida_mux_H,
        out_registrador_rt
    );

    MuxD_ula muxD_ula(
        muxD,
        pc_out,
        out_registrador_rs,
        saida_mux_D
    );

    MuxE_ula muxE_ula(
        muxE,
        out_registrador_rt,
        signExtend_16_32_out,
        shiftLeft2_out,
        registrador_deslocamento_out,
        saida_mux_E
    );
    
    Ula32 ula32(
        saida_mux_D,
        saida_mux_E,
        aluOp,
        aluResult_out,
        overflow_out,
        negativo_out,
        z_out,
        igual_out,
        maior_out,
        menor_out
    );

    Registrador ula_reg(    //aluOut
        clk,
        reset,
        ula_reg_write,
        aluResult_out,
        ula_reg_out
    );

    Registrador EPC(
        clk,
        reset,
        epc_write,
        aluResult_out,
        epc_out
    );

    MuxF_pc muxF_pc(
        muxF,
        aluResult_out,
        ula_reg_out,
        epc_out,
        signExtend_26_28_out,
        out_registrador_rs,
        loadSize_out,
        saida_mux_F
    );

    MuxK_RegDeslocamento muxK_RegDeslocamento(
        muxK,
        out_registrador_rt,
        signExtend_16_32_out,
        out_registrador_rs,
        saida_mux_K        
    );
    
    wire[4:0] rt_muxL;
    wire[4:0] signExtend_muxL;
    wire[4:0] shamt;
    assign rt_muxL = out_registrador_rt[4:0];
    assign signExtend_muxL = signExtend_16_32_out;
    assign shamt = imediato_out[10:6];
    MuxL_NRegDeslocamento muxL_NRegDeslocamento(
        muxL,
        rt_muxL,
        mdr_out,
        shamt,
        saida_mux_L
    );

    RegDesloc registrador_delocamento(
        clk,
        reset,
        reg_deslocamento_shift,
        saida_mux_L,
        saida_mux_K,
        registrador_deslocamento_out
    );
    
    assign inst_25_0 = {{rs_out,rt_out},imediato_out};
    SignExtend_26_28 signExtend_26_28(
        inst_25_0,
        signExtend_26_28_out
    );

    SignExtend_1_32 signExtend_1_32(
        menor_out,
        signExtend_1_31_out
    );

    Div div(
        clk,
        flag_start_div,
        out_registrador_rs,
        out_registrador_rt,
        div_hi_out,
        div_lo_out,
        flag_stop_div
    );

    Multiplicacao multiplicacao(
        clk,
        sinalStartMult,
        out_registrador_rs,
        out_registrador_rt,
        mult_hi_out,
        mult_lo_out,
        sinalParadaMult
    );
    
    Registrador hi(
        clk,
        reset,
        hi_write,
        saida_mux_IJ_hi,
        hi_out
    );

    Registrador lo(
        clk,
        reset,
        lo_write,
        saida_mux_IJ_lo,
        lo_out
    );

    MuxIJ_MultDiv muxIJ_mult_div(
        muxIJ,
        mult_hi_out,
        mult_lo_out,
        div_hi_out,
        div_lo_out,
        saida_mux_IJ_hi,
        saida_mux_IJ_lo
    );

    Loader loader(
        mdr_out,
        loadSise_write,
        loadSize_out
    );

    store_size storeSize(
        store_size_command,
        mdr_out,
        out_registrador_rt,
        storeSize_out
    );
    
    unit_controle UnidadeDeControle(
        clk,
        reset,
        overflow_out,
        maior_out,
        igual_out,
        menor_out,
        z_out,
        opcode_out,///
        funct,
        flag_stop_div,
        sinalParadaMult,
        out_registrador_rt,
        pc_write,
        mem_write,
        mdr_write,
        ir_write,
        reg_write,
        a_write,
        b_write,
        ula_reg_write,
        epc_write,
        lo_write,
        hi_write,
        store_size_command,
        loadSise_write,
        reg_deslocamento_shift,
        aluOp,
        muxA,
        muxB,
        muxC,
        muxD,
        muxE,
        muxF,
        muxG,
        muxH,
        muxIJ,
        muxK,
        muxL,
        flag_start_div,
        sinalStartMult,
        reset
    );
endmodule