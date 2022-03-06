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
        "[combine:128x26:0,0={vlnd_pixel.png^[multiply:#1e00ff^[resize:25x26^[combine:25x17:11,9={[combine:5x8:0,0=1.png^[colorize:#ffffff}}";
        -- Display configuration: max_width, height, level
        { 128, 26, "number" };
    };
    {
        "Subway wagon colors";
        "2";
        "[combine:128x26:0,0={vlnd_pixel.png^[multiply:#ff001e^[resize:25x26^[combine:25x17:11,9={[combine:5x8:0,0=2.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Leading non-digits";
        "U3";
        "[combine:128x26:0,0={vlnd_pixel.png^[multiply:#????^[resize:25x26^[combine:25x17:????,9={[combine:10x8:0,0=U3.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Trailing non-digits";
        "4a";
        "[combine:128x26:0,0={vlnd_pixel.png^[multiply:#????^[resize:25x26^[combine:25x17:???,9={[combine:10x8:0,0=4a.png^[colorize:#ffffff}}";
        { 128, 26, "number" };
    };
    {
        "Square background";
        "[[5]]";
        "";
        { 128, 26, "number" };
    };
    {
        "Round, diamond background";
        "((Line)) <<6>>";
        "";
        { 128, 26, "number" };
    };
    {
        "Outlined background";
        "_[Outlined]_ _(7th)_ _<Line>_";
        "";
        { 128, 26, "number" };
    };
    {
        "Text section";
        "<<8>>; some Destination";
        "";
        { 128, 26, "number" };
    };
    {
        "Details section";
        "[[9]]\nsome Destination\nvia <<some>> stopover";
        "";
        { 128, 26, "text" };
    };
    {
        "Color algorithm";
        "10";
        "";
        { 128, 26, "number" };
    };
    {
        "Background features 1";
        "/11";
        "";
        { 128, 26, "number" };
    };
    {
        "Background features 2";
        "[[\\12]]";
        "";
        { 128, 26, "number" };
    };
    {
        "Background features 3";
        "[[|13]]";
        "";
        { 128, 26, "number" };
    };
    {
        "Foreground features";
        "[[14/]]; towards A; via B|";
        "";
        { 128, 26, "details" };
    };
    {
        "Background patterns 1";
        "-((15))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 2";
        "/((16))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 3";
        "|((17))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 4";
        "\\((18))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 5";
        "-|((19))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 6";
        "\\/((20))";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 7";
        "/((21)) ((21))/";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 8";
        "|-((22));; ((22))-|";
        "";
        { 128, 26, "details" };
    };
    {
        "Background patterns 9";
        "|-_(23)_ _[23]_-|";
        "";
        { 128, 26, "number" };
    };
    {
        "Background patterns 10";
        "_(24)_\\/ \\/_<24>_-|";
        "";
        { 128, 26, "number" };
    };
    {
        "Double space line breaks";
        "Line  25";
        "";
        { 128, 26, "number" };
    };
    {
        "Double space line breaks";
        "<<Line  26>>; to  A; via  B";
        "";
        { 128, 26, "details" };
    };
    {
        "Entities 1";
        "<<Line {sp}27>>; to {space}A; via{nl}B";
        "";
        { 128, 26, "details" };
    };
    {
        "Entities 2";
        "<<Line {}28>>; to {space}A; via{NewLine}B";
        "";
        { 128, 26, "details" };
    };
    {
        "Entities 3";
        "_<{underscore}{lt}29{gt}{us}>_";
        "";
        { 128, 26, "number" };
    };
    {
        "HTML 4 entities";
        "30; K{ouml}ln";
        "";
        { 128, 26, "text" };
    };
    {
        "HTML 5 entities";
        "31; {OpenCurlyDoubleQuote}Island{CloseCurlyDoubleQuote}";
        "";
        { 128, 26, "text" };
    };
    {
        "Missing glyph entities";
        "32; {num} {sharp}";
        "";
        { 128, 26, "text" };
    };
    {
        "Numeric entities 1";
        "33; No {#32}line{#x20} breaks";
        "";
        { 128, 26, "text" };
    };
    {
        "Numeric entities 2";
        "34; {#08206}Island{#x002019}";
        "";
        { 128, 26, "text" };
    };
    {
        "Numeric entities 2";
        "34; {#08206}Island{#x002019}";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 1";
        "<<{background:#ffffff}35>>; {text:#ffaa00}Orange";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 2";
        "<<{b:#000}36>>; {t:#ffaa00}Orange";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 3";
        "<<37>>{b:#00f}; Text";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 4";
        "{b:#00f}<<38>>; Text";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 5";
        "<<39>>{t:#00f}; Text";
        "";
        { 128, 26, "text" };
    };
    {
        "Color brace sequences 5";
        "{t:#00f}<<40>>; Text";
        "";
        { 128, 26, "text" };
    };
    {
        "Deleting explicit colors";
        "-|[[{secondary_background:#f2b}46]]; -|[[41]]";
        "";
        { 128, 26, "text" };
    };
    {
        "“all” color brace sequence 1";
        "{all:1}<<42>>; Text";
        "";
        { 128, 26, "text" };
    };
    {
        "“all” color brace sequence 2";
        "<<43>>; _[Some]_ {a:1} _[Text]_";
        "";
        { 128, 26, "text" };
    };
    {
        "Referencing color brace sequences";
        "<<{b:\"43\"}44>>; {t:\"40\"}Text";
        "";
        { 128, 26, "text" };
    };
    {
        "Explicit colors";
        "[[45]]; ((some)) {b:#050} ((text))";
        "";
        { 128, 26, "text" };
    };
    {
        "Deleting explicit colors";
        "[[46]]; {b:#050} ((some)) {b:} ((text))";
        "";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 1";
        "[[47]]; {broken:#123} color brace sequence";
        "";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 2";
        "[[48]]; {b:#1234} broken color brace sequence";
        "";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 3";
        "[[49]]; [_wrong_] [(blocks)]";
        "";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 4";
        "[[50]]; (single) [brackets] <work>";
        "";
        { 128, 26, "text" };
    };
    {
        "Syntax errors 5";
        "[[51]]; features | in / text";
        "";
        { 128, 26, "text" };
    };
    {
        "No nesting 1";
        "[[52]]; ((No [[nested]] {{blocks}}))";
        "";
        { 128, 26, "text" };
    };
    {
        "No nesting 2";
        "[[53]]; cut off ((block";
        "";
        { 128, 26, "text" };
    };
    {
        "No nesting 3";
        "[[54]]; ((((excess brackets))))";
        "";
        { 128, 26, "text" };
    };
    {
        "No nesting 4";
        "[[55]]; (<<(excess brackets)>>)";
        "";
        { 128, 26, "text" };
    };
};
