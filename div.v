/**
 * Módulo de divisão.
 *
 * Este módulo implementa a operação de divisão entre dois números de 32 bits.
 * Ele recebe um sinal de clock (clk) e um sinal de reset (reset) para controlar o funcionamento.
 * O sinal de controle (divControl) é usado para iniciar a operação de divisão.
 * Os sinais de entrada (aInput e bInput) representam o dividendo e o divisor, respectivamente.
 * Os sinais de saída (HI, LO e err) representam o quociente, o resto e um sinal de erro indicando divisão por zero.
 *
 * @param clk       Sinal de clock.
 * @param reset     Sinal de reset.
 * @param divControl Sinal de controle para iniciar a operação de divisão.
 * @param aInput    Sinal de entrada representando o dividendo.
 * @param bInput    Sinal de entrada representando o divisor.
 * @param HI        Sinal de saída representando o quociente.
 * @param LO        Sinal de saída representando o resto.
 * @param err       Sinal de saída indicando erro de divisão por zero.
 */
module div(
    input wire clk,
    input wire reset,
    input wire divControl,
    input wire [31:0] aInput,
    input wire [31:0] bInput,
    output reg [31:0] HI,
    output reg [31:0] LO,
    output reg err
);
  // Restante do código...
endmodule
module div(  
    input wire clk,  
    input wire reset,  
    input wire divControl,  
    input wire [31:0] aInput,
    input wire [31:0] bInput,
    output reg [31:0] HI,  // Quocient
    output reg [31:0] LO,  // Rest
    output reg err        // Divison by zero
);
  
  reg [31:0] mod;
  reg [31:0] quoc;
  reg [31:0] A;
  reg [5:0] counter; //contador pra div em até 32 ciclos
  // aInput -> dividendo ;; bInput -> divisor
  
  always @(posedge clk) begin
    
    if(divControl == 1'b1 && reset == 1'b0) begin 
      if(bInput == 32'b00000000000000000000000000000000) begin
        err = 1'b1;
      end
      else begin
		      
        if(counter == 6'b000000) begin
          mod = bInput;
          quoc = aInput;
        end

        if(counter == 6'b100000) begin
          HI = A;
          LO = quoc;
        end

        {A, quoc} = {A, quoc} << 1;
        A = A - mod;

        if(A[31] == 1'b1) begin
          quoc[0] = 1'b0;
          A = A + mod;
        end

        else begin 
          quoc[0] = 1'b1;
        end

        counter = counter + 1;
      end
      
    end
    
    
    else if (divControl == 1'b0 || reset == 1'b1) begin
      mod = 32'b00000000000000000000000000000000;
      quoc = 32'b00000000000000000000000000000000;
      A = 32'b00000000000000000000000000000000;
      counter = 6'b000000;
      err = 0;     
    end
    
  end //always

endmodule