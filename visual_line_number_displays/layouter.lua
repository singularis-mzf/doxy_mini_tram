-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Lua 5.1 is incompatible to Lua 5.3 at math.log().
-- Bypass this incompability by using only natural logarithms.
local ln_2_ = 1 / math.log(2);
local function ld(x)
    return math.log(x) * ln_2_;
end

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

--! @class blocks_layout
--! A blocks_layout object describes placement and scale of one row of text blocks.
--!
--! It is a list of tables with these elements:
--! \li @c block The original text_block_description table. (Read-only)
--! \li @c position Table with @c x and @c y, top-left position of scaled block.
--! \li @c scale By which factor the block is scaled up. (Usually less than one.)
--! \li @c size Table with @c width and @c height, painting target of scaled block.
--!
--! It also provides some methods,
--! which allow to compute the optimum layout for this block row.
visual_line_number_displays.blocks_layout = {};

--! Constructs a new blocks_layout table.
--!
--! @param blocks A list of text_block_description tables.
function visual_line_number_displays.blocks_layout:new(blocks)
    local b = {};
    for _, block in ipairs(blocks) do
        table.insert(b, {
                block = block;
                scale = 1;
                position = { x = 0, y = 0 };
                size = {
                    width = block.required_size.width;
                    height = block.required_size.height;
                };
            });
    end;

    setmetatable(b, { __index = self });

    return b;
end

--! Returns the total width of this layout, including 2px spacing.
function visual_line_number_displays.blocks_layout:width()
    local w = 0;

    for _, block in ipairs(self) do
        w = w + block.size.width;
    end

    return w + (2 * (#self - 1));
end

--! Returns the total height of this layout.
function visual_line_number_displays.blocks_layout:height()
    local h = 0;

    for _, block in ipairs(self) do
        h = math.max(h, block.size.height);
    end

    return h;
end

--! Returns the scale of the least scaled down block in this layout.
function visual_line_number_displays.blocks_layout:max_scale()
    local s = nil;

    for _, block in ipairs(self) do
        s = math.max(s or 0, block.scale);
    end

    return s;
end

--! Scales all larger blocks down to @p scale.
function visual_line_number_displays.blocks_layout:set_max_scale(scale)
    for i, block in ipairs(self) do
        if block.scale > scale then
            -- Avoid rounding errors in ld() using factor 0.9.
            self:scale_block(i, (scale / block.scale) * 0.9);
        end
    end
end

--! Scales all blocks down so much that they fit in @p height.
function visual_line_number_displays.blocks_layout:set_max_height(height)
    for i, block in ipairs(self) do
        if block.size.height > height then
            self:scale_block(i, height / block.size.height);
        end
    end
end

--! Returns false if all blocks are at their minimum scale (width = 1).
function visual_line_number_displays.blocks_layout:can_be_shortened()
    for _, block in ipairs(self) do
        if block.size.width > 1 then
            return true;
        end
    end

    return false;
end

--! Scales the block with largest scale (or dimension) one step down.
--!
--! @param what Can be the string @c width or @c height, optional.
function visual_line_number_displays.blocks_layout:shrink(what)
    local max_scale = 0;
    local max_size = 0;

    local block_to_scale = nil;

    for i, block in ipairs(self) do
        if block.scale > max_scale then
            block_to_scale = i;
        elseif what and block.scale == max_scale and block.size[what] > max_size then
            block_to_scale = i;
        end

        max_scale = math.max(max_scale, block.scale);
        max_size = math.max(max_size, block.size[what]);
    end

    if not block_to_scale then
        return;
    end

    -- Scales down one scaling step.
    self:scale_block(block_to_scale, 0.9);
end

--! Scales block @p index by @p factor.
--! Limits scale to powers of two and 1.5 times powers of two.
function visual_line_number_displays.blocks_layout:scale_block(index, factor)
    local block = self[index];

    local new_scale = block.scale * factor;

    local next_power_of_two = 2 ^ math.floor(ld(new_scale));
    local next_power_of_two_times_1_5 = 1.5 * (2 ^ math.floor(ld(new_scale * 0.6667)));

    new_scale = math.max(next_power_of_two, next_power_of_two_times_1_5);

    block.scale = new_scale;
    block.size = {
        width = math.ceil(block.block.required_size.width * new_scale);
        height = math.ceil(block.block.required_size.height * new_scale);
    };
end

--! Moves blocks so they are side-by-side with 2px spacing, centered at @p center.
--!
--! Blocks are not resized or scaled.
--!
--! @param center Table with @c x and @c y.
function visual_line_number_displays.blocks_layout:align(center)
    local total_width = self:width();
    local total_height = self:height();

    local current_x = math.floor(center.x - total_width * 0.5)
    local top = math.floor(center.y - total_height * 0.5)

    for _, block in ipairs(self) do
        local top_margin = math.floor((total_height - block.size.height) * 0.5);

        block.position.x = current_x;
        block.position.y = top + top_margin;

        current_x = current_x + block.size.width + 2;
    end
end

--! Stretches height of all shaped blocks to @p max_height,
--! but not taller than square.
--!
--! Blocks are not repositioned, so you need to call align() afterwards.
function visual_line_number_displays.blocks_layout:stretch_height(max_height)
    for _, block in ipairs(self) do
        if block.block.background_shape then
            block.size.height = math.min(max_height, math.max(block.size.width, block.size.height));
        end
    end
end

--! @class display_layout
--! A display_layout object describes placement and scale of text blocks
--! on a display.
--!
--! It contains three blocks_layout tables called
--! @c number_section, @c text_section and @c details_section.
--! These blocks_layout tables may be empty.
visual_line_number_displays.display_layout = {};

--! Creates a display_layout object from text_block_description table lists.
--!
--! @param number Goes on the left side of the display.
--! @param text Goes on the right side of the display. (Optional)
--! @param details Goes below @p text, with smaller font. (Optional)
function visual_line_number_displays.display_layout:new(number, text, details)
    local d = {
        number_section = visual_line_number_displays.blocks_layout:new(number);
        text_section = visual_line_number_displays.blocks_layout:new(text or {});
        details_section = visual_line_number_displays.blocks_layout:new(details or {});
    };

    -- Details section is a bit smaller.
    d.details_section:set_max_scale(0.75);

    setmetatable(d, { __index = self });

    return d;
end

--! Returns the current width of the layout at the current blocks’ scales.
function visual_line_number_displays.display_layout:width()
    return self.number_section:width() + math.max(self.text_section:width(), self.details_section:width());
end

--! Returns the current height of the layout at the current blocks’ scales.
function visual_line_number_displays.display_layout:height()
    return math.max(self.number_section:height(), self.text_section:height() + self.details_section:height());
end

--! Resizes and arranges blocks so they fit in @p size.
--!
--! @param size Maximum size, table with elements @p width and @p height.
function visual_line_number_displays.display_layout:calculate_layout(size)
    -- First approximation: maximum height.
    self.number_section:set_max_height(size.height);
    self.text_section:set_max_height(size.height);
    self.details_section:set_max_height(size.height);

    -- Shrink to fit.
    while (self.text_section:height() + self.details_section:height()) > size.height do
        local ts = self.text_section:max_scale();
        local ds = self.details_section:max_scale();

        if ts > ds * 1.5 then
            self.text_section:shrink("height");
        else
            self.details_section:shrink("height");
        end
    end

    while self:width() > size.width do
        local ns = self.number_section:max_scale();
        local ts = self.text_section:max_scale();
        local ds = self.details_section:max_scale();

        if ns > (math.max(ts, ds)) then
            self.number_section:shrink("width");
        elseif ts > ds * 1.5 then
            self.text_section:shrink("width");
        else
            self.details_section:shrink("width");
        end
    end

    -- Height stretch for shaped blocks.
    self.number_section:stretch_height(size.height);
    -- Stretch text before details.
    -- Text is less likely to contain shaped blocks,
    -- but if it does, these make better use of stretching.
    self.text_section:stretch_height(size.height - self.details_section:height());
    self.details_section:stretch_height(size.height - self.text_section:height());

    -- Position.
    local width = self:width();
    local number_width = self.number_section:width();

    self.number_section:align({ x = number_width * 0.5, y = size.height * 0.5 });

    local text_x_center = (width + number_width) * 0.5;

    local th = self.text_section:height()
    local dh = self.details_section:height();
    local text_details_y_between = (size.height * 0.5) + (th - dh) * 0.5;
    local text_y_center = text_details_y_between - (th * 0.5);
    local details_y_center = text_details_y_between + (dh * 0.5);

    self.text_section:align({ x = text_x_center, y = text_y_center });
    self.details_section:align({ x = text_x_center, y = details_y_center });
end