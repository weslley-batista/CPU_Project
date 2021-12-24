module unit_controle (
    input wire clk,
    input wire reset,

    input wire Overflow,
    input wire Gt,
    input wire Eq,
    input wire Lt,
    input wire ze,

    input wire [5:0] opcode,
    input wire [5:0] funct,

    input wire stopDiv,
    input wire stopMult,
    
    input wire [31:0]rt,
    
    //Writes
    output reg pc_write,
    output reg mem_write,
    output reg mdr_write,
    output reg ir_write,
    output reg reg_write,
    output reg a_write,
    output reg b_write,
    output reg ula_reg_write,
    output reg epc_write,
    output reg lo_write,
    output reg hi_write,

    //Sizes
    output reg [1:0] store_size,
    output reg [1:0] load_size,

    //Registrador de Deslocamento
    output reg [2:0] shift,

    //ULA
    output reg[2:0] aluOp,

    //Muxs
    output reg [3:0] muxA,
    output reg [2:0] muxB,
    output reg [3:0] muxC,
    output reg muxD,
    output reg [1:0] muxE,
    output reg [2:0] muxF,
    output reg muxG,
    output reg muxH,
    output reg muxIJ,
    output reg [1:0] muxK,
    output reg [2:0] muxL,

    //Flags
    output reg flag_start_div,
    output reg sinalStartMult,

    //Reset out
    output reg reset_out
);

    // Parametrização dos estados
    parameter state_fetch = 7'd0;
    parameter state_fetch_write = 7'd1;
    parameter state_decode = 7'd2;
    parameter state_reset = 7'd3;
    parameter state_branch = 7'd4;
    parameter state_branch_write = 7'd5;
    parameter state_addiu = 7'd6;
    parameter state_addi = 7'd7;
    parameter state_add = 7'd8;
    parameter state_sub = 7'd9;
    parameter state_and = 7'd10;
    parameter state_rd_write = 7'd11;
    parameter state_slt = 7'd12;
    parameter state_rd_write_slt = 7'd13;
    parameter state_div = 7'd14;
    parameter state_flag_div = 7'd15;
    parameter state_flag_div_write = 7'd16;
    parameter state_mult = 7'd17;
    parameter state_flag_mult = 7'd18;
    parameter state_mult_write = 7'd19;
    parameter state_mfhi = 7'd20;
    parameter state_mflo = 7'd21;
    parameter state_break = 7'd22;
    parameter state_break_write = 7'd23;
    parameter state_divm_read_rs = 7'd24;
    parameter state_divm_mdr_write_rs = 7'd25;
    parameter state_divm_read_rt = 7'd26;
    parameter state_divm_mdr_write_rt = 7'd27;
    parameter state_div_divm = 7'd28;
    parameter state_flag_div_divm = 7'd29;
    parameter state_div_write_divm = 7'd30;
    parameter state_sra = 7'd31;
    parameter state_sra_shift = 7'd32;
    parameter state_sll = 7'd33;
    parameter state_sll_shift = 7'd34;
    parameter state_srl = 7'd35;
    parameter state_srl_shift = 7'd36;
    parameter state_sllv = 7'd37;
    parameter state_sllv_shift = 7'd38;
    parameter state_srav = 7'd39;
    parameter state_srav_shift = 7'd40;
    parameter state_shift_write = 7'd41;
    parameter state_jr = 7'd42;
    parameter state_rte = 7'd43;
    parameter state_lui_sll = 7'd44;
    parameter state_sll_shift_lui = 7'd45;
    parameter state_lui_write = 7'd46;
    parameter state_j = 7'd47;
    parameter state_jal = 7'd48;
    parameter state_sum_offset_rs = 7'd49;
    parameter state_load_mdr_write = 7'd50;
    parameter state_lw = 7'd51;
    parameter state_lh = 7'd52;
    parameter state_lb = 7'd53;
    parameter state_load_rt_write = 7'd54;
    parameter state_sw = 7'd55;
    parameter state_mem_read_word = 7'd56;
    parameter state_sh = 7'd57;
    parameter state_sb = 7'd58;
    parameter state_read_word = 7'd59;
    parameter state_sram = 7'd60;
    parameter state_sram_shift = 7'd61;
    parameter state_sram_write = 7'd62;
    parameter state_slti = 7'd63;
    parameter state_slti_write = 7'd64;
    parameter state_divisao_por_0_1 = 7'd65;
    parameter state_divisao_por_0_2 = 7'd66;
    parameter state_divisao_por_0_3 = 7'd67;
    parameter state_overflow_1 = 7'd68;
    parameter state_overflow_2 = 7'd69;
    parameter state_overflow_3 = 7'd70;
    parameter state_opcode_inexistente_1 = 7'd71;
    parameter state_opcode_inexistente_2 = 7'd72;
    parameter state_opcode_inexistente_3 = 7'd73;
    parameter state_rt_write = 7'd74;
    parameter state_lui_shift = 7'd75;

    
    // Funct das instruções com Opcode 0x0
    parameter add = 6'b100000;
    parameter and_instruction = 6'b100100;
    parameter div = 6'b011010;
    parameter mult = 6'b011000;
    parameter jr = 6'b001000;
    parameter mfhi = 6'b010000;
    parameter mflo = 6'b010010;
    parameter sll = 6'b000000;
    parameter sllv = 6'b000100;
    parameter slt = 6'b101010;
    parameter sra = 6'b000011;
    parameter srav = 6'b000111;
    parameter srl = 6'b000010;
    parameter sub = 6'b100010;
    parameter break = 6'b001101;
    parameter rte = 6'b010011;
    parameter divm = 6'b000101;

    // Opcode das instruções
    parameter addi = 6'b001000;
    parameter addiu = 6'b001001;
    parameter beq = 6'b000100;
    parameter bne = 6'b000101;
    parameter ble = 6'b000110;
    parameter bgt = 6'b000111;
    parameter sram = 6'b000001;
    parameter lb = 6'b100000;
    parameter lh = 6'b100001;
    parameter lui = 6'b001111;
    parameter lw = 6'b100011;
    parameter sb = 6'b101000;
    parameter sh = 6'b101001;
    parameter slti = 6'b001010;
    parameter sw = 6'b101011;
    
    //instruções J (opCode)
    parameter j = 6'b000010;
    parameter jal = 6'b000011;

    reg [6:0] state;
    reg [5:0] counter;
    reg debug;

    initial begin
        reset_out = 1'b1; //Reset inicial da CPU
    end

    always @(posedge clk) begin
        if (reset == 1'b1) begin
            if (state != state_reset) begin
                state = state_reset;
                //Reseting output wires
                pc_write = 1'b0;
                mem_write = 1'b0;
                mdr_write = 1'b0;
                ir_write = 1'b0;
                reg_write = 1'b1; ///
                a_write = 1'b0;
                b_write = 1'b0;
                ula_reg_write = 1'b0;
                epc_write = 1'b0;
                lo_write = 1'b0;
                hi_write = 1'b0;
                store_size = 2'b00;
                load_size = 2'b00;
                shift = 3'b000;
                aluOp = 3'b000;
                muxA = 4'b0000;
                muxB = 3'b010;   ///
                muxC = 4'b1000;  ///
                muxD = 1'b0;
                muxE = 2'b00;
                muxF = 3'b000;
                muxG = 1'b0;
                muxH = 1'b0;
                muxIJ = 1'b0;
                muxK = 2'b00;
                muxL = 3'b000;
                flag_start_div = 1'b0;
                sinalStartMult = 1'b0;
                reset_out = 1'b1; //Garante que o reset continue mesmo que o botão seja solto
                counter = 6'b000000;
            end
            else begin
                pc_write = 1'b0;
                mem_write = 1'b0;
                mdr_write = 1'b0;
                ir_write = 1'b0;
                reg_write = 1'b1; ///
                a_write = 1'b0;
                b_write = 1'b0;
                ula_reg_write = 1'b0;
                epc_write = 1'b0;
                lo_write = 1'b0;
                hi_write = 1'b0;
                store_size = 1'b0;
                load_size = 2'b00;
                shift = 3'b000;
                aluOp = 3'b000;
                muxA = 4'b0000;
                muxB = 3'b010;   ///
                muxC = 4'b1000;  ///
                muxD = 1'b0;
                muxE = 2'b00;
                muxF = 3'b000;
                muxG = 1'b0;
                muxH = 1'b0;
                muxIJ = 1'b0;
                muxK = 2'b00;
                muxL = 3'b000;
                flag_start_div = 1'b0;
                sinalStartMult = 1'b0;
                counter = 6'b000000; //
                reset_out = 1'b0;
                state = state_fetch;
            end
        end
        else begin
            case (state)
                state_fetch: begin
                    if (counter == 6'b000000) begin
                        // Desfaz os sinas do reset                        
                        counter = 6'b000000;
                        muxB = 3'b000;
                        muxC = 4'b0000;
                        reg_write = 1'b0;
                        // Fetch
                        muxA = 0;
                        mem_write = 0;
                        muxD = 0;
                        muxE = 1;
                        muxF = 0;
                        aluOp = 3'b001;
                        counter = counter + 1;
                    end
                    else begin
                        state = state_fetch_write;
                        counter = 0;
                    end
                end
                state_fetch_write: begin
                    if (counter == 6'b000000) begin
                        pc_write = 1;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 6'b000000;
                        pc_write = 1'b0;
                        state = state_decode;
                    end
                end
                state_decode: begin
                    if (counter == 6'b000000) begin
                        ir_write = 1;
                        reg_write = 0;
                        muxG = 0;
                        muxH = 0;
                        pc_write = 0;
                        muxD = 0;
                        muxE = 2'b11;
                        aluOp = 3'b001;
                        muxF = 3'b000;
                        counter = 6'b000010; // Usado para poder fazer o contador final do decode ser 1
                    end
                    else if(counter == 6'b000010) begin
                        ir_write = 0; 
                        ula_reg_write = 1;
                        counter = 6'b000011;
                    end
                    else if(counter == 6'b000011) begin // Escrever em A e B
                        a_write = 1'b1;
                        b_write = 1'b1;
                        ula_reg_write = 0; 
                        counter = 6'b000100;
                    end
                    else if(counter == 6'b000100) begin
                        a_write = 1'b0;
                        b_write = 1'b0;
                        counter = 6'b000001;
                    end
                    else begin
                        //counter entra como 1
                        ir_write = 0;   //Nao escrever no banco durante o decode
                        case (opcode)
                            0:
                                case (funct)
                                    add:
                                        state = state_add;
                                    sub:
                                        state = state_sub;
                                    and_instruction:
                                        state = state_and;
                                    slt:
                                        state = state_slt;
                                    mfhi:
                                        state = state_mfhi;
                                    mflo:
                                        state = state_mflo;
                                    jr:
                                        state = state_jr;
                                    rte:
                                        state = state_rte;
                                    break:
                                        state = state_break;
                                    sll:
                                        state = state_sll;
                                    srl:
                                        state = state_srl;
                                    sra:
                                        state = state_sra;
                                    sllv:
                                        state = state_sllv;
                                    srav:
                                        state = state_srav;
                                    div:
                                        state = state_div;
                                    mult:
                                        state = state_mult;
                                    divm: 
                                        state = state_divm_read_rs;
                                endcase
                            addi:
                                state = state_addi;
                            addiu:
                                state = state_addiu;
                            beq:
                                state = state_branch;
                            bne:
                                state = state_branch;
                            bgt:
                                state = state_branch;
                            ble:
                                state = state_branch;
                            lui:
                                state = state_lui_sll;
                            slti:
                                state = state_slti;
                            j:
                                state = state_j;
                            jal:
                                state = state_jal;
                            lw:
                                state = state_sum_offset_rs;
                            lh:
                                state = state_sum_offset_rs;
                            lb:
                                state = state_sum_offset_rs;
                            sw:
                                state = state_sum_offset_rs;
                            sh:
                                state = state_sum_offset_rs;
                            sb:
                                state = state_sum_offset_rs;
                            sram:
                                state = state_sum_offset_rs;
                            default:
                                // debug = 1'b1;
                                state = state_opcode_inexistente_1;
                        endcase
                    end
                end
                state_addi:
                    if(counter == 6'b000001) begin
                        a_write = 1'b1;
                        b_write = 1'b1;
                        muxD = 1'b1;
                        muxE = 2'b10;
                        aluOp = 3'b001;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        if (Overflow == 1'b0) begin
                            state = state_rt_write;
                        end
                        else begin
                            state = state_overflow_1;
                        end                    
                    end
                state_addiu:
                    if(counter == 6'b000001) begin
                        a_write = 1'b1;
                        b_write = 1'b1;
                        muxD = 1'b1;
                        muxE = 2'b10;
                        aluOp = 3'b001;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        state = state_rt_write;
                    end                    
                state_add:
                    if(counter == 6'b000001) begin
                        muxD = 1'b1;
                        muxE = 2'b00;
                        aluOp = 3'b001;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        if (Overflow == 1'b0) begin
                            state = state_rd_write;
                        end
                        else begin
                            state = state_overflow_1;
                        end
                    end
                state_sub:
                    if(counter == 6'b000001) begin
                        muxD = 1'b1;
                        muxE = 2'b00;
                        aluOp = 3'b010;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        if (Overflow == 1'b0) begin
                            state = state_rd_write;
                        end
                        else begin
                            state = state_overflow_1;
                        end                    
                    end
                state_and:
                    if(counter == 6'b000001) begin
                        muxD = 1'b1;
                        muxE = 2'b00;
                        aluOp = 3'b011;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        state = state_rd_write;
                    end
                state_rt_write: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        muxB = 3'b000;
                        muxC = 4'b0100;
                        reg_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end 
                state_rd_write: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        muxB = 3'b001;
                        muxC = 4'b0100;
                        reg_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 1'b0;
                        state = state_fetch;
                    end
                end
                state_slt:begin
                    if(counter == 6'b000001)begin
                        muxD = 1'b1;
                        muxE = 2'b00;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        aluOp = 3'b111;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        state = state_rd_write_slt;
                    end
                end
                state_rd_write_slt:begin
                    if (counter == 6'b000000 || counter == 6'b000001)begin
                        muxB = 3'b001;
                        muxC = 4'b1001;
                        reg_write = 1'b1; 
                        counter = counter + 1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 1'b0;
                        state = state_fetch;
                    end
                end
                state_mfhi:begin
                    if(counter == 6'b000001)begin
                        muxB = 3'b001;
                        muxC = 4'b0101;
                        reg_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        reg_write =1'b0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_mflo: begin
                    if(counter == 6'b000001) begin
                        muxB = 3'b001;
                        muxC = 4'b0110;
                        reg_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        reg_write =1'b0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end       
                state_jr: begin
                    if(counter == 6'b000001) begin
                        reg_write = 1'b0; //
                        muxG = 1'b0; //
                        muxF = 3'b100;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        counter = counter + 1;
                    end
                    else if(counter == 6'b000010) begin //
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
                state_rte: begin
                    if(counter == 6'b000001) begin
                        muxF = 3'b010;
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
                state_break: begin
                    if(counter == 6'b000001) begin
                        a_write = 1'b1;
                        b_write = 1'b1;
                        muxD = 1'b0;
                        muxE = 3'b001;
                        aluOp = 3'b010;
                        counter = counter + 1;
                    end
                    else begin
                        a_write = 1'b0;
                        b_write = 1'b0;
                        counter = 6'b000000; // 
                        state = state_break_write;
                    end
                end
                state_break_write: begin
                    if(counter == 6'b000000) begin // 3 Ciclos estavam reaizando duas subtrações
                        muxF = 3'b000;
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        counter = 6'b000000; // Reseta o counter para o fetch
                        state = state_fetch;    
                    end
                end
                state_sll: begin
                    muxK  = 2'b00;
                    muxL  = 3'b011;
                    shift = 3'b001;
                    state = state_sll_shift;
                end
                state_sll_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b010;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_shift_write;
                        shift = 3'b000;
                    end
                end
                state_sra: begin
                    muxK  = 2'b00;
                    muxL  = 3'b011;
                    shift = 3'b001;
                    state = state_sra_shift;
                end
                state_sra_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b100;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_shift_write;
                        shift = 3'b000;
                    end
                end
                state_srl: begin
                    muxK  = 2'b00;
                    muxL  = 3'b011;
                    shift = 3'b001;
                    state = state_srl_shift;
                end
                state_srl_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b011;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_shift_write;
                        shift = 3'b000;
                    end
                end
                state_sllv: begin
                    muxK  = 2'b10;
                    muxL  = 3'b000;
                    shift = 3'b001;
                    state = state_sllv_shift;
                end
                state_sllv_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b010;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_shift_write;
                        shift = 3'b000;
                    end
                end
                state_srav: begin
                    muxK  = 2'b10;
                    muxL  = 3'b000;
                    shift = 3'b001;
                    state = state_srav_shift;
                end
                state_srav_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b100;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_shift_write;
                        shift = 3'b000;
                    end
                end
                state_shift_write: begin
                    muxC = 4'b0011;
                    muxB = 3'b001;
                    reg_write = 1'b1;
                    counter = 6'b000000;
                    state = state_fetch;
                end
                state_lui_sll: begin
                    muxK  = 2'b01;
                    muxL  = 3'b001;
                    shift = 3'b001;
                    state = state_lui_shift;
                end
                state_lui_shift: begin
                    if (counter != 6'b000010) begin // 2 ciclos
                        shift = 3'b010;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_lui_write;
                        shift = 3'b000;
                    end
                end
                state_lui_write: begin
                    muxC = 4'b0011;
                    muxB = 3'b000;
                    reg_write = 1'b1;
                    counter = 6'b000000;
                    state = state_fetch;
                end
                state_slti: begin
                    if(counter == 6'b000001)begin
                        muxD = 1'b1;
                        muxE = 2'b10;
                        a_write = 1'b1;
                        b_write = 1'b1;
                        aluOp = 3'b111;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        a_write = 1'b0;
                        b_write = 1'b0;
                        state = state_slti_write;
                    end
                end
                state_slti_write: begin
                if (counter == 6'b000000 || counter == 6'b000001)begin
                        muxB = 3'b000;
                        muxC = 4'b1001;
                        reg_write = 1'b1; 
                        counter = counter + 1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 1'b0;
                        state = state_fetch;
                    end
                end
                //########## Divisão ##########
                //verificar quantidade de ciclos
                state_div: begin
                    // || counter == 6'b000010 
                    if(counter == 6'b000001) begin
                        if(rt == 32'b00000000000000000000000000000000) begin
                            state = state_divisao_por_0_1; //fazer estado
                        end
                        else begin
                            flag_start_div = 1;
                            counter = counter + 1;
                        end                                   
                    end
                    else begin
                        counter = 0;
                        flag_start_div = 0;
                        state = state_flag_div;
                    end
                end
                state_flag_div: begin  
                    if (counter < 6'b100000 && stopDiv == 1'b1) begin // sinal div
                        state = state_flag_div_write;
                        counter = 0;                    
                    end
                    else begin
                        counter = counter + 1;
                    end                                   
                end
                state_flag_div_write: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        muxIJ = 1'b0; //saida hi e lo div
                        hi_write = 1;
                        lo_write = 1;
                        counter = counter + 1;
                    end
                    else begin
                        hi_write = 0;
                        lo_write = 0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end              
                //###################################################################
                //########## Multiplicão ##########
                state_mult: begin
                    if(counter == 6'b000001) begin
                        sinalStartMult = 1;
                        counter = counter + 1;                                                 
                    end
                    else begin
                        counter = 0;
                        sinalStartMult = 0;
                        state = state_flag_mult;
                    end
                end
                state_flag_mult: begin
                    if (counter > 6'b000000 && stopMult == 1'b1) begin // sinal div
                        state = state_mult_write;
                        counter = 0;
                    end
                    else begin
                        counter = counter + 1;
                    end                  
                end
                state_mult_write: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        muxIJ = 1'b1; //saida '1' hi e lo mult
                        hi_write = 1;
                        lo_write = 1;
                        counter = counter + 1;
                    end
                    else begin
                        hi_write = 0;
                        lo_write = 0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
                //###################################################################
                state_j: begin
                    if(counter == 6'b000001) begin
                        muxF = 3'b011;
                        pc_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        counter = 6'b000000;
                        pc_write = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_jal: begin
                    if(counter == 6'b000001)begin
                        muxB = 3'b011;
                        muxD = 1'b0;
                        aluOp = 3'b000;
                        muxC = 4'b0100;
                        reg_write = 1'b1;
                        counter = counter +1'b1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 6'b000001;
                        state = state_j;
                    end
                end
                state_branch: begin
                    if(counter == 6'b000001) begin
                        muxG = 1'b0;
                        muxH = 1'b0;
                        muxD = 1'b1;
                        muxE = 2'b00;
                        aluOp = 3'b111;
                        counter = counter + 1'b1;
                    end
                    else if (counter == 6'b000010) begin
                        if(Eq == 1'b1 && opcode == 6'b000100) begin
                            counter = 6'b000001;
                            state = state_branch_write;
                        end
                        else if(Gt == 1'b1 && opcode == 6'b000111) begin
                            counter = 6'b000001;
                            state = state_branch_write;
                        end
                        else if((Eq == 1'b1 || Lt == 1'b1) && opcode == 6'b000110) begin
                            counter = 6'b000001;
                            state = state_branch_write;
                        end
                        else if(Eq == 1'b0 && opcode == 6'b000101) begin
                            counter = 6'b000001;
                            state = state_branch_write;
                        end
                        else begin
                            counter = 6'b000000;
                            state = state_fetch;                          
                        end
                    end
                end
                state_branch_write: begin
                    if(counter == 6'b000001) begin
                        muxF = 3'b001;
                        aluOp = 3'b000;
                        pc_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        pc_write = 1'b0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_sum_offset_rs: begin
                    if(counter == 6'b000001)begin
                        muxD = 1'b1;
                        muxE = 2'b10;
                        muxA = 4'b0001;
                        aluOp = 3'b001;
                        counter = counter + 1'b1;
                    end
                    else begin
                        // Direciona para estado correto
                        if(opcode == lw || opcode == lh || opcode == lb) begin
                            state = state_load_mdr_write;
                        end
                        else if(opcode == sw) begin
                            state = state_sw;
                        end
                        else if(opcode == sram) begin
                            state = state_read_word;
                        end
                        else begin
                            state = state_mem_read_word;
                        end
                    end
                end
                state_load_mdr_write: begin
                    if(counter == 6'b000010) begin
                        mdr_write = 1'b1;
                        aluOp = 3'b000;
                        counter = counter + 1'b1;
                    end
                    else  begin
                        case (opcode)
                            lw: state = state_lw;
                            lh: state = state_lh;
                            lb: state = state_lb;
                        endcase
                    end
                end
                state_lw: begin
                    load_size = 2'b00;
                    mdr_write = 1'b0;
                    state = state_load_rt_write;
                end
                state_lh: begin
                    load_size = 2'b10;
                    mdr_write = 1'b0;
                    state = state_load_rt_write;
                end
                state_lb: begin
                    load_size = 2'b1;
                    mdr_write = 1'b0;
                    state = state_load_rt_write;
                end
                state_load_rt_write: begin
                    if(counter == 6'b000011) begin
                        muxC = 4'b0010;
                        muxB = 3'b000;
                        reg_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_sw: begin
                    if(counter == 6'b000010 || counter == 6'b000011) begin
                        store_size = 2'b00;
                        mem_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        mdr_write = 1'b0;
                        mem_write = 1'b0;
                        counter  = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_mem_read_word: begin
                    if (counter != 6'b000100) begin
                        muxA = 4'b0001;
                        mem_write = 1'b0;
                        mdr_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        if (opcode == sh) begin
                            state = state_sh;
                        end
                        else begin
                            state = state_sb;
                        end
                    end
                end
                state_sh: begin
                    if(counter == 6'b000100 || counter == 6'b000101) begin
                        store_size = 2'b10;
                        mem_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        mem_write = 1'b0;
                        counter  = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_sb: begin
                    if(counter == 6'b000100 || counter == 6'b000101) begin
                        store_size = 2'b01;
                        mem_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        mem_write = 1'b0;
                        counter  = 6'b000000;
                        state = state_fetch;
                    end
                end
                state_read_word: begin
                    if(counter == 6'b000001) begin
                        muxA = 4'b0000;
                        ir_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        ir_write = 1'b0;
                        counter = 6'b000001;
                        state = state_sram;
                    end
                end
                state_sram: begin
                    if(counter == 6'b000001) begin
                        mdr_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else if(counter == 6'b000010) begin
                        mdr_write = 1'b0;
                        muxA = 4'b0000;
                        muxK = 2'b00;
                        muxL = 3'b010;
                        shift = 3'b001;
                        counter = counter + 1'b1;
                    end
                    else begin
                        counter = 6'b000001;
                        state = state_sram_shift;
                    end
                end
                state_sram_shift: begin
                    if(counter == 6'b000001) begin
                        shift = 3'b100;
                        counter = counter + 1'b1;
                    end
                    else begin
                        shift = 3'b000;
                        counter = 6'b000001;
                        state = state_sram_write;
                    end
                end
                state_sram_write: begin
                    if (counter == 6'b000001) begin
                        muxB = 3'b000;
                        muxC = 4'b0011;
                        reg_write = 1'b1;
                        counter = counter + 1'b1;
                    end
                    else begin
                        reg_write = 1'b0;
                        counter = 6'b000000;
                        state = state_fetch;
                    end
                end
                //############ DIVM ###############
                state_divm_read_rs: begin
                    if(counter == 6'b000001) begin
                        muxA = 4'b0101;
                        mem_write = 0;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        state = state_divm_mdr_write_rs;
                    end
                end
                state_divm_mdr_write_rs: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        mdr_write = 1'b1;
                        mem_write = 0;
                        muxG = 1'b1;
                        a_write = 1;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        mdr_write = 1'b0;
                        mem_write = 0;
                        a_write = 0;
                        state = state_divm_read_rt;
                    end
                end
                state_divm_read_rt: begin
                    if (counter == 6'b000000 || counter == 6'b000001) begin
                        muxA = 4'b0110;
                        mem_write = 0;
                        counter = counter + 1;
                    end
                    else begin
                        counter = 0;
                        state = state_divm_mdr_write_rt;
                    end
                end
                state_divm_mdr_write_rt: begin
                    if (counter != 6'b000011) begin
                        mem_write = 0;
                        mdr_write = 1'b1;
                        muxH = 1'b1;
                        b_write = 1;
                        counter = counter + 1;
                    end
                    else begin
                        mdr_write = 1'b0;
                        counter = 6'b000001;
                        mem_write = 0;
                        b_write = 0;
                        state = state_div; //o estado de Div leva ao State_fecth
                    end
                end
                //#####################################################################
                state_overflow_1: begin
                    muxD = 1'b0;
                    muxE = 2'b01;
                    aluOp = 3'b010;
                    epc_write = 1'b1;
                    muxA = 4'b0011;
                    counter = 6'b000000;
                    state = state_overflow_2;
                end
                state_overflow_2: begin
                    if (counter == 6'b000000) begin
                        muxA = 4'b0011;
                        mem_write = 1'b0;
                        epc_write = 1'b0;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_overflow_3;
                    end
                end
                state_overflow_3: begin
                    if(counter != 6'b000100)begin
                        mdr_write = 1'b1;
                        load_size = 2'b11;
                        muxF = 3'b101;
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
                state_opcode_inexistente_1: begin
                    muxD = 1'b0;
                    muxE = 2'b01;
                    aluOp = 3'b010;
                    epc_write = 1'b1;
                    muxA = 4'b0010;
                    counter = 6'b000000;
                    state = state_opcode_inexistente_2;
                end
                state_opcode_inexistente_2: begin
                    if (counter == 6'b000000) begin
                        muxA = 4'b0010;
                        mem_write = 1'b0;
                        epc_write = 1'b0;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_opcode_inexistente_3;
                    end
                end
                state_opcode_inexistente_3: begin
                    if(counter != 6'b000100)begin
                        mdr_write = 1'b1;
                        load_size = 2'b11;
                        muxF = 3'b101;
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
                state_divisao_por_0_1: begin
                    muxD = 1'b0;
                    muxE = 2'b01;
                    aluOp = 3'b010;
                    epc_write = 1'b1;
                    muxA = 4'b0100;
                    counter = 6'b000000;
                    state = state_divisao_por_0_2;
                end
                state_divisao_por_0_2: begin
                    if (counter == 6'b000000) begin
                        muxA = 4'b0100;
                        mem_write = 1'b0;
                        epc_write = 1'b0;
                        counter = counter + 1'b1;
                    end
                    else begin
                        state = state_divisao_por_0_3;
                    end
                end
                state_divisao_por_0_3: begin
                    if(counter != 6'b000100)begin
                        mdr_write = 1'b1;
                        load_size = 2'b11;
                        muxF = 3'b101;
                        pc_write = 1'b1;
                        counter = counter + 1;
                    end
                    else begin
                        pc_write = 1'b0;
                        state = state_fetch;
                        counter = 6'b000000;
                    end
                end
            endcase
        end
    end
endmodule