
`include "instruction_memory.v"
`include "alu.v"
`include "Mux2x1.v"
`include "Mux4x1.v"
`include "hazard_unit.v"
`include "pc.v"
`include "IF_DEC_Reg.v"
`include "adder.v"
`include "control_unit.v"
`include "register_file.v"
`include "imm_extend.v"
`include "DEC_EX_Reg.v"
`include "EX_MEM_Reg.v"
`include "data_memory.v"
`include "MEM_WB_Reg.v"


module RV32I(fun_clk,scan_clk,fun_rst,scan_rst,test_mode,pc_out,alu_out);

input fun_clk,scan_clk,fun_rst,scan_rst,test_mode;
output[31:0] pc_out,alu_out;

wire clk,rst;

wire[31:0] pc_current,pc_nxt,ImmExtD,ImmExtE,ALUResultE,ALUResultM,ALUResultW,PCTargetE,WriteDataM,ReadDataM,ReadDataW;
wire[31:0] PCPlus4F,InstF,InstD,PCD,PCPlus4D,RD1D,RD2D,RD1E,RD2E,PCE,PCPlus4E,PCPlus4M,PCPlus4W,SrcBE1,SrcBE2,SrcAE,ResultW;


wire ZeroE,PCSrcE,BranchCond,FlushE,FlushD,StallD,StallF;

wire RegWriteD,MemWriteD,JumpD,BranchD,ALUSrcD;
wire RegWriteE,MemWriteE,JumpE,BranchE,ALUSrcE;
wire RegWriteM,MemWriteM;
wire RegWriteW;

wire[4:0] RdE,RdM,RdW,Rs1E,Rs2E;

wire[1:0] ResultSrcD,ImmSrcD,MemStrobeD,ResultSrcE,ResultSrcM,ResultSrcW,ImmSrcE,MemStrobeE,MemStrobeM,ForwardAE,ForwardBE;

wire[3:0] ALUControlD,ALUControlE;


////////////DFT MUXES///////////////////

 
 // mux_clock 
 Mux2x1 U0_Mux2x1(
	.in_0(fun_clk)   ,
	.in_1(scan_clk)  ,
	.sel(test_mode)  ,
	.out(clk)
 ); 
 // mux_reset
 Mux2x1 U1_Mux2x1(
	.in_0(fun_rst)   ,
	.in_1(scan_rst)  ,
	.sel(test_mode)  ,
	.out(rst)
 );  

/////////////////Hazard Unit/////////////////

hazard_unit HU(
	Rs1E,Rs2E,InstD[19:15],InstD[24:20],
	RdE,RdM,RdW,RegWriteM,RegWriteW,ResultSrcE[0],
	PCSrcE,FlushE,FlushD,StallD,StallF,ForwardAE,ForwardBE);

/////////////////START OF FETCH STAGE/////////////////

pc PC(pc_current,pc_nxt,clk,rst,StallF);

instruction_memory Inst_Mem(pc_nxt,InstF);

IF_DEC_Reg FD_Reg(InstF,InstD,pc_nxt,PCD,PCPlus4F,PCPlus4D,clk,rst,StallD,FlushD);

addr PCPlus4(pc_nxt,32'd4,PCPlus4F);

/////////////////END OF FETCH STAGE/////////////////


/////////////////START OF DECODE STAGE/////////////////

control_unit CU(
	InstD[6:0],{InstD[30],InstD[5],InstD[14:12]},
	RegWriteD,ResultSrcD,MemWriteD,JumpD,BranchD,ALUControlD,ALUSrcD,ImmSrcD,MemStrobeD
	);

register_file RF(clk,InstD[19:15],InstD[24:20],RdW,ResultW,RD1D,RD2D,rst,RegWriteW);

imm_extend ImmExt(InstD[31:7],ImmSrcD,ImmExtD);

DEC_EX_Reg DE_Reg(
	 clk,rst,RegWriteD,MemWriteD,JumpD,BranchD,ALUSrcD,FlushE,
     ResultSrcD,ImmSrcD,MemStrobeD,
     ALUControlD,
     RD1D,RD2D,PCD,ImmExtD,PCPlus4D,
     InstD[11:7],InstD[19:15],InstD[24:20],
     RegWriteE,MemWriteE,JumpE,BranchE,ALUSrcE,
     ResultSrcE,ImmSrcE,MemStrobeE,
     ALUControlE,
     RD1E,RD2E,PCE,ImmExtE,PCPlus4E,
	 RdE,Rs1E,Rs2E
	);

/////////////////END OF DECODE STAGE/////////////////


/////////////////START OF EXECUTE STAGE/////////////////

assign SrcBE1 = (ForwardBE==2)?ALUResultM:(ForwardBE==1)?ResultW:RD2E;

assign SrcBE2 = ALUSrcE?ImmExtE:SrcBE1;

assign SrcAE = (ForwardAE==2)?ALUResultM:(ForwardAE==1)?ResultW:RD1E;

alu ALU(SrcAE,SrcBE2,ALUResultE,ZeroE,ALUControlE);

addr JMPADDER(PCE,ImmExtE,PCTargetE);

and(BranchCond,ZeroE,BranchE);
or(PCSrcE,JumpE,BranchCond);

assign pc_current = PCSrcE?PCTargetE:PCPlus4F;

EX_MEM_Reg EM_Reg(
	 clk,rst,RegWriteE,MemWriteE,
	 ResultSrcE,MemStrobeE,
	 ALUResultE,SrcBE1,RdE,PCPlus4E,
     RegWriteM,MemWriteM,
	 ResultSrcM,MemStrobeM,
	 ALUResultM,WriteDataM,PCPlus4M,
	 RdM
	);

/////////////////END OF EXECUTE STAGE/////////////////


/////////////////START OF WRITE BACK STAGE/////////////////

data_memory DAT_MEM(ALUResultM,MemStrobeM,WriteDataM,clk,rst,MemWriteM,ReadDataM);

MEM_WB_Reg MW_Reg(
	clk,rst,RegWriteM,
	ResultSrcM,
	RdM,
	ALUResultM,ReadDataM,PCPlus4M,
	RegWriteW,
	ResultSrcW,
	RdW,
	ALUResultW,ReadDataW,PCPlus4W
	);

Mux4x1 U0_Mux4x1(
	.in_0(ALUResultW),
	.in_1(ReadDataW),
	.in_2(PCPlus4W),
	.sel(ResultSrcW),
	.out(ResultW)
);

//assign ResultW = (ResultSrcW==0)?ALUResultW:(ResultSrcW==1)?ReadDataW:(ResultSrcW==2)?PCPlus4W:0;

/////////////////END OF WRITE BACK STAGE/////////////////

//////////// OUTS //////////////

assign pc_out = pc_nxt;
assign alu_out = ALUResultW;

endmodule

