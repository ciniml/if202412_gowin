// SPDX-License-Identifier: BSL-1.0
// Copyright Kenta Ida 2024.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          https://www.boost.org/LICENSE_1_0.txt)
/**
 * @file   tb.sv
 * @brief Test bench for packet_sum
 */

`timescale 1ns/1ps

module tb #(
    parameter int NUMBER_OF_TESTS = 100
)();
    logic         clock = 0;     // クロック /*verilator clocker*/
    logic         reset = 1;     // リセット (正論理)
    logic         input_valid;   // accumulator入力VALID
    logic         input_ready;   // accumulator入力READY
    logic [7:0]   input_data;    // accumulator入力データ
    logic         input_last;    // accumulator入力LAST
    logic         output_valid;  // accumulator出力VALID
    logic         output_ready;  // accumulator出力READY
    logic [15:0]  output_data;   // accumulator出力データ
    
    // テスト対象のインスタンス化
    packet_sum dut_sink (
        .*
    );

    localparam int TIMEOUT_CYCLES = NUMBER_OF_TESTS * 20;

    int test_count = 0;
    int timeout_counter = 0;
    
    bit [7:0] input_data_next = 0;
    bit [7:0] output_packet_sum_start = 0;
    int input_packet_count = 0;
    int input_packet_index = 0;
    int output_packet_index = 0;
    int packet_every[0:NUMBER_OF_TESTS-1];

    // パケットの初期カウント値とパケットの長さから、パケットの合計値を計算する
    function automatic bit [15:0] calculate_packet_sum(input bit [7:0] start, input int count);
    begin
        automatic bit [15:0] sum;
        automatic bit [7:0]  data;
        data = start;
        sum = 0;
        for( int i = 0; i < count; i++ ) begin
            sum += 16'(data);
            data += 8'd1;
        end
        return sum;
    end
    endfunction

    logic input_ready_reg;
    always @(posedge clock) begin
        input_ready_reg <= input_ready; // READYをクロックの立ち上がりでサンプリング
    end

    always @(negedge clock) begin
        if( reset ) begin
            input_valid <= 0;
            input_data  <= 0;
            input_data_next <= 0;
            input_last <= 0;
            input_packet_count <= 0;
            input_packet_index <= 0;
        end
        else begin
            if( input_valid && input_ready_reg ) begin
                input_valid <= 0;
            end
            if( input_packet_index < NUMBER_OF_TESTS ) begin
                if( !input_valid || input_ready_reg ) begin
                    input_valid <= 1;
                    input_data <= input_data_next;
                    input_data_next <= input_data_next + 8'd1;
                    input_last <= 0;
                    input_packet_count <= input_packet_count + 1;
                    if( input_packet_count == packet_every[input_packet_index] - 1 ) begin
                        input_last <= 1;
                        input_packet_count <= 0;
                        input_packet_index <= input_packet_index + 1;
                    end
                end
            end
        end
    end

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
            output_packet_sum_start <= 0;
            output_packet_index <= 0;
        end
        else begin
            if( output_valid && output_ready ) begin
                automatic bit [15:0] accumulated_expected = calculate_packet_sum(output_packet_sum_start, packet_every[output_packet_index]);  // 期待値の計算
                $info("output_packet_sum_start=%02h, packet_every[%0d]=%0d, accumulated_expected=%04h, output_data=%02h", output_packet_sum_start, output_packet_index, packet_every[output_packet_index], accumulated_expected, output_data);
                if( output_data != accumulated_expected ) $error("mismatch: expected %04h != actual %04h", accumulated_expected, output_data);
                output_packet_sum_start <= 8'(int'(output_packet_sum_start) + packet_every[output_packet_index]);
                output_packet_index <= output_packet_index + 1; 
                test_count <= test_count + 1;           // テスト回数のカウント
                output_packet_index <= output_packet_index + 1;
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
        
        // パケットサイズの生成
        for( int i = 0; i < NUMBER_OF_TESTS; i++ ) begin
            packet_every[i] = $urandom_range(1, 10);
        end

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