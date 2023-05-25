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


module cputop( clock,reset, ioread_data_switch,seg_en,seg_out0);
input clock;
wire clkcpu;
cpuclk cpucl(.clk_out1(clkcpu),.clk_in1(clock));
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
wire[31:0] Read_data_ra; // the address of instruction used by jr instruction



// from Controller
//wire Branch; // while Branch is 1,it means current instruction is beq
// nBranch; // while nBranch is 1,it means current instruction is bnq
// Jmp; // while Jmp 1, it means current instruction is jump
//wire Jal; // while Jal is 1, it means current instruction is jal
//wire Jr; // while Jr is 1, it means current instruction is j
 wire[31:0] read_data_1;               // ����ĵ�һ������
   wire[31:0] read_data_2;               // ����ĵڶ�������
  
   //wire[31:0]  Instruction;               // ȡָ��Ԫ����ָ��
 // wire[31:0]  mem_data;                   //  ��DATA RAM or I/O portȡ��������
   //wire[31:0]  ALU_result;                   // ��ִ�е�Ԫ��������Ľ��
  // wire        Jal;                       //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
   //wire      RegWrite;                  // ���Կ��Ƶ�Ԫ
  //wire        MemtoReg;              // ���Կ��Ƶ�Ԫ
  //wire       RegDst;             
   wire[31:0] Sign_extend;               // ��չ���32λ������
                
  wire[31:0]  opcplus4;                 // ����ȡָ��Ԫ��JAL����
  assign opcplus4=link_addr;
  
wire [5:0]   Opcode;            // ����IFetchģ���ָ���6bit
 
  assign Opcode=Instruction[31:26];
 
      wire [5:0]   Function_opcode;      // ����IFetchģ���ָ���6bit����������r-�����е�ָ��
   
      assign  Function_opcode=Instruction[5:0];
    
      wire[15:0] Alu_resultHigh; // From the execution unit Alu_Result[31..10]
      assign Alu_resultHigh=ALU_Result[31:16];
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
      wire MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
     
     wire MemRead; // 1 indicates that the instruction needs to read from the memory
      
      wire IORead; // 1 indicates I/O read
      wire IOWrite; // 1 indicates I/O write
     
      //wire memWrite;
      // the 'Address' of memory unit which is toberead/writen
        wire[31:0] addr_out; // address to Data-Memory
     wire[31:0] address;
      // data tobe wirten to the memory unit
      assign address=addr_out;
     //wire[31:0] writeData;
      /*data to be read from the memory unit, in the left
      screenshot its name is 'MemData' */
      wire[31:0] readDatamem;
      
      //wire mRead; // read memory, from Controller
      //wire mWrite; // write memory, from Controller
      //wire ioRead; // read IO, from Controller
     // wire ioWrite; // write IO, from Controller
     wire[31:0] addr_in; // from alu_result in ALU
     assign addr_in=ALU_Result;
    
     wire[31:0] m_rdata; // data read from Data-Memory
     assign m_rdata=readDatamem;
      //wire[15:0] io_rdata; // data read from IO,16 bits
     wire [31:0]  r_wdata; // data to Decoder(register file)
     // wire[31:0] r_rdata; // data read from Decoder(register file)
     wire[31:0] write_data; // data to memory or I/O��m_wdata, io_wdata��
      wire LEDCtrl; // LED Chip Select
     wire SwitchCtrl;   
      
        //wire			reset,				// reset, active high ��λ�ź� (�ߵ�ƽ��Ч)
       //wire            ior;               // from Controller, 1 means read from input device(�ӿ���������I/O��)
      // wire             switchctrl;            // means the switch is selected as input device (��memorio������ַ�߶��߻�õĲ��뿪��ģ��Ƭѡ)
      input       [3:0]    ioread_data_switch;   // the data from switch(���������Ķ����ݣ��˴����Բ��뿪��)
      wire      [15:0]    ioread_data ;        // the data to memorio (���������������͸�memorio)
      
      // wire		ledrst,		// reset, active high (��λ�ź�,�ߵ�ƽ��Ч)
       // wire          led_clk;    // clk for led (ʱ���ź�)
        //wire            ledwrite,    // led write enable, active high (д�ź�,�ߵ�ƽ��Ч)
       // wire            ledcs;       // 1 means the leds are selected as output (��memorio���ģ��ɵ�����λ�γɵ�LEDƬѡ�ź�)
      //wire   [1:0]    ledaddr;  // 2'b00 means updata the low 16bits of ledout, 2'b10 means updata the high 8 bits of ledout
         wire   [15:0]    ledwdata;    // the data (from register/memorio)  waiting for to be writen to the leds of the board
         assign ledwdata=write_data[15:0];
        wire  [15:0]    ledout ;       // the data writen to the leds  of the board
        output   [3:0] seg_en;
            output  [7:0]  seg_out0;
           
      
        
   
    
   
    
Ifetc32 ife(Instruction, branch_base_addr, link_addr,  clkcpu, reset, Addr_Result,read_data_1,Branch, nBranch, Jmp, Jal, Jr, Zero);
decode32 deco(read_data_1,read_data_2,Instruction,r_wdata,ALU_Result,Jal,RegWrite,MemtoReg,RegDST,Sign_extend, clkcpu,reset,opcplus4);
control32 cont(Opcode, Function_opcode,Sign_extend[31:16], MemorIOtoReg,MemRead,IORead,IOWrite, Jr, RegDST, ALUSrc, MemtoReg, RegWrite, MemWrite, Branch, nBranch, Jmp, Jal, I_format, Sftmd, ALUOp);
executs32 exec(clkcpu,read_data_1,read_data_2,Sign_extend,Function_opcode,Opcode,ALUOp,Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,branch_base_addr);
dmemory32 dmem( clkcpu,MemWrite,ALU_Result,read_data_2,readDatamem);
memori mmemori(  MemRead,IORead,readDatamem,ioread_data_switch,  r_wdata);
//ioread  iore(reset,IORead,	ioread_data_switch,	ioread_data);
leds le(reset,clkcpu,IOWrite, read_data_2[15:0],seg_en,seg_out0);

endmodule
