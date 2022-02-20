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
function visual_line_number_displays.parse_line_number_string(input)
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

    visual_line_number_displays.parse_entities_in_blocks(number_blocks);
    visual_line_number_displays.parse_entities_in_blocks(text_blocks);
    visual_line_number_displays.parse_entities_in_blocks(details_blocks);

    return number_blocks, text_blocks, details_blocks;
end
