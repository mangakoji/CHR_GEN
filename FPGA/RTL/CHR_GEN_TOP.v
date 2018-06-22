//CHR_GEN_TOP.v
//      PLUS_CTR top
//      pulse counter 
//170323r   001 :retruct ORGAN
//170320m   002 :start ORGOLE
//170320m   001 :mv to CQMAX10 
//151220su      :mod sound ck 192 -> 144MHz
//               1st
//

module CHR_GEN_TOP
(
      input     CK48M_i     //27
    , input     P29_i
    , input     XPSW_i      //123
    , output    XLED_R_o   //120
    , output    XLED_G_o   //122
    , output    XLED_B_o   //121
    // CN1
    , inout     P62
    , inout     P61
    , inout     P60
    , inout     P59
    , inout     P58
    , inout     P57
    , inout     P56
    , inout     P55
    , inout     P52
    , inout     P50
    , inout     P48
    , inout     P47
    , inout     P46
    , inout     P45
    , inout     P44
    , inout     P43
    , inout     P41
    , inout     P39
    , inout     P38
    // CN2
    , inout     P124
    , inout     P127
    , inout     P130
    , inout     P131
    , inout     P132
    , inout     P134
    , inout     P135
    , inout     P140
    , inout     P141
//    , inout     P3 //analog AD pin
    , inout     P6
    , inout     P7
    , inout     P8
    , inout     P10
    , inout     P11
    , inout     P12
    , inout     P13
    , inout     P14
    , inout     P17

) ;
    function integer log2;
        input integer value ;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end endfunction
    parameter C_FCK = 48_000_000 ;
    parameter C_F_WAVE = 440 ;
    localparam C_PRESCALE_DIV = C_FCK /C_F_WAVE/(1<<12) ;//26
    localparam C_PRESCALE_CTR_W = log2(C_PRESCALE_DIV) ; //5


    // start
    wire            NFSC_CK        ;
    wire            DAC_CK        ;
    wire            CK              ;
    wire            XSYS_R           ;
    PLL 
    PLL
    (
              .areset       ( 1'b0          )
            , .inclk0       ( P29_i       )
            , .c0           ( NFSC_CK       )
            , .c1           ( DAC_CK      )
            , .locked       ( XSYS_R         )
    ) ;

    wire [7:0]  CPU_VRAM_WDs        ;
    wire [9:0]  CPU_VRAM_WAs        ;
    wire        CPU_VRAM_WE         ;
    wire        BUS_OSD_CPU_USE     ;
    wire        BUS_OSD_OFF         ;
    wire [11:0] BUS_H_DLYs          ;
    wire [10:0] BUS_V_DLYs          ;
    wire [2:0]  BUS_H_MAGs          ;
    wire [2:0]  BUS_V_MAGs          ;
    wire [7:0]  BUS_H_SCROLLs       ;
    wire [7:0]  BUS_V_SCROLLs       ;
    wire        BUS_FUCHI_MASK      ;
    wire        VIDEO   ;
    wire        CHAR    ;
    wire        FUCHI   ;
    wire        XSYNC   ;
    wire        BLANK   ;
    wire        BURST   ;
    CHR_GEN_TEST_TOP
    CHR_GEN_TEST_TOP
    (
          .NFSC_CK_i       ( NFSC_CK  )
        , .DAC_CK_i        ( DAC_CK  )
        , .XSYS_R_i         ( XSYS_R    )
//        , .CPU_VRAM_WDs_i   ()
//        , .CPU_VRAM_WAs_i   ()
//        , .CPU_VRAM_WE_i    ()
//        , .BUS_OSD_CPU_USE  ()
//        , .BUS_OSD_OFF      ()
//        , .BUS_H_DLYs       ()
//        , .BUS_V_DLYs       ()
        , .BUS_H_MAGs       (2)
        , .BUS_V_MAGs       (2)
//        , .BUS_H_SCROLLs    ()
//        , .BUS_V_SCROLLs    ()
//        , .BUS_FUCHI_MASK   ()
        , .VIDEO_o          ( VIDEO     )
        , .XSYNC_o          ( XSYNC     )
        , .BLANK_o          ( BLANK     )
        , .BURST_o          ( BURST     )
        , .CHAR_o           ( CHAR      )
        , .FUCHI_o          ( FUCHI     )
    ) ;
    //CHR_GEN_TEST_TOP


//    assign P17= WAVE[11] ;
//    assign P14 = ~ WAVE[11]         ;
//    assign XLED_R_o = ~ SCORE_CTR[0]      ;

//    assign P17= QQ_X ;
//    assign P14 =QQ_Y ;
    assign XLED_R_o = ~ 1'b0 ;
    assign XLED_G_o = ~ 1'b0 ;
    assign XLED_B_o = ~ 1'b0 ;
    assign P38 = FUCHI ;
    assign P39 = XSYNC ;
    assign P41 = BLANK ;
    assign P43 = BURST ;
    assign P44 = CHAR ;
    assign P45 = VIDEO ;
endmodule //CHR_GEN_TOP
