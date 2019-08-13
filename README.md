# learning-rps
Rock Paper Scissor with AI: 
Instrution: Users indicate their choice on switches. Both Computer's and user's choices would be indicated on the monitor. Computer has 3 modes: random, markov, and reinforcement. In the last 2 modes, computer will try to win user every single turns.
Device: FPGA board, monitor.

# Top level name
- m3: integrating the frontend(vga display) and backend(logics & machine learning), depends on data from screen_display, backend(....), and hex_decoder. 
- hex_decoder: tranlate the score in decimal to hex display
- screen_display: translate user's and computer's choice into corresponding images on VGA display. 
- image_translator: translate the (x,y) coordinate in a 80*120 resolution images to address. The data from here is needed by scree_display for intepreting data stored in Rom

# Module that are not created by us
- VGA adapter

# Resources
- Github: source code

# Other required file
- new_rock.mono.mif 
- new_paper.mono.mif
- new_scissor.mono.mif
- rock.bmp
- scissor.bmp
- paper.bmp
