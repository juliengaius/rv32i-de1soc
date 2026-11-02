`timescale 1ns/1ps
module tb_immgen;
	reg [31:0] instr;
	wire [31:0] imm;
	integer errors;
	
immgen dut(.instr(instr), .imm(imm));

task check;
	input [31:0] in_instr, expected;
	begin
		instr = in_instr;
		#10;
		if (imm !== expected) begin
			$display("FAIL instr=%h got=%h expected=%h", in_instr, imm, expected);
			errors = errors + 1;
		end
		else
		$display("PASS instr=%h imm=%h", in_instr, imm);
	end
endtask


initial begin
errors = 0;

// I type
check(32'hFFB00093, 32'hFFFFFFFB);  // addi x1, x0, -5
check(32'h0080A103, 32'h00000008);  // lw   x2, 8(x1)
check(32'hFF0100E7, 32'hFFFFFFF0);  // jalr x1, -16(x2)

// S type
check(32'h0020A623, 32'h0000000C);  // sw x2, 12(x1)
check(32'hFE20AE23, 32'hFFFFFFFC);  // sw x2, -4(x1)
// B type
check(32'h00208863, 32'h00000010);  // beq x1, x2, 16
check(32'hFE209CE3, 32'hFFFFFFF8);  // bne x1, x2, -8
check(32'h002080E3, 32'h00000800);  // beq x1, x2, 2048  (tests instr[7] -> bit 11)
// U type
check(32'h123452B7, 32'h12345000);  // lui   x5, 0x12345
check(32'hFFFFF317, 32'hFFFFF000);  // auipc x6, 0xFFFFF
// J type
check(32'h001000EF, 32'h00000800);  // jal x1, 2048  (tests instr[20] -> bit 11)
check(32'h0000106F, 32'h00001000);  // jal x0, 4096  (tests instr[19:12])
check(32'hFFDFF06F, 32'hFFFFFFFC);  // jal x0, -4
// R type has no immediate -> default
check(32'h002081B3, 32'h00000000);  // add x3, x1, x2
$display("Done: %0d errors", errors);
$stop;
end
endmodule