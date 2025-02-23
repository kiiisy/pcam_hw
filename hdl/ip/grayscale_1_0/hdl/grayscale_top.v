module grayscale_top #(
    parameter integer C_S_AXIS_DATA_WIDTH = 32
) (
    input  wire        CLK,
    input  wire        RESET,
    // S AXI-Stream interface
    output wire        S_AXIS_VIDEO_TREADY,
    input  wire [C_S_AXIS_DATA_WIDTH-1:0] S_AXIS_VIDEO_TDATA,
    input  wire        S_AXIS_VIDEO_TVALID,
    input  wire        S_AXIS_VIDEO_TUSER,
    input  wire        S_AXIS_VIDEO_TLAST,

    // M AXI-Stream interface
    input  wire        M_AXIS_VIDEO_TREADY,
    output wire [C_S_AXIS_DATA_WIDTH-1:0] M_AXIS_VIDEO_TDATA,
    output wire        M_AXIS_VIDEO_TVALID,
    output wire        M_AXIS_VIDEO_TUSER,
    output wire        M_AXIS_VIDEO_TLAST,

    // Grayscale
    input wire         GRAYSCALE_EN,
    input wire         GRAYSCALE_PTN
);

    wire [ 9: 0] w_red;
    wire [ 9: 0] w_green;
    wire [ 9: 0] w_blue;
    reg  [ 9: 0] r_max;
    reg          r_axis_video_tready;
    reg          r_axis_video_tvalid;
    reg          r_axis_video_tuser;
    reg          r_axis_video_tlast;

    assign w_red   = S_AXIS_VIDEO_TDATA[ 9: 0];
    assign w_green = S_AXIS_VIDEO_TDATA[19:10];
    assign w_blue  = S_AXIS_VIDEO_TDATA[29:20];

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            r_max <= 10'd0;
        end else begin
            if (S_AXIS_VIDEO_TVALID) begin
                r_max <= (w_red > w_green && w_red > w_blue) ? w_red : (w_green > w_red && w_green > w_blue) ? w_green : w_blue;
            end else begin
                r_max <= 10'd0;
            end
        end
    end

    always @(posedge CLK or posedge RESET) begin
        if (RESET) begin
            r_axis_video_tready <= 1'b0;
            r_axis_video_tvalid <= 1'b0;
            r_axis_video_tuser  <= 1'b0;
            r_axis_video_tlast  <= 1'b0;
        end else begin
            r_axis_video_tready <= M_AXIS_VIDEO_TREADY;
            r_axis_video_tvalid <= S_AXIS_VIDEO_TVALID;
            r_axis_video_tuser  <= S_AXIS_VIDEO_TUSER;
            r_axis_video_tlast  <= S_AXIS_VIDEO_TLAST;
        end
    end

    assign S_AXIS_VIDEO_TREADY = (GRAYSCALE_EN) ? r_axis_video_tready : M_AXIS_VIDEO_TREADY;
    assign M_AXIS_VIDEO_TDATA  = (GRAYSCALE_EN) ? {2'b00, r_max[9:0], r_max[9:0], r_max[9:0]} : S_AXIS_VIDEO_TDATA;
    assign M_AXIS_VIDEO_TVALID = (GRAYSCALE_EN) ? r_axis_video_tvalid : S_AXIS_VIDEO_TVALID;
    assign M_AXIS_VIDEO_TUSER  = (GRAYSCALE_EN) ? r_axis_video_tuser : S_AXIS_VIDEO_TUSER;
    assign M_AXIS_VIDEO_TLAST  = (GRAYSCALE_EN) ? r_axis_video_tlast : S_AXIS_VIDEO_TLAST;

endmodule