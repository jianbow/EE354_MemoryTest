// ----------------------------------------------------------------------
// 	A Verilog module for a simple divider
//
// 	Written by Gandhi Puvvada  Date: 7/17/98, 2/15/2008, 10/13/08, 2/21/2010
//
//      File name:  divider_combined_cu_dpu.v
// ------------------------------------------------------------------------
//	This is an improvement over divider.v
// We combined the two separate case statements in the divider.v
// into one single case statement.
// Notice the following lines added because of this combining
//	      X <= 4'bXXXX;        // to avoid recirculating mux controlled by Reset
//	      Y <= 4'bXXXX;	   // to avoid recirculating mux controlled by Reset 
//	      Quotient <= 4'bXXXX; // to avoid recirculating mux controlled by Reset
//
// We kept the module name same ("divider") as in divider.
// So, between divider.v and divider_combined_cu_dpu.v, the file, which was 
// mostly recently compiled in modelsim, will define the behavior of 
// the compiled module divider in modelsim (if you are simulating the testbench
// in a stand-alone modelsim simulation. In the Xilinx ISE, you need to add either
// the file  (divider_combined_cu_dpu.v) or the other file (divider.v).
// ------------------------------------------------------------------------

//COPIED ALL THIS STUFF FROM THE DIVIDER LAB

//module memory (Xin, Yin, Start, Ack, Clk, Reset, 
//				Done, Quotient, Remainder, Qi, Qc, Qd);
				
module memory (SS_in, INC_in, Start, Ack, Clk, Reset, Right, Left, Up, Down, Select,
				Lives, outA, outB, Qi, Qg, Qfo, Qp, Ql, outX, outY);
				
//DECLARE ALL MY INPUTS AND OUTPUTS

//both 4 bit values
input [3:0] SS_in, INC_in;
input Start, Ack, Clk, Reset, Right, Left, Up, Down, Select;
output Lives;
output Qi, Qg, Qfo, Qp, Ql;
output outA, outB;
output outX, outY;

// DECLARE ALL THE LOCAL VARIABLES

reg[4:0] ones, seed, increment, score, state;
// Declare 2, 4X4 Arrays
reg [3:0] A [9:0];
reg [3:0] B [9:0];
// NOTE : positive X is to the right, positive Y is down
reg [2:0] X,Y,I, searchX, searchY;
reg [1:0] lives; //max 3;




localparam
INITIAL = 5'b00001,
GENERATE = 5'b00010,
FINDONES = 5'b00100;
PLAY = 5'01000;
LOSE = 5'10000;

always @(posedge Clk, posedge Reset) 
  begin  : memory_test
    if (Reset)
       begin
		  state <= INITIAL;
       end
    else
       begin
         //(* full_case, parallel_case *)
         case (state)
	        INITIAL: 
	          begin
		         // STATE TRANSITION
		         if (Start)
		           state <= GENERATE;
		         // RTL
				   X <= 0;
				   Y <= 0;
				   I <= 0;
				   searchX <= 0;
				   searchY <= 0;
				   ones <= 0;
				   seed <= SS_in;
				   increment <= INC_in;
				   score <= 0;
				   lives <= 3;
	          end
	        GENERATE:
	          begin
		         // STATE TRANSITION
		         if (I == 3)
		           state <= FINDONES;
		         // RTL
		         if (I < 4) //or I<=3, last operation with I==3
		           begin
		             A[I] <= seed;
					 seed <= seed + increment;
					 I <= I+1;
		           end
				 if (I == 3) //redundant, but just to seperate RTL and STATE TRANSITION
					I <= 0;
 	          end
	        FINDONES:
	          begin  
				// STATE TRANSITION
				if(searchX == 3 && searchY == 3) //if we went through the whole thing, this is very inefficient unfortunately
					state <= PLAY;
				// RTL
				if(A[searchX][searchY] == 1)
					findones <= findones + 1;
				if(searchX == 3)//if dones with this row
					searchX <= 0;
	          end    
			PLAY:
	          begin  
				// STATE TRANSITION
				if(findones == 0)
					state <= GENERATE;
				else if(findones != 0 && lives == 0)
					state <= LOSE;
				//else, stay here
				// RTL
				
				//manage movement
				if(Right && X < 3)
					X <= X + 1;
				else if(Left && X > 0)
					X <= X - 1;
				else if(Up && Y > 0)
					Y <= Y - 1;
				else if(Down && Y < 3)
					Y <= Y + 1;
				//manage select
				else if(Select)
					begin
						if(A[X][Y] == 1)
							B[X][Y] <= 1;
							findones <= findones - 1;
						else
							lives <= lives - 1;
					end
				//if all found, increase score;
				if(findones == 0)
					score <= score + 1;
	          end   
			LOSE:
	          begin  
				// STATE TRANSITION
				if(Start)
					state <= INITIAL;
				// RTL
	          end   
      endcase
    end 
  end
 
	 //OFL
	 assign {Qi, Qg, Qfo, Qp, Ql} = state;
	 //output so we can display
	 assign Lives = lives;
	//allow top to see what the arrays are.
	assign outA = A;
	assign outB = B;
	//allow top to see what square we are currently one
	assign outX = X;
	assign outY = Y;
	assign Lives = lives;
endmodule  // memory_test