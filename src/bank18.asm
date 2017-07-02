bank $18

org {hook_handle_stage_select}
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
    JMP {org_break_man}

  .select_normal_stage:
    LDA #$00 ; STA $60 ; STA $61

    LDA {org_stage_map},y
    JMP stage_select

  .pressed_start:
    LDA $12 ; CMP #$01 ; BEQ .no_action
    LDA $13 ; CMP #$03 ; BEQ .no_action

    LDA $12 ; CLC ; ADC $13 ; ADC #$9 ; TAY
    LDA #$09 ; STA $60
    LDA {org_stage_map},y
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
