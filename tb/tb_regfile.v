`timescale 1ns/1ps
module tb_regfile;
	reg clk, we;
	reg [4:0] rs1, rs2, rd;
	reg [31:0] wdata;
	wire [31:0] rdata1, rdata2;
	integer errors, i;


regfile dut(.clk(clk), .we(we), .rs1(rs1), .rs2(rs2), .rd(rd), .wdata(wdata), .rdata1(rdata1), .rdata2(rdata2));

	initial clk = 0;
	always #5 clk = ~clk;

	task write_reg;
		input [4:0] r;
		input [31:0] v;
		begin
			@(negedge clk);
			we = 1; rd = r; wdata = v;
			@(negedge clk);
			we = 0;
		end
	endtask

	task check_read;
		input [4:0] r1, r2;
		input [31:0] exp1, exp2;
		begin
			rs1 = r1; rs2 = r2;
			#1;
			if (rdata1 !== exp1 || rdata2 !== exp2) begin
				$display("FAIL rs1=x%0d got=%h exp=%h | rs2=x%0d got=%h exp=%h", r1, rdata1, exp1, r2, rdata2, exp2);
				errors = errors + 1;
			end
			else
				$display("PASS rs1=x%0d=%h rs2=x%0d=%h", r1, rdata1, r2, rdata2);
		end
	endtask

initial begin
	errors = 0; we = 0; rd = 0; wdata = 0; rs1 = 0; rs2 = 0;
	
	write_reg(5'd1, 32'h11111111);
	write_reg(5'd2, 32'h22222222);
	check_read(5'd1, 5'd2, 32'h11111111, 32'h22222222);

	write_reg(5'd0, 32'hDEADBEEF);
	check_read(5'd0, 5'd0, 32'h00000000, 32'h00000000);

	write_reg(5'd3, 32'h00000005);
	@(negedge clk); we = 0; rd = 5'd3; wdata = 32'h00000099;
	@(negedge clk);
	check_read(5'd3, 5'd3, 32'h00000005, 32'h00000005);

	write_reg(5'd1, 32'hCAFEF00D);
	check_read(5'd1, 5'd2, 32'hCAFEF00D, 32'h22222222);

	for (i = 1; i < 32; i = i + 1)
		write_reg(i, i * 32'h01010101);
		for (i = 1; i < 32; i = i + 1)
			check_read(i, 0, i * 32'h01010101, 32'h00000000);

		$display("Done: %0d errors", errors);
		$stop;
	end
endmodule

