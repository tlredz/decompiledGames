local module = require("../../util/component")
local module2 = require("../core/container")
local module3 = require("../../theme")
return module(function(list)
	return module2({
		color = list.color or module3.background,
		transparency = list.transparency or module3.background_transparency,
		stroke = list.stroke,
		stroke_transparency = list.stroke_transparency,
		thickness = list.thickness,
		corner = list.corner,
		image = list.image,
		tile_scale = list.tile_scale,
		clips = list.clips,
		keycode = list.keycode,
		sink = list.sink,
		enabled = list.enabled,
		hover = list.hover,
		hold = list.hold,
		input = list.input,
		clicked = list.clicked,
		wheel = list.wheel,
		unpack(list)
	})
end)