module mux_ALU2(
    input wire [31:0] PCOut, 
    input wire [31:0] BOut, //entrada 1
    input wire [31:0]quatro, // entrada 2
    input wire [31:0]sign, // entrada 3
    input wire [31:0]shift, // entrada 4 
    input wire ALU2control,
    output wire [31:0] ALU2Out
);

//PRECISA VER 
    // assign ALU1Out = (ALU1control == 2'b00) ? PCOut :
    // (ALU1control == 2'b01) ? AOut :
    // (ALU1control == 2'b10) ? zero :
    // (ALU1control == 2'b11) ? auxOut :
    // reset; 

endmodule
