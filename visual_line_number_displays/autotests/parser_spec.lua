-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "visual_line_number_displays/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.visual_line_number_displays = {};

require("parser");
require("basic_entities");

describe("parse_text_block_string()", function()
    -- Calls parse_text_block_string(), but removes empty tables like features.
    local function ptbs(text)
        local result = visual_line_number_displays.parse_text_block_string(text);

        for _, block in ipairs(result) do
            if not next(block.features) then
                block.features = nil;
            end
        end

        return result;
    end

    it("parses very plain texts", function()
        assert.same({{ text = "1" }}, ptbs("1"));
        assert.same({{ text = "S30" }}, ptbs("S30"));
        assert.same({{ text = "Porta Westfalica" }}, ptbs("Porta Westfalica"));
    end);

    it("preserves whitespace in shaped blocks", function()
        assert.same({{
                text = " Whitespace\n kept ";
                background_shape = "square";
            }}, ptbs("[ Whitespace\n kept ]"));
    end);

    it("removes outer space from shapeless blocks", function()
        assert.same({{
                text = "no outer space characters";
            }}, ptbs("   no outer space characters   "));
        assert.same({{
                text = "no outer space characters inside features";
                features = {
                    stroke_13_background = true;
                    stroke_foreground = true;
                };
            }}, ptbs("/   no outer space characters inside features   |"));
        assert.same({}, ptbs(" "));
    end);

    it("Converts section breaks from shapeless block input", function()
        assert.same({{
                text = ";";
            }}, ptbs(" \n "));
        assert.same({
                {
                    text = ";";
                };
                {
                    text = "inner";
                };
                {
                    text = ";";
                };
                {
                    text = "and outer";
                };
                {
                    text = ";";
                };
                {
                    text = "newline";
                };
                {
                    text = ";";
                };
            }, ptbs("\n inner\nand outer \n newline\n "));
    end);

    it("recognizes single features", function()
        assert.same({{
                text = "A";
                features = {
                    stroke_13_background = true;
                };
            }}, ptbs("/A"));
        assert.same({{
                text = "abc";
                features = {
                    stroke_24_foreground = true;
                };
            }}, ptbs("abc\\"));
    end);

    it("recognizes multiple features", function()
        assert.same({{
                text = "A-";
                features = {
                    stroke_24_background = true;
                    stroke_13_foreground = true;
                    stroke_foreground = true;
                };
            }}, ptbs("\\A-/|"));
    end);

    it("does not recognize features within text", function()
        assert.same({{
                text = "a/b-c|d";
                features = {
                    stroke_24_foreground = true;
                };
            }}, ptbs("a/b-c|d\\"));
    end);

    it("recognizes background shapes", function()
        assert.same({{ text = "A", background_shape = "square" }}, ptbs("[A]"));
        assert.same({{ text = "abc", background_shape = "round" }}, ptbs("(abc)"));
        assert.same({{ text = "First\nSecond", background_shape = "diamond" }}, ptbs("<First\nSecond>"));
    end);

    it("preserves emptyness in shaped blocks", function()
        assert.same({{
                text = "";
                background_shape = "diamond";
            }}, ptbs("<>"));
    end);

    it("recognizes background patterns", function()
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "diag_4";
            }}, ptbs("/[A]"));
        assert.same({{
                text = "A";
                background_shape = "round";
                background_pattern = "diag_2";
            }}, ptbs("(A)/"));
        assert.same({{
                text = "A";
                background_shape = "diamond";
                background_pattern = "diag_1";
            }}, ptbs("<A>\\"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "upper";
            }}, ptbs("-[A]"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "right";
            }}, ptbs("[A]|"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "x_left";
            }}, ptbs("/\\[A]"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "x_upper";
            }}, ptbs("[A]\\/"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "plus_4";
            }}, ptbs("|-[A]"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "plus_4";
            }}, ptbs("-|[A]"));
    end);

    it("recognizes features and background patterns together", function()
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "diag_4";
                features = {
                    stroke_13_background = true;
                };
            }}, ptbs("/[/A]"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "left";
                features = {
                    stroke_foreground = true;
                };
            }}, ptbs("|[A|]"));
    end);

    it("discards additional background patterns", function()
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "x_left";
            }}, ptbs("/\\-[A]|-"));
        assert.same({{
                text = "A";
                background_shape = "square";
                background_pattern = "right";
            }}, ptbs("[A]|\\/"));
    end);

    it("splits by background block", function()
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                    background_pattern = "diag_3";
                };
                {
                    text = "B";
                    background_shape = "round";
                };
            }, ptbs("\\[A] (B)"));
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                };
                {
                    text = "B";
                    background_shape = "square";
                };
            }, ptbs("[A][B]"));
        assert.same({
                {
                    text = "abc";
                };
                {
                    text = "ABC";
                    background_shape = "square";
                };
            }, ptbs("abc[ABC]"));
    end);

    it("assigns background patterns preferably to the left block", function()
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                    background_pattern = "right";
                };
                {
                    text = "B";
                    background_shape = "round";
                };
            }, ptbs("[A]|(B)"));
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                    background_pattern = "diag_2";
                };
                {
                    text = "B";
                    background_shape = "square";
                };
            }, ptbs("[A]/[B]"));
        assert.same({
                {
                    text = "abc";
                    features = {
                        stroke_foreground = true;
                    };
                };
                {
                    text = "ABC";
                    background_shape = "square";
                };
            }, ptbs("abc|[ABC]"));
        assert.same({
                {
                    text = "ABC";
                    background_shape = "square";
                    background_pattern = "right";
                };
                {
                    text = "abc";
                };
            }, ptbs("[ABC]|abc"));
    end);

    it("distributes features and background patterns", function()
        assert.same({
                {
                    text = "A";
                    features = {
                        stroke_13_foreground = true;
                    };
                };
                {
                    text = "B";
                    background_shape = "square";
                    background_pattern = "diag_3";
                };
            }, ptbs("A/ \\[B]"));
        assert.same({
                {
                    text = "A";
                    features = {
                        stroke_13_foreground = true;
                        stroke_foreground = true;
                    };
                };
                {
                    text = "B";
                    background_shape = "square";
                    background_pattern = "diag_3";
                };
            }, ptbs("A/ | \\[B]"));
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                    background_pattern = "lower";
                };
                {
                    text = "-";
                };
            }, ptbs("[A]- -"));
        assert.same({
                {
                    text = "A";
                    background_shape = "square";
                    background_pattern = "lower";
                };
                {
                    text = "B";
                    background_shape = "square";
                    background_pattern = "left";
                };
            }, ptbs("[A]- |[B]"));
    end);

    it("uses only the first background shape", function()
        assert.same({
                {
                    text = "[A";
                    background_shape = "square";
                };
            }, ptbs("[[A]"));
        assert.same({
                {
                    text = "<A";
                    background_shape = "round";
                };
            }, ptbs("(<A)"));
        assert.same({
                {
                    text = "A]";
                    background_shape = "round";
                };
            }, ptbs("(A]"));
        assert.same({
                {
                    text = "A )";
                    background_shape = "square";
                };
            }, ptbs("[A )"));
        assert.same({
                {
                    text = " ( A ";
                    background_shape = "square";
                };
                {
                    text = ")";
                };
            }, ptbs("[ ( A ] )"));
        assert.same({
                {
                    text = "[A";
                    background_shape = "square";
                };
                {
                    text = "]";
                };
            }, ptbs("[[A]]"));
    end);

    it("preserves braces", function()
        assert.same({
                {
                    text = "{}";
                };
            }, ptbs("{}"));
        assert.same({
                {
                    text = "{A}";
                };
            }, ptbs("{A}"));
        assert.same({
                {
                    text = "{";
                };
                {
                    text = "}A";
                    background_shape = "square";
                };
            }, ptbs("{[}A]"));
        assert.same({
                {
                    text = "{";
                };
                {
                    text = "A";
                    background_shape = "square";
                };
            }, ptbs("{[A]"));
        assert.same({
                {
                    text = "{A}b";
                    background_shape = "square";
                };
            }, ptbs("[{A}b]"));
        assert.same({
                {
                    text = "A{";
                    background_shape = "square";
                };
                {
                    text = "}b]- c}";
                };
            }, ptbs("[A{]}b]- c}"));
        assert.same({
                {
                    text = "{|}A";
                    background_shape = "square";
                    features = {
                        stroke_foreground = true;
                    };
                };
            }, ptbs("[{|}A|]"));
    end);

    it("strips shapeless blocks adjacent to shaped blocks", function()
        assert.same({
                {
                    text = "abc";
                };
                {
                    text = "ABC";
                    background_shape = "square";
                };
                {
                    text = "def";
                };
            }, ptbs("abc [ABC] def"));
        assert.same({
                {
                    text = "abc";
                    features = {
                        stroke_13_foreground = true;
                    };
                };
                {
                    text = "ABC";
                    background_shape = "square";
                    background_pattern = "diag_4";
                };
                {
                    text = "def";
                    features = {
                        stroke_background = true;
                    };
                };
            }, ptbs("abc/ /[ABC] |def"));
        assert.same({
                {
                    text = "abc";
                    features = {
                        stroke_13_foreground = true;
                        stroke_foreground = true;
                    };
                };
                {
                    text = "ABC";
                    background_shape = "square";
                };
                {
                    text = "def";
                    features = {
                        stroke_background = true;
                    };
                };
            }, ptbs("abc / | [ABC] | def"));
    end);

    it("parses empty blocks, assigning features to background", function()
        assert.same({{ text = "", background_shape = "square" }}, ptbs("[]"));
        assert.same({{
                text = "";
                background_shape = "square";
                features = {
                    stroke_13_background = true;
                };
            }}, ptbs("[/]"));
        assert.same({{
                text = "";
                background_shape = "square";
                features = {
                    stroke_background = true;
                };
            }}, ptbs("[|]"));
        assert.same({{
                text = "";
                background_shape = "round";
                features = {
                    stroke_24_background = true;
                    stroke_background = true;
                };
            }}, ptbs("(\\|"));
        assert.same({{
                text = "";
                features = {
                    stroke_13_background = true;
                };
            }}, ptbs("/"));
    end);
end);

describe("parse_entities_in_blocks()", function()
    local function peb(blocks)
        visual_line_number_displays.parse_entities_in_blocks(blocks);
        return blocks;
    end

    local function t(text)
        return {
            text = text;
            features = {};
        };
    end

    it("Replaces basic entities", function()
        assert.same({t("[")}, peb({t("{lbrak}")}));
        assert.same({t("{{")}, peb({t("{lcurl}{lcurl}")}));
        assert.same({t("<>")}, peb({t("{lt}{gt}")}));
        assert.same({t("\n ")}, peb({t("{nl}{sp}")}));
        assert.same({t("\n ")}, peb({t("{newline}{space}")}));
    end);

    it("Preserves text", function()
        assert.same({t("")}, peb({t("")}));
        assert.same({t("lbrak}")}, peb({t("lbrak}")}));
        assert.same({t("lcurl}{")}, peb({t("lcurl}{lcurl}")}));
        assert.same({t("{lcurl}")}, peb({t("{lcurl}lcurl}")}));
        assert.same({t("lt>")}, peb({t("lt{gt}")}));
        assert.same({t("lt}>")}, peb({t("lt}{gt}")}));
        assert.same({t("ltgt")}, peb({t("ltgt")}));
        assert.same({t("lt}gt")}, peb({t("lt}gt")}));
        assert.same({t("<gt")}, peb({t("{lt}gt")}));
    end);

    it("Preserves invalid entities", function()
        assert.same({t("{")}, peb({t("{")}));
        assert.same({t("{{")}, peb({t("{lcurl}{")}));
        assert.same({t("{{lcurl}}")}, peb({t("{{lcurl}}")}));
        assert.same({t("{}")}, peb({t("{lcurl}}")}));
        assert.same({t("{lcurl")}, peb({t("{lcurl")}));
        assert.same({t("}(")}, peb({t("}{lpar}")}));
        assert.same({t("<{gt")}, peb({t("{lt}{gt")}));
        assert.same({t("{invalidentity}")}, peb({t("{invalidentity}")}));
    end);
end);
