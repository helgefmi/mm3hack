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

  .boss:
    JSR $F89A
    JSR .main
    RTS

  .main:
    // Show frame counter for 1 second.
    LDA #60 ; STA {trans_timer}

    LDA {timer_frames} ; STA {last_frames}
    LDA {timer_seconds} ; STA {last_seconds}
    RTS


// oam
oam_hook:
    // This call completely erases the oam buffer, making it a perfect place
    // to populate it with whatever we want.
    JSR $C5E9

    LDA {trans_timer} ; BNE .transition
    RTS

  .transition:
    DEC {trans_timer} ; BNE .not_done

    // Makes the NMI restore the correct banks (remove digits from tile map).
    LDA #$01 ; STA $1B

  .not_done:
    // Set them to 0 every frame during transition. It's overkill, but
    // we don't have to "detect" the last transition frame.
    LDA #0 ; STA {timer_frames} ; STA {timer_seconds}

    // Swaps in the CHR ROM with our counter digits in.
    // Luckily, the game switches to the appropriate one after the transition by itself.
    LDA #$05 ; STA $8000 ; LDA #$66 ; STA $8001

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
