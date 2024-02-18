module CPU(
    input wire clk, 
    input wire reset
); 

    // CONTROL WIRES UM BIT
    wire PCWrite;
    wire divControl; 
    wire multControl; 
    wire muxAControl; 
    wire muxBControl;
    wire muxExtControl;
    wire muxHiControl;
    wire muxLoControl;
    wire muxMemWriteControl;
    wire MemWrite;
    wire MemRead;
    wire RegWrite;
    wire AluOutWrite;
    wire HiWrite;
    wire LoWrite;
    wire EPCWrite;
    wire RegAWrite;
    wire RegBWrite;
    //wire RegAuxWrite;
    wire MDRWrite;
    wire instructRegWrite;

    // flags 
    wire ovf; //overflow
    wire eq; 
    wire gt; 
    wire lt; 
    wire zero; 
    wire ng; //neg
    wire divz; //divisão por zero 

    // dois bits
    wire [1:0] muxAlu1Control;
    wire [1:0] muxAlu2Control;
    wire [1:0] muxShamtControl;
    wire [1:0] muxShiftInControl;
    wire [1:0] storeSel;
    wire [1:0] loadSel;
    wire [1:0] exceptionControl;

    // três bits
    wire [2:0] ALUControl;
    wire [2:0] muxDataControl;
    wire [2:0] muxPCControl;
    wire [2:0] muxRegControl;
    wire [2:0] muxAddressControl;
    wire [2:0] shiftControl;

    
// INST. REG
    wire [5:0] instruct31to26; //opcode
    wire [4:0] instruct25to21; //rs
    wire [4:0] instruct20to16; //rt
    wire [4:0] instruct15to11; //rd
    wire [25:0] instruct25to0; //junção de rs, rt e opcode

// WIRES DE CARREGAMENTO
    // wire de quatro bits
    wire [3:0] pc31to28;                    // Fio que bifurca do pc e entra no concat (PC[31:28])

    // wires de cinco bits
    wire [4:0] code29toReg = 5'b11101;                 // Código 29 que entra no muxReg
    wire [4:0] code31toReg = 5'b11111;                 // Código 31 que entra no muxReg
    wire [4:0] muxRegOut;                   // Fio que sai do muxReg
    wire [4:0] muxShamtOut;                 // Fio que sai do muxShamt
    wire [4:0] num24toMuxShamt = 5'd24;     // 24 que entra no muxShamt
    
    // wires de 16 bits
    wire [15:0] instruct15to0;              // Instruções [15:0] que saem do registrador de instruções
    wire [15:0] muxExtOut;                  // Fio que sai do muxExtend

    assign instruct15to11 = instruct15to0[15:11];
   
    // wire de 28 bits
    wire [27:0] sl26to28Out;                // Fio que sai do shift left de 26 para 28 bits
    
    // wires 32 bits
    wire [31:0] pcOut;                      // Fio que sai do PC
    wire [31:0] opExcOut = 32'd253;         // Código 253 (opcode) que entra no muxAddress
    wire [31:0] ofExcOut = 32'd254;         // Código 254 (overflow) que entra no muxAddress
    wire [31:0] dbzExcOut = 32'd255;        // Código 255 (divBy0) que entra no muxAddress
    wire [31:0] muxAddressOut;              // Fio que sai do muxAddress
    wire [31:0] muxMemWriteOut;             // Fio que sai do muxMemWrite
    wire [31:0] memOut;                     // Fio que sai da memória
    wire [31:0] mdrOut;                     // Fio que sai do MDR
    wire [31:0] ssOut;                      // Fio que sai do Store Size
    wire [31:0] ls32Out;                    // Fio de 32 bits que sai do Load Size
    wire [31:0] ls16Out;                    // Fio de 16 bits que sai do Load Size
    wire [31:0] readData1;                  // Fio que sai do Read Data 1 do banco de registradores
    wire [31:0] readData2;                  // Fio que sai do Read Data 2 do banco de registradores
    wire [31:0] muxAOut;                    // Fio que sai do muxA
    wire [31:0] aOut;                       // Fio que sai do registrador A
    wire [31:0] muxBOut;                    // Fio que sai do muxB
    wire [31:0] bOut;                       // Fio que sai do registrador B
    //wire [31:0] auxOut;                     // Fio que sai do registrador Aux
    wire [31:0] muxAlu1Out;                 // Fio que sai do muxALU1
    wire [31:0] muxAlu2Out;                 // Fio que sai do muxALU2
    wire [31:0] muxShiftInOut;              // Fio que sai do muxShiftIn
    wire [31:0] shiftRegOut;             // Fio que sai do Shift Reg
    wire [31:0] aluResult;                  // Fio que sai da ALU pela saída AluResult
    wire [31:0] aluOut;                     // Fio que sai do registrador ALUOut
    wire [31:0] multHiOut;                  // Fio que sai pela saída Hi da unidade Mult
    wire [31:0] multLoOut;                  // Fio que sai pela saída Lo da unidade Mult
    wire [31:0] divHiOut;                   // Fio que sai pela saída Hi da unidade Div
    wire [31:0] divLoOut;                   // Fio que sai pela saída Lo da unidade Div
    wire [31:0] hiOut;                      // Fio que sai do registrador HI
    wire [31:0] loOut;                      // Fio que sai do registrador LO
    wire [31:0] muxHiOut;                   // Fio que sai do muxHi
    wire [31:0] muxLoOut;                   // Fio que sai do muxLo
    wire [31:0] sl16to32Out;                // Fio que sai do shift left de 16 para 32 bits
    wire [31:0] sl32to32Out;                // Fio que sai do shift left de 32 para 32 bits
    wire [31:0] concatOut;                  // Fio que sai do concat
    wire [31:0] muxDataOut;                 // Fio que sai do muxData
    wire [31:0] code227toMuxData = 32'd227; // Código 227 que entra no muxData 
    wire [31:0] signExtOut;                 // Fio que sai do sign extend de 16 para 32 bits
    wire [31:0] ltExtOut;                   // Fio que sai do sign extend de 1 para 32 bits (antes de LT)
    wire [31:0] zeroToMuxAlu1 = 32'd0;      // 0 que entra no muxALU1
    wire [31:0] fourToMuxAlu2 = 32'd4;      // 4 que entra no muxALU2
    wire [31:0] zeroToMuxPc = 32'd0;        // 0 que entra no muxPC
    wire [31:0] muxPcOut;                   // Fio que sai do muxPC
    wire [31:0] epcOut;                     // Fio que sai do registrador EPC

//REGISTRADORES
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

Registrador Pc( 
    clk, 
    reset, 
    PCWrite,
    muxPcOut,
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
    muxPcOut, 
    epcOut
);

Registrador ALUOUT(
    clk, 
    reset, 
    AluOutWrite,  
    aluResult, //saída da ULA
    aluOut
);

//Registrador Aux( 
 //   clk, 
  //  reset, 
 //   RegAuxWrite,
  //  muxAOut, 
  //  auxOut
//);

//MUX's
mux_A muxA( 
    memOut, //in
    readData1, //in
    muxAControl, //control
    muxAOut //out
);

mux_B muxB(
    readData2, //in
    memOut, //in
    muxBControl, //control
    muxBOut //out
);

mux_address muxAdress(
    pcOut, //in
    opExcOut,//in
    ofExcOut,//in
    dbzExcOut,//in
    aluOut,//in
    muxAddressControl, //control
    muxAddressOut //out 
);

mux_memwrite muxMemWrite(
    ssOut, //in
    bOut, //in
    muxMemWriteControl, //control
    muxMemWriteOut //out
);

mux_pc muxPC( 
    epcOut, //in 
    ls32Out, //in 
    aluOut, // in
    concatOut, // in 
    aluResult, // in
    muxPCControl, //control
    muxPcOut //out
);

mux_extend muxExt(
    ls16Out, //in
    instruct15to0, //in
    muxExtControl, //control
    muxExtOut //out
);

mux_reg muxReg(
    instruct25to21,
    instruct20to16,
    code29toReg,
    code31toReg,
    instruct15to11,
    muxRegControl,
    muxRegOut
);

mux_ALU1 muxALU1(
    pcOut,
    aOut,
    zeroToMuxAlu1,
    muxAlu1Control,
    muxAlu1Out    
);

mux_ALU2 muxALU2(
    bOut,
    fourToMuxAlu2,
    signExtOut,
    sl32to32Out,
    muxAlu2Control,
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
    instruct15to0[10:6],
    bOut,
    num24toMuxShamt,
    muxShamtControl,
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
    ltExtOut,
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
    muxLoControl,
    muxLoOut
);

//MULT E DIV
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
    divz
);

//Sign Extender & Zero Extender & Shift Left 2
shift_left2 shift2( 
    signExtOut, //in(saída do sign extend)
    sl32to32Out //out
);

shift_left16to32 shift16(
    instruct15to0,
    sl16to32Out
);

shift_left26to28 shift2PC(
    instruct25to0, 
    sl26to28Out
);

sign_extend16 sign16(
    muxExtOut,
    signExtOut //saída do sign extend
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
    muxShamtOut,
    muxShiftInOut,
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
    instruct15to0
);

Banco_reg Banco(
    clk, 
    reset, 
    RegWrite,
    instruct25to21,
    instruct20to16, 
    muxRegOut,
    muxDataOut,
    readData1, //saída do read data 1
    readData2 // saída do read data 2 
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
    clk, 
    reset, 
// CONTROL WIRES 
    // um bit
    PCWrite,
    MemWrite,
    instructRegWrite,
    RegWrite,
    RegAWrite,
    RegBWrite,
    AluOutWrite,
    MDRWrite,
    HiWrite,
    LoWrite,
    EPCWrite,
    divControl, 
    multControl,
    muxAControl,
    muxBControl,
    muxExtControl,
    muxHiControl,
    muxLoControl,
    muxMemWriteControl,
    MemRead,
    //RegAuxWrite,
    
    // dois bits
    muxAlu1Control,
    muxAlu2Control,
    muxShamtControl,
    muxShiftInControl,
    storeSel,
    loadSel,
    exceptionControl,
    
    // três bits
    ALUControl,
    muxDataControl,
    muxPCControl,
    muxRegControl,
    muxAddressControl,
    shiftControl,

    // flags 
    ovf, //overflow
    eq,
    gt, 
    lt,
    zero, 
    ng,//neg
    divz, //divisão por zero 
    
    //instruções
    instruct31to26, //opcode
    instruct15to0[5:0], //16
    reset
);


endmodule