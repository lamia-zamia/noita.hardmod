local new_spells = {}
local spell_patches = {}
local edit_spell_hooks = {}

dofile_once("data/scripts/gun/gun_enums.lua")

local function add_patches(path)
	if not ModDoesFileExist(path) then
		error("File does not exist: "..path)
		return
	end

	local hooks = dofile_once(path)
	for _,new_spell in ipairs(hooks.new_spells or {}) do
		new_spells[#new_spells+1] = new_spell
	end
	for spell_id,spell_patch in pairs(hooks.spell_patches or {}) do
		spell_patches[spell_id] = spell_patches[spell_id] or {}
		for key, value in pairs(spell_patch) do
			local curr_value = spell_patches[spell_id][key]
			if curr_value ~= nil and value ~= curr_value then print(('[%s] COLLISION at "%s": %s -> %s'):format(spell_id, key, curr_value, value)) end
			spell_patches[spell_id][key] = value
		end
	end
	if hooks.edit_spell then
		edit_spell_hooks[#edit_spell_hooks+1] = hooks.edit_spell
	end
	if hooks.func then
		hooks.func()
	end
end

local function edit_spells(spell)
	for _,func in ipairs(edit_spell_hooks) do
		func(spell)
	end
end

for _,path in ipairs(ModLuaFileGetAppends("mods/noita.hardmod/files/__spell_appends.lua")) do
	local succ, res = pcall(add_patches, path)
	if not succ then
		print("[Hardmod] Patching spells from "..path.." failed: "..tostring(res))
	end
end

local num_spells = #actions
for i,spell in ipairs(new_spells) do
	actions[num_spells+i] = spell
end

for _,spell in ipairs(actions) do
	if spell_patches[spell.id] then
		for key, value in pairs(spell_patches[spell.id]) do
			spell[key] = value
		end
	end

	local succ, res = pcall(edit_spells, spell)
	if not succ then
		print("[Hardmod] Patching spell "..spell.id.." failed: "..tostring(res))
	end
end
