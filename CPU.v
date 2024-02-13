module CPU(
    input wire clk, 
    input wire reset
); 
// flags 
    wire ovf; //overflow
    wire eq; 
    wire gt; 
    wire lt; 
    wire zero; 
    wire ng; //neg
    wire zero_D; //divisão por zero 
    wire IsBEQ;
    wire IsBNE;
    wire IsBGT;
    wire IsBLE;

// control wires 
    // control wires um bit
    wire divControl; 
    wire multControl;
    wire muxAControl;
    wire muxBControl;
    wire muxExtControl;
    wire muxHiControl;
    wire muxLoControl;
    wire muxMemWrite;
    wire MemWrite;
    wire MemRead;
    wire concatControl;
    wire RegWrite;
    wire AluOutWrite;
    wire HiWrite;
    wire LoWrite;
    wire PCWrite;
    wire EPCWrite;
    wire LTWrite;
    wire ShiftRegWrite;
    wire RegAWrite;
    wire RegBWrite;
    wire RegAuxWrite;
    wire MDRWrite;
    wire instructRegWrite;


// control wires de dois bits
    wire [1:0] ALU1Control;
    wire [1:0] ALU2Control;
    wire [1:0] muxShamtControl;
    wire [1:0] muxShiftInControl;
    wire [1:0] storeSel;
    wire [1:0] loadSel;
    wire [1:0] exceptionControl;

// control wires de três bits
    wire [2:0] ALUControl;
    wire [2:0] muxDataControl;
    wire [2:0] muxPCControl;
    wire [2:0] muxRegControl;
    wire [2:0] muxAddressControl;
    wire [2:0] shiftControl;

// wire de quatro bits
    wire [3:0] pc31to28;            // Fio que bifurca do pc e entra no concat (PC[31:28])

// wires de cinco bits
    wire [4:0] code29toReg;         // Código 29 que entra no muxReg
    wire [4:0] code31toReg;         // Código 31 que entra no muxReg
    wire [4:0] muxRegOut;           // Fio que sai do muxReg
    wire [4:0] muxShamtOut;         // Fio que sai do muxShamt
    wire [4:0] num24toMuxShamt      // 24 que entra no muxShamt
    
// wires de 16 bits
    wire [15:0] instruct15to0;      // Instruções [15:0] que saem do registrador de instruções
    wire [15:0] muxExtOut;          // Fio que sai do muxExtend

// wire de 28 bits
    wire [27:0] sl26to28Out;        // Fio que sai do shift left de 26 para 28 bits
    
// wires 32 bits
    wire [31:0] pcOut;              // Fio que sai do PC
    wire [31:0] opExcOut;           // Código 253 (opcode) que entra no muxAddress
    wire [31:0] ofExcOut;           // Código 254 (overflow) que entra no muxAddress
    wire [31:0] dbzExcOut;          // Código 255 (divBy0) que entra no muxAddress
    wire [31:0] muxAddressOut;      // Fio que sai do muxAddress
    wire [31:0] muxMemWriteOut;     // Fio que sai do muxMemWrite
    wire [31:0] memOut;             // Fio que sai da memória
    wire [31:0] mdrOut;             // Fio que sai do MDR
    wire [31:0] ssOut;              // Fio que sai do Store Size
    wire [31:0] ls32Out;            // Fio de 32 bits que sai do Load Size
    wire [31:0] ls16Out;            // Fio de 16 bits que sai do Load Size
    wire [31:0] readData1;          // Fio que sai do Read Data 1 do banco de registradores
    wire [31:0] readData2;          // Fio que sai do Read Data 2 do banco de registradores
    wire [31:0] muxAOut;            // Fio que sai do muxA
    wire [31:0] aOut;               // Fio que sai do registrador A
    wire [31:0] muxBOut;            // Fio que sai do muxB
    wire [31:0] bOut;               // Fio que sai do registrador B
    wire [31:0] auxOut;             // Fio que sai do registrador Aux
    wire [31:0] muxAlu1Out;         // Fio que sai do muxALU1
    wire [31:0] muxAlu2Out;         // Fio que sai do muxALU2
    wire [31:0] muxShiftInOut;      // Fio que sai do muxShiftIn
    wire [31:0] shiftRegOut;        // Fio que sai do Shift Reg
    wire [31:0] aluResult;          // Fio que sai da ALU pela saída AluResult
    wire [31:0] aluOut;             // Fio que sai do registrador ALUOut
    wire [31:0] multHiOut;          // Fio que sai pela saída Hi da unidade Mult
    wire [31:0] multLoOut;          // Fio que sai pela saída Lo da unidade Mult
    wire [31:0] divHiOut;           // Fio que sai pela saída Hi da unidade Div
    wire [31:0] divLoOut;           // Fio que sai pela saída Lo da unidade Div
    wire [31:0] hiOut;              // Fio que sai do registrador HI
    wire [31:0] loOut;              // Fio que sai do registrador LO
    wire [31:0] muxHiOut;           // Fio que sai do muxHi
    wire [31:0] muxLoOut;           // Fio que sai do muxLo
    wire [31:0] sl16to32Out;        // Fio que sai do shift left de 16 para 32 bits
    wire [31:0] sl32to32Out;        // Fio que sai do shift left de 32 para 32 bits
    wire [31:0] concatOut;          // Fio que sai do concat
    wire [31:0] muxDataOut;         // Fio que sai do muxData
    wire [31:0] code227toMuxData;   // Código 227 que entra no muxData
    wire [31:0] signExtOut;         // Fio que sai do sign extend de 16 para 32 bits
    wire [31:0] ltExtOut;           // Fio que sai do sign extend de 1 para 32 bits (antes de LT)
    wire [31:0] ltOut;              // Fio que sai do registrador LT
    wire [31:0] zeroToMuxAlu1;      // 0 que entra no muxALU1
    wire [31:0] fourToMuxAlu2;      // 4 que entra no muxALU2
    wire [31:0] zeroToMuxPc;        // 0 que entra no muxPC
    wire [31:0] muxPcOut;           // Fio que sai do muxPC
    wire [31:0] epcOut;             // Fio que sai do registrador EPC

// INST. REG
    wire [5:0] instruct31to26; //opcode
    wire [4:0] instruct25to21; //rs
    wire [4:0] instruct20to16; //rt
    wire [15:0] immediate; //16
    wire [25:0] inst25to0 //junção de rs, rt e opcode

//Registradores 
Registrador A( 
    clk, 
    reset, 
    RegAWrite,
    muxAOut,
    aOut
);

Registrador B(
    clk, 
    reset, 
    RegBWrite,
    muxBOut,
    bOut
);

Registrador Hi(
    clk,
    reset, 
    HiWrite,
    muxHiOut,
    hiOut
);

Registrador Lo(
    clk, 
    reset,
    LoWrite, 
    muxLoOut,
    loOut
);

Registrador PC( 
    clk, 
    reset, 
    PCWrite,
    muxPCOut,
    pcOut
);

Registrador MDR(
    clk, 
    reset, 
    MDRWrite,
    memOut,
    mdrOut
);

Registrador EPC(
    clk, 
    reset, 
    EPCWrite,  
    aluOut, //saída do ALUOUT = ALURESULT
    EPCOut
);

Registrador Aux( 
    clk, 
    reset, 
    RegAWrite,
    muxAOut, 
    auxOut
);

//MUX's
mux_A muxA( 
    memOut, //in
    readData1, //in
    muxAControl, //control
    muxAOut //out
);

mux_B muxB(
    memOut, //in
    readData2, //in
    muxBControl, //control
    muxBOut //out
);

mux_address muxAdress(
    pcOut,
    opExcOut,
    ofExcOut,
    dbzExcOut,
    aluOut,
    muxAddressControl,
    muxAddressOut  
);

mux_memwrite muxMemWrite(
    ssOut, //in
    bOut, //in
    muxMemWriteOut
);

mux_pc muxPC( 
    EPCOut, //in 
    zeroToMuxPc, //in 
    aluOut, // in
    concatOut, // in 
    aluResult, // in
    muxPCOut
);

mux_extend muxExt(
    ls16Out, //in
    immediate, //in
    muxExtOut
);

mux_reg muxReg(
    instruct25to21,
    instruct20to16,
    code29toReg,
    code31toReg,
    immediate  
);

mux_ALU1 muxALU1(
    pcOut,
    aOut,
    zeroToMuxAlu1,
    auxOut,
    ALU1Control,
    muxAlu1Out    
);

mux_ALU2 muxALU2(
    bOut,
    fourToMuxAlu2,
    signExtOut,
    sl32to32Out,
    ALU2Control,
    muxAlu2Out
);

mux_shiftIn muxShiftIn(
    aOut,
    bOut,
    mdrOut,
    muxShiftInControl,
    muxShiftInOut
);

mux_shamt muxShamt(
    immediate,
    bOut,
    num24toMuxShamt,
    muxShamtOut
);

mux_data muxData(
    code227toMuxData,
    ls32Out,
    aluOut,
    sl16to32Out,
    hiOut,
    loOut,
    shiftRegOut,
    ltOut,
    muxDataControl,
    muxDataOut
);

mux_HI muxHI (
    multHiOut,
    divHiOut,
    muxHiControl,
    muxHiOut
);

mux_LO muxLO (
    multLoOut,
    divLoOut,
    muxLoOut
);

//mult e div
mult multi(
    clk,
    reset,
    multControl,
    aOut,
    bOut,
    multHiOut,
    multLoOut
); 
div divi(
    clk, 
    reset, 
    divControl,
    aOut,
    bOut, 
    divHiOut,
    divLoOut,
    zero_D
);

//Sign Extender & Zero Extender & Shift Left 2
shift_left2 shift2( 
    ext, //in(saída do sign extend)
    shiftLeftOut //out
);

shift_left16to32 shift16(
    immediate,
    shiftLeftOut
);

shift_left26to28 shift2PC(
    inst25to0, 
    shiftLeftPCOut
);

sign_extend16 sign16(
    muxExtOut,
    ext //saída do sign extend
);

sign_extend_LT signLT(
    lt,
    ltExtOut
);

//CRIADOS
concat concatena(
    pcOut,
    sl26to28Out,
    concatOut
);

LS LoadSize(
    clk,
    reset,
    loadSel,
    mdrOut,
    exceptionControl,
    ls32Out,
    ls16Out
);

SS StoreSize(
    clk,
    reset,
    storeSel,
    bOut,
    mdrOut,
    exceptionControl,
    ssOut
);

//Dados
Memoria Mem( 
    muxAddressOut,
    clk, 
    MemWrite,
    muxMemWriteOut,
    memOut
);

RegDesloc RegisterShift( 
    clk,
    reset,
    shiftControl,
    shamtOut,
    shiftinOut,
    shiftRegOut
);

Instr_Reg Inst_(
    clk, 
    reset, 
    instructRegWrite,
    memOut, 
    instruct31to26,
    instruct25to21,
    instruct20to16,
    immediate,
);

Banco_reg Banco(
    clk, 
    reset, 
    RegWrite,
    instruct25to21,
    instruct20to16, 
    muxRegOut,
    muxdataOut,
    data1Out //saída do read data 1
    data1Out // saída do read data 2 
);

ula32 ULA( 
    muxAlu1Out,
    muxAlu2Out,
    ALUControl,
    aluResult,
    ovf, 
    ng, 
    zero, 
    eq, 
    gt, 
    lt
);

unid_controle unidadecontrole(

);


endmodule