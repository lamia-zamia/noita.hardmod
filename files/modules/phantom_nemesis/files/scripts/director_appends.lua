dofile_once("mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/miniboss_creator.lua")

function is_valid_enemy( file )
	local test = "data/entities/animals/"

	if ( string.sub( file, 1, #test ) == test ) then
		return true
	end

	return false
end

function entity_load_camera_bound(entity_data, x, y, rand_x, rand_y)
	-- if true then return nil end  -- enable 2 disable spawns
	if rand_x == nil then rand_x = 4 end
	if rand_y == nil then rand_y = 4 end
    local miniboss = false
    math.randomseed(x + y)
    local rng = math.random(1,20)
    if rng == 1 then miniboss = true end

	-- load groups
	if( entity_data.entities ~= nil ) then
		for j,ev in ipairs(entity_data.entities) do
			if( type( ev ) == 'table' ) then
				local count = 1
				if( ev.min_count ~= nil ) then
					count = ev.min_count
					if( ev.max_count ~= nil ) then
						count = ProceduralRandom( x+j, y, ev.min_count, ev.max_count )
					end
				end

				for i = 1,count do
					local pos_x = x + ProceduralRandom(x+j, y+i, -rand_x, rand_x)
					local pos_y = y + ProceduralRandom(x+j, y+i, -rand_y, rand_y)
					if( ev.offset_y ~= nil ) then pos_y = pos_y + ev.offset_y end
					if( ev.offset_x ~= nil ) then pos_x = pos_x + ev.offset_x end
                    if ev.entity == nil then goto skip end

                    if miniboss == true then
                        local eid = EntityLoad( ev.entity, pos_x, pos_y)
                        ChooseMinibossLevel(eid,pos_x,pos_y)
                    else
                        EntityLoadCameraBound( ev.entity, pos_x, pos_y )
                    end
				end
			else
				if( ev ~= nil ) then
					local pos_x = x + ProceduralRandom(x+j, y, -rand_x, rand_x)
					local pos_y = y + ProceduralRandom(x+j, y, -rand_y, rand_y)
					if( ev.offset_y ~= nil ) then pos_y = pos_y + ev.offset_y end
					if( ev.offset_x ~= nil ) then pos_x = pos_x + ev.offset_x end
                    if ev.entity == nil then goto skip end

                    if miniboss == true then
                        local eid = EntityLoad( ev.entity, pos_x, pos_y)
                        ChooseMinibossLevel(eid,pos_x,pos_y)
                    else
                        EntityLoadCameraBound( ev.entity, pos_x, pos_y )
                    end
				end
			end
                ::skip::
		end
	end

	if( entity_data.entity == nil or  entity_data.entity == '' ) then
		return 0
	end

	local how_many = ProceduralRandom(x,y,entity_data.min_count,entity_data.max_count)
	if( how_many <= 0 ) then
		return 0
	end
	
	local pos_x = x
	local pos_y = y

	for i = 1,how_many do
		pos_x = x + ProceduralRandom(x+i,y,-rand_x, rand_x)
		pos_y = y + ProceduralRandom(x+i,y,-rand_y, rand_y)
		if( entity_data.offset_y ~= nil ) then pos_y = pos_y + entity_data.offset_y end
		if( entity_data.offset_x ~= nil ) then pos_x = pos_x + entity_data.offset_x end

        if miniboss == true then
            local eid = EntityLoad( entity_data.entity, pos_x, pos_y)
            ChooseMinibossLevel(eid,pos_x,pos_y)
            break
        else
            EntityLoadCameraBound( entity_data.entity, pos_x, pos_y )
        end
	end

	return 1
end
