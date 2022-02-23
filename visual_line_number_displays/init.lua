-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

visual_line_number_displays = {};

visual_line_number_displays.font = font_api.get_font("metro");

local modpath = minetest.get_modpath("visual_line_number_displays")
dofile(modpath .. "/api.lua");
dofile(modpath .. "/basic_entities.lua");
dofile(modpath .. "/colorizer.lua");
dofile(modpath .. "/core.lua");
dofile(modpath .. "/layouter.lua");
dofile(modpath .. "/parser.lua");
dofile(modpath .. "/renderer.lua");
