util.require_no_lag('natives-1640181023') --da natives
require "lib.murtensUtils" --my util classes

--[[      SETUP        ]]

--#region "classes"

local properties = b_properties.new()

local common_funcs = b_common_funcs.new()

local vectors = b_vectors.new()

local math_funcs = b_math_funcs.new()

local colour = b_colour.new()

local drawing_funcs = b_drawing_funcs.new()

local input = b_input.new()

local notification = b_notifications.new()

--#endregion
notification.notify("hallo","welcome, i hope you like my script :)")

--#region updated values
local player_ped_id
local delta_time
local player_pos
util.create_tick_handler(function ()
    player_ped_id = PLAYER.PLAYER_PED_ID()
    delta_time = MISC.GET_FRAME_TIME()
    player_pos = ENTITY.GET_ENTITY_COORDS(player_ped_id)
    return true
end)
--#endregion

--[[      LISTS        ]]

--#region sub menus
local self_list = menu.list(menu.my_root(), "self")
    local deadline_list = menu.list(self_list, "deadline")

local vehicles_list = menu.list(menu.my_root(), "vehicles")
    local better_heli_list = menu.list(vehicles_list, "better heli")
    local personal_vehicle_info_list = menu.list(vehicles_list, "personal vehicle info")
    local shitty_gps_list = menu.list(vehicles_list, "shitty gps")

local UI_list = menu.list(menu.my_root(), "UI")
    local hotkey_display_list = menu.list(UI_list, "hotkey display")
    local damage_numbers_list = menu.list(UI_list, "damage numbers")
    local theme_loader_list = menu.list(UI_list, "theme loader (Beta)")

local online_list = menu.list(menu.my_root(), "online")
    local host_tools_list = menu.list(online_list, "host tools")

local world_list = menu.list(menu.my_root(), "world")
    local bounding_box_list = menu.list(world_list, "bounding boxes")
    local terrain_grid_list = menu.list(world_list, "terrain grid")

local arcade_list = menu.list(menu.my_root(), "arcade")
    local stacker_list = menu.list(arcade_list, "stacker")

local misc_list = menu.list(menu.my_root(), "misc")
    local executor_list = menu.list(misc_list, "executor")
    

local mayo_list = menu.list(menu.my_root(), "mayo")
    local mayo_settings_list = menu.list(mayo_list, "settings")
        local notification_settings_list = menu.list(mayo_settings_list, "notifications")
--#endregion

--[[       SELF        ]]

--#region deadline
local deadline_colour_a = colour.magenta
local deadline_colour_b = colour.magenta

local deadline_dashed = false

local deadline_wave = false
local deadline_veloBased = false
local deadline_waveAmp = 0.2

local deadline_settings_list = menu.list(deadline_list, "Settings")

menu.toggle(deadline_settings_list, "dash", {"deadlinedash"}, "make the line dashed", function (value)
    deadline_dashed = value
end)
local wave_settings = menu.list(deadline_settings_list, "wave")
menu.toggle(wave_settings, "wave", {"deadlinewave"}, "make the line wave", function (value)
    deadline_wave = value
end)
menu.toggle(wave_settings, "velocticy based", {"deadlinewaveVelo"}, "make the line wave be affected by your speed", function (value)
    deadline_veloBased = value
end)
menu.slider(wave_settings, "amplitude", {"deadlinewaveAmplitude"}, "aplitude of the wave", 0, 10, 2, 1, function (value)
    deadline_waveAmp = value * 0.1
end)

local deadline_colour_a_settings = menu.list(deadline_settings_list, "Colour A")

--[[------------------------------------------------------------------------]]
local deadline_Stripe_a = false
menu.toggle(deadline_colour_a_settings, "stripe", {"deadlineStripeA"}, "make the line striped", function (value)
        deadline_Stripe_a = value
        local timer = 10
        local new_colour = colour.new(255, 255, 255, 255)
        util.create_tick_handler(function()
            if timer == 10 then
                local new_value = new_colour.r == 255 and 0 or 255
                new_colour = colour.new(new_value, new_value, new_value, 255)
                timer = 0
            end
            timer = timer + 1

            deadline_colour_a = new_colour
            return deadline_Stripe_a
        end)
end, false)
local deadline_colour_a_id = menu.colour(deadline_colour_a_settings, "colour a", {"deadlineColourA"}, "colour a of the trail", {r = 1, g = 0,b = 1, a = 1}, true, function (new_colour)
        deadline_colour_a = colour.to_rage(new_colour)
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

            deadline_colour_b = new_colour
            return Stripe_b
        end)
end, false)
local deadline_colour_b_id = menu.colour(deadline_colour_b_settings, "colour b", {"deadlineColourB"}, "colour b of the trail", {r = 1, g = 0,b = 1, a = 1}, true, function (new_colour)
        deadline_colour_b = colour.to_rage(new_colour)
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

menu.slider(deadline_settings_list, "length", {"deadlineLength"}, "length of the line \n higher values may make your game crash", 0, 600, 200, 1, function (value)
    for i = #deadline_positions, value, -1 do
        table.remove(deadline_positions, i)
        table.remove(deadline_coloursa, i)
        table.remove(deadline_coloursb, i)
    end
    deadline_line_length = value
end)

local deadline_run = false
menu.toggle(deadline_list, "deadline", {"deadline"}, "renders a line behind you as seen in the deadline game mode", function(value)
    deadline_run = value
    if value then
        util.create_tick_handler(function ()
            if deadline_write_index < deadline_line_length then
                deadline_write_index = deadline_write_index + 1
            else
                deadline_write_index = 1
            end
            if deadline_wave then
                if deadline_veloBased then
                    player_pos.z = player_pos.z + math.sin(MISC.GET_FRAME_COUNT() * 0.25) * ENTITY.GET_ENTITY_SPEED(PLAYER.PLAYER_PED_ID()) * deadline_waveAmp
                else
                    player_pos.z = player_pos.z + math.sin(MISC.GET_FRAME_COUNT() * 0.25)
                end
            end
            deadline_positions[deadline_write_index] = player_pos
            deadline_coloursa[deadline_write_index] = deadline_colour_a
            deadline_coloursb[deadline_write_index] = deadline_colour_b

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
                if deadline_dashed then
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
local secondary_handeling_data_offset = 0x330
local thrust_offset = 0x338
local better_heli_handling_offsets = {
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
    if common_funcs.get_player_vehicle_class() == 15 or ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()) == util.joaat("BLIMP") then
        local Daddy = common_funcs.address_from_pointer_chain(entities.get_user_vehicle_as_pointer() + 0x938, {thrust_offset})
        if Daddy ~= 0 then
            memory.write_float(Daddy, value * 0.1)
        else
            notification.notify("error","failed to find address for thrust", 3)
            return
        end
    elseif ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()) == util.joaat("HYDRA") then
            local Daddy = common_funcs.address_from_pointer_chain(entities.get_user_vehicle_as_pointer() + 0x938, {thrust_offset + secondary_handeling_data_offset})
            if Daddy ~= 0 then
                memory.write_float(Daddy, value * 0.1)
            end
    else
        notification.notify("failed","get in a heli first")
    end
end)

menu.action(better_heli_list, "better heli mode", {"betterheli"}, "disabables heli auto stablization\nthis is on a per heli basis (also works for blimps)", function ()
    if common_funcs.get_player_vehicle_class() == 15 or ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()) == util.joaat("BLIMP") then
        for index, offset in pairs(better_heli_handling_offsets) do
            local Daddy = common_funcs.address_from_pointer_chain(entities.get_user_vehicle_as_pointer() + 0x938, {offset})
            if Daddy ~= 0 then
                memory.write_float(Daddy, 0)
            else
                notification.notify("error","failed to find address for: "..index, 3)
                return
            end
        end
        notification.notify("done","try not to crash :)")
    elseif ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()) == util.joaat("HYDRA") then
        for index, offset in pairs(better_heli_handling_offsets) do
            local Daddy = common_funcs.address_from_pointer_chain(entities.get_user_vehicle_as_pointer() + 0x938, {offset + secondary_handeling_data_offset})
            if Daddy ~= 0 then
                memory.write_float(Daddy, 0)
            else
                notification.notify("error","failed to find address for: "..index, 3)
                return
            end
        end
        notification.notify("done","try not to crash :)")
    else
        notification.notify("failed","get in a heli first")
    end
end)
--#endRegion

--#region shitty gps
local shitty_gps_colour_settings = menu.list(shitty_gps_list, "colours")

local shitty_gps_colour_a = colour.magenta
local shitty_gps_colour_b = colour.white
local shitty_gps_size = 1

local shitty_gps_colour_a_id = menu.colour(shitty_gps_colour_settings,"colour a",{"GpsColourA"},"",{r = 1, g = 0, b = 1, a = 1},true,function(new_colour)
        shitty_gps_colour_a = colour.to_rage(new_colour)
    end
)
menu.rainbow(shitty_gps_colour_a_id)
local shitty_gps_colour_b_id = menu.colour(shitty_gps_colour_settings,"colour b",{"GpsColourB"},"",{r = 1, g = 1, b = 1, a = 1},true,function(new_colour)
        shitty_gps_colour_b = colour.to_rage(new_colour)
    end
)
menu.rainbow(shitty_gps_colour_b_id)

local function get_waypoint_coords()
    return HUD.GET_BLIP_INFO_ID_COORD(HUD.GET_FIRST_BLIP_INFO_ID(HUD.GET_WAYPOINT_BLIP_ENUM_ID()))
end


local shitty_gps_run = false
menu.toggle(shitty_gps_list, "shitty gps", {"shittygps"}, "a very bad gps that sometimes points where you wanna go", function(value)
    local p_direction = memory.alloc(1) --bool
    local p_5 = memory.alloc(4) --float
    local p_distToNxJunction = memory.alloc(4) --float
    local p_screenX = memory.alloc(4) --float
    local p_screenY = memory.alloc(4) --float

    local turn_dir = 0
    shitty_gps_run = value

    if value then
    util.create_tick_handler(function ()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)

    local waypoint_pos = get_waypoint_coords()
    local total = waypoint_pos.x + waypoint_pos.y + waypoint_pos.z

    if total ~= 0 and ENTITY.IS_ENTITY_A_VEHICLE(vehicle) then
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
            turn_dir = math_funcs.lerp(turn_dir, 180, 5 * delta_time)
            directx.draw_text(screen_x, screen_y, "make a U-turn when possible", ALIGN_CENTRE, 1, colour.to_stand(shitty_gps_colour_a))
        elseif direction == 3 then
            turn_dir =  math_funcs.lerp(turn_dir, -90, 5 * delta_time)
            directx.draw_text(screen_x,screen_y,"turn left in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 6 then
            turn_dir =  math_funcs.lerp(turn_dir, -145, 5 * delta_time)
            directx.draw_text(screen_x,screen_y,"turn sharp left in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 4 then
            turn_dir =  math_funcs.lerp(turn_dir, 90, 5 * delta_time)
            directx.draw_text(screen_x,screen_y,"turn right in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 7 then
            turn_dir =  math_funcs.lerp(turn_dir, 145, 5 * delta_time)
            directx.draw_text(screen_x,screen_y,"turn sharp right in " .. math.floor(distToNxJunction) .. " meters",ALIGN_CENTRE,1,colour.to_stand(shitty_gps_colour_a))
        elseif direction == 8 then
            turn_dir =  math_funcs.lerp(turn_dir, 0, 5 * delta_time)
            directx.draw_text(screen_x, screen_y, "calculating new route    ", ALIGN_CENTRE, 1, colour.to_stand(shitty_gps_colour_a))
        else
            turn_dir =  math_funcs.lerp(turn_dir, 0, 5 * delta_time)
        end
        local direction = ENTITY.GET_ENTITY_FORWARD_VECTOR(player_ped_id)
        local angle = vectors.vector2.get_angle(direction, {x = 0, y = 1})
        if vectors.vector2.dot({x = direction.x, y = direction.y}, {x = 1, y = 0}) > 0 then
            angle = -angle
        end
        local draw_pos = common_funcs.get_pos_above_entity(vehicle)
        draw_pos.z = draw_pos.z + 0.4
        drawing_funcs.draw_arrow(draw_pos, angle - math.rad(turn_dir), shitty_gps_size, shitty_gps_colour_a, shitty_gps_colour_b)
    end

    return shitty_gps_run
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

--#region personal vehicle info
local personal_vehicle_info_entries = {}
menu.action(personal_vehicle_info_list,"reload vehicles", {""}, "reloads all your personal vehicles", function ()
    for _, entry in ipairs(personal_vehicle_info_entries) do
        menu.delete(entry)
    end
    personal_vehicle_info_entries = {}
    local price = memory.alloc(4)
    for index = 0, 300, 1 do
        if memory.read_int(memory.script_global(1585844 + index * 142 + 67)) ~= 0 then
            STATS.STAT_GET_INT(util.joaat("MP0_MPSV_PRICE_PAID_"..index), price, -1)
            car_name = HUD._GET_LABEL_TEXT(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(memory.read_int(memory.script_global(1585844 + index * 142 + 67))))

            sub_list = menu.list(personal_vehicle_info_list, car_name)
            personal_vehicle_info_entries[#personal_vehicle_info_entries+1] = sub_list

            menu.divider(sub_list, car_name)
            menu.action(sub_list,"model: "..VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(memory.read_int(memory.script_global(1585844 + index * 142 + 67))), {}, "" ,function () end)
            menu.action(sub_list,"plate: "..memory.read_string(memory.script_global(1585844 + index * 142 + 2)), {}, "" ,function () end)
            menu.action(sub_list,"personal vehicle slot: "..index, {}, "" ,function () end)
            menu.action(sub_list,"price paid: "..memory.read_int(price), {}, "" ,function () end)
            menu.action(sub_list,"is destroyed: "..tostring(MISC.IS_BIT_SET(memory.read_int(memory.script_global(1585844 + index * 142 + 104)), 1)), {}, "" ,function () end)
            menu.action(sub_list,"is insured: "..tostring(MISC.IS_BIT_SET(memory.read_int(memory.script_global(1585844 + index * 142 + 104)), 2)), {}, "" ,function () end)
            local is_active = false
            if memory.read_int(memory.script_global(2359296 + 1 + 675 + 2)) == index then is_active = true end
            menu.action(sub_list,"is active: "..tostring(is_active), {}, "", function () end)
            menu.action(sub_list,"radio station: "..memory.read_string(memory.script_global(1585844 + index * 142 + 123)), {}, "" ,function () end)

            mods_list = menu.list(sub_list, "mods")
            menu.action(mods_list,"engine: "..memory.read_int(memory.script_global(1585844 + index * 142 + 22)), {}, "" ,function () end)
            menu.action(mods_list,"brakes: "..memory.read_int(memory.script_global(1585844 + index * 142 + 23)), {}, "" ,function () end)
            menu.action(mods_list,"transmission: "..memory.read_int(memory.script_global(1585844 + index * 142 + 24)), {}, "" ,function () end)
            menu.action(mods_list,"armor: "..memory.read_int(memory.script_global(1585844 + index * 142 + 27)), {}, "" ,function () end)
            menu.divider(mods_list, "might add more in the future")
        end
    end
    memory.free(price)
end)
menu.divider(personal_vehicle_info_list, "Vehicles")
--#endregion



--[[        UI         ]]

--#region hotkey display
local hotkey_display_run
local hotkey_display_colour = colour.to_stand(colour.magenta)
local hotkey_display_posx, hotkey_display_posy = 0.36, 0.78
local hotkey_display_max_column_height = 10
menu.toggle(hotkey_display_list, "hotkey display", {"displayhotkeys", "hotkeydisplay"}, "displays all your current hotkeys on screen", function (value)

    local dir = filesystem.stand_dir().."Hotkeys.txt"

    if not filesystem.exists(dir) then 
        notification.notify("error", "file: \""..dir.."\" could not be found")
        menu.trigger_commands("displayhotkeys off")
        return
    end

    local hotkeys = {}

    for line in io.lines(dir) do
        if string.find(line, ":") and not string.find(line, "Tree") then
            hotkeys[#hotkeys+1] = string.gsub(line, "\t", "")
        end
    end

    hotkey_display_run = value
    if hotkey_display_run then

        util.create_tick_handler(function ()
            local total_height = 0
            local tab = 0
            local largest_line = 0
            local current_y_index = 0
            for i, hotkey in ipairs(hotkeys) do
                directx.draw_text(hotkey_display_posx + tab, hotkey_display_posy + current_y_index * 0.02, hotkey, ALIGN_TOP_LEFT, 0.6, hotkey_display_colour, false)
                local line_width = directx.get_text_size(hotkey, 0.6)
                if line_width > largest_line then
                    largest_line = line_width
                end
                current_y_index = current_y_index + 1
                total_height = total_height + current_y_index * 0.02
                if total_height >= hotkey_display_max_column_height * 0.1 then
                    tab = tab + largest_line + 0.02
                    largest_line = 0
                    total_height = 0
                    current_y_index = 0
                end
            end
            return hotkey_display_run
        end)
    end
end)
menu.slider(hotkey_display_list, "position x", {"hotkeydisplayposx"}, "", 0, 100, 36, 1, function (value)
    hotkey_display_posx = value * 0.01
end)
menu.slider(hotkey_display_list, "position y", {"hotkeydisplayposy"}, "", 0, 100, 78, 1, function (value)
    hotkey_display_posy = value * 0.01
end)
menu.slider(hotkey_display_list, "column height", {"hotkeydisplayheight"}, "", 0, 100, 10, 1, function (value)
    hotkey_display_max_column_height = value
end)
menu.rainbow(menu.colour(hotkey_display_list, "colour", {"hotkeydisplaycolour", "displayhotkeycolour"}, "changes the colour of the text", colour.to_stand(colour.magenta), true, function (value)
    hotkey_display_colour = value
end))
--#endregion

--#region damage numbers
local damage_numbers_target_ptr = memory.alloc(4)
local damage_numbers_tracked_entities = {}
local damage_numbers_health_colour = colour.to_stand(colour.new(20, 180, 50, 255))
local damage_numbers_armour_colour = colour.to_stand(colour.new(50, 50, 200, 255))
local damage_numbers_crit_colour = colour.to_stand(colour.new(200, 200, 10, 255))
local damage_numbers_vehicle_colour = colour.to_stand(colour.new(200, 100, 20, 255))
local damage_numbers_bone_ptr = memory.alloc(4)
local damage_numbers_target_vehicles
local damage_numbers_text_size = 0.7
menu.toggle_loop(damage_numbers_list, "damage numbers", {"damagenumbers"}, "", function()
   if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(players.user(), damage_numbers_target_ptr) then
        local target = memory.read_int(damage_numbers_target_ptr)
        if ENTITY.IS_ENTITY_A_PED(target) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(target, false)
            if vehicle ~= 0 and damage_numbers_target_vehicles then
                if damage_numbers_tracked_entities[vehicle] == nil then
                    damage_numbers_tracked_entities[vehicle] = {
                        health = math.max(0, ENTITY.GET_ENTITY_HEALTH(vehicle)),
                        timer = 1
                    }
                else
                    damage_numbers_tracked_entities[vehicle].timer = 1
                end
            end
                if damage_numbers_tracked_entities[target] == nil then
                    damage_numbers_tracked_entities[target] = {
                        health = math.max(0, ENTITY.GET_ENTITY_HEALTH(target) - 100),
                        armour = PED.GET_PED_ARMOUR(target),
                        timer = 1
                    }
                else
                    damage_numbers_tracked_entities[target].timer = 1
                end
        elseif ENTITY.IS_ENTITY_A_VEHICLE(target) and damage_numbers_target_vehicles then
            if damage_numbers_tracked_entities[target] == nil then
                damage_numbers_tracked_entities[target] = {
                    health = math.max(0, ENTITY.GET_ENTITY_HEALTH(target)),
                    timer = 1
                }
            else
                damage_numbers_tracked_entities[target].timer = 1
            end
        end
   end
   for entity, data in pairs(damage_numbers_tracked_entities) do
        if  ENTITY.IS_ENTITY_A_PED(entity) then
            local current_health = math.max(0, ENTITY.GET_ENTITY_HEALTH(entity) - 100)
            local current_armour = PED.GET_PED_ARMOUR(entity)
            if ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY(entity, player_ped_id, 1) then
                if current_health < data.health then
                    data.timer = 1
                    PED.GET_PED_LAST_DAMAGE_BONE(entity, damage_numbers_bone_ptr)
                    if memory.read_int(damage_numbers_bone_ptr) == 31086 then
                        drawing_funcs.draw_damage_number(entity, data.health - current_health, damage_numbers_crit_colour, damage_numbers_text_size)
                    else
                        drawing_funcs.draw_damage_number(entity, data.health - current_health, damage_numbers_health_colour, damage_numbers_text_size)
                    end
                end
                if current_armour < data.armour then
                    data.timer = 1
                    drawing_funcs.draw_damage_number(entity, data.armour - current_armour, damage_numbers_armour_colour, damage_numbers_text_size)
                end
            end
            data.timer = data.timer - delta_time
            if data.timer < 0 then
                damage_numbers_tracked_entities[entity] = nil
            end
            data.health = current_health
            data.armour = current_armour
        else
            local current_health = math.max(0, ENTITY.GET_ENTITY_HEALTH(entity))
            if ENTITY.HAS_ENTITY_BEEN_DAMAGED_BY_ENTITY(entity, player_ped_id, 1) then
                if current_health < data.health then
                    data.timer = 1
                    drawing_funcs.draw_damage_number(entity, data.health - current_health, damage_numbers_vehicle_colour, damage_numbers_text_size)
                end
            end
            data.timer = data.timer - delta_time
            if data.timer < 0 then
                damage_numbers_tracked_entities[entity] = nil
            end
            data.health = current_health
        end
    end
end)
menu.toggle(damage_numbers_list, "include vehicles", {"damagenumbersvehicles"}, "also target vehicles for damage numbers", function (value)
    damage_numbers_target_vehicles = value
end)
menu.slider(damage_numbers_list, "text size", {"damagenumberstextsize"}, "the size of the AR text", 1, 100, 7, 1, function (value)
    damage_numbers_text_size = value * 0.1
end)
local damage_numbers_colours_list = menu.list(damage_numbers_list, "colour settings")
menu.rainbow(menu.colour(damage_numbers_colours_list, "default colour", {"damagenumcolour"}, "colour of the default hit", damage_numbers_health_colour, true, function (value)
    damage_numbers_health_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "crit colour", {"damagenumcritcolour"}, "colour of the crit hit", damage_numbers_crit_colour, true, function (value)
    damage_numbers_crit_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "armour colour", {"damagenumarmourcolour"}, "colour of the armour hit", damage_numbers_armour_colour, true, function (value)
    damage_numbers_armour_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "vehicle colour", {"damagenumvehiclecolour"}, "colour of the vehicle hit", damage_numbers_vehicle_colour, true, function (value)
    damage_numbers_vehicle_colour = value
end))
--#endregion

--#region theme loader
    local theme_loader_profiles = {}
    local theme_loader_themes   = {}
    local theme_loader_selected_profile = {name = "profile: none", dir = "", profile = {}, selected = false}
    local theme_loader_selected_theme = {name = "theme: none", dir = "", profile = {}, selected = false}
    local theme_loader_theme_selector_list
    local theme_loader_profile_selector_list
    local theme_loader_profile_selector_entries = {}
    local theme_loader_theme_selector_entries = {}
    local theme_loader_text_input = -1
    local theme_loader_divider
    local theme_loader_include_font = true

    local theme_loader_profile_template = {
        ["Stand>Settings>Appearance>Colours>Primary Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Primary Colour\\"] = "",
        ["Stand>Settings>Appearance>Colours>Focused Text Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Focused Right-Bound Text Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Focused Texture Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Background Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Unfocused Text Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Unfocused Right-Bound Text Colour"] = "",
        ["Stand>Settings>Appearance>Colours>Unfocused Texture Colour"] = "",
        ["Stand>Settings>Appearance>Colours>HUD Colour"] = "",
        ["Stand>Settings>Appearance>Colours>HUD Colour\\"] = "",
        ["Stand>Settings>Appearance>Header>Header"] = "",
        ["Stand>Settings>Appearance>Header>Frame Interval"] = "",
        ["Stand>Settings>Appearance>Header>Legacy Positioning"] = "",
        ["Stand>Settings>Appearance>Address Bar>Address Bar"] = "",
        ["Stand>Settings>Appearance>Address Bar>Address Separator"] = "",
        ["Stand>Settings>Appearance>Address Bar>Width Addected By Scrollbar"] = "",
        ["Stand>Settings>Appearance>Address Bar>Height"] = "",
        ["Stand>Settings>Appearance>Address Bar>Text>Scale"] = "",
        ["Stand>Settings>Appearance>Address Bar>Text>X Offset"] = "",
        ["Stand>Settings>Appearance>Address Bar>Text>Y Offset"] = "",
        ["Stand>Settings>Appearance>Cursor>Width"] = "",
        ["Stand>Settings>Appearance>Cursor>Rounded"] = "",
        ["Stand>Settings>Appearance>Cursor>Colour"] = "",
        ["Stand>Settings>Appearance>Cursor>Colour\\"] = "",
        ["Stand>Settings>Appearance>Tabs>Tabs"] = "",
        ["Stand>Settings>Appearance>Tabs>Width"] = "",
        ["Stand>Settings>Appearance>Tabs>Position"] = "",
        ["Stand>Settings>Appearance>Tabs>Text Alignment"] = "",
        ["Stand>Settings>Appearance>Tabs>Show Icon Left"] = "",
        ["Stand>Settings>Appearance>Tabs>Show Name"] = "",
        ["Stand>Settings>Appearance>Tabs>Show Icon Right"] = "",
        ["Stand>Settings>Appearance>Scrollbar>Scrollbar"] = "",
        ["Stand>Settings>Appearance>Scrollbar>Width"] = "",
        ["Stand>Settings>Appearance>Command Info Text>Position"] = "",
        ["Stand>Settings>Appearance>Command Info Text>Width"] = "",
        ["Stand>Settings>Appearance>Command Info Text>Padding"] = "",
        ["Stand>Settings>Appearance>Notifications>Colour"] = "",
        ["Stand>Settings>Appearance>Notifications>Colour\\"] = "",
        ["Stand>Settings>Appearance>Border>Width"] = "",
        ["Stand>Settings>Appearance>Border>Rounded"] = "",
        ["Stand>Settings>Appearance>Border>Colour"] = "",
        ["Stand>Settings>Appearance>Border>Colour\\"] = "",
        ["Stand>Settings>Appearance>Max Visible Commands"] = "",
        ["Stand>Settings>Appearance>List Width"] = "",
        ["Stand>Settings>Appearance>Spacer Size"] = "",
        ["Stand>Settings>Appearance>Background Blur"] = "",
        ["Stand>Settings>Appearance>Font & Text>Big Text>Scale"] = "",
        ["Stand>Settings>Appearance>Font & Text>Big Text>X Offset"] = "",
        ["Stand>Settings>Appearance>Font & Text>Big Text>Y Offset"] = "",
        ["Stand>Settings>Appearance>Font & Text>Small Text>Scale"] = "",
        ["Stand>Settings>Appearance>Font & Text>Small Text>X Offset"] = "",
        ["Stand>Settings>Appearance>Font & Text>Small Text>Y Offset"] = "",
        ["Stand>Settings>Appearance>Font & Text>Show Text Bounding Boxes"] = "",
        ["Stand>Settings>Appearance>Textures>Leftbound"] = ""
    }

    local function update_profiles(dir, trim)
        local files = filesystem.list_files(dir)
        file_table = {}
        for i, dir in ipairs(files) do
            local split_dir = common_funcs.split(dir, "\\")
            file_table[#file_table+1] = {name = string.sub(split_dir[#split_dir],1, string.len(split_dir[#split_dir])-trim), dir = dir}
        end
        return file_table
    end

    local function populate_list(target, content, prefix, selection_target, entries, remove_text_input_on_click)
        for _, entrie in ipairs(content) do
            menu.delete(entrie)
        end
        content = {}
        for _, entry in ipairs(entries) do
            content[#content+1] = menu.action(target, entry.name, {""}, entry.dir, function ()
                selection_target.name = entry.name
                selection_target.dir = entry.dir
                selection_target.selected = true
                menu.set_menu_name(target,prefix..selection_target.name)
                menu.set_help_text(target, selection_target.dir)
                menu.trigger_command(theme_loader_list)
                if remove_text_input_on_click and theme_loader_text_input ~= -1 then
                    menu.delete(theme_loader_text_input)
                    menu.delete(theme_loader_divider)
                    theme_loader_text_input = -1
                end
            end)
        end
        return content
    end

    
    menu.divider(theme_loader_list, "profile")

    theme_loader_profile_selector_list = menu.list(theme_loader_list, "profile: none", {""}, "select the target profile", function ()
        theme_loader_profiles = update_profiles(filesystem.stand_dir().."Profiles\\", 4)
        
        theme_loader_profile_selector_entries = populate_list(theme_loader_profile_selector_list, theme_loader_profile_selector_entries, "Profile: ", theme_loader_selected_profile, theme_loader_profiles)
    end)

    menu.action(theme_loader_list, "load\\reload profile", {""}, "reload the selected profile", function ()
        if theme_loader_selected_profile.name ~= "profile: none" then
            menu.trigger_commands("load"..string.gsub(theme_loader_selected_profile.name, "%s+", ""))
        end
    end)

    menu.divider(theme_loader_list, "theme")

    theme_loader_theme_selector_list = menu.list(theme_loader_list, "theme: none", {""}, "select a theme to load", function ()
        theme_loader_themes = update_profiles(filesystem.stand_dir().."Themes\\", 0)
        
        theme_loader_theme_selector_entries = populate_list(theme_loader_theme_selector_list, theme_loader_theme_selector_entries, "Themes: ", theme_loader_selected_theme, theme_loader_themes, true)
    end)
    menu.action(theme_loader_list, "create new theme", {""}, "create a new theme", function ()
        theme_loader_selected_theme.name = "new_theme"
        theme_loader_selected_theme.dir = filesystem.stand_dir().."Themes\\"..theme_loader_selected_theme.name
        theme_loader_selected_theme.selected = true
        theme_loader_divider = menu.divider(theme_loader_list, "new theme:")
        theme_loader_text_input = menu.text_input(theme_loader_list, "theme name", {"themeName"}, "", function (value)
            theme_loader_selected_theme.name = value
            theme_loader_selected_theme.dir = filesystem.stand_dir().."Themes\\"..theme_loader_selected_theme.name
        end, "new_theme")
        menu.set_menu_name(theme_loader_theme_selector_list,"Creating new theme")
        menu.set_help_text(theme_loader_theme_selector_list, "")
    end)

    menu.toggle(theme_loader_list, "include font", {""}, "include or exlude your current font in save and loading themes", function (value)
        theme_loader_include_font = value
    end, true)



    local function save_theme()
        local theme_dir = theme_loader_selected_theme.dir.."\\"
        util.write_colons_file(theme_dir..theme_loader_selected_theme.name..".txt", theme_loader_selected_theme.profile)
        if theme_loader_selected_theme.profile["Stand>Settings>Appearance>Header>Header"] == "Custom" then
            filesystem.mkdir(theme_dir.."Header")
            local files = filesystem.list_files(filesystem.stand_dir().."Headers\\Custom Header")
            for _, value in ipairs(files) do
                local split_path = common_funcs.split(value, "\\")
                new_dir = theme_dir.."Header\\"..split_path[#split_path]
                common_funcs.copy_File(value, new_dir)
            end
        end
        if theme_loader_include_font then
            local stand_theme_dir = filesystem.stand_dir().."Theme\\"
            if filesystem.exists(stand_theme_dir.."Font.spritefont") then
                common_funcs.copy_File(stand_theme_dir.."Font.spritefont", theme_dir.."Font.spritefont")
            else
                notification.notify("Error", "Font not found, theme saved without font.\nMake sure that Font.spritefont is present in your Stand\\Theme folder")
            end
        end
        notification.notify("Theme saved", "saved \""..theme_loader_selected_theme.name.."\" as a theme\nyou can now load it into any profile")
    end

    local function load_theme()
        for key, _ in pairs(theme_loader_profile_template) do
            if theme_loader_selected_theme.profile[key] ~= "" then
                theme_loader_selected_profile.profile[key] = theme_loader_selected_theme.profile[key]
            else
                theme_loader_selected_profile.profile[key] = nil
            end
        end
        util.write_colons_file(theme_loader_selected_profile.dir, theme_loader_selected_profile.profile)
        local theme_dir = theme_loader_selected_theme.dir.."\\"
        local stand_header_dir = filesystem.stand_dir().."Headers\\Custom Header\\"
        if theme_loader_selected_theme.profile["Stand>Settings>Appearance>Header>Header"] == "Custom" then
            for _, value in ipairs(filesystem.list_files(stand_header_dir)) do
                os.remove(value)
            end 
            local files = filesystem.list_files(theme_dir.."Header")
            for _, value in ipairs(files) do
                local split_path = common_funcs.split(value, "\\")
                new_dir = stand_header_dir..split_path[#split_path]
                common_funcs.copy_File(value, new_dir)
            end
            menu.trigger_commands("header hide")
            menu.trigger_commands("header custom")
        end
        if theme_loader_include_font then
            if filesystem.exists(theme_dir.."Font.spritefont") then
                local stand_theme_dir = filesystem.stand_dir().."Theme\\"
                os.remove(stand_theme_dir.."Font.spritefont")
                common_funcs.copy_File(theme_dir.."Font.spritefont", stand_theme_dir.."Font.spritefont")
                menu.trigger_commands("reloadfont")
            end
        end
        menu.trigger_commands("load"..string.gsub(theme_loader_selected_profile.name, "%s+", ""))
        notification.notify("Theme loaded", "\""..theme_loader_selected_theme.name.."\" was loaded")
    end

    menu.divider(theme_loader_list, "save/load")

    menu.action(theme_loader_list, "create theme from profile", {""}, "saves the selected profile as a theme", function ()
        if not theme_loader_selected_profile.selected then
            notification.notify("Error", "please select a profile to extract the theme from first")
           return
        end
        if not theme_loader_selected_theme.selected then
            notification.notify("Error", "please select a theme to override or create a new theme first")
           return
        end

        theme_loader_selected_profile.profile = util.read_colons_and_tabs_file(theme_loader_selected_profile.dir)
        for key, _ in pairs(theme_loader_profile_template) do
            if theme_loader_selected_profile.profile[key] ~= "" and theme_loader_selected_profile.profile[key]  ~= nil then
                theme_loader_selected_theme.profile[key] = theme_loader_selected_profile.profile[key]
            else
                theme_loader_selected_theme.profile[key] = nil
            end
        end
        if not filesystem.exists(filesystem.stand_dir().."Themes") then
            filesystem.mkdir(filesystem.stand_dir().."Themes")
        end
        if not filesystem.exists(theme_loader_selected_theme.dir) then
            filesystem.mkdir(filesystem.stand_dir().."Themes\\"..theme_loader_selected_theme.name)
            save_theme()
        else
            menu.show_warning(theme_loader_list, 0, "Theme already exists.\nDo you want to replace it?", save_theme)
        end
    end)
    menu.action(theme_loader_list, "load selected theme", {""}, "loads the selected theme in the selected profile without overriding anything but visual stuff\n(this also loads the selected profile", function ()
        if not theme_loader_selected_profile.selected then
            notification.notify("Error", "please select a profile to import the theme into first")
           return
        end
        if not theme_loader_selected_theme.selected then
            notification.notify("Error", "please select a theme to load first")
           return
        end

        if theme_loader_text_input ~= -1 then
            notification.notify("Error", "cannot load a new theme\nplease select an existing theme to load")
            return
        end
        theme_loader_selected_profile.profile = util.read_colons_and_tabs_file(theme_loader_selected_profile.dir)
        theme_loader_selected_theme.profile = util.read_colons_and_tabs_file(theme_loader_selected_theme.dir.."\\"..theme_loader_selected_theme.name..".txt")

        if theme_loader_selected_theme.profile["Stand>Settings>Appearance>Header>Header"] == "Custom" then
            menu.show_warning(theme_loader_list, 0, "Theme contains a custom header. This will delete your current header.\nMake a backup if you wish to keep it", load_theme)
        else
            load_theme()
        end
    end)

--#endregion

--[[       online       ]]

--#region session slots
menu.slider(host_tools_list, "max players", {"maxplayers"}, "set the max players for the lobby\nonly works when host\ncredit to Ren#5219 for discovering this", 1, 32, 32, 1, function (value)
    if Stand_internal_script_can_run then
        NETWORK.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(0, value)
        notification.notify("free slots",NETWORK.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(0))
    end
end)
menu.slider(host_tools_list, "max spectators", {"maxSpectators"}, "set the max spectators for the lobby\nonly works when host\ncredit to Ren#5219 for discovering this", 0, 2, 2, 1, function (value)
    if Stand_internal_script_can_run then
        NETWORK.NETWORK_SESSION_SET_MATCHMAKING_GROUP_MAX(4, value)
        notification.notify("free slots",NETWORK.NETWORK_SESSION_GET_MATCHMAKING_GROUP_FREE(4))
    end
end)
--#endregion

--[[       WORLD       ]]

--#region terrain grid
local terrain_grid_run
local terrain_grid_scale = 10
local terrain_grid_intensity = 10
local terrain_grid_cell_size = 1
menu.toggle(terrain_grid_list, "terrain grid", {"drawterraingrid", "terraingrid"}, "render a grid on the ground", function (value)
    GRAPHICS.TERRAINGRID_ACTIVATE(value)
    GRAPHICS.TERRAINGRID_SET_COLOURS(255, 0, 255, 255, 255, 0, 255, 255, 255, 0, 255, 255)
    terrain_grid_run = value
    if terrain_grid_run then
        util.create_tick_handler(function ()
            coords = CAM.GET_FINAL_RENDERED_CAM_COORD()
            GRAPHICS.TERRAINGRID_SET_PARAMS(
                math.floor(coords.x * terrain_grid_cell_size) / terrain_grid_cell_size,
                math.floor(coords.y * terrain_grid_cell_size) / terrain_grid_cell_size,
                coords.z - 0.5,
                1, 0, 0,
                20 * terrain_grid_scale,
                20 * terrain_grid_scale, 
                20 * terrain_grid_scale, 
                terrain_grid_scale * 20 * 2 * terrain_grid_cell_size, 
                terrain_grid_intensity, 
                coords.z - 0.5, 0)
            return true
        end)
    end
end)
menu.slider(terrain_grid_list, "scale", {"terraingridscale"}, "sets the scale of the grid", 1, 1000, 10, 1, function (value)
    terrain_grid_scale = value  
end)
menu.slider(terrain_grid_list, "cell size", {"terraingridsize"}, "sets the cell size of the grid", 1, 100, 1, 1, function (value)
    terrain_grid_cell_size = value * 0.05
end)
menu.slider(terrain_grid_list, "glow intesity", {"terraingridglow"}, "sets the glow intesity of the grid (might look weird on low grapics settings)", 1, 1000, 10, 1, function (value)
    terrain_grid_intensity = value
end)
local terrain_grid_colour = colour.magenta
menu.rainbow(menu.colour(terrain_grid_list, "colour", {"terraingridcolour"}, "", 1, 0, 1, 1, true, function (new_colour)
    terrain_grid_colour = colour.to_rage(new_colour)
    GRAPHICS.TERRAINGRID_SET_COLOURS(
        terrain_grid_colour.r, terrain_grid_colour.g, terrain_grid_colour.b, terrain_grid_colour.a,
        terrain_grid_colour.r, terrain_grid_colour.g, terrain_grid_colour.b, terrain_grid_colour.a,
        terrain_grid_colour.r, terrain_grid_colour.g, terrain_grid_colour.b, terrain_grid_colour.a)
end))

--#endregion

--#region bounding boxes

local bounding_box_target_peds
local bounding_box_target_vehicles = true
local bounding_box_target_objects
local bounding_box_colour = colour.magenta


menu.toggle_loop(bounding_box_list, "bounding boxes", {"boundingboxes", "AABB"}, "draws bounding boxes around specified entities\nVERY BIG PERFORMANCE COST", function ()
    if bounding_box_target_peds then
        for _, ped in ipairs(entities.get_all_peds_as_handles()) do
            drawing_funcs.draw_bounding_box(ped, bounding_box_colour)
        end
    end
    if bounding_box_target_vehicles then
        for _, entity in ipairs(entities.get_all_vehicles_as_handles()) do
            drawing_funcs.draw_bounding_box(entity, bounding_box_colour)
        end
    end
    if bounding_box_target_objects then
        for _, entity in ipairs(entities.get_all_objects_as_handles()) do
            drawing_funcs.draw_bounding_box(entity, bounding_box_colour)
        end
    end
end)

local bounding_box_settings_list = menu.list(bounding_box_list, "settings")

menu.toggle(bounding_box_settings_list, "target peds", {""}, "targets peds with the bounding boxes", function (value)
    bounding_box_target_peds = value
end)
menu.toggle(bounding_box_settings_list, "target vehicles", {""}, "targets vehicles with the bounding boxes", function (value)
    bounding_box_target_vehicles = value
end, true)
menu.toggle(bounding_box_settings_list, "target objects", {""}, "targets objects with the bounding boxes\nWILL DESTROY YOUR FPS", function (value)
    bounding_box_target_objects = value
end)

menu.rainbow(menu.colour(bounding_box_settings_list, "box colour", {"boundingboxcolour"}, "the colour of the box", colour.magenta, true, function (new_colour)
    bounding_box_colour = colour.to_rage(new_colour)
end))

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
    if stacker_in_progress then notification.notify("failed","game already in progress") return end
    notification.notify("get ready","starting stacker, good luck :)")
    stacker_in_progress = true
    stacker_progress = 1
    stacker_y = 1
    stacker_x = 1
    stacker_move_delay = 0.5
    stacker_timer = 0
    stacker_dir = 1
    stacker_size = 3
    drawing_funcs.draw_button_tip({{'place blocks', 22, true},{'quit stacker', 194, true}}, 4, colour.black)
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
                
                for y, row in ipairs(stacker_board) do
                    for x, state in ipairs(row) do
                        directx.draw_rect(0.1 + x * 0.02, 0.5 - (y - 1)  * 0.02 * properties.aspect_ratio_16_9, 0.015, 0.015 * properties.aspect_ratio_16_9, state == 0 and colour.white or colour.magenta)
                    end
                end
                for i = 1, stacker_size, 1 do
                    if stacker_x + i >= 1 and stacker_x + i <= #stacker_board[stacker_y] then
                        directx.draw_rect(0.1 + stacker_x * 0.02 + i * 0.02, 0.5 - (stacker_y - 1) * 0.02 * properties.aspect_ratio_16_9, 0.015, 0.015 * properties.aspect_ratio_16_9, colour.magenta)
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
                directx.draw_text(0.5, 0.5, "you win :D", ALIGN_CENTRE, 1, colour.to_stand(colour.magenta))
                if stacker_timer > 3 then
                    stacker_in_progress = false
                    return false
                end
                stacker_timer = stacker_timer + delta_time
            end
        else
            directx.draw_text(0.5, 0.5, "you lost :(", ALIGN_CENTRE, 1, colour.to_stand(colour.magenta))
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

--[[       MISC        ]]

--#region executor
    local executor_code = "util.toast(\"first enter some code dumbass\")"

    local executor_run = function()
        local func = load(executor_code)
        func()
    end

    menu.text_input(executor_list, "Enter code", {"inputLua"}, "enter Lua code to be executed", function(value)
        executor_code = value
    end, executor_code)

    menu.action(executor_list, "Run code", {"executeLua"}, "run the code entered above", function() executor_run() end)
--#endregion

--[[       MAYO       ]]

--#region settings

--#region notifcations
menu.slider(notification_settings_list, "max notifications", {"maxnotifications"}, "maximum amount of notifications", 1, 50, 10, 1, function (value)
    notification.max_notifs = value
end)

menu.slider(notification_settings_list, "width", {"notificationwidth"}, "the width of notifications", 1 , 100, 15, 1, function (value)
    notification.notif_width = value * 0.01
end)

menu.slider(notification_settings_list, "title size", {"notificationtitlesize"}, "title size of notifications", 0, 10, 6, 1, function (value)
    notification.notif_title_size = value * 0.1
end)

menu.slider(notification_settings_list, "text size", {"notificationtextsize"}, "text size of notifications", 0, 10, 5, 1, function (value)
    notification.notif_text_size = value * 0.1
end)

menu.slider(notification_settings_list, "flash duration", {"notificationflashduration"}, "how long a notification wil \"flash\"", 0, 10, 5, 1, function (value)
    notification.notif_text_size = value * 0.1
end)

menu.slider(notification_settings_list, "notification spacing", {"notificationspacing"}, "spacing between notifications", 0, 100, 15, 1, function (value)
    notification.notif_spacing = value * 0.001
end)
menu.toggle(notification_settings_list, "use default notifications", {"notificationusedefault"}, "toggles between the custom and default notfications", function (value)
    notification.use_toast = value
end)
local num = 1
menu.action(notification_settings_list, "test notif", {"testnotif"}, "", function ()
   notification.notify("Title","lorem impulse"..num)
   num = num + 1
end)
--#endregion




--#endregion

--clean up my mess here
util.on_stop(function ()
    GRAPHICS.TERRAINGRID_ACTIVATE(false)
    util.toast("bye bye\nhope you enjoyed mayo")
end)
--keep script running
util.keep_running()