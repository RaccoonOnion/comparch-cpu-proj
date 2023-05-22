`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 17:07:15
// Design Name: 
// Module Name: Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module control32(Op,Func,ALUop,Jr,Jal,Branch,nBranch,RegDST,MemtoReg,RegWrite,MemWrite,ALUSrc,Sftmd,Alu_resultHigh,MemorIOtoReg,MemRead,IORead,IOWrite);
input[21:0] Alu_resultHigh;
output reg MemorIOtoReg; //1 indicates that read date from memory or I/O to write to the register
output reg MemRead; // 1 indicates that reading from the memory to get data
output reg IORead; // 1 indicates I/O read
output reg IOWrite; // 1 indicates I/O w
    input[5:0] Op; // instruction[31:26], opcode
    input[5:0] Func; // instructions[5:0], funct
    output reg [1:0] ALUop;
    output reg Jr ; // 1 indicates the instruction is "jr", otherwise it's not "jr" output Jmp; // 1 indicate the instruction is "j", otherwise it's not
    output reg Jal; // 1 indicate the instruction is "jal", otherwise it's not
    output reg Branch; // 1 indicate the instruction is "beq" , otherwise it's not
    output reg nBranch;
    output reg RegDST; // 1 indicate destination register is "rd"(R),otherwise it's "rt"(I)
    output reg MemtoReg; // 1 indicate read data from memory and write it into register
   
    output reg RegWrite; // 1 indicate write register(R,I(lw)), otherwise it's not
    output reg MemWrite; // 1 indicate write data memory, otherwise it's not
    output reg ALUSrc; // 1 indicate the 2nd data is immidiate (except "beq","bne")
    output reg Sftmd; // 1 indicate the instruction is shift instruction
    reg R_format;
     reg I_format;
      reg lw;
       reg sw;
    
    always@(Op,Func)
    begin
    Jr =((Op==6'b000000)&&(Func==6'b001000)) ? 1'b1 : 1'b0;//1
  R_format = (Op==6'b000000)? 1'b1:1'b0;
    RegDST = R_format;//2
     I_format= (Op[5:3]==3'b001)? 1'b1:1'b0;
     lw= (Op==6'b100011)? 1'b1:1'b0;
      Branch= (Op==6'b000100)? 1'b1:1'b0;
       nBranch= (Op==6'b000101)? 1'b1:1'b0;
       Jal= (Op==6'h03)? 1'b1:1'b0;//6
 RegWrite = (R_format || lw || Jal || I_format) && !(Jr);//3
 ALUop = { (R_format || I_format) , (Branch || nBranch) };//4
 Sftmd = (((Func==6'b000000)||(Func==6'b000010)
 ||(Func==6'b000011)||(Func==6'b000100)
 ||(Func==6'b000110)||(Func==6'b000111))
 && R_format) ? 1'b1 : 1'b0;//5
 ALUSrc= (Op==6'b000000)? 1'b0:1'b1;//6
 MemtoReg=(Op==6'b100011)? 1'b1:1'b0;//6
 MemWrite=((sw==1) && (Alu_resultHigh[21:0] != 22'h3FFFFF)) ?1'b1:1'b0;
 MemRead= ((lw==1) && (Alu_resultHigh[21:0] != 22'h3FFFFF))?1'b1:1'b0;
  IORead = ((lw==1) && (Alu_resultHigh[21:0] == 22'h3FFFFF))?1'b1:1'b0;
 IOWrite = ((sw==1) && (Alu_resultHigh[21:0] == 22'h3FFFFF)) ?1'b1:1'b0;
 MemorIOtoReg=IORead||MemRead;
 
 
 
   
    
    end
endmodule
