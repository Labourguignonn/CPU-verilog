// O QUE FICA PERTO DO CONCAT

module shift_left26to28(
    input wire [25:0] twentyfive, //entrada de 26 bits
    output wire [27:0] shiftLeftOut //saída de 28 bits
);
    assign shiftLeftOut = {twentyfive, {2{1'b0}}};
    
endmodule
