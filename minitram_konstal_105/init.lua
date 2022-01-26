-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105");
local V = vector.new;

local konstal_105_definition = {
    mesh = "minitram_konstal_105_normal.b3d";
    textures = { "minitram_konstal_105_normal_base_texture.png" };
    drives_on = {
        default = true;
    };
    max_speed = 20; -- 72km/h is the actual maximum speed of Konstal 105Na.
    seats = {
        {
            name = S("Front Driver Stand");
            attach_offset = V(-4, 10, 25);
            view_offset = V(0, 0, 0);
            group = "driver_stands";
        };
        {
            name = S("Passenger Area 1");
            attach_offset = V(4, 10, 20);
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
    visual_size = V(10, 10, 10); -- For Blender 1m = Minetest 1m scaling.
    wagon_span = 4.5; -- Wagon length ~~ 8.5m => Coupling distance ~~ 9 m.
    is_locomotive = true;
    drops = { "default:steelblock 4" };
};

advtrains.register_wagon("minitram_konstal_105:minitram_konstal_105_normal", konstal_105_definition, S("Minitram Konstal 105 Two-Way Version"), "black.png");
