`default_nettype none
module uart_tx_fixed #(
    parameter int NUMBER_OF_BITS = 8,
    parameter int BAUD_DIVIDER = 4,
    parameter bit [7:0] CHARACTER = 8'h41   // ASCII 'A'
) (
    input wire   clock,
    input wire   reset,

    output logic tx     // UART信号出力
);

localparam int RATE_COUNTER_BITS = $clog2(BAUD_DIVIDER);        // ボーレート・カウンタのビット数
localparam int BIT_COUNTER_BITS  = $clog2(NUMBER_OF_BITS+2+1);  // ビット・カウンタのビット数

logic [RATE_COUNTER_BITS-1:0] rate_counter = 0; // ボーレート・カウンタ
logic [BIT_COUNTER_BITS-1:0] bit_counter = 0;   // ビット・カウンタ
logic [NUMBER_OF_BITS+1:0] bits;                // 送信バッファ

assign tx = bit_counter == 0 || bits[0];    // フレーム未送信：1, フレーム送信中：bits[0]

always_ff @(posedge clock) begin
    if( reset ) begin
        rate_counter <= 0;
        bit_counter <= 0;
    end
    else begin
       if( bit_counter == 0 ) begin // ビット・カウンタが0 (フレーム未送信) のとき
           bits <= {1'b1, CHARACTER, 1'b0 };    // 送信バッファに STOP(1), DATA, START(0) をセット
           bit_counter <= BIT_COUNTER_BITS'(NUMBER_OF_BITS + 2);    // ビット・カウンタを　NUMBER_OF_BITS + 2 にセット
           rate_counter <= RATE_COUNTER_BITS'(BAUD_DIVIDER - 1);    // ボーレート・カウンタを BAUD_DIVIDER - 1 にセット
       end
       if( bit_counter > 0 ) begin  // フレーム送信中のとき
           if( rate_counter == 0 ) begin    // ボーレート・カウンタが0→次の信号出力タイミング
                bits <= {1'b0, bits[NUMBER_OF_BITS+1:1]};   // 送信バッファをシフト
                bit_counter <= bit_counter - 1;             // ビット・カウンタをデクリメント
                rate_counter <= RATE_COUNTER_BITS'(BAUD_DIVIDER - 1);   // ボーレート・カウンタを BAUD_DIVIDER - 1 にセット
           end
           else begin   // ボーレート・カウンタをデクリメント
               rate_counter <= RATE_COUNTER_BITS'(rate_counter - RATE_COUNTER_BITS'(1));
           end
       end
    end
end

endmodule
`default_nettype wire