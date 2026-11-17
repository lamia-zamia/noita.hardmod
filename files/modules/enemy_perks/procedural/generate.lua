local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local dir = utils.module_dir.."enemy_perks/"

local callback_data = dofile_once(dir.."procedural/data.lua")

local generated_dir = dir.."generated/"
local procedural_dir = dir.."procedural/"
for _,callback in ipairs(callback_data.callbacks) do
    local id = callback.id

    local templates = {
        "template_shot.lua",
        "template_shot.xml",
        "template_hit.xml",
        "template_explode.lua"
    }
    for _,template in ipairs(templates) do
        local file = ModTextFileGetContent(procedural_dir..template)

        for key, value in pairs(callback) do
            file = file:gsub(utils.escape('%'..key:upper()..'%'), value)
        end

        ModTextFileSetContent(table.concat({generated_dir,id,template:sub(9)}), file)
    end
end
