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

    wire divControl; 
    wire multControl;
    wire aControl;
    wire bControl;
    wire exControl;
    wire Hicontrol;
    wire Locontrol;
    wire memwritecontrol;


// control wires dois bits
    wire adresscontrol;
    wire ALU1control;
    wire ALU2control;
    wire shamtcontrol;
    wire shiftincontrol;

// control wires três bits
    wire dataControl;
    wire muxPCcontrol;
    wire RegControl;

