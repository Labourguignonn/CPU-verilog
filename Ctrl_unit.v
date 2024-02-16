module unit_control(
    input wire clk,
    input wire reset,

    input wire [31:26] OPCODE,
    input wire [5:0] OFFSET,
    
    output reg PC_write,
    output reg MEM_write, // checar - ok!
    output reg IR_write,
    output reg Regwrite,
    output reg A_write,
    output reg B_write,
    output reg ALUOutCtrl, 

    output reg [2:0] Alu_control,

    output reg aluSourceA_control,
    output reg [1:0] aluSourceB_control,
    output reg HIWrite,
    output reg LOWrite,
    output reg [1:0] mux_toRegs_control, // checar - ok!
    output reg [3:0] srcData_control, // checar - ok!
    output reg [2:0] pcSource_control, // checar - ok!
    output reg [1:0] mux_IorD_control,
    output reg [1:0] controlSS,
    output reg MDR_Write, // checar - ok!
    output reg ShiftAmt,
    output reg ShiftSrc,
    output reg [2:0] ShiftControl,
    
    input wire Eq,
    input wire Gt,
    input wire Overflow,
    input wire Ng,
    input wire Zr,
    input wire Lt,




    output reg [1:0] ExceptionControl,
    output reg [1:0] ExceptionControl2,
    output reg EPC_Write,

    output reg [1:0] LScontrol, // agora tem!
    output reg div_Control,

    output reg change_reset
);

// estado, opcode, funct
reg [6:0] estado;
reg [2:0] counter;
reg [5:0] div_counter;

//STATES
parameter FETCH_DECODE_ST = 7'b0000000;
parameter ADD_ST = 7'b0000101;
parameter ADDI_ST = 7'b0000110;
parameter SUB_ST = 7'b0000111;
parameter AND_ST = 7'b0001000;
parameter SLL_ST = 7'b0001001;
parameter SLT_ST = 7'b0001010;
parameter SRA_ST = 7'b0001011;
parameter SRL_ST = 7'b0001100;
parameter SLLV_ST = 7'b0001101;
parameter SRAV_ST = 7'b0001110;
parameter SLTI_ST = 7'b0001111;
parameter RESET_ST = 7'b1111111;
parameter J_ST = 7'b0101001;
parameter JAL_ST = 7'b0111101;
parameter JR_ST = 7'b0111001;
parameter BEQ_ST = 7'b0010000;
parameter BNE_ST = 7'b0010001;
parameter MFHI_ST = 7'b0011001;
parameter MFLO_ST = 7'b0011101;
parameter BREAK_ST = 7'b1000000;
parameter LUI_ST = 7'b1011101;
parameter BLE_ST = 7'b0010010;
parameter BGT_ST = 7'b0010011;
parameter ADDIU_ST = 7'b0010100;
parameter LOADS_ST = 7'b0110001;
parameter LW_ST = 7'b1011001;
parameter LH_ST = 7'b1001001;
parameter LB_ST = 7'b1001011;
parameter STORES_ST = 7'b0110011;
parameter SW_ST = 7'b1111001;
parameter SH_ST = 7'b1101001;
parameter SB_ST = 7'b1101011;
parameter OVERFLOW_ST = 7'b0010101;
parameter RTE_ST = 7'b0010110;
parameter DIV_ST = 7'b0110100;

//OPCODE
parameter R = 6'b000000; //instruções tipo R possuem opcode 000000
parameter ADDI_OP = 6'b001000;
parameter ADDIU_OP = 6'b001001;
parameter BEQ_OP = 6'b000100;
parameter BNE_OP = 6'b000101;
parameter BLE_OP = 6'b000110;
parameter BGT_OP = 6'b000111;
parameter ADDM_OP = 6'b000001; // checar
parameter LB_OP = 6'b100000;
parameter LH_OP = 6'b100001;
parameter LUI_OP = 6'b001111;
parameter LW_OP = 6'b100011;
parameter SB_OP = 6'b101000;
parameter SH_OP = 6'b101001;
parameter SLTI_OP = 6'b001010;
parameter SW_OP = 6'b101011;

parameter J_OP = 6'b000010;
parameter JAL_OP = 6'b000011;
//parameter RESET_OP = 6'b111111;

//FUNCT (FORMATO R) 
parameter ADD_FUNCT = 6'b100000;
parameter AND_FUNCT = 6'b100100;
parameter DIV_FUNCT = 6'b011010; // checar
parameter MULT_FUNCT = 6'b011000; // checar
parameter JR_FUNCT = 6'b001000;
parameter MFHI_FUNCT = 6'b010000;
parameter MFLO_FUNCT = 6'b010010;
parameter SLL_FUNCT = 6'b000000;
parameter SLLV_FUNCT = 6'b000100;
parameter SLT_FUNCT = 6'b101010;
parameter SRA_FUNCT = 6'b000011;
parameter SRAV_FUNCT = 6'b000111;
parameter SRL_FUNCT = 6'b000010;
parameter SUB_FUNCT = 6'b100010;
parameter BREAK_FUNCT = 6'b001101;
parameter RTE_FUNCT = 6'b010011;
parameter DIVM_FUNCT = 6'b000101;

initial begin
    change_reset = 1'b1;
end

always @(posedge clk) begin
    if (reset == 1'b1) begin
        if (estado  != RESET_ST) begin
            estado = RESET_ST;

            PC_write = 1'b0;
            MEM_write = 1'b0;
            IR_write = 1'b0;
            Regwrite = 1'b0;
            A_write = 1'b0;
            B_write = 1'b0;
            Alu_control = 3'b000;
            ALUOutCtrl = 1'b0;
            aluSourceA_control = 1'b0;
            aluSourceB_control = 2'b00;
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            mux_toRegs_control = 2'b00;
            srcData_control = 4'b0000;
            pcSource_control = 3'b000;
            mux_IorD_control = 2'b00;
            controlSS = 2'b00;
            LScontrol = 2'b00;
            MDR_Write = 1'b0;
            ShiftAmt = 1'b0;
            ShiftSrc = 1'b0;
            ShiftControl = 3'b000;
            ExceptionControl = 2'b00;
            ExceptionControl2 = 2'b00;
            EPC_Write = 1'b0;
            div_Control = 1'b0;
            change_reset = 1'b1;  //

            counter = 3'b000;
            div_counter = 6'b000000;
        end
        else begin
            estado = FETCH_DECODE_ST;

            PC_write = 1'b0;
            MEM_write = 1'b0;
            IR_write = 1'b0;
            Regwrite = 1'b0;
            A_write = 1'b0;
            B_write = 1'b0;
            Alu_control = 3'b000;
            ALUOutCtrl = 1'b0;
            aluSourceA_control = 1'b0;
            aluSourceB_control = 2'b00;
            HIWrite = 1'b0;
            LOWrite = 1'b0;
            mux_toRegs_control = 2'b00;
            srcData_control = 4'b0000;
            pcSource_control = 3'b000;
            mux_IorD_control = 2'b00;
            controlSS = 2'b00;
            LScontrol = 2'b00;
            MDR_Write = 1'b0;
            ShiftAmt = 1'b0;
            ShiftSrc = 1'b0;
            ShiftControl = 3'b000;
            ExceptionControl = 2'b00;
            ExceptionControl2 = 2'b00;
            EPC_Write = 1'b0;
            div_Control = 1'b0;
            change_reset = 1'b0;  //

            counter = 3'b000;
            div_counter = 6'b000000;

        end
    end
    else begin
        case (estado)
            FETCH_DECODE_ST: begin
                if (counter == 3'b000 || counter == 3'b001 || counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;      //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;  //
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;       //
                    aluSourceB_control = 2'b01;      //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    div_Control = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b011) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b1;       //
                    MEM_write = 1'b0;
                    IR_write = 1'b1;       //
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b01;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b100) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;       //
                    MEM_write = 1'b0;
                    IR_write = 1'b0;       //
                    Regwrite = 1'b0;       //
                    A_write = 1'b1;        //
                    B_write = 1'b1;        //
                    Alu_control = 3'b001;  //
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b11;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b101) begin
                    case (OPCODE)
                        R: begin
                            case (OFFSET)
                                ADD_FUNCT: begin
                                    estado = ADD_ST;
                                end

                                SUB_FUNCT: begin
                                    estado = SUB_ST;
                                end

                                AND_FUNCT: begin
                                    estado = AND_ST;
                                end

                                SLL_FUNCT: begin
                                    estado = SLL_ST;
                                end

                                SLT_FUNCT: begin
                                    estado = SLT_ST;
                                end

                                SRA_FUNCT: begin
                                    estado = SRA_ST;
                                end

                                SRL_FUNCT: begin
                                    estado = SRL_ST;
                                end

                                SLLV_FUNCT: begin
                                    estado = SLLV_ST;
                                end

                                SRAV_FUNCT: begin
                                    estado = SRAV_ST;
                                end

                                JR_FUNCT: begin
                                    estado = JR_ST;
                                end

                                MFHI_FUNCT: begin
                                    estado = MFHI_ST;
                                end

                                MFLO_FUNCT: begin
                                    estado = MFLO_ST;
                                end

                                BREAK_FUNCT: begin
                                    estado = BREAK_ST;
                                end

                                RTE_FUNCT: begin
                                    estado = RTE_ST;
                                end

                                DIV_FUNCT: begin
                                    estado = DIV_ST;
                                end

                            endcase
                        end


                        ADDI_OP: begin
                            estado = ADDI_ST;
                        end

                        ADDIU_OP: begin
                            estado = ADDIU_ST;
                        end

                        J_OP: begin
                            estado = J_ST;
                        end

                        JAL_OP: begin
                            estado = JAL_ST;
                        end

                        SLTI_OP: begin
                            estado = SLTI_ST;
                        end

                        BEQ_OP: begin
                            estado = BEQ_ST;
                        end

                        BNE_OP: begin
                            estado = BNE_ST;
                        end

                        BLE_OP: begin
                            estado = BLE_ST;
                        end

                        BGT_OP: begin
                            estado = BGT_ST;
                        end

                        LUI_OP: begin
                            estado = LUI_ST;
                        end

                        LW_OP: begin
                            estado = LOADS_ST;
                        end

                        LH_OP: begin
                            estado = LOADS_ST;
                        end

                        LB_OP: begin
                            estado = LOADS_ST;
                        end

                        SW_OP: begin
                            estado = STORES_ST;
                        end

                        SH_OP: begin
                            estado = STORES_ST;
                        end

                        SB_OP: begin
                            estado = STORES_ST;
                        end
                        

                    endcase

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;      
                    Regwrite = 1'b0;       
                    A_write = 1'b0;        
                    B_write = 1'b0;       
                    Alu_control = 3'b000;  
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            ADD_ST: begin
                if (counter == 3'b000) begin
                    estado = ADD_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1; 
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        estado = OVERFLOW_ST;
                    end else begin
                        estado = FETCH_DECODE_ST;   
                    end

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            RESET_ST: begin
                if (counter == 3'b000) begin
                    estado = RESET_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b1;

                    counter = 3'b000;
                end
            end

            ADDI_ST: begin
                if (counter == 3'b000) begin
                    estado = ADDI_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b10;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        estado = OVERFLOW_ST;
                    end else begin
                        estado = FETCH_DECODE_ST;   
                    end

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            ADDIU_ST: begin
                if (counter == 3'b000) begin
                    estado = ADDIU_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b10;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SUB_ST: begin
                if (counter == 3'b000) begin
                    estado = SUB_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b010;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    if (Overflow) begin
                        estado = OVERFLOW_ST;
                    end else begin
                        estado = FETCH_DECODE_ST;   
                    end

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b010;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            AND_ST: begin
                if (counter == 3'b000) begin
                    estado = AND_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b011;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b011;
                    ALUOutCtrl = 1'b1;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SLL_ST: begin
                if (counter == 3'b000) begin
                    estado = SLL_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b1;
                    ShiftSrc = 1'b1;
                    ShiftControl = 3'b001;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    estado = SLL_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0010;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end

            end

            SLT_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b1;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b111;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b1;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b01;
                srcData_control = 4'b0001;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            SRA_ST: begin
                if (counter == 3'b000) begin
                    estado = SRA_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b1;
                    ShiftSrc = 1'b1;
                    ShiftControl = 3'b001;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    estado = SRA_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b100;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0010;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SRL_ST: begin
                if (counter == 3'b000) begin
                    estado = SRL_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b1;
                    ShiftSrc = 1'b1;
                    ShiftControl = 3'b001;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    estado = SRL_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b011;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0010;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SLLV_ST: begin
                if (counter == 3'b000) begin
                    estado = SLLV_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b001;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    estado = SLLV_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0010;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SRAV_ST: begin
                if (counter == 3'b000) begin
                    estado = SRAV_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b001;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b001) begin
                    estado = SRAV_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b1000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b100;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end

                else if (counter == 3'b010) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b01;
                    srcData_control = 4'b0010;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b010;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            SLTI_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b1;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b111;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b1;
                aluSourceB_control = 2'b10;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0001;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            J_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b1;              //
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b001;          //
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            JAL_ST: begin
                if (counter == 3'b000) begin
                    estado = JAL_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b1;     //
                    aluSourceA_control = 1'b0;   //
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (3'b001) begin
                    estado = FETCH_DECODE_ST;    //

                    PC_write = 1'b1;    //
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1;      //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0; 
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b10;    //
                    srcData_control = 4'b0000; //
                    pcSource_control = 3'b001;     //
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;  //
                end
            end

            JR_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b1;              //
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;                 //
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b1;           //
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b000;          //
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            BEQ_ST: begin
                if (counter == 3'b000) begin
                    estado = BEQ_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;

                    if (Eq == 1'b1) begin
                        PC_write = 1'b1;
                    end

                    else if (Eq == 1'b0) begin
                        PC_write = 1'b0;
                    end
                end
            end

            BNE_ST: begin
                if (counter == 3'b000) begin
                    estado = BNE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;

                    if (Eq == 1'b0) begin
                        PC_write = 1'b1;
                    end

                    else if (Eq == 1'b1) begin
                        PC_write = 1'b0;
                    end
                end
            end

            BLE_ST: begin
                if (counter == 3'b000) begin
                    estado = BLE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;

                    if (Gt == 1'b0) begin
                        PC_write = 1'b1;
                    end

                    else if (Gt == 1'b1) begin
                        PC_write = 1'b0;
                    end
                end
            end

            BGT_ST: begin
                if (counter == 3'b000) begin
                    estado = BGT_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b111;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1;
                    aluSourceB_control = 2'b00;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b010;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;

                    if (Gt == 1'b1) begin
                        PC_write = 1'b1;
                    end

                    else if (Gt == 1'b0) begin
                        PC_write = 1'b0;
                    end
                end
            end

            MFHI_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b1; //
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b01; //
                srcData_control = 4'b0011; //
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            MFLO_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b1; //
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b01; //
                srcData_control = 4'b0100; //
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            BREAK_ST: begin
                if (counter == 3'b000) begin
                    estado = BREAK_ST;

                    PC_write = 1'b1; //
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b010; //
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b01; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = BREAK_ST;

                    PC_write = 1'b0; //
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000; //
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                end
            end

            LUI_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;  
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b1; //
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;  
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00; //
                srcData_control = 4'b0101; //
                pcSource_control = 3'b000; 
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
            end

            LOADS_ST: begin
                // clk 1
                if (counter == 3'b000) begin
                    estado = LOADS_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001; // ADD
                    ALUOutCtrl = 1'b1; // 
                    aluSourceA_control = 1'b1; //
                    aluSourceB_control = 2'b10; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                // clk 2 - wait 1
                else if (counter == 3'b001) begin

                    estado = LOADS_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0; 
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b1; //
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;

                end
                // clk 3 - wait 2
                else if (counter == 3'b010) begin
                    case(OPCODE)
                        LW_OP : begin
                            estado = LW_ST;
                        end
                        LH_OP: begin
                            estado = LH_ST;
                        end
                        LB_OP: begin
                            estado = LB_ST;
                        end
                    endcase

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0; 
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b1; //
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;
                    
                    counter = 3'b000;
                end

            end

            LW_ST: begin
                if (counter == 3'b000) begin

                    estado = LW_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b01; //
                    MDR_Write = 1'b1; // ????????
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b01; //
                    MDR_Write = 1'b0; // 
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end

            end

            LH_ST: begin
                if (counter == 3'b000) begin

                    estado = LH_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b10; //
                    MDR_Write = 1'b1; // ????????
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b10; //
                    MDR_Write = 1'b0; // 
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end

            end

            LB_ST: begin
                if (counter == 3'b000) begin

                    estado = LB_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b11; //
                    MDR_Write = 1'b1; // ????????
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;

                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b1; //
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00; //
                    srcData_control = 4'b0110; //
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00; 
                    controlSS = 2'b00;
                    LScontrol = 2'b11; //
                    MDR_Write = 1'b0; // 
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            STORES_ST: begin
                // clk 1
                if (counter == 3'b000) begin
                    estado = STORES_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001; //
                    ALUOutCtrl = 1'b1; //
                    aluSourceA_control = 1'b1; //
                    aluSourceB_control = 2'b10; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                // clk 2 - wait 1
                else if (counter == 3'b001) begin
                    estado = STORES_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001; //
                    ALUOutCtrl = 1'b0; //
                    aluSourceA_control = 1'b1; //
                    aluSourceB_control = 2'b10; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                // clk 3 - wait 2
                else if (counter == 3'b010) begin
                    estado = STORES_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001; //
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1; //
                    aluSourceB_control = 2'b10; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                // clk 4 - wait 3
                else if (counter == 3'b011) begin
                    case(OPCODE)
                        SW_OP : begin
                            estado = SW_ST;
                        end
                        SH_OP: begin
                            estado = SH_ST;
                        end
                        SB_OP: begin
                            estado = SB_ST;
                        end
                    endcase

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b001; //
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b1; //
                    aluSourceB_control = 2'b10; //
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b10; //
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b1; //
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end

            end

            SW_ST: begin

                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b1; //
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000; 
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b10; //
                controlSS = 2'b01; //
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;
                
            end

            SH_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b1; //
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000; 
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b10; //
                controlSS = 2'b10; //
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;

            end

            SB_ST: begin
                estado = FETCH_DECODE_ST;

                PC_write = 1'b0;
                MEM_write = 1'b1; //
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000; 
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b10; //
                controlSS = 2'b11; //
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;

                counter = 3'b000;

            end

            OVERFLOW_ST: begin
                if (counter == 3'b000) begin
                    estado = OVERFLOW_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0; //
                    IR_write = 1'b0;
                    Regwrite = 1'b1;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b010; 
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b01;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b11;
                    srcData_control = 4'b0111;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b11; //
                    controlSS = 2'b11; //
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b01;
                    ExceptionControl2 = 2'b01;
                    EPC_Write = 1'b1;
                    change_reset = 1'b0;

                    counter = counter + 1;
                end
                else if (counter == 3'b001) begin
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b1;
                    MEM_write = 1'b1; //
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b010; 
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b01;
                    HIWrite = 1'b0;
                    LOWrite = 1'b0;
                    mux_toRegs_control = 2'b11;
                    srcData_control = 4'b0111;
                    pcSource_control = 3'b100;
                    mux_IorD_control = 2'b11; //
                    controlSS = 2'b11; //
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b01;
                    ExceptionControl2 = 2'b01;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;

                    counter = 3'b000;
                end
            end

            RTE_ST: begin
                estado = FETCH_DECODE_ST; //

                PC_write = 1'b1; //
                MEM_write = 1'b0; 
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000; 
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b011; //
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0; 
                change_reset = 1'b0;

                counter = 3'b000; //
            end

            DIV_ST: begin

                PC_write = 1'b0;
                MEM_write = 1'b0;
                IR_write = 1'b0;
                Regwrite = 1'b0;
                A_write = 1'b0;
                B_write = 1'b0;
                Alu_control = 3'b000;
                ALUOutCtrl = 1'b0;
                aluSourceA_control = 1'b0;
                aluSourceB_control = 2'b00;
                HIWrite = 1'b0;
                LOWrite = 1'b0;
                mux_toRegs_control = 2'b00;
                srcData_control = 4'b0000;
                pcSource_control = 3'b000;
                mux_IorD_control = 2'b00;
                controlSS = 2'b00;
                LScontrol = 2'b00;
                MDR_Write = 1'b0;
                ShiftAmt = 1'b0;
                ShiftSrc = 1'b0;
                ShiftControl = 3'b000;
                ExceptionControl = 2'b00;
                ExceptionControl2 = 2'b00;
                EPC_Write = 1'b0;
                change_reset = 1'b0;
                div_Control = 1'b1; //

                div_counter = div_counter + 1;
                
                if (div_counter == 6'b101000) begin
                    
                    estado = FETCH_DECODE_ST;

                    PC_write = 1'b0;
                    MEM_write = 1'b0;
                    IR_write = 1'b0;
                    Regwrite = 1'b0;
                    A_write = 1'b0;
                    B_write = 1'b0;
                    Alu_control = 3'b000;
                    ALUOutCtrl = 1'b0;
                    aluSourceA_control = 1'b0;
                    aluSourceB_control = 2'b00;
                    HIWrite = 1'b1; //
                    LOWrite = 1'b1; //
                    mux_toRegs_control = 2'b00;
                    srcData_control = 4'b0000;
                    pcSource_control = 3'b000;
                    mux_IorD_control = 2'b00;
                    controlSS = 2'b00;
                    LScontrol = 2'b00;
                    MDR_Write = 1'b0;
                    ShiftAmt = 1'b0;
                    ShiftSrc = 1'b0;
                    ShiftControl = 3'b000;
                    ExceptionControl = 2'b00;
                    ExceptionControl2 = 2'b00;
                    EPC_Write = 1'b0;
                    change_reset = 1'b0;
                    div_Control = 1'b0;

                end

            end
            
        endcase
    end
end

endmodule
