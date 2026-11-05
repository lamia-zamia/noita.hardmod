
dofile_once("data/scripts/lib/utilities.lua") --Tired Sinning
--Hello yes thank you Graham for letting me "borrow" this :) - Spoop
--Hello Spoop and Graham, thankyou for letting me "permanently borrow" this for Felcesis - Conga Lyne (This implementation is way easier to port over than the entire dialogue mod)

local entity_id = GetUpdatedEntityID()
local host_id = EntityGetRootEntity(entity_id)
local dialogue_vsc_comp = EntityGetComponentIncludingDisabled(entity_id,"VariableStorageComponent")[3]
local forced_speak = ComponentGetValue2(dialogue_vsc_comp,"value_string")
local last_idle_talk = ComponentGetValue2(dialogue_vsc_comp,"value_int")
local idle_talk_cd = 1200
local x, y = EntityGetTransform(entity_id)
local cam_x, cam_y, cam_w, cam_h = GameGetCameraBounds()
local radius = math.floor((cam_w / 4) * 3)

-- Specific scenario for the Sheep Ending
--Conga: Might be funny if he made fun of your death
--"You crawl into my tomb, crack my coffin open, rend MY flesh apart, but you die to a purple freak because he turned you into a sheep? You're pathetic"
--Spoop: Maaayyybee...
--Conga: I still think this would be funny
local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)
math.randomseed(x+y)
SetRandomSeed(x + GameGetFrameNum(), y + 1394)
-- ctrl+f("Mr. Felcesis") replace("Mr. Felcesis")
-- how talkative Mr. Felcesis is
local rate = 10
-- how big Mr. Felcesis's text is
local size_x = 0.8
local size_y = 0.8
-- how hard to hear Mr. Felcesis is
local alpha = 0.8
-- what tone of voice Mr. Felcesis uses when speaking
local tone = "norm"
-- "norm" is normal speech
-- "power" is when he's being intimidating or imposing
-- "gossip" is when he makes an off handed comment or something
-- ^ one of the sounds sort of sound like a laugh so you could also use it for when he's joking
-- "quiet" is when he's trying to be quiet, only really used in the introduction
-- "yell" is when he's screaming at you, only really used for mountain altar (and now destroying the stone :) )
-- "long" is when there's a lot of dialogue, mostly when informing/scolding you of something
-- "pained" is when he's dying, only one use scenario
-- will default to "norm" if nothing is given

-- used for checking the number of the current message more easily
local num = 0

function GetPlayer()
  local tags = {"player_unit", "polymorphed_player", "polymorphed_cessation"}
	for tag=1,#tags do
		local player = EntityGetWithTag(tags[tag])
		if #player > 0 then
			return player[1]
		end
	end
  return nil
end

--Move functions outside of checks so they can be accessed from the file globally*
function Speak(entity, text, pool)

    --Prevents Felcesis from inturrupting himself (speaking again if he's already speaking)
    local textComponent = EntityGetFirstComponentIncludingDisabled(entity_id, "SpriteComponent", "graham_speech_text")
    if textComponent then return end

    local old_text = text
    local x, y = EntityGetTransform(entity_id)
    SetRandomSeed(entity_id + x + 2352, GameGetFrameNum() - y + 24806)

    local hitbox_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "HitboxComponent") or 0
    local hitbox_height_y = 0
    if hitbox_comp > 0 then 
        hitbox_height_y = ComponentGetValue2(hitbox_comp, "aabb_min_y")
    end

    local offset_y = 40 + (hitbox_height_y)

    ---- All dialogue handling should go above this point ----

    -- here lies some terrible width code that has since been replaced
    -- thank you to Evaisa (and Copi) for making this not trash
    local gui = GuiCreate()
    GuiStartFrame(gui)
    local offset_x = GuiGetTextDimensions( gui, text, size_x ) * 0.625
    GuiDestroy(gui)

    EntityAddTag(entity, "graham_speaking")
    EntityAddComponent2(entity, "SpriteComponent", {
        _tags = "enabled_in_world, enabled_in_hand, enabled_in_inventory, graham_speech_text",    --Conga: This could be tag optimised... Spoop: sShhuhshshshush...
        image_file = "mods/noita.hardmod/files/modules/phantom_nemesis/files/fonts/font_felcesis.xml",
        emissive = true,
        is_text_sprite = true,
        offset_x = offset_x,
        offset_y = offset_y,
        alpha = alpha,
        update_transform = true,
        update_transform_rotation = false,
        text = text,
        has_special_scale = true,
        special_scale_x = size_x,
        special_scale_y = size_y,
        z_index = -9000,
        never_ragdollify_on_death = true
    })

    local luacomp = EntityGetFirstComponentIncludingDisabled(entity, "LuaComponent", "graham_speech_quiet")
    if luacomp then EntityRemoveComponent(entity, luacomp) end

    EntityAddComponent2(entity, "LuaComponent", {
        _tags= "enabled_in_world, enabled_in_hand, enabled_in_inventory, graham_speech_quiet",
        execute_every_n_frame = 120 + (#text * rate), --Starting at 2 seconds, every letter adds 10 frames to the dialogue duration.
        script_source_file="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/dialogue/phantom_dialogue_quiet.lua"
    })
end

local events = {
    {
        trigger = function()
            if forced_speak:len() > 0 then
                rate = 2
                alpha = 0.7
                local d_opts = {forced_speak}
                local dialogue = d_opts[math.random(1,#d_opts)]
                tone = "power"
                ComponentSetValue2(dialogue_vsc_comp,"value_string","")
                return true, dialogue
            end
            return false
        end
    },
    {
        trigger = function()
            if GetPlayer() == nil and GameGetFrameNum() > last_idle_talk + (idle_talk_cd * 0.5) then
                rate = 2
                alpha = 0.7
                local d_opts = {"Good riddance","We can rest easy now","It's finally over","We can now cease to be","My purpose is fulfilled"}
                local dialogue = d_opts[math.random(1,#d_opts)]
                tone = "gossip"
                ComponentSetValue2(dialogue_vsc_comp,"value_int",GameGetFrameNum())
                return true, dialogue
            end
            return false
        end
    },
    {
        trigger = function()
            if GameGetFrameNum() > last_idle_talk + idle_talk_cd then
                rate = 2
                alpha = 0.7
                local d_opts = {"You can't escape your sins","I SEE YOU","Your death will not be mourned","You can pray but you won't find forgiveness","Winter is coming for you","I will make you inanimate","Hell won't be enough for you!","Your end has come"}
                local dialogue = d_opts[math.random(1,#d_opts)]
                tone = "norm"
                if dialogue == "I SEE YOU" then
                    tone = "power"
                end
                ComponentSetValue2(dialogue_vsc_comp,"value_int",GameGetFrameNum())
                return true, dialogue
            end
            return false
        end
    }
}

for k=1,#events do
    if events[k].trigger() == true and EntityHasTag(entity_id,"graham_speaking") == false then
        local bool, dialogue = events[k].trigger()
        if bool == true then
            Speak(entity_id, dialogue)
	        GamePlaySound( "mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/phantom_audio.bank", "felcesis/phantom_talk", x, y );
            break
        end
    end
end
