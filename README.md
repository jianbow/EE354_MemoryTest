# EE354_MemoryTest

Link to the state machine diagram: 
https://drive.google.com/file/d/1wR7WM8XkPMT_f0bBvVhx4qE_nV9Q2Smr/view?usp=sharing

## How the pseudo random generation works

The 4X4 grid is represented by 4, 4bit numbers, 1's represents hits and 0's represent invalid squares.
We start with the given seed and increment values. We just use increment to generate the next row. This continues into the next grid.
This generates a decently random, yet patterned grid for our memory test, and uses the fact that counters will loop.

### Example
Seed: 0, Increment 3

#### Grid 1
0000: Val = 0<br />
0011: Val = 3<br />
0110: Val = 6<br />
1001: Val = 9<br />

#### Grid 2
1100: Val = 12<br />
1111: Val = 15<br />
0010: Val = 2<br />
0101: Val = 5<br />

## Files for Simulation
* memory_sm.v
* memory_tb.v
## Files for Synthesis
* ee201_debounce_DPB_SCEN_CCEN_MCEN.v
* memory_sm.v
* memory_top.v
* memory_top.xdc
