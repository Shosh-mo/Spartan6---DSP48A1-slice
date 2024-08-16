module reg_mux ( clk , rst , EN , D , sel , out);
  parameter RSTTYPE = "SYNC";
  parameter N = 18;
   
  input clk , rst ,EN;
  input sel;
  input [N-1 : 0] D;
  output [N-1 : 0] out;
  reg [N-1 : 0] Q;
  reg [N-1 : 0] QA ,QS;
  
  assign out = (sel)?Q:D; 
  always @(posedge clk , posedge rst) begin
        if(EN) begin
              if(rst)
                  QA <= 'b0;
              else 
                  QA <= D;
        end
  end
  
  always @(posedge clk) begin
          if(EN) begin
                if(rst)
                    QS <= 'b0;
                else 
                    QS <= D;
          end
   end
    
    always @ (*) begin
        if (RSTTYPE == "ASYNC")
            Q <= QA;
        else if(RSTTYPE == "SYNC")
            Q <= QS;
    end
  
endmodule

 //if selector =1 so take the output of the register
/*  
  always @ (posedge clk , posedge rst) begin
    
      if (RSTTYPE == "ASYNC") begin
            if(rst)
                Q <= 'b0;
            else 
                Q <= D;
      end
    
      else if (RSTTYPE == "SYNC") begin
            if(clk) begin
                if(rst)
                    Q <= 'b0;
                else
                    Q <= D;
            end
      end
  
  end 
  */
