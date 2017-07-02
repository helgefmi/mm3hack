bank $1E

// random hexedits
org {org_stages_done_break}
    // Comment out storing "stages done" after beating break:
    // STA $60
    NOP ; NOP

org {org_stages_done_robo}
    // Comment out storing "stages done" for robot masters
    // STA $61
    NOP ; NOP

org $CA22
    // JSR $FF21
    JSR start_of_stage

// nmi
org $C0E7
    // INC $92 ; LDX #$FF
    JSR nmi_hook
    NOP


// -----
bank $1F
// -----

// trans start
org {org_trans_start_hori_hook}
    // LDA $F9 ; SEC
    JSR trans_start.hori

org {org_trans_start_vert_hook}
    // JSR $EB6D
    JSR trans_start.vert


// trans frame
org {org_trans_frame_hori_hook}
    // JSR $E467
    JSR trans_frame.hori

org {org_trans_frame_vert_hook}
    // LDA $23 : AND #$04
    JSR trans_frame.vert
    NOP


// oam
org $FF5B
    JSR oam_hook


// trans start
org $F320
start_of_stage:
    // This is called at the very start of a stage (when READY blinks).
    LDA #$0 ; STA {timer_frames} ; STA {timer_seconds}
    JSR $FF21
    RTS

trans_start:
  .hori:
    JSR .main
    LDA $F9
    SEC
    RTS

  .vert:
    JSR .main
    JSR {org_trans_start_vert_jsr}
    RTS

  .main:
    LDA {timer_frames} ; STA {last_frames}
    LDA {timer_seconds} ; STA {last_seconds}
    RTS


// trans frame
trans_frame:
  .hori:
    JSR .main
    JSR {org_trans_frame_hori_jsr}
    RTS

  .vert:
    JSR .main
    LDA $23 ; AND #$04
    RTS

  .main:
    // Swaps in the CHR ROM with our counter digits in.
    // Luckily, the game switches to the appropriate one after the transition by itself.
    LDA #$05 ; STA $8000 ; LDA #$66 ; STA $8001

    // Indicate that we are still transitioning since we want to transfer the counter to the oam each frame.
    INC {flag_trans}

    // Set them to 0 every frame during transition. It's overkill, but
    // we don't have to "detect" the last transition frame.
    LDA #0 ; STA {timer_frames} ; STA {timer_seconds}
    RTS


// oam
oam_hook:
    // This call completely erases the oam buffer, making it a perfect place
    // to populate it with whatever we want.
    JSR $C5E9

    LDA {flag_trans} ; BNE .transition
    RTS

  .transition:
    LDA #0 ; STA {flag_trans}

    LDA {last_seconds} ; JSR hex_to_dec ; TAX
    LDA {last_frames} ; JSR hex_to_dec ; TAY

    // Y
    LDA #$10
    STA $0204 ; STA $0208 ; STA $020C ; STA $0210 ; STA $0214

    // Palette
    LDA #$01
    STA $0206 ; STA $020A ; STA $020E ; STA $0212 ; STA $0216

    // X
    LDA #$D0 ; STA $0207
    LDA #$D8 ; STA $020B
    LDA #$E0 ; STA $020F
    LDA #$E8 ; STA $0213
    LDA #$F0 ; STA $0217

    // Tile id
    LDA #$CC ; STA $020D
    TXA ; LSR ; LSR ; LSR ; LSR ; ORA #$C0 ; STA $0205
    TXA ; AND #$0F ; ORA #$C0 ; STA $0209
    TYA ; LSR ; LSR ; LSR ; LSR ; ORA #$C0 ; STA $0211
    TYA ; AND #$0F ; ORA #$C0 ; STA $0215

    // This is supposed to point to the next slot in the oam buffer.
    LDA #$18 ; STA $97
    RTS


// nmi
nmi_hook:
    INC $92

    INC {timer_frames} ; LDA {timer_frames} ; CMP #60 ; BNE .done
    INC {timer_seconds} ; LDA #0 ; STA {timer_frames}

  .done:
    LDX #$FF
    RTS


// util
hex_to_dec:
    // Maps e.g. #69 to $69.
    STA {tmp1}
    LSR
    ADC {tmp1}
    ROR
    LSR
    LSR
    ADC {tmp1}
    ROR
    ADC {tmp1}
    ROR
    LSR
    AND #$3C
    STA {tmp2}
    LSR
    ADC {tmp2}
    ADC {tmp1}
    RTS


warnpc $F580
