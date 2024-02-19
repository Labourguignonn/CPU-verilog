module mux_reg(
    input wire [4:0] twentotwen, // - twentotwen: entrada de 5 bits
    input wire [4:0] twentosix, // - twentosix: entrada de 5 bits
    input wire [4:0] dec29, // - dec29: entrada de 5 bits
    input wire [4:0] dec31, // - dec31: entrada de 5 bits
    input wire [4:0] fiftozero, //instruct 15:11 - fiftozero: entrada de 5 bits
    input wire [2:0] RegControl, // - RegControl: entrada de 3 bits
    output wire [4:0] muxRegOut // - muxRegOut: saída de 5 bits
);

    assign muxRegOut = (RegControl == 3'b000) ? twentotwen : // - Se RegControl for igual a 3'b000, muxRegOut será igual a twentotwen
    (RegControl == 3'b001) ? twentosix : // - Se RegControl for igual a 3'b001, muxRegOut será igual a twentosix
    (RegControl == 3'b010) ? dec29 : // - Se RegControl for igual a 3'b010, muxRegOut será igual a dec29
    (RegControl == 3'b011) ? dec31 : // - Se RegControl for igual a 3'b011, muxRegOut será igual a dec31
    (RegControl == 3'b100) ? fiftozero : // - Se RegControl for igual a 3'b100, muxRegOut será igual a fiftozero
     5'b0;
    // - Caso contrário, muxRegOut será igual a 5'b0 (valor zero de 5 bits)







endmodule