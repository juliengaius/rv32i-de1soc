module regfile(clk, we, rs1, rs2, rd, wdata, rdata1, rdata2);
	input clk, we;
	input [4:0] rs1, rs2, rd;
	input [31:0] wdata;
	output [31:0] rdata1, rdata2;
	
	reg [31:0] regs [0:31];
	
	always@(posedge clk) begin
		if (we && (rd != 5'd0))
		regs[rd] <= wdata;
	end
	
	assign rdata1 = (rs1 == 5'd0) ? 32'd0 : regs[rs1];
	assign rdata2 = (rs2 == 5'd0) ? 32'd0 : regs[rs2];

endmodule
