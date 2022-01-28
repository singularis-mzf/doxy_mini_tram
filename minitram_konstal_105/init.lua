-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105");
local V = vector.new;

--! Updates the livery of a wagon using the unofficial API introduced in
--! advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_livery method of a wagon definition.
--! This function is then called when the player punches the wagon
--! with a painting tool.
--!
--! Calls set_textures() automatically.
--!
--! @param self The advtrains wagon definition.
--! @param puncher The player, not used here.
--! @param itemstack The tool used by the player. Carries color data.
--! @param persistent_data advtrains data of the wagon.
local function set_livery(self, _puncher, itemstack, persistent_data)
    -- This function comes from the JR_E231series_modpack.
    -- https://git.bananach.space/JR_E231series_modpack.git
    -- SPDX-FileCopyrightText: 2019 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
    -- SPDX-License-Identifier: LGPL-2.1-only
    local meta = itemstack:get_meta();
    local color = meta:get_string("paint_color");
    local alpha = meta:get_string("alpha");
    if color and color:find("^#%x%x%x%x%x%x$") then
--         calculate_livery(puncher, persistent_data, color, alpha);
        persistent_data.livery = "minitram_konstal_105_normal_base_texture.png^(minitram_konstal_105_normal_livery_base.png^[multiply:" .. color .. ")";
        self:set_textures(persistent_data);
    end
end

--! Updates the livery of a wagon using the unofficial API introduced in
--! advtrains commit b71c72b4ab.
--!
--! This function needs to be the @c set_textures method of a wagon definition.
--! This function is then called by advtrains when the livery is needed.
--!
--! @param self The advtrains wagon definition.
--! @param persistent_data advtrains data of the wagon.
local function set_textures(self, persistent_data)
    -- This function comes from the JR_E231series_modpack.
    -- https://git.bananach.space/JR_E231series_modpack.git
    -- SPDX-FileCopyrightText: 2019 Gabriel Pérez-Cerezo <gabriel@gpcf.eu>
    -- SPDX-License-Identifier: LGPL-2.1-only
    if persistent_data.livery then
        self.object:set_properties({
            textures = { persistent_data.livery };
        });
    end
end

--! Updates the livery property of @p data using @p color and @p alpha,
--! and sends feedback to @p player.

local konstal_105_definition = {
    mesh = "minitram_konstal_105_normal.b3d";
    textures = { "minitram_konstal_105_normal_base_texture.png^(minitram_konstal_105_normal_livery_base.png^[multiply:#ff8822)" };
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
    wagon_span = 4.6; -- Wagon length ~~ 8.8m => Coupling distance ~~ 9.2 m.
    is_locomotive = true;
    collisionbox = { -1.5, -0.5, -1.5, 1.5, 2.5, 1.5 };
    set_livery = set_livery;
    set_textures = set_textures;
    drops = { "default:steelblock 4" };
};

advtrains.register_wagon("minitram_konstal_105:minitram_konstal_105_normal", konstal_105_definition, S("Minitram Konstal 105 Two-Way Version"), "black.png");
