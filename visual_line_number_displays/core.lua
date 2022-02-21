-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

local section_end_characters = {
    ["\n"] = true;
    [";"] = true;
};

--! Returns whether @p block ends a display section,
--! and in that case returns the visible text of the block,
--! or nil if it is not visible.
--!
--! @returns ends_section; visible_part or nil.
function visual_line_number_displays.ends_section(block)
    -- TODO I believe all semicolon blocks are exactly ";" anyway.
    if block.background_shape then
        -- Shaped blocks never end sections.
        return false;
    elseif section_end_characters[string.sub(block.text, -1)] then
        -- Shapeless block ends in certain character. Remove that character.
        local text = string.sub(block.text, 1, -2);
        if text ~= "" then
            return true, text;
        else
            return true, nil;
        end
    else
        return false;
    end
end

--! Converts @p input from a line number string (with blocks syntax)
--! to lists of blocks describing a line number display section each.
--!
--! @returns number_blocks, text_blocks, details_blocks,
--! which are lists of text_block_description tables.
function visual_line_number_displays.parse_display_string(input)
    local block_list = visual_line_number_displays.parse_text_block_string(input);

    local number_blocks = {};
    local text_blocks = {};
    local details_blocks = {};

    local block = 1;

    for _, section in ipairs({ number_blocks, text_blocks }) do
        while block <= #block_list do
            local is_end, visible_text = visual_line_number_displays.ends_section(block_list[block]);
            if is_end and visible_text then
                block_list[block].text = visible_text;
                table.insert(section, block_list[block]);
                block = block + 1;
                break;
            elseif is_end then
                block = block + 1;
                break;
            else
                table.insert(section, block_list[block]);
                block = block + 1;
            end
        end
    end

    for i = block, #block_list do
        table.insert(details_blocks, block_list[i]);
    end

    visual_line_number_displays.parse_line_breaks_in_blocks(number_blocks);
    visual_line_number_displays.parse_line_breaks_in_blocks(text_blocks);
    visual_line_number_displays.parse_line_breaks_in_blocks(details_blocks);

    visual_line_number_displays.parse_entities_in_blocks(number_blocks);
    visual_line_number_displays.parse_entities_in_blocks(text_blocks);
    visual_line_number_displays.parse_entities_in_blocks(details_blocks);

    visual_line_number_displays.calculate_block_sizes(number_blocks);
    visual_line_number_displays.calculate_block_sizes(text_blocks);
    visual_line_number_displays.calculate_block_sizes(details_blocks);

    return number_blocks, text_blocks, details_blocks;
end

--! Returns a texture string.
--!
--! @param display_description A display_description table.
--! @param display_string The string used for the outside train display.
function visual_line_number_displays.render_displays(display_description, display_string)
    if #display_description.displays == 0 then
        return "";
    end

    local number, text, details = visual_line_number_displays.parse_display_string(display_string);

    local layouts = {};
    local superresolution = 1;

    for _, display in ipairs(display_description.displays) do
        -- Layout
        local layout;
        if display.level == "number" then
            layout = visual_line_number_displays.display_layout:new(number);
        elseif display.level == "text" then
            layout = visual_line_number_displays.display_layout:new(number, text);
        else
            layout = visual_line_number_displays.display_layout:new(number, text, details);
        end

        layout:calculate_layout(display.max_width, display.height);

        -- Required superresolution
        superresolution = math.max(superresolution, layout:required_superresolution());

        -- Horizontal alignment
        local used_width = layout:width();
        local center_to_left = display.center_width;
        local center_to_right = display.max_width - display.center_width;

        if (used_width * 0.5) >= center_to_left then
            -- Left align
            layout.x_offset = 0;
        elseif (used_width * 0.5) >= center_to_right then
            -- Right align
            layout.x_offset = display.max_width - used_width;
        else
            -- Center align
            layout.x_offset = math.floor(display.center_width - (used_width * 0.5));
        end

        table.insert(layouts, layout);
    end

    local texture_size = {
        width = display_description.base_resolution.width * superresolution;
        height = display_description.base_resolution.height * superresolution;
    };
    local texture_string = string.format("[combine:%ix%i", texture_size.width, texture_size.height);

    local layout_strings = {}
    for i = 1, #display_description.displays do
        local layout_texture = visual_line_number_displays.render_layout(layouts[i], superresolution);
        layout_texture = visual_line_number_displays.texture_escape(layout_texture);
        local layout_position = {
            x = display_description.displays[i].position.x + layouts[i].x_offset * superresolution;
            y = display_description.displays[i].position.y * superresolution;
        };
        layout_texture = string.format(":%i,%i=", layout_position.x, layout_position.y) .. layout_texture;

        table.insert(layout_strings, layout_texture);
    end

    return texture_string .. table.concat(layout_strings);
end

--! Updates the line number display textures of a wagon,
--! using the data available in the wagon (part of @p {...}),
--! and the definition consisting of @p display_description and @p slot.
--!
--! This function needs to be called from custom_on_step() of an advtrains wagon.
--!
--! @param display_description A display_description table.
--! @param slot Which texture slot shall receive the displays.
--! @param {...} Arguments passed to custom_on_step().
function visual_line_number_displays.advtrains_wagon_on_step(display_description, slot, ...)
    local self, _dtime, _data, train = ...;

    local display_string = train.text_outside or "";

    if display_string == self.display_string_cache then
        return;
    end

    self.display_string_cache = display_string;

    local texture = visual_line_number_displays.render_displays(display_description, display_string);

    local textures = self.object:get_properties().textures;
    textures[slot] = texture;
    self.object:set_properties({ textures = textures });
end
