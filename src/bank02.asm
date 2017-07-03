bank $02

// Same for JP/EN
org $A023
    JSR handle_menu

// Possibly same for JP/EN
org $B9E0
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

    // Reset "stages beaten"
    LDA #$00 ; STA $60 ; STA $61

    // We need to reset the stack to where it would usually be when going to $9212,
    // else it would continue to grow and make the game crash eventually.
    PLA ; PLA ; PLA ; PLA ; PLA
    PLA ; PLA ; PLA ; PLA ; PLA

    // Make sure it goes to menu initializing code after `JMP {org_switchbanks}`.
    LDA #$92 ; PHA
    LDA #$11 ; PHA

    JMP {org_switchbanks}

  .done:
    JSR $A398
    RTS

stage_select_palette:
    db $0F,$30,$15,$11,$0F,$37,$21,$10,$0F,$37,$26,$15,$0F,$37,$26,$0F

warnpc $BAE0
