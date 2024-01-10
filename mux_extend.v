
module mux_extend(input wire [31:0] load, 
              input wire [15:0] twentozero,
              input wire exControl,
              output wire [15:0] exOut);
  
  assign exOut = (exControl == 1'b0) ? load : twentozero;
  
  
endmodule