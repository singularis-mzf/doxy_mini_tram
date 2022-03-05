-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

return {
    {
        -- Short description
        "Single digit";
        -- Display string input
        "1";
        -- Expected texture string (with autotest mocks)
        "[combine:128x26:0,0={vlnd_pixel.png^[multiply:#1e00ff^[resize:5x26^[combine:5x17:1,9={[combine:5x8:0,0=1.png^[colorize:#ffffff}}";
        -- Display configuration: max_width, height, level
        { 128, 26, "number" };
    };
};
