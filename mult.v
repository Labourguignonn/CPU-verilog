module mult(
	input wire clk,  
    input wire reset,  
    input wire multControl,
    input wire [31:0] aInput,
  	input wire [31:0] bInput, 
  	output reg [31:0] HI, // bits mais significativos
  	output reg [31:0] LO  // bits menos significativos
);

reg [31:0] multiplicand; // multiplicando
reg [31:0] multiplier;   // multiplicador
reg [63:0] result;       // Resultado temporário 
reg [5:0]  cycle;        // Contador de ciclos

always @(posedge clk or posedge reset) begin
end


