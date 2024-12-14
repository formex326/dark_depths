---@type mod_calllbacks
local M = {}

---@type brain_function
_G["dark_depths.ray_brain"] = function(body)
    -- get our custom values
    local target_id = body.values[1]
    local aggro_timer = body.values[2] -- timer for giving up on its target
    local target_x = body.values[3]
    local target_y = body.values[4]
    local health = body.health
    local max_health = body.max_health

    local brain = {}
    local closest_enemy = nil
    local closest_enemy_id = 0
    local closest_dist = 300 -- set the aggro range to 200, the max is 1000

    local ally_avoid_range = 100
    local wall_avoid_range = 20

    if target_id == 0 then
        aggro_timer = 0
    end



        function check_dead(x, y)
            local cell_id = get_body_cell_id(body.id, x, y, false)
            local info = get_cell_info(cell_id)
            if info then
                if info.health >= 1 then
                    return true
                end
            end
        end

    aggro_timer = aggro_timer - 1;
    if aggro_timer <= 0 then
        target_id = 0 -- forget about current target if we haven't seen it for a while

        -- movement while not aggro'd
        brain.movement = 1.0
          if check_dead(0,0) then
		brain.ability = true
	  end
    elseif target_id ~= 0 then
        ally_avoid_range = 20
        wall_avoid_range = 5
        local bodies = get_visible_bodies(body.id, 800, true)
	local closest_enemy, closest_dist = nil, 800
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist then
			closest_enemy = b
			closest_enemy_id = b.id
			closest_dist = b.dist
		end
        end
	brain.grab_weight = 1
      	brain.grab_target_x = target_x
      	brain.grab_target_y = target_y
        if health > max_health * 0.8 then
	  move_towards(body, brain, target_x, target_y)
	else
            avoid_body(body, brain, closest_enemy, 800)
            brain.movement = 3
            if closest_enemy.dist > 100 and check_dead(0,0) then
                brain.ability = true
            end
	end
    end
    closest_enemy = nil
    closest_enemy_id = 0
    closest_dist = 500

    local DEAGGRO_TIME = 10*120 -- 10 seconds

    local bodies = get_visible_bodies(body.id, 200, true)
    for i, b in ipairs(bodies) do
        if b.team == body.team then
            -- avoid allies
            avoid_body(body, brain, b, ally_avoid_range)
        elseif b.id == target_id then
            -- if the target is visible, then update the target position and refresh aggro_timer
            target_x = b.cost_center_x
            target_y = b.cost_center_y
            aggro_timer = DEAGGRO_TIME
        elseif b.dist < closest_dist then
            closest_enemy = b
            closest_enemy_id = b.id
            closest_dist = b.dist
        end
    end

    if target_id == 0 and closest_enemy then
        target_x = closest_enemy.cost_center_x
        target_y = closest_enemy.cost_center_y
        target_id = closest_enemy_id
        aggro_timer = DEAGGRO_TIME
    end

    avoid_walls(body, brain, wall_avoid_range)

    -- update our custom values
    brain.values = {}
    brain.values[1] = target_id
    brain.values[2] = aggro_timer
    brain.values[3] = target_x
    brain.values[4] = target_y

    return brain
end

---@type brain_function
_G["dark_depths.squid_brain"] = function(body)
    -- get our custom values
    local target_id = body.values[1]
    local aggro_timer = body.values[2] -- timer for giving up on its target
    local target_x = body.values[3]
    local target_y = body.values[4]
    local health = body.health
    local max_health = body.max_health

    local brain = {}
    local closest_enemy = nil
    local closest_enemy_id = 0
    local closest_dist = 800 -- set the aggro range to 200, the max is 1000

    local ally_avoid_range = 100
    local wall_avoid_range = 20

    if target_id == 0 then
        aggro_timer = 0
    end

        function check_dead(x, y)
            local cell_id = get_body_cell_id(body.id, x, y, false)
            local info = get_cell_info(cell_id)
            if info then
                if info.health >= 1 then
                    return true
                end
            end
        end

    aggro_timer = aggro_timer - 1;
    if aggro_timer <= 0 then
        target_id = 0 -- forget about current target if we haven't seen it for a while

        -- movement while not aggro'd
        brain.movement = 1.0
        brain.rotation = 0.5*rand_normal() + math.sin(0.15*body.age) --random turning + a wiggle
    elseif target_id ~= 0 then
        ally_avoid_range = 20
        wall_avoid_range = 5
        local bodies = get_visible_bodies(body.id, 800, true)
	local closest_enemy, closest_dist = nil, 800
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist then
			closest_enemy = b
			closest_enemy_id = b.id
			closest_dist = b.dist
		end
        end

        if health > max_health * 0.7 then
	  move_towards(body, brain, target_x, target_y)
          if check_dead(0,0) then
	    brain.grab_weight = 1
      	    brain.grab_target_x = target_x
      	    brain.grab_target_y = target_y
	  end
	elseif closest_enemy.dist < 400 then
            avoid_body(body, brain, closest_enemy, 800)
		brain.ability = true
            brain.movement = 3
	end
    end
    closest_enemy = nil
    closest_enemy_id = 0
    closest_dist = 500

    local DEAGGRO_TIME = 10*120 -- 10 seconds

    local bodies = get_visible_bodies(body.id, 200, true)
    for i, b in ipairs(bodies) do
        if b.team == body.team then
            -- avoid allies
            avoid_body(body, brain, b, ally_avoid_range)
        elseif b.id == target_id then
            -- if the target is visible, then update the target position and refresh aggro_timer
            target_x = b.cost_center_x
            target_y = b.cost_center_y
            aggro_timer = DEAGGRO_TIME
        elseif b.dist < closest_dist then
            closest_enemy = b
            closest_enemy_id = b.id
            closest_dist = b.dist
        end
    end

    if target_id == 0 and closest_enemy then
        target_x = closest_enemy.cost_center_x
        target_y = closest_enemy.cost_center_y
        target_id = closest_enemy_id
        aggro_timer = DEAGGRO_TIME
    end

    avoid_walls(body, brain, wall_avoid_range)

    -- update our custom values
    brain.values = {}
    brain.values[1] = target_id
    brain.values[2] = aggro_timer
    brain.values[3] = target_x
    brain.values[4] = target_y

    return brain
end

---@type brain_function
_G["dark_depths.worm_brain"] = function(body)
	---@type brain
    local health = body.health
    local max_health = body.max_health
	local brain = {}
        local closest_dist = 500
        local bodies = get_visible_bodies(body.id, 500, true)
	local closest_enemy, closest_dist = nil, 500
	brain.movement = 3
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist and health < max_health * 0.98 then
                        avoid_body(body, brain, b, 500)
			closest_dist = b.dist
		end
        end
	return brain
end

---@type brain_function
_G["dark_depths.ghostplant_brain"] = function(body)
	---@type brain
	local brain = {}
        local closest_dist = 800
        local bodies = get_visible_bodies(body.id, 800, true)
	local closest_enemy, closest_dist = nil, 800
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist then
            		target_x = b.cost_center_x
            		target_y = b.cost_center_y
   		        brain.grab_weight = 1
        		brain.grab_target_x = target_x
        		brain.grab_target_y = target_y
			closest_dist = b.dist
		end
        end
	return brain
end

---@type brain_function
_G["dark_depths.glowbug_brain"] = function(body)
    -- get our custom values
    local target_id = body.values[1]
    local aggro_timer = body.values[2] -- timer for giving up on its target
    local target_x = body.values[3]
    local target_y = body.values[4]
    local health = body.health
    local max_health = body.max_health

    local brain = {}

    local closest_enemy = nil
    local closest_enemy_id = 0
    local closest_dist = 900 -- set the aggro range to 900, the max is 1000

    local ally_avoid_range = 100
    local wall_avoid_range = 20

    if target_id == 0 then
        aggro_timer = 0
    end

    aggro_timer = aggro_timer - 1;
    if aggro_timer <= 0 then
        target_id = 0 -- forget about current target if we haven't seen it for a while

        -- movement while not aggro'd
        brain.movement = 1.0
        brain.rotation = 0.5*rand_normal() + math.sin(0.15*body.age) --random turning + a wiggle
    elseif target_id ~= 0 then
        ally_avoid_range = 20
        wall_avoid_range = 5
        local bodies = get_visible_bodies(body.id, 800, true)
	local closest_enemy, closest_dist = nil, 800
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist then
			closest_enemy = b
			closest_enemy_id = b.id
			closest_dist = b.dist
		end
        end
        move_towards(body, brain, target_x, target_y)
        brain.grab_weight = 1
        brain.ability = true
        brain.grab_target_x = target_x
        brain.grab_target_y = target_y
    end
    closest_enemy = nil
    closest_enemy_id = 0
    closest_dist = 900
    local DEAGGRO_TIME = 5*120 -- 5 seconds

    local bodies = get_visible_bodies(body.id, 200, true)
    for i, b in ipairs(bodies) do
        if b.team == body.team then
            -- avoid allies
            avoid_body(body, brain, b, ally_avoid_range)
        elseif b.id == target_id then
            -- if the target is visible, then update the target position and refresh aggro_timer
            target_x = b.cost_center_x
            target_y = b.cost_center_y
			brain.ability = true
            aggro_timer = DEAGGRO_TIME
        elseif b.dist < closest_dist then
            closest_enemy = b
            closest_enemy_id = b.id
            closest_dist = b.dist
        end
    end

    if target_id == 0 and closest_enemy then
        target_x = closest_enemy.cost_center_x
        target_y = closest_enemy.cost_center_y
        target_id = closest_enemy_id
        aggro_timer = DEAGGRO_TIME
    end

    avoid_walls(body, brain, wall_avoid_range)

    -- update our custom values
    brain.values = {}
    brain.values[1] = target_id
    brain.values[2] = aggro_timer
    brain.values[3] = target_x
    brain.values[4] = target_y

    return brain
end


---@type brain_function
_G["dark_depths.phantom_brain"] = function(body)
    -- get our custom values
    local target_id = body.values[1]
    local aggro_timer = body.values[2] -- timer for giving up on its target
    local target_x = body.values[3]
    local target_y = body.values[4]
    local health = body.health
    local max_health = body.max_health

    local brain = {}
    local closest_enemy = nil
    local closest_enemy_id = 0
    local closest_dist = 800 -- set the aggro range to 200, the max is 1000

    local ally_avoid_range = 100
    local wall_avoid_range = 20

    if target_id == 0 then
        aggro_timer = 0
    end

    aggro_timer = aggro_timer - 1;
    if aggro_timer <= 0 then
        target_id = 0 -- forget about current target if we haven't seen it for a while

        -- movement while not aggro'd
        brain.movement = 1.0
        brain.rotation = 0.5*rand_normal() + math.sin(0.15*body.age) --random turning + a wiggle
    elseif target_id ~= 0 then
        ally_avoid_range = 20
        wall_avoid_range = 5
	brain.ability = true
        local bodies = get_visible_bodies(body.id, 800, true)
	local closest_enemy, closest_dist = nil, 800
	for _, b in ipairs(bodies) do
		if b.team ~= body.team and b.dist < closest_dist then
			closest_enemy = b
			closest_enemy_id = b.id
			closest_dist = b.dist
		end
        end
        if health > max_health * 0.6 and closest_enemy.dist > 2 then
            move_towards(body, brain, target_x, target_y)
	else
            avoid_body(body, brain, closest_enemy, 800)
            brain.movement = 3
	end
    end
    closest_enemy = nil
    closest_enemy_id = 0
    closest_dist = 500

    local DEAGGRO_TIME = 10*120 -- 10 seconds

    local bodies = get_visible_bodies(body.id, 200, true)
    for i, b in ipairs(bodies) do
        if b.team == body.team then
            -- avoid allies
            avoid_body(body, brain, b, ally_avoid_range)
        elseif b.id == target_id then
            -- if the target is visible, then update the target position and refresh aggro_timer
            target_x = b.cost_center_x
            target_y = b.cost_center_y
            if b.dist > 40 then
                brain.ability = true
            elseif isWithinSector(body, b, math.pi) then
                brain.ability = false
            else
                brain.ability = true
            end
            aggro_timer = DEAGGRO_TIME
        elseif b.dist < closest_dist then
            closest_enemy = b
            closest_enemy_id = b.id
            closest_dist = b.dist
        end
    end

    if target_id == 0 and closest_enemy then
        target_x = closest_enemy.cost_center_x
        target_y = closest_enemy.cost_center_y
        target_id = closest_enemy_id
        aggro_timer = DEAGGRO_TIME
    end

    avoid_walls(body, brain, wall_avoid_range)

    -- update our custom values
    brain.values = {}
    brain.values[1] = target_id
    brain.values[2] = aggro_timer
    brain.values[3] = target_x
    brain.values[4] = target_y

    return brain
end

---@type spawn_function
_G["dark_depths.explosion_resist"] = function(body_id, x, y)
	give_mutation(body_id, MUT_EXPLOSIVE_RESISTANCE)
	return { nil, nil, x, y } -- this determines spawn extra info
end

-- post hook is for defining creatures
function M.post(api, config)
        local spawn_rates = config.spawn_rates or 1
	-- we shadow the creature_list function to call our additional code after it
	local old_creature_list = creature_list
	creature_list = function(...)
		-- call the original
		local r = { old_creature_list(...) }

		-- register our creatures
		register_creature(
			api.acquire_id("dark_depths.glowbug"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/glowbug.bod",
			"dark_depths.glowbug_brain"
		)
		register_creature(
			api.acquire_id("dark_depths.phantom"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/phantom.bod",
			"dark_depths.phantom_brain",
			"dark_depths.explosion_resist"
		)
		register_creature(
			api.acquire_id("dark_depths.squid"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/squid.bod",
			"dark_depths.squid_brain",
			"dark_depths.explosion_resist"
		)
		register_creature(
			api.acquire_id("dark_depths.squid_baby"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/squid_baby.bod",
			"dark_depths.squid_brain",
			"dark_depths.explosion_resist"
		)
		register_creature(
			api.acquire_id("dark_depths.ray"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/ray.bod",
			"dark_depths.ray_brain",
			"dark_depths.explosion_resist"
		)
		register_creature(
			api.acquire_id("dark_depths.ghost_plant"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/ghostplant.bod",
			"dark_depths.ghostplant_brain",
			"dark_depths.explosion_resist"
		)
		register_creature(
			api.acquire_id("dark_depths.worm"),
			"data/scripts/lua_mods/mods/dark_depths/bodies/worm.bod",
			"dark_depths.worm_brain"
		)
		-- return the result of the original, not strictly neccesary here but useful in some situations
		return unpack(r)
	end

	-- shadow init_biomes function to call our stuff afterwards
	local old_init_biomes = init_biomes
	init_biomes = function(...)
		local r = { old_init_biomes(...) }
		-- add our creatures to the starting biome, if spawn_rates are too high you will start to see issues where only some creatures can spawn
		-- to fix this make sure the sum isn't too high, i will perhaps add a prehook for compat with this in future
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.glowbug"), 0.017*spawn_rates, 25)
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.phantom"), 0.017*spawn_rates, 25)
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.squid"), 0.001*spawn_rates, 2000)
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.squid_baby"), 0.02*spawn_rates, 20)
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.ray"), 0.015*spawn_rates, 30)
		add_creature_spawn_chance("DARK", api.acquire_id("dark_depths.worm"), 0.03*spawn_rates, 10)
		add_plant_spawn_chance("DARK", api.acquire_id("dark_depths.ghost_plant"), 0.02*spawn_rates, 20)
		return unpack(r)
	end
end

return M