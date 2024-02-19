module unid_controle (  
    input wire clk,
    input wire reset,
    output reg PCWrite,
    output reg MemWrite,
    output reg instructRegWrite,
    output reg RegWrite,
    output reg RegAWrite,
    output reg RegAuxWrite,
    output reg RegBWrite,
    output reg AluOutWrite,
    output reg MDRWrite,
    output reg HiWrite,
    output reg LoWrite,
    output reg EPCWrite,
    output reg divControl, 
    output reg multControl,
    output reg muxAControl,
    output reg muxBControl,
    output reg muxExtControl,
    output reg muxHiControl,
    output reg muxLoControl,
    output reg muxMemWrite,
    //2 bits
    output reg [1:0] ALU1Control,
    output reg [1:0] ALU2Control,
    output reg [1:0] muxShamtControl,
    output reg [1:0] muxShiftInControl,
    output reg [1:0] storeSel,
    output reg [1:0] loadSel,
    output reg [1:0] exceptionControl,
    
    //3 bits
    output reg[2:0] ALUControl,
    output reg[2:0] muxDataControl,
    output reg[2:0] muxPCControl,
    output reg[2:0] muxRegControl,
    output reg[2:0] muxAddressControl,
    output reg[2:0] ShiftControl,

    //flags
    input wire ovf,
    input wire eq,
    input wire gt,
    input wire lt,
    input wire zero,
    input wire ng,
    input wire divz,

    //Instrucoes
    input wire [5:0] instruct31to26,
    input wire [5:0] funct,
    output reg rst
);
//Variáveis
    reg [5:0] Counter;
    reg [5:0] State;
//Parametros
    //Estados
    parameter ST_COMMON = 6'd0;
    parameter ST_ADD = 6'd1;
    parameter ST_ADDI = 6'd2;
    parameter ST_ADDIU = 6'd3;
    parameter ST_AND = 6'd4;
    parameter ST_SUB = 6'd5;
    parameter ST_DIV = 6'd6;
    parameter ST_MULT = 6'd7;
    parameter ST_MFHI = 6'd8;
    parameter ST_MFLO = 6'd9;
    parameter ST_JR = 6'd10;
    parameter ST_RTE = 6'd11;

    parameter ST_BNE = 6'd12;
    parameter ST_BEQ = 6'd13;
    parameter ST_BLE = 6'd14;
    parameter ST_BGT = 6'd15;
    parameter ST_SLT = 6'd16;
    parameter ST_SLTI= 6'd17;

    parameter ST_LUI = 6'd18;

    parameter ST_J = 6'd19;
    parameter ST_JAL = 6'd20;

    parameter ST_SLL = 6'd21;
    parameter ST_SLLV = 6'd22;
    parameter ST_SRL = 6'd23;
    parameter ST_SRA = 6'd24;
    parameter ST_SRAV = 6'd25;

    parameter ST_SW = 6'd26; //store

    parameter ST_OF = 6'd27; //overflow
    parameter ST_DIVZ = 6'd28; //div0

    parameter ST_LW = 6'd29;
    parameter ST_LH = 6'd30;
    parameter ST_LB = 6'd31;

    parameter ST_SB = 6'd34;
    parameter ST_SH = 6'd35;

    parameter ST_SRAM = 6'd36;
    parameter ST_XCHG = 6'd37;

    parameter ST_BREAK = 6'd32; //PENÚLTIMO ESTADO!
    parameter ST_RESET = 6'd33; //ÚLTIMO ESTADO!
    parameter ST_OPN = 6'd38; //opcode no existent 

    //Opcode
    parameter RESET = 6'b111111;

    //Type R
    parameter Type_R = 6'd0;
        //Funct dos Tipos R
        parameter ADD = 6'h20;
        parameter SUB = 6'h22;
        parameter AND = 6'h24;
        parameter DIV = 6'h1a;
        parameter MULT = 6'h18;
        parameter JR = 6'h8;
        parameter MFHI = 6'h10;
        parameter MFLO = 6'h12;
        parameter SLL = 6'h0;
        parameter SLLV = 6'h4;
        parameter SLT = 6'h2a;
        parameter SRA = 6'h3;
        parameter SRAV = 6'h7;
        parameter SRL = 6'h2;
        parameter BREAK = 6'hd;
        parameter RTE = 6'h13;
        parameter XCHG = 6'h5;

    //Type I
    parameter ADDI = 6'h8;
    parameter ADDIU = 6'h9;
    parameter BEQ = 6'h4;
    parameter BNE = 6'h5;
    parameter BLE = 6'h6;
    parameter BGT = 6'h7;
    parameter LB = 6'h20;
    parameter LH = 6'h21;
    parameter LUI = 6'hf;
    parameter LW = 6'h23;
    parameter SB = 6'h28;
    parameter SH = 6'h29;
    parameter SLTI = 6'ha;
    parameter SW = 6'h2b;
    parameter SRAM = 6'h1;

    //Type J
    parameter J = 6'h2;
    parameter JAL = 6'h3;

    initial begin
        //Da o reset inicial na maquina
        rst = 1'b1; //instrução que realiza a confirmação do reset
        State = ST_ADD;
    end
    always @(posedge clk) begin
        if (rst == 1'b1) begin
            if (State != ST_RESET) begin
                State = ST_RESET;

                //um bit
                PCWrite = 1'b0;
                MemWrite = 1'b0;
                instructRegWrite = 1'b0;
                RegWrite = 1'b1;
                RegAWrite = 1'b0;
                RegAuxWrite = 1'b0;
                RegBWrite = 1'b0;
                AluOutWrite = 1'b0;
                MDRWrite = 1'b0;
                HiWrite = 1'b0;
                LoWrite = 1'b0;
                EPCWrite = 1'b0;
                
                divControl = 1'b0;
                multControl = 1'b0;
                muxAControl = 1'b0;
                muxBControl = 1'b0;
                muxExtControl = 1'b0;
                muxHiControl = 1'b0;
                muxLoControl = 1'b0;
                muxMemWrite = 1'b0;

                //dois bits
                ALU1Control = 2'b00;
                ALU2Control = 2'b00;
                muxShamtControl = 2'b00;
                muxShiftInControl = 2'b00;
                storeSel = 2'b00;
                loadSel = 2'b00;
                exceptionControl = 2'b00;

                //tres bits
                ALUControl = 3'b000;
                muxDataControl = 3'b000;
                muxPCControl = 3'b100; 
                muxRegControl = 3'b010; 
                muxAddressControl = 3'b000;
                ShiftControl = 3'b000;

                rst = 1'b1; 
                Counter = 6'd0;
            end
            else begin
                State = ST_COMMON;

                PCWrite = 1'b0;
                MemWrite = 1'b0;
                instructRegWrite = 1'b0;
                RegWrite = 1'b1;
                RegAWrite = 1'b0;
                RegAuxWrite = 1'b0;
                RegBWrite = 1'b0;
                AluOutWrite = 1'b0;
                MDRWrite = 1'b0;
                HiWrite = 1'b0;
                LoWrite = 1'b0;
                EPCWrite = 1'b0;
                
                divControl = 1'b0;
                multControl = 1'b0;
                muxAControl = 1'b0;
                muxBControl = 1'b0;
                muxExtControl = 1'b0;
                muxHiControl = 1'b0;
                muxLoControl = 1'b0;
                muxMemWrite = 1'b0;               

                //dois bits
                ALU1Control = 2'b00;
                ALU2Control = 2'b00;
                muxShamtControl = 2'b00;
                muxShiftInControl = 2'b00;
                storeSel = 2'b00;
                loadSel = 2'b00;
                exceptionControl = 2'b00;

                //tres bits
                ALUControl = 3'b000;
                muxDataControl = 3'b000; // pega 227 
                muxPCControl = 3'b000;
                muxRegControl = 3'b010; //pega o 29
                muxAddressControl = 3'b000;
                ShiftControl = 3'b000;

                rst = 1'b0;
                Counter = 6'd0;
            end
        end
        else begin
            case(State)
                ST_COMMON: begin
                    if (Counter == 6'd0 || Counter == 6'd1 || Counter == 6'd2) begin
                        //Busca e waiting
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; //SOMA
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd3) begin
                        //Salvar PC
                        State = ST_COMMON;

                        PCWrite = 1'b1; //escreve o resultado de PC+4 em PC
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b1;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01; //4 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; //SOMA(PC+4)
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100; //pode ser 000 -- precisa disso para passar a informação para PC
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd4) begin
                        //Nesse else acontece o estado de Decode
                        State = ST_COMMON;
                        
                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b1;
                        RegAuxWrite = 1'b1;
                        RegBWrite = 1'b1;
                        AluOutWrite = 1'b1;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1; 
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00; //PC
                        ALU2Control = 2'b11; //Immediate(shift)
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; //SOMA
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd5) begin
                        case(instruct31to26) // Opcde
                            Type_R: begin
                                case(funct)
                                    ADD: begin
                                        State = ST_ADD;
                                    end
                                    AND: begin
                                        State = ST_AND;
                                    end
                                    SUB: begin
                                        State = ST_SUB;
                                    end
                                    DIV: begin
                                        State = ST_DIV;
                                    end
                                    MULT: begin
                                        State = ST_MULT;
                                    end
                                    MFHI: begin
                                        State = ST_MFHI;
                                    end
                                    MFLO: begin
                                        State = ST_MFLO;
                                    end
                                    JR: begin
                                        State = ST_JR;
                                    end
                                    RTE: begin
                                        State = ST_RTE;
                                    end
                                    BREAK: begin
                                        State = ST_BREAK;
                                    end
                                    SLL: begin
                                        State = ST_SLL;
                                    end
                                    SLLV: begin
                                        State = ST_SLLV;
                                    end
                                    SRL: begin
                                        State = ST_SRL;
                                    end
                                    SRA: begin
                                        State = ST_SRA;
                                    end
                                    SRAV: begin
                                        State = ST_SRAV;
                                    end
                                    SLT: begin
                                        State = ST_SLT;
                                    end
                                    XCHG: begin
                                        State = ST_XCHG;
                                    end
                                    default:
                                        State = ST_OPN;
                                endcase
                            end
                            
                            ADDI: begin
                                State = ST_ADDI;
                            end

                            ADDIU: begin
                                State = ST_ADDIU;
                            end
                            
                            RESET: begin
                                State = ST_RESET;
                            end

                            BNE: begin
                                State = ST_BNE;
                            end

                            BEQ: begin
                                State = ST_BEQ;
                            end

                            BLE: begin
                                State = ST_BLE;
                            end

                            BGT: begin
                                State = ST_BGT;
                            end

                            SLTI: begin
                                State = ST_SLTI;
                            end

                            LUI: begin
                                State = ST_LUI;
                            end

                            J: begin
                                State = ST_J;
                            end

                            JAL: begin
                                State = ST_JAL;
                            end

                            SW: begin
                                State = ST_SW;
                            end

                            LW: begin
                                State = ST_LW;
                            end

                            LB: begin
                                State = ST_LB;
                            end

                            LH: begin
                                State = ST_LH;
                            end

                            SB: begin
                                State = ST_SB;
                            end

                            SH: begin
                                State = ST_SH;
                            end

                            SRAM: begin
                                State = ST_SRAM;
                            end
                            default:
                                State = ST_OPN;
                        endcase
                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_ADD: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADD;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
            
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                        if (ovf == 1'b1) 
                        begin
                            State = ST_OF;
                        end
                    end
                end
                ST_ADDI: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADDI;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                    
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000; 
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 3'b000;
                        if (ovf == 1'b1) 
                        begin
                            State = ST_OF;
                        end
                    end
                end
                ST_OPN: begin
                    if(Counter == 6'd0) 
                    begin
                        State = ST_OPN;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b1;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;

                    end else if (Counter == 6'd1  || Counter == 6'd2) 
                    begin
                        State = ST_OPN;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b001;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;

                    end else if (Counter == 6'd3)
                    begin
                        State = ST_OPN;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end else if (Counter == 6'd4)
                    begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b001;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end

                ST_OF: begin
                    if(Counter == 6'd0) 
                    begin
                        State = ST_OF;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b1;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end 
                    else if (Counter == 6'd1  || Counter == 6'd2) begin
                        State = ST_OF;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b1;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b010;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end else if (Counter == 6'd3) // pegar o valor da memoria e dar um carrega A
                    begin
                        State = ST_OF;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end else if (Counter == 6'd4)
                    begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b001;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_ADDIU: begin
                    if(Counter == 6'd0) begin
                        State = ST_ADDIU;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000; 
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                    
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 3'b000;
                    end
                end
                ST_AND: begin
                    if(Counter == 6'd0) begin
                        State = ST_AND;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b011;
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                         PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b011; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                end
                ST_SUB: begin
                    if(Counter == 6'd0) begin
                        State = ST_SUB;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                        if (ovf == 1'b1) 
                        begin
                            State = ST_OF;
                        end
                    end
                end
                ST_DIV: begin
                    if(Counter < 6'd33) begin
                        State = ST_DIV;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b1;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b1;
                        LoWrite = 1'b1;
                        EPCWrite = 1'b0;
                        divControl = 1'b1; //DESLIGAR SE N FUNCIONAR
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b1;
                        muxLoControl = 1'b1;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                        if (divz == 1'b1)
                        begin
                            State = ST_DIVZ;
                        end
                    end
                end
                ST_DIVZ: begin
                    if(Counter == 6'd0) 
                    begin
                        State = ST_DIVZ;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b1;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end else if (Counter == 6'd1  || Counter == 6'd2) 
                    begin
                        State = ST_DIVZ;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b011;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;

                    end else if (Counter == 6'd3)
                    begin
                        State = ST_DIVZ;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end else if (Counter == 6'd4)
                    begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b001;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_MULT: begin
                    if(Counter < 6'd33) begin
                        State = ST_MULT;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b1;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd33) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b1;
                        LoWrite = 1'b1;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b1;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_MFHI: begin
                    if(Counter == 6'd0) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b100;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end  
                end
                ST_MFLO: begin
                    if(Counter == 6'd0) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b101;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_JR: begin
                    if(Counter == 6'd0) begin
                        State = ST_JR; 

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_RTE: begin
                    if(Counter == 6'd0) begin
                        State = ST_RTE;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0; 
                        Counter = 6'd0;
                    end
                end
                ST_BNE: begin
                    if(Counter == 6'd0) begin
                        State = ST_BNE; 
                        
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        if(eq == 1'b0) begin
                            PCWrite = 1'b1;   
                        end 
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end           
                ST_BEQ: begin
                    if(Counter == 6'd0) begin
                        State = ST_BEQ;
                                                       
                        if(eq == 1'b1) begin
                            PCWrite = 1'b1;   
                        end
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;

                        if(eq == 1'b1) begin
                            PCWrite = 1'b1;   
                        end
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_BLE: begin
                    if(Counter == 6'd0) begin
                        State = ST_BLE;
                        if(gt == 1'b0) begin
                            PCWrite = 1'b1;   
                        end
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;

                        if(gt == 1'b0) begin
                            PCWrite = 1'b1;   
                        end
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_BGT: begin
                    if(Counter == 6'd0) begin
                        State = ST_BGT;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 1'd1) begin
                        State = ST_COMMON;
                        
                        if(gt == 1'b1) begin
                            PCWrite = 1'b1;   
                        end
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b010;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_SLTI: begin
                    if(Counter == 6'd0) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; //comparação
                        muxDataControl = 3'b111;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_LUI: begin
                    if(Counter == 6'd0) begin
                        State = ST_COMMON;
                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b011;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                            
                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_J: begin
                    if(Counter == 6'd0) begin
                        State = ST_J;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b011;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                            
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_COMMON;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b011;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_JAL: begin
                    if(Counter == 6'd0) begin
                        State = ST_JAL;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; //pode ser 1
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b011;
                        muxRegControl = 3'b011;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_J;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b011;
                        muxRegControl = 3'b011;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_SLL: begin
                    if(Counter == 6'd0) begin
                        State = ST_SLL;
                        
                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;                      
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b01;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SLL;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b010;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b1;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;   
                    end
                end
                ST_SRL: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRL;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;                      
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00; //instruct15to0
                        muxShiftInControl = 2'b01; //bout
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000; 
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100; 
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRL;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b011;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0; //pode ser 1
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 6'd0;   
                    end
                end
                ST_SRA: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRA;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;   

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b01;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRA;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b100;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;   
                    end
                end
                ST_SLLV: begin
                    if(Counter == 6'd0) begin
                        State = ST_SLLV;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00 ;
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SLLV;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;                       
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                                                
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b010;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                                                                  
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 6'd0;   ///
                    end
                end
                ST_SRAV: begin
                    if(Counter == 6'd0) begin
                        State = ST_SRAV;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00 ;
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd1) begin
                        State = ST_SRAV;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;                       
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                                                
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b100; //sinal de controle desloc. aritm.
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if(Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;                                                           

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_SLT: begin
                    State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01; //valor de A
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b111; //comparação
                        muxDataControl = 3'b111; //saída do lt
                        muxPCControl = 3'b010; //pode ser 000
                        muxRegControl = 3'b100; //[15:11]
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                end
                 ST_SW: begin
                    if(Counter == 6'd0) begin
                        State = ST_SW;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; //grava o valor 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01; //pegar o valor de A 
                        ALU2Control = 2'b10; //offset
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; //realizar a soma
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
 
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_SW;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                                                
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b10;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100; //
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b1;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b10;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 0;
                    end
                end
                ST_SB: begin
                    if(Counter == 6'd0) begin
                        State = ST_SB;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                    
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00; 
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_SB;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100; 
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b1;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
  
                        rst = 1'b0;
                        Counter = 0;
                    end
                end
                ST_SH: begin
                    if(Counter == 6'd0) begin
                        State = ST_SH;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0; //pode ser 0
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                              
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00; 
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100; //pode ser 000
                        ShiftControl = 3'b000;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin
                        State = ST_SH;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;   

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b01;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100; 
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2) begin
                        State = ST_COMMON;

                        PCWrite = 1'b0;
                        MemWrite = 1'b1;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00 ;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b01;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 0;
                    end
                end
                ST_LW: begin
                    if (Counter == 6'd0) begin
                        State = ST_LW; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1 || Counter == 6'd2 || Counter == 6'd3) begin
                        State = ST_LW; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b10;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                        
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd4) begin
                        State = ST_LW; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b10;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd5) begin
                        State = ST_COMMON; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b10;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_LB: begin
                    if (Counter == 6'd0) begin
                        State = ST_LB; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                    
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1 || Counter == 6'd2 || Counter == 6'd3) begin
                        State = ST_LB; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd4) begin
                        State = ST_LB; 
                        
                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd5) begin
                        State = ST_COMMON; //

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_LH: begin
                    if (Counter == 6'd0) begin
                        State = ST_LH; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1 || Counter == 6'd2 || Counter == 6'd3) begin
                        State = ST_LH; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b01;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd4) begin
                        State = ST_LH; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b01;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd5) begin
                        State = ST_COMMON; //

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b01;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000 ;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;

                        rst = 1'b0;
                        Counter = 6'd0;
                    end
                end
                ST_SRAM: begin
                    if (Counter == 6'd0) begin // Soma rs + offset
                        State = ST_SRAM;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b1;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b10; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin // Joga o valor de ALUOut no endereço da memória
                        State = ST_SRAM;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2 || Counter == 6'd3 || Counter == 6'd4) begin // Salva o valor da memória em MDR
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b1;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b10;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b001;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b100;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd5) begin // Passa B para ALUOut e dá load de Mem[rs+offset] em rt
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b10;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b10;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001;        // Somando B+0, para passar B
                        muxDataControl = 3'b001;    // Entrada do valor do load
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;     // rt
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
				    else if (Counter == 6'd6) begin // Registra o valor de B em rs
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;    // ALUOut
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;     // rs
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd7) begin // Grava o valor de rs em A e o rt em B
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b1;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b1;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b1;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd8) begin // Fazer o SRA A >> B (rt >> Mem[rs+offset]): load no shift reg // Carrega aux
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b11;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b001;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd9) begin // Fazer o SRA A >> B (rt >> Mem[rs+offset]): operação no shift reg // rs <- aux
                        State = ST_SRAM;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b01;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b100;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
                    else if (Counter == 6'd10) begin // Escreve o resultado do SRA em rt
                        State = ST_COMMON;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;
                        
                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b110;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 6'd0;
				    end
                end
                ST_XCHG: begin
                    if (Counter == 6'd0) begin // Carrega B
                        State = ST_XCHG;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1;
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;                                           

                        //dois bits
                        ALU1Control = 2'b10;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b001; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd1) begin // Escreve o valor de B em rs
                        State = ST_XCHG;

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;                                           

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b000;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
                    end
                    else if (Counter == 6'd2) begin // Carrega A
                        State = ST_XCHG;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b1; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;             

                        //dois bits
                        ALU1Control = 2'b01;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = Counter + 1;
				    end
				    else if (Counter == 6'd3) begin // Escreve o valor de A em rt
                        State = ST_COMMON;

				        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b1;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b00; 
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000; 
                        muxDataControl = 3'b010;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                       
                        rst = 1'b0;
                        Counter = 6'd0;
				    end
                end
                ST_BREAK: begin
                        State = ST_BREAK;

                        PCWrite = 1'b1;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0;
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b010;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b000;
                        muxRegControl = 3'b001;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;

                    rst = 1'b0;
                    Counter = 6'd0;
                end
                ST_RESET: begin
                    if (Counter == 6'd0) begin
                        State = ST_RESET; 

                        PCWrite = 1'b0;
                        MemWrite = 1'b0;
                        instructRegWrite = 1'b0;
                        RegWrite = 1'b0; //pode ser 1
                        RegAWrite = 1'b0;
                        RegAuxWrite = 1'b0;
                        RegBWrite = 1'b0;
                        AluOutWrite = 1'b0; 
                        MDRWrite = 1'b0;
                        HiWrite = 1'b0;
                        LoWrite = 1'b0;
                        EPCWrite = 1'b0;
                        divControl = 1'b0;
                        multControl = 1'b0;
                        muxAControl = 1'b0;
                        muxBControl = 1'b0;
                        muxExtControl = 1'b0;
                        muxHiControl = 1'b0;
                        muxLoControl = 1'b0;
                        muxMemWrite = 1'b0;

                        //dois bits
                        ALU1Control = 2'b00;
                        ALU2Control = 2'b01;
                        muxShamtControl = 2'b00;
                        muxShiftInControl = 2'b00;
                        storeSel = 2'b00;
                        loadSel = 2'b00;
                        exceptionControl = 2'b00;

                        //tres bits
                        ALUControl = 3'b000;
                        muxDataControl = 3'b000;
                        muxPCControl = 3'b100;
                        muxRegControl = 3'b010;
                        muxAddressControl = 3'b000;
                        ShiftControl = 3'b000;
                        
                        rst = 1'b1;
                        Counter = 6'd0;
                    end
                end
            endcase
        end
    end
endmodule