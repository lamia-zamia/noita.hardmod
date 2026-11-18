local projPool = {}

local projPoolVanilla = {
    "orb_cursed",
    "orb_dark",
    "orb_expanding",
    "orb_hearty",
    "orb_homing",
    "orb_neutral",
    "orb_swapper",
    "orb_twitchy",
    "orb_weaken",
    "orb_wither",
    "thunderball",
}

--Adds vanilla files to projectile pool
for k=1,#projPoolVanilla do
    table.insert(projPool, table.concat({"data/entities/projectiles/",projPoolVanilla[k],".xml"}))
end

--Functions for corruption update file to pick a random file
function pickrandomspell(seed_x, seed_y)
    SetRandomSeed(seed_x + seed_y, seed_x * seed_y)
    local projFile = projPool[Random(1, #projPool)]
    return projFile
end
