// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2024.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)
/**
 * @file   tb.sv
 * @brief Test bench for counter
 */

`timescale 1ns/1ps

module tb #(
    parameter int NUMBER_OF_TESTS = 1000,
    parameter bit DUT_IS_FIFO = 1,
    parameter int DEPTH_BITS = 4,
    parameter int VALID_RATE = 8,
    parameter int READY_RATE = 8
)();
    logic         clock = 0;     // クロック /*verilator clocker*/
    logic         reset = 1;     // リセット (正論理)
    logic         input_valid;   // FIFO入力VALID
    logic         input_ready;   // FIFO入力READY
    logic [7:0]   input_data;    // FIFO入力データ
    logic         output_valid;  // FIFO出力VALID
    logic         output_ready;  // FIFO出力READY
    logic [7:0]   output_data;   // FIFO出力データ
    
    // テスト対象のインスタンス化
generate 
    if( DUT_IS_FIFO ) begin : dut_block_fifo
        simple_fifo #(
            .DEPTH_BITS(DEPTH_BITS)
        ) dut (
            .*
        );
    end
    else begin : dut_block_slice
        register_slice dut (
            .*
        );
    end
endgenerate

    localparam int TIMEOUT_CYCLES = NUMBER_OF_TESTS * 10;

    int test_count = 0;
    int timeout_counter = 0;
    logic [7:0]  input_data_next = 0;   // 次の入力データ
    logic [7:0]  data_expected = 0;     // 入力データの期待値

    // 入力データとVALID生成
    always @(negedge clock) begin
        if( reset ) begin
            input_valid <= 1'b0;
            input_data_next <= 8'd0;
            input_data <= 8'd0;
        end
        else begin
            if( input_valid && input_ready ) begin
                input_valid <= 0;
            end
            if( $urandom_range(0, 10) < VALID_RATE && (!input_valid || input_ready) ) begin
                input_valid <= 1;
                input_data <= input_data_next;
                input_data_next <= input_data_next + 8'd1;
            end
        end
    end
    // 出力のREADY生成
    always @(negedge clock) begin
        if( reset ) begin
            output_ready <= 1'b0;
        end
        else begin
            output_ready <= $urandom_range(0, 10) < READY_RATE;
        end
    end

    always @(posedge clock) begin   // 出力データチェック
        if( reset ) begin
            data_expected <= 8'd0;
        end
        else begin
            if( output_valid && output_ready ) begin
                if( output_data != data_expected ) $error("mismatch: expected %04h != actual %04h", data_expected, output_data);
                data_expected <= data_expected + 8'd1;  // 次の期待値
                test_count <= test_count + 1;           // テスト回数のカウント
            end
        end
    end

    always @(posedge clock) begin   // タイムアウト カウンター
        timeout_counter <= timeout_counter + 1;
    end
    always #(5) begin // クロック生成 (5[ns]*2 = 10[ns] 周期)
        clock = ~clock;
    end
    
    initial begin
        $dumpfile("trace.fst"); // トレースファイルの作成
        $dumpvars(0, dut);      // トレースへDUTの変数追加
        
        // リセット - 2サイクル後に解除
        reset = 1;
        repeat(2) @(negedge clock);
        reset = 0;
        @(posedge clock);

        // テストデータのチェック完了もしくはタイムアウトまで待つ
        while( test_count < NUMBER_OF_TESTS && timeout_counter < TIMEOUT_CYCLES ) @(posedge clock);
        if( timeout_counter >= TIMEOUT_CYCLES ) $error("timeout");
        $finish;
    end
endmodule

module tb_default();
    tb #() tb_inst();
endmodule

module tb_low_valid();
    tb #(.VALID_RATE(4)) tb_inst();
endmodule
module tb_low_ready();
    tb #(.READY_RATE(4)) tb_inst();
endmodule

module tb_default_1();
    tb #(.DEPTH_BITS(1)) tb_inst();
endmodule

module tb_low_valid_1();
    tb #(.DEPTH_BITS(1), .VALID_RATE(4)) tb_inst();
endmodule
module tb_low_ready_1();
    tb #(.DEPTH_BITS(1), .READY_RATE(4)) tb_inst();
endmodule

module tb_default_slice();
    tb #(.DUT_IS_FIFO(0)) tb_inst();
endmodule

module tb_low_valid_slice();
    tb #(.VALID_RATE(4), .DUT_IS_FIFO(0)) tb_inst();
endmodule
module tb_low_ready_slice();
    tb #(.READY_RATE(4), .DUT_IS_FIFO(0)) tb_inst();
endmodule