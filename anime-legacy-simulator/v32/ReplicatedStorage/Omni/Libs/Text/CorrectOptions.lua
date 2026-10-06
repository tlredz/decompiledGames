local TextService = game:GetService("TextService")
local Defaults = require(script.Parent.Defaults)
local Fonts = require(script.Parent.Fonts)
local v = {
	RootX = true,
	RootY = true,
	RootXY = true,
	FrameX = true,
	FrameY = true,
	FrameXY = true
}
local v2 = {
	Left = true,
	Center = true,
	Right = true,
	Justified = true
}
local v3 = {
	Top = true,
	Center = true,
	Bottom = true,
	Justified = true
}
local getTextBoundsParams = Instance.new("GetTextBoundsParams")
getTextBoundsParams.Text = ""
return function(state)
	if not v[state.ScaleSize] then
		state.ScaleSize = Defaults.ScaleSize
	end

	if v[state.ScaleSize] then
		if type(state.MinimumSize) ~= "number" then
			state.MinimumSize = Defaults.MinimumSize
		end

		if type(state.MinimumSize) == "number" then
			if state.MinimumSize < 1 then
				state.MinimumSize = 1
			end
		else
			state.MinimumSize = nil
		end

		if type(state.MaximumSize) ~= "number" then
			state.MaximumSize = Defaults.MaximumSize
		end

		if type(state.MaximumSize) == "number" then
			if state.MaximumSize < 1 then
				state.MaximumSize = 1
			end
		else
			state.MaximumSize = nil
		end

		if type(state.Size) ~= "number" then
			state.Size = Defaults.Size
		end
	else
		state.ScaleSize = nil
		state.MinimumSize = nil
		state.MaximumSize = nil

		if type(state.Size) == "number" then
			if state.Size < 1 then
				state.Size = 1
			end
		else
			state.Size = Defaults.Size
		end
	end

	local font = state.Font

	if font == nil then
		state.Font = Defaults.Font

		if state.Size > 100 then
			state.Size = 100
		end
	elseif typeof(font) == "Font" then
		getTextBoundsParams.Font = state.Font
		getTextBoundsParams.Text = ""
		local _, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

		if type(textBoundsAsync) == "string" then
			warn("Invalid font. Fallback to default.")
			state.Font = Defaults.Font
		end

		if state.Size > 100 then
			state.Size = 100
		end
	elseif not Fonts[font] then
		warn("Invalid font. Fallback to default.")
		state.Font = Defaults.Font

		if state.Size > 100 then
			state.Size = 100
		end
	end

	local lineHeight = state.LineHeight

	if type(lineHeight) == "number" then
		if lineHeight < 0 then
			state.LineHeight = 0
		end
	else
		state.LineHeight = Defaults.LineHeight
	end

	local characterSpacing = state.CharacterSpacing

	if type(characterSpacing) == "number" then
		if characterSpacing < 0 then
			state.CharacterSpacing = 0
		end
	else
		state.CharacterSpacing = Defaults.CharacterSpacing
	end

	if typeof(state.Color) ~= "Color3" then
		state.Color = Defaults.Color
	end

	if type(state.Transparency) ~= "number" then
		state.Transparency = Defaults.Transparency
	end

	local pixelated = state.Pixelated

	if pixelated == false then
		state.Pixelated = nil
	elseif pixelated ~= true then
		state.Pixelated = Defaults.Pixelated
	end

	if typeof(state.Offset) ~= "Vector2" then
		state.Offset = Defaults.Offset
	end

	if type(state.Rotation) ~= "number" then
		state.Rotation = Defaults.Rotation
	end

	local strokeSize = state.StrokeSize
	local strokeColor = state.StrokeColor
	local strokeTransparency = state.StrokeTransparency
	local strokeScaled = state.StrokeScaled

	if type(strokeSize) == "number" then
		if typeof(strokeColor) ~= "Color3" then
			state.StrokeColor = Defaults.StrokeColor
		end

		if type(strokeTransparency) ~= "number" then
			state.StrokeTransparency = state.Transparency
		end

		if type(strokeScaled) ~= "boolean" then
			state.StrokeScaled = Defaults.StrokeScaled
		end
	elseif typeof(strokeColor) == "Color3" then
		state.StrokeSize = Defaults.StrokeSize
		state.StrokeScaled = Defaults.StrokeScaled

		if type(strokeTransparency) ~= "number" then
			state.StrokeTransparency = state.Transparency
		end
	elseif type(strokeTransparency) == "number" then
		state.StrokeSize = Defaults.StrokeSize
		state.StrokeScaled = Defaults.StrokeScaled

		if type(strokeColor) ~= "number" then
			state.StrokeColor = Defaults.StrokeColor
		end
	else
		state.StrokeSize = nil
		state.StrokeColor = nil
		state.StrokeTransparency = nil
		state.StrokeScaled = nil
	end

	local shadowOffset = state.ShadowOffset
	local shadowColor = state.ShadowColor
	local shadowTransparency = state.ShadowTransparency

	if typeof(shadowOffset) == "Vector2" then
		if typeof(shadowColor) ~= "Color3" then
			state.ShadowColor = Defaults.ShadowColor
		end

		if type(shadowTransparency) ~= "number" then
			state.ShadowTransparency = state.Transparency
		end
	elseif typeof(shadowColor) == "Color3" then
		state.ShadowOffset = Defaults.ShadowOffset

		if type(shadowTransparency) ~= "number" then
			state.ShadowTransparency = state.Transparency
		end
	elseif type(shadowTransparency) == "number" then
		state.ShadowOffset = Defaults.ShadowOffset

		if type(shadowColor) ~= "number" then
			state.ShadowColor = Defaults.ShadowColor
		end
	else
		state.ShadowOffset = nil
		state.ShadowColor = nil
		state.ShadowTransparency = nil
	end

	local truncate = state.Truncate

	if truncate == false then
		state.Truncate = nil
	elseif truncate ~= true then
		state.Truncate = Defaults.Truncate
	end

	if not v2[state.XAlignment] then
		state.XAlignment = Defaults.XAlignment
	end

	if not v3[state.YAlignment] then
		state.YAlignment = Defaults.YAlignment
	end

	local wordSorting = state.WordSorting

	if wordSorting == false then
		state.WordSorting = nil
	elseif wordSorting ~= true then
		state.WordSorting = Defaults.WordSorting
	end

	local lineSorting = state.LineSorting

	if lineSorting == false then
		state.LineSorting = nil
	elseif lineSorting ~= true then
		state.LineSorting = Defaults.LineSorting
	end
end