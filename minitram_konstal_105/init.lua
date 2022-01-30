-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105");
local V = vector.new;

local livery_definition = {
    components = {
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
    base_texture_file = "minitram_konstal_105_normal_base_texture.png";
    initial_livery = {
        layers = {
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
};

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
    drops = { "default:steelblock 4" };
};

multi_component_liveries.setup_advtrains_wagon(konstal_105_definition, livery_definition);

advtrains.register_wagon("minitram_konstal_105:minitram_konstal_105_normal", konstal_105_definition, S("Minitram Konstal 105 Two-Way Version"), "black.png");
