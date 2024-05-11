module glbl_ctrl #(
    parameter X_BUF_ADDR = 10, 
    parameter W_BUF_1_ADDR = 10, 
    parameter W_BUF_2_ADDR = 6,
    parameter W_BUF_3_ADDR = 5,
    parameter W_BUF_4_ADDR = 5,
    parameter W_BUF_5_ADDR = 4,
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
reg [X_BUF_ADDR - 1:0]      x_buf_addr;
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
    
    // mux interface
reg [2 : 0]                 w_buf_mux;          // w buf mux 1 of 5
reg                         x_buf_mux;
endmodule
