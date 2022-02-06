-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

local S = minetest.get_translator("minitram_crafting_recipes");

minitram_crafting_recipes = {};

local steel_ingot = nil;
if minetest.registered_items["technic:carbon_steel_ingot"] then
    steel_ingot = "technic:carbon_steel_ingot";
else
    steel_ingot = "default:steel_ingot";
end

local steel_plate = nil;
if minetest.registered_items["default:ladder_steel"] then
    steel_plate = "default:ladder_steel";
elseif minetest.registered_items["technic:carbon_steel_ingot"] then
    steel_plate = "technic:carbon_steel_ingot";
else
    steel_plate = steel_ingot;
end

-- Minitram pretends to run on battery if technic is available.
local battery = nil;
if minetest.registered_items["technic:blue_energy_crystal"] then
    battery = "technic:blue_energy_crystal";
elseif minetest.registered_items["basic_materials:energy_crystal_simple"] then
    battery = "basic_materials:energy_crystal_simple";
else
    battery = "";
end

local controller = nil;
if minetest.registered_items["technic:control_logic_unit"] then
    controller = "technic:control_logic_unit";
elseif minetest.registered_items["mesecons_luacontroller:luacontroller0000"] then
    controller = "mesecons_luacontroller:luacontroller0000";
elseif minetest.registered_items["mesecons_microcontroller:microcontroller0000"] then
    controller = "mesecons_microcontroller:microcontroller0000";
elseif minetest.registered_items["basic_materials:ic"] then
    controller = "basic_materials:ic";
else
    controller = "";
end

local door = nil;
if minetest.registered_items["doors:door_steel"] then
    door = "doors:door_steel";
else
    door = steel_plate;
end

local gem = nil;
if minetest.registered_items["default:mese_crystal"] then
    gem = "default:mese_crystal";
else
    gem = "";
end

local gear = nil;
if minetest.registered_items["basic_materials:gear_steel"] then
    gear = "basic_materials:gear_steel";
elseif minetest.registered_items["carts:rail"] then
    gear = "carts:rail";
elseif minetest.registered_items["default:ladder_steel"] then
    gear = "default:ladder_steel";
else
    gear = "";
end

local glass = nil;
if minetest.registered_items["xpanes:obsidian_pane_flat"] then
    glass = "xpanes:obsidian_pane_flat";
elseif minetest.registered_items["default:obsidian_glass"] then
    glass = "default:obsidian_glass";
else
    glass = "default:glass";
end

local graphite = nil;
if minetest.registered_items["technic:graphite_rod"] then
    graphite = "technic:graphite_rod";
elseif minetest.registered_items["mesecons:wire_00000000_off"] then
    graphite = "mesecons:wire_00000000_off";
else
    graphite = "default:coal_lump";
end

local insulator = nil;
if minetest.registered_items["technic:rubber"] then
    insulator = "technic:rubber";
elseif minetest.registered_items["mesecons_materials:fiber"] then
    insulator = "mesecons_materials:fiber";
elseif minetest.registered_items["basic_materials:cement_block"] then
    insulator = "basic_materials:cement_block";
else
    insulator = "default:clay_brick";
end

-- Lighting in crafting recipes.
-- Unfortunately, these mods do not provide groups like technical_light.
local lamp = nil;
if minetest.registered_items["morelights_modern:bar_light"] then
    lamp = "morelights_modern:bar_light";
elseif minetest.registered_items["technic:lv_led"] then
    lamp = "technic:lv_led";
else
    lamp = "default:meselamp";
end

local motor = nil;
if minetest.registered_items["technic:motor"] then
    motor = "technic:motor";
elseif minetest.registered_items["basic_materials:motor"] then
    motor = "basic_materials:motor";
elseif minetest.registered_items["default:mese_crystal"] then
    motor = "default:mese_crystal";
else
    motor = "";
end

local paper = "default:paper";

-- Dynamic line number signs in crafting recipes.
-- Unfortunately, these mods do not provide a sign group.
local sign = nil;
-- Make sure that the signs mod is the one from display_modpack.
local signs_modpath = minetest.get_modpath("signs");
if signs_modpath and string.find(signs_modpath, "display_modpack", 1, --[[ plain ]] true) then
    sign = "group:display_api";
elseif minetest.registered_items["digilines:lcd"] then
    sign = "digilines:lcd";
else
    sign = "default:sign_wall_steel";
end

local steel_rod = nil;
if minetest.registered_items["technic:rebar"] then
    steel_rod = "technic:rebar";
elseif minetest.registered_items["basic_materials:steel_bar"] then
    steel_rod = "basic_materials:steel_bar";
else
    steel_rod = steel_ingot;
end

local steel_block = nil;
if minetest.registered_items["technic:carbon_steel_block"] then
    steel_block = "technic:carbon_steel_block";
else
    steel_block = "default:steelblock";
end

local trapdoor = nil;
if minetest.registered_items["doors:trapdoor_steel"] then
    trapdoor = "doors:trapdoor_steel";
elseif minetest.registered_items["doors:door_steel"] then
    trapdoor = "doors:door_steel";
else
    trapdoor = steel_ingot;
end

local wheel = "advtrains:wheel";

local wool = nil;
if minetest.registered_items["lrfurn:armchair_blue"] then
    wool = "lrfurn:armchair_blue";
else
    wool = "wool:blue";
end

local template = "minitram_crafting_recipes:minitram_template";
minetest.register_craftitem(template, {
    description = S("Minitram Template\nCrafting ingredient for Minitram products");
    groups = {
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_template.png";
});

minetest.register_craft({
    output = template;
    recipe = {
        { paper, gem, paper };
        { "group:dye,color_cyan", gem, "group:dye,color_blue" };
        { paper, gear, paper };
    };
});

local seat = "minitram_crafting_recipes:minitram_seat_assembly";
minetest.register_craftitem(seat, {
    description = S("Minitram Seat Assembly\nFolding seat for Minitram vehicles.");
    groups = {
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_seat_assembly.png";
});

minetest.register_craft({
    output = seat;
    recipe = {
        { wool, template, wool };
        { trapdoor, steel_plate, trapdoor };
    };
});

local automatic_door = "minitram_crafting_recipes:minitram_door";
minetest.register_craftitem(automatic_door, {
    description = S("Minitram Automatic Door\nDoor for Minitram vehicles.");
    groups = {
        minitram = 1;
        metal = 1;
    };
    inventory_image = "minitram_crafting_recipes_door_assembly.png";
});

minetest.register_craft({
    output = automatic_door;
    type = "shapeless";
    recipe = { template, motor, steel_ingot, door, glass, glass };
});

local pantograph = "minitram_crafting_recipes:minitram_pantograph";
minetest.register_craftitem(pantograph, {
    description = S("Minitram Pantograph\nOverhead current collector for Minitram vehicles.");
    groups = {
        minitram = 1;
        metal = 1;
    };
    inventory_image = "minitram_crafting_recipes_pantograph.png";
});

minetest.register_craft({
    output = pantograph;
    recipe = {
        { graphite, template, graphite };
        { steel_rod, steel_ingot, steel_rod };
        { insulator, motor, insulator };
    };
});

local body = "minitram_crafting_recipes:minitram_konstal_105_body";
minetest.register_craftitem(body, {
    description = S("Minitram Konstal 105 Body Structure\nA steel shell waiting to be painted.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_konstal_105_body.png";
});

minetest.register_craft({
    output = body;
    recipe = {
        { steel_plate, steel_plate, steel_plate };
        { steel_rod, template, steel_rod };
        { steel_block, steel_block, steel_block };
    };
});


local body_assembly = "minitram_crafting_recipes:minitram_konstal_105_body_assembly";
minetest.register_craftitem(body_assembly, {
    description = S("Minitram Konstal 105 Body Assembly\nA steel shell with some furniture and paint.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_konstal_105_body_assembly.png";
});

minetest.register_craft({
    output = body_assembly;
    recipe = {
        { lamp, glass, lamp };
        { automatic_door, "group:dye,color_orange", automatic_door };
        { seat, body, seat };
    };
});

local bogie = "minitram_crafting_recipes:minitram_bogie";
minetest.register_craftitem(bogie, {
    description = S("Minitram Bogie\nThe “feet” of Minitram vehicles.");
    groups = {
        metal = 1;
        minitram = 1;
    };
    inventory_image = "minitram_crafting_recipes_bogie.png";
});

minetest.register_craft({
    output = bogie;
    recipe = {
        { wheel, steel_block, wheel };
        { motor, template, motor };
        { wheel, steel_block, wheel };
    };
});

local konstal_105 = "minitram_konstal_105:minitram_konstal_105_normal";
minetest.register_craft({
    output = konstal_105;
    recipe = {
        { battery, battery, "minitram_crafting_recipes:minitram_pantograph" };
        { sign, body_assembly, sign };
        { bogie, controller, bogie };
    };
});

-- Cheap additional templates.
minetest.register_craft({
    output = template;
    recipe = {
        { paper, "", paper };
        { "", "group:minitram", "" };
        { paper, "", paper };
    };
    -- preserve option is not implemented.
    replacements = {
        { template, template };
        { seat, seat };
        { door, door };
        { pantograph, pantograph };
        { body, body };
        { body_assembly, body_assembly };
        { bogie, bogie };
        { konstal_105, konstal_105 };
    };
});
