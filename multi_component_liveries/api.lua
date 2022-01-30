-- SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>
--
-- SPDX-License-Identifier: MIT OR LGPL-2.1-or-later

--! @class livery_definition
--! A livery_definition table is a Lua table which defines a livery set.
--!
--! The table must be a list of tables,
--! which each describe one available livery component. TODO Base texture.
--!
--! Each list element must have these properties:
--! \li @c description A user facing string to describe the component.
--! \li @c texture_file The file name of the component’s texture.
--!
--! @par Example
--! @code
--! local cat_livery_set = {
--!     {
--!         description = S("Fur on legs");
--!         texture_file = "my_cat_mod_cat_leg_overlay.png";
--!     };
--!     {
--!         description = S("Fur near feet");
--!         texture_file = "my_cat_mod_cat_feet_overlay.png";
--!     };
--! };
--! @endcode

--! @class livery_stack
--! A livery_stack table is a Lua table which defines the state of a livery.
--!
--! The table must contain the elements @c component_stack and @c next_layer.
--!
--! @c component_stack is a list of tables, which define one livery layer each. TODO layer_stack
--! Each layer definition has these properties:
--! \li @c component The index of the livery component in the livery_definition.
--! \li @c color The color in which this component is painted.
--!
--! @c next_layer is the index of a layer in @c component_stack.
--! This layer shall be painted next.
--!
--! @par Example
--! @parblock
--! Together with the example for livery_stack,
--! this example defines a cat with blue legs and red feet.
--!
--! The red feet are not visible,
--! because the blue legs component is in a higher layer than the feet.
--! (Assuming that the leg texture also covers the feet.)
--!
--! The next time a player paints the cat, the legs will be recolored.
--! @code
--! local cat_texture_stack = {
--!     component_stack = {
--!         {
--!             component = 2;
--!             color = "red";
--!         };
--!         {
--!             component = 1;
--!             color = "blue";
--!         };
--!     };
--!     next_layer = 2;
--! };
--! @endcode
--! @endparblock

--! Adds methods to an advtrains wagon definition to implement livery paiting.
--!
--! @param wagon_definition The “wagon prototype” which you pass to register_wagon().
--! @param livery_components A livery_definition table, defines the available livery components for this wagon.
--! @param initial_livery A livery_stack table, which will be applied to the wagon when a player paints it the first time.
--! @see livery_definition, livery_stack.
function multi_component_liveries.setup_advtrains_wagon(wagon_definition, livery_components, initial_livery)
    wagon_definition.set_textures = multi_component_liveries.set_textures;
    wagon_definition.set_livery = multi_component_liveries.set_livery;
    wagon_definition.livery_components = livery_components;
    wagon_definition.initial_livery = initial_livery;
end
