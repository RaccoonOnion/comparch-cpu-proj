`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/22 16:26:02
// Design Name: 
// Module Name: cputop
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


module cputop( clock,reset);
input clock;
wire clkcpu;
cpuclk cpucl(clock,clkcpu);
input reset;
wire [31:0] Instruction; // the instruction fetched from this module to Decoder and Controller
//wire[31:0]  Read_data_1;		// �����뵥Ԫ��Read_data_1����
   //wire[31:0]  Read_data_2;		// �����뵥Ԫ��Read_data_2����
   // wire[31:0]  Sign_extend;		// �����뵥Ԫ������չ���������
 //  wire[5:0]   Function_opcode;  	// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
   //wire[5:0]   Exe_opcode;  		// ȡָ��Ԫ���Ĳ�����
  //  wire[1:0]   ALUOp;             // ���Կ��Ƶ�Ԫ������ָ����Ʊ���
   wire[4:0]   Shamt;             // ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
   assign Shamt= Instruction[10:6];
  //  wire 		 Sftmd;            // ���Կ��Ƶ�Ԫ�ģ���������λָ��
   // wire        ALUSrc;            // ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
  //  wire        I_format;          // ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
   // wire        Jr;               // ���Կ��Ƶ�Ԫ��������JRָ��
    wire       Zero;              // Ϊ1��������ֵΪ0 
    wire[31:0] ALU_Result;        // ��������ݽ��
    wire[31:0] Addr_Result;		// ����ĵ�ַ���        
   // wire[31:0]  PC_plus_4;         // ����ȡָ��Ԫ��PC+4


wire  [31:0] branch_base_addr; // (pc+4) to ALU which is used by branch type instruction
wire [31:0] link_addr; // (pc+4) to Decoder which is used by jal instruction
//from CPU TOP

// from ALU

//wire[31:0] Addr_result; // the calculated address from ALU

//wire Zero; // while Zero is 1, it means the ALUresult is zero
// from Decoder
wire[31:0] Read_data_1; // the address of instruction used by jr instruction
 wire[31:0] ra;
assign Read_data_1=ra;

// from Controller
//wire Branch; // while Branch is 1,it means current instruction is beq
// nBranch; // while nBranch is 1,it means current instruction is bnq
// Jmp; // while Jmp 1, it means current instruction is jump
//wire Jal; // while Jal is 1, it means current instruction is jal
//wire Jr; // while Jr is 1, it means current instruction is j
 wire[31:0] read_data_1;               // ����ĵ�һ������
   wire[31:0] read_data_2;               // ����ĵڶ�������
  
   //wire[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
  wire[31:0]  mem_data;                   //  ��DATA RAM or I/O portȡ��������
   wire[31:0]  ALU_result;                   // ��ִ�е�Ԫ��������Ľ��
  // wire        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
   //wire      RegWrite;                  // ���Կ��Ƶ�Ԫ
  //wire        MemtoReg;              // ���Կ��Ƶ�Ԫ
  //wire       RegDst;             
   wire[31:0] Sign_extend;               // ��չ���32λ������
                
  wire[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
  assign opcplus4=link_addr;
  
  wire[5:0]   Opcode;            // ����IFetchģ���ָ���6bit
  assign Opcode=Instruction[31:26];
      wire[5:0]   Function_opcode;      // ����IFetchģ���ָ���6bit����������r-�����е�ָ��
      assign Function_opcode=Instruction[5:0];
     wire     Jr;              // Ϊ1������ǰָ����jr��Ϊ0��ʾ��ǰָ���jr
     wire       RegDST;          // Ϊ1����Ŀ�ļĴ�����rd��Ϊ0ʱ��ʾĿ�ļĴ�����rt
      wire      ALUSrc;          // Ϊ1�����ڶ�����������ALU�е�Binput��������������beq��bne���⣩��Ϊ0ʱ��ʾ�ڶ������������ԼĴ���
      wire       MemtoReg;     // Ϊ1�����Ӵ洢����I/O��ȡ����д���Ĵ�����Ϊ0ʱ��ʾ��ALUģ���������д���Ĵ���
      wire      RegWrite;         // Ϊ1������ָ����Ҫд�Ĵ�����Ϊ0ʱ��ʾ����Ҫд�Ĵ���
      wire       MemWrite;       // Ϊ1������ָ����Ҫд�洢����Ϊ0ʱ��ʾ����Ҫд������
     wire       Branch;        // Ϊ1������beqָ�Ϊ0ʱ��ʾ����beqָ��
     wire       nBranch;       // Ϊ1������bneָ�Ϊ0ʱ��ʾ����bneָ��
      wire       Jmp;            // Ϊ1������jָ�Ϊ0ʱ��ʾ����jָ��
      wire       Jal;            // Ϊ1������jalָ�Ϊ0ʱ��ʾ����jalָ��
      wire       I_format;      // Ϊ1������ָ���ǳ�beq��bne��lw��sw֮���I-����ָ��������Ϊ0
      wire      Sftmd;         // Ϊ1��������λָ�Ϊ0����������λָ��
      wire[1:0]  ALUOp;        // ��ָ��ΪR-type��I_formatΪ1ʱ��ALUOp�ĸ߱���λΪ1������߱���λΪ0; ��ָ��Ϊbeq��bneʱ��ALUOp�ĵͱ���λΪ1������ͱ���λΪ0
      
     
      //wire memWrite;
      // the ��Address�� of memory unit which is toberead/writen
     wire[31:0] address;
      // data tobe wirten to the memory unit
      assign address=ALU_Result;
     wire[31:0] writeData;
      /*data to be read from the memory unit, in the left
      screenshot its name is ��MemData�� */
      wire[31:0] readData;
      assign writeData=read_data_1;

Ifetc32 ife(Instruction, branch_base_addr, link_addr,  clkcpu, reset, Addr_Result,Read_data_1, Branch, nBranch, Jmp, Jal, Jr, Zero);
decode32 deco(read_data_1,read_data_2,ra,Instruction,mem_data,ALU_result,Jal,RegWrite,MemtoReg,RegDST,Sign_extend, clkcpu,reset,opcplus4);
control32 cont(Opcode, Function_opcode, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
executs32 exec(read_data_1,read_data_2,Sign_extend,Function_opcode,Opcode,ALUOp,Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,branch_base_addr);
dmemory32 dmem( clkcpu,MemWrite,address,writeData,readData);
endmodule
