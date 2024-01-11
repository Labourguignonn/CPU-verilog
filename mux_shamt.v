
module mux_shamt(input wire [4:0] fiftozero,
              input wire [4:0] BOut,
              input wire [4:0] twenfour, //24
              input wire [1:0] shamtcontrol,
              output wire [4:0] shamtOut);
  
  assign shamtOut = (shamtcontrol == 2'b00) ? fiftozero :
     (shamtcontrol == 2'b01) ? BOut :
     (shamtcontrol == 2'b10) ? twenfour :
     reset;
  
  
endmodule