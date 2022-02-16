-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

-- Replacement for Minetest’s string:split().
local function split(text, separator)
    local text_lines = {};
    local pos = 1;

    while pos <= #text do
        local found = string.find(text, separator, pos, --[[ plain ]] true);

        if found then
            table.insert(text_lines, string.sub(text, pos, found - 1));
            pos = found + #separator;
        else
            table.insert(text_lines, string.sub(text, pos));
            break;
        end
    end

    -- Include empty match at end of last separator.
    if pos > 1 and pos > #text then
        table.insert(text_lines, "");
    end

    return text_lines;
end

string.split = split;

-- Replacement for Font:get_width().
local function get_width(text)
    return 5 * #text;
end

-- Replacement for Font:get_height().
local function get_height(line_count)
    return 8 * line_count;
end

visual_line_number_displays.font = {
    get_width = get_width;
    get_height = get_height;
};

require("layouter");

describe("calculate_block_size", function()
    local cbs = visual_line_number_displays.calculate_block_size;

    local function wh(w, h)
        return { width = w, height = h };
    end

    local function t(text, shape)
        return {
            text = text;
            background_shape = shape;
            features = {};
        };
    end

    it("calculates size of plain shapeless blocks", function()
        assert.same(wh(0, 0), cbs(t("")).required_size);
        assert.same(wh(0, 0), cbs(t("")).text_size);
        assert.same(wh(5, 8), cbs(t(" ")).required_size);
        assert.same(wh(5, 8), cbs(t("A")).required_size);
        assert.same(wh(35, 8), cbs(t("123 456")).required_size);
        assert.same(wh(0, 16), cbs(t("\n")).required_size);
        assert.same(wh(5, 16), cbs(t("A\n")).required_size);
        assert.same(wh(5, 16), cbs(t("\nB")).required_size);
        assert.same(wh(5, 16), cbs(t("A\nB")).required_size);
        assert.same(wh(10, 16), cbs(t("A\nBc")).required_size);
        assert.same(wh(10, 24), cbs(t("A\nBc\nd")).required_size);
        assert.same(wh(5, 32), cbs(t("A\nB\nC\nD")).required_size);
        assert.same(wh(0, 24), cbs(t("\n\n")).required_size);
        assert.same(wh(60, 8), cbs(t("Hello World!")).required_size);
        assert.same(wh(60, 16), cbs(t("Hello World!\n")).required_size);
        assert.same(wh(60, 16), cbs(t("Hello World!\n")).text_size);
    end);

    it("calculates size of square blocks", function()
        assert.same(wh(4, 4), cbs(t("", "square")).required_size);
        assert.same(wh(9, 12), cbs(t("A", "square")).required_size);
        assert.same(wh(39, 12), cbs(t("123 456", "square")).required_size);
        assert.same(wh(4, 20), cbs(t("\n", "square")).required_size);
        assert.same(wh(9, 20), cbs(t("A\nB", "square")).required_size);
    end);

    it("calculates size of round and diamond blocks", function()
        -- These tests are prone to fail after minor adjustments.
        -- Adjust reference values as needed and appropriate.
        assert.same(wh(2, 2), cbs(t("", "round")).required_size);
        assert.same(wh(3, 3), cbs(t("", "diamond")).required_size);
        assert.same(wh(10, 10), cbs(t("A", "round")).required_size);
        assert.same(wh(13, 13), cbs(t("A", "diamond")).required_size);
        assert.same(wh(39, 12), cbs(t("123 456", "round")).required_size);
        assert.same(wh(59, 16), cbs(t("123 456", "diamond")).required_size);
    end);
end);
