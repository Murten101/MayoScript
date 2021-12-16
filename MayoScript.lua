util.require_no_lag('natives-1627063482') --da natives
require "lib.murtensUtils" --my util classes

--[[      SETUP        ]]

--#region "classes"

local properties = b_properties.new()

local common_funcs = b_common_funcs.new()

local vectors = b_vectors.new()

local colour = b_colour.new()

local drawing_funcs = b_drawing_funcs.new()

local input = b_input.new()

--#endregion

--#region updated values
local player_ped_id
local delta_time
util.create_tick_handler(function ()
    player_ped_id = PLAYER.PLAYER_PED_ID()
    delta_time = MISC.GET_FRAME_TIME()
end)
--#endregion

--[[      LISTS        ]]

--#region sub menus
local self_list = menu.list(menu.my_root(), "self")
    local deadline_list = menu.list(self_list, "deadline")

local vehicles_list = menu.list(menu.my_root(), "vehicles")
    local better_heli_list = menu.list(vehicles_list, "better heli")
    local shitty_gps_list = menu.list(vehicles_list, "shitty gps")

local arcade_list = menu.list(menu.my_root(), "arcade")
    local stacker_list = menu.list(arcade_list, "stacker")
--#endregion

--[[       SELF        ]]

--#region deadline
local colour_a = colour.magenta()
local colour_b = colour.magenta()

local dashed = false

local wave = false
local veloBased = false
local waveAmp = 0.2

local deadline_settings_list = menu.list(deadline_list, "Settings")

menu.toggle(deadline_settings_list, "dash", {"deadlinedash"}, "make the line dashed", function (value)
    dashed = value
end)
local wave_settings = menu.list(deadline_settings_list, "wave")
menu.toggle(wave_settings, "wave", {"deadlinewave"}, "make the line wave", function (value)
    wave = value
end)
menu.toggle(wave_settings, "velocticy based", {"deadlinewaveVelo"}, "make the line wave be affected by your speed", function (value)
    veloBased = value
end)
menu.slider(wave_settings, "amplitude", {"deadlinewaveAmplitude"}, "aplitude of the wave", 0, 10, 2, 1, function (value)
    waveAmp = value * 0.1
end)

local deadline_colour_a_settings = menu.list(deadline_settings_list, "Colour A")

--[[------------------------------------------------------------------------]]
local Stripe_a = false
menu.toggle(deadline_colour_a_settings, "stripe", {"deadlineStripeA"}, "make the line striped", function (value)
        Stripe_a = value
        local timer = 10
        local new_colour = colour.new(255, 255, 255, 255)
        util.create_tick_handler(function()
            if timer == 10 then
                local new_value = new_colour.r == 255 and 0 or 255
                new_colour = colour.new(new_value, new_value, new_value, 255)
                timer = 0
            end
            timer = timer + 1

            colour_a = new_colour
            return Stripe_a
        end)
end, false)
deadline_colour_a_id = menu.colour(deadline_colour_a_settings, "colour a", {"deadlineColourA"}, "colour a of the trail", {r = 1, g = 0,b = 1, a = 1}, true, function (new_colour)
        colour_a = colour.to_rage(new_colour)
end)
menu.rainbow(deadline_colour_a_id)
--[[------------------------------------------------------------------------]]
local deadline_colour_b_settings = menu.list(deadline_settings_list, "Colour B")
local Stripe_b = false
menu.toggle(deadline_colour_b_settings, "stripe", {"deadlineStripeB"}, "make the line striped", function (value)
        Stripe_b = value
        local timer = 10
        local new_colour = colour.new(255, 255, 255, 255)
        util.create_tick_handler(function()
            if timer == 10 then
                local new_value = new_colour.r == 255 and 0 or 255
                new_colour = colour.new(new_value, new_value, new_value, 255)
                timer = 0
            end
            timer = timer + 1

            colour_b = new_colour
            return Stripe_b
        end)
end, false)
deadline_colour_b_id = menu.colour(deadline_colour_b_settings, "colour b", {"deadlineColourB"}, "colour b of the trail", {r = 1, g = 0,b = 1, a = 1}, true, function (new_colour)
        colour_b = colour.to_rage(new_colour)
end)
menu.rainbow(deadline_colour_b_id)
--[[------------------------------------------------------------------------]]

local deadline_texture_dict = "deadline"
local deadline_texture = "deadline_trail_01"
local deadline_line_height = 0.7
local deadline_line_length = 200

local deadline_positions = {}
local deadline_coloursa = {}
local deadline_coloursb = {}
local deadline_write_index = 1

local deadline_run = false
menu.toggle(deadline_list, "deadline", {"deadline"}, "renders a line behind you as seen in the deadline game mode", function(value)
    deadline_run = value
    if value then
        util.create_tick_handler(function ()
            local player_pos = ENTITY.GET_ENTITY_COORDS(player_ped_id)
            if deadline_write_index < deadline_line_length then
                deadline_write_index = deadline_write_index + 1
            else
                deadline_write_index = 1
            end
            if wave then
                if veloBased then
                    player_pos.z = player_pos.z + math.sin(MISC.GET_FRAME_COUNT() * 0.25) * ENTITY.GET_ENTITY_SPEED(PLAYER.PLAYER_PED_ID()) * waveAmp
                else
                    player_pos.z = player_pos.z + math.sin(MISC.GET_FRAME_COUNT() * 0.25)
                end
            end
            deadline_positions[deadline_write_index] = player_pos
            deadline_coloursa[deadline_write_index] = colour_a
            deadline_coloursb[deadline_write_index] = colour_b

        for index, value in ipairs(deadline_positions) do
            local previous = {}
            if index == 1 then
                if  deadline_write_index == #deadline_positions then
                    previous = nil
                else
                    previous = deadline_positions[#deadline_positions]
                end
            else
                if index - 1 == deadline_write_index then
                    previous = nil
                else
                    previous = deadline_positions[index - 1]
                end
            end
            if previous ~= nil then
                if dashed then
                    if index % 2 == 0 then
                    drawing_funcs.draw_quad(previous, value, deadline_line_height, deadline_coloursb[index], deadline_coloursa[index], deadline_texture_dict, deadline_texture)
                    else
                    drawing_funcs.draw_quad(previous, value, deadline_line_height, deadline_coloursa[index], deadline_coloursb[index], deadline_texture_dict, deadline_texture)
                    end
                else
                    drawing_funcs.draw_quad(previous, value, deadline_line_height, deadline_coloursa[index], deadline_coloursb[index], deadline_texture_dict, deadline_texture)
                end
            end
        end
            return deadline_run
        end)         
    end
end)

--#endregion

--[[     VEHICLES      ]]

--#region better heli
local thrust_offset = 0x338
local handling_offsets = {
    ["fYawMult"] = 0x348, -- dont remember
    ["fYawStabilise"] = 0x350, --minor stabalization
    ["fSideSlipMult"] = 0x354, --minor stabalizaztion
    ["fRollStabilise"] = 0x360, --minor stabalization
    ["fAttackLiftMult"] = 0x378, --disables most of it
    ["fAttackDiveMult"] = 0x37C, --disables most of the other axis
    ["fWindMult"] = 0x388, --helps with removing some jitter
    ["fPitchStabilise"] = 0x36C --idk what it does but it seems to help
}

menu.slider(better_heli_list, "thrust", {"heliThrust"}, "set the heli thrust", 0, 100, 5, 1, function (value)
    if common_funcs.get_player_vehicle_class() == 15 then
        local Daddy = common_funcs.address_from_pointer_chain(properties.worldPtr, {0x08, 0xD30, 0x938, thrust_offset})
        if Daddy ~= 0 then
            memory.write_float(Daddy, value * 0.1)
        else
            util.toast("failed to find address for thrust")
        end
    else
        util.toast("get in a heli first")
    end
end)

menu.action(better_heli_list, "better heli mode", {"betterheli"}, "disabables heli auto stablization\nthis is on a per heli basis", function ()
    if common_funcs.get_player_vehicle_class() == 15 then
        for index, offset in pairs(handling_offsets) do
            local Daddy = common_funcs.address_from_pointer_chain(properties.worldPtr, {0x08, 0xD30, 0x938, offset})
            if Daddy ~= 0 then
                memory.write_float(Daddy, 0)
            else
                util.toast("failed to find address for: "..index)
            end
        end
        util.toast("done, try not to crash :)")
    else
        util.toast("get in a heli first")
    end
end)
--#endRegion

--#region shitty gps
local shitty_gps_colour_settings = menu.list(shitty_gps_list, "colours")

local shitty_gps_colour_a = colour.magenta()
local shitty_gps_colour_b = colour.white()
local shitty_gps_size = 1

local deadline_colour_a_id =menu.colour(shitty_gps_colour_settings,"colour a",{"GpsColourA"},"",{r = 1, g = 0, b = 1, a = 1},true,function(new_colour)
        shitty_gps_colour_a = colour.to_rage(new_colour)
    end
)
menu.rainbow(deadline_colour_a_id)
local deadline_colour_b_id =
    menu.colour(shitty_gps_colour_settings,"colour b",{"GpsColourB"},"",{r = 1, g = 1, b = 1, a = 1},true,function(new_colour)
        shitty_gps_colour_b = colour.to_rage(new_colour)
    end
)
menu.rainbow(deadline_colour_b_id)

local function get_waypoint_coords()
    return HUD.GET_BLIP_INFO_ID_COORD(HUD.GET_FIRST_BLIP_INFO_ID(HUD.GET_WAYPOINT_BLIP_ENUM_ID()))
end


local run_loop = false
menu.toggle(shitty_gps_list, "shitty gps", {"shittygps"}, "a very bad gps that sometimes points where you wanna go", function(value)
    local p_direction = memory.alloc(1) --bool
    local p_5 = memory.alloc(4) --float
    local p_distToNxJunction = memory.alloc(4) --float
    local p_screenX = memory.alloc(4) --float
    local p_screenY = memory.alloc(4) --float
    run_loop = value

    if value then
    util.create_tick_handler(function ()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)

    local waypoint_pos = get_waypoint_coords()
    local total = waypoint_pos.x + waypoint_pos.y + waypoint_pos.z

    if total ~= 0 and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
        local player_pos = ENTITY.GET_ENTITY_COORDS(player_ped_id)

        local height = ENTITY.GET_ENTITY_HEIGHT(vehicle, player_pos.x, player_pos.y, player_pos.z, true, false)

        PATHFIND.GENERATE_DIRECTIONS_TO_COORD(
            waypoint_pos.x,
            waypoint_pos.y,
            waypoint_pos.z,
            0,
            p_direction,
            p_5,
            p_distToNxJunction
        )

        local direction = memory.read_byte(p_direction)
        local distToNxJunction = memory.read_float(p_distToNxJunction)

        local turn_dir = 0

        GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(
            player_pos.x,
            player_pos.y,
            player_pos.z + 1.5 + height,
            p_screenX,
            p_screenY
        )
        local screen_x = memory.read_float(p_screenX)
        local screen_y = memory.read_float(p_screenY)

        if direction == 1 then
            turn_dir = 180
            directx.draw_text(screen_x, screen_y, "make a U-turn when possible", ALIGN_CENTRE, 1, colour.to_stand(shitty_gps_colour_a))
        elseif direction == 3 then
            turn_dir = -90
            directx.draw_text(screen_x,screen_y,"turn left in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 6 then
            turn_dir = -145
            directx.draw_text(screen_x,screen_y,"turn sharp left in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 4 then
            turn_dir = 90
            directx.draw_text(screen_x,screen_y,"turn right in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 7 then
            turn_dir = 145
            directx.draw_text(screen_x,screen_y,"turn sharp right in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 8 then
            directx.draw_text(screen_x, screen_y, "calculating new route    ", ALIGN_CENTRE, 1, colour.to_stand(shitty_gps_colour_a))
        end
        local player_pos = ENTITY.GET_ENTITY_COORDS(player_ped_id)
        local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player_ped_id)
        local angle = vectors.vector2.get_angle(direction, {x = 0, y = 1})
        if vectors.vector2.dot({x = direction.x, y = direction.y}, {x = 1, y = 0}) > 0 then
            angle = -angle
        end
        player_pos.z = player_pos.z + 1 + height
        util.draw_debug_text(shitty_gps_colour_a.r)
        drawing_funcs.draw_arrow(player_pos, angle - math.rad(turn_dir), shitty_gps_size, shitty_gps_colour_a, shitty_gps_colour_b)
    end

    return run_loop
    end)
    else
        memory.free(p_distToNxJunction)
        memory.free(p_direction)
        memory.free(p_5)
        memory.free(p_screenX)
        memory.free(p_screenY)
    end
end)

--#endregion

--[[      ARCADE       ]]

--#region stacker
local stacker_board
local stacker_progression = {3, 2, 1}
local stacker_progress
local stacker_y
local stacker_x
local stacker_move_delay
local stacker_timer
local stacker_dir
local stacker_size
local stacker_in_progress = false
menu.action(stacker_list, "stacker", {"stacker"}, "play the classic arcade game stacker in gta", function ()
    if stacker_in_progress then util.toast("game already in progress") return end
    util.toast("starting stacker, good luck :)")
    stacker_in_progress = true
    stacker_progress = 1
    stacker_y = 1
    stacker_x = 1
    stacker_move_delay = 0.5
    stacker_timer = 0
    stacker_dir = 1
    stacker_size = 3
    drawing_funcs.draw_button_tip({{'place blocks', 22, true},{'quit stacker', 194, true}}, 4, colour.black())
    stacker_board = {
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
        {0, 0, 0, 0, 0, 0, 0},
    }
    util.create_tick_handler(function ()

        if stacker_size > 0 then
            if stacker_y < #stacker_board + 1 then
                if stacker_timer >= stacker_move_delay then
                    stacker_x = stacker_x + stacker_dir
                    stacker_timer = 0
                    if stacker_x == #stacker_board[stacker_y] - 1 or stacker_x + (stacker_size) == 1 then
                        stacker_dir = -stacker_dir
                    end
                end
                stacker_timer = stacker_timer + delta_time
                
                local aspect_ratio = common_funcs.get_ascpect_ratio()
                
                for y, row in ipairs(stacker_board) do
                    for x, state in ipairs(row) do
                        directx.draw_rect(0.1 + x * 0.02, 0.5 - (y - 1)  * 0.02 * aspect_ratio, 0.015, 0.015 * aspect_ratio, state == 0 and colour.white() or colour.magenta())
                    end
                end
                for i = 1, stacker_size, 1 do
                    if stacker_x + i >= 1 and stacker_x + i <= #stacker_board[stacker_y] then
                        directx.draw_rect(0.1 + stacker_x * 0.02 + i * 0.02, 0.5 - (stacker_y - 1) * 0.02 * aspect_ratio, 0.015, 0.015 * aspect_ratio, colour.magenta())
                    end
                end

                if input.jump() then
                    for i = 1, stacker_size, 1 do
                        if stacker_x + i >= 1 and stacker_x + i <= #stacker_board[stacker_y] then
                            if stacker_y == 1 or stacker_board[stacker_y - 1][stacker_x + i] == 1 then
                                stacker_board[stacker_y][stacker_x + i] = 1
                            else
                                stacker_size = stacker_size - 1
                            end
                        else
                            stacker_size = stacker_size - 1
                        end
                    end
                    stacker_y = stacker_y + 1
                    if stacker_y % 4 == 0 and stacker_size ~= 1 then
                        stacker_progress = stacker_progress + 1
                        if stacker_progression[stacker_progress] < stacker_size then
                            stacker_size = stacker_progression[stacker_progress]
                        end
                    end
                    stacker_x = 1 - stacker_size
                    stacker_dir = 1
                    stacker_move_delay = stacker_move_delay / 1.2
                end
            else
                directx.draw_text(0.5, 0.5, "you win :D", ALIGN_CENTRE, 1, colour.to_stand(colour.magenta()))
                if stacker_timer > 3 then
                    stacker_in_progress = false
                    return false
                end
                stacker_timer = stacker_timer + delta_time
            end
        else
            directx.draw_text(0.5, 0.5, "you lost :(", ALIGN_CENTRE, 1, colour.to_stand(colour.magenta()))
            if stacker_timer > 3 then
                stacker_in_progress = false
                return false
            end
            stacker_timer = stacker_timer + delta_time
        end
        if input.cancel() then
            stacker_in_progress = false
            return false
        end
        return true
    end)
end)
--#endregion


--keep script running
util.keep_running()
