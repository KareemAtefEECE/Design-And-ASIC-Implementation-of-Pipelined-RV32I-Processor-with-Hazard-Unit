
// Instruction Memory

// inst_width = 32 bits
// mem_depth = 256 instruction (2^8)

module instruction_memory(pc_addr,inst);

input[31:0] pc_addr;
output[31:0] inst;

reg[31:0] inst_mem[0:31];

integer i;

assign inst = inst_mem[pc_addr>>2] ;

initial begin
    // program 1

    inst_mem[0]  = 32'h00500113;
    inst_mem[1]  = 32'h00C00193;
    inst_mem[2]  = 32'hFF718393;
    inst_mem[3]  = 32'h0023E233;
    inst_mem[4]  = 32'h0041F2B3;
    inst_mem[5]  = 32'h004282B3;
    inst_mem[6]  = 32'h02728863;
    inst_mem[7]  = 32'h0041A233;
    inst_mem[8]  = 32'h00020463;
    inst_mem[9]  = 32'h00000293;
    inst_mem[10] = 32'h0023A233;
    inst_mem[11] = 32'h005203B3;
    inst_mem[12] = 32'h402383B3;
    inst_mem[13] = 32'h0471AA23;
    inst_mem[14] = 32'h06002103;
    inst_mem[15] = 32'h005104B3;
    inst_mem[16] = 32'h008001EF;
    inst_mem[17] = 32'h00100113;
    inst_mem[18] = 32'h00910133;
    inst_mem[19] = 32'h0221A023;
    inst_mem[20] = 32'h00210063;

     for (i = 21; i < 32; i = i + 1)
        inst_mem[i] = 32'd0;

end

endmodule
