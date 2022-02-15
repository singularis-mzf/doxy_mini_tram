-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! Returns an iterator through UTF-8 characters of the string @p input.
--!
--! Tolerates UTF-8 errors.
--!
--! @returns character position in @p input, character as a string.
local function utf_8_characters(input)
    -- I think this function would be useful in the Minetest Lua API.
    local position = 1;

    function iterator()
        if position > #input then
            return nil;
        end

        local msb = string.byte(input, position);
        if not msb then
            return nil;
        end

        local char_width;
        if msb < 0xc0 then
            -- 0x00 .. 0x7f are single byte sequences.
            -- 0x80 .. 0xbf are non-MSB bytes; now recovering from errors.
            char_width = 1;
        elseif msb < 0xe0 then
            -- 0xc0 .. 0xc1 are start of invalid two byte sequences.
            -- 0xc2 .. 0xdf are start of two byte sequences.
            char_width = 2;
        elseif msb < 0xf0 then
            -- Start of three byte sequences.
            char_width = 3;
        elseif msb < 0xf8 then
            -- 0xf0 .. 0xf4 are start of four byte sequences.
            -- 0xf5 .. 0xf7 are start of invalid four byte sequences.
            char_width = 4;
        else
            -- Start of 5+ byte sequences or entirely invalid bytes.
            char_width = 1;
        end

        local old_position = position;
        position = position + char_width;

        return old_position, string.sub(input, old_position, position - 1);
    end

    return iterator;
end

local whitespace_characters = {
    [" "] = true;
    ["\n"] = true;
};

--! @returns text before last space, text after last space or nil.
local function split_at_last_space(text)
    local last_space = nil;

    for position, character in utf_8_characters(text) do
        if whitespace_characters[character] then
            last_space = position;
        end
    end

    if last_space and (last_space < #text) then
        return string.sub(text, 1, last_space - 1), string.sub(text, last_space + 1);
    else
        return text;
    end
end

--! Parses a text block string, returns a list of text block descriptions.
--!
--! Does not parse brace sequences.
function visual_line_number_displays.parse_text_block_string(input)
    -- This parser parses somewhat complex syntax.
    -- Since invalid syntax shall be passed through without errors,
    -- and using a system like flex/bison seems complicated for a Minetest mod,
    -- I decided to implement the parser like this.
    --
    -- The parser iterates through the input strings by characters.
    --
    -- For each character, the current state of the parser is checked
    -- to determine what to do with the character.
    -- The character may be appended to the current string,
    -- or to a temporary string if its purpose is not yet clear.
    -- The character may also change the current state,
    -- e. g. to start a new background block.
    --
    -- The parser uses many closures,
    -- to keep the iterator loop on a high programming level.

    -- Completed text blocks are inserted here.
    local result = {};

    -- Constructs an empty text block description.
    local function empty_text_block()
        return {
            text = "";
            features = {};
        };
    end

    -- The text block which is currently being constructed.
    local current_block = empty_text_block();

    -- Characters found after other text in the current block,
    -- which may become foreground features if no other text follows.
    local text_after = "";

    -- Whether we are inside a background shape block.
    -- Determines e. g. whether characters become foreground features
    -- or background patterns.
    local background_block_open = false;

    -- Returns whether the current block is visually empty.
    local function current_block_is_empty()
        -- background_pattern can not appear without background_shape.
        return (#current_block.text == 0) and (not next(current_block.features)) and (not current_block.background_shape);
    end

    local foreground_features = {
        ["/"] = "stroke_13_foreground";
        ["|"] = "stroke_foreground";
        ["\\"] = "stroke_24_foreground";
        ["-"] = "dash_after";
    };

    -- Parses any characters from text_after,
    -- which were found after other text by parse_pattern_or_feature().
    --
    -- These become foreground features.
    local function parse_text_after_as_foreground_features()
        for _, character in utf_8_characters(text_after) do
            local feature = foreground_features[character];

            -- text_after may contain whitespace, so check this value.
            if feature then
                current_block.features[feature] = true;
            end
        end

        text_after = "";
    end

    -- Appends the current block to results, unless it is visually empty.
    -- Call this when the end of a text block has been found.
    local function finish_block()
        parse_text_after_as_foreground_features();

        if not current_block.background_shape then
            -- Shapeless blocks are whitespace trimmed,
            -- because there are no start and end delimiters.
            -- Trimming needs to be done before checking for visual emptiness,
            -- because whitespace may separate two shaped blocks like “[A]/ -[B]”,
            -- but also shapeless blocks like “[A] |- [B]”.
            current_block.text = string.trim(current_block.text);

            -- Shapeless blocks do not need the background pattern.
            current_block.background_pattern = nil;
        end

        -- Dash (-) is recognized as feature, because it is also used as
        -- background pattern, and needs to be parsed at the same time.
        -- To allow negative line numbers, this feature needs to be restored
        -- to a dash.
        -- TODO With the availability of additional wagon properties
        -- TODO in advtrains, remove this piece of spaghetti code
        -- TODO by allowing - as stroke feature.
        if current_block.features.dash_before then
            current_block.text = "-" .. current_block.text;
            current_block.features.dash_before = nil;
        end
        if current_block.features.dash_after then
            current_block.text = current_block.text .. "-";
            current_block.features.dash_after = nil;
        end

        if not current_block_is_empty() then
            table.insert(result, current_block);
        end

        current_block = empty_text_block();
        background_block_open = false;
    end

    local background_patterns_before = {
        ["|"] = "left";
        ["/"] = "diag_4";
        ["-"] = "upper";
        ["\\"] = "diag_3";
        -- Combinations
        ["diag_4\\"] = "x_left";
        ["diag_3/"] = "x_left";
        ["upper|"] = "plus_4";
        ["left-"] = "plus_4";
    };

    local background_patterns_after = {
        ["|"] = "right";
        ["/"] = "diag_2";
        ["-"] = "lower";
        ["\\"] = "diag_1";
        -- Combinations
        ["diag_2\\"] = "x_upper";
        ["diag_1/"] = "x_upper";
        ["lower|"] = "plus_1";
        ["right-"] = "plus_1";
    };

    local background_features = {
        ["/"] = "stroke_13_background";
        ["|"] = "stroke_background";
        ["\\"] = "stroke_24_background";
        ["-"] = "dash_before";
    };

    -- Tries to parse a background pattern or feature character.
    --
    -- Before opening a background shape block,
    -- the character is parsed as both background pattern and feature.
    -- If this block turns out to be shapeless, the pattern is discarded.
    --
    -- If the block has no text yet, features go in the background.
    -- Otherwise, features go to text_after.
    -- text_after will be appended to text when more text is found,
    -- and will be parsed as foreground features when the block ends.
    --
    -- Returns true when the character has been parsed.
    local function parse_pattern_or_feature(character)
        if not background_patterns_before[character] then
            -- This is not any kind of pattern or feature.
            return false;
        end

        if background_block_open then
            -- Inside shaped block
            if #current_block.text == 0 then
                -- Background feature.
                -- Example case: “[/A]”
                local feature = background_features[character];
                current_block.features[feature] = true;
            else
                -- Possibly foreground feature.
                -- Example cases: “[A/]”, “[ab/c]”
                text_after = text_after .. character;
            end
        elseif not current_block.background_shape then
            -- Before shaped block or in shapeless block.
            if #current_block.text == 0 then
                -- Background feature or background pattern.
                -- Example cases: “/A”, “/[A]”, “\/[A]”
                local feature = background_features[character];
                current_block.features[feature] = true;

                local pattern = (current_block.background_pattern or "");
                pattern = background_patterns_before[pattern .. character];
                if pattern then
                    current_block.background_pattern = pattern;
                end
            else
                -- Possibly foreground feature.
                -- Example cases: “A/”, “ab/c”
                text_after = text_after .. character;
            end
        else
            -- After shaped block.
            -- Background pattern.
            -- Example cases: “[A]/”, “[A]\/”
            local pattern = (current_block.background_pattern or "");
            pattern = background_patterns_after[pattern .. character];
            if pattern then
                current_block.background_pattern = pattern;
            end
        end

        return true;
    end

    local background_block_starts = {
        ["["] = "square";
        ["("] = "round";
        ["<"] = "diamond";
    };

    -- Tries to parse a background block start character.
    -- Returns true if the character has been parsed.
    local function parse_background_block_start(character)
        if background_block_open then
            -- Already inside a shaped block.
            return false;
        end

        local shape = background_block_starts[character];
        if not shape then
            -- Not a background block start character.
            return false;
        end

        if #text_after > 0 then
            local a, b = split_at_last_space(text_after);
            if b then
                -- If the current text_after contains spaces,
                -- the part after the last space is a pattern for this block.
                -- Examples: “abc /[A]”, “abc/ |[A]”
                text_after = a;

                finish_block();

                for _, c in utf_8_characters(b) do
                    parse_pattern_or_feature(c);
                end

                -- parse_pattern_or_feature() has parsed patterns as features too.
                current_block.features = {};
            else
                -- Otherwise, the text_after belongs to the previous block anyway.
                finish_block();
            end
        elseif #current_block.text > 0 then
            -- The previous (shapeless) block has text,
            -- so features on that block should stay on that block.
            -- This includes cases like “ [A]”, “/ [A]”, or “abc/[A]”.
            finish_block();
        else
            -- Any previous characters were background patterns,
            -- which are already parsed, but are parsed as background feature too.
            -- This includes cases like “/[A]”, “|-[A]”, or “ /[A]”.
            -- Clear the features.
            current_block.features = {};
        end

        current_block.background_shape = shape;
        background_block_open = true;

        return true;
    end

    local background_block_ends = {
        ["]"] = "square";
        [")"] = "round";
        [">"] = "diamond";
    };

    -- Tries to parse a background block end character.
    -- Returns true if the character has been parsed.
    local function parse_background_block_end(character)
        if not background_block_open then
            return false;
        end

        local shape = background_block_ends[character];
        if shape == current_block.background_shape then
            background_block_open = false;
            return true;
        else
            return false;
        end
    end

    -- Parses a character as plain text.
    -- This is done if the character is an actual text character,
    -- or its special interpretation failed.
    local function parse_text_character(character)
        if current_block.background_shape and (not background_block_open) then
            -- This is the beginning of the next shapeless block
            -- after a shaped block.
            -- Example: “[A]b”
            finish_block();
        end

        if #current_block.text == 0 then
            -- text_after can not contain anything now.
            if (not background_block_open) and whitespace_characters[character] then
                -- Do not start a shapeless block with whitespace.
            else
                current_block.text = current_block.text .. character;
            end
        else
            if whitespace_characters[character] and (not background_block_open) then
                -- Do not cause text_after to be considered text
                -- if it is followed by whitespace.
                -- Examples: “abc/ [A]”, “abc/ /[A]”
                -- But not: “[abc/ ]”
                text_after = text_after .. character;
            else
                -- text_after needs to be applied,
                -- since now it is known that it is text content.
                -- Examples: “A/b”, “abc/ d”
                current_block.text = current_block.text .. text_after .. character;
                text_after = "";
            end
        end
    end

    -- Parses a character.
    -- The purpose of this function is to return after parsing the character.
    local function parse_character(character)
        if parse_background_block_start(character) then
        elseif parse_background_block_end(character) then
        elseif parse_pattern_or_feature(character) then
        else
            parse_text_character(character);
        end
    end

    for _, character in utf_8_characters(input) do
        parse_character(character);
    end

    finish_block();

    return result;
end
