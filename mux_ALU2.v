module mux_ALU2( 
    input wire [31:0] BOut, //entrada 1
    input wire [31:0]quatro, // entrada 2
    input wire [31:0]sign, // entrada 3
    input wire [31:0]shift, // entrada 4 
    input wire [1:0] ALU2control,
    output wire [31:0] ALU2Out
);

 
    assign ALU2Out = (ALU2control == 2'b00) ? BOut :
     (ALU2control == 2'b01) ? quatro :
     (ALU2control == 2'b10) ? sign :
     (ALU2control == 2'b11) ? shift :
     reset; 

endmodule
