module mux_ALU1(
    input wire [31:0] PCOut, 
    input wire [31:0] AOut, 
    input wire [31:0]zero,
    input wire [1:0] ALU1control,
    output wire [31:0] ALU1Out
);

    assign ALU1Out = (ALU1control == 2'b00) ? PCOut :
    (ALU1control == 2'b01) ? AOut :
    zero;

endmodule
