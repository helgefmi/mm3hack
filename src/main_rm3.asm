arch nes.cpu
header

banksize $2000

define hook_handle_stage_select $92CD

define org_menu_idle $9231
define org_load_stage $C8F7
define org_break_man $9A88
define org_stage_map $9CAD
define org_stages_done_break $DF75
define org_stages_done_robo $DC54

define org_trans_start_hori_hook $E2CD
define org_trans_start_vert_hook $E38D
define org_trans_start_vert_jsr $EB65
define org_trans_frame_hori_hook $E5DB
define org_trans_frame_vert_hook $E61B
define org_trans_frame_hori_jsr $E45F

incsrc "defines.asm"
incsrc "bank02.asm"
incsrc "bank18.asm"
incsrc "bank1e.asm"
incsrc "gfx.asm"
