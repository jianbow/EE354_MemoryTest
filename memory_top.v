/*
TODO
	NEED TO ADD SINGLE STEPPING
	NEED TO ADD OUTPUTS FOR VGA
	NEED TO MAKE SURE THIS WORKS
	NEED TO MAKE SURE DEFAULT XDC WORKS
	NEED TO MAKE SURE THIS WORKS
	
	TESTING STEPS
	1. CREATE TB TO MAKE SURE STATE MACHINE WORKS
	2. CONFIRM THAT PLAIN TESTBENCH FILE WORKS WITH NO VGA
	3. MAKE SURE VGA CAN OUTPUT PRESET VALUES
	4. TIE VGA OUTPUT CODE WITH THIS TOP FILE TO GET FINAL DESIGN
*/
module memory_top	(   
		MemOE, MemWR, RamCS, QuadSpiFlashCS, // Disable the three memory chips

        ClkPort,                           // the 100 MHz incoming clock signal
		
		BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons 		BtnL, BtnR,
		BtnC,                              // the center button (this is our reset in most of our designs)
		Sw8, Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0, // 9 switches
		Ld8, Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 9 LEDs
		An3, An2, An1, An0,			       // 4 anodes
		An7, An6, An5, An4,                // another 4 anodes (need turned off)
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
		Dp,                                 // Dot Point Cathode on SSDs
		hSync, vSync,
		vgaR, vgaB, vgaG
	  );

	 
								
	/*  INPUTS */
	// Clock & Reset I/O
	input		ClkPort;	
	// Project Specific Inputs
	input		BtnL, BtnU, BtnD, BtnR, BtnC;	
	input		Sw8, Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;
	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;
	// Project Specific Outputs
	// LEDs
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7, Ld8;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	
	output  An4, An5, An6, An7;
	//VGA signal
	output hSync, vSync;
	output [3:0] vgaR, vgaG, vgaB;

	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire [2:0] 	ssdscan_clk;
	
	
	wire [3:0] 	SS_in, INC_in;
	wire [3:0] 	outX, outY, Lives;
	wire 		Start, Ack;
	//for all the states
	wire Qi, Qg, Qfo, Qp, Ql;
	
	//RGB
	wire [11:0] rgb;
	wire bright;
	wire[9:0] hc, vc;

// to produce divided clock
	reg [26:0]	DIV_CLK;
// SSD (Seven Segment Display)
	reg [3:0]	SSD;
	wire [3:0]	SSD4, SSD3, SSD2, SSD1, SSD0;
	reg [7:0]  	SSD_CATHODES;
	wire 		Right, Left, Up, Down, Select;
	//NOT SURE IF THIS SHOULD BE REG OR WIRE? i think reg bc endpoint
	
	wire [3:0] outA0, outA1, outA2, outA3, outB0, outB1, outB2, outB3;
	wire [3:0] outScore;
	
	
	//Move clk for moving selected square
	//wire move_clk;
	//assign move_clk=DIV_CLK[19]; //slower clock to drive the movement of objects on the vga screen
	
//------------	
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
	
	
//------------
// CLOCK DIVISION

	// The clock division circuitary works like this:
	//
	// ClkPort ---> [BUFGP2] ---> board_clk
	// board_clk ---> [clock dividing counter] ---> DIV_CLK
	// DIV_CLK ---> [constant assignment] ---> sys_clk;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	

// As the ClkPort signal travels throughout our design,
// it is necessary to provide global routing to this signal. 
// The BUFGPs buffer these input ports and connect them to the global 
// routing resources in the FPGA.

	// BUFGP BUFGP2 (Reset, BtnC); In the case of Spartan 3E (on Nexys-2 board), we were using BUFGP to provide global routing for the reset signal. But Spartan 6 (on Nexys-3) does not allow this.
	
	//I'm changing this to Switch 8
	assign Reset = Sw8;
	
	//assign the directions
	assign Right = BtnR;
	assign Left = BtnL;
	assign Up = BtnU;
	assign Down = BtnD;
	assign Select = BtnC;
	
//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
  always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//------------	
	// In this design, we run the core design at full 50MHz clock!
	
	//MIGHT WANT TO ADJUST THIS VAL FOR OUR DESIGN
	assign	sys_clk = board_clk;
	// assign	sys_clk = DIV_CLK[25];


	//------------         

	assign SS_in = {Sw7, Sw6, Sw5, Sw4};
	assign INC_in = {Sw3, Sw2, Sw1, Sw0};
	
	//TODO
	//MIGHT NEED TO CHECK THIS
	//am i allowed to do this?
	assign Start = BtnC;
    assign Ack = BtnC; // This was used in the divider_simple and also here
	
	// Unlike in the divider_simple, here we use one button BtnU to represent SCEN
	// Instantiate the debouncer	// module ee201_debouncer(CLK, RESET, PB, DPB, SCEN, MCEN, CCEN);
	// notice the "SCEN" is produced here and is sent into the divider core further below
	
	//WILL NEED TO USE SCEN
	/*
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(SCEN), .MCEN( ), .CCEN( ));
		*/
							
						
	// instantiate the core divider design. Note the .SCEN(SCEN)
/*divider divider_1(.Xin(Xin), .Yin(Yin), .Start(Start), .Ack(Ack), .Clk(sys_clk), .Reset(Reset), 
				.SCEN(SCEN), .Done(Done), .Quotient(Quotient), .Remainder(Remainder), .Qi(Qi), .Qc(Qc), .Qd(Qd) );*/
				
ee201_debouncer #(.N_dc(25)) ee201_debouncer_SACK 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(SCENSACK), .MCEN( ), .CCEN( ));

ee201_debouncer #(.N_dc(25)) ee201_debouncer_R 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(SCENR), .MCEN( ), .CCEN( ));
        
ee201_debouncer #(.N_dc(25)) ee201_debouncer_L
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(SCENL), .MCEN( ), .CCEN( ));
        
ee201_debouncer #(.N_dc(25)) ee201_debouncer_D
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(SCEND), .MCEN( ), .CCEN( ));
        
ee201_debouncer #(.N_dc(25)) ee201_debouncer_U
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(SCENU), .MCEN( ), .CCEN( ));
				
memory mem_test(.SS_in(SS_in), .INC_in(INC_in), .Start(SCENSACK), .Ack(SCENSACK), .Clk(sys_clk), .Reset(Reset), .Right(SCENR), .Left(SCENL), .Up(SCENU), .Down(SCEND), .Select(SCENSACK),
				.Lives(Lives), .outScore(outScore), .outA0(outA0), .outA1(outA1), .outA2(outA2), .outA3(outA3), .outB0(outB0), .outB1(outB1), .outB2(outB2), .outB3(outB3), .Qi(Qi), .Qg(Qg), .Qfo(Qfo), .Qp(Qp), .Ql(Ql), .outX(outX), .outY(outY), .unos(unos));

display_controller dc(.clk(sys_clk), .hSync(hSync), .vSync(vSync), .bright(bright), .hCount(hc), .vCount(vc));

block_controller sc(.bright(bright), .X(outX), .Y(outY), .A0(outA0), .A1(outA1), .A2(outA2), .A3(outA3), .B0(outB0), .B1(outB1), .B2(outB2), .B3(outB3), .Qi(Qi), .Qg(Qg), .Qfo(Qfo), .Qp(Qp), .Ql(Ql), .hCount(hc), .vCount(vc), .rgb(rgb));

//------------
// OUTPUT: LEDS
	
	assign {Ld8, Ld7, Ld6, Ld5, Ld4} = {Qi, Qg, Qfo, Qp, Ql};
	assign {Ld3, Ld2, Ld1, Ld0} = {Start,Right,Left,Up}; // We do not want to put SCEN in place of BtnU here as the Ld2 will be on for just 10ns!
	
	//
	assign vgaR = rgb[11 : 8];
	assign vgaG = rgb[7  : 4];
	assign vgaB = rgb[3  : 0];

//------------
// SSD (Seven Segment Display)
	// reg [3:0]	SSD;
	// wire [3:0]	SSD3, SSD2, SSD1, SSD0;
	
	//SSDs display Xin, Yin, Quotient, and Reminder  
	assign SSD7 = outScore;
	assign SSD4 = Lives;
	assign SSD3 = SS_in;
	assign SSD2 = INC_in;
	assign SSD1 = outX;
	assign SSD0 = outY;


	// need a scan clk for the seven segment display 
	
	// 100 MHz / 2^18 = 381.5 cycles/sec ==> frequency of DIV_CLK[17]
	// 100 MHz / 2^19 = 190.7 cycles/sec ==> frequency of DIV_CLK[18]
	// 100 MHz / 2^20 =  95.4 cycles/sec ==> frequency of DIV_CLK[19]
	
	// 381.5 cycles/sec (2.62 ms per digit) [which means all 4 digits are lit once every 10.5 ms (reciprocal of 95.4 cycles/sec)] works well.
	
	//                  --|  |--|  |--|  |--|  |--|  |--|  |--|  |--|  |   
    //                    |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
	//  DIV_CLK[17]       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
	//
	//               -----|     |-----|     |-----|     |-----|     |
    //                    |  0  |  1  |  0  |  1  |     |     |     |     
	//  DIV_CLK[18]       |_____|     |_____|     |_____|     |_____|
	//
	//         -----------|           |-----------|           |
    //                    |  0     0  |  1     1  |           |           
	//  DIV_CLK[19]       |___________|           |___________|
	//
	
	assign ssdscan_clk = DIV_CLK[19:17];

	assign An0	= !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 000
	assign An1	= !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 001
	assign An2	=  !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 010
	assign An3	=  !(~(ssdscan_clk[2]) && (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 011
	assign An4  = !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 100
	assign An7  = !((ssdscan_clk[2]) && ~(ssdscan_clk[1]) && (ssdscan_clk[0]));  // when ssdscan_clk = 101
	assign {An6, An5} = 2'b11;
	
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD7)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  3'b000: SSD = SSD0;
				  3'b001: SSD = SSD1;
				  3'b010: SSD = SSD2;
				  3'b011: SSD = SSD3;
				  3'b100: SSD = SSD4;
				  3'b101: SSD = SSD7;
		endcase 
	end

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 8'b00000010; // 0
			4'b0001: SSD_CATHODES = 8'b10011110; // 1
			4'b0010: SSD_CATHODES = 8'b00100100; // 2
			4'b0011: SSD_CATHODES = 8'b00001100; // 3
			4'b0100: SSD_CATHODES = 8'b10011000; // 4
			4'b0101: SSD_CATHODES = 8'b01001000; // 5
			4'b0110: SSD_CATHODES = 8'b01000000; // 6
			4'b0111: SSD_CATHODES = 8'b00011110; // 7
			4'b1000: SSD_CATHODES = 8'b00000000; // 8
			4'b1001: SSD_CATHODES = 8'b00001000; // 9
			4'b1010: SSD_CATHODES = 8'b00010000; // A
			4'b1011: SSD_CATHODES = 8'b11000000; // B
			4'b1100: SSD_CATHODES = 8'b01100010; // C
			4'b1101: SSD_CATHODES = 8'b10000100; // D
			4'b1110: SSD_CATHODES = 8'b01100000; // E
			4'b1111: SSD_CATHODES = 8'b01110000; // F    
			default: SSD_CATHODES = 8'bXXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
	// reg [7:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp} = {SSD_CATHODES};
	
endmodule
