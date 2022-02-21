-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

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
