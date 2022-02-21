-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path
package.path = "visual_line_number_displays/autotests/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("layouter");
require("renderer");

require("render_mocks");

describe("render_text_block()", function()
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

        assert.same(":30,10={[combine:5x8:0,0=A.png^[resize:4x6}", rtb(block, 2));
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

describe("render_layout()", function()
    local rl = visual_line_number_displays.render_layout;

    it("renders deplaced scaled text blocks in superresolution", function()
        local number_section = {{
            block = {
                text = "A";
                required_size = { width = 9, height = 16 };
                text_size = { width = 5, height = 8 };
            };
            scale = 0.375;
            position = { x = 15, y = 4 };
            size = { width = 9, height = 16 };
        }};

        local details_section = {{
            block = {
                text = "A";
                required_size = { width = 5, height = 8 };
                text_size = { width = 5, height = 8 };
                text_color = "#00ff00";
            };
            scale = 1;
            position = { x = 0, y = 1 };
            size = { width = 5, height = 8 };
        }};

        local layout = visual_line_number_displays.display_layout:new({});
        layout.number_section = number_section;
        layout.details_section = details_section;

        assert.same("[combine:48x40:30,10={[combine:5x8:0,0=A.png^[resize:4x6}:0,2={[combine:5x8:0,0=A.png^[colorize:#00ff00^[resize:10x16}", rl(layout, 2));
    end);
end);
