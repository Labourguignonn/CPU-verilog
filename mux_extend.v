
module mux_extend(input wire [15:0] loadouthalf, 
              input wire [15:0] fiftozero,
              input wire exControl,
              output wire [15:0] exOut);
  
  assign exOut = (exControl == 1'b0) ? loadouthalf : fiftozero;
  
  
endmodule