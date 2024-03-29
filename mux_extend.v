
module mux_extend(input wire [15:0] loadouthalf, 
              input wire [15:0] fiftozero, //immediate
              input wire exControl,
              output wire [15:0] muxExtOut);
  
  assign muxExtOut = (exControl == 1'b0) ? loadouthalf : fiftozero;
  
  
endmodule