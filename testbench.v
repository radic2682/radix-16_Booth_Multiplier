`timescale 1ns/100ps

module testbench;

reg [6:0] in1;
reg [8:0] in2;

wire [15:0] out;
wire overflow;

multiplier_16b multiplier_16b_m0 (in1, in2, out, overflow);

initial begin

in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h7f;
in2 = 9'h1ff;

#100

in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h3f;
in2 = 9'h1ff;

#100


in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h7f;
in2 = 9'hff;

#100

in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h7e;
in2 = 9'h1af;

#100

in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h5b;
in2 = 9'h1ef;

#100

in1 = 7'h00;
in2 = 9'h00;

#100

in1 = 7'h6c;
in2 = 9'h17c;

#100

in1 = 7'h00;
in2 = 9'h00;

end
endmodule


