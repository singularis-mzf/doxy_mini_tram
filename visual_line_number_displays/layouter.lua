-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Calculates the necessary bounding box for @p block at 1:1 scale.
--!
--! Includes multi-line text and background shapes.
--!
--! @returns Table with @c required_size and @c text_size,
--! which contain @c width and @c height each.
function visual_line_number_displays.calculate_block_size(block)
    local text_lines = string.split(block.text, "\n", --[[ include_empty ]] true);

    local width = 0;
    for _, line in ipairs(text_lines) do
        width = math.max(visual_line_number_displays.font.get_width(line), width);
    end

    local height = visual_line_number_displays.font.get_height(#text_lines);

    local required_width = width;
    local required_height = height;

    if block.background_shape == "square" then
        required_width = width + 4;
        required_height = height + 4;
    elseif block.background_shape == "round" then
        if width <= (height * 2) then
            -- Make a circle at least as wide as high.
            local wh = math.ceil((width + height + 3) * 0.6);
            required_width = wh;
            required_height = wh;
        else
            -- Stretch the rounded rectangle to fit around the text.
            local wh = math.ceil(height * 0.2);
            required_width = width + 2 + wh;
            required_height = height + 2 + wh;
        end
    elseif block.background_shape == "diamond" then
        if width <= (height * 2) then
            -- Make the diamond at least as wide as high.
            local wh = math.ceil((width + height + 3) * 0.8);
            required_width = wh;
            required_height = wh;
        else
            -- Stretch the diamond to fit around the text.
            required_width = math.ceil((width + 1.5) * 1.6);
            required_height = math.ceil((height + 1.5) * 1.6);
        end
    end

    return {
        text_size = { width = width, height = height };
        required_size = { width = required_width, height = required_height };
    };
end

function visual_line_number_displays.calculate_blocks_sizes(blocks)
    for _, block in ipairs(blocks) do
        local size = visual_line_number_displays.calculate_block_size(block);
        block.required_size = size.required_size;
        block.text_size = size.text_size;
    end
end
