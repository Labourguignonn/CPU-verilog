// O QUE FICA PERTO DO LOAD SIZE

module shift_left16to32(
    input wire [15:0] sixteen, // offset
    output wire [31:0] shiftLeftOut //saída de 32bits
);
    assign shiftLeftOut = {sixteen, 16'b0};
    
endmodule
