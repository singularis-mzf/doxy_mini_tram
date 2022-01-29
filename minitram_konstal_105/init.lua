-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT
--
-- This file contains functions copied from the JR_E231series_modpack.
-- https://git.bananach.space/JR_E231series_modpack.git
-- SPDX-FileCopyrightText: 2019 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
-- SPDX-License-Identifier: LGPL-2.1-only

local S = minetest.get_translator("minitram_konstal_105");
local V = vector.new;

--! Updates the livery property of @p persistent_data using @p color;
--! and possibly sends feedback and instructions to @p player via chat.
--!
--! Property @c livery of @p persistent_data holds
--! @c component_stack, which is used to modify and assemble the texture;
--! and @c next_layer, which remembers which livery layer shall be changed next.
--!
--! @p player is a player ObjectRef.
--! @p wagon_definition is the advtrains wagon definition, containing these properties:
--! \li @c base_texture is the file name of the constant, lowermost texture layer.
--! \li @c livery_components is a list of tables with @c description and @c texture_file.
--! \li @c initial_livery is a list of tables with @c component (integer) and @c color (string).
--! @p persistent_data is the advtrains data of the wagon.
--! @p color is an #rrggbb or #rrggbbaa string.
--! @p alpha is an optional integer.
--!
--! @returns true if the livery was changed.
local function calculate_livery(player, wagon_definition, persistent_data, color, alpha)
    -- Parse RGB component values (0..255).
    local r, g, b, a;
    if string.find(color, "^#%x%x%x%x%x%x$") then
        r = tonumber(string.sub(color, 2, 3), 16);
        g = tonumber(string.sub(color, 4, 5), 16);
        b = tonumber(string.sub(color, 6, 7), 16);
        if #color == 9 then
            a = tonumber(string.sub(color, 8, 9), 16);
        else
            a = tonumber(alpha);
        end
    else
        minetest.chat_send_player(player:get_player_name(), S("This tool has invalid color: @1", color));
        return;
    end

    -- Initialize component stack.
    if type(persistent_data.livery) ~= "table" then
        persistent_data.livery = wagon_definition.initial_livery;
    end

    -- A meta painting operation is when the player chooses certain special
    -- colors, e. g. to choose which livery layer shall be painted next.
    local is_meta_color;
    if a then
        is_meta_color = r == 0 and a == 0;
    else 
        is_meta_color = r == 0;
    end

    if is_meta_color then
        local undefined_text;
        if a then
            undefined_text = S("Undefined meta color. Paint #000000 0% for help.");
        else
            undefined_text = S("Undefined meta color. Paint #000000 for help.");
        end

        -- Meta painting commands consist of the G and B component.
        if g == 0 and b == 0 then
            -- Help text requested.
            local meta_definition;
            if a then
                meta_definition = S("Meta colors have red and alpha components set to zero.");
            else
                meta_definition = S("Meta colors have the red component set to zero.");
            end

            local choices = {};
            for i, v in ipairs(wagon_definition.livery_components) do
                table.insert(choices, S(" * N = @1 — @2", i, v.description));
            end
            choices = table.concat(choices, "\n");

            local current_components = {};
            if #persistent_data.livery.component_stack >= 1 then
                for i, v in ipairs(persistent_data.livery.component_stack) do
                    table.insert(current_components, S("@1.: @2 @3", i, v.component, v.color));
                end
                current_components = table.concat(current_components, S(" — "));
            else
                current_components = S("nothing");
            end

            local help_text = S([[
This wagon offers multiple livery components. To access them, you can paint some “meta colors”, which are explained here. @1
 * Green == 0 — Commands
    - Blue == 0 — Print this help text.
 * Green == N; 1 ≤ N ≤ 254 — Select livery component N to paint next.
    - Blue == 0 — Paint livery component on its current position or on top.
    - Blue == L; 1 ≤ L ≤ 254 — Move livery component to layer L. Higher L goes on top of lower L.
    - Blue == 255 — Remove livery component N.
You can choose from these livery components:
@2
Current livery: @3
]], meta_definition, choices, current_components);
            minetest.chat_send_player(player:get_player_name(), help_text);
        elseif g == 0 then
            -- Undefined meta color painted.
            minetest.chat_send_player(player:get_player_name(), undefined_text);
        elseif g <= 254 then
            -- Livery component selection requested.
            -- The G component chooses the livery component which to paint next.
            -- The B component chooses on which layer the component shall go.

            -- Find the layer of the selected component.
            persistent_data.livery.next_layer = nil;
            for i, layer in ipairs(persistent_data.livery.component_stack) do
                if layer.component == g then
                    persistent_data.livery.next_layer = i;
                    break;
                end
            end

            if b == 0 then
                -- Append the requested component if it is not yet used.
                if not persistent_data.livery.next_layer then
                    local layer = {
                        component = g;
                        color = "#ff00ff"; -- Magenta, for highlighting.
                    };
                    table.insert(persistent_data.livery.component_stack, layer);

                    -- Select for painting.
                    persistent_data.livery.next_layer = #persistent_data.livery.component_stack;
                    return true;
                end
            elseif b >= 1 and b <= 254 then
                -- Insert component in the layer stack.
                local current_color = "#ff00ff"; -- Magenta, as fallback.

                -- Remove from stack if already used.
                if persistent_data.livery.next_layer then
                    current_color = persistent_data.livery.component_stack[persistent_data.livery.next_layer].color;
                    table.remove(persistent_data.livery.component_stack, persistent_data.livery.next_layer);
                end

                -- Insert at new position.
                local layer = {
                    component = g;
                    color = current_color;
                };
                local new_position = math.min(#persistent_data.livery.component_stack + 1, b);
                table.insert(persistent_data.livery.component_stack, new_position, layer);

                -- Select for painting.
                persistent_data.livery.next_layer = new_position;
                return true;
            elseif b == 255 then
                -- Remove component from the layer stack.
                if persistent_data.livery.next_layer then
                    table.remove(persistent_data.livery.component_stack, persistent_data.livery.next_layer)

                    -- Deselect for painting.
                    persistent_data.livery.next_layer = nil;
                    return true;
                end
            end
        else
            -- Undefined meta color painted.
            minetest.chat_send_player(player:get_player_name(), undefined_text);
        end
    else
        -- Non-meta color painted.
        if not persistent_data.livery.next_layer then
            -- No layer selected, warn player.
            local error_message;
            if a then
                error_message = S("No livery component selected. Paint #000000 0% for help.");
            else
                error_message = S("No livery component selected. Paint #000000 for help.");
            end
            minetest.chat_send_player(player:get_player_name(), error_message);
        else
            -- Paint layer and update textures.
            local color_string = string.format("#%02x%02x%02x", r, g, b);
            persistent_data.livery.component_stack[persistent_data.livery.next_layer].color = color_string;
            return true;
        end
    end
end

--! Updates the livery of a wagon using the unofficial API introduced in
--! advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_livery method of a wagon definition.
--! This function is then called when the player punches the wagon
--! with a painting tool.
--!
--! Calls set_textures() automatically.
--!
--! @param self A lua entity of the wagon definition.
--! @param puncher The player, not used here.
--! @param itemstack The tool used by the player. Carries color data.
--! @param persistent_data advtrains data of the wagon.
local function set_livery(self, puncher, itemstack, persistent_data)
    -- This function comes from the JR_E231series_modpack.
    local meta = itemstack:get_meta();
    local color = meta:get_string("paint_color");
    local alpha = meta:get_string("alpha");
    if color then
        if calculate_livery(puncher, self, persistent_data, color, alpha) then
            self:set_textures(persistent_data);
        end
    end
end

--! Updates the livery of a wagon using the unofficial API introduced in
--! advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_textures method of a wagon definition.
--! This function is then called by advtrains when the livery is needed.
--!
--! @param self A lua entity of the wagon definition.
--! @param persistent_data advtrains data of the wagon.
local function set_textures(self, persistent_data)
    -- This function comes from the JR_E231series_modpack.
    if persistent_data.livery and persistent_data.livery.component_stack then
        local textures = { self.base_texture };
        for _, layer in ipairs(persistent_data.livery.component_stack) do
            -- Create a texture overlay.
            -- Because of version updates, the livery component stack may
            -- refer to not existing livery components. Skip those.
            local component = self.livery_components[layer.component];
            if component then
                table.insert(textures, "(" .. component.texture_file .. "^[multiply:" .. layer.color .. ")");
            end
        end
        self.object:set_properties({
            textures = { table.concat(textures, "^") };
        });
    end
end

local konstal_105_definition = {
    mesh = "minitram_konstal_105_normal.b3d";
    textures = { "minitram_konstal_105_normal_base_texture.png" }; -- Contains initial livery, necessary as fallback.
    drives_on = {
        default = true;
    };
    max_speed = 20; -- 72km/h is the actual maximum speed of Konstal 105Na.
    seats = {
        {
            name = S("Front Driver Stand");
            attach_offset = V(-2, 2, 37);
            view_offset = V(0, 0, 0);
            group = "driver_stands";
        };
        {
            name = S("Passenger Area 1");
            attach_offset = V(3, 2, 39);
            view_offset = V(0, 0, 0);
            group = "passenger_area_1";
        };
    };
    seat_groups = {
        driver_stands = {
            name = S("Driver Stands");
            access_to = { "passenger_area_1" };
            require_doors_open = true;
            driving_ctrl_access = true;
        };
        passenger_area_1 = {
            name = S("Passenger Area");
            access_to = { "driver_stands" };
            require_doors_open = true;
            driving_ctrl_access = false;
        };
    };
    assign_to_seat_group = {
        "driver_stands";
        "passenger_area_1";
    };
    doors = {
        open = {
            [-1] = {
                frames = { x = 0, y = 23 }; -- Somehow there is bleed from the closing animation, so drop the last two frames.
                time = 1; -- Time setting is broken; must be done in Blender.
            };
            [1] = {
                frames = { x = 50, y = 73 };
                time = 1;
            };
        };
        close = {
            [-1] = {
                frames = { x = 25, y = 50 };
                time = 1;
            };
            [1] = {
                frames = { x = 75, y = 100 };
                time = 1;
            };
        };
    };
    door_entry = { -3.5, 0, 3.5 };
    visual_size = V(1, 1, 1); -- For Blender 10m = Minetest 1m scaling. Scale 1m = 1m can not be used because that makes the player extremey big.
    wagon_span = 4.7; -- Wagon length ~~ 8.9m => Coupling distance ~~ 9.4 m.
    is_locomotive = true;
    collisionbox = { -1.5, -0.5, -1.5, 1.5, 2.5, 1.5 };
    livery_components = {
        {
            description = S("Side walls");
            texture_file = "minitram_konstal_105_normal_livery_walls.png";
        };
        {
            description = S("Window background strip");
            texture_file = "minitram_konstal_105_normal_livery_window_strip.png";
        };
        {
            description = S("Doors");
            texture_file = "minitram_konstal_105_normal_livery_doors.png";
        };
        {
            description = S("Lower skirt");
            texture_file = "minitram_konstal_105_normal_livery_skirt.png";
        };
        {
            description = S("Front Area");
            texture_file = "minitram_konstal_105_normal_livery_front.png";
        };
        {
            description = S("Back Area");
            texture_file = "minitram_konstal_105_normal_livery_back.png";
        };
        {
            description = S("Stripes on skirt");
            texture_file = "minitram_konstal_105_normal_livery_stripes.png";
        };
        {
            description = S("Window detail");
            texture_file = "minitram_konstal_105_normal_livery_window_detail.png";
        };
        {
            description = S("Bumper");
            texture_file = "minitram_konstal_105_normal_livery_bumper.png";
        };
        {
            description = S("Bumper bar");
            texture_file = "minitram_konstal_105_normal_livery_bumper_bar.png";
        };
        {
            description = S("Front lights");
            texture_file = "minitram_konstal_105_normal_livery_lights.png";
        };
    };
    base_texture = "minitram_konstal_105_normal_base_texture.png";
    initial_livery = {
        component_stack = {
            {
                component = 1;
                color = "#ffa200";
            };
            {
                component = 4;
                color = "#ea0303";
            };
            {
                component = 9;
                color = "#080809";
            };
            {
                component = 8;
                color = "#131413";
            };
            {
                component = 2;
                color = "#0f0f0e";
            };
        };
        next_layer = 1;
    };
    set_livery = set_livery;
    set_textures = set_textures;
    drops = { "default:steelblock 4" };
};

advtrains.register_wagon("minitram_konstal_105:minitram_konstal_105_normal", konstal_105_definition, S("Minitram Konstal 105 Two-Way Version"), "black.png");
