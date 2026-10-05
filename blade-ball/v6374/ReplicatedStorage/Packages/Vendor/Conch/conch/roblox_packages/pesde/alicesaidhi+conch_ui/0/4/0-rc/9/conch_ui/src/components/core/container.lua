local module = require("../../util/component")
local module2 = require("../../util/guistate")
local module3 = require("../../../roblox_packages/vide")
return module(function(data, _)
	local tile_scale = data.tile_scale or 1
	local v

	if data.image then
		local tw = data.image.tw or data.image.th
		v = {
			Image = data.image.src,
			ImageColor3 = data.color,
			ImageTransparency = data.transparency or 0,
			ScaleType = data.image.scale_type or Enum.ScaleType.Stretch,
			ResampleMode = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			SliceCenter = 0,
			SliceScale = 0,
			TileSize = 0,
			BackgroundTransparency = 1,
			AutoLocalize = false,
			ClipsDescendants = 0
		}
		local resampleMode

		if data.image.pixelated then
			resampleMode = Enum.ResamplerMode.Pixelated
		else
			resampleMode = Enum.ResamplerMode.Default
		end

		v.ResampleMode = resampleMode
		v.ImageRectOffset = data.image.rect_offset
		v.ImageRectSize = data.image.rect_size
		v.SliceCenter = data.image.slice_center
		v.SliceScale = data.image.slice_scale
		local tileSize

		if tw then
			tileSize = function()
				return UDim2.fromOffset(
					math.max(module3.read(data.image.tw or 1) * module3.read(tile_scale) // 1, 1),
					(math.max(module3.read(data.image.th or 1) * module3.read(tile_scale) // 1, 1))
				)
			end
		else
			tileSize = UDim2.fromOffset(1, 1)
		end

		v.TileSize = tileSize
		v.ClipsDescendants = data.clips
	else
		v = {
			BackgroundColor3 = data.color,
			BorderSizePixel = 0,
			BackgroundTransparency = data.transparency or data.color and 0 or 1,
			ClipsDescendants = data.clips
		}
	end

	if data.sink ~= nil then
		v.Active = data.sink
	end

	local clicked = data.clicked or data.hold or data.hover or data.input or data.wheel

	if clicked then
		table.insert(v, {
			AutoButtonColor = false,
			module2(data)
		})
	end

	if data.stroke then
		table.insert(v, module3.create("UIStroke")({
			Color = data.stroke,
			Transparency = data.stroke_transparency,
			Thickness = function()
				return module3.read(data.thickness or 1)
			end
		}))
	end

	if data.corner then
		table.insert(v, (module3.create("UICorner")({
			CornerRadius = function()
				return UDim.new(0, module3.read(data.corner))
			end
		})))
	end

	local v2

	if module3.read(data.image) and clicked then
		v2 = "ImageButton"
	elseif module3.read(data.image) and not clicked then
		v2 = "ImageLabel"
	elseif clicked then
		v2 = "ImageButton"
	else
		v2 = "Frame"
	end

	return (module3.create(v2)(v))
end)