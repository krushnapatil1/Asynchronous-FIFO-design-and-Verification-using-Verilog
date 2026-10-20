
module async_fifo (
    input wr_clk, rd_clk, rst,
    input wr_en, rd_en,
    input [7:0] din,
    output reg [7:0] dout,
    output reg full, empty
);

    reg [7:0] mem [0:7];

    reg [3:0] wr_ptr, rd_ptr;
    reg [3:0] wr_gray, rd_gray;

    reg [3:0] rd_sync1, rd_sync2;
    reg [3:0] wr_sync1, wr_sync2;

    // Write pointer synchronization
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            rd_sync1 <= 0;
            rd_sync2 <= 0;
        end
        else begin
            rd_sync1 <= rd_gray;
            rd_sync2 <= rd_sync1;
        end
    end

    // Read pointer synchronization
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            wr_sync1 <= 0;
            wr_sync2 <= 0;
        end
        else begin
            wr_sync1 <= wr_gray;
            wr_sync2 <= wr_sync1;
        end
    end

    // Write operation
    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr  <= 0;
            wr_gray <= 0;
            full    <= 0;
        end
        else if (wr_en && !full) begin
            mem[wr_ptr[2:0]] <= din;
            wr_ptr <= wr_ptr + 1;
            wr_gray <= ((wr_ptr + 1) >> 1) ^ (wr_ptr + 1);
        end
    end

    // Read operation
    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr  <= 0;
            rd_gray <= 0;
            dout    <= 0;
            empty   <= 1;
        end
        else if (rd_en && !empty) begin
            dout <= mem[rd_ptr[2:0]];
            rd_ptr <= rd_ptr + 1;
            rd_gray <= ((rd_ptr + 1) >> 1) ^ (rd_ptr + 1);
        end
    end

    // Status flags
    always @(*) begin
        empty = (rd_gray == wr_sync2);
        full = (wr_gray == {~rd_sync2[3:2], rd_sync2[1:0]});
    end

endmodule
