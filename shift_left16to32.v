// O QUE FICA PERTO DO LOAD SIZE

module shift_left16to32(
    input wire [15:0] sixteen, // offset
    output wire [31:0] shiftLeftOut //saída de 32bits
);
    wire [31:0] aux;
    assign aux = {{16{1'b0}}, sixteen};


    assign shiftLeftOut = aux << 16; 
    
endmodule
