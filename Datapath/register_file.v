
// Register File

// word_width = 32 bits
// reg_file_depth = 32 words

module register_file(clk,A1,A2,A3,WD3,RD1,RD2,rst,WE);

input clk,rst,WE;
input[4:0] A1,A2,A3;
input[31:0] WD3;
output[31:0] RD1,RD2;

reg[31:0] reg_file[0:15];

integer i;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 16; i = i + 1)
            reg_file[i] <= 32'd0;
    end else if (WE) begin
        reg_file[A3] <= WD3;
    end
end

// Read ports with write-through (avoid RAW hazards)
assign RD1 = (WE && (A1 != 0) && (A1 == A3)) ? WD3 : reg_file[A1];
assign RD2 = (WE && (A2 != 0) && (A2 == A3)) ? WD3 : reg_file[A2];

endmodule
