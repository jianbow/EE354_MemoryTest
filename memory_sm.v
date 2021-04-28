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
				
module memory (SS_in, INC_in, Start, Ack, Clk, Reset, Right, Left, Up, Down, Select, outScore,
				Lives, outA0, outA1, outA2, outA3, outB0, outB1, outB2, outB3, Qi, Qg, Qfo, Qp, Ql, outX, outY, unos);
				
//DECLARE ALL MY INPUTS AND OUTPUTS

//both 4 bit values
input [3:0] SS_in, INC_in;
input Start, Ack, Clk, Reset, Right, Left, Up, Down, Select;
output [3:0] Lives;
output Qi, Qg, Qfo, Qp, Ql;
output [3:0] outA0, outA1, outA2, outA3, outB0, outB1, outB2, outB3;
output [1:0] outX, outY;
output [3:0] unos;
output [3:0] outScore;

// DECLARE ALL THE LOCAL VARIABLES

reg[4:0] ones;
reg[4:0] seed;
reg[4:0] increment;
reg[3:0] score;
reg[4:0] state;
// Declare 2, 4X4 Arrays

reg [3:0] findones;

reg [3:0] A [3:0];
reg [3:0] B [3:0];

// NOTE : positive X is to the right, positive Y is down
reg [1:0] X;
reg [1:0] Y;
reg [2:0] I;
reg [2:0] searchX;
reg [2:0] searchY;
reg [3:0] lives; //max 3;
reg flag;



localparam
INITIAL = 5'b00001,
GENERATE = 5'b00010,
FINDONES = 5'b00100,
PLAY = 5'b01000,
LOSE = 5'b10000;

always @(posedge Clk, posedge Reset) 
  begin  : memory_test
    if (Reset)
       begin
		  state <= INITIAL;
		  B[0][3:0] = 4'bXXXX;
		  B[1][3:0] = 4'bXXXX;
	      B[2][3:0] = 4'bXXXX;
	      B[3][3:0] = 4'bXXXX;
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
				   X <= 2'b00;
				   Y <= 2'b00;
				   I <= 2'b00;
				   searchX <= 2'b00;
				   searchY <= 2'b00;
				   ones <= 0;
				   seed <= SS_in;
				   increment <= INC_in;
				   score <= 0;
				   lives <= 3;
				   findones<=0;
				   B[0][3:0] = 4'b0000;
				   B[1][3:0] = 4'b0000;
				   B[2][3:0] = 4'b0000;
				   B[3][3:0] = 4'b0000;
	          end
	        GENERATE:
	          begin
		         // STATE TRANSITION
		         if (I == 3)
		           state <= FINDONES;
		           flag <= 0;
		         // RTL
		         if (I < 4) //or I<=3, last operation with I==3
		           begin
		             A[I] <= seed;
		             B[I] <= 0;
					 seed <= seed + increment;
					 I <= I+1;
		           end
				 if (I == 3) //redundant, but just to seperate RTL and STATE TRANSITION
					I <= 0;
 	          end
	        FINDONES:
	          begin  
				// STATE TRANSITION
				if(searchX == 3 && searchY == 3 && Start) //if we went through the whole thing, this is very inefficient unfortunately
				    begin
					   state <= PLAY;
					   searchX <= 0;
					   searchY <= 0;
                   end
				// RTL
				if(~flag) begin
				    if(searchX == 3 && searchY ==3)
				        flag <= 1;
                    if(A[searchX][searchY] == 1)
                        findones <= findones + 1;
                    if(searchX == 3 && searchY != 3)//if dones with this row
                        begin
                            searchX <= 0;
                            searchY <= searchY + 1;
                        end
                    else if(searchX != 3)
                        searchX <= searchX + 1;
                end
	          end    
			PLAY:
	          begin  
				// STATE TRANSITION
				if(findones == 0) begin
					state <= GENERATE;
					score <= score + 1;
					X <= 0;
					Y <= 0;
					end
				else if(findones != 0 && lives == 0)
					state <= LOSE;
				//else, stay here
				// RTL
				
				//manage movement
				if(Right && Y < 3)
					Y <= Y + 1;
				else if (Right && Y==3)
				    Y<= 0;
				if(Left && Y > 0)
					Y <= Y - 1;
				else if (Left && Y==0)
				    Y <= 3;
				if(Up && X > 0)
					X <= X - 1;
				else if (Up && X==0)
				    X<= 3;
				if(Down && X < 3)
					X <= X + 1;
				else if(Down && X==3)
				    X<= 0;
				//manage select
				if(Select)
					begin
						if(A[X][Y] == 1 && B[X][Y] == 0)
						begin
							B[X][Y] <= 1;
							findones <= findones - 1;
						end
						else if(A[X][Y] == 0 && B[X][Y] == 0)
						begin
						    B[X][Y] <= 1;
							lives <= lives - 1;
						end
					end
				end
				//if all found, increase score; 
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
	 //assign {Qi, Qg, Qfo, Qp, Ql} = state;
	 assign {Ql, Qp, Qfo, Qg, Qi} = state;
	 //output so we can display
	 assign Lives = lives;
	//allow top to see what the arrays are.
	assign outA0 = A[0];
	assign outA1 = A[1];
	assign outA2 = A[2];
	assign outA3 = A[3];
	assign outB0 = B[0];
	assign outB1 = B[1];
	assign outB2 = B[2];
	assign outB3 = B[3];
	//allow top to see what square we are currently one
	//assign outX = X;
	//assign outY = Y;
	assign outScore = score;
	assign outX = X;
	assign outY = Y;
	assign unos = findones;
endmodule  // memory_test