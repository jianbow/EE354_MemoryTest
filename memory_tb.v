//////////////////////////////////////////////////////////////////////////////////
// Author:			Shideh Shahidi, Bilal Zafar, Gandhi Puvvada
// Create Date:   02/25/08, 10/13/08
// File Name:		ee354_GCD_tb.v 
// Description: 
//
//
// Revision: 		2.1
// Additional Comments:  
// 10/13/2008 Clock Enable (CEN) has been added by Gandhi
// 3/1/2010 Signal names are changed in line with the divider_verilog design
//  02/20/2020 Nexys-3 to Nexys-4 conversion done by Yue (Julien) Niu
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module ee354_memory;

	// Inputs
	reg Clk;
	reg Reset;
	reg Start;
	reg Ack;
	reg Right, Left, Up, Down, Select;
	reg [7:0] SS_in;
	reg [7:0] INC_in;

	// Outputs

	wire Qi, Qg, Qfo, Qp, Ql;
	wire [3:0] Lives;
	wire [3:0] outX, outY;
	wire [3:0] outA0, outA1, outA2, outA3, outB0, outB1, outB2, outB3;
	wire [3:0] unos;
	reg [6*8:0] state_string; // 6-character string for symbolic display of state
	integer clk_cnt, start_clock_cnt,clocks_taken;
	// Instantiate the Unit Under Test (UUT)
	/*
	ee354_GCD uut (
		.Clk(Clk), 
		.CEN(CEN),
		.Reset(Reset), 
		.Start(Start), 
		.Ack(Ack), 
		.Ain(Ain), 
		.Bin(Bin), 
		.A(A),
		.B(B),
		.AB_GCD(AB_GCD), 
		.i_count(i_count),
		.q_I(q_I), 
		.q_Sub(q_Sub), 
		.q_Mult(q_Mult), 
		.q_Done(q_Done)
	);
	*/
				
	memory uut(.SS_in(SS_in), .INC_in(INC_in), .Start(Start), .Ack(Ack), .Clk(Clk), .Reset(Reset), .Right(Right), .Left(Left), .Up(Up), .Down(Down), .Select(Select),
				.Lives(Lives), .outA0(outA0), .outA1(outA1), .outA2(outA2), .outA3(outA3), .outB0(outB0), .outB1(outB1), .outB2(outB2), .outB3(outB3), .Qi(Qi), .Qg(Qg), .Qfo(Qfo), .Qp(Qp), .Ql(Ql), .outX(outX), .outY(outY), .unos(unos));
		
		
		always  begin #5; Clk = ~ Clk; end
		always@(posedge Clk) clk_cnt=clk_cnt+1; //don't want to use reset to clear the clk_cnt or initialize
		initial begin
		// Initialize Inputs
		clk_cnt=0;
		Clk = 0;
				 // ****** in Part 2 ******
				 // Here, in Part 1, we are enabling clock permanently by making CEN a '1' constantly.
				 // In Part 2, your TOP design provides single-stepping through SCEN control.
				 // We are not planning to write a testbench for the part 2 design. However, if we were 
				 // to write one, we will remove this line, and make CEN enabled and disabled to test 
				 // single stepping.
				 // One of the things you make sure in your core design (DUT) is that when state 
				 // transitions are stopped by making CEN = 0,
				 // the data transformations are also stopped.
		Reset = 0;
		Start = 0;
		Ack = 0;


		Right = 0;
		Left = 0;
		Up = 0;
		Down = 0;
		Select = 0;
		
		SS_in = 0;
		INC_in = 0;

		//generate Reset, Start, Ack, Ain, Bin signals according to the waveform on page 14/19
		//add start_clock_cnt and clocks_taken code in the correct areas
		//add $display statements per 6.10 on page 13/19
		
		
		//reset control
		@(posedge Clk); //wait until we get a posedge in the Clk signal
		@(posedge Clk);
		#1;
		Reset=1;
		@(posedge Clk);
		#1;
		Reset=0;
		
		
		//First stimulus (1,1)
		/*
			shoudl generate 
			0001
			0010
			0011
			0100
		*/
		SS_in = 1;
		INC_in = 1;
		//make start signal active for one clock
		@(posedge Clk);
		#1;
		Start=1;
		@(posedge Clk);
		#1;
		Start=0;
		//leaving the q_I state, so start keeping track of the clocks taken
		wait(Qp); //wait until q_Done signal is a 1
		#1;
		$display("A0: %d A1: %d, A2: %d, A2: %d", outA0, outA1, outA2, outA3);
		
		//i just want to see what the A values are
		//SAMPLE PLAY THORUGH OF 1,2,3,4
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Right=1;
		@(posedge Clk);
		#1;
		Right=0;
		@(posedge Clk);
		#1;
		Down=1;
		@(posedge Clk);
		#1;
		Down=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Right=1;
		@(posedge Clk);
		#1;
		Right=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Up=1;
		@(posedge Clk);
		#1;
		Up=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Right=1;
		@(posedge Clk);
		#1;
		Right=0;
		@(posedge Clk);
		#1;
		Down=1;
		@(posedge Clk);
		#1;
		Down=0;
		@(posedge Clk);
		#1;
		Down=1;
		@(posedge Clk);
		#1;
		Down=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		
		//SAMPLE ERROR PLAYTHROUGH
        @(posedge Qp);
		@(posedge Clk);
		#1;
		Down=1;
		@(posedge Clk);
		#1;
		Down=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		@(posedge Clk);
		#1;
		Select=1;
		@(posedge Clk);
		#1;
		Select=0;
		/*
		//keep Ack signal high for one clock
		Ack=1;
		@(posedge Clk);
		#1;
		Ack=0;
		
		
		//Second stimulus (5,15)
		Ain = 5;
		Bin = 15;
		@(posedge Clk);										
		
		// generate a Start pulse
		Start = 1;
		@(posedge Clk);
		Start = 0;

		wait(q_Sub)
		start_clock_cnt = clk_cnt;
			
		wait(q_Done);
		clocks_taken = clk_cnt - start_clock_cnt;
		// generate and Ack pulse
		#1;
		$display("Ain: %d Bin: %d, GCD: %d", Ain, Bin, AB_GCD);
		$display("It took %d clock(s) to compute the GCD", clocks_taken);
		Ack = 1;
		@(posedge Clk);
		Ack = 0;
		*/
		#20;					
		

	end
	
	always @(*)
		begin
			case ({Qi, Qg, Qfo, Qp, Ql})    // Note the concatenation operator {}
				5'b10000: state_string = "q_I   ";  // ****** TODO ******
				5'b01000: state_string = "q_Gen ";  // Fill-in the three lines
				5'b00100: state_string = "q_Find";
				5'b00010: state_string = "q_play";		
				5'b00001: state_string = "q_lose";					
			endcase
		end
 
      
endmodule

