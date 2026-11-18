--[[
	Globals from Noita's vanilla lua scripts for LuaLS.
	This file SHOULD NOT be imported or used anywhere,
	just keep it open in your editor to get globals from thisd file.

	Add stuff here if you encounter missing global errors when working with vanilla globals
]]--

------------------
--- Wand stuff ---
------------------

---@class GunAction
---@field id string
---@field name string
---@field sprite string
---@field sprite_unidentified string?
---@field related_projectiles string[]?
---@field related_extra_entities string[]?
---@field type integer
---@field spawn_level string?
---@field spawn_probability string?
---@field spawn_requires_flag string?
---@field recursive boolean?
---@field price integer?
---@field mana integer?
---@field max_uses integer?
---@field never_unlimited boolean?
---@field custom_xml_file string?
---@field action fun(recursion_level: integer, iteration: integer)?

---@type GunAction[]
actions = {}

---@class Shot
---@field state ShotState
---@field num_of_cards_to_draw integer

---@class ShotState
---@field action_id string
---@field action_name string
---@field action_description string
---@field action_sprite_filename string
---@field action_unidentified_sprite_filename string
---@field action_type integer
---@field action_spawn_level string
---@field action_spawn_probability string
---@field action_spawn_requires_flag string
---@field action_spawn_manual_unlock boolean
---@field action_max_uses number
---@field custom_xml_file string
---@field action_mana_drain number
---@field action_is_dangerous_blast boolean
---@field action_draw_many_count number
---@field action_ai_never_uses boolean
---@field action_never_unlimited boolean
---@field state_shuffled boolean
---@field state_cards_drawn number
---@field state_discarded_action boolean
---@field state_destroyed_action boolean
---@field fire_rate_wait number
---@field speed_multiplier number
---@field child_speed_multiplier number
---@field dampening number
---@field explosion_radius number
---@field spread_degrees number
---@field pattern_degrees number
---@field screenshake number
---@field recoil number
---@field damage_melee_add number
---@field damage_projectile_add number
---@field damage_electricity_add number
---@field damage_fire_add number
---@field damage_explosion_add number
---@field damage_ice_add number
---@field damage_slice_add number
---@field damage_healing_add number
---@field damage_curse_add number
---@field damage_drill_add number
---@field damage_null_all number
---@field damage_critical_chance number
---@field damage_critical_multiplier number
---@field explosion_damage_to_materials number
---@field knockback_force number
---@field reload_time number
---@field lightning_count number
---@field material string
---@field material_amount number
---@field trail_material string
---@field trail_material_amount number
---@field bounces number
---@field gravity number
---@field light number
---@field blood_count_multiplier number
---@field gore_particles number
---@field ragdoll_fx number
---@field friendly_fire boolean
---@field physics_impulse_coeff number
---@field lifetime_add number
---@field sprite string
---@field extra_entities string
---@field game_effect_entities string
---@field sound_loop_tag string
---@field projectile_file string

---@type ShotState
c = nil

gun = {}
hand = {}
discarded = {}
deck = {}
shot_effects = {}
first_shot = true
current_reload_time = 0
reloading = false

ACTION_TYPE_PROJECTILE = 0
ACTION_TYPE_STATIC_PROJECTILE = 1
ACTION_TYPE_MODIFIER = 2
ACTION_TYPE_DRAW_MANY = 3
ACTION_TYPE_MATERIAL = 4
ACTION_TYPE_OTHER = 5
ACTION_TYPE_UTILITY = 6
ACTION_TYPE_PASSIVE = 7

ACTION_MANA_DRAIN_DEFAULT = 10

---@type table<string, fun()>
extra_modifiers = {}

---@type fun(num_of_cards_to_draw: integer): Shot
create_shot = nil

---@type fun(how_many: integer, instant_reload_if_empty: boolean)
draw_actions = nil

---@type fun(entity_file: string)
add_projectile = nil

---@type fun(entity_id: entity_id, action_id: string)
AddGunActionPermanent = nil

---@type fun(who_shot: entity_id, entity_file: string, x: number, y: number, vel_x: number, vel_y: number, send_message?: boolean)
shoot_projectile = nil

---@type fun(who_shot: entity_id, entity_file: string, x: number, y: number, vel_x: number, vel_y: number)
shoot_projectile_from_projectile = nil

---@type fun(entity_filename: string, delay_frames: integer, action_draw_count: integer)
add_projectile_trigger_timer = nil

---@type fun(data: any, rec_?: integer): integer
check_recursion = nil

---@type fun()
move_discarded_to_deck = nil

-------------
--- Perks ---
-------------

---@class Perk
---@field id string
---@field ui_name string
---@field ui_description string
---@field ui_icon string
---@field perk_icon string
---@field game_effect game_effect?
---@field game_effect2 game_effect?
---@field particle_effect string?
---@field stackable boolean?
---@field stackable_maximum integer?
---@field stackable_is_rare boolean?
---@field usable_by_enemies boolean?
---@field max_in_perk_pool integer?
---@field not_in_default_perk_pool boolean?
---@field not_progress boolean? Hardmod's custom field, hides the perk from the progress menu
---@field holy_mountain_exclusive boolean? Hardmod's custom field
---@field func fun(perk_entity: entity_id, picked_by_entity: entity_id, item_name: string)?
---@field func_remove fun(picked_by_entity: entity_id)?

---@type Perk[]
perk_list = {}

STACKABLE_YES = true ---@deprecated Please use booleans like a normal person
STACKABLE_NO = false ---@deprecated Please use booleans like a normal person

---@type fun(x: number, y: number, dont_remove_others_?: boolean): entity_id
perk_spawn_random = nil

---@type fun(perk_id: string): string
get_perk_picked_flag_name = nil

---@type fun(player: entity_id, amount: integer, set_to_this_value?: integer)
add_halo_level = nil

----------------------
--- Status Effects ---
----------------------

---@class StatusEffect
---@field id string
---@field ui_name string
---@field ui_description string
---@field ui_icon string
---@field protects_from_fire boolean?
---@field remove_cells_that_cause_when_activated boolean?
---@field is_harmful boolean?
---@field effect_permanent boolean?
---@field min_threshold_normalized number?
---@field ui_timer_offset_normalized number?
---@field extra_status_00 string?
---@field effect_entity string

---@type StatusEffect[]
status_effects = {}

-----------------
--- Utilities ---
-----------------

---@alias Rnd { x: number, y: number }
---@type fun(x: number, y: number): Rnd
random_create = nil

---@type fun(value: number, min: number, max: number): number
clamp = nil

---@type fun(x1: number, y1: number, x2: number, y2: number): number
get_distance = nil

---@type fun(x1: number, y1: number, x2: number, y2: number, weight: number): number, number
vec_lerp = nil

---@type fun(x: number, y: number): number, number
vec_normalize = nil

---@type fun(eid: entity_id, name: string): component_id
get_variable_storage_component = nil

---@type fun(eid: entity_id, amount: number)
heal_entity = nil

---@type fun(x: number, y: number): string
temple_pos_to_id = nil

---@type fun(x: number, y: number, flag: string)
temple_set_active_flag = nil

---@type fun(x: number, y: number)
temple_spawn_guardian = nil

GUI_OPTION = {
	None=0,IsDraggable=1,NonInteractive=2,AlwaysClickable=3,ClickCancelsDoubleClick=4,IgnoreContainer=5,NoPositionTween=6,ForceFocusable=7,HandleDoubleClickAsClick=8,GamepadDefaultWidget=9,Layout_InsertOutsideLeft=10,Layout_InsertOutsideRight=11,Layout_InsertOutsideAbove=12,Layout_ForceCalculate=13,Layout_NextSameLine=14,Layout_NoLayouting=15,Align_HorizontalCenter=16,Align_Left=17,FocusSnapToRightEdge=18,NoPixelSnapY=19,DrawAlwaysVisible=20,DrawNoHoverAnimation=21,DrawWobble=22,DrawFadeIn=23,DrawScaleIn=24,DrawWaveAnimateOpacity=25,DrawSemiTransparent=26,DrawActiveWidgetCursorOnBothSides=27,DrawActiveWidgetCursorOff=28,TextRichRendering=29,NoSound=47,Hack_ForceClick=48,Hack_AllowDuplicateIds=49,ScrollContainer_Smooth=50,IsExtraDraggable=51,_SnapToCenter=62,Disabled=63
}

------------------------
--- Director Helpers ---
------------------------

---@type fun(what: table, x: number, y: number, rand_x?: number, rand_y?: number)
spawn = nil
spawn2 = spawn

---@type fun(what: table, x: number, y: number, rand_x?: number, rand_y?: number, entities_to_randomize: string[])
spawn_with_limited_random = nil

---@type fun(what: table, x: number, y: number)
load_random_pixel_scene = nil

---@type fun(what: table, x: number, y: number)
load_random_background_sprite = nil

-------------------
--- Biome stuff ---
-------------------

---@class BiomeModifier
---@field id string
---@field ui_name string? Hardmod's custom field
---@field ui_description string
---@field ui_decoration_file string?
---@field requires_flag string?
---@field probability number
---@field does_not_apply_to_biome string[]?
---@field apply_only_to_biome string[]?
---@field whitelist_biomes table<string, boolean>? Hardmod's custom field
---@field blacklist_biomes table<string, boolean>? Hardmod's custom field
---@field action fun(biome_name: string, biome_filename: string)?
---@field inject_spawn_action fun(biome_name: string)?

---@type BiomeModifier[]
biome_modifiers = {}

---@type fun()
init_biome_modifiers = nil

---@type fun(list: any[], probability_mult: number, new_spawn: any)
inject_spawn = nil

---@type fun(x: number, y: number, cheap?: boolean, biomeid?: number, is_stealable?: boolean)
generate_shop_item = nil

---@type fun(x: number, y: number)
spawn_heart = nil

--------------------
--- Mod Settings ---
--------------------

MOD_SETTING_SCOPE_NEW_GAME = 0
MOD_SETTING_SCOPE_RUNTIME_RESTART = 1
MOD_SETTING_SCOPE_RUNTIME = 2
MOD_SETTING_SCOPE_ONLY_SET_DEFAULT = 3

---@type fun(mod_id: string, settings: any, gui: userdata, in_main_menu: boolean)
mod_settings_gui = nil

---@type fun(mod_id: string, settings: any, init_scope: integer)
mod_settings_update = nil

---@type fun(mod_id: string): integer
mod_settings_get_version = nil

---@type fun(mod_id: string, settings: any): integer
mod_settings_gui_count = nil
