`timescale 1ns / 1ps

module block_controller(
	//input clk, //this clock must be a slow enough clock to view the changing positions of the objects
	input bright,
	input [1:0] X,
	input [1:0] Y,
	input [3:0] A0,
	input [3:0] A1,
	input [3:0] A2,
	input [3:0] A3,
	input [3:0] B0,
	input [3:0] B1,
	input [3:0] B2,
	input [3:0] B3,
	input Qi,
	input Qg,
	input Qfo,
	input Qp,
	input Ql,
	input [9:0] hCount, vCount,
	output reg [11:0] rgb
   );

   wire selected;
   wire guess_correct;
   wire guess_wrong;
   wire unguessed;

   reg[1:0] i; //
   reg[1:0] j; //Iterators



	localparam
	RED = 12'b1111_0000_0000,
	GREEN = 12'b0000_1111_0000,
	WHITE = 12'b1111_1111_1111,
	BLUE = 12'b0000_0000_1111,
	BACKGROUND = 12'b0000_0000_0000,
	SQUARE11X = 297,
	SQUARE12X = 386,
	SQUARE13X = 475,
	SQUARE14X = 564,
	SQUARE11Y = 106,
	SQUARE21Y = 195,
	SQUARE31Y = 284,
	SQUARE41Y = 373;

	/*
		TODO: Set each square center to a location

	*/


	/*
		VTOP = 106
		TOP ROW MIDDLE = 138
		SECOND ROW MIDDLE = 227
		THIRD ROW MIDDLE = 316
		LAST ROW MIDDLE = 405

		HLEFT = 297
		FIRST COLUMN MIDDLE = 329
		2 = 386
		3 = 475
		LAST = 564
		TRY 65X65 SQUARES, 24 PIXELS BETWEEN, 154 BETWEEN BOARD AND H-SIDES, 72 FOR V-SIDES

	*/

	always@ (*)
	begin
		if(~bright )	//force black if not inside the display area
			rgb = 12'b0000_0000_0000;
		else if (guess_correct || sQg)
			rgb = GREEN;
		else if (guess_wrong || sQfo || (sQl && sLose))
			rgb = RED;
		else if (selected || sQi)
			rgb = BLUE;
		else if (unguessed || sQp)
			rgb = WHITE;
		else
			rgb=BACKGROUND;
	end
	
	assign sLose = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) || ((vCount >= SQUARE11Y-40) && (vCount <=SQUARE11Y-30)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) || ((vCount >= SQUARE11Y-30) && (vCount <=SQUARE11Y-20)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) || ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X+10) && (hCount <= SQUARE11X + 20));
	assign sQi = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) && Qi;
	assign sQg = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) && Qg;
	assign sQfo = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) && Qfo;
	assign sQp = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) && Qp;
	assign sQl = ((vCount >= SQUARE11Y-20) && (vCount <=SQUARE11Y-10)) && ((hCount >= SQUARE11X) && (hCount <= SQUARE11X + 10)) && Ql;

	assign SQUARE11 = (vCount >= SQUARE11Y) && (vCount <=SQUARE11Y+65) && (hCount>=SQUARE11X) && (hCount<=SQUARE11X+65);
	assign SQUARE12 = (vCount >= SQUARE11Y) && (vCount <=SQUARE11Y+65) && (hCount>=SQUARE12X) && (hCount<=SQUARE12X+65);
	assign SQUARE13 = (vCount >= SQUARE11Y) && (vCount <=SQUARE11Y+65) && (hCount>=SQUARE13X) && (hCount<=SQUARE13X+65);
	assign SQUARE14 = (vCount >= SQUARE11Y) && (vCount <=SQUARE11Y+65) && (hCount>=SQUARE14X) && (hCount<=SQUARE14X+65);

	assign SQUARE21 = (vCount >= SQUARE21Y) && (vCount <=SQUARE21Y+65) && (hCount>=SQUARE11X) && (hCount<=SQUARE11X+65);
	assign SQUARE22 = (vCount >= SQUARE21Y) && (vCount <=SQUARE21Y+65) && (hCount>=SQUARE12X) && (hCount<=SQUARE12X+65);
	assign SQUARE23 = (vCount >= SQUARE21Y) && (vCount <=SQUARE21Y+65) && (hCount>=SQUARE13X) && (hCount<=SQUARE13X+65);
	assign SQUARE24 = (vCount >= SQUARE21Y) && (vCount <=SQUARE21Y+65) && (hCount>=SQUARE14X) && (hCount<=SQUARE14X+65);

	assign SQUARE31 = (vCount >= SQUARE31Y) && (vCount <=SQUARE31Y+65) && (hCount>=SQUARE11X) && (hCount<=SQUARE11X+65);
	assign SQUARE32 = (vCount >= SQUARE31Y) && (vCount <=SQUARE31Y+65) && (hCount>=SQUARE12X) && (hCount<=SQUARE12X+65);
	assign SQUARE33 = (vCount >= SQUARE31Y) && (vCount <=SQUARE31Y+65) && (hCount>=SQUARE13X) && (hCount<=SQUARE13X+65);
	assign SQUARE34 = (vCount >= SQUARE31Y) && (vCount <=SQUARE31Y+65) && (hCount>=SQUARE14X) && (hCount<=SQUARE14X+65);

	assign SQUARE41 = (vCount >= SQUARE41Y) && (vCount <=SQUARE41Y+65) && (hCount>=SQUARE11X) && (hCount<=SQUARE11X+65);
	assign SQUARE42 = (vCount >= SQUARE41Y) && (vCount <=SQUARE41Y+65) && (hCount>=SQUARE12X) && (hCount<=SQUARE12X+65);
	assign SQUARE43 = (vCount >= SQUARE41Y) && (vCount <=SQUARE41Y+65) && (hCount>=SQUARE13X) && (hCount<=SQUARE13X+65);
	assign SQUARE44 = (vCount >= SQUARE41Y) && (vCount <=SQUARE41Y+65) && (hCount>=SQUARE14X) && (hCount<=SQUARE14X+65);



	assign guess_wrong = !Qi && ((((!A0[0] && B0[0])|| Ql) && SQUARE11) ||  (((!A0[1] && B0[1]) || Ql) && SQUARE12) || (((!A0[2] && B0[2]) ||Ql) && SQUARE13) || 
		(!A0[3] && B0[3] && SQUARE14) || (!A1[0] && B1[0] && SQUARE21) || (!A1[1] && B1[1] && SQUARE22) || (!A1[2] && B1[2] && SQUARE23) || (!A1[3] && B1[3] && SQUARE24) ||
		(!A2[0] && B2[0] && SQUARE31) ||  (!A2[1] && B2[1] && SQUARE32) || (!A2[2] && B2[2] && SQUARE33) || (!A2[3] && B2[3] && SQUARE34) || (!A3[0] && B3[0] && SQUARE41) || 
		(!A3[1] && B3[1] && SQUARE42) || (!A3[2] && B3[2] && SQUARE43) || (!A3[3] && B3[3] && SQUARE44));
	assign unguessed = !Ql && (SQUARE11 || SQUARE12 || SQUARE13 || SQUARE14 || SQUARE21 || SQUARE22 || SQUARE23 || SQUARE24 || SQUARE31 || SQUARE32 || SQUARE33 || SQUARE34 || 
		SQUARE41 || SQUARE42 || SQUARE43 || SQUARE44);
	assign guess_correct = !Qi && !Ql && ((A0[0] && (B0[0] || Qfo)  && SQUARE11) ||  (A0[1] && (B0[1] || Qfo) && SQUARE12) || (A0[2] && (B0[2] || Qfo) && SQUARE13) || 
		(A0[3] && (B0[3] || Qfo) && SQUARE14) || (A1[0] && (B1[0] || Qfo) && SQUARE21) || (A1[1] && (B1[1] || Qfo) && SQUARE22) || (A1[2] && (B1[2] || Qfo) && SQUARE23) || 
		(A1[3] && (B1[3] || Qfo) && SQUARE24) || (A2[0] && (B2[0] || Qfo) && SQUARE31) ||  (A2[1] && (B2[1] || Qfo) && SQUARE32) || (A2[2] && (B2[2] || Qfo) && SQUARE33) || 
		(A2[3] && (B2[3] || Qfo) && SQUARE34) || (A3[0] && (B3[0] || Qfo) && SQUARE41) || (A3[1] && (B3[1] || Qfo) && SQUARE42) || (A3[2] && (B3[2] || Qfo) && SQUARE43) || 
		(A3[3] && (B3[3] || Qfo) && SQUARE44));
	assign selected = Qp && ((X==0 && Y==0 && SQUARE11) ||  (X==0 && Y==1 && SQUARE12) || (X==0 && Y==2 && SQUARE13) || (X==0 && Y==3 && SQUARE14) || (X==1 && Y==0 && SQUARE21) || 
		(X==1 && Y==1 && SQUARE22) || (X==1 && Y==2 && SQUARE23) || (X==1 && Y==3 && SQUARE24) || (X==2 && Y==0 && SQUARE31) ||  (X==2 && Y==1 && SQUARE32) || 
		(X==2 && Y==2 && SQUARE33) || (X==2 && Y==3 && SQUARE34) || (X==3 && Y==0 && SQUARE41) || (X==3 && Y==1 && SQUARE42) || (X==3 && Y==2 && SQUARE43) || (X==3 && Y==3 && SQUARE44));



endmodule
