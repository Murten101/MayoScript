util.require_no_lag('natives-1627063482')

local function get_world_pointer()
    local worldPtr = memory.rip(memory.scan('48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08 48 85 C9 74 07') + 3)
    if worldPtr == 0 then
        util.toast("Pattern scan failed. stoping script now")
        util.yield(500)
        util.stop_script()
    end
    return worldPtr
end

b_properties = {}
b_properties.new = function ()
    local self = {}

    self.worldPtr = get_world_pointer()

    self.player_ped_id = function ()
        return PLAYER.PLAYER_PED_ID()
    end 

    return self
end

b_common_funcs = {}
b_common_funcs.new = function ()
    local self = {}
    --credit to Nowiry#2663 and QuickNET#9999 for this one
    self.address_from_pointer_chain = function (basePtr, offsets)
        local addr = memory.read_long(basePtr)
        for k = 1, (#offsets - 1) do
            addr = memory.read_long(addr + offsets[k])
            if addr == 0 then
                return 0
            end
        end
        addr = addr + offsets[#offsets]
        return addr
    end
    self.get_player_vehicle_class = function ()
        local veh = entities.get_user_vehicle_as_handle()
        return VEHICLE.GET_VEHICLE_CLASS(veh)
    end
    self.get_ascpect_ratio = function()
        local screen_x, screen_y = directx.get_client_size()
    
        return screen_x / screen_y
    end
    return self
end


b_math_funcs = {}
b_math_funcs.new = function ()
    local self = {}

    return self
end

b_drawing_funcs = {}
b_drawing_funcs.new = function ()
    local self = {}
    self.draw_arrow = function(pos, angle, size, colour_a, colour_b)
        local angle_cos = math.cos(angle)
        local angle_sin = math.sin(angle)
    
        local width = 0.5 * size
        local length = 1 * size
        local height = 0.25 * size
    
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * -width - angle_sin * -length),
            pos.y + (angle_sin * -width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + -height,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + height,
            colour_b.r,
            colour_b.g,
            colour_b.b,
            colour_b.a
        )
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + -height,
            pos.x + (angle_cos * width - angle_sin * -length),
            pos.y + (angle_sin * width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + height,
            colour_a.r,
            colour_a.g,
            colour_a.b,
            colour_a.a
        )
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * width - angle_sin * -length),
            pos.y + (angle_sin * width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * width),
            pos.y + (angle_sin * 0 + angle_cos * width),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + height,
            colour_a.r,
            colour_a.g,
            colour_a.b,
            colour_a.a
        )
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * 0 - angle_sin * width),
            pos.y + (angle_sin * 0 + angle_cos * width),
            pos.z + 0,
            pos.x + (angle_cos * width - angle_sin * -length),
            pos.y + (angle_sin * width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + -height,
            colour_a.r,
            colour_a.g,
            colour_a.b,
            colour_a.a
        )
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * -width - angle_sin * -length),
            pos.y + (angle_sin * -width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * width),
            pos.y + (angle_sin * 0 + angle_cos * width),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + -height,
            colour_b.r,
            colour_b.g,
            colour_b.b,
            colour_b.a
        )
        GRAPHICS.DRAW_POLY(
            pos.x + (angle_cos * 0 - angle_sin * width),
            pos.y + (angle_sin * 0 + angle_cos * width),
            pos.z + 0,
            pos.x + (angle_cos * -width - angle_sin * -length),
            pos.y + (angle_sin * -width + angle_cos * -length),
            pos.z + 0,
            pos.x + (angle_cos * 0 - angle_sin * -width),
            pos.y + (angle_sin * 0 + angle_cos * -width),
            pos.z + height,
            colour_b.r,
            colour_b.g,
            colour_b.b,
            colour_b.a
        )
    end
    self.draw_quad = function (pos1_org, pos2_org, size, colour_a, colour_b, dict, texture)
        GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(dict, false)
        if GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED(dict) then
            pos1 =  {x = pos1_org.x, y = pos1_org.y, z = pos1_org.z}
            pos2 =  {x = pos2_org.x, y = pos2_org.y, z = pos2_org.z}
            pos2.z = pos2.z - size * 0.5
            pos1.z = pos1.z - size * 0.5
            GRAPHICS.SET_BACKFACECULLING(false)
            GRAPHICS._DRAW_SPRITE_POLY_2(
                pos1.x,     pos1.y,             pos1.z,
                pos2.x,     pos2.y,             pos2.z,
                pos2.x,     pos2.y,             pos2.z + size,
                colour_b.r, colour_b.g, colour_b.b, colour_b.a,
                colour_b.r, colour_b.g, colour_b.b, colour_b.a,
                colour_b.r, colour_b.g, colour_b.b, colour_b.a,
                dict,
                texture,
                0, 1, 0, 
                1, 1, 0,
                0, 0, 0
            )
              GRAPHICS._DRAW_SPRITE_POLY_2(
                pos1.x,     pos1.y,             pos1.z + size,
                pos1.x,     pos1.y,             pos1.z,
                pos2.x,     pos2.y,             pos2.z + size,
                colour_a.r, colour_a.g, colour_a.b, colour_a.a,
                colour_a.r, colour_a.g, colour_a.b, colour_a.a,
                colour_a.r, colour_a.g, colour_a.b, colour_a.a,
                dict,
                texture,
                0, 0, 0,
                1, 1, 0,
                1, 0, 0
            )
        else
            util.toast("not loaded")
        end 
    end
    --all credit to Nowiry#2663 for this one
    self.draw_button_tip = function (buttons, duration, colour)
        function equals(l1, l2)
            if l1 == l2 then return true end
            local type1 = type(l1)
            local type2 = type(l2)
            if type1 ~= type2 then return false end
            if type1 ~= 'table' then return false end
            for k, v in pairs(l1) do
                if not l2[ k ] or not equals(v, l2[ k ]) then
                    return false
                end
            end
            return true
        end
        local timer = 0
        util.create_tick_handler(function ()
            local INSTRUCTIONAL = {}
        INSTRUCTIONAL.scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE('instructional_buttons')
        INSTRUCTIONAL.isKeyboard = PAD._IS_USING_KEYBOARD(2)
    
        if not equals(buttons, INSTRUCTIONAL.currentsettup) or INSTRUCTIONAL.isKeyboard ~= PAD._IS_USING_KEYBOARD(2) then
            local colour = colour or {
                ['r'] = 0,
                ['g'] = 0,
                ['b'] = 0
            }
    
            while not GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(INSTRUCTIONAL.scaleform) do
                util.yield()
            end
            
            GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(INSTRUCTIONAL.scaleform, 'CLEAR_ALL')
            GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    
            GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(INSTRUCTIONAL.scaleform, 'TOGGLE_MOUSE_BUTTONS')
            GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(true)
            GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    
            for i = 1, #buttons do
                GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(INSTRUCTIONAL.scaleform, 'SET_DATA_SLOT')
                GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(i) --position
                GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING(PAD.GET_CONTROL_INSTRUCTIONAL_BUTTON(2, buttons[i][2], true)) --control
                GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(buttons[i][1]) --name
                GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(buttons[i][3] or false) --clickable
                GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(buttons[i][2]) --what control will be pressed when you click the button
                GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
            end
    
            GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(INSTRUCTIONAL.scaleform, 'SET_BACKGROUND_COLOUR')
            GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(colour.r)
            GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(colour.g)
            GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(colour.b)
            GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(80)
            GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    
            GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(INSTRUCTIONAL.scaleform, 'DRAW_INSTRUCTIONAL_BUTTONS')
            GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    
            INSTRUCTIONAL.currentsettup = buttons
            INSTRUCTIONAL.isKeyboard = PAD._IS_USING_KEYBOARD(2)
        end
        GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(INSTRUCTIONAL.scaleform, 255, 255, 255, 255, 0)
        if timer > duration then
            return false
        end
        timer = timer + MISC.GET_FRAME_TIME()
        return true
        end)
    end
    return self
end

b_vectors = {}
b_vectors.new = function ()
    local self = {}

    self.vector2 = {}
    self.vector2.new = function (x, y)
        return {x = x, y = y}
    end
    self.vector2.dot = function(vector_a, vector_b)
        return (vector_a.x * vector_b.x) + (vector_a.y * vector_b.y)
    end
    self.vector2.magnitude = function(vector)
        return math.sqrt((vector.x * vector.x) + (vector.y * vector.y))
    end
    self.vector2.get_angle = function(vector_a, vector_b)
        return math.acos(self.vector2.dot(vector_a, vector_b) / self.vector2.magnitude(vector_a) / self.vector2.magnitude(vector_b))
    end
    return self
end

b_colour = {}
b_colour.new = function ()
    local self = {}
    self.new = function (r, g, b, a)
        return {
            r = r,
            g = g,
            b = b,
            a = a
        }
    end
    self.white = function ()
        return self.new(255, 255, 255, 255)
    end
    self.black = function ()
        return self.new(0, 0, 0, 255)
    end
    self.magenta = function ()
        return self.new(255, 0, 255, 255)
    end
    self.red = function ()
        return self.new(255, 0, 0, 255)
    end
    self.green = function ()
        return self.new(0, 255, 0, 255)
    end
    self.blue = function ()
        return self.new(0, 0, 255, 255)
    end
    self.to_rage = function (colour)
        return {
            r = math.floor(colour.r * 255),
            g = math.floor(colour.g * 255),
            b = math.floor(colour.b * 255),
            a = math.floor(colour.a * 255)
        }
    end
    self.to_stand = function (colour)
        return {
            r = colour.r / 255,
            g = colour.g / 255,
            b = colour.b / 255,
            a = colour.a / 255
        }
    end
    return self
end

b_input = {}
b_input.new = function ()
    local self = {}
    self.jump = function ()
        return PAD.IS_CONTROL_JUST_PRESSED(2, 22)
    end
    self.cancel = function ()
        return PAD.IS_CONTROL_JUST_PRESSED(2, 194)
    end
    return self
end