-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! @class display_description
--! A display_description table describes the geometry of some displays,
--! which are available in a texture slot.
--!
--! It needs to have these elements:
--! \li @c base_resolution Table with elements @c width and @c height,
--! describing the size of the texture slot without superresolution.
--! \li @c displays A list of descriptions for each display.
--!
--! Each element in the @c displays list needs to be a table with these elements:
--! \li @c position Table with elements @c x and @c y,
--! describing the top-left corner of the display in the texture,
--! at base resolution, and before applying transformation.
--! \li @c height The fixed height at base resolution.
--! \li @c max_width The available width at base resolution.
--! \li @c center_width If less than @c max_width is needed,
--! the display is centered around this width position.
--! (Examples: 0 = left alignment; 0.5 * max_width = center alignment.)
--! \li @c level String specifying up to which section it is rendered.
--! Values: @c number, @c text, @c details.

--! Adds line number displays to advtrains wagon @c wagon_definition.
--!
--! @param wagon_definition The table which will be passed to advtrains.register_wagon().
--! @param display_description A display_description table.
--! @param slot Which texture slot shall receive the displays.
function visual_line_number_displays.setup_advtrains_wagon(wagon_definition, display_description, slot)
    old_on_step = wagon_definition.custom_on_step;

    wagon_definition.custom_on_step = function(...)
        visual_line_number_displays.advtrains_wagon_on_step(display_description, slot, ...);

        if old_on_step then
            old_on_step(...)
        end
    end
end
