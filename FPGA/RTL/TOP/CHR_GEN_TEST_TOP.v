//CHR_GEN.vhd<
//CHR_GEN()
// by @mangakoji
// license by BSD
//      without font ROM data
//
//180617s       :syntax check passed 
//180426f       :mod for new coding rule
//2018-03-12m   :mod net naming rule xxxs
//2018-03-11u   :mod new coding rule like BSD style
//              :many debug
//2014-??-??
//2010-01-01?? : 1st.
module CHR_GEN_TEST_TOP
(
      input             FSC32_CK_i
    , input tri1        XSYS_R_i
    , input tri0 [7:0]  CPU_VRAM_WDs_i
    , input tri0 [9:0]  CPU_VRAM_WAs_i
    , input tri0        CPU_VRAM_WE_i
    , input tri0        BUS_OSD_CPU_USE
    , input tri0        BUS_OSD_OFF
    , input tri0 [11:0] BUS_H_DLYs
    , input tri0 [10:0] BUS_V_DLYs
    , input tri0 [2:0]  BUS_H_MAGs
    , input tri0 [2:0]  BUS_V_MAGs
    , input tri0 [7:0]  BUS_H_SCROLLs
    , input tri0 [7:0]  BUS_V_SCROLLs
    , input tri0        BUS_FUCHI_MASK
    , output        VIDEO_o
    //
    , output        XSYNC_o
    , output        BLANK_o
    , output        BURST_o
    , output        CHAR_o
    , output        FUCHI_o
    , output[ 7:0] YYs_o
    , output[ 9:0] VIDEOs_o
//    , output[ 9:0] VIDEOs_DD_o 
) ;
    reg         FSC4_CK_EE ;
    reg [ 2 :0] FSC4_PRESCALE_CTRs  ;
    wire FSC4_PRESCALE_CTRs_cy ;
    assign FSC4_PRESCALE_CTRs_cy = (FSC4_PRESCALE_CTRs == 6) ;
    always@(posedge FSC32_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
        begin
            FSC4_CK_EE <= 1 ;
            FSC4_PRESCALE_CTRs <= 7 ;
        end else
        begin
            FSC4_CK_EE <= FSC4_PRESCALE_CTRs_cy ;
            if( FSC4_CK_EE )
                FSC4_PRESCALE_CTRs <= 0 ;
            else
                FSC4_PRESCALE_CTRs <= FSC4_PRESCALE_CTRs + 1 ;
        end
    wire XSYNC ;
    wire BLANK ;
    wire BURST ;
    wire[ 9:0]  HCTRs ;
    wire[ 9:0]  VCTRs ;
    NTSC_TG 
    NTSC_TG 
    (
          .CK_i         ( FSC32_CK_i    )
        , .XAR_i        ( XSYS_R_i      )
        , .CK_EE_i      ( FSC4_CK_EE    )
        , .XSYNC_o      ( XSYNC      )//0:sync
        , .BLANK_o      ( BLANK      )//1:blank
        , .BURST_o      ( BURST      )//1:burst
        , .HCTRs_o      ( HCTRs )
        , .VCTRs_o      ( VCTRs )
    ) ;
    assign XSYNC_o      = XSYNC      ; //0:sync
    assign BLANK_o      = BLANK      ; //1:blank
    assign BURST_o      = BURST      ; //1:burst


    reg XHD ;
    reg XVD ;
    always@(posedge FSC32_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
        begin
            XHD <= 1 ;
            XVD <= 1 ;
        end else if( FSC4_CK_EE )
        begin
            XHD <= ~ (HCTRs == (910-1)) ;
            XVD <= ~ (VCTRs  == 0) ;
        end

    reg [7:0] VRAM_WDs ;
    reg [9:0] VRAM_WAs ;
    reg        VRAM_WE ;
    always@(posedge FSC32_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i)
        begin
            VRAM_WDs <= 0 ;
            VRAM_WAs <= 0 ;
            VRAM_WE <= 0 ;
        end else if( FSC4_CK_EE )
        begin 
            VRAM_WDs <= VRAM_WDs + 1 ;
            VRAM_WAs <= VRAM_WAs + 1 ;
            VRAM_WE <= 1 ;
        end            


    wire    CHAR ;
    wire    FUCHI ;
    CHR_GEN
    CHR_GEN
    (
          .CK_i             ( FSC32_CK_i    )
        , .XAR_i            ( XSYS_R_i      )
        , .CK_EE_i          ( FSC4_CK_EE    )
        , .XHD_i            ( XHD           )
        , .XVD_i            ( XVD           )
        , .VRAM_WDs_i       ( VRAM_WDs      )
        , .VRAM_WAs_i       ( VRAM_WAs      )
        , .VRAM_WE_i        ( VRAM_WE       )
        , .CPU_VRAM_WDs_i   ( CPU_VRAM_WDs_i    )
        , .CPU_VRAM_WAs_i   ( CPU_VRAM_WAs_i    )
        , .CPU_VRAM_WE_i    ( CPU_VRAM_WE_i     )
        , .BUS_OSD_CPU_USE  ( BUS_OSD_CPU_USE   )
        , .BUS_OSD_OFF      ( BUS_OSD_OFF    )
        , .BUS_H_DLYs       ( BUS_H_DLYs     )
        , .BUS_V_DLYs       ( BUS_V_DLYs     )
        , .BUS_H_MAGs       ( BUS_H_MAGs     )
        , .BUS_V_MAGs       ( BUS_V_MAGs     )
        , .BUS_H_SCROLLs    ( BUS_H_SCROLLs  )
        , .BUS_V_SCROLLs    ( BUS_V_SCROLLs  )
        , .BUS_FUCHI_MASK   ( BUS_FUCHI_MASK )
        , .CHAR_o           ( CHAR          )
        , .FUCHI_o          ( FUCHI         )
    ) ;
    assign CHAR_o = CHAR ;
    assign FUCHI_o = FUCHI ;

    reg [7:0] YYs ;
    always@(posedge FSC32_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i )
            YYs <= 0 ;
        else if( FSC4_CK_EE )
            if( CHAR )
                YYs <= 8'd220 ;
            else if( FUCHI )
                YYs <= 8'h00 ;
            else
                YYs <= 8'd110 ;
    assign YYs_o = YYs ;
    wire [9:0] VIDEOs ;
    NTSC_ENC_TINY
    NTSC_ENC_TINY
    (
          . CK_i    ( FSC32_CK_i    )
        , .XAR_i    ( XSYS_R_i      )
        , .CK_EE_i  ( FSC4_CK_EE    )
        , .YYs_i    ( YYs           )
        , .BLANK_i  ( BLANK         ) //1:BLANK */
        , .XSYNC_i  ( XSYNC         ) //0:SYNC */
        , .VIDEOs_o ( VIDEOs        )
    ) ;
    assign VIDEOs_o = VIDEOs ;
    // 
    reg [9:0] VIDEOs_Ds [0:7] ;
    reg [9:0] VIDEOs_DD ;
    always@(posedge FSC32_CK_i or negedge XSYS_R_i)
        if( ~ XSYS_R_i)
        begin
            VIDEOs_Ds[0] <= 0 ;
            VIDEOs_Ds[1] <= 0 ;
            VIDEOs_Ds[2] <= 0 ;
            VIDEOs_Ds[3] <= 0 ;
            VIDEOs_Ds[4] <= 0 ;
            VIDEOs_Ds[5] <= 0 ;
            VIDEOs_Ds[6] <= 0 ;
            VIDEOs_Ds[7] <= 0 ;
            VIDEOs_DD  <= 0 ;
        end else
        begin
            VIDEOs_Ds[0] <= VIDEOs ;
            VIDEOs_Ds[1] <= VIDEOs_Ds[0] ;
            VIDEOs_Ds[2] <= VIDEOs_Ds[1] ;
            VIDEOs_Ds[3] <= VIDEOs_Ds[2] ;
            VIDEOs_Ds[4] <= VIDEOs_Ds[3] ;
            VIDEOs_Ds[5] <= VIDEOs_Ds[4] ;
            VIDEOs_Ds[6] <= VIDEOs_Ds[5] ;
            VIDEOs_Ds[7] <= VIDEOs_Ds[6] ;
            VIDEOs_DD <= 
                (
                      VIDEOs_Ds[0] 
                    + VIDEOs_Ds[1]
                    + VIDEOs_Ds[2]
                    + VIDEOs_Ds[3]
                    + VIDEOs_Ds[4]
                    + VIDEOs_Ds[5]
                    + VIDEOs_Ds[6]
                    + VIDEOs_Ds[7]
                )>>3 
            ;
        end
    assign VIDEOs_DD_o = VIDEOs_DD ;
    DELTA_SIGMA_1BIT_DAC 
    #(
        .C_DAT_W    ( 10 )
    )(
          .CK       ( FSC32_CK_i    )
        , .XARST_i  ( XSYS_R_i      )
        , .DAT_i    ( VIDEOs     )
        , .QQ_o     ( VIDEO_o       )
    ) ;
    
    
endmodule
//CHR_GEN_TEST_TOP()

