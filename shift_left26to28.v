// O QUE FICA PERTO DO CONCAT

module shift_left26to28(
    input wire [25:0] twentyfive, // entrada de 26 bits
    output wire [27:0] shiftLeftPCOut // saída de 28 bits
);
    wire [27:0] aux; // fio auxiliar de 28 bits
    assign aux = {{2{1'b0}}, twentyfive}; // atribuição de valor ao fio auxiliar

    assign shiftLeftOut = aux << 2; // atribuição de valor ao fio shiftLeftOut
    
endmodule
