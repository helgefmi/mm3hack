arch nes.cpu
header

banksize $2000

incsrc "defines.asm"


bank $02

org $A023
    JSR handle_menu


org $AD28
handle_menu:
    LDA $14 ; AND #$20 ; BEQ .done

    // Fade to black
    LDA #$00 ; STA $EE ; JSR $C752

    // Remove OAM entries
    LDX #$00
    LDA #$F8
  .oam_loop:
    STA $200,x
    INX ; INX ; INX ; INX ; BEQ .oam_loop_done
  .oam_loop_done:

  .remove_menu_loop:
    LDA $51
    CMP #$E8
    BEQ .remove_menu_done
    LDA $51
    CLC
    ADC #$04
    STA $51
    JSR $A2EA
    DEC $95
    JMP .remove_menu_loop

  .remove_menu_done:

    // Sets correct palette for the menu.
    LDX #$0F
  .loop_palette:
    LDA stage_select_palette,x
    STA $610,x
    DEX ; BPL .loop_palette

    // This tells the game we no longer have a menu up
    LDA #$00 ; STA $50

    // Fixes a weird "bug" where it softlocks if you scrolled horizontally.
    LDA #$00 ; STA $FA ; STA $FC

    // Set correct CHR banks. Not all of them really needed
    LDA #$7C ; STA $E8 ; LDA #$7E ; STA $E9
    LDA #$38 ; STA $EA ; LDA #$39 ; STA $EB
    LDA #$36 ; STA $EC ; LDA #$34 ; STA $ED

    // Change to these PRG banks
    LDA #$18 ; STA $F4
    LDA #$13 ; STA $F5

    // Pop current return address off stack
    PLA ; PLA

    // Make sure it goes to menu initializing code after `JMP {org_switchbanks}`.
    LDA #$92 ; PHA
    LDA #$11 ; PHA

    JMP {org_switchbanks}

  .done:
    JSR $A398
    RTS

stage_select_palette:
    db $0F,$30,$15,$11,$0F,$37,$21,$10,$0F,$37,$26,$15,$0F,$37,$26,$0F

warnpc $AE00

bank $1E

// random hexedits
org $DF7D
    // Comment out storing "stages done" after beating break
    NOP ; NOP

org $DC5C
    // Comment out storing "stages done" for robot masters
    NOP ; NOP

org $CA22
    JSR start_of_stage

// nmi
org $C0E7
    JSR nmi_hook ; NOP


bank $1F

// trans start
org $E2D5
    JSR trans_start.hori

org $E395
    JSR trans_start.vert


// trans frame
org $E623
    JSR trans_frame.vert
    NOP

org $E5E3
    JSR trans_frame.hori


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
    JSR $EB6D
    RTS

  .main:
    LDA {timer_frames} ; STA {last_frames}
    LDA {timer_seconds} ; STA {last_seconds}
    RTS


// trans frame
trans_frame:
  .hori:
    JSR .main
    JSR $E467
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
    // Thiss call completely erases the oam buffer, making it a perfect place
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


bank $18

org $92FD
    JMP handle_stage_select

org $9E4A
handle_stage_select:
    LDA {current_order_is_drawn} ; BNE .current_order_is_drawn
    INC {current_order_is_drawn} ; JSR draw_current_order

  .current_order_is_drawn:
    LDA $14 ; AND #$10 ; BNE .pressed_start
    LDA $14 ; AND #$20 ; BNE .pressed_select
    LDA $14 ; AND #$40 ; BNE .pressed_b
    LDA $14 ; AND #$80 ; BNE .pressed_a

    JMP {org_menu_idle}

  .pressed_a:
    // Cursor position
    LDA $12 ; CLC ; ADC $13
    TAY ; CPY #$04 ; BNE .select_normal_stage

    // Make it so we've beaten no Wily stages
    LDA #$00 ; STA $75

    // Enter Break Man
    JMP $9ABC

  .select_normal_stage:
    LDA #$00 ; STA $60 ; STA $61

    LDA $9CE1,y
    JMP stage_select

  .pressed_start:
    LDA $12 ; CMP #$01 ; BEQ .no_action
    LDA $13 ; CMP #$03 ; BEQ .no_action

    LDA $12 ; CLC ; ADC $13 ; ADC #$9 ; TAY
    LDA #$09 ; STA $60
    LDA $9CE1,y
    JMP stage_select

  .no_action:
    JMP {org_menu_idle}

  .pressed_b:
    LDA $12 ; CLC ; ADC $13
    // How many Wily stages we've supposedly beaten
    STA $75
    ADC #$0C
    JMP stage_select

  .pressed_select:
    LDA {current_order} ; ADC #1
    CMP #3 ; BNE .save_current_order
    LDA #0

  .save_current_order:
    STA {current_order}
    JSR draw_current_order
    JMP {org_menu_idle}


stage_select:
    // Store stage index
    STA $22 ; STA $0F

    TYA ; PHA

    LDA {current_order}
    ASL ; ASL ; ASL ; ASL ; ASL ; TAY

    LDA #$00
    LDX #$0A

  .reset_loop:
    STA $A3,x
    DEX ; BPL .reset_loop

    STA $6E
    STA $60 ; STA $61

  .set_loop:
    LDA .order_weapons,y
    CMP $0F ; BEQ .done
    CMP #$FF ; BEQ .done
    INY ; LDA .order_weapons,y ; TAX ; LDA #$9C ; STA $00,x
    INY ; LDA .order_weapons,y ; TAX ; LDA #$9C ; STA $00,x
    INY
    JMP .set_loop

  .done:
    LDA #$00 ; STA {current_order_is_drawn}
    LDA #$00 ; STA {timer_frames} ; STA {timer_seconds}
    PLA ; TAY ; LDA $0F
    JSR {org_load_stage}
    RTS

    // This needs a rewrite
  .order_weapons:
    // Top first
    db $4, $A7, $A9 // top
    db $7, $AC, $AB // shadow
    db $2, $A3, $A9 // gemini
    db $0, $A4, $AD // needle
    db $1, $A6, $A9 // magnet
    db $3, $A5, $A9 // hard
    db $5, $A8, $A9 // snake
    db $6, $AA, $A9 // spark
    db $FF, $FF, $FF
    db $FF, $FF, $FF
    db $FF, $FF

    // Magnet first
    db $1, $A6, $A9 // magnet
    db $3, $A5, $A9 // hard
    db $4, $A7, $A9 // top
    db $7, $AC, $AB // shadow
    db $2, $A3, $A9 // gemini
    db $0, $A4, $AD // needle
    db $5, $A8, $A9 // snake
    db $6, $AA, $A9 // spark
    db $FF, $FF, $FF
    db $FF, $FF, $FF
    db $FF, $FF

    // Gemini first
    db $2, $A3, $a9 // gemini
    db $0, $A4, $aD // needle
    db $6, $AA, $a9 // spark
    db $1, $A6, $a9 // magnet
    db $3, $A5, $a9 // hard
    db $4, $A7, $a9 // top
    db $7, $AC, $aB // shadow
    db $5, $A8, $a9 // snake
    db $FF, $FF, $FF
    db $FF, $FF, $FF
    db $FF, $FF


draw_current_order:
    LDA {current_order} ; ASL ; ASL ; ASL ; ASL ; TAX
    LDY #$0

    // Take account which name table quadrant we should draw on
    LDA .order_gfx,x
    ORA $10
    STA $0780,y
    INX ; INY

  .loop:
    // Transfer tiles to buffer and let NMI transfer it to the PPU
    LDA .order_gfx,x
    STA $0780,y
    INX ; INY ; CPY #$10 ; BNE .loop

    // Indicate to NMI to transfer buffer
    LDA #$01 ; STA $19
    RTS

  .order_gfx:
    // top
    db $20, $4A, $0B, $73, $1D, $18, $19, $25, $0F, $12, $1B, $1C, $1D, $73, $74, $FF
    // magnet
    db $20, $4A, $0B, $16, $0A, $10, $17, $0E, $1D, $73, $0F, $12, $1B, $1C, $1D, $FF
    // gemini
    db $20, $4A, $0B, $10, $0E, $16, $12, $17, $12, $73, $0F, $12, $1B, $1C, $1D, $FF

warnpc $9FFF

bank $2C
org $9800
    incbin "../target/digits_small.bin"
