module mux_reg(
    input wire [4:0] twentotwen, 
    input wire [4:0] twentosix, 
    input wire [4:0] dec29, 
    input wire [4:0] dec31,
    input wire [4:0] fiftozero, //instruct 15:11
    input wire [2:0] RegControl,
    output wire [4:0] muxRegOut
);

    assign muxRegOut = (RegControl == 3'b000) ? twentotwen :
    (RegControl == 3'b001) ? twentosix :
    (RegControl == 3'b010) ? dec29 :
    (RegControl == 3'b011) ? dec31 :
    (RegControl == 3'b100) ? fiftozero :
     5'b0;

endmodule