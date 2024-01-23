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
  reg ok; // sinal de controle

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      multiplicand <= 0;
      multiplier <= 0;
      result <= 0;
      cycle <= 0;
      ok <= 0;
    end
    else if (multControl) begin
      // Inicialização da multiplicação
      multiplicand <= aInput;
      multiplier <= bInput;
      result <= 64'b0; 
      cycle <= 6'd31; // 32 ciclos para multiplicação de 32 bits

      // Ativar a multiplicação
      ok <= 1;
    end
    else if (ok) begin
      // Realizar a multiplicação
      result <= result + {multiplicand, multiplier};
      multiplicand <= multiplicand << 1;
      multiplier <= multiplier >> 1;
      cycle <= cycle - 6'd1;
    end
  end

  assign HI = result[63:32];
  assign LO = result[31:0];

endmodule
