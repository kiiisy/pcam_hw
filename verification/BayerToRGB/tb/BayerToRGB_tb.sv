`timescale 1ns / 1ps

//import BayerToRGB_Test_axi_vip_0_0_pkg::*;
// axi4-stream vip
import BayerToRGB_Test_axi4stream_vip_0_0_pkg::*;
import BayerToRGB_Test_axi4stream_vip_1_0_pkg::*;
import axi4stream_vip_pkg::*;


module BayerToRGB_tb ();

    localparam AXIS_CLK_PERIOD = 3;
    localparam RST_PERIOD = 15;

    BayerToRGB_Test_axi4stream_vip_0_0_mst_t axis_master_agent;
    BayerToRGB_Test_axi4stream_vip_1_0_slv_t axis_slave_agent;
    axi4stream_ready_gen axis_ready;

    // Axi4 Stream
    logic aclk = 0;
    logic aresetn = 0;

    // dut
    BayerToRGB_Test_wrapper dut(
        .aclk            (aclk),
        .aresetn         (aresetn)
    );

    // リセット処理
    initial begin
        #(RST_PERIOD);
        aresetn = 1;
    end

    always #(AXIS_CLK_PERIOD) aclk = ~aclk;

    task wait_clk(int n);
        repeat(n) @(posedge aclk);
    endtask

    task init_agent();
        // axi4-stream agent
        axis_master_agent = new("AXIS master agent", dut.BayerToRGB_Test_i.axi4stream_vip_0.inst.IF);
        axis_slave_agent = new("AXIS slave agent", dut.BayerToRGB_Test_i.axi4stream_vip_1.inst.IF);
        axis_master_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        axis_slave_agent.vif_proxy.set_dummy_drive_type(XIL_AXI4STREAM_VIF_DRIVE_NONE);
        axis_master_agent.start_master();
        axis_slave_agent.start_slave();

        // ready signal
        ready_gen();
    endtask

    task ready_gen();
        axis_ready = axis_slave_agent.driver.create_ready("ready_gen");
        axis_ready.set_ready_policy(XIL_AXI4STREAM_READY_GEN_OSC);
        axis_ready.set_low_time(0);
        axis_ready.set_high_time(0);
        axis_slave_agent.driver.send_tready(axis_ready);
    endtask

    task wr_tansaction(input logic line, input logic user, input logic last);
        axi4stream_transaction wr_trans;
        logic [9:0] red;
        logic [9:0] green;
        logic [9:0] blue;

        wr_trans = axis_master_agent.driver.create_transaction("write transaction");

        red = 1;
        green = 0;
        blue = 0;

        if (line % 2 == 0) begin
            // 偶数ラインはBGBG
            wr_trans.set_data_beat({blue, green, blue, green});
        end else begin
            // 奇数ラインはGRGR
            wr_trans.set_data_beat({green, red, green, red});
        end
        wr_trans.set_user_beat(user);
        wr_trans.set_last(last);
        wr_trans.set_delay(0);
        axis_master_agent.driver.send(wr_trans);
    endtask

    // シナリオ
    initial begin
        init_agent();

        // テストパターン
        for (int y=0; y < 4; y++) begin
            for (int x=0; x < 2048; x++) begin
                if (y == 0 && x == 0) begin
                    wr_tansaction(y, 1, 0);
                end else if (x == (2048-1)) begin
                    wr_tansaction(y, 0, 1);
                end else begin
                    wr_tansaction(y, 0, 0);
                end
            end
        end
        $finish();
    end
endmodule
