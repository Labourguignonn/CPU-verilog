// O QUE FICA PERTO DO CONCAT

module shift_left16to32(
    input wire [25:0] twentyfive, //entrada de 26 bits
    output wire [27:0] shiftLeftPCOut //saída de 28 bits
);
    wire [27:0] aux;
    assign aux = {{2{1'b0}}, twentyfive};

    assign shiftLeftOut = aux << 2; 
    
endmodule
