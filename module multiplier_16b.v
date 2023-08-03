`timescale 1ns/100ps

module multiplier_16b (in_0, in_1, out, overflow);
	input [6:0] in_0;
	input [8:0] in_1;
	output [15:0] out;
	output overflow;

// Write netlists for your multiplier below using primitive logic gates given.

	wire [8:0] w_multiplicand = in_1;
	wire [6:0] w_multiplier = in_0;

	wire [10:0] w_Y, w_2Y, w_3Y, w_4Y;
	wire w_carry0, w_carry1;

	Y_GENERATOR u000(
		.multiplicand(w_multiplicand),
		
		.o_Y         (w_Y),
		.o_2Y        (w_2Y),
		.o_3Y        (w_3Y),
		.o_4Y        (w_4Y),
		
		.o_carry0    (w_carry0),
		.o_carry1    (w_carry1)
	);

	// Field 1
	wire w_carry0_F1, w_carry1_F1;
	wire [10:0] w_pp_F1;
	wire [15:0] w_pp_F1_result;
	wire w_sign_F1, w_sign_inv_F1, w_3M_F1;
	PP_GENERATOR u001 (
		.i_booth_multiplier({w_multiplier[2:0], 1'b0}),
		.i_Y               (w_Y),
		.i_2Y              (w_2Y),
		.i_3Y              (w_3Y),
		.i_4Y              (w_4Y),
		
		
		.o_pp              (w_pp_F1),
		
		.o_sign            (w_sign_F1),
		.o_sign_inv        (w_sign_inv_F1),
		.o_3M 			   (w_3M_F1)
	);

	assign w_pp_F1_result = {1'b0, w_sign_inv_F1, {3{w_sign_F1}}, w_pp_F1};
	AND_2I1O u002(.i0(w_carry0), .i1(w_3M_F1), .o(w_carry0_F1));
	AND_2I1O u003(.i0(w_carry1), .i1(w_3M_F1), .o(w_carry1_F1));

	// Field 2
	wire        w_carry0_F2, w_carry1_F2;
	wire [10:0] w_pp_F2;
	wire [15:0] w_pp_F2_result;
	wire w_sign_F2, w_sign_inv_F2, w_3M_F2;
	PP_GENERATOR u004 (
		.i_booth_multiplier(w_multiplier[5:2]),
		.i_Y               (w_Y),
		.i_2Y              (w_2Y),
		.i_3Y              (w_3Y),
		.i_4Y              (w_4Y),
		
		
		.o_pp              (w_pp_F2),
		
		.o_sign            (w_sign_F2),
		.o_sign_inv        (w_sign_inv_F2),
		.o_3M 			   (w_3M_F2)
	);

	assign w_pp_F2_result = {1'b1, w_sign_inv_F2, w_pp_F2, {3{1'b0}}};
	AND_2I1O u005(.i0(w_carry0), .i1(w_3M_F2), .o(w_carry0_F2));
	AND_2I1O u006(.i0(w_carry1), .i1(w_3M_F2), .o(w_carry1_F2));

	// Field 3
	wire w_carry0_F3, w_carry1_F3;
	wire [10:0] w_pp_F3;
	wire [15:0] w_pp_F3_result;
	wire w_sign_F3, w_sign_inv_F3, w_3M_F3;
	PP_GENERATOR u007 (
		.i_booth_multiplier({{2{1'b0}}, w_multiplier[6:5]}),
		.i_Y               (w_Y),
		.i_2Y              (w_2Y),
		.i_3Y              (w_3Y),
		.i_4Y              (w_4Y),
		
		
		.o_pp              (w_pp_F3),
		
		.o_sign            (w_sign_F3),
		.o_sign_inv        (w_sign_inv_F3),
		.o_3M 			   (w_3M_F3)
	);

	assign w_pp_F3_result = {w_pp_F3[9:0], {6{1'b0}}};
	AND_2I1O u008(.i0(w_carry0), .i1(w_3M_F3), .o(w_carry0_F3));
	AND_2I1O u009(.i0(w_carry1), .i1(w_3M_F3), .o(w_carry1_F3));

	// CSA
	wire [15:0]csa_in_0, csa_in_1;
	wire [15:6]w_csa_carry;

	assign csa_in_0[2:0] = w_pp_F1_result[2:0];
	assign csa_in_1[3:0] = {{3{1'b0}}, w_sign_F1};

	// COMP_3to2_CELL u004(.i0(), .i1(), .i2(), .o(), .Cout());
	COMP_3to2_CELL   u011(.i0(w_pp_F1_result[3]),  .i1(w_pp_F2_result[3]), 							 .i2(w_sign_F2), 		  				  .o(csa_in_0[3]),  .Cout (csa_in_1[4]));
	COMP_3to2_CELL   u012(.i0(w_pp_F1_result[4]),  .i1(w_pp_F2_result[4]), 							 .i2(w_carry0_F1), 						  .o(csa_in_0[4]),  .Cout (csa_in_1[5]));
	COMP_2to2_CELL   u013(.i0(w_pp_F1_result[5]),  .i1(w_pp_F2_result[5]), 							 									 	  .o(csa_in_0[5]),  .Cout (csa_in_1[6]));
	COMP_4to2_CELL   u014(.i0(w_pp_F1_result[6]),  .i1(w_pp_F2_result[6]),  .i2(w_pp_F3_result[6]),  .i3(w_sign_F3), 						  .o(csa_in_0[6]),  .Carry(csa_in_1[7]),  .Cout(w_csa_carry[6]));
	COMP_4to2_C_CELL u015(.i0(w_pp_F1_result[7]),  .i1(w_pp_F2_result[7]),  .i2(w_pp_F3_result[7]),  .i3(w_carry0_F2), .Cin(w_csa_carry[6]),  .o(csa_in_0[7]),  .Carry(csa_in_1[8]),  .Cout(w_csa_carry[7]));
	COMP_4to2_C_CELL u016(.i0(w_pp_F1_result[8]),  .i1(w_pp_F2_result[8]),  .i2(w_pp_F3_result[8]),  .i3(w_carry1_F1), .Cin(w_csa_carry[7]),  .o(csa_in_0[8]),  .Carry(csa_in_1[9]),  .Cout(w_csa_carry[8]));
	COMP_3to2_C_CELL u017(.i0(w_pp_F1_result[9]),  .i1(w_pp_F2_result[9]),  .i2(w_pp_F3_result[9]),    				   .Cin(w_csa_carry[8]),  .o(csa_in_0[9]),  .Carry(csa_in_1[10]), .Cout(w_csa_carry[9]));
	COMP_3to2_C_CELL u018(.i0(w_pp_F1_result[10]), .i1(w_pp_F2_result[10]), .i2(w_pp_F3_result[10]),   				   .Cin(w_csa_carry[9]),  .o(csa_in_0[10]), .Carry(csa_in_1[11]), .Cout(w_csa_carry[10]));
	COMP_4to2_C_CELL u019(.i0(w_pp_F1_result[11]), .i1(w_pp_F2_result[11]), .i2(w_pp_F3_result[11]), .i3(w_carry1_F2), .Cin(w_csa_carry[10]), .o(csa_in_0[11]), .Carry(csa_in_1[12]), .Cout(w_csa_carry[11]));
	COMP_3to2_C_CELL u020(.i0(w_pp_F1_result[12]), .i1(w_pp_F2_result[12]), .i2(w_pp_F3_result[12]), 				   .Cin(w_csa_carry[11]), .o(csa_in_0[12]), .Carry(csa_in_1[13]), .Cout(w_csa_carry[12]));
	COMP_3to2_C_CELL u021(.i0(w_pp_F1_result[13]), .i1(w_pp_F2_result[13]), .i2(w_pp_F3_result[13]), 				   .Cin(w_csa_carry[12]), .o(csa_in_0[13]), .Carry(csa_in_1[14]), .Cout(w_csa_carry[13]));
	COMP_3to2_C_CELL u022(.i0(w_pp_F1_result[14]), .i1(w_pp_F2_result[14]), .i2(w_pp_F3_result[14]), 				   .Cin(w_csa_carry[13]), .o(csa_in_0[14]), .Carry(csa_in_1[15]), .Cout(w_csa_carry[14]));
	COMP_2to2_C_CELL u023(						   .i0(w_pp_F2_result[15]), .i1(w_pp_F3_result[15]), 				   .Cin(w_csa_carry[14]), .o(csa_in_0[15]), 					  .Cout(w_csa_carry[15]));

	// CPA
	ADDER_16 u024(
    .i_A(csa_in_0),
    .i_B(csa_in_1),
    .i_Cin(1'b0),

    .o_SUM(out),
    .o_Cout() // no use
    );

	assign overflow = 1'b0;

endmodule









///////////////////////////////////////////////////////////////////////////////////
// Partial product generating modules

module PP_GENERATOR (
	input [3:0] i_booth_multiplier,
	input [10:0] i_Y,
	input [10:0] i_2Y,
	input [10:0] i_3Y,
	input [10:0] i_4Y,


	output [10:0] o_pp,

	output o_sign,
	output o_sign_inv,
	output o_3M
	);

	wire [3:0] w_booth_multiplie_inv;

	INV u000(.i(i_booth_multiplier[0]), .o(w_booth_multiplie_inv[0]));
	INV u001(.i(i_booth_multiplier[1]), .o(w_booth_multiplie_inv[1]));
	INV u002(.i(i_booth_multiplier[2]), .o(w_booth_multiplie_inv[2]));
	INV u003(.i(i_booth_multiplier[3]), .o(w_booth_multiplie_inv[3]));

	wire w_M;
	wire w_2M;
	wire w_3M;
	wire w_4M;
	wire w_sign;

	BOOTH_ENCODER u004 (
		.i_A    (i_booth_multiplier[3]),
		.i_B    (i_booth_multiplier[2]),
		.i_C    (i_booth_multiplier[1]),
		.i_D    (i_booth_multiplier[0]),
		
		.i_A_inv(w_booth_multiplie_inv[3]),
		.i_B_inv(w_booth_multiplie_inv[2]),
		.i_C_inv(w_booth_multiplie_inv[1]),
		.i_D_inv(w_booth_multiplie_inv[0]),
		
		.o_M    (w_M),
		.o_2M   (w_2M),
		.o_3M   (w_3M),
		.o_4M   (w_4M),
		
		.o_sign (w_sign)
	);

	assign o_sign = w_sign;
	assign o_3M = w_3M;
	INV u005(.i(w_sign), .o(o_sign_inv));

    genvar i;
    generate for (i = 0; i < 11; i = i + 1) begin
        BOOTH_SELECTOR u006 (
			.i_sign(w_sign),
			
			.i_M   (w_M),
			.i_2M  (w_2M),
			.i_3M  (w_3M),
			.i_4M  (w_4M),
			
			.i_Y   (i_Y[i]),
			.i_2Y  (i_2Y[i]),
			.i_3Y  (i_3Y[i]),
			.i_4Y  (i_4Y[i]),
			
			.o_pp  (o_pp[i])
		);
    end endgenerate

endmodule

module BOOTH_SELECTOR (
	input i_sign,

	input i_M,
	input i_2M,
	input i_3M,
	input i_4M,

	input i_Y,
	input i_2Y,
	input i_3Y,
	input i_4Y,
	
	output o_pp
	);

	wire [3:0]w;
	wire ww;

	NAND_2I1O   u000(.i0(i_M),  .i1(i_Y),  .o(w[0]));
	NAND_2I1O   u001(.i0(i_2M), .i1(i_2Y), .o(w[1]));
	NAND_2I1O   u002(.i0(i_3M), .i1(i_3Y), .o(w[2]));
	NAND_2I1O   u003(.i0(i_4M), .i1(i_4Y), .o(w[3]));

	NAND_4I1O   u004(.i0(w[0]), .i1(w[1]), .i2(w[2]), .i3(w[3]), .o(ww));

	XOR_2I1O_CELL u005(.i0(i_sign), .i1(ww), .o(o_pp));

endmodule

module BOOTH_ENCODER (
	input i_A,
	input i_B,
	input i_C,
	input i_D,

	input i_A_inv,
	input i_B_inv,
	input i_C_inv,
	input i_D_inv,

	output o_M,
	output o_2M,
	output o_3M,
	output o_4M,

	output o_sign
	);
	
	assign o_sign = i_A;

	// M
	wire [3:0] w_M;
	NAND_4I1O u000 (.i0(i_C_inv), .i1(i_D), .i2(i_A), .i3(i_B), .o(w_M[0]));
	NAND_4I1O u001 (.i0(i_C_inv), .i1(i_D), .i2(i_B_inv), .i3(i_A_inv), .o(w_M[1]));
	NAND_4I1O u002 (.i0(i_C), .i1(i_D_inv), .i2(i_A), .i3(i_B), .o(w_M[2]));
	NAND_4I1O u003 (.i0(i_C), .i1(i_D_inv), .i2(i_B_inv), .i3(i_A_inv), .o(w_M[3]));
	NAND_4I1O u004 (.i0(w_M[0]), .i1(w_M[1]), .i2(w_M[2]), .i3(w_M[3]), .o(o_M));

	// 2M
	wire [1:0] w_2M;
	NAND_3I1O u005 (.i0(i_B_inv), .i1(i_C), .i2(i_D), .o(w_2M[0]));
	NAND_3I1O u006 (.i0(i_B), .i1(i_C_inv), .i2(i_D_inv), .o(w_2M[1]));
	NAND_2I1O u009 (.i0(w_2M[0]), .i1(w_2M[1]), .o(o_2M));

	// 3M
	wire [3:0] w_3M;
	NAND_4I1O u010 (.i0(i_B_inv), .i1(i_A), .i2(i_C_inv), .i3(i_D), .o(w_3M[0]));
	NAND_4I1O u011 (.i0(i_B_inv), .i1(i_A), .i2(i_C), .i3(i_D_inv), .o(w_3M[1]));
	NAND_4I1O u012 (.i0(i_B), .i1(i_A_inv), .i2(i_C_inv), .i3(i_D), .o(w_3M[2]));
	NAND_4I1O u013 (.i0(i_B), .i1(i_A_inv), .i2(i_C), .i3(i_D_inv), .o(w_3M[3]));
	NAND_4I1O u014 (.i0(w_3M[0]), .i1(w_3M[1]), .i2(w_3M[2]), .i3(w_3M[3]), .o(o_3M));

	// 4M
	wire [1:0] w_4M;
	NAND_4I1O u015 (.i0(i_B_inv), .i1(i_A), .i2(i_D_inv), .i3(i_C_inv), .o(w_4M[0]));
	NAND_4I1O u016 (.i0(i_B), .i1(i_A_inv), .i2(i_C), .i3(i_D), .o(w_4M[1]));
	NAND_2I1O u017 (.i0(w_4M[0]), .i1(w_4M[1]), .o(o_4M));

endmodule


///////////////////////////////////////////////////////////////////////////////////
// Y_GENERATOR: Generate Y, 2Y, 3Y, 4Y

module Y_GENERATOR (
	input [8:0] multiplicand,

	output [10:0] o_Y,
	output [10:0] o_2Y,
	output [10:0] o_3Y,
	output [10:0] o_4Y,

	output o_carry0,
	output o_carry1
	);

	wire [8:0] w_1Y;
	wire [9:0] w_2Y;
	wire [10:0] w_3Y;
	wire [10:0] w_4Y;

	assign w_1Y = multiplicand;
	SHIFTER #(.SHIFT_IN_BIT(9), .SHIFT_NUM(1)) u000(.i(multiplicand), .o(w_2Y));
	MAKE_3Y u001(.i_Y(w_1Y), .i_2Y(w_2Y), .o_3Y(w_3Y), .o_carry0(o_carry0), .o_carry1(o_carry1));
	SHIFTER #(.SHIFT_IN_BIT(9), .SHIFT_NUM(2)) u002(.i(multiplicand), .o(w_4Y));

	assign o_Y  = {{2{1'b0}}, w_1Y};
	assign o_2Y = {1'b0, w_2Y};
	assign o_3Y = w_3Y;
	assign o_4Y = w_4Y;

endmodule

module MAKE_3Y (
	input [8:0] i_Y,
	input [9:0] i_2Y,

	output [10:0] o_3Y,
	output o_carry0,
	output o_carry1
	);

	ADDER_4 u000(.i_A(i_Y[3:0]), .i_B(i_2Y[3:0]), .o_SUM(o_3Y[3:0]), .o_Cout(o_carry0));
	ADDER_4 u001(.i_A(i_Y[7:4]), .i_B(i_2Y[7:4]), .o_SUM(o_3Y[7:4]), .o_Cout(o_carry1));
	ADDER_2 u002(.i_A({1'b0, i_Y[8]}), .i_B(i_2Y[9:8]), .o_SUM(o_3Y[9:8]), .o_Cout(o_3Y[10]));

endmodule

module SHIFTER #(
	parameter SHIFT_IN_BIT = 9,
	parameter SHIFT_NUM    = 1
	)(
	input  [            SHIFT_IN_BIT-1:0] i,
	output [(SHIFT_IN_BIT-1)+SHIFT_NUM:0] o
	);

	assign o = {i, {SHIFT_NUM{1'b0}}};

endmodule


///////////////////////////////////////////////////////////////////////////////////
// Adders

// 16bit KS Adder -----------------------------------------------------------------
module ADDER_16 (
    input [15:0] i_A,
    input [15:0] i_B,
    input i_Cin,

    output [15:0] o_SUM,
    output o_Cout
    );

    wire [15:0] w_G, w_P, w_GG;
    wire w_PP_15to0;

    BPG_16     u000(.i_A(i_A), .i_B(i_B), .o_G(w_G), .o_P(w_P));
    GPG_16     u001(.i_G(w_G), .i_P(w_P), .i_CIN(i_Cin), .o_GG(w_GG), .o_PP_15to0(w_PP_15to0));
    SUM_16     u002(.i_GG(w_GG), .i_P(w_P), .i_PP_15to_0(w_PP_15to0), .i_CIN(i_Cin), .o_S(o_SUM), .o_COUT(o_Cout));

endmodule

module BPG_16 (
    input [15:0]    i_A, i_B,

    output [15:0]   o_G, o_P
    );

    genvar i;
    generate for (i = 0; i < 16; i = i + 1) begin
        GEN_PROP_CELL   u000(.i_A(i_A[i]), .i_B(i_B[i]), .o_G(o_G[i]), .o_P(o_P[i]));
    end endgenerate

endmodule

module GPG_16 (
    input [15:0]    i_G, i_P,
    input           i_CIN,

    output [15:0]   o_GG,
    output          o_PP_15to0
    );

    wire [15:0] w_GG_S1;
    wire [15:3] w_PP_S1;

    // STAGE 1
    GRAY_CELL   u000(.i_Ga(i_G[0]), .i_Pa(i_P[0]), .i_Gb(i_CIN), .o_Y(w_GG_S1[0]));
    HVAL_G_3I_CELL   u001(.i_Ga(i_G[1]), .i_Pa(i_P[1]), .i_Gb(i_G[0]), .i_Pb(i_P[0]), .i_Gc(i_CIN), .o_Ga2c(w_GG_S1[1]));
    HVAL_G_4I_CELL   u002(.i_Ga(i_G[2]), .i_Pa(i_P[2]), .i_Gb(i_G[1]), .i_Pb(i_P[1]), .i_Gc(i_G[0]), .i_Pc(i_P[0]), .i_Gd(i_CIN), .o_Ga2d(w_GG_S1[2]));

    genvar i;
    generate for (i = 3; i < 16; i = i + 1) begin
        HVAL_B_4I_CELL   u003(.i_Ga(i_G[i]), .i_Pa(i_P[i]), .i_Gb(i_G[i-1]), .i_Pb(i_P[i-1]), .i_Gc(i_G[i-2]), .i_Pc(i_P[i-2]), .i_Gd(i_G[i-3]), .i_Pd(i_P[i-3]), .o_Ga2d(w_GG_S1[i]), .o_Pa2d(w_PP_S1[i]));
    end endgenerate

    // STAGE 2
    assign o_GG[2:0] = w_GG_S1[2:0];

    GRAY_CELL u004 (.i_Ga(w_GG_S1[3]), .i_Pa(w_PP_S1[3]), .i_Gb(i_CIN), .o_Y(o_GG[3]));
    GRAY_CELL u005 (.i_Ga(w_GG_S1[4]), .i_Pa(w_PP_S1[4]), .i_Gb(w_GG_S1[0]), .o_Y(o_GG[4]));
    GRAY_CELL u006 (.i_Ga(w_GG_S1[5]), .i_Pa(w_PP_S1[5]), .i_Gb(w_GG_S1[1]), .o_Y(o_GG[5]));
    GRAY_CELL u007 (.i_Ga(w_GG_S1[6]), .i_Pa(w_PP_S1[6]), .i_Gb(w_GG_S1[2]), .o_Y(o_GG[6]));

    HVAL_G_3I_CELL u008 (.i_Ga(w_GG_S1[7]), .i_Pa(w_PP_S1[7]), .i_Gb(w_GG_S1[3]), .i_Pb(w_PP_S1[3]), .i_Gc(i_CIN), .o_Ga2c(o_GG[7]));
    HVAL_G_3I_CELL u009 (.i_Ga(w_GG_S1[8]), .i_Pa(w_PP_S1[8]), .i_Gb(w_GG_S1[4]), .i_Pb(w_PP_S1[4]), .i_Gc(w_GG_S1[0]), .o_Ga2c(o_GG[8]));
    HVAL_G_3I_CELL u010 (.i_Ga(w_GG_S1[9]), .i_Pa(w_PP_S1[9]), .i_Gb(w_GG_S1[5]), .i_Pb(w_PP_S1[5]), .i_Gc(w_GG_S1[1]), .o_Ga2c(o_GG[9]));
    HVAL_G_3I_CELL u011 (.i_Ga(w_GG_S1[10]), .i_Pa(w_PP_S1[10]), .i_Gb(w_GG_S1[6]), .i_Pb(w_PP_S1[6]), .i_Gc(w_GG_S1[2]), .o_Ga2c(o_GG[10]));

    HVAL_G_4I_CELL u012 (.i_Ga(w_GG_S1[11]), .i_Pa(w_PP_S1[11]), .i_Gb(w_GG_S1[7]), .i_Pb(w_PP_S1[7]), .i_Gc(w_GG_S1[3]), .i_Pc(w_PP_S1[3]), .i_Gd(i_CIN), .o_Ga2d(o_GG[11]));
    HVAL_G_4I_CELL u013 (.i_Ga(w_GG_S1[12]), .i_Pa(w_PP_S1[12]), .i_Gb(w_GG_S1[8]), .i_Pb(w_PP_S1[8]), .i_Gc(w_GG_S1[4]), .i_Pc(w_PP_S1[4]), .i_Gd(w_GG_S1[0]), .o_Ga2d(o_GG[12]));
    HVAL_G_4I_CELL u014 (.i_Ga(w_GG_S1[13]), .i_Pa(w_PP_S1[13]), .i_Gb(w_GG_S1[9]), .i_Pb(w_PP_S1[9]), .i_Gc(w_GG_S1[5]), .i_Pc(w_PP_S1[5]), .i_Gd(w_GG_S1[1]), .o_Ga2d(o_GG[13]));
    HVAL_G_4I_CELL u015 (.i_Ga(w_GG_S1[14]), .i_Pa(w_PP_S1[14]), .i_Gb(w_GG_S1[10]), .i_Pb(w_PP_S1[10]), .i_Gc(w_GG_S1[6]), .i_Pc(w_PP_S1[6]), .i_Gd(w_GG_S1[2]), .o_Ga2d(o_GG[14]));

    HVAL_B_4I_CELL u016 (.i_Ga(w_GG_S1[15]), .i_Pa(w_PP_S1[15]), .i_Gb(w_GG_S1[11]), .i_Pb(w_PP_S1[11]), .i_Gc(w_GG_S1[7]), .i_Pc(w_PP_S1[7]), .i_Gd(w_GG_S1[3]), .i_Pd(w_PP_S1[3]), .o_Ga2d(o_GG[15]), .o_Pa2d(o_PP_15to0));

endmodule

module SUM_16 (
    input [15:0]    i_GG,
    input [15:0]    i_P,
    input           i_PP_15to_0,
    input           i_CIN,

    output [15:0]   o_S,
    output          o_COUT
    );
    
    wire [15:0] new_GG = {i_GG[14:0], i_CIN};

    genvar i;
    generate for (i = 0; i < 16; i = i + 1) begin
       XOR_2I1O_CELL u000(.i0(i_P[i]), .i1(new_GG[i]), .o(o_S[i]));
    end endgenerate

    GRAY_CELL   u001(.i_Ga(i_GG[15]), .i_Pa(i_PP_15to_0), .i_Gb(i_CIN), .o_Y(o_COUT));

endmodule

// 4bit KS Adder(no Cin) ----------------------------------------------------------
module ADDER_4 (
    input [3:0] i_A,
    input [3:0] i_B,

    output [3:0] o_SUM,
    output o_Cout
    );

    wire [3:0] w_G, w_P, w_GG;

    BPG_4     u000(.i_A(i_A), .i_B(i_B), .o_G(w_G), .o_P(w_P));
    GPG_4     u001(.i_G(w_G), .i_P(w_P), .o_GG(w_GG));
    SUM_4     u002(.i_GG(w_GG), .i_P(w_P), .o_S(o_SUM), .o_Cout(o_Cout));

endmodule

module BPG_4 (
    input [3:0]    i_A, i_B,

    output [3:0]   o_G, o_P
    );

    genvar i;
    generate for (i = 0; i < 4; i = i + 1) begin
        GEN_PROP_CELL   u000(.i_A(i_A[i]), .i_B(i_B[i]), .o_G(o_G[i]), .o_P(o_P[i]));
    end endgenerate

endmodule

module GPG_4 (
    input [3:0]    i_G, i_P,

    output [3:0]   o_GG
    );

	assign o_GG[0] = i_G[0];
	GRAY_CELL u000(.i_Ga(i_G[1]), .i_Pa(i_P[1]), .i_Gb(i_G[0]), .o_Y(o_GG[1]));
	HVAL_G_3I_CELL u001(.i_Ga(i_G[2]), .i_Pa(i_P[2]), .i_Gb(i_G[1]), .i_Pb(i_P[1]), .i_Gc(i_G[0]), .o_Ga2c(o_GG[2]));
	HVAL_G_4I_CELL u002(.i_Ga(i_G[3]), .i_Pa  (i_P[3]), .i_Gb(i_G[2]), .i_Pb(i_P[2]), .i_Gc(i_G[1]), .i_Pc(i_P[1]), 
						.i_Gd(i_G[0]), .o_Ga2d(o_GG[3]));

endmodule

module SUM_4 (
    input [3:0]    i_GG,
    input [3:0]    i_P,

    output [3:0]   o_S,
    output         o_Cout
    );
    
	assign o_S[0] = i_P[0];
	XOR_2I1O_CELL u000(.i0(i_P[1]), .i1(i_GG[0]), .o(o_S[1]));
	XOR_2I1O_CELL u001(.i0(i_P[2]), .i1(i_GG[1]), .o(o_S[2]));
	XOR_2I1O_CELL u002(.i0(i_P[3]), .i1(i_GG[2]), .o(o_S[3]));
	assign o_Cout = i_GG[3];

endmodule


// 2bit KS Adder(no Cin) ----------------------------------------------------------
module ADDER_2 (
    input [1:0] i_A,
    input [1:0] i_B,

    output [1:0] o_SUM,
    output o_Cout
    );

    wire [1:0] w_G, w_P, w_GG;

    // BPG
    genvar i;
    generate for (i = 0; i < 2; i = i + 1) begin
        GEN_PROP_CELL   u000(.i_A(i_A[i]), .i_B(i_B[i]), .o_G(w_G[i]), .o_P(w_P[i]));
    end endgenerate

    // GPG
    assign w_GG[0] = w_G[0];
	GRAY_CELL u001(.i_Ga(w_G[1]), .i_Pa(w_P[1]), .i_Gb(w_G[0]), .o_Y(w_GG[1]));

	// SUM
	assign o_SUM[0] = w_P[0];
	XOR_2I1O_CELL u002(.i0(w_P[1]), .i1(w_GG[0]), .o(o_SUM[1]));
	assign o_Cout = w_GG[1];

endmodule


///////////////////////////////////////////////////////////////////////////////////
// Cells
module GRAY_CELL (
        input i_Ga, i_Pa,
        input i_Gb,

        output o_Y
    );

    wire w0, w1;

    INV         u000(.i(i_Ga), .o(w0));
    NAND_2I1O   u001(.i0(i_Pa), .i1(i_Gb), .o(w1));
    NAND_2I1O   u002(.i0(w0), .i1(w1), .o(o_Y));

endmodule

module GEN_PROP_CELL (
        input i_A,
        input i_B,

        output o_G,
        output o_P
    );

    wire w0, w1, w2;

    NAND_2I1O   u000(.i0(i_A), .i1(i_B), .o(w0));

    NAND_2I1O   u001(.i0(i_A), .i1(w0), .o(w1));
    NAND_2I1O   u002(.i0(i_B), .i1(w0), .o(w2));

    NAND_2I1O   u003(.i0(w1), .i1(w2), .o(o_P));

    INV         u004(.i(w0), .o(o_G));

endmodule

module HVAL_G_3I_CELL (
        input i_Ga, i_Pa,
        input i_Gb, i_Pb,
        input i_Gc,

        output o_Ga2c
    );

    wire w0, w1, w2;

    NAND_3I1O   u000(.i0(i_Pa), .i1(i_Pb), .i2(i_Gc), .o(w0));
    NAND_2I1O   u001(.i0(i_Pa), .i1(i_Gb), .o(w1));
    INV         u002(.i(i_Ga), .o(w2));

    NAND_3I1O   u003(.i0(w0), .i1(w1), .i2(w2), .o(o_Ga2c));

endmodule

module HVAL_G_4I_CELL (
        input i_Ga, i_Pa,
        input i_Gb, i_Pb,
        input i_Gc, i_Pc,
        input i_Gd,

        output o_Ga2d
    );

    wire w0, w1, w2, w3;

    NAND_4I1O   u000(.i0(i_Pa), .i1(i_Pb), .i2(i_Pc), .i3(i_Gd), .o(w0));
    NAND_3I1O   u001(.i0(i_Pa), .i1(i_Pb), .i2(i_Gc), .o(w1));
    NAND_2I1O   u002(.i0(i_Pa), .i1(i_Gb), .o(w2));
    INV         u003(.i(i_Ga), .o(w3));

    NAND_4I1O   u004(.i0(w0), .i1(w1), .i2(w2), .i3(w3), .o(o_Ga2d));

endmodule

module HVAL_B_4I_CELL (
        input i_Ga, i_Pa,
        input i_Gb, i_Pb,
        input i_Gc, i_Pc,
        input i_Gd, i_Pd,

        output o_Ga2d, o_Pa2d
    );

    wire w0;

    HVAL_G_4I_CELL   u000(.i_Ga(i_Ga), .i_Pa(i_Pa), .i_Gb(i_Gb), .i_Pb(i_Pb), .i_Gc(i_Gc), .i_Pc(i_Pc), .i_Gd(i_Gd), .o_Ga2d(o_Ga2d));

    NAND_4I1O   u001(.i0(i_Pa), .i1(i_Pb), .i2(i_Pc), .i3(i_Pd), .o(w0));
    INV         u002(.i(w0), .o(o_Pa2d));

endmodule

module COMP_4to2_C_CELL (
    input i0,
    input i1,
    input i2,
    input i3,
    input Cin,

    output o,
    output Cout,
    output Carry
	);

	wire w0;

	XOR_3I1O_CELL u000(.i0(i0), .i1(i1), .i2(i2), .o(w0));
	MAJ_3I1O_CELL u001(.i0(i0), .i1(i1), .i2(i2), .o(Cout));

	XOR_3I1O_CELL u002(.i0(w0), .i1(i3), .i2(Cin), .o(o));
	MAJ_3I1O_CELL u003(.i0(w0), .i1(i3), .i2(Cin), .o(Carry));

endmodule

module COMP_4to2_CELL (
    input i0,
    input i1,
    input i2,
    input i3,

    output o,
    output Cout,
    output Carry
	);

	wire w0;

	XOR_3I1O_CELL u000(.i0(i0), .i1(i1), .i2(i2), .o(w0));
	MAJ_3I1O_CELL u001(.i0(i0), .i1(i1), .i2(i2), .o(Cout));

	XOR_2I1O_CELL u002(.i0(w0), .i1(i3), .o(o));
	MAJ_2I1O_CELL u003(.i0(w0), .i1(i3), .o(Carry));

endmodule

module COMP_3to2_C_CELL (
    input i0,
    input i1,
    input i2,
    input Cin,

    output o,
    output Cout,
    output Carry
	);

	wire w0;

	XOR_3I1O_CELL u000(.i0(i0), .i1(i1), .i2(i2), .o(w0));
	MAJ_3I1O_CELL u001(.i0(i0), .i1(i1), .i2(i2), .o(Cout));

	XOR_2I1O_CELL u002(.i0(w0), .i1(Cin), .o(o));
	MAJ_2I1O_CELL u003(.i0(w0), .i1(Cin), .o(Carry));

endmodule

module COMP_3to2_CELL (
    input i0,
    input i1,
    input i2,

    output o,
    output Cout
	);

	wire w0;

	XOR_3I1O_CELL u000(.i0(i0), .i1(i1), .i2(i2), .o(o));
	MAJ_3I1O_CELL u001(.i0(i0), .i1(i1), .i2(i2), .o(Cout));

endmodule

module COMP_2to2_C_CELL (
    input i0,
    input i1,
    input Cin,

    output o,
    output Cout
	);

	wire w0;

	XOR_3I1O_CELL u000(.i0(i0), .i1(i1), .i2(Cin), .o(o));
	MAJ_3I1O_CELL u001(.i0(i0), .i1(i1), .i2(Cin), .o(Cout));

endmodule

module COMP_2to2_CELL (
    input i0,
    input i1,

    output o,
    output Cout
	);

	wire w0;

	XOR_2I1O_CELL u000(.i0(i0), .i1(i1), .o(o));
	MAJ_2I1O_CELL u001(.i0(i0), .i1(i1), .o(Cout));

endmodule

module MAJ_3I1O_CELL (
	input i0,
	input i1,
	input i2,

	output o
	);

	wire [2:0]w;

	NAND_2I1O   u000(.i0(i0), .i1(i1), .o(w[0]));
	NAND_2I1O   u001(.i0(i1), .i1(i2), .o(w[1]));
	NAND_2I1O   u002(.i0(i0), .i1(i2), .o(w[2]));

	NAND_3I1O   u003(.i0(w[0]), .i1(w[1]), .i2(w[2]), .o(o));

endmodule

module MAJ_2I1O_CELL (
	input i0,
	input i1,

	output o
	);

	AND_2I1O   u000(.i0(i0), .i1(i1), .o(o));

endmodule

module XOR_3I1O_CELL (
	input i0,
	input i1,
	input i2,

	output o
    );

	wire i0_inv, i1_inv, i2_inv;
	wire [3:0] w;

    INV			u000(.i(i0), .o(i0_inv));
    INV			u001(.i(i1), .o(i1_inv));
	INV			u002(.i(i2), .o(i2_inv));

	NAND_3I1O   u003(.i0(i0), .i1(i1), .i2(i2), .o(w[0]));
	NAND_3I1O   u004(.i0(i0_inv), .i1(i1_inv), .i2(i2), .o(w[1]));
	NAND_3I1O   u005(.i0(i0_inv), .i1(i1), .i2(i2_inv), .o(w[2]));
	NAND_3I1O   u006(.i0(i0), .i1(i1_inv), .i2(i2_inv), .o(w[3]));

	NAND_4I1O   u007(.i0(w[0]), .i1(w[1]), .i2(w[2]), .i3(w[3]), .o(o));

endmodule

module XOR_2I1O_CELL (
        input i0,
        input i1,
        output o
    );

    wire i0_inv, i1_inv, w0, w1;

    INV			u000(.i(i0), .o(i0_inv));
    INV			u001(.i(i1), .o(i1_inv));

    NAND_2I1O   u002(.i0(i0), .i1(i1_inv), .o(w0));
    NAND_2I1O   u003(.i0(i1), .i1(i0_inv), .o(w1));

    NAND_2I1O   u004(.i0(w0), .i1(w1), .o(o));

endmodule

module AND_2I1O (
	input i0,
	input i1,

	output o
	);

	wire w0;
	NAND_2I1O   u000(.i0(i0), .i1(i1), .o(w0));
	INV 		u001(.i(w0), .o(o));

endmodule


///////////////////////////////////////////////////////////////////////////////////
// Don't modify the following primitive logic gates

module NAND_2I1O (i0, i1, o);
input i0;
input i1;
output o;

assign #(0.1, 0.2) o = ~(i0 & i1);

endmodule

module NAND_3I1O (i0, i1, i2, o);
input i0;
input i1;
input i2;
output o;

assign #(0.1, 0.3) o = ~(i0 & i1 & i2);

endmodule

module NAND_4I1O (i0, i1, i2, i3, o);
input i0;
input i1;
input i2;
input i3;
output o;

assign #(0.1, 0.4) o = ~(i0 & i1 & i2 & i3);

endmodule

module NOR_2I1O (i0, i1, o);
input i0;
input i1;
output o;

assign #(0.2, 0.1) o = ~(i0 | i1);

endmodule

module NOR_3I1O (i0, i1, i2, o);
input i0;
input i1;
input i2;
output o;

assign #(0.3, 0.1) o = ~(i0 | i1 | i2);

endmodule

module NOR_4I1O (i0, i1, i2, i3, o);
input i0;
input i1;
input i2;
input i3;
output o;

assign #(0.4, 0.1) o = ~(i0 | i1 | i2 | i3);

endmodule


module INV (i, o);
input i;
output o;

assign #(0.1, 0.1) o = ~i;

endmodule

