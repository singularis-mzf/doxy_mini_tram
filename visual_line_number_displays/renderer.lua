-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Escapes @p input for use in Minetest texture strings.
--!
--! This is shit, Minetest should just implement parentheses correctly,
--! and everything would be cool.
--! (Honestly, the whole texture string syntax is shit.)
function visual_line_number_displays.texture_escape(input)
    return string.gsub(input, "[:^]", "\\%1");
end

--! Makes a texture string depicting @p block.
--!
--! Result needs to be added to a @c combine modifier.
--! It is returned with leading colon, and sufficiently escaped.
--!
--! @param block Layouted block; element from a blocks_layout table.
--! @param sr_scale superresolution scaling factor for this display.
function visual_line_number_displays.render_text_block(block, sr_scale)
    -- Calculate block position and size in superresolution coordinates.
    -- Because superresolution scales are integers, no rounding is needed here.
    local block_position = {
        x = block.position.x * sr_scale;
        y = block.position.y * sr_scale;
    };
    local block_size = {
        width = block.size.width * sr_scale;
        height = block.size.height * sr_scale;
    };

    -- Calculate text position and size in block coordinates.
    local block_text_position = {
        x = (block.block.required_size.width - block.block.text_size.width) * 0.5;
        y = (block.block.required_size.height - block.block.text_size.height) * 0.5;
    };

    -- Calculate text position and size in layout coordinates.
    local layout_text_position = {
        x = block.position.x + block_text_position.x * block.scale;
        y = block.position.y + block_text_position.y * block.scale;
    };
    local layout_text_size = {
        width = block.block.text_size.width * block.scale;
        height = block.block.text_size.height * block.scale;
    };

    -- Calculate text position and size in superresolution coordinates.
    -- Exactly here we need rounding,
    -- because block scales are not integers and should line up in superresolution.
    local text_position = {
        x = math.floor(layout_text_position.x * sr_scale);
        y = math.floor(layout_text_position.y * sr_scale);
    };
    local text_size = {
        width = math.ceil(layout_text_size.width * sr_scale);
        height = math.ceil(layout_text_size.height * sr_scale);
    };

    -- Render text.
    local text_color = block.block.text_color;
    if text_color == "black" or text_color == "#000000" then
        text_color = nil;
    end
    local text_style = {
        halign = "center";
        color = text_color;
    };
    local text_texture = visual_line_number_displays.font:render(block.block.text, block.block.text_size.width, block.block.text_size.height, text_style);

    local total_text_scale = block.scale * sr_scale;
    if total_text_scale ~= 1 then
        text_texture = text_texture .. string.format("^[resize:%ix%i", text_size.width, text_size.height);
    end

    text_texture = visual_line_number_displays.texture_escape(text_texture);

    text_texture = string.format(":%i,%i=", text_position.x, text_position.y) .. text_texture;

    return text_texture;
end

--! Makes a texture string depicting @p layout.
--!
--! Result is a stand-alone texture string.
--! @p layout starts with top-left at origin.
--!
--! @param layout A display_layout table.
--! @param sr_scale superresolution scaling factor for this display.
function visual_line_number_displays.render_layout(layout, sr_scale)
    local bottom_right = layout:bottom_right();
    local size = {
        width = bottom_right.x * sr_scale;
        height = bottom_right.y * sr_scale;
    }

    local texture_string = string.format("[combine:%ix%i", size.width, size.height);

    local block_strings = {};
    for _, section in ipairs({ layout.number_section, layout.text_section, layout.details_section }) do
        for _, block in ipairs(section) do
            table.insert(block_strings, visual_line_number_displays.render_text_block(block, sr_scale));
        end
    end

    if not next(block_strings) then
        return nil;
    end

    return texture_string .. table.concat(block_strings);
end
