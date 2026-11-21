local creatures = {}


for _,path in ipairs(ModLuaFileGetAppends("mods/noita.hardmod/files/__creatures.lua")) do
    dofile_once(path)(creatures)
end