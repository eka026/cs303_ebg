// DO NOT CHANGE THE NAME OR THE SIGNALS OF THIS MODULE

module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);

/* Your design goes here. */
// State definitions
parameter IDLE = 4'b0000;
parameter SHOW_A = 4'b0001;
parameter A_IN = 4'b0010;
parameter ERROR_A = 4'b0011;
parameter SHOW_B = 4'b0100;
parameter B_IN = 4'b0101;
parameter ERROR_B = 4'b0110;
parameter SHOW_SCORE = 4'b0111;
parameter A_SHOOT = 4'b1000;
parameter A_SINK = 4'b1001;
parameter A_WIN = 4'b1010;
parameter B_SHOOT = 4'b1011;
parameter B_SINK = 4'b1100;
parameter B_WIN = 4'b1101;

// Internal registers
reg [15:0] A_map;
reg [15:0] B_map;
reg [3:0] currentState;
reg [3:0] nextState;
reg [2:0] A_score;
reg [2:0] B_score;
reg [2:0] A_counter;
reg [2:0] B_counter;
reg [5:0] timer;
reg Z; // To store hit/miss status

// Sequential state transitions
always@ (posedge clk or posedge rst)
begin
  if (rst)
    begin
      currentState <= IDLE;
        // Reset other registers
        A_map <= 16'b0;
        B_map <= 16'b0; 
        A_score <= 3'b0;
        B_score <= 3'b0;
        A_counter <= 3'b0;
        B_counter <= 3'b0;
        timer <= 6'b0;
        Z <= 1'b0;
    end
  else
    begin
      currentState <= nextState;
      case(currentState)
      IDLE:
      begin
        timer <= 0;
      end
      SHOW_A:
      begin
        timer <= timer + 1;
      end
      A_IN:
      begin
        if (pAb && A_map[Y*4 + X] == 1'b0 )
        begin
          if(A_counter > 2)
            begin
              A_map[(Y*4) + X] <= 1'b1;
            end
          else
            begin
              A_map[(Y*4) + X] <= 1'b1;
              A_counter <= A_counter + 1;
            end
        end

        timer <= 6'd0;

      end
      ERROR_A:
      begin
        timer <= timer + 1;
      end
      SHOW_B:
      begin
        timer <= timer + 1;
      end
      B_IN:
      begin
        if (pBb && B_map[Y*4 + X] == 1'b0 )
        begin
          if(B_counter > 2)
            begin
              B_map[(Y*4) + X] <= 1'b1;
            end
          else
            begin
              B_map[(Y*4) + X] <= 1'b1;
              B_counter <= B_counter + 1;
            end
        end
    
        timer <= 6'd0;
      end
      ERROR_B:
      begin
        timer <= timer + 1;
      end
      SHOW_SCORE:
      begin
        timer <= timer + 1;
      end
      A_SHOOT:
      begin
        timer <= 6'd0;

        if (pAb)
        begin
          if (B_map[Y*4 + X] == 1'b1)
            begin
              A_score <= A_score + 1;
              B_map[Y*4 + X] <= 1'b0;
              Z <= 1'b1;
            end
          else
            begin
              Z <= 1'b0;
            end
        end
      end
      A_SINK:
      begin
        // Increment timer
        timer <= timer + 1;
      end
      A_WIN:
      begin
        // 1 second period blinking for all LEDs
        if(timer == 6'd49) 
          begin
            timer <= 6'd0;
          end
        else 
          begin
            timer <= timer + 1;
          end
      end
      B_SHOOT:
      begin
        timer <= 6'd0;

        if (pBb)
        begin
          if (A_map[Y*4 + X] == 1'b1)
            begin
              B_score <= B_score + 1;
              A_map[Y*4 + X] <= 1'b0;
              Z <= 1'b1;
            end
          else
            begin
              Z <= 1'b0;
            end
        end
      end
      B_SINK:
      begin
        // Increment timer
        timer <= timer + 1;
      end
      B_WIN:
      begin
        // 1 second period blinking for all LEDs
        if(timer == 6'd49) 
          begin
            timer <= 6'd0;
          end
        else 
          begin
            timer <= timer + 1;
          end
      end
    endcase
    end
end

// Combinational state transitions
always@(*)
begin

  // Default assignments to SSDs and LEDs
  disp3 = 8'b00000000;
  disp2 = 8'b00000000;
  disp1 = 8'b00000000;
  disp0 = 8'b00000000;
  led = 8'b00000000;

  nextState = currentState;
  case(currentState)
    IDLE:
    begin
      disp3 = 8'b00000110;
      disp2 = 8'b01011110;
      disp1 = 8'b00111000;
      disp0 = 8'b01111001;
      led[7] = 1;
      led[4] = 1;
      led[3] = 1;
      led[0] = 1;  
      if (start)
        nextState = SHOW_A;
    end
    SHOW_A:
    begin
      disp3 = 8'b01110111;
      disp2 = 8'b00000000;
      disp1 = 8'b00000000;
      disp0 = 8'b00000000;
      if (timer < 6'd50) // Count up to 50 since there are 50 cycles in 1 second
        nextState = SHOW_A;
      else
        begin
          nextState = A_IN;
        end
        
    end
    A_IN:
    begin
      disp3 = 8'b00000000;
      disp2 = 8'b00000000;

      
      case(X)  
        2'b00: disp1 = 8'b00111111; // "0"
        2'b01: disp1 = 8'b00000110; // "1"
        2'b10: disp1 = 8'b01011011; // "2"
        2'b11: disp1 = 8'b01001111; // "3"
      endcase


      case(Y)  
          2'b00: disp0 = 8'b00111111; // "0"
          2'b01: disp0 = 8'b00000110; // "1"
          2'b10: disp0 = 8'b01011011; // "2"
          2'b11: disp0 = 8'b01001111; // "3"
      endcase
      nextState = A_IN; // If no conditions are satisfied, state stays in A_IN

      // It's A's turn, so light up LED7
      led[7] = 1'b1;

      // Set LED5,4 based on input count of player A
      led[5:4] = A_counter[1:0];
      
      // Turn off other lights
      led[6] = 1'b0;
      led[3:0] = 4'b0000;
  
      if (pAb)
        begin
          if(A_map[(Y*4)+X] == 1'b1)
            begin
              nextState = ERROR_A;
            end
          else
            begin
              if(A_counter > 2)
                nextState = SHOW_B;
            end
        end
    end
    ERROR_A:
    begin

      disp3 = 8'b01111001;
      disp2 = 8'b01010000;
      disp1 = 8'b01010000;
      disp0 = 8'b01011100;

      led[7] = 1'b1;
      led[4] = 1'b1;
      led[3] = 1'b1;
      led[0] = 1'b1;

      if(timer < 6'd50)
        begin
          nextState = ERROR_A;
        end
      else
        begin
          nextState = A_IN;
        end
        
    end
    SHOW_B:
    begin

      disp3 = 8'b01111100;
      disp2 = 8'b00000000;
      disp1 = 8'b00000000;
      disp0 = 8'b00000000;
      if (timer < 6'd50)
        begin
          nextState = SHOW_B;
        end
      else
        begin
          nextState = B_IN;
        end
        
    end
    B_IN:
    begin
      nextState = B_IN; // If no conditions are satisfied, state stays in B_IN
      disp3 = 8'b00000000;
      disp2 = 8'b00000000;

      
      case(X)  
        2'b00: disp1 = 8'b00111111; // "0"
        2'b01: disp1 = 8'b00000110; // "1"
        2'b10: disp1 = 8'b01011011; // "2"
        2'b11: disp1 = 8'b01001111; // "3"
      endcase


      case(Y)  
          2'b00: disp0 = 8'b00111111; // "0"
          2'b01: disp0 = 8'b00000110; // "1"
          2'b10: disp0 = 8'b01011011; // "2"
          2'b11: disp0 = 8'b01001111; // "3"
      endcase

       // It's B's turn, so light up LED0
      led[0] = 1'b1;

      // Set LED5,4 based on input count of player A
      led[3:2] = B_counter[1:0];
      
      // Turn off other lights
      led[1] = 1'b0;
      led[7:4] = 4'b0000;
      if (pBb)
        begin
          if(B_map[(Y*4)+X] == 1'b1)
            begin
              nextState = ERROR_B;
            end
          else
            begin
              if(B_counter > 2)
                nextState = SHOW_SCORE;
            end
        end
    end
    ERROR_B:
    begin
      disp3 = 8'b01111001;
      disp2 = 8'b01010000;
      disp1 = 8'b01010000;
      disp0 = 8'b01011100;

      led[7] = 1'b1;
      led[4] = 1'b1;
      led[3] = 1'b1;
      led[0] = 1'b1;
      if(timer < 6'd50)
        begin
          nextState = ERROR_B;
        end
      else
        begin
          nextState = B_IN;
        end
    end
    SHOW_SCORE:
    begin

      disp3 = 8'b00111111;
      disp2 = 8'b01000000;
      disp1 = 8'b01000000;
      disp0 = 8'b00111111;

      led[7] = 1'b1;
      led[4] = 1'b1;
      led[3] = 1'b1;
      led[0] = 1'b1;

      if(timer < 6'd50)
        begin
          nextState = SHOW_SCORE;
        end
      else
        begin
          nextState = A_SHOOT;
        end

    end
    A_SHOOT:
    begin
      disp3 = 8'b00000000;
      disp2 = 8'b00000000;

      
      case(X)  
        2'b00: disp1 = 8'b00111111; // "0"
        2'b01: disp1 = 8'b00000110; // "1"
        2'b10: disp1 = 8'b01011011; // "2"
        2'b11: disp1 = 8'b01001111; // "3"
      endcase


      case(Y)  
          2'b00: disp0 = 8'b00111111; // "0"
          2'b01: disp0 = 8'b00000110; // "1"
          2'b10: disp0 = 8'b01011011; // "2"
          2'b11: disp0 = 8'b01001111; // "3"
      endcase

      led[7] = 1'b1;

      led[5:4] = A_score[1:0];
      led[3:2] = B_score[1:0];
      
      led[6] = 1'b0;
      led[1:0] = 2'b00;
      if(pAb)
        begin
          if(B_map[(Y*4)+X] == 1'b1)
            begin
              nextState = A_SINK;
            end
          else
            begin
              nextState = A_SINK;
            end
        end
      else
        begin
          nextState = A_SHOOT;
        end
    end
    A_SINK:
    begin
    case(A_score)
        3'd0: disp3 = 8'b00111111; 
        3'd1: disp3 = 8'b00000110; 
        3'd2: disp3 = 8'b01011011; 
        3'd3: disp3 = 8'b01001111; 
        3'd4: disp3 = 8'b01100110; 
        default: disp3 = 8'b00111111; 
      endcase

      disp2 = 8'b01000000;
      disp1 = 8'b01000000; 
      
      case(B_score)
          3'd0: disp0 = 8'b00111111; // "0"
          3'd1: disp0 = 8'b00000110; // "1"
          3'd2: disp0 = 8'b01011011; // "2"
          3'd3: disp0 = 8'b01001111; // "3"
          3'd4: disp0 = 8'b01100110; // "4"
          default: disp0 = 8'b00111111; // "0"
      endcase

      if (Z == 1'b1) 
        begin
          led = 8'b11111111; // All LEDs on for hit
        end
      else 
        begin
          led = 8'b00000000; // All LEDs off for miss
        end

    if (timer < 6'd50)
      begin
        if (Z == 1'b1)
          begin
            nextState = A_SINK;
          end
        else
          begin
            nextState = A_SINK;
          end
      end
    else
      begin
        if (A_score > 3)
          begin
            nextState = A_WIN;
          end
        else
          begin
            nextState = B_SHOOT;
          end
      end
    end
    A_WIN:
    begin
      disp3 = 8'b01110111;

      // Display the final score
      case(A_score)
        3'd0: disp2 = 8'b00111111; 
        3'd1: disp2 = 8'b00000110; 
        3'd2: disp2 = 8'b01011011; 
        3'd3: disp2 = 8'b01001111; 
        3'd4: disp2 = 8'b01100110; 
        default: disp2 = 8'b00111111;
      endcase

      case(B_score)
        3'd0: disp0 = 8'b00111111; 
        3'd1: disp0 = 8'b00000110; 
        3'd2: disp0 = 8'b01011011; 
        3'd3: disp0 = 8'b01001111; 
        3'd4: disp0 = 8'b01100110; 
        default: disp0 = 8'b00111111;
      endcase

      // Display "-" on SSD1
      disp1 = 8'b01000000;

      // All LEDs on for first half second, all off for second half
      if(timer < 6'd25) 
      begin
        led = 8'b11111111; 
      end
      else 
      begin
        led = 8'b00000000;
      end
      nextState = A_WIN;
    end
    B_SHOOT:
    begin

      disp3 = 8'b00000000;
      disp2 = 8'b00000000;

      
      case(X)  
        2'b00: disp1 = 8'b00111111; // "0"
        2'b01: disp1 = 8'b00000110; // "1"
        2'b10: disp1 = 8'b01011011; // "2"
        2'b11: disp1 = 8'b01001111; // "3"
      endcase


      case(Y)  
          2'b00: disp0 = 8'b00111111; // "0"
          2'b01: disp0 = 8'b00000110; // "1"
          2'b10: disp0 = 8'b01011011; // "2"
          2'b11: disp0 = 8'b01001111; // "3"
      endcase

      led[7] = 1'b1;

      led[5:4] = A_score[1:0];
      led[3:2] = B_score[1:0];
      
      led[6] = 1'b0;
      led[1:0] = 2'b00;
      if(pBb)
        begin
          if (A_map[(Y*4)+X] == 1'b1)
            begin
              nextState = B_SINK;
            end
          else
            begin
              nextState = B_SINK;
            end
        end
      else
        begin
          nextState = B_SHOOT;
        end
    end
    B_SINK:
    begin
      case(A_score)
        3'd0: disp3 = 8'b00111111; 
        3'd1: disp3 = 8'b00000110; 
        3'd2: disp3 = 8'b01011011; 
        3'd3: disp3 = 8'b01001111; 
        3'd4: disp3 = 8'b01100110; 
        default: disp3 = 8'b00111111; 
      endcase

      disp2 = 8'b01000000;
      disp1 = 8'b01000000; 
      
      case(B_score)
          3'd0: disp0 = 8'b00111111; // "0"
          3'd1: disp0 = 8'b00000110; // "1"
          3'd2: disp0 = 8'b01011011; // "2"
          3'd3: disp0 = 8'b01001111; // "3"
          3'd4: disp0 = 8'b01100110; // "4"
          default: disp0 = 8'b00111111; // "0"
      endcase

      if (Z == 1'b1) 
        begin
          led = 8'b11111111; // All LEDs on for hit
        end
      else 
        begin
          led = 8'b00000000; // All LEDs off for miss
        end
      if (timer < 6'd50)
        begin
          if (Z == 1'b1)
            begin
              nextState = B_SINK;
            end
          else
            begin
              nextState = B_SINK;
            end
        end
      else
        begin
          if (B_score > 3)
            begin
              nextState = B_WIN;
            end
          else
            begin
              nextState = A_SHOOT;
            end
        end
    end
    B_WIN:
    begin
      disp3 = 8'b01111100;

      // Display the final score
      case(A_score)
        3'd0: disp2 = 8'b00111111; 
        3'd1: disp2 = 8'b00000110; 
        3'd2: disp2 = 8'b01011011; 
        3'd3: disp2 = 8'b01001111; 
        3'd4: disp2 = 8'b01100110; 
        default: disp2 = 8'b00111111;
      endcase

      case(B_score)
        3'd0: disp0 = 8'b00111111; 
        3'd1: disp0 = 8'b00000110; 
        3'd2: disp0 = 8'b01011011; 
        3'd3: disp0 = 8'b01001111; 
        3'd4: disp0 = 8'b01100110; 
        default: disp0 = 8'b00111111;
      endcase

      // Display "-" on SSD1
      disp1 = 8'b01000000;

      // All LEDs on for first half second, all off for second half
      if(timer < 6'd25) 
      begin
        led = 8'b11111111; 
      end
      else 
      begin
        led = 8'b00000000;
      end
      nextState = B_WIN;
    end
  endcase
end

endmodule
