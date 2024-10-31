`default_nettype none
module uart_rx #(
    parameter int NUMBER_OF_BITS = 8,
    parameter int BAUD_DIVIDER = 4,
    parameter int RX_SYNC_STAGES = 3
) (
    input wire  clock,
    input wire  reset,

    output logic                      data_valid,   // 受信データ出力VALID
    input  wire                       data_ready,   // 受信データ出力READY
    output logic [NUMBER_OF_BITS-1:0] data_bits,    // 受信データ

    input  wire  rx,                // UART信号入力
    output logic overrun            // 受信データオーバーラン
);

localparam int RATE_COUNTER_BITS = $clog2(BAUD_DIVIDER*3/2);    // レート・カウンタは3/2までカウント
localparam int BIT_COUNTER_BITS  = $clog2(NUMBER_OF_BITS);      // ビット・カウンタのビット数

logic [RATE_COUNTER_BITS-1:0] rate_counter = 0; // レート・カウンタ
logic [BIT_COUNTER_BITS-1:0]  bit_counter = 0;  // ビット・カウンタ
logic [NUMBER_OF_BITS-1:0]    bits;             // 受信バッファ
logic [NUMBER_OF_BITS-1:0]    next_bits;        // 次の受信バッファ
logic [RX_SYNC_STAGES+1:0]    rx_regs = 0;      // RX信号レジスタ
logic running = 0;  // フレーム受信処理中なら1

assign next_bits = { rx_regs[0], bits[NUMBER_OF_BITS-1 : 1] };

always_ff @(posedge clock) begin
    if( reset ) begin
        data_valid <= 0;
        rate_counter <= 0;
        bit_counter <= 0;
        rx_regs <= 0;
        running <= 0;
        overrun <= 0;
    end
    else begin
        if( data_valid && data_ready ) begin    // 受信データ出力 トランザクション成立
            data_valid <= 0;                    // 受信データ出力VALIDをデアサート
        end
        // UART信号入力(非同期)のクロック同期化
        rx_regs <= {rx, rx_regs[RX_SYNC_STAGES+1 : 1]};

        if( !running ) begin    // フレーム受信処理中ではない場合
            if( !rx_regs[1] && rx_regs[0] ) begin   // スタート・ビットの立下りエッジを検出
                rate_counter <= RATE_COUNTER_BITS'(BAUD_DIVIDER*3/2 - 1);   // データ・ビットの先頭の真ん中まで待つ
                bit_counter <= BIT_COUNTER_BITS'(NUMBER_OF_BITS - 1);       // データ・ビット分のカウンタをセット
                running <= 1;
            end
        end
        else begin
            if( rate_counter == 0 ) begin   // 次のビットをサンプリング
                bits <= next_bits;
                if( bit_counter == 0 ) begin
                    data_valid <= 1;
                    data_bits <= next_bits;
                    overrun <= data_valid;  // まだ前回の受信データが残っているならオーバーラン
                    running <= 0;
                end
                else begin
                    rate_counter <= RATE_COUNTER_BITS'(BAUD_DIVIDER - 1);
                    bit_counter <= bit_counter - 1;
                end
            end
            else begin
                rate_counter <= rate_counter - 1;
            end
        end
    end
end

endmodule
`default_nettype wire