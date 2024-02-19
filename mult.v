module mult(
  input wire clk,  
  input wire reset,  
  input wire multControl,
  input wire [31:0] aInput,
  input wire [31:0] bInput, 
  output reg [31:0] HI, // bits mais significativos
  output reg [31:0] LO  // bits menos significativos
);

    reg [31:0] multiplicand; //multiplicando
    reg [31:0] multiplier;   //multiplicador
    reg Q1;
    reg [31:0] A;
  	reg [5:0] counter; //operação em até 32 ciclos

  	reg aux = 1;
  	
  always @ (posedge clk) begin
    
    if(multControl == 1'b1 && reset == 1'b0) begin // Verifica se a multiplicação está habilitada e o reset está desativado
      
      if(counter == 6'b000000) begin // Verifica se o contador está no valor inicial
        
        multiplier = aInput; // Atribui o valor de aInput ao multiplicador
        multiplicand = bInput; // Atribui o valor de bInput ao multiplicando
        counter = counter + 1; // Incrementa o contador
        
      end
      else begin // Caso o contador não esteja no valor inicial
        
        if(multiplier[0] == 1'b1 && Q1 == 1'b0) begin // Verifica se o bit menos significativo do multiplicador é 1 e o bit Q1 é 0
          
          A = A - multiplicand; // Subtrai o multiplicando de A
        
        end
        
        else if(multiplier[0] == 1'b0 && Q1 == 1'b1) begin // Verifica se o bit menos significativo do multiplicador é 0 e o bit Q1 é 1
          
          A = A + multiplicand; // Soma o multiplicando a A
          
        end
        
        {A, multiplier, Q1} = {A, multiplier, Q1} >> 1'b1; // Desloca A, o multiplicador e o bit Q1 para a direita em 1 bit
        
        
        if(A[30] == 1'b1) begin // Verifica se o bit 30 de A é 1
          
          A[31] = 1'b1; // Atribui 1 ao bit mais significativo de A
          
        end         

        counter = counter + 1; // Incrementa o contador
        
      end //else
    
      if(counter == 6'b100001) begin // Verifica se o contador chegou ao valor final
        
        LO = multiplier; // Atribui o valor do multiplicador a LO
        HI = A; // Atribui o valor de A a HI
        
      end
        
      
    end //if1
    
    else begin // Caso a multiplicação não esteja habilitada ou o reset esteja ativado
      
      counter = 6'b000000; // Atribui o valor inicial ao contador
      multiplier = 32'b00000000000000000000000000000000; // Atribui o valor inicial ao multiplicador
      multiplicand = 32'b00000000000000000000000000000000; // Atribui o valor inicial ao multiplicando
      Q1 = 1'b0; // Atribui 0 ao bit Q1
      A = 32'b00000000000000000000000000000000; // Atribui o valor inicial a A
      
    end
  
  end //always
  
endmodule
