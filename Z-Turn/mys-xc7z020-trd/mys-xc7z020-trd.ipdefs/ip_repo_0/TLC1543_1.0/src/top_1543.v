`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/03 10:55:38
// Design Name: 
// Module Name: top_1543
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_1543#(
    parameter SYS_CLOCK_FREQ = 100_000_000,
    parameter SPI_CLOCK_FREQ =   1_000_000
    )(
    input clk_in,
    input reset_n,
    input start_sig,
    input EOC,
    input [3:0] channel,
    output IOCLK,
    input DOUT,
    output reg ADDR,
    output CS_n,
    output reg [9:0] data,
    output data_valid
    );
    
    localparam CNT_IOSCLK_MAX = SYS_CLOCK_FREQ / SPI_CLOCK_FREQ - 1;

    reg cs_n_buf;
    wire eoc_rising;
    wire eoc_falling;
    reg [5:0] cnt_iosclk;
    reg [3:0] cnt_spi;
    reg [3:0] counter;
    reg [2:0] state = IDLE;
    localparam IDLE           = 0;
    localparam WAIT_START     = 1;
    localparam GET_ADDR       = 2;
    localparam DATACONV       = 3;
    localparam GET_DATA       = 4;
    localparam WAIT_EOC       = 5;
    localparam WAIT_BUFFER    = 6;
    
    //FSM state
    always@(posedge clk_in)
    begin
        if(~reset_n)
        begin
            counter <= 0;
            state <= IDLE;
        end
        case(state)
            IDLE:  
                begin
                    if(eoc_rising & start_sig)
                        state <= GET_ADDR;
                    else if(eoc_rising|EOC)
                        state <= WAIT_START;
                    else if(start_sig)
                        state <= WAIT_EOC;
                    else
                        state <= IDLE;
                end
            WAIT_EOC:
                begin
                    if(eoc_rising)
                        state <= GET_ADDR;
                    else
                        state <= WAIT_EOC;
                end
            WAIT_START:
                begin
                    if(start_sig & eoc_falling)
                        state <= WAIT_EOC;
                    else if(start_sig)
                        state <= GET_ADDR;
                    else if(eoc_falling)
                        state <= IDLE;
                    else
                        state <= WAIT_START;
                end
            GET_ADDR:
                begin
                    if(eoc_falling)
                        state <= DATACONV;
                    else
                        state <= GET_ADDR;
                end
            DATACONV:
                begin
                    if(eoc_rising)
                        state <= GET_DATA;
                    else
                        state <= DATACONV;
                end
            GET_DATA:
                begin
                    if(eoc_falling)
                        state <= WAIT_BUFFER;
                    else
                        state <= GET_DATA;
                end
             WAIT_BUFFER:
                begin
                    if(counter == 15)
                        state <= IDLE;
                    else
                        state <= WAIT_BUFFER;
                    counter <= counter + 1;
                end
           default:     state <= IDLE;
       endcase
    end
    
    //FSM output
    assign CS_n = cs_n_buf;
    always@(posedge clk_in, negedge reset_n)
    begin
        if(~reset_n)
            cs_n_buf <= 1'b1;
        else if(state == GET_ADDR || state == GET_DATA || state == WAIT_BUFFER)
            cs_n_buf <= 1'b0;
        else
            cs_n_buf <= 1'b1;
    end
    
    edgedetect e2(
        .clk_in(clk_in),
        .inpsig(EOC),
        .sig_falling(eoc_falling),
        .sig_rising(eoc_rising));
                
    always@(posedge clk_in, negedge reset_n)
    begin
        if(~reset_n)
            cnt_iosclk <= 1'b0;
        else if(state == GET_ADDR || state == GET_DATA)
            cnt_iosclk <= cnt_iosclk + 1'b1;
        else if(cs_n_buf)
           cnt_iosclk <= 1'b0;
    end
    
    assign IOCLK = (cnt_spi > 0)?cnt_iosclk[5]:1'b0;
    
    edgedetect e1(
        .clk_in(clk_in),
        .inpsig(cnt_iosclk[5]),
        .sig_falling(iosclk_falling),
        .sig_rising(iosclk_rising));
        
    always@(posedge clk_in, negedge reset_n)
        begin
            if(~reset_n)
                cnt_spi <= 1'b0;
            else if((state == GET_ADDR || state == GET_DATA) && iosclk_falling)
                cnt_spi <= cnt_spi + 1'b1;
            else if(state == GET_ADDR || state == GET_DATA)
                cnt_spi <= cnt_spi;
            else
                cnt_spi <= 1'b0;
        end
       
   localparam addr_shift = 4;
 
    reg [addr_shift-1:0] addr = {addr_shift-1{1'b0}};
    reg addr_buf;
    always @(posedge clk_in)
       if (state == IDLE) begin
          addr <= channel[addr_shift-1:0];
          //addr_buf <= channel[addr_shift-1];
       end
       else if(iosclk_falling && state == GET_ADDR)
       begin
          addr <= {addr[addr_shift-2:0], 1'b0};
          addr_buf  <= addr[addr_shift-1];
       end
       
    always@(posedge clk_in, negedge reset_n)
        if(~reset_n)
            ADDR <= 1'b0;
        else
            ADDR <= addr_buf;
             
    localparam data_shift = 10;
    
    //reg [data_shift-1:0]data = {data_shift{1'b0}};
    
    always @(posedge clk_in, negedge reset_n)
        if(~reset_n)
            data <= 1'b0;
        else if(iosclk_rising && state == GET_DATA)
            data  <= {data[data_shift-2:0], DOUT};

     assign data_valid = state == WAIT_BUFFER?1'b1:1'b0;     
                                          
endmodule
