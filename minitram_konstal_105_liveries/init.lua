-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_konstal_105_liveries");

minitram_konstal_105_liveries = {};

function minitram_konstal_105_liveries.add_liveries_konstal_105(wagon_definition)
    local livery_definition = {
        components = {
            {
                description = S("Side walls");
                texture_file = "minitram_konstal_105_liveries_normal_livery_walls.png";
            };
            {
                description = S("Window background strip");
                texture_file = "minitram_konstal_105_liveries_normal_livery_window_strip.png";
            };
            {
                description = S("Doors");
                texture_file = "minitram_konstal_105_liveries_normal_livery_doors.png";
            };
            {
                description = S("Lower skirt");
                texture_file = "minitram_konstal_105_liveries_normal_livery_skirt.png";
            };
            {
                description = S("Front Area");
                texture_file = "minitram_konstal_105_liveries_normal_livery_front.png";
            };
            {
                description = S("Back Area");
                texture_file = "minitram_konstal_105_liveries_normal_livery_back.png";
            };
            {
                description = S("Stripes on skirt");
                texture_file = "minitram_konstal_105_liveries_normal_livery_stripes.png";
            };
            {
                description = S("Window detail");
                texture_file = "minitram_konstal_105_liveries_normal_livery_window_detail.png";
            };
            {
                description = S("Bumper");
                texture_file = "minitram_konstal_105_liveries_normal_livery_bumper.png";
            };
            {
                description = S("Bumper bar");
                texture_file = "minitram_konstal_105_liveries_normal_livery_bumper_bar.png";
            };
            {
                description = S("Front lights");
                texture_file = "minitram_konstal_105_liveries_normal_livery_lights.png";
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
            active_layer = 1;
        };
    };

    local livery_texture_slot = 2;

    multi_component_liveries.setup_advtrains_wagon(wagon_definition, livery_definition, livery_texture_slot);
end
