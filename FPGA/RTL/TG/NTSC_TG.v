// $Id: $
// file_name    : NTSC_TG.v
// discript     : frame_construction
//
// 2013-02-23W6 : EE append, and rename names
// 2009-07-29W3 : coding rule correct
// 2009-07-28W2 : WIP
// 2004-05???   : 1st.


/*
//      counter archtecture
//       4fsc
//       v
//       H 0~910-1
//       v
//      --------v_ctr----------
//       V 0~263-1  
//       v cy at half Frame
//       v FI <= 1
//       v 
//       V 0~263-1
//       v cy at full Frame
//       v FI <= 0
//     ---------------------
//       v
//       now 1 frame
//
*/

module  NTSC_TG (     
         CK 
        , XAR 
        , XR
        , EE
        , HSYNC
        , VSYNC
        , SYNC 
        , H_BLANK
        , V_BLANK
        , BLANK 
        , BURST
        , FI
        , H_CTR 
        , V_CTR
        , HCY 
        , HHCY
        , VCY
        , H_START
        , V_START
) ;



        parameter P_H_START = 10'd126   ;
        parameter P_V_START = 10'd31 ;

        input           CK              ;
        input           XAR             ;
        input           XR              ;
        input           EE              ;
        output          HSYNC           ;
        output          VSYNC           ;
        output          SYNC            ;       // 0:SYNC
        output          H_BLANK         ;
        output          V_BLANK         ;
        output          BLANK           ;       // 1:BLANK
        output          BURST           ;       // 1:BURST
        output          FI              ;
        output  [ 9:0]  H_CTR           ;
        output  [ 9:0]  V_CTR           ;
        output          HCY             ;
        output          HHCY            ;
        output          VCY             ;
        output          H_START         ;       // 1:en
        output          V_START         ;       // 1:en
        localparam 
                P_HH_SIZE               = 455
                , P_H_SIZE              = 2 * P_HH_SIZE
                , P_EQU_SIDE_1          = 36
                , P_EQU_SIDE_2          = P_HH_SIZE + P_EQU_SIDE_1
                , P_EQU_CENTER_1        = 388
                , P_EQU_CENTER_2        = P_HH_SIZE + P_EQU_CENTER_1
                , P_HSYNC_PORCH         =  66
        ;

        wire            HCY             ;
        assign  HCY = & ( ((P_H_SIZE - 1) & H_CTR[9 :0]) | ~(P_H_SIZE -1)) ;
//        assign  HCY = (P_H_SIZE - 1) == H_CTR[9 :0] ;
        wire            HHCY            ;
        assign  HHCY = (P_HH_SIZE - 1) ==  H_CTR[9 :0] ;
        wire            HSYNC_a ;
        reg             HSYNC   ;

        /*      h_count 0--P_H_SIZE-1     */
        reg     [ 9:0]  H_CTR      ;
        wire    [10:0]  inc_h   ;
        assign  HSYNC_a = 
                ( HCY ) ?                               1'b0
                : ((P_HSYNC_PORCH-1) == H_CTR[9:0]) ?     1'b1
                :                                       HSYNC
        ;
        assign inc_h = H_CTR + 10'd1 ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR) begin
                        H_CTR   <= 10'd0 ;
                        HSYNC   <= 1'b1 ;
                end else if ( EE ) begin
                        H_CTR <= ( ~ XR || HCY) ? 9'h000 : inc_h[9 :0] ;
                        HSYNC <=  HSYNC_a ;
                end


        wire            equ_sync_side_a         ;
        reg             equ_sync_side           ;
        wire            equ_sync_center_a       ;
        reg             equ_sync_center         ;
        //      等価パルス＠VSYNC side 3+3H
        assign  equ_sync_side_a = 
                ( HCY ) ?                       1'b0
                : ((P_EQU_SIDE_1-1) == H_CTR) ?   1'b1
                : ( HHCY ) ?                    1'b0
                : ((P_EQU_SIDE_2-1) == H_CTR) ?   1'b1
                :                               equ_sync_side
        ;
        //      等価パルス＠VSYNC center 3 H
        assign  equ_sync_center_a = 
                ( HCY ) ?                       1'b0
                : ((P_EQU_CENTER_1-1) == H_CTR) ? 1'b1
                : ( HHCY ) ?                    1'b0
                : ((P_EQU_CENTER_2-1) == H_CTR) ? 1'b1
                :                               equ_sync_center
        ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR) begin
                        equ_sync_center <= 1'b1 ;
                        equ_sync_side <= 1'b1 ;
                end else if ( EE ) begin
                        equ_sync_side <= equ_sync_side_a ;
                        equ_sync_center <= equ_sync_center_a ;
                end

        wire            SYNC_a  ;
        reg             SYNC    ;
        wire            equ_sync_center_now_a ;
        assign  SYNC_a = 
                ( VSYNC_a ) ?                   HSYNC_a
                : ( equ_sync_center_now_a) ?    equ_sync_center
                :                               equ_sync_side
        ;
        always @ (posedge CK or negedge XAR)
                if ( ~XAR )
                        SYNC <= 1'b1 ;
                else if ( EE )
                        SYNC <= SYNC_a ;


        /*      v_count 0--262,0--261 repeat */
        reg     [ 9 :0] V_CTR   ;
        reg             FI      ;
        wire            VCY     ;
        wire            v0cy    ;
        wire            v1cy    ;
        assign v0cy = ~ FI & (262 == V_CTR) ;
        assign v1cy = FI & (261 == V_CTR) ; 
        assign VCY = v0cy | v1cy ;
        wire    [10:0]  inc_v ;
        assign inc_v = V_CTR + 10'd1 ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR ) begin
                        V_CTR <=  10'd0 ;
                        FI <= 1'd0 ;
                end else if ( EE ) begin
                        V_CTR <= 
                                ( ~XR ) ?       10'h000
                                : (VCY & HCY) ? 10'h000
                                : ( HCY ) ?     inc_v[9 :0]
                                :               V_CTR
                        ;
                        FI <= 
                                ( ~ XR) ?               1'b0
                                : (v0cy & HCY ) ?       1'b1
                                : (v1cy & HCY) ?        1'b0
                                :                       FI
                        ;
                end

        wire            VSYNC_a ;
        reg             VSYNC   ;
        assign  VSYNC_a = 
                (VCY &  HCY  &   FI) ?                  1'b0 
                : ((9-1 == V_CTR) & HCY  & ~ FI) ?   1'b1 
                : (VCY & HHCY & ~ FI) ?                 1'b0 
                : ((9-1 == V_CTR) & HHCY &   FI) ?    1'b1
                :                                       VSYNC
        ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR)
                        VSYNC <= 1'b1 ;
                else if ( EE )
                        VSYNC <= VSYNC_a ;

        reg     equ_sync_center_now ;
        assign  equ_sync_center_now_a = 
                ((  2 == V_CTR) & HCY  & ~ FI) ?    1'b1 :
                ((  5 == V_CTR) & HCY  & ~ FI) ?    1'b0 :
                ((  2 == V_CTR) & HHCY &   FI) ?    1'b1 :
                ((  5 == V_CTR) & HHCY &   FI) ?    1'b0
                 :
                                                    equ_sync_center_now
        ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR)
                        equ_sync_center_now <= 1'd1 ;
                else if ( EE )
                        equ_sync_center_now <= equ_sync_center_now_a ;

        /*      1:BLANK       */
        reg             BLANK           ;
        reg             H_BLANK         ;
        reg             V_BLANK         ;
        reg             H_START         ;
        reg             V_START         ;
        wire            BLANK_a         ;
        wire            H_BLANK_a       ;
        wire            V_BLANK_a       ;
        localparam P_H_BLANK_START = 894 ;
        localparam P_H_BLANK_END = 125   ;
        assign H_BLANK_a = 
                ((P_H_BLANK_START-1) == H_CTR) ?   1'd1 
                : ( P_H_BLANK_END == H_CTR)   ?   1'd0 
                :                               H_BLANK  ;
        assign V_BLANK_a =
                (FI & VCY & HCY) ?              1'b1 
                : (~FI & (19 == V_CTR) & HCY) ? 1'b0 
                : (~FI & VCY & HHCY) ?          1'b1 
                : (FI & (19 == V_CTR) & HHCY) ? 1'b0
                :                               V_BLANK ;
        assign BLANK_a = H_BLANK_a | V_BLANK_a ;
        wire            H_START_a       ;
        assign H_START_a = (P_H_START-1 == H_CTR[9:0]) ;
        always @ (posedge CK or negedge XAR)
                if ( ~ XAR) begin
                        H_BLANK <= 1'b1 ;
                        V_BLANK <= 1'b1 ;
                        BLANK <= 1'b1 ;
                        H_START <= 1'b0 ;
                        V_START <= 1'b0 ;
                end else if ( EE ) begin
                        H_BLANK <= H_BLANK_a ;
                        V_BLANK <= V_BLANK_a ;
                        BLANK <=  BLANK_a ;
                        H_START <= H_START_a ;
                        V_START <= (P_V_START-1 == V_CTR[9:0]) & H_START_a ;
                        
                end


        reg             BURST   ;
        wire            BURST_a ;
        localparam P_BURST_START = 73 ;
        localparam P_BURST_END = 115 ;
        assign BURST_a = ~ V_BLANK & (
                (P_BURST_START-1 == H_CTR) ?    1'b1
                : (P_BURST_END == H_CTR) ?      1'b0 
                :                               BURST
            )
        ;
        always  @(posedge CK or negedge XAR)
                if ( ~ XAR)
                        BURST <= 1'b0 ;
                else if ( EE )
                        BURST <= BURST_a ;
endmodule
// NTSC_TG.v
