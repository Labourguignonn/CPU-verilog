module mux_ALU1(
    input wire [31:0] PCOut, // 0
    input wire [31:0] AOut, // 1
    input wire [31:0]zero,
    input wire [31:0]auxOut,
    input wire [31:0]ALU1Selector,
    output wire [31:0] ALU1Out
);

    assign ALU1Out = (ALU1Selector == 2'b00) ? PCOut :
    (ALU1Selector == 2'b01) ? AOut :
    (ALU1Selector == 2'b10) ? zero :
    (ALU1Selector == 2'b11) ? auxOut :
    reset; //b111

endmodule
