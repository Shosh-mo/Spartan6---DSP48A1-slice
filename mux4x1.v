module mux4x1 (in0 , in1 , in2 , in3 , sel , out);
  //this mux has output of 48 bits
  //it has one input with N bits
  parameter N = 36;
  input [47:0] in0 , in2 , in3;
  input [N-1 :0] in1;
  input [1:0] sel;
  output reg [47:0] out;
  
  always @ (*) begin
    if(sel==0)
      out = in0;
    else if(sel==1) begin
      out = in1;
      
      if (N==36) begin
        out[47:36] ='b0;
      end
     
    end
    else if(sel==2)
      out = in2;
    else
      out = in3;
  end
endmodule
