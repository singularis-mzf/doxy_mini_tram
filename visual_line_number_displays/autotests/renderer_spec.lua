-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

-- Replacement for Font:render().
local function render(_self, text, width, height, style)
    local texture_string =  string.format("[combine:%ix%i:0,0=%s.png", width, height, text);
    if style.color then
        texture_string = texture_string .. "^[colorize:" .. style.color;
    end
    return texture_string;
end

visual_line_number_displays.font = {
    render = render;
}

require("renderer");

-- More readable replacement for texture_escape().
-- Minetest documents texture grouping with parentheses,
-- but the client source code doesn’t even care about it.
local function texture_escape(input)
    return "{" .. input .. "}";
end

visual_line_number_displays.texture_escape = texture_escape;

describe("render_text_block", function()
    local rtb = visual_line_number_displays.render_text_block;

    it("renders plain text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":0,1={[combine:5x8:0,0=A.png}", rtb(block, 1));
    end);

    it("renders superresolution text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":0,2={[combine:5x8:0,0=A.png^[resize:10x16}", rtb(block, 2));
    end);

    it("renders scaled text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
            };
            scale = 0.5;
            position = { x = 1, y = 2 };
            size = { width = 3, height = 4 };
        };

        assert.same(":2,4={[combine:5x8:0,0=A.png}", rtb(block, 2));
    end);

    it("renders deplaced text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 9, height = 16 };
        };

        assert.same(":2,5={[combine:5x8:0,0=A.png}", rtb(block, 1));
    end);

    it("renders deplaced scaled text blocks in superresolution", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
            };
            scale = 0.375;
            position = { x = 15, y = 4 };
            size = { width = 9, height = 16 };
        };

        assert.same(":31,11={[combine:5x8:0,0=A.png^[resize:4x6}", rtb(block, 2));
    end);

    it("renders colored text blocks", function()
        local block = {
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                text_color = "#00ff00";
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        };

        assert.same(":0,1={[combine:5x8:0,0=A.png^[colorize:#00ff00}", rtb(block, 1));
    end);
end);
