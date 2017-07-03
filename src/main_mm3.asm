arch nes.cpu
header

banksize $2000

define hook_handle_stage_select $92FD

define org_menu_idle $9261
define org_load_stage $C8F7
define org_break_man $9ABC
define org_stage_map $9CE1
define org_stages_done_break $DF7D
define org_stages_done_robo $DC5C

define org_trans_start_hori_hook $E2D5
define org_trans_start_vert_hook $E395
define org_trans_start_vert_jsr $EB6D
define org_trans_boss_hook $82BA

incsrc "defines.asm"
incsrc "bank02.asm"
incsrc "bank18.asm"
incsrc "bank1c.asm"
incsrc "bank1e.asm"
incsrc "gfx.asm"
