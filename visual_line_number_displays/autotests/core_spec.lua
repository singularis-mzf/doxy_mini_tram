-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("basic_entities");
require("parser");
require("core");

describe("parse_line_number_string", function()
    local plns = visual_line_number_displays.parse_line_number_string;

    it("parses very simple line numbers", function()
        local number, text, details = plns("18");

        local number_reference = {
            {
                text = "18";
                features = {};
            };
        };

        assert.same(number_reference, number);
        assert.same({}, text);
        assert.same({}, details);
    end);

    it("parses usual line numbers 1", function()
        local number, text, details = plns("[6]\nZürich\nüber Basel");

        local number_reference = {
            {
                text = "6";
                background_shape = "square";
                features = {};
            };
        };

        local text_reference = {
            {
                text = "Zürich";
                features = {};
            };
        };

        local details_reference = {
            {
                text = "über Basel";
                features = {};
            };
        };

        assert.same(number_reference, number);
        assert.same(text_reference, text);
        assert.same(details_reference, details);
    end);

    it("parses usual line numbers 2", function()
        local number, text, details = plns("[6]; Zürich; über Basel");

        local number_reference = {
            {
                text = "6";
                background_shape = "square";
                features = {};
            };
        };

        local text_reference = {
            {
                text = "Zürich";
                features = {};
            };
        };

        local details_reference = {
            {
                text = "über Basel";
                features = {};
            };
        };

        assert.same(number_reference, number);
        assert.same(text_reference, text);
        assert.same(details_reference, details);
    end);

    it("parses complex line numbers", function()
        local number, text, details = plns("\\/<RE11>; Köln HBF [U] (S)\nüber: (S) Chorweiler {lpar}tief{rpar}");

        local number_reference = {
            {
                text = "RE11";
                background_shape = "diamond";
                background_pattern = "x_left";
                features = {};
            };
        };

        local text_reference = {
            {
                text = "Köln HBF";
                features = {};
            };
            {
                text = "U";
                background_shape = "square";
                features = {};
            };
            {
                text = "S";
                background_shape = "round";
                features = {};
            };
        };

        local details_reference = {
            {
                text = "über:";
                features = {};
            };
            {
                text = "S";
                background_shape = "round";
                features = {};
            };
            {
                text = "Chorweiler (tief)";
                features = {};
            };
        };

        assert.same(number_reference, number);
        assert.same(text_reference, text);
        assert.same(details_reference, details);
    end);
end);
