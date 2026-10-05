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
local getTextBoundsParams = Instance.new("GetTextBoundsParams")
getTextBoundsParams.Size = 100
local v14 = {}
require(script.Fonts)
local v15 = {
	GetText = function(p)
		local v16 = v9[p]

		if not v16 then
			error("Invalid frame.", 2)
		end

		return v16
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
		local v16 = v13[p]

		if not v16 then
			error("Invalid frame.", 2)
		end

		return v16
	end,
	GetCharacters = function(instance)
		local v16 = v10[instance]

		if not v16 then
			error("Invalid frame.", 2)
		end

		return coroutine.wrap(function()
			local lineSorting = v16.LineSorting
			local wordSorting = v16.WordSorting

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
				local v17 = type(v16.Font) == "table" and "ImageLabel" or "TextLabel"

				for i, child in instance:GetChildren() do
					if child:IsA(v17) then
						coroutine.yield(i, child)
					end
				end
			end
		end)
	end
}

local function clear(instance)
	local v16 = v10[instance]
	local v17, v18

	if type(v16.Font) == "table" then
		v17 = v4
		v18 = "ImageLabel"
	else
		v17 = v2
		v18 = "TextLabel"
	end

	local function stashCharacter(child)
		child.Parent = nil
		table.insert(v17, child)
		local uIStroke = child:FindFirstChildOfClass("UIStroke")

		if uIStroke then
			uIStroke.Parent = nil
			v6[v5 + 1] = uIStroke
		end

		local firstChildOfClass = child:FindFirstChildOfClass(v18)

		if firstChildOfClass then
			firstChildOfClass.Parent = nil
			table.insert(v17, firstChildOfClass)
			local uIStroke2 = firstChildOfClass:FindFirstChildOfClass("UIStroke")

			if uIStroke2 then
				uIStroke2.Parent = nil
				v6[v5 + 1] = uIStroke2
			end
		end
	end

	local lineSorting = v16.LineSorting
	local wordSorting = v16.WordSorting

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
			if child:IsA(v18) then
				stashCharacter(child)
			end
		end
	end
end

local function render(parent, value, state)
	local absoluteSize = parent.AbsoluteSize
	local X = absoluteSize.X
	local Y = absoluteSize.Y
	local font = state.Font
	local size = state.Size
	local color = state.Color
	local transparency = state.Transparency
	local offset = state.Offset
	local rotation = state.Rotation
	local strokeSize = state.StrokeSize
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
		local v17

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
				v17 = size * 0.01 * viewportSize.X
			elseif scaleSize == "RootY" then
				v17 = size * 0.01 * viewportSize.Y
			else
				v17 = size * 0.01 * (viewportSize.X + viewportSize.Y) / 2
			end
		elseif scaleSize == "FrameX" then
			v17 = size * 0.01 * X
		elseif scaleSize == "FrameY" then
			v17 = size * 0.01 * Y
		else
			v17 = size * 0.01 * (X + Y) / 2
		end

		local v18

		if v17 < 1 then
			v18 = 1
		else
			local minimumSize = state.MinimumSize

			if minimumSize and state.Size < minimumSize then
				state.Size = minimumSize
			end

			local maximumSize = state.MaximumSize

			if maximumSize and maximumSize < state.Size then
				state.Size = maximumSize
			end

			v18 = type(font) ~= "table" and v17 > 100 and 100 or v17
		end

		textSize = math.round(v18)
		X3 = math.round(offset.X * 0.01 * textSize)
		Y3 = math.round(offset.Y * 0.01 * textSize)
		strokeSize = strokeSize and math.round(strokeSize * 0.01 * textSize)

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

	local v17 = lineHeight * textSize
	local fn, fn2

	if type(font) == "table" then
		local image = "rbxassetid://" .. tostring(font.Image)
		local v19 = textSize / font.Size
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
					local v20 = character[1]
					local v21 = character[2]
					local vector = Vector2.new(v20, v21)
					local imageRectOffset = character[3]
					local v23 = p2 + character[4] * textSize
					local v24 = p3 + character[5] * textSize
					local uDim = UDim2.fromOffset(
						math.round(v23 + v20 * v19) - math.round(v23),
						math.round(v24 + v21 * v19) - math.round(v24)
					)
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
					parent2.Position = UDim2.fromOffset(math.round(v23) + X3 + X2, math.round(v24) + Y3 + Y2)
					parent2.Rotation = rotation
					local v26 = v4[v3]

					if v26 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v26 = Instance.new("ImageLabel")
					end

					v26.BackgroundTransparency = 1
					v26.Image = image
					v26.ImageColor3 = color
					v26.ImageTransparency = transparency
					v26.ResampleMode = pixelated
					v26.ImageRectSize = vector
					v26.ImageRectOffset = imageRectOffset
					v26.Size = uDim
					v26.Position = UDim2.fromOffset(-X2, -Y2)
					v26.Name = "Main"
					v26.Parent = parent2
					return parent2
				else
					local v20 = v4[v3]

					if v20 then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						v20 = Instance.new("ImageLabel")
					end

					v20.BackgroundTransparency = 1
					v20.Image = "rbxassetid://75989824347198"
					v20.ImageColor3 = color
					v20.ImageTransparency = transparency
					v20.ResampleMode = pixelated
					v20.Size = UDim2.fromOffset(textSize, textSize)
					v20.Position = UDim2.fromOffset(math.round(p2 + textSize) + X3, math.round(p3 + textSize) + Y3)
					v20.Rotation = rotation
					return v20
				end
			end
		else
			fn2 = function(p, p2, p3)
				local character = characters[p]

				if character then
					local selected = v4[v3]

					if selected then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						selected = Instance.new("ImageLabel")
					end

					selected.BackgroundTransparency = 1
					selected.Image = image
					selected.ImageColor3 = color
					selected.ImageTransparency = transparency
					selected.ResampleMode = pixelated
					local v21 = character[1]
					local v22 = character[2]
					selected.ImageRectSize = Vector2.new(v21, v22)
					selected.ImageRectOffset = character[3]
					local v23 = p2 + character[4] * textSize
					local v24 = p3 + character[5] * textSize
					selected.Size = UDim2.fromOffset(
						math.round(v23 + v21 * v19) - math.round(v23),
						math.round(v24 + v22 * v19) - math.round(v24)
					)
					selected.Position = UDim2.fromOffset(math.round(v23) + X3, math.round(v24) + Y3)
					selected.Rotation = rotation
					return selected
				else
					local selected = v4[v3]

					if selected then
						v4[v3] = nil
						v3 -= 1
					else
						v3 += 1
						selected = Instance.new("ImageLabel")
					end

					selected.BackgroundTransparency = 1
					selected.Image = "rbxassetid://75989824347198"
					selected.ImageColor3 = color
					selected.ImageTransparency = transparency
					selected.Size = UDim2.fromOffset(textSize, textSize)
					selected.Position = UDim2.fromOffset(math.round(p2 + textSize) + X3, math.round(p3 + textSize) + Y3)
					selected.Rotation = rotation
					return selected
				end
			end
		end
	else
		local strokeColor, strokeTransparency

		if strokeSize then
			strokeSize = strokeSize < 1 and 1 or strokeSize
			strokeColor = state.StrokeColor
			strokeTransparency = state.StrokeTransparency
		else
			strokeColor = nil
			strokeTransparency = nil
		end

		local v18 = 1 / characterSpacing
		local v19 = font.Family .. tostring(font.Weight.Value) .. tostring(font.Style.Value)

		fn = function(text)
			local v20 = text .. v19
			local v21 = v14[v20]

			if not v21 then
				getTextBoundsParams.Text = text
				v21 = TextService:GetTextBoundsAsync(getTextBoundsParams).X * 0.01
				v14[v20] = v21
			end

			return v21 * textSize * characterSpacing
		end

		if shadowOffset then
			local shadowColor = state.ShadowColor
			local shadowTransparency = state.ShadowTransparency

			fn2 = function(text, p, p2, p3)
				local uDim = UDim2.fromOffset(math.round(p3 * v18), textSize)
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
				parent2.Position = UDim2.fromOffset(p + X3 + X2, p2 + Y3 + Y2)
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
				parent3.Position = UDim2.fromOffset(-X2, -Y2)
				parent3.Name = "Main"
				parent3.Parent = parent2

				if not strokeSize then
					return parent2
				end

				local v22 = v6[v5]

				if v22 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v22 = Instance.new("UIStroke")
				end

				v22.Thickness = strokeSize
				v22.Color = strokeColor
				v22.Transparency = strokeTransparency
				v22.Parent = parent3
				local v23 = v6[v5]

				if v23 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v23 = Instance.new("UIStroke")
				end

				v23.Thickness = strokeSize
				v23.Color = strokeColor
				v23.Transparency = strokeTransparency
				v23.Parent = parent2
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
				parent2.Size = UDim2.fromOffset(math.round(p3 * v18), textSize)
				parent2.Rotation = rotation
				parent2.Position = UDim2.fromOffset(p + X3, p2 + Y3)

				if not strokeSize then
					return parent2
				end

				local v21 = v6[v5]

				if v21 then
					v6[v5] = nil
					v5 -= 1
				else
					v5 += 1
					v21 = Instance.new("UIStroke")
				end

				v21.Thickness = strokeSize
				v21.Color = strokeColor
				v21.Transparency = strokeTransparency
				v21.Parent = parent2
				return parent2
			end
		end
	end

	local v18 = xAlignment ~= "Justified" and 0 or X
	local v19 = fn(" ")
	local v20 = fn(".")
	local v21 = v20 * 3
	local v22 = {}
	local flag = nil
	local fn3
	fn3 = truncate and function()
		local count = #v22
		local v23 = v22[count]
		local v24 = v23[1]

		if #v24 == 0 then
			v23[2] = v21
			local v25 = { ".", v20 }
			v24[1] = { v25, v25, v25 }
		else
			local v25 = v21

			for _, v26 in v24 do
				if v26 then
					for _, v27 in v26 do
						v25 += v27[2]
					end
				end

				v25 += v19
			end

			for i = #v24, 1, -1 do
				local v26 = v24[i]

				if v26 then
					if v25 < X then
						v23[2] = v25
						local v27 = { ".", v20 }
						local count2 = #v26
						v26[count2 + 1] = v27
						v26[count2 + 2] = v27
						v26[count2 + 3] = v27
						return
					else
						for i2 = #v26, 2, -1 do
							v25 -= v26[i2][2]
							v26[i2] = nil

							if not (v25 < X) then
								continue
							end

							v23[2] = v25
							local v27 = { ".", v20 }
							local count2 = #v26
							v26[count2 + 1] = v27
							v26[count2 + 2] = v27
							v26[count2 + 3] = v27
							return
						end

						v25 -= v19 + v26[1][2]
						v24[i] = nil
					end
				else
					v24[i] = nil
					v25 -= v19
				end
			end

			if count == 1 then
				v23[2] = v21
				local v26 = { ".", v20 }
				table.insert(v24, { v26, v26, v26 })
			else
				v22[count] = nil
				fn3()
			end
		end
	end or nil
	local v23 = -v19
	local v24 = 1
	local v25 = {}

	for _, v27 in value:split("\n") do
		if v27 == "" then
			if #v25 > 0 then
				if v18 < v23 then
					v18 = v23
				end

				v22[v24] = { v25, v23 }
				v24 += 1
			end

			v22[v24] = {
				{},
				0
			}
			v24 += 1
			v23 = -v19
			v25 = {}
		else
			local v28 = 1

			for _, v30 in v27:split(" ") do
				if v30 == "" then
					v25[v28] = false
					v28 += 1
					v23 += v19
				else
					local v31 = v19
					local v32 = {}
					local v33 = 1

					for k in v30:gmatch(utf8.charpattern) do
						local v34 = fn(k)
						v31 += v34
						v32[v33] = { k, v34 }
						v33 += 1
					end

					if X < v23 + v31 and v28 > 1 then
						if v23 < X and v18 < v23 then
							v18 = v23
						end

						if truncate and Y < v24 * v17 + textSize then
							v25[v28] = v32
							v28 += 1
							v22[v24] = { v25, v23 }
							v24 += 1
							fn3()
							flag = true
							break
						else
							v22[v24] = { v25, v23 }
							v24 += 1
							v23 = v31
							v28 = 2
							v25 = { v32 }
						end
					else
						v25[v28] = v32
						v28 += 1
						v23 += v31
					end
				end
			end

			if v18 < v23 then
				v18 = v23
			end

			if flag then
				break
			end

			v22[v24] = { v25, v23 }
			v24 += 1
			v23 = -v19
			v25 = {}
		end
	end

	local v27, v28, v29

	if yAlignment == "Top" then
		v27 = (v24 - 2) * v17 + textSize
		v28 = 0
		v29 = 0
	elseif yAlignment == "Center" then
		v27 = (v24 - 2) * v17 + textSize
		v28 = math.round((Y - v27) / 2)
		v29 = 0
	elseif yAlignment == "Bottom" then
		v27 = (v24 - 2) * v17 + textSize
		v28 = Y - v27
		v29 = 0
	elseif #v22 == 1 then
		v27 = textSize
		v28 = 0
		v29 = 0
	else
		local v30 = v24 - 2
		v29 = (Y - (v30 * v17 + textSize)) / v30
		v27 = Y
		v28 = 0
	end

	local count = 0
	local count2 = 0

	for k, v30 in v22 do
		local v31 = v30[1]
		local v32, v33

		if xAlignment == "Left" then
			v32 = 0
			v33 = 0
		elseif xAlignment == "Center" then
			v33 = math.round((X - v30[2]) / 2)
			v32 = 0
		elseif xAlignment == "Right" then
			v33 = X - v30[2]
			v32 = 0
		else
			local count3 = #v31
			v32 = not (count3 > 1) and 0 or (X - v30[2]) / (count3 - 1)
			v33 = 0
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

		for k2, v35 in v31 do
			if v35 then
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

				for k3, v37 in v35 do
					local v38 = v37[2]
					local v39 = fn2(v37[1], v33, v28, v38)

					if lineSorting or wordSorting then
						v39.Name = tostring(k3)
					else
						count2 += 1
						v39.Name = tostring(count2)
					end

					v39.Parent = parent3
					v33 += v38
				end
			end

			v33 += v19 + v32
		end

		v28 += v17 + v29
	end

	v11[parent] = Vector2.new(v18, v27)

	if module then
		v13[parent]:Fire()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enableDynamic(guiObject, _)
	v12[guiObject] = guiObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		clear(guiObject)
		local v16 = v9[guiObject]

		if v16 == "" then
			v11[guiObject] = Vector2.zero

			if module then
				v13[guiObject]:Fire()
			end
		else
			render(guiObject, v16, v10[guiObject])
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function create(guiObject, value, p)
	v9[guiObject] = value
	v10[guiObject] = p

	if value == "" then
		v11[guiObject] = Vector2.zero

		if module then
			v13[guiObject]:Fire()
		end
	else
		render(guiObject, value, p)
	end
end

function v15.Create(guiObject, value: string, p)
	local v16 = v10[guiObject]

	if not v16 and (typeof(guiObject) ~= "Instance" or not guiObject:IsA("GuiObject")) then
		error("Invalid frame.", 2)
	end

	if type(value) ~= "string" then
		error("Invalid text.", 2)
	end

	if v16 then
		clear(guiObject)

		if type(p) == "table" then
			for k, v17 in p do
				if Options[k] then
					if v17 then
						v16[k] = v17
					else
						v16[k] = nil
					end
				else
					warn("Invalid option '" .. k .. "'.")
				end
			end

			CorrectOptions(v16)
		end

		if type(v16.Dynamic) ~= "boolean" then
			v16.Dynamic = Defaults.Dynamic
		end

		if v16.Dynamic == true then
			create(guiObject, value, v16) -- equivalent call inferred; original call site unknown
			enableDynamic(guiObject) -- equivalent call inferred; original call site unknown
		else
			local connection = not v16.Dynamic and v12[guiObject]

			if connection then
				connection:Disconnect()
			end

			v16.Dynamic = nil
			create(guiObject, value, v16) -- equivalent call inferred; original call site unknown
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
		guiObject.Destroying:Once(function()
			if guiObject:IsDescendantOf(game) then
				clear(guiObject)
			end

			if module then
				v13[guiObject]:Destroy()
				v13[guiObject] = nil
			end

			v12[guiObject] = nil
			v9[guiObject] = nil
			v10[guiObject] = nil
			v11[guiObject] = nil
		end)

		if type(p.Dynamic) ~= "boolean" then
			p.Dynamic = Defaults.Dynamic
		end

		if p.Dynamic == true then
			create(guiObject, value, p) -- equivalent call inferred; original call site unknown
			enableDynamic(guiObject) -- equivalent call inferred; original call site unknown
		else
			local connection = not p.Dynamic and v12[guiObject]

			if connection then
				connection:Disconnect()
			end

			p.Dynamic = nil
			create(guiObject, value, p) -- equivalent call inferred; original call site unknown
		end
	end
end

return table.freeze(v15)