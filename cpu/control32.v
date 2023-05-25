`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/10 17:04:07
// Design Name: 
// Module Name: control32
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


module control32(Opcode, Function_opcode,Alu_resultHigh, MemorIOtoReg,MemRead,IORead,IOWrite,Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit
    input[5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit，用于区分r-类型中的指令
    input[15:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output reg  MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
    output reg  MemRead; // 1 indicates that the instruction needs to read from the memory
 
    output reg  IORead; // 1 indicates I/O read
    output reg  IOWrite; // 1 ind
    output reg        Jr;         	 // 为1表明当前指令是jr，为0表示当前指令不是jr
    output reg        RegDST;          // 为1表明目的寄存器是rd，为0时表示目的寄存器是rt
    output reg        ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）来自立即数（beq，bne除外），为0时表示第二个操作数来自寄存器
    output reg        MemtoReg;     // 为1表明从存储器或I/O读取数据写到寄存器，为0时表示将ALU模块输出数据写到寄存器
    output reg        RegWrite;   	  // 为1表明该指令需要写寄存器，为0时表示不需要写寄存器
    output reg        MemWrite;       // 为1表明该指令需要写存储器，为0时表示不需要写储存器
    output reg        Branch;        // 为1表明是beq指令，为0时表示不是beq指令
    output reg        nBranch;       // 为1表明是bne指令，为0时表示不是bne指令
    output reg        Jmp;            // 为1表明是j指令，为0时表示不是j指令
    output reg        Jal;            // 为1表明是jal指令，为0时表示不是jal指令
    output reg        I_format;      // 为1表明该指令是除beq，bne，lw，sw之外的I-类型指令，其余情况为0
    output reg        Sftmd;         // 为1表明是移位指令，为0表明不是移位指令
    output reg [1:0]  ALUOp;        // 当指令为R-type或I_format为1时，ALUOp的高比特位为1，否则高比特位为0; 当指令为beq或bne时，ALUOp的低比特位为1，否则低比特位为0
    
   reg R_format;
    reg Lw;
   reg sw;
   always@(*)
   begin
      sw=  (Opcode==6'b101011)? 1'b1:1'b0;
      Lw = (Opcode==6'b100011)? 1'b1:1'b0;
      Jr =((Opcode==6'b000000)&&(Function_opcode==6'b001000)) ? 1'b1 : 1'b0;
      Jmp = ((Opcode==6'b000010)) ? 1'b1 : 1'b0;
      Jal = ((Opcode==6'b000011)) ? 1'b1 : 1'b0;
      Branch = ((Opcode==6'b000100)) ? 1'b1 : 1'b0;
      nBranch = ((Opcode==6'b000101)) ? 1'b1 : 1'b0;
      MemtoReg = ((Opcode==6'b100011)) ? 1'b1 : 1'b0;
       MemWrite = ((sw==1) && (Alu_resultHigh[15:0] != 16'hffff))?1'b1:1'b0;
      MemRead= ((Lw==1) && (Alu_resultHigh[15:0] != 16'hffff))?1'b1:1'b0;
       IORead = ((Lw==1) && (Alu_resultHigh[15:0] == 16'hffff))?1'b1:1'b0;
      IOWrite = ((sw==1) && (Alu_resultHigh[15:0] == 16'hffff)) ?1'b1:1'b0;
      MemorIOtoReg=IORead||MemRead;
      I_format = ((Opcode[5:3]==3'b001) ? 1'b1 : 1'b0);
      ALUSrc = (I_format || MemWrite || Lw||sw) && !Branch && !nBranch;
        
      R_format = (Opcode==6'b000000)? 1'b1:1'b0;
      RegDST = R_format;
      RegWrite = (R_format || Lw || Jal || I_format) && !(Jr);
      ALUOp = { (R_format || I_format) , (Branch || nBranch) };
      Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010)
    ||(Function_opcode==6'b000011)||(Function_opcode==6'b000100)
    ||(Function_opcode==6'b000110)||(Function_opcode==6'b000111))
    && R_format) ? 1'b1 : 1'b0;
    end
endmodule
