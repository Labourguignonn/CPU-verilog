// O QUE FICA DEPOIS DO SIGN EXTEND

module shift_left2(
    input wire [31:0] ex, // extend
    output wire [31:0] shiftLeftOut
);

    assign shiftLeftOut = ex << 2; 

endmodule
