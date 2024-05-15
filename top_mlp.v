`timescale 1ns / 1ps

module top_mlp #(
    parameter IN_IMG_NUM = 1,
	parameter FP_BW = 32,
	parameter INT_BW = 8,
    // parameter X_BUF_DATA_WIDTH = INT_BW*IN_IMG_NUM,  	// add in 2024-04-17 / if you try INT8 Streamline , you should change X_BUF_DATA_WIDTH to this line
	parameter X_BUF_DATA_WIDTH = FP_BW*IN_IMG_NUM,
	parameter X_BUF_DEPTH = 784*IN_IMG_NUM,
    // parameter W_BUF_DATA_WIDTH = INT_BW *IN_IMG_NUM,		// add in 2024-04-17 / if you try INT8 Streamline , you should change W_BUF_DATA_WIDTH to this line
	parameter W_BUF_DATA_WIDTH = FP_BW *IN_IMG_NUM, 	    //modify in 2024-05-15
	parameter W_BUF_1_DEPTH = 784*IN_IMG_NUM,
	parameter W_BUF_1_COL = 64*IN_IMG_NUM,
	parameter W_BUF_2_DEPTH = 64*IN_IMG_NUM,
	parameter W_BUF_2_COL = 32*IN_IMG_NUM,
	parameter W_BUF_3_DEPTH = 32*IN_IMG_NUM,
	parameter W_BUF_3_COL = 32*IN_IMG_NUM,
	parameter W_BUF_4_DEPTH = 32*IN_IMG_NUM,
	parameter W_BUF_4_COL = 16*IN_IMG_NUM,
	parameter W_BUF_5_DEPTH = 16*IN_IMG_NUM,
	parameter W_BUF_5_COL = 10*IN_IMG_NUM,
	// paramter TEMP_BUF									//add in 2024-05-15
	parameter TEMP_BUF_DATA_WIDTH = FP_BW*IN_IMG_NUM,
	parameter TEMP_BUF_DEPTH = 64*IN_IMG_NUM,
	// parameter Y_BUF
    	parameter Y_BUF_DATA_WIDTH = 32,
	parameter Y_BUF_ADDR_WIDTH = 32,  							// add in 2023-05-10
    	parameter Y_BUF_DEPTH = 10*IN_IMG_NUM * 4 					// modify in 2024-04-17, y_buf_addr has to increase +4 -> 0 - 396
)(
    // system interface
    input   wire                            clk,
    input   wire                            rst_n,
    input   wire                            start_i,
    output  wire                            done_intr_o,
    output  wire                            done_led_o,
    // output buffer interface
    output  wire                            y_buf_en,
    output  wire                            y_buf_wr_en,
    output  wire [$clog2(Y_BUF_DEPTH)-1:0]  y_buf_addr,			// modify in 2023-05-10, [$clog2(Y_BUF_DEPTH)-1:0] -> [Y_BUF_ADDR_WIDTH-1:0]
    output  wire [Y_BUF_DATA_WIDTH-1:0]     y_buf_data
);

    	localparam X_BUF_INIT_FILE =  "D:/idsl_hw/DSD/x.txt";
    	localparam W_BUF_1_INIT_FILE =  "D:/idsl_hw/DSD/w1.txt"; 	//modify in 2024-05-15
	localparam W_BUF_2_INIT_FILE =  "D:/idsl_hw/DSD/w2.txt";
	localparam W_BUF_3_INIT_FILE =  "D:/idsl_hw/DSD/w3.txt";
	localparam W_BUF_4_INIT_FILE =  "D:/idsl_hw/DSD/w4.txt";
	localparam W_BUF_5_INIT_FILE =  "D:/idsl_hw/DSD/w5.txt";
    
   	wire x_buf_en;
   	wire [$clog2(X_BUF_DEPTH)-1:0] x_buf_addr;
	wire [X_BUF_DATA_WIDTH - 1:0] x_buf_data;
   	wire w_buf_1_en;                             				//add in 2024-05-15
	wire [$clog2(W_BUF_1_DEPTH)-1:0] w_buf_1_addr;
	wire [W_BUF_DATA_WIDTH * W_BUF_1_COL - 1:0] w_buf_1_data;
    	wire w_buf_2_en;
	wire [$clog2(W_BUF_2_DEPTH)-1:0] w_buf_2_addr;
	wire [W_BUF_DATA_WIDTH * W_BUF_2_COL - 1:0] w_buf_2_data;
	wire w_buf_3_en;
	wire [$clog2(W_BUF_3_DEPTH)-1:0] w_buf_3_addr;
	wire [W_BUF_DATA_WIDTH * W_BUF_3_COL - 1:0] w_buf_3_data;
	wire w_buf_4_en;
	wire [$clog2(W_BUF_4_DEPTH)-1:0] w_buf_4_addr;
	wire [W_BUF_DATA_WIDTH * W_BUF_4_COL - 1:0] w_buf_4_data;
	wire w_buf_5_en;
	wire [$clog2(W_BUF_5_DEPTH)-1:0] w_buf_5_addr;
	wire [W_BUF_DATA_WIDTH * W_BUF_5_COL - 1:0] w_buf_5_data;
	wire temp_buf_rst;
	wire temp_buf_en;
	wire temp_buf_wen;
	wire [$clog2(TEMP_BUF_DEPTH)-1:0] temp_buf_addr;
	wire [TEMP_BUF_DATA_WIDTH - 1:0] temp_buf_data;
	wire [TEMP_BUF_DATA_WIDTH * TEMP_BUF_DEPTH - 1:0] temp_buf_input
	
    	wire prcss_start;
    	wire prcss_done;
    
    glbl_ctrl #(
        .BUF_ADDR_WIDTH(32)
    ) glbl_ctrl_inst(
        // system interface
        .clk(clk),
        .rst_n(rst_n),
        .start_i(start_i),
        .done_intr_o(done_intr_o),
        .done_led_o(done_led_o),
        // x_buffer interface
        .x_buf_en(x_buf_en),
        .x_buf_addr(x_buf_addr),
        // w_buffer interface
	.w_buf_1_en_o(w_buf_1_en),									//modify in 2024-05-15
	.w_buf_1_addr_o(w_buf_1_addr),
	.w_buf_2_en_o(w_buf_2_en),
	.w_buf_2_addr_o(w_buf_2_addr),
	.w_buf_3_en_o(w_buf_3_en),
	.w_buf_3_addr_o(w_buf_3_addr),
	.w_buf_4_en_o(w_buf_4_en),
	.w_buf_4_addr_o(w_buf_4_addr),
	.w_buf_5_en_o(w_buf_5_en),
	.w_buf_5_addr_o(w_buf_5_addr),
	//temp_buf interface
	.temp_buf_rst_o(temp_buf_rst),
	.temp_buf_en_o(temp_buf_en),
	.temp_buf_wen_o(temp_buf_wen),
	.temp_buf_addr_o(temp_buf_addr),
        // processing unit interface
        .prcss_start(prcss_start),
        .prcss_done(prcss_done)
    );
	
	
    pu #(
        .IN_X_BUF_DATA_WIDTH(X_BUF_DATA_WIDTH),
        .IN_W_BUF_DATA_WIDTH(W_BUF_DATA_WIDTH),
        .OUT_BUF_ADDR_WIDTH($clog2(Y_BUF_DEPTH)),
        .OUT_BUF_DATA_WIDTH(Y_BUF_DATA_WIDTH)
    ) pu_inst(
        // system interface
        .clk(clk),
        .rst_n(rst_n),
        // global controller interface
        .prcss_start(prcss_start),
        .prcss_done(prcss_done),
        // input data buffer interface
        .x_buf_data(x_buf_data),
        .w_buf_data(w_buf_data),
        // output data buffer interface
        .y_buf_en(y_buf_en),
        .y_buf_wr_en(y_buf_wr_en),
        .y_buf_addr(y_buf_addr),
        .y_buf_data(y_buf_data)
    );

	single_port_bram  #(           //modify in 2024-05-15
        .WIDTH(X_BUF_DATA_WIDTH),
        .DEPTH(X_BUF_DEPTH),
        .INIT_FILE(X_BUF_INIT_FILE)
    ) x_buffer_inst (
		.clk(clk), .x_buf_en_i(x_buf_en),
		.wen(), .x_buf_addr_i(x_buf_addr),
		.din(), .x_buf_data_o(x_buf_data)
    		);
    
	w_buf  #(                      // modify in 2024-05-15
        	.WIDTH(W_BUF_DATA_WIDTH),
		.DEPTH(W_BUF_1_DEPTH),
		.COL(W_BUF_1_COL)
		.INIT_FILE(W_BUF_1_INIT_FILE)
    ) w_buffer_inst1 (
		.clk(clk), .w_buf_en_i(w_buf_1_en),
		.wen(), .w_buf_addr_i(w_buf_1_addr),
		.din(), .w_buf_data_o(w_buf_1_data)
		);
	
	w_buf  #(                      // add in 2024-05-15
        .WIDTH(W_BUF_DATA_WIDTH),
		.DEPTH(W_BUF_2_DEPTH),
		.COL(W_BUF_2_COL)
		.INIT_FILE(W_BUF_2_INIT_FILE)
	) w_buffer_inst2 (
		.clk(clk), .w_buf_en_i(w_buf_2_en),
		.wen(), .w_buf_addr_i(w_buf_2_addr),
		.din(), .w_buf_data_o(w_buf_2_data)
    );
	
	w_buf  #(                      // add in 2024-05-15
        .WIDTH(W_BUF_DATA_WIDTH),
		.DEPTH(W_BUF_3_DEPTH),
		.COL(W_BUF_3_COL)
		.INIT_FILE(W_BUF_3_INIT_FILE)
	) w_buffer_inst3 (
		.clk(clk), .w_buf_en_i(w_buf_3_en),
		.wen(), .w_buf_addr_i(w_buf_3_addr),
		.din(), .w_buf_data_o(w_buf_3_data)
    );

	w_buf  #(                      // add in 2024-05-15
        .WIDTH(W_BUF_DATA_WIDTH),
		.DEPTH(W_BUF_4_DEPTH),
		.COL(W_BUF_4_COL)
		.INIT_FILE(W_BUF_4_INIT_FILE)
	) w_buffer_inst4 (
		.clk(clk), .w_buf_en_i(w_buf_4_en),
		.wen(), .w_buf_addr_i(w_buf_4_addr),
		.din(), .w_buf_data_o(w_buf_4_data)
    );
	
	w_buf  #(                      // add in 2024-05-15
        .WIDTH(W_BUF_DATA_WIDTH),
        .DEPTH(W_BUF_DEPTH),
		.COL(W_BUF_5_COL)
		.INIT_FILE(W_BUF_5_INIT_FILE)
	) w_buffer_inst5 (
		.clk(clk), .w_buf_en_i(w_buf_5_en),
		.wen(), .w_buf_addr_i(w_buf_5_addr),
		.din(), S.w_buf_data_o(w_buf_5_data)
    );
	
	temp_buf  #(                      // add in 2024-05-15
		.WIDTH(TEMP_BUF_DATA_WIDTH),
		.DEPTH(TEMP_BUF_DEPTH),
		//.INIT_FILE(W_BUF_5_INIT_FILE)
	) temp_buffer_inst (
        .clk(clk),
		.temp_buf_rst_i(temp_buf_rst)
		.temp_buf_en_i(temp_buf_en),
		.temp_buf_wen_i(temp_buf_en),
		.temp_buf_addr_i(temp_buf_addr),
		.temp_buf_in_i(temp_buf_input),
		.temp_buf_data_o(temp_buf_data)
    );



    
    
    
    
endmodule
