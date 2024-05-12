module glbl_ctrl #(
    parameter X_BUF_ADDR    = 10, 
    parameter W_BUF_1_ADDR  = 10, 
    parameter W_BUF_2_ADDR  = 6,
    parameter W_BUF_3_ADDR  = 5,
    parameter W_BUF_4_ADDR  = 5,
    parameter W_BUF_5_ADDR  = 4,
    parameter TEMP_BUF_ADDR = 6,
    
    parameter IDLE      = 3'b000,
    parameter STATE_1   = 3'b001,
    parameter STATE_2   = 3'b011,
    parameter STATE_3   = 3'b010,
    parameter STATE_4   = 3'b110,
    parameter STATE_5   = 3'b111,
    parameter STATE_6   = 3'b101,
    parameter DONE      = 3'b100
)(
    // system interface
    input   wire                        clk,
    input   wire                        rst_n,
    input   wire                        start_i,
    output  wire                        done_intr_o,
    output  wire                        done_led_o,
    
    // x_buffer interface
    output  wire                        x_buf_en_o,
    output  wire [X_BUF_ADDR - 1:0]     x_buf_addr_o,
    
    // w_buffer interface
    output  wire                        w_buf_1_en_o,
    output  wire [W_BUF_1_ADDR - 1:0]   w_buf_1_addr_o,
    
    // w_buffer_2
    output  wire                        w_buf_2_en_o,
    output  wire [W_BUF_2_ADDR - 1:0]   w_buf_2_addr_o,
    
    // w_buffer_3
    output  wire                        w_buf_3_en_o,
    output  wire [W_BUF_3_ADDR - 1:0]   w_buf_3_addr_o,
    
    // w_buffer_4
    output  wire                        w_buf_4_en_o,
    output  wire [W_BUF_4_ADDR - 1:0]   w_buf_4_addr_o,
    
    // w_buffer_5
    output  wire                        w_buf_5_en_o,
    output  wire [W_BUF_5_ADDR - 1:0]   w_buf_5_addr_o,
    
    // temp_buffer
    output  wire                        temp_buf_en_o,
    output  wire                        temp_buf_wen_o,
    output  wire [TEMP_BUF_ADDR - 1:0]  temp_buf_addr_o,
    output  wire                        temp_buf_rst_o,
    
    // y buffer interface
    output wire                         y_buf_en_o,
    output wire                         y_buf_wen_o,
    
    // mux interface
    output  wire [2 : 0]                w_buf_mux_o,          // w buf mux 1 of 5
    output  wire                        x_buf_mux_o,          // x buf or temp buf
    
    // processing unit interface
    output  wire                        prcss_start_o,
    input   wire                        prcss_done_i
);
reg [3 : 0]                 present_state;
reg [3 : 0]                 next_state;
reg [X_BUF_ADDR - 1 : 0]    count;

//x buf register
reg                         x_buf_en;
reg [X_BUF_ADDR - 1 : 0]    x_buf_addr;
    // w_buffer interface
reg                         w_buf_1_en;
reg [W_BUF_1_ADDR - 1:0]    w_buf_1_addr;
    
    // w_buffer_2
reg                         w_buf_2_en;
reg [W_BUF_2_ADDR - 1:0]    w_buf_2_addr;
    
    // w_buffer_3
reg                         w_buf_3_en;
reg [W_BUF_3_ADDR - 1:0]    w_buf_3_addr;
    
    // w_buffer_4
reg                         w_buf_4_en;
reg [W_BUF_4_ADDR - 1:0]    w_buf_4_addr;
    
    // w_buffer_5
reg                         w_buf_5_en;
reg [W_BUF_5_ADDR - 1:0]    w_buf_5_addr;
    
    // temp_buffer
reg                         temp_buf_en;
reg                         temp_buf_wen;
reg [TEMP_BUF_ADDR - 1:0]   temp_buf_addr;
reg                         temp_buf_rst;
    
reg                         y_buf_en;
reg                         y_buf_wen;
    // mux interface
reg [2 : 0]                 w_buf_mux;          // w buf mux 1 of 5
reg                         x_buf_mux;

reg                         prcss_start;

reg                         done_intr;
reg                         done_led; 

assign done_intr_o      = done_intr;
assign done_led_o       = done_led;     
assign x_buf_en_o       = x_buf_en;     
assign x_buf_addr_o     = x_buf_addr;
assign w_buf_1_en_o     = w_buf_1_en;
assign w_buf_1_addr_o   = w_buf_1_addr;
assign w_buf_2_en_o     = w_buf_2_en;  
assign w_buf_2_addr_o   = w_buf_2_addr; 
assign w_buf_3_en_o     = w_buf_3_en; 
assign w_buf_3_addr_o   = w_buf_3_addr;
assign w_buf_4_en_o     = w_buf_4_en; 
assign w_buf_4_addr_o   = w_buf_4_addr;
assign w_buf_5_en_o     = w_buf_5_en; 
assign w_buf_5_addr_o   = w_buf_5_addr;
assign temp_buf_en_o    = temp_buf_en; 
assign temp_buf_wen_o   = temp_buf_wen;
assign temp_buf_addr_o  = temp_buf_addr;
assign temp_buf_rst_o   = temp_buf_rst;
assign y_buf_en_o       = y_buf_en;
assign y_buf_wen_o      = y_buf_wen;
assign w_buf_mux_o      = w_buf_mux;
assign x_buf_mux_o      = x_buf_mux; 
assign prcss_start_o    = prcss_start; 
assign done_intr_o      = done_intr;
assign done_led_o       = done_led;

assign prcss_start_o = prcss_start;

always@(posedge clk) begin
    if(~rst_n) begin
        next_state      <= IDLE;
    end
    else begin
        present_state   <= next_state;
    end
end

always@ (posedge clk) begin
    case(present_state)
        IDLE : begin                    // reset all
                next_state      <= 0;
                count           <= 0;
                
                x_buf_en        <= 0;
                x_buf_addr      <= 0;
                
                w_buf_1_en      <= 0;
                w_buf_1_addr    <= 0;
                
                w_buf_2_en      <= 0;
                w_buf_2_addr    <= 0;
                
                w_buf_3_en      <= 0;
                w_buf_3_addr    <= 0;
                
                w_buf_4_en      <= 0;
                w_buf_4_addr    <= 0;
                
                w_buf_5_en      <= 0;
                w_buf_5_addr    <= 0;
                
                temp_buf_en     <= 0;
                temp_buf_wen    <= 0;
                temp_buf_addr   <= 0;
                temp_buf_rst    <= 0;
                
                y_buf_en        <= 0;
                y_buf_wen       <= 0;
                
                w_buf_mux       <= 0;
                x_buf_mux       <= 0;
                
                prcss_start     <= 0;
                
                done_intr       <= 0;
                done_led        <= 0;
                end
                
        STATE_1 : begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    x_buf_en            <= 1;
                    x_buf_addr          <= count;
                    
                    count               <= count + 1;
                    
                    w_buf_mux           <= 3'b000;
                    x_buf_mux           <= 0;
                    
                    prcss_start         <= 1;
                    
                    w_buf_1_en          <= 1;
                    w_buf_1_addr        <= count;
                    
                    temp_buf_rst    <= 0;
                    if(count == 784) begin              // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        temp_buf_en     <= 1;
                        temp_buf_wen    <= 1;
                        
                        count           <= 0;
                    end
                end
            end
        STATE_2 : begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    temp_buf_en         <= 1;
                    temp_buf_addr       <= count;
                    temp_buf_wen        <= 0;
                    temp_buf_rst        <= 0;
                    
                    count               <= count + 1;
                    x_buf_mux           <= 1;           // 0 -> x buf, 1 -> temp buf
                    w_buf_mux           <= 3'b001;      // 0 -> w1, 1 -> w2 ...
                    
                    w_buf_2_en          <= 1;
                    w_buf_2_addr        <= count;
                    if(count == 64) begin               // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        temp_buf_en     <= 1;
                        temp_buf_wen    <= 1;
                    end
                end
            end
        STATE_3 : begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    temp_buf_en         <= 1;
                    temp_buf_addr       <= count;
                    temp_buf_wen        <= 0;
                    temp_buf_rst        <= 0;
                    
                    count               <= count + 1;
                    x_buf_mux           <= 1;           // 0 -> x buf, 1 -> temp buf
                    w_buf_mux           <= 3'b010;      // 0 -> w1, 1 -> w2 ...
                    
                    w_buf_3_en          <= 1;
                    w_buf_3_addr        <= count;
                    if(count == 32) begin               // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        temp_buf_en     <= 1;
                        temp_buf_wen    <= 1;
                        
                        count           <= 0;
                    end
                end
            end
        STATE_4 : begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    temp_buf_en         <= 1;
                    temp_buf_addr       <= count;
                    temp_buf_wen        <= 0;
                    temp_buf_rst        <= 0;
                    
                    count               <= count + 1;
                    x_buf_mux           <= 1;           // 0 -> x buf, 1 -> temp buf
                    w_buf_mux           <= 3'b011;      // 0 -> w1, 1 -> w2 ...
                    
                    w_buf_4_en          <= 1;
                    w_buf_4_addr        <= count;
                    if(count == 32) begin               // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        temp_buf_en     <= 1;
                        temp_buf_wen    <= 1;
                    end
                end
            end
        STATE_5 :begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    temp_buf_en         <= 1;
                    temp_buf_addr       <= count;
                    temp_buf_wen        <= 0;
                    temp_buf_rst        <= 0;
                    
                    count               <= count + 1;

                    x_buf_mux           <= 1;           // 0 -> x buf, 1 -> temp buf
                    w_buf_mux           <= 3'b100;      // 0 -> w1, 1 -> w2 ...
                    
                    w_buf_5_en          <= 1;
                    w_buf_5_addr        <= count;
                    if(count == 16) begin               // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        temp_buf_en     <= 1;
                        temp_buf_wen    <= 1;
                    end
                end
            end
        STATE_6 : begin
                if( ~prcss_start ) begin
                    prcss_start     <= 1;
                    temp_buf_rst    <= 1;
                end
                else begin
                    temp_buf_en         <= 1;
                    temp_buf_addr       <= count;
                    temp_buf_wen        <= 0;
                    temp_buf_rst        <= 0;
                    
                    count               <= count + 1;
                    x_buf_mux           <= 1;           // 0 -> x buf, 1 -> temp buf
                    w_buf_mux           <= 3'b101;      // 0 -> w1, 1 -> w2 ...
                    if(count == 10) begin               // timing verification
                        count           <= 0;
                        prcss_start     <= 0;
                        
                        y_buf_en        <= 1;
                        y_buf_wen       <= 1;
                    end
                end
            end
        DONE : begin
            done_intr                   <= 1;
            done_led                    <= 1;
        end
    endcase
end

always@ ( * ) begin
    case(present_state)
        IDLE  :   begin if(start_i) next_state <= STATE_1;                       else next_state <= IDLE   ; end
        STATE_1 : begin if(count == 784 || prcss_done_i)  next_state <= STATE_2; else next_state <= STATE_1; end        // * prcss_done_i may not need
        STATE_2 : begin if(count == 64  || prcss_done_i)  next_state <= STATE_3; else next_state <= STATE_2; end
        STATE_3 : begin if(count == 32  || prcss_done_i)  next_state <= STATE_4; else next_state <= STATE_3; end
        STATE_4 : begin if(count == 32  || prcss_done_i)  next_state <= STATE_5; else next_state <= STATE_4; end
        STATE_5 : begin if(count == 16  || prcss_done_i)  next_state <= STATE_6; else next_state <= STATE_5; end
        STATE_6 : begin if(count == 10  || prcss_done_i)  next_state <= DONE;    else next_state <= STATE_6; end
        DONE    : begin if(start_i)                       next_state <= IDLE;    else next_state <= DONE;    end         // next state idle
    endcase
end
endmodule
