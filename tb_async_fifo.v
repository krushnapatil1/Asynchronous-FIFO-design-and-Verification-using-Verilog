
`timescale 1ns/1ps

module tb_async_fifo;

    reg wr_clk = 0, rd_clk = 0;
    reg rst, wr_en, rd_en;
    reg [7:0] din;
    wire [7:0] dout;
    wire full, empty;

    async_fifo dut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    always #5 wr_clk = ~wr_clk;
    always #7 rd_clk = ~rd_clk;

    initial begin
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        #20 rst = 0;

        // Write data
        repeat (4) begin
            @(negedge wr_clk);
            wr_en = 1;
            din = din + 8'h11;
        end

        @(negedge wr_clk);
        wr_en = 0;

        // Read data
        repeat (3) @(negedge rd_clk);

        repeat (4) begin
            @(negedge rd_clk);
            rd_en = 1;
            @(posedge rd_clk);
            #1 $display("Read data = %h", dout);
        end

        @(negedge rd_clk);
        rd_en = 0;

        #30 $finish;
    end

    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, tb_async_fifo);
    end

endmodule
