module mux_ALU2( 
    input wire [31:0] BOut, // entrada 1
    input wire [31:0]quatro, // entrada 2
    input wire [31:0]sign, // entrada 3
    input wire [31:0]shift, // entrada 4 
    input wire [1:0] ALU2control, // controle do multiplexador
    output wire [31:0] ALU2Out // saída do multiplexador
);

 
    assign ALU2Out = (ALU2control == 2'b00) ? BOut : // se ALU2control for 2'b00, a saída será BOut
     (ALU2control == 2'b01) ? quatro : // se ALU2control for 2'b01, a saída será quatro
     (ALU2control == 2'b10) ? sign : // se ALU2control for 2'b10, a saída será sign
     shift;  // se ALU2control for 2'b11, a saída será shift

endmodule
