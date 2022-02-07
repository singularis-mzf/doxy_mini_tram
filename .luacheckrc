-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: CC0-1.0 OR MIT

max_string_line_length = 240;
max_code_line_length = 240;

ignore = {
    -- Callback handlers receive many unused variables.
    -- Mark intentionally unused ones with a leading underscore.
    "21/_.*",
};

globals = {
    "minitram_konstal_105_liveries";
    "multi_component_liveries";
};

read_globals = {
    -- Other mods’ API
    advtrains = { fields = { "register_wagon" } };

    -- Minetest API
    "minetest";
    table = { fields = { "copy" } };
    vector = { fields = { "new" } };

    -- busted API
    "describe";
    "it";
    "assert";
};
