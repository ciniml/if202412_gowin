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
    parameter int NUMBER_OF_TESTS = 1000
)();
    logic         clock = 0;     // クロック /*verilator clocker*/
    logic         reset = 1;     // リセット (正論理)
    logic         input_valid;   // accumulator入力VALID
    logic         input_ready;   // accumulator入力READY
    logic [7:0]   input_data;    // accumulator入力データ
    logic         output_valid;  // accumulator出力VALID
    logic         output_ready;  // accumulator出力READY
    logic [15:0]  output_data;   // accumulator出力データ
    
    // テスト対象のインスタンス化
    counter_8bit dut_source (
        .valid(input_valid),
        .ready(input_ready),
        .data (input_data),
        .*
    );
    accumulator dut_sink (
        .*
    );

    localparam int TIMEOUT_CYCLES = NUMBER_OF_TESTS * 10;

    int test_count = 0;
    int timeout_counter = 0;
    logic [7:0]  data_expected = 0;     // 入力データの期待値
    logic [15:0] last_accumulated = 0;  // 最後の積算値出力


    always @(negedge clock) begin
        if( reset ) begin
            output_ready <= 1'b0;
        end
        else begin
            output_ready <= $urandom_range(0, 10) < 8;
        end
    end

    always @(posedge clock) begin   // 出力データチェック
        if( reset ) begin
            data_expected <= 8'd0;
            last_accumulated <= 16'd0;
        end
        else begin
            if( output_valid && output_ready ) begin
                automatic bit [15:0] accumulated_expected = last_accumulated + 16'(data_expected);  // 期待値の計算
                if( output_data != accumulated_expected ) $error("mismatch: expected %04h != actual %04h", accumulated_expected, output_data);
                data_expected <= data_expected + 8'd1;  // カウンタから積算モジュールに入力される次の値
                test_count <= test_count + 1;           // テスト回数のカウント
                last_accumulated <= accumulated_expected;
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