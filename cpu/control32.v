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
    input[5:0]   Opcode;            // ����IFetchģ���ָ���6bit
    input[5:0]   Function_opcode;  	// ����IFetchģ���ָ���6bit����������r-�����е�ָ��
    input[15:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output reg  MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
    output reg  MemRead; // 1 indicates that the instruction needs to read from the memory
 
    output reg  IORead; // 1 indicates I/O read
    output reg  IOWrite; // 1 ind
    output reg        Jr;         	 // Ϊ1������ǰָ����jr��Ϊ0��ʾ��ǰָ���jr
    output reg        RegDST;          // Ϊ1����Ŀ�ļĴ�����rd��Ϊ0ʱ��ʾĿ�ļĴ�����rt
    output reg        ALUSrc;          // Ϊ1�����ڶ�����������ALU�е�Binput��������������beq��bne���⣩��Ϊ0ʱ��ʾ�ڶ������������ԼĴ���
    output reg        MemtoReg;     // Ϊ1�����Ӵ洢����I/O��ȡ����д���Ĵ�����Ϊ0ʱ��ʾ��ALUģ���������д���Ĵ���
    output reg        RegWrite;   	  // Ϊ1������ָ����Ҫд�Ĵ�����Ϊ0ʱ��ʾ����Ҫд�Ĵ���
    output reg        MemWrite;       // Ϊ1������ָ����Ҫд�洢����Ϊ0ʱ��ʾ����Ҫд������
    output reg        Branch;        // Ϊ1������beqָ�Ϊ0ʱ��ʾ����beqָ��
    output reg        nBranch;       // Ϊ1������bneָ�Ϊ0ʱ��ʾ����bneָ��
    output reg        Jmp;            // Ϊ1������jָ�Ϊ0ʱ��ʾ����jָ��
    output reg        Jal;            // Ϊ1������jalָ�Ϊ0ʱ��ʾ����jalָ��
    output reg        I_format;      // Ϊ1������ָ���ǳ�beq��bne��lw��sw֮���I-����ָ��������Ϊ0
    output reg        Sftmd;         // Ϊ1��������λָ�Ϊ0����������λָ��
    output reg [1:0]  ALUOp;        // ��ָ��ΪR-type��I_formatΪ1ʱ��ALUOp�ĸ߱���λΪ1������߱���λΪ0; ��ָ��Ϊbeq��bneʱ��ALUOp�ĵͱ���λΪ1������ͱ���λΪ0
    
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
