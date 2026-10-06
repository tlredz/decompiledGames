local CollectionService = game:GetService("CollectionService")
local TextService = game:GetService("TextService")
local plugin = script:FindFirstAncestorOfClass("Plugin")
local module = nil

if plugin then
	for _, descendant in plugin:GetDescendants() do
		if not descendant:HasTag("Signal") then
			continue
		end

		module = require(descendant)

		if type(module) == "table" and module.new then
			module = module.new
		end

		break
	end
else
	module = CollectionService:GetTagged("Signal")[1]

	if module then
		module = require(module)

		if type(module) == "table" and module.new then
			module = module.new
		end
	end
end

local currentCamera = workspace.CurrentCamera
local Options = require(script.Options)
local Defaults = require(script.Defaults)
local CorrectOptions = require(script.CorrectOptions)
local v = 0
local v2 = {}
local v3 = 0
local v4 = {}
local v5 = 0
local v6 = {}
local v7 = 0
local v8 = {}

local function getTextLabel()
	local v9 = v2[v]

	if not v9 then
		v += 1
		return Instance.new("TextLabel")
	end

	v2[v] = nil
	v -= 1
	return v9
end

local function getImageLabel()
	local v9 = v4[v3]

	if not v9 then
		v3 += 1
		return Instance.new("ImageLabel")
	end

	v4[v3] = nil
	v3 -= 1
	return v9
end

local function getUIStroke()
	local v9 = v6[v5]

	if not v9 then
		v5 += 1
		return Instance.new("UIStroke")
	end

	v6[v5] = nil
	v5 -= 1
	return v9
end

local function getFolder()
	local v9 = v8[v7]

	if not v9 then
		v7 += 1
		return Instance.new("Folder")
	end

	v8[v7] = nil
	v7 -= 1
	return v9
end

local v9 = {}
local v10 = {}
local v11 = {}
local v12 = {}
local v13 = module and {} or nil
local v14 = {}
local v15 = {}
local getTextBoundsParams = Instance.new("GetTextBoundsParams")
getTextBoundsParams.Size = 100
local v16 = {}
require(script.Fonts)
local v17 = {
	GetText = function(p)
		local v18 = v9[p]

		if not v18 then
			error("Invalid frame.", 2)
		end

		return v18
	end,
	GetOptions = function(p)
		if not v10[p] then
			error("Invalid frame.", 2)
		end

		return v10[p]
	end,
	GetBounds = function(p)
		local point = v11[p]

		if not point then
			error("Invalid frame.", 2)
		end

		return point
	end,
	GetUpdateSignal = function(p)
		local v18 = v13[p]

		if not v18 then
			error("Invalid frame.", 2)
		end

		return v18
	end,
	GetCharacters = function(instance)
		local v18 = v10[instance]

		if not v18 then
			error("Invalid frame.", 2)
		end

		return coroutine.wrap(function()
			local lineSorting = v18.LineSorting
			local wordSorting = v18.WordSorting

			if lineSorting and wordSorting then
				local count = 0

				for _, folder in instance:GetChildren() do
					if not folder:IsA("Folder") then
						continue
					end

					for _, child in folder:GetChildren() do
						for _, child2 in child:GetChildren() do
							count += 1
							coroutine.yield(count, child2)
						end
					end
				end
			elseif lineSorting or wordSorting then
				local count = 0

				for _, folder in instance:GetChildren() do
					if not folder:IsA("Folder") then
						continue
					end

					for _, child in folder:GetChildren() do
						count += 1
						coroutine.yield(count, child)
					end
				end
			else
				local v19 = type(v18.Font) == "table" and "TextLabel" or "ImageLabel"

				for i, child in instance:GetChildren() do
					if child:IsA(v19) then
						coroutine.yield(i, child)
					end
				end
			end
		end)
	end
}

local function clear(instance)
	local v18 = v10[instance]
	local v19, v20

	if type(v18.Font) == "table" then
		v19 = v4
		v20 = "ImageLabel"
	else
		v19 = v2
		v20 = "TextLabel"
	end

	local function stashCharacter(child)
		child.Parent = nil
		table.insert(v19, child)
		local uIStroke = child:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Parent = nil
			v6[v5 + 1] = uIStroke
		end

		local firstChildOfClass = child:FindFirstChildOfClass(v20)

		if firstChildOfClass then
			firstChildOfClass.Parent = nil
			table.insert(v19, firstChildOfClass)
			local uIStroke2 = firstChildOfClass:FindFirstChildOfClass("UIStroke")

			if uIStroke2 then
				uIStroke2.Parent = nil
				v6[v5 + 1] = uIStroke2
			end
		end
	end

	local lineSorting = v18.LineSorting
	local wordSorting = v18.WordSorting

	if lineSorting and wordSorting then
		for _, folder in instance:GetChildren() do
			if not folder:IsA("Folder") then
				continue
			end

			folder.Parent = nil
			v8[v7 + 1] = folder

			for _, child in folder:GetChildren() do
				child.Parent = nil
				v8[v7 + 1] = child

				for _, child2 in child:GetChildren() do
					stashCharacter(child2)
				end
			end
		end
	elseif lineSorting or wordSorting then
		for _, folder in instance:GetChildren() do
			if not folder:IsA("Folder") then
				continue
			end

			folder.Parent = nil
			v8[v7 + 1] = folder

			for _, child in folder:GetChildren() do
				stashCharacter(child)
			end
		end
	else
		for _, child in instance:GetChildren() do
			if child:IsA(v20) then
				stashCharacter(child)
			end
		end
	end
end

local function render(parent, value, state)
	local absoluteSize = parent.AbsoluteSize
	local X = absoluteSize.X
	local Y = absoluteSize.Y

	if X < 1 or Y < 1 then
		return
	end

	local v18 = not (X > 0) and 1 or X
	local v19 = not (Y > 0) and 1 or Y

	local function ScalePosition(p: number, p2: number)
		return UDim2.new(p / v18, 0, p2 / v19, 0)
	end

	local function ScaleSize(p: number, p2: number)
		return UDim2.new(p / v18, 0, p2 / v19, 0)
	end

	local font = state.Font
	local size = state.Size
	local color = state.Color
	local transparency = state.Transparency
	local offset = state.Offset
	local rotation = state.Rotation
	local strokeSize = state.StrokeSize
	local strokeScaled = state.StrokeScaled
	local shadowOffset = state.ShadowOffset
	local X2 = nil
	local Y2 = nil
	local lineHeight = state.LineHeight
	local characterSpacing = state.CharacterSpacing
	local truncate = state.Truncate
	local xAlignment = state.XAlignment
	local yAlignment = state.YAlignment
	local wordSorting = state.WordSorting
	local lineSorting = state.LineSorting
	local scaleSize = state.ScaleSize
	local textSize, X3, Y3

	if scaleSize then
		local v21

		if scaleSize:sub(1, 1) == "R" then
			local guiBase = parent:FindFirstAncestorOfClass("GuiBase")
			local viewportSize

			if guiBase then
				if guiBase:IsA("ScreenGui") then
					viewportSize = currentCamera.ViewportSize
				else
					viewportSize = guiBase.AbsoluteSize
				end
			else
				viewportSize = Vector2.zero
			end

			if scaleSize == "RootX" then
				v21 = size * 0.01 * viewportSize.X
			elseif scaleSize == "RootY" then
				v21 = size * 0.01 * viewportSize.Y
			else
				v21 = size * 0.01 * (viewportSize.X + viewportSize.Y) / 2
			end
		elseif scaleSize == "FrameX" then
			v21 = size * 0.01 * X
		elseif scaleSize == "FrameY" then
			v21 = size * 0.01 * Y
		else
			v21 = size * 0.01 * (X + Y) / 4
		end

		local v22

		if v21 < 1 then
			v22 = 1
		else
			local minimumSize = state.MinimumSize

			if minimumSize and state.Size < minimumSize then
				state.Size = minimumSize
			end

			local maximumSize = state.MaximumSize

			if maximumSize and maximumSize < state.Size then
				state.Size = maximumSize
			end

			v22 = type(font) ~= "table" and v21 > 100 and 100 or v21
		end

		textSize = math.round(v22)
		X3 = math.round(offset.X * 0.01 * textSize)
		Y3 = math.round(offset.Y * 0.01 * textSize)

		if strokeSize and not strokeScaled then
			strokeSize = math.round(strokeSize * 0.01 * textSize)
		end

		if shadowOffset then
			X2 = math.round(shadowOffset.X * 0.01 * textSize)
			Y2 = math.round(shadowOffset.Y * 0.01 * textSize)
		end
	else
		textSize = math.round(size)
		X3 = offset.X
		Y3 = offset.Y

		if shadowOffset then
			X2 = shadowOffset.X
			Y2 = shadowOffset.Y
		end
	end

	local v21 = lineHeight * textSize
	local fn, fn2

	if type(font) == "table" then
		local image = "rbxassetid://" .. tostring(font.Image)
		local v23 = textSize / font.Size
		local characters = font.Characters
		local pixelated

		if state.Pixelated then
			pixelated = Enum.ResamplerMode.Pixelated
		else
			pixelated = Enum.ResamplerMode.Default
		end

		fn = function(p)
			local character = characters[p]

			if character then
				return character[6] * textSize * characterSpacing
			end

			return textSize * characterSpacing
		end

		if shadowOffset then
			local shadowColor = state.ShadowColor
			local shadowTransparency = state.ShadowTransparency

			fn2 = function(p, p2, p3)
				local character = characters[p]

				if character then
					local v24 = character[1]
					local v25 = character[2]
					local vector = Vector2.new(v24, v25)
					local imageRectOffset = character[3]
					local v27 = p2 + character[4] * textSize
					local v28 = p3 + character[5] * textSize
					local v29 = math.round(v27 + v24 * v23) - math.round(v27)
					local v30 = math.round(v28 + v25 * v23) - math.round(v28)
					local uDim = UDim2.new(v29 / v18, 0, v30 / v19, 0)
					local parent2 = v4[v3]

					if parent2 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						parent2 = Instance.new("ImageLabel")
					end

					parent2.BackgroundTransparency = 1
					parent2.Image = image
					parent2.ImageColor3 = shadowColor
					parent2.ImageTransparency = shadowTransparency
					parent2.ResampleMode = pixelated
					parent2.ImageRectSize = vector
					parent2.ImageRectOffset = imageRectOffset
					parent2.Size = uDim
					local v32 = math.round(v27) + X3 + X2
					local v33 = math.round(v28) + Y3 + Y2
					parent2.Position = UDim2.new(v32 / v18, 0, v33 / v19, 0)
					parent2.Rotation = rotation
					local v34 = v4[v3]

					if v34 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v34 = Instance.new("ImageLabel")
					end

					v34.BackgroundTransparency = 1
					v34.Image = image
					v34.ImageColor3 = color
					v34.ImageTransparency = transparency
					v34.ResampleMode = pixelated
					v34.ImageRectSize = vector
					v34.ImageRectOffset = imageRectOffset
					v34.Size = uDim
					local v35 = -X2
					local v36 = -Y2
					v34.Position = UDim2.new(v35 / v18, 0, v36 / v19, 0)
					v34.Name = "Main"
					v34.Parent = parent2
					return parent2
				else
					local v24 = v4[v3]

					if v24 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v24 = Instance.new("ImageLabel")
					end

					v24.BackgroundTransparency = 1
					v24.Image = "rbxassetid://75989824347198"
					v24.ImageColor3 = color
					v24.ImageTransparency = transparency
					v24.ResampleMode = pixelated
					v24.Size = UDim2.new(textSize / v18, 0, textSize / v19, 0)
					local v27 = math.round(p2 + textSize) + X3
					local v28 = math.round(p3 + textSize) + Y3
					v24.Position = UDim2.new(v27 / v18, 0, v28 / v19, 0)
					v24.Rotation = rotation
					return v24
				end
			end
		else
			fn2 = function(p, p2, p3)
				local character = characters[p]

				if character then
					local v24 = v4[v3]

					if v24 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v24 = Instance.new("ImageLabel")
					end

					v24.BackgroundTransparency = 1
					v24.Image = image
					v24.ImageColor3 = color
					v24.ImageTransparency = transparency
					v24.ResampleMode = pixelated
					local v25 = character[1]
					local v26 = character[2]
					v24.ImageRectSize = Vector2.new(v25, v26)
					v24.ImageRectOffset = character[3]
					local v27 = p2 + character[4] * textSize
					local v28 = p3 + character[5] * textSize
					local v29 = math.round(v27 + v25 * v23) - math.round(v27)
					local v30 = math.round(v28 + v26 * v23) - math.round(v28)
					v24.Size = UDim2.new(v29 / v18, 0, v30 / v19, 0)
					local v31 = math.round(v27) + X3
					local v32 = math.round(v28) + Y3
					v24.Position = UDim2.new(v31 / v18, 0, v32 / v19, 0)
					v24.Rotation = rotation
					return v24
				else
					local v24 = v4[v3]

					if v24 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v24 = Instance.new("ImageLabel")
					end

					v24.BackgroundTransparency = 1
					v24.Image = "rbxassetid://75989824347198"
					v24.ImageColor3 = color
					v24.ImageTransparency = transparency
					v24.Size = UDim2.new(textSize / v18, 0, textSize / v19, 0)
					local v27 = math.round(p2 + textSize) + X3
					local v28 = math.round(p3 + textSize) + Y3
					v24.Position = UDim2.new(v27 / v18, 0, v28 / v19, 0)
					v24.Rotation = rotation
					return v24
				end
			end
		end
	else
		local strokeColor, strokeTransparency

		if strokeSize then
			strokeColor = state.StrokeColor
			strokeTransparency = state.StrokeTransparency
		else
			strokeColor = nil
			strokeTransparency = nil
		end

		local v22 = 1 / characterSpacing
		local v23 = font.Family .. tostring(font.Weight.Value) .. tostring(font.Style.Value)

		fn = function(text)
			local v24 = text .. v23
			local v25 = v16[v24]

			if not v25 then
				getTextBoundsParams.Text = text
				v25 = TextService:GetTextBoundsAsync(getTextBoundsParams).X * 0.01
				v16[v24] = v25
			end

			return v25 * textSize * characterSpacing
		end

		if shadowOffset then
			local shadowColor = state.ShadowColor
			local shadowTransparency = state.ShadowTransparency

			fn2 = function(text, p, p2, p3)
				local v24 = math.round(p3 * v22)
				local uDim = UDim2.new(v24 / v18, 0, textSize / v19, 0)
				local parent2 = v2[v]

				if parent2 then
					v2[v] = nil
					v -= 1
				else
					v += 1
					parent2 = Instance.new("TextLabel")
				end

				parent2.BackgroundTransparency = 1
				parent2.Text = text
				parent2.TextSize = textSize
				parent2.TextColor3 = shadowColor
				parent2.TextTransparency = shadowTransparency
				parent2.FontFace = font
				parent2.TextXAlignment = Enum.TextXAlignment.Left
				parent2.TextYAlignment = Enum.TextYAlignment.Top
				parent2.Size = uDim
				parent2.Rotation = rotation
				local v27 = p + X3 + X2
				local v28 = p2 + Y3 + Y2
				parent2.Position = UDim2.new(v27 / v18, 0, v28 / v19, 0)
				local parent3 = v2[v]

				if parent3 then
					v2[v] = nil
					v -= 1
				else
					v += 1
					parent3 = Instance.new("TextLabel")
				end

				parent3.BackgroundTransparency = 1
				parent3.Text = text
				parent3.TextSize = textSize
				parent3.TextColor3 = color
				parent3.TextTransparency = transparency
				parent3.FontFace = font
				parent3.TextXAlignment = Enum.TextXAlignment.Left
				parent3.TextYAlignment = Enum.TextYAlignment.Top
				parent3.Size = uDim
				local v30 = -X2
				local v31 = -Y2
				parent3.Position = UDim2.new(v30 / v18, 0, v31 / v19, 0)
				parent3.Name = "Main"
				parent3.Parent = parent2

				if not strokeSize then
					return parent2
				end

				local v32 = v6[v5]

				if v32 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v32 = Instance.new("UIStroke")
				end

				v32.Thickness = strokeSize
				local strokeSizingMode

				if strokeScaled then
					strokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				else
					strokeSizingMode = Enum.StrokeSizingMode.FixedSize
				end

				v32.StrokeSizingMode = strokeSizingMode
				v32.Color = strokeColor
				v32.Transparency = strokeTransparency
				v32.Parent = parent3
				local v34 = v6[v5]

				if v34 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v34 = Instance.new("UIStroke")
				end

				v34.Thickness = strokeSize
				local strokeSizingMode2

				if strokeScaled then
					strokeSizingMode2 = Enum.StrokeSizingMode.ScaledSize
				else
					strokeSizingMode2 = Enum.StrokeSizingMode.FixedSize
				end

				v34.StrokeSizingMode = strokeSizingMode2
				v34.Color = strokeColor
				v34.Transparency = strokeTransparency
				v34.Parent = parent2
				return parent2
			end
		else
			fn2 = function(text, p, p2, p3)
				local parent2 = v2[v]

				if parent2 then
					v2[v] = nil
					v -= 1
				else
					v += 1
					parent2 = Instance.new("TextLabel")
				end

				parent2.BackgroundTransparency = 1
				parent2.Text = text
				parent2.TextSize = textSize
				parent2.TextColor3 = color
				parent2.TextTransparency = transparency
				parent2.FontFace = font
				parent2.TextXAlignment = Enum.TextXAlignment.Left
				parent2.TextYAlignment = Enum.TextYAlignment.Top
				local v25 = math.round(p3 * v22)
				parent2.Size = UDim2.new(v25 / v18, 0, textSize / v19, 0)
				parent2.Rotation = rotation
				local v27 = p + X3
				local v28 = p2 + Y3
				parent2.Position = UDim2.new(v27 / v18, 0, v28 / v19, 0)

				if not strokeSize then
					return parent2
				end

				local v29 = v6[v5]

				if v29 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v29 = Instance.new("UIStroke")
				end

				v29.Thickness = strokeSize
				local strokeSizingMode

				if strokeScaled then
					strokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				else
					strokeSizingMode = Enum.StrokeSizingMode.FixedSize
				end

				v29.StrokeSizingMode = strokeSizingMode
				v29.Color = strokeColor
				v29.Transparency = strokeTransparency
				v29.Parent = parent2
				return parent2
			end
		end
	end

	local v22 = xAlignment ~= "Justified" and 0 or X
	local v23 = fn(" ")
	local v24 = fn(".")
	local v25 = v24 * 3
	local v26 = {}
	local flag = nil
	local fn3
	fn3 = truncate and function()
		local count = #v26
		local v27 = v26[count]
		local v28 = v27[1]

		if #v28 == 0 then
			v27[2] = v25
			local v29 = { ".", v24 }
			v28[1] = { v29, v29, v29 }
		else
			local v29 = v25

			for _, v30 in v28 do
				if v30 then
					for _, v31 in v30 do
						v29 += v31[2]
					end
				end

				v29 += v23
			end

			for i = #v28, 1, -1 do
				local v30 = v28[i]

				if v30 then
					if v29 < X then
						v27[2] = v29
						local v31 = { ".", v24 }
						local count2 = #v30
						v30[count2 + 1] = v31
						v30[count2 + 2] = v31
						v30[count2 + 3] = v31
						return
					else
						for i2 = #v30, 2, -1 do
							v29 -= v30[i2][2]
							v30[i2] = nil

							if not (v29 < X) then
								continue
							end

							v27[2] = v29
							local v31 = { ".", v24 }
							local count2 = #v30
							v30[count2 + 1] = v31
							v30[count2 + 2] = v31
							v30[count2 + 3] = v31
							return
						end

						v29 -= v23 + v30[1][2]
						v28[i] = nil
					end
				else
					v28[i] = nil
					v29 -= v23
				end
			end

			if count == 1 then
				v27[2] = v25
				local v30 = { ".", v24 }
				table.insert(v28, { v30, v30, v30 })
			else
				v26[count] = nil
				fn3()
			end
		end
	end or nil
	local v27 = -v23
	local v28 = 1
	local v29 = {}

	for _, v31 in value:split("\n") do
		if v31 == "" then
			if #v29 > 0 then
				if v22 < v27 then
					v22 = v27
				end

				v26[v28] = { v29, v27 }
				v28 += 1
			end

			v26[v28] = {
				{},
				0
			}
			v28 += 1
			v27 = -v23
			v29 = {}
		else
			local v32 = 1

			for _, v34 in v31:split(" ") do
				if v34 == "" then
					v29[v32] = false
					v32 += 1
					v27 += v23
				else
					local v35 = v23
					local v36 = {}
					local v37 = 1

					for k in v34:gmatch(utf8.charpattern) do
						local v38 = fn(k)
						v35 += v38
						v36[v37] = { k, v38 }
						v37 += 1
					end

					if X < v27 + v35 and v32 > 1 then
						if v27 < X and v22 < v27 then
							v22 = v27
						end

						if truncate and Y < v28 * v21 + textSize then
							v29[v32] = v36
							v32 += 1
							v26[v28] = { v29, v27 }
							v28 += 1
							fn3()
							flag = true
							break
						else
							v26[v28] = { v29, v27 }
							v28 += 1
							v27 = v35
							v32 = 2
							v29 = { v36 }
						end
					else
						v29[v32] = v36
						v32 += 1
						v27 += v35
					end
				end
			end

			if v22 < v27 then
				v22 = v27
			end

			if flag then
				break
			end

			v26[v28] = { v29, v27 }
			v28 += 1
			v27 = -v23
			v29 = {}
		end
	end

	local v31, v32, v33

	if yAlignment == "Top" then
		v31 = (v28 - 2) * v21 + textSize
		v32 = 0
		v33 = 0
	elseif yAlignment == "Center" then
		v31 = (v28 - 2) * v21 + textSize
		v32 = math.round((Y - v31) / 2)
		v33 = 0
	elseif yAlignment == "Bottom" then
		v31 = (v28 - 2) * v21 + textSize
		v32 = Y - v31
		v33 = 0
	elseif #v26 == 1 then
		v31 = textSize
		v32 = 0
		v33 = 0
	else
		local v34 = v28 - 2
		v33 = (Y - (v34 * v21 + textSize)) / v34
		v31 = Y
		v32 = 0
	end

	local count = 0
	local count2 = 0

	for k, v34 in v26 do
		local v35 = v34[1]
		local v36, v37

		if xAlignment == "Left" then
			v36 = 0
			v37 = 0
		elseif xAlignment == "Center" then
			v37 = math.round((X - v34[2]) / 2)
			v36 = 0
		elseif xAlignment == "Right" then
			v37 = X - v34[2]
			v36 = 0
		else
			local count3 = #v35
			v36 = not (count3 > 1) and 0 or (X - v34[2]) / (count3 - 1)
			v37 = 0
		end

		local parent2

		if lineSorting then
			parent2 = v8[v7]

			if parent2 then
				v8[v7] = nil
				v7 -= 1
			else
				v7 += 1
				parent2 = Instance.new("Folder")
			end

			parent2.Name = tostring(k)
			parent2.Parent = parent
		else
			parent2 = parent
		end

		for k2, v39 in v35 do
			if v39 then
				local parent3

				if wordSorting then
					parent3 = v8[v7]

					if parent3 then
						v8[v7] = nil
						v7 -= 1
					else
						v7 += 1
						parent3 = Instance.new("Folder")
					end

					if lineSorting then
						parent3.Name = tostring(k2)
					else
						count += 1
						parent3.Name = tostring(count)
					end

					parent3.Parent = parent2
				else
					parent3 = parent2
				end

				for k3, v41 in v39 do
					local v42 = v41[2]
					local v43 = fn2(v41[1], v37, v32, v42)

					if lineSorting or wordSorting then
						v43.Name = tostring(k3)
					else
						count2 += 1
						v43.Name = tostring(count2)
					end

					v43.Parent = parent3
					v37 += v42
				end
			end

			v37 += v23 + v36
		end

		v32 += v21 + v33
	end

	v11[parent] = Vector2.new(v22, v31)

	if module then
		v13[parent]:Fire()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelPendingRender(p)
	local thread = v15[p]

	if thread then
		task.cancel(thread)
		v15[p] = nil
	end
end

local renderWhenSettled

renderWhenSettled = function(parent, p2, p3, point: Vector2?)
	cancelPendingRender(parent) -- equivalent call inferred; original call site unknown
	local v18 = point or parent.AbsoluteSize
	v15[parent] = task.delay(0.05, function()
		v15[parent] = nil

		if v9[parent] ~= p2 or v10[parent] ~= p3 then
			return
		end

		local absoluteSize = parent.AbsoluteSize

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			renderWhenSettled(parent, p2, p3)
			return
		end

		if math.abs(absoluteSize.X - v18.X) > 1 or math.abs(absoluteSize.Y - v18.Y) > 1 then
			renderWhenSettled(parent, p2, p3, absoluteSize)
			return
		end

		clear(parent)
		render(parent, p2, p3)
		v14[parent] = absoluteSize
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableDynamic(guiObject, _)
	local connection = v12[guiObject]

	if connection then
		connection:Disconnect()
	end

	v12[guiObject] = guiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if v15[guiObject] then
			return
		end

		local v18 = v9[guiObject]

		if v18 == nil then
			return
		end

		if v18 == "" then
			v11[guiObject] = Vector2.zero

			if module then
				v13[guiObject]:Fire()
			end
		else
			local parent = guiObject
			local v20 = v10[guiObject]
			cancelPendingRender(parent) -- equivalent call inferred; original call site unknown
			local point = nil or parent.AbsoluteSize
			v15[parent] = task.delay(0.05, function()
				v15[parent] = nil

				if v9[parent] ~= v18 or v10[parent] ~= v20 then
					return
				end

				local absoluteSize = parent.AbsoluteSize

				if absoluteSize.X < 1 or absoluteSize.Y < 1 then
					renderWhenSettled(parent, v18, v20)
					return
				end

				if math.abs(absoluteSize.X - point.X) > 1 or math.abs(absoluteSize.Y - point.Y) > 1 then
					renderWhenSettled(parent, v18, v20, absoluteSize)
					return
				end

				clear(parent)
				render(parent, v18, v20)
				v14[parent] = absoluteSize
			end)
		end
	end)
end

local function create(guiObject, value, p)
	v9[guiObject] = value
	v10[guiObject] = p

	if value == "" then
		v11[guiObject] = Vector2.zero

		if module then
			v13[guiObject]:Fire()
		end
	else
		local absoluteSize = guiObject.AbsoluteSize

		if absoluteSize.X >= 1 and absoluteSize.Y >= 1 and v14[guiObject] == absoluteSize then
			render(guiObject, value, p)
			return
		end

		cancelPendingRender(guiObject) -- equivalent call inferred; original call site unknown
		local point = nil or guiObject.AbsoluteSize
		v15[guiObject] = task.delay(0.05, function()
			v15[guiObject] = nil

			if v9[guiObject] ~= value or v10[guiObject] ~= p then
				return
			end

			local absoluteSize2 = guiObject.AbsoluteSize

			if absoluteSize2.X < 1 or absoluteSize2.Y < 1 then
				renderWhenSettled(guiObject, value, p)
				return
			end

			if math.abs(absoluteSize2.X - point.X) > 1 or math.abs(absoluteSize2.Y - point.Y) > 1 then
				renderWhenSettled(guiObject, value, p, absoluteSize2)
				return
			end

			clear(guiObject)
			render(guiObject, value, p)
			v14[guiObject] = absoluteSize2
		end)
	end
end

function v17.Create(guiObject, value: string, p)
	local v18 = v10[guiObject]

	if not v18 and (typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject")) then
		error("Invalid frame.", 2)
	end

	if type(value) ~= "string" then
		error("Invalid text.", 2)
	end

	if v18 then
		clear(guiObject)

		if type(p) == "table" then
			for k, v19 in p do
				if Options[k] then
					if v19 then
						v18[k] = v19
					else
						v18[k] = nil
					end
				else
					warn("Invalid option '" .. k .. "'.")
				end
			end

			CorrectOptions(v18)
		end

		if type(v18.Dynamic) ~= "boolean" then
			v18.Dynamic = Defaults.Dynamic
		end

		if v18.Dynamic == true then
			create(guiObject, value, v18)
			enableDynamic(guiObject) -- equivalent call inferred; original call site unknown
		else
			local connection = not v18.Dynamic and v12[guiObject]

			if connection then
				connection:Disconnect()
			end

			v18.Dynamic = nil
			create(guiObject, value, v18)
		end
	else
		if module then
			v13[guiObject] = module()
		end

		if type(p) == "table" then
			for k in p do
				if Options[k] then
					continue
				end

				p[k] = nil
				warn("Invalid option '" .. k .. "'.")
			end
		else
			p = {}
		end

		CorrectOptions(p)

		if type(p.Dynamic) ~= "boolean" then
			p.Dynamic = Defaults.Dynamic
		end

		if p.Dynamic == true then
			create(guiObject, value, p)
			enableDynamic(guiObject) -- equivalent call inferred; original call site unknown
		else
			local connection = not p.Dynamic and v12[guiObject]

			if connection then
				connection:Disconnect()
			end

			p.Dynamic = nil
			create(guiObject, value, p)
		end

		guiObject.Destroying:Once(function()
			clear(guiObject)

			if module then
				v13[guiObject]:Destroy()
				v13[guiObject] = nil
			end

			v12[guiObject] = nil
			cancelPendingRender(guiObject) -- equivalent call inferred; original call site unknown
			v9[guiObject] = nil
			v10[guiObject] = nil
			v11[guiObject] = nil
			v14[guiObject] = nil
		end)
	end
end

return table.freeze(v17)