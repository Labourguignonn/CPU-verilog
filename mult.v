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
    
    if(multControl == 1'b1 && reset == 1'b0) begin
      
      if(counter == 6'b000000) begin
        
        multiplier = aInput;
        multiplicand = bInput;
        counter = counter + 1;
        
      end
      else begin
        
        if(multiplier[0] == 1'b1 && Q1 == 1'b0) begin
          
          A = A - multiplicand;
        
        end
        
        else if(multiplier[0] == 1'b0 && Q1 == 1'b1) begin
          
          A = A + multiplicand;
          
        end
        
        {A, multiplier, Q1} = {A, multiplier, Q1} >> 1'b1;
        
        
        if(A[30] == 1'b1) begin
          
          A[31] = 1'b1;
          
        end         

        counter = counter + 1;
        
      end //else
    
      if(counter == 6'b100001) begin
        
        LO = multiplier;
        HI = A;
        
      end
        
      
    end //if1
    
    else begin
      
      counter = 6'b000000;
      multiplier = 32'b00000000000000000000000000000000;
      multiplicand = 32'b00000000000000000000000000000000;
      Q1 = 1'b0;
      A = 32'b00000000000000000000000000000000;
      
    end
  
  end //always
  
endmodule
