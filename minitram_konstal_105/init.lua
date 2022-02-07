-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105");
local V = vector.new;

local konstal_105_definition = {
    mesh = "minitram_konstal_105_normal.b3d";
    textures = {
        -- Entirely empty image.
        "minitram_konstal_105_normal_line_number_signs_base_texture.png";
        -- Default texture, available even without the livery mod.
        "minitram_konstal_105_normal_base_texture.png"
    };
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
        -- Somehow there is bleed from the closing animation,
        -- so drop the last two frames of the opening animation.
        --
        -- Time setting is broken; must be done in Blender.
        open = {
            [-1] = {
                frames = { x = 0, y = 23 };
                time = 1;
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

    -- This needs to be 1, so Blender 10m = Minetest 1m.
    -- If it was scaling to Blender 1m, the attached players would be huge.
    visual_size = V(1, 1, 1);

    wagon_span = 4.7; -- Wagon length ~~ 8.9m => Coupling distance ~~ 9.4 m.
    is_locomotive = true;
    collisionbox = { -1.5, -0.5, -1.5, 1.5, 2.5, 1.5 };
    drops = { "default:steelblock 4" };
};

if minitram_konstal_105_liveries and minitram_konstal_105_liveries.add_liveries_konstal_105 then
    minitram_konstal_105_liveries.add_liveries_konstal_105(konstal_105_definition);
end

local item_name = "minitram_konstal_105:minitram_konstal_105_normal"
advtrains.register_wagon(item_name, konstal_105_definition, S("Minitram Konstal 105\nKonstal 111N adapted to advtrains gauge."), "minitram_konstal_105_normal_inv.png");

-- Add group to e. g. allow crafting templates from this wagon.
local groups = table.copy(minetest.registered_items[item_name].groups);
groups.minitram = 1;
minetest.override_item(item_name, { groups = groups });
