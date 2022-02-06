-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

-- Look for test subjects outside of autotests/
package.path = "multi_component_liveries/?.lua;" .. package.path

-- See https://rubenwardy.com/minetest_modding_book/en/quality/unit_testing.html
_G.multi_component_liveries = {};

--! Replacement for minetest.get_translator().
local function get_translator()
    -- Make a non-translator.
    return(function(text)
        return text;
    end);
end

--! Replacement for Minetest’s table.copy().
local function copy(t)
    local c = {};

    for k, v in pairs(t) do
        if type(v) == table then
            c[k] = copy(v);
        else
            c[k] = v;
        end
    end

    return c;
end

_G.minetest = {
    get_translator = get_translator;
};

_G.table.copy = copy;

-- The code does some access to the minetest global table.
-- But it should only do so if a player name is provided.
require("core");
require("api");

-- simple_liv, simple_def, etc. are functions which create brand new tables
-- on demand. This saves the need for table.copy().

--! Component 2 on layer 1.
local function simple_liv()
    return {
        layers = {
            {
                component = 2;
                color = "#123456";
            };
        };
        active_layer = 1;
    };
end

--! Component 2 in red.
local function red_liv()
    local red = simple_liv();
    red.layers[1].color = "#ff0000";
    return red;
end

--! Selects layer @p layer in the stack @p stack and returns resulting stack.
local function select_layer(stack, layer)
    stack.active_layer = layer;
    return stack;
end

--! Component 1 in magenta appended to simple_liv().
local function simple_liv_appended()
    local appended = simple_liv();
    appended.layers[2] = {
        component = 1;
        color = "#ff00ff";
    };
    return appended;
end

--! Component 1 in magenta appended to red_liv().
local function red_liv_appended()
    local appended = red_liv();
    appended.layers[2] = {
        component = 1;
        color = "#ff00ff";
    };
    return appended;
end

--! Component 1 in magenta prepended to simple_liv().
local function simple_liv_prepended()
    local prepended = simple_liv();
    table.insert(prepended.layers, 1, {
        component = 1;
        color = "#ff00ff";
    });
    return prepended;
end

--! Component 2, then component 1.
local function reverse_liv()
    local reverse = simple_liv();
    reverse.layers[2] = {
        component = 1;
        color = "#654321";
    };
    return reverse;
end

--! Component 5 (invalid) appended to simple_liv().
local function invalid_layer_liv()
    local reverse = simple_liv();
    reverse.layers[2] = {
        component = 5;
        color = "#aaaaaa";
    };
    return reverse;
end

--! No components present, no layer selected.
local function empty_liv()
    return {
        layers = {};
    };
end

--! Definition with 2 components, sufficient for simple_liv().
local function simple_def()
    return {
        components = {
            {
                description = "abc";
                texture_file = "comp1.png";
            };
            {
                description = "abc";
                texture_file = "comp2.png";
            };
        };
        base_texture_file = "base.png";
        initial_livery = simple_liv();
    };
end

describe("paint_on_livery()", function()
    local function paint(definition, stack, color, alpha)
        -- The tool which is passed to paint_on_livery().
        -- This needs to return metadata with a get_string() method.
        local tool = {
            get_meta = function(self)
                return {
                    get_string = function(self, key)
                        if key == "paint_color" then
                            return color;
                        elseif key == "alpha" then
                            return alpha;
                        end
                    end
                };
            end
        };

        local result = multi_component_liveries.paint_on_livery(nil, definition, stack, tool);

        return {
            result = result;
            stack = stack;
        };
    end

    it("modifies nothing when requesting help", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#000000", 0));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00000000"));
        assert.same({ result = false; stack = red_liv(); },
                    paint(simple_def(), red_liv(), "#00000000"));
        assert.same({ result = false; stack = {}; },
                    paint(simple_def(), {}, "#00000000"));
    end);

    it("selects existing layers by component", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), select_layer(simple_liv(), 2), "#000200", 0));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), select_layer(simple_liv(), 3), "#00020000"));
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), select_layer(reverse_liv(), 2), "#00020000"));
        assert.same({ result = false; stack = select_layer(reverse_liv(), 2); },
                    paint(simple_def(), reverse_liv(), "#00010000"));
    end);

    it("selects already selected layer by component", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00020000"));
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), reverse_liv(), "#00020000"));
        assert.same({ result = false; stack = select_layer(reverse_liv(), 2); },
                    paint(simple_def(), select_layer(reverse_liv(), 2), "#00010000"));
    end);

    it("appends new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#00010000"));
    end);

    it("inserts new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#00010200"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv(), "#0001fe00"));
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), simple_liv(), "#00010100"));
    end);

    it("initializes when inserting new component", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#00010000"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#00010200"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), {}, "#0001fe00"));
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), {}, "#00010100"));
    end);

    it("deletes layer by component", function()
        assert.same({ result = true; stack = empty_liv(); },
                    paint(simple_def(), simple_liv(), "#0002ff00"));
        assert.same({ result = true; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), reverse_liv(), "#0001ff00"));
    end);

    it("initializes when deleting layer", function()
        assert.same({ result = true; stack = empty_liv(); },
                    paint(simple_def(), {}, "#0002ff00"));
    end);

    it("moves layer by component, and selects it", function()
        assert.same({ result = true; stack = simple_liv_prepended(); },
                    paint(simple_def(), simple_liv_appended(), "#00010100"));
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv_prepended(), "#00010200"));
    end);

    it("does not move layers past the end", function()
        assert.same({ result = true; stack = select_layer(simple_liv_appended(), 2); },
                    paint(simple_def(), simple_liv_prepended(), "#0001fe00"));
    end);

    it("does not modify anything if moving selected layer to current position", function()
        assert.same({ result = false; stack = reverse_liv(); },
                    paint(simple_def(), reverse_liv(), "#00020100"));
    end);

    it("does not move the only layer", function()
        -- Painting update result does not matter in this corner case.
        assert.same(simple_liv(),
                    paint(simple_def(), simple_liv(), "#0002fe00").stack);
    end);

    it("does not insert invalid layers", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00050000"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#00050100"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0005fe00"));
    end);

    it("does not modify anything if removing missing layer", function()
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0001ff00"));
    end);

    it("removes invalid layers if present", function()
        assert.same({ result = true; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), invalid_layer_liv(), "#0005ff00"));
        assert.same({ result = false; stack = simple_liv(); },
                    paint(simple_def(), simple_liv(), "#0005ff00"));
    end);

    it("paints selected layer", function()
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), simple_liv(), "#ff0000ff"));
        assert.same({ result = true; stack = red_liv_appended(); },
                    paint(simple_def(), simple_liv_appended(), "#ff0000ff"));
    end);

    it("initializes when painting", function()
        assert.same({ result = true; stack = red_liv(); },
                    paint(simple_def(), {}, "#ff0000ff"));
    end);

    it("Does not paint if no layer selected", function()
        assert.same({ result = false; stack = select_layer(simple_liv(), nil); },
                    paint(simple_def(), select_layer(simple_liv(), nil), "#ff0000ff"));
    end);
end);
