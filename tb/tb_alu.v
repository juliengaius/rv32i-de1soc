`timescale 1ns/1ps

module tb_alu;
	reg [31:0] a, b;
	reg [3:0] alu_op;
	wire [31:0] result;
	integer errors;

alu dut(.a(a), .b(b), .alu_op(alu_op), .result(result));

task check;
	input [3:0] op;
	input [31:0] in_a, in_b, expected;
	begin
		a = in_a; b = in_b; alu_op = op;
		#10;
		if (result !== expected) begin
		$display("FAIL op=%b a=%h b=%h got=%h expected=%h", op, in_a, in_b, result, expected);
		errors = errors + 1;
		end
		else
		$display("PASS op=%b a=%h b=%h result=%h", op, in_a, in_b, result);
	end
	endtask

	initial begin
		errors = 0;
		check(4'b0000, 32'd5, 32'd3, 32'd8); // ADD
		check(4'b0000, 32'hFFFFFFFF, 32'd1, 32'h00000000);  // ADD wraps
		check(4'b1000, 32'd3, 32'd5, 32'hFFFFFFFE);  // SUB negative result
		check(4'b0001, 32'd1, 32'd4, 32'h00000010);  // SLL basic
		check(4'b0001, 32'd1, 32'd31,32'h80000000);  // SLL max shift
		check(4'b0001, 32'd1, 32'd32,32'h00000001);  // SLL only b[4:0] counts
		check(4'b0010, 32'hFFFFFFFF, 32'd1, 32'h00000001);  // SLT -1 < 1 signed
		check(4'b0011, 32'hFFFFFFFF, 32'd1, 32'h00000000);  // SLTU huge, not less
		check(4'b0100, 32'hF0F0F0F0, 32'hFFFF0000, 32'h0F0FF0F0);  // XOR
		check(4'b0101, 32'h80000000, 32'd4, 32'h08000000);  // SRL zero fill
		check(4'b1101, 32'h80000000, 32'd4, 32'hF8000000);  // SRA sign fill
		check(4'b1101, 32'h40000000, 32'd4, 32'h04000000);  // SRA positive stays positive
		check(4'b0110, 32'hF0F0F0F0, 32'h0F0F0000, 32'hFFFFF0F0);  // OR
		check(4'b0111, 32'hF0F0F0F0, 32'hFF00FF00, 32'hF000F000);  // AND
		check(4'b1111, 32'h12345678,  32'd1, 32'h00000000);  // unused op -> default
		$display("Done: %0d errors", errors);
		$stop;
	end
endmodule

