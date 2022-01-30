<!--
SPDX-FileCopyrightText: 2022 David Hurka <doxydoxy@mailbox.org>

SPDX-License-Identifier: MIT OR CC-BY-SA-4.0
-->

# Complex livery painting library (multi_component_liveries)

This library provides functionality to paint multiple livery layers on e. g. advtrains wagons, using only one generic painting tool.

## How it works

Entity objects may have a property `livery`, which needs to be a Lua table for which persistent storage is provided.
The functions in this library will store a component stack in this table, and read this table to create texture strings with all livery components.

The player may use a single painting tool to paint the livery components.
By painting certain “meta colors”, the player can choose which component shall be painted next.
The chosen component is stored in the `livery` table too.

The player interfaces with this library via the painting tool (e. g. the `bike_painter`), and via help texts displayed as chat message.

## How to use this library

TODO

## advtrains interface

This library provides a function that implements livery painting on advtrains wagon definitions.

It uses the unofficial livery API from advtrains, added in commit 
[b71c72b4ab4d50c8f3a3a6ccbe15427548e1d2ff](https://git.bananach.space/advtrains.git/commit/?id=).

```{txt}
commit b71c72b4ab4d50c8f3a3a6ccbe15427548e1d2ff
Author: Gabriel Pérez-Cerezo <email@redacted>
Date:   Sun Dec 1 12:08:28 2019 +0100

    Add experimental liveries feature

    Please do not use this in your train mods yet, this may be subject to
    changes!
```

Essentially, wagon definitions have a `set_livery()` method, which is called when a player uses a painting tool on the wagon; and a `set_texture()` method, which is called when the lua entity of the wagon is created.
These methods have access to the lua entity (to apply textures), and to advtrains’ persistent data storage of the wagon, where a `livery` property must be stored.

advtrains only accepts the `bike_painter` tool, which provides the property strings `paint_color` and `alpha`.

As soon as advtrains gains official/stable livery API, this interface of this library shall be adapted.
(In that case, contact the maintainer of this library, multi_component_liveries!)
