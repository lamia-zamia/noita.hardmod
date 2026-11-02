local new_perks = {}
local perk_patches = {}
local edit_perk_hooks = {}


for _,path in ipairs(ModLuaFileGetAppends("mods/noita.hardmod/files/__perk_appends.lua")) do
	local hooks = dofile_once(path)
	for _,new_perk in ipairs(hooks.new_perks or {}) do
		new_perks[#new_perks+1] = new_perk
	end
	for perk_id,perk_patch in pairs(hooks.perk_patches or {}) do
		perk_patches[perk_id] = perk_patches[perk_id] or {}
		for key, value in pairs(perk_patch) do
			if perk_patches[perk_id][key] then print(('[%s] COLLISION at "%s": %s -> %s'):format(perk_id, key, perk_patches[perk_id][key], value)) end
			perk_patches[perk_id][key] = value
		end
	end
	if hooks.edit_perk then
		edit_perk_hooks[#edit_perk_hooks+1] = hooks.edit_perk
	end
	if hooks.func then
		hooks.func()
	end
end


---@diagnostic disable-next-line: lowercase-global
perk_list = perk_list

local num_perks = #perk_list
for i,perk in ipairs(new_perks) do
	perk_list[num_perks+i] = perk
end

for _,perk in ipairs(perk_list) do
	if perk_patches[perk.id] then
		for key, value in pairs(perk_patches[perk.id]) do
			perk[key] = value
		end
	end

	for _,func in ipairs(edit_perk_hooks) do
		func(perk)
	end
	--AddFlagPersistent("perk_picked_"..perk.id:lower())
end

