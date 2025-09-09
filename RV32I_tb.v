

// RV32I Testbench

module RV32I_tb();

reg fun_clk,scan_clk,fun_rst,scan_rst,test_mode;

RV32I DUT(fun_clk,scan_clk,fun_rst,scan_rst,test_mode);

initial begin
	fun_clk=0;
	forever
	#5 fun_clk=~fun_clk;
end
/*
initial $readmemh("inst_memory.mem",DUT.Inst_Mem.inst_mem);
initial $readmemh("data_memory.mem",DUT.DAT_MEM.data_mem);
initial $readmemh("reg_file_memory.mem",DUT.RF.reg_file);

initial begin
	rst=1;
	#10
	rst=0;
	#400
	$writememh("final_data_memory.mem",DUT.DAT_MEM.data_mem);
	$writememh("final_reg_file_memory.mem",DUT.RF.reg_file);
	#400
	$stop;
end
*/
	initial begin
	fun_rst=1;
	test_mode = 0;
	#10
	fun_rst=0;
	#400
	$stop;
end

endmodule

