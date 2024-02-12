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

// control wires 
    // control wires um bit
    wire divControl; 
    wire multControl;
    wire muxAControl;
    wire muxBControl;
    wire extControl;
    wire muxHicontrol;
    wire muxLocontrol;
    wire MemWriteControl;
    wire MemReadControl;
    wire concatControl;
    wire RegWrite;
    wire AluOutWrite;
    wire HiWrite;
    wire LoWrite;
    wire PCWrite;
    wire EPCWrite;
    wire LTWrite;
    wire RegAuxWrite;
    wire ShiftRegWrite;
    wire RegAWrite;
    wire RegBWrite;
    wire MDRWrite;


// control wires dois bits
    wire adresscontrol;
    wire ALU1control;
    wire ALU2control;
    wire shamtcontrol;
    wire shiftincontrol;

// control wires três bits
    wire ALUControl;
    wire muxData;
    wire muxPCcontrol;
    wire RegControl;
    wire 

