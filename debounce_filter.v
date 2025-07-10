module debounce_filter (
    input   wire        clk,
    input   wire        rst_n,
    input   wire [3:0]  i_debounce,
    input   wire [2:0]  DEBOUNCEFILTx,
    input   wire        INx,
    output  wire        INDEBOUNCEx
);

    // Internal signals
    wire        selected_db_clk;      // Renamed for consistency
    wire        SYNCINx;
    reg  [2:0]  counter;              // Changed to reg since used in always block
    wire        counter_max;
    wire        counter_min;
    wire        or_out;
    wire        and_out;
    wire        flop_out;
    wire        s_stop;
    reg         s_indebounce;
    wire        unused_output;        // For the unused 4th input case

    //-----------------------------------
    // Input selection using tiboxv_log_mx4
    //-----------------------------------
    tiboxv_log_mx4 input_mux (        // Changed to MX4 for 4 inputs
        .a(i_debounce[0]),
        .b(i_debounce[1]),
        .c(i_debounce[2]),
        .d(i_debounce[3]),            // Added fourth input
        .s(DEBOUNCEFILTx[2:1]),
        .y(selected_db_clk)
    );

    //-----------------------------------
    // Synchronizer
    //-----------------------------------
    tiboxv_sync_2s_acn I_dbf_sync(
        .clr_n(rst_n),
        .d(INx),
        .clk(selected_db_clk),
        .q(SYNCINx)
    );

    //-----------------------------------
    // Counter control logic
    //-----------------------------------
    assign counter_max = (counter == 3'b111);
    assign counter_min = (counter == 3'b000);
    assign s_stop = counter_max | counter_min;

    //-----------------------------------
    // Counter behavior
    //-----------------------------------
    always @(posedge selected_db_clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b000;
        end
        else begin
            if (!s_stop && SYNCINx) begin
                counter <= counter + 1'b1;
            end
            else if (!s_stop && !SYNCINx) begin
                counter <= counter - 1'b1;
            end
        end
    end

    //-----------------------------------
    // Output flop control
    //-----------------------------------
    always @(posedge selected_db_clk or negedge rst_n) begin
        if (!rst_n) begin
            s_indebounce <= 1'b0;
        end
        else begin
            if (counter_max) begin
                s_indebounce <= 1'b1;
            end
            else if (counter_min) begin
                s_indebounce <= 1'b0;
            end
        end
    end

    //-----------------------------------
    // Final output mux
    //-----------------------------------
    tiboxv_log_mx2 output_mux (
        .a(s_indebounce),
        .b(INx),
        .s(DEBOUNCEFILTx[0]),
        .y(INDEBOUNCEx)              // Changed .out to .y to match mx2 port
    );

  endmodule
