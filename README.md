# learning-rps
Rock Paper Scissor with AI: 

Intuition: Users indicate their choice on switches. Both Computer's and user's choices would be indicated on the monitor. Computer has 3 modes: random, markov, and reinforcement. In the last 2 modes, computer will try to win the user by learning the user's pattern of choice.
Device: FPGA board, monitor.

# Top Level Module
m3

# Modules
- m3: integrating the frontend(vga display) and backend(mathmatical computations for the three modes)
- hex_decoder: tranlate the score in decimal to hex display
- screen_display: translate user's and computer's choice into corresponding images on VGA display. 
- image_translator: translate the (x,y) coordinate in a 80*120 resolution images to address. The data from here is needed by screen_display for intepreting data stored in Rom
- random: random number generator
- markov: main computation for the markov method
- comparator_matrix: comparator for the markov method
- reinforce: top level module for the reinforce method
- comparator_32: comparator for the reinforce method
- theta: parameter computation for the reinforce method

# Module that are not created by us
- VGA adapter
- modules for single-precision floating point computation: float_adder, ALTFP_EXa, float_div, float_multi, float_compare

# Other required file
- new_rock.mono.mif 
- new_paper.mono.mif
- new_scissor.mono.mif
- rock.bmp
- scissor.bmp
- paper.bmp
