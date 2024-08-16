module DSP ( A , B , C , D , CARRYIN , M , P , CARRYOUT , CARRYOUTF ,
clk , OPMODE , 
CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP ,
RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP,
BCOUT, BCIN , PCIN , PCOUT );

  parameter A0REG =0;
  parameter A1REG =1;
  parameter B0REG =0;
  parameter B1REG =1;

  parameter CREG = 1;
  parameter DREG = 1;
  parameter MREG = 1;
  parameter PREG = 1;
  parameter CARRYINREG = 1;
  parameter CARRYOUTREG = 1;
  parameter OPMODEREG = 1;
  
  parameter CARRYINSEL = "OPMODE5";
  parameter B_INPUT = "DIRECT";
  parameter RSTTYPE = "SYNC";
  
  input [17:0] A , B , D;
  input [47:0] C;
  input CARRYIN;
  
  output [35:0] M;
  output [47:0] P;
  output CARRYOUT , CARRYOUTF;
  
  input clk;
  input [7:0] OPMODE;
  //clock enable input ports
  input CEA , CEB , CEC , CECARRYIN , CED , CEM , CEOPMODE , CEP;
  //reset ports
  input RSTA , RSTB , RSTC , RSTCARRYIN , RSTD , RSTM , RSTOPMODE , RSTP;
  
  output [17:0] BCOUT;
  output [47:0] PCOUT;
  input [47:0] PCIN;
  input [17:0] BCIN;
  
  wire [17:0] D_REG_out;
  wire [17:0] B0_REG_out;
  wire [17:0] B1_REG_out;
  wire [17:0] A0_REG_out;
  wire [17:0] A1_REG_out;
  wire [47:0] C_REG_out;
  
  wire [17:0] B_out_mux;
  wire [35:0] multiplier_out;
  wire [35:0] multiplier_REG_out;
  
  wire carryi;
  wire carryi_REG_out;
  wire [7:0] opmode_REG;  // this should be used in operations as selector
  wire cout_post_adder;
  wire [47:0] post_adder_subtractor;
  wire [17:0] pre_adder_subtractor;
  wire [17:0] pre_adder_subtractor_mux;
  wire [47:0] DAB_concatenated;
  
  wire [47:0] x_out;
  wire [47:0] z_out;
  
  assign B_out_mux = (B_INPUT == "DIRECT")?B:(B_INPUT == "CASCADE")?BCIN:0;
  assign CARRYOUTF = CARRYOUT;
  assign BCOUT = B1_REG_out;
  assign carryi = (CARRYINSEL == "CARRYIN")?CARRYIN:(CARRYINSEL == "OPMODE5")?opmode_REG[5]:0;       //carry sel mux
  
  assign pre_adder_subtractor_mux = (opmode_REG[4])?pre_adder_subtractor:B0_REG_out;
  
  assign DAB_concatenated = { D_REG_out[11:0] , A1_REG_out[17:0] , B1_REG_out[17:0] };
  
  assign pre_adder_subtractor = (opmode_REG[6])?(D_REG_out - B0_REG_out):(D_REG_out + B0_REG_out);
  assign multiplier_out = A1_REG_out * B1_REG_out;
  
  assign post_adder_subtractor = (opmode_REG[7])?(z_out - (x_out + carryi_REG_out)):(z_out + (x_out + carryi_REG_out)) ;
  
  assign M = ~(~multiplier_REG_out); ////////how to make a buffer??
   
  assign PCOUT = P;
  //inistantiations
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(18) ) D_REG ( .clk(clk), .rst(RSTD) , .EN(CED) , .D(D) , .sel(DREG) , .out(D_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(18) ) B0_REG ( .clk(clk), .rst(RSTB) , .EN(CEB) , .D(B_out_mux) , .sel(B0REG) , .out(B0_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(18) ) A0_REG ( .clk(clk), .rst(RSTA) , .EN(CEA) , .D(A) , .sel(A0REG) , .out(A0_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(48) ) C_REG ( .clk(clk), .rst(RSTC) , .EN(CEC) , .D(C) , .sel(CREG) , .out(C_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(18) ) A1_REG ( .clk(clk), .rst(RSTA) , .EN(CEA) , .D(A0_REG_out) , .sel(A1REG) , .out(A1_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(18) ) B1_REG ( .clk(clk), .rst(RSTB) , .EN(CEB) , .D(pre_adder_subtractor_mux) , .sel(B1REG) , .out(B1_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(36) ) M_REG ( .clk(clk), .rst(RSTM) , .EN(CEM) , .D(multiplier_out) , .sel(MREG) , .out(multiplier_REG_out) );

  reg_mux #( .RSTTYPE(RSTTYPE) , .N(1) ) CYI ( .clk(clk), .rst(RSTCARRYIN) , .EN(CECARRYIN) , .D(carryi) , .sel(CARRYINREG) , .out(carryi_REG_out) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(8) ) OPMODE_REG ( .clk(clk), .rst(RSTOPMODE) , .EN(CEOPMODE) , .D(OPMODE) , .sel(OPMODEREG) , .out(opmode_REG) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(1) ) CYO ( .clk(clk), .rst(RSTCARRYIN) , .EN(CECARRYIN) , .D(cout_post_adder) , .sel(CARRYOUTREG) , .out(CARRYOUT) );
  
  reg_mux #( .RSTTYPE(RSTTYPE) , .N(48) ) P_REG ( .clk(clk), .rst(RSTP) , .EN(CEP) , .D(post_adder_subtractor) , .sel(PREG) , .out(P) );
  
  
  mux4x1 #(.N(36)) X (.in0(48'b0) , .in1(multiplier_REG_out) , .in2(P) , .in3(DAB_concatenated) , .sel(opmode_REG[1:0]) , .out(x_out));
  mux4x1 #(.N(48)) Z (.in0(48'b0) , .in1(PCIN) , .in2(P) , .in3(C_REG_out) , .sel(opmode_REG[3:2]) , .out(z_out));
  
  
endmodule

