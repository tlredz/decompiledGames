local CollectionService = game:GetService("CollectionService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local TekrinnDialogue = {}
local _ = {
	{
		Text = "This will be the ",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 17, 17)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		}),
		TextStrokeColor = Color3.new(0, 0, 0),
		Bold = false,
		Italic = false,
		Shake = {
			Enabled = false,
			Intensity = 1,
			Lifetime = 2
		},
		TypeSpeed = 0.03
	},
	{
		Text = "LAST TIME!",
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 17, 17))
		}),
		TextStrokeColor = Color3.new(0, 0, 0),
		Bold = true,
		Italic = true,
		Shake = {
			Enabled = true,
			Intensity = 5,
			Lifetime = 1
		},
		TypeSpeed = 0.04
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function easeOutQuad(p)
	return math.pow(p - 1, 3) * 2.70158 + 1 + math.pow(p - 1, 2) * 1.70158
end

function getColor(p, list)
	local v = list[1]
	local _ = list[#list]
	local value = v.Value

	for i = 1, #list - 1 do
		if not (list[i].Time <= p and p <= list[i + 1].Time) then
			continue
		end

		local v2 = list[i]
		local v3 = list[i + 1]
		local v4 = (p - v2.Time) / (v3.Time - v2.Time)
		return (v2.Value:lerp(v3.Value, v4))
	end

	return value
end

local function retireTexts(template)
	for _, child in template:GetChildren() do
		if child.Name ~= "letter" then
			continue
		end

		child:SetAttribute("Ending", true)
		game.TweenService:Create(child, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = child.Position + UDim2.new(0, 0, 0, 50),
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		game.Debris:AddItem(child, 0.5)
	end
end

local function trimString(value)
	if type(value) == "string" then
		return value:gsub("^%s+", ""):gsub("%s+$", "")
	end

	return ""
end

local function normalizeIconValue(value)
	local selected = type(value) ~= "string" and "" or value:gsub("^%s+", ""):gsub("%s+$", "")

	if selected == "" then
		return ""
	end

	if selected:match("^rbxassetid://%d+$") or selected:match("^rbxasset://") or selected:match("^rbxthumb://") then
		return selected
	end

	if selected:lower():match("^https?://") then
		local v2 = selected:match("create%.roblox%.com/store/asset/(%d+)") or selected:match("roblox%.com/library/(%d+)") or selected:match("[?&]assetId=(%d+)") or selected:match("[?&]id=(%d+)")

		if v2 then
			return "rbxassetid://" .. v2
		end

		return selected
	else
		local match = selected:match("[?&]id=(%d+)")

		if match then
			return "rbxassetid://" .. match
		end

		local match2 = selected:match("(%d+)")

		if match2 then
			return "rbxassetid://" .. match2
		end

		return selected
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveGapBefore(item)
	local gapBefore = tonumber(item and item.GapBefore) or 0
	return (math.clamp(gapBefore ~= gapBefore and 0 or gapBefore, -300, 300))
end

local function resolveSpeakerName(value)
	if not (typeof(value) ~= "Instance" and type(value) ~= "table") then
		return trimString(value.Name)
	end

	if type(value) == "string" then
		return trimString(value)
	end

	return ""
end

local function toColor3FromAny(nameColor)
	if typeof(nameColor) == "Color3" then
		return nameColor
	end

	if typeof(nameColor) == "Vector3" then
		return Color3.fromRGB(
			math.clamp(math.floor(nameColor.X + 0.5), 0, 255),
			math.clamp(math.floor(nameColor.Y + 0.5), 0, 255),
			(math.clamp(math.floor(nameColor.Z + 0.5), 0, 255))
		)
	end

	return nil
end

local uDim = UDim2.new(0.5, 0, 1, 0)
local uDim2 = UDim2.new(0.5, 0, 0.965, 0)
local uDim3 = UDim2.new(0.5, 0, 0.82, 0)

local function findMoveEditorTimelineGui()
	if not localPlayer then
		return nil
	end

	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local moveEditor = playerGui:FindFirstChild("MoveEditor")

	if not (moveEditor and moveEditor:IsA("ScreenGui") and moveEditor.Enabled) then
		return nil
	end

	local timeline = moveEditor:FindFirstChild("Timeline", true)

	if timeline and timeline:IsA("GuiObject") and timeline.Visible then
		return timeline
	end

	return nil
end

local function resolveHigherUpHolderPosition(guiObject, p)
	if not p then
		return uDim2
	end

	local moveEditorTimelineGui = findMoveEditorTimelineGui()

	if not moveEditorTimelineGui then
		return uDim2
	end

	if not (guiObject and guiObject:IsA("GuiObject")) then
		return uDim3
	end

	local Y = 0
	local currentCamera = workspace.CurrentCamera

	if currentCamera and currentCamera.ViewportSize.Y > 0 then
		Y = currentCamera.ViewportSize.Y
	elseif guiObject.AbsoluteSize.Y > 0 then
		Y = guiObject.AbsoluteSize.Y
	end

	if Y <= 0 then
		return uDim3
	end

	local v = math.max(8, (math.floor((guiObject.AbsoluteSize.Y > 0 and guiObject.AbsoluteSize.Y or 56) * 0.15)))
	local v2 = math.clamp((moveEditorTimelineGui.AbsolutePosition.Y - v) / Y + 0.06, 0.15, 0.94)
	return UDim2.new(0.5, 0, v2, 0)
end

local function doText(items, p)
	local v = p or localPlayer
	local name

	if typeof(v) == "Instance" then
		local name2 = v.Name
		name = type(name2) ~= "string" and "" or name2:gsub("^%s+", ""):gsub("%s+$", "")
	elseif type(v) == "table" then
		local name2 = v.Name
		name = type(name2) ~= "string" and "" or name2:gsub("^%s+", ""):gsub("%s+$", "")
	else
		name = type(v) ~= "string" and "" or type(v) ~= "string" and "" or v:gsub("^%s+", ""):gsub("%s+$", "")
	end

	if name == "" then
		name = localPlayer and localPlayer.Name or "Speaker"
	end

	local v2 = localPlayer.PlayerGui:FindFirstChild(name .. "KJUI") or script.KJDialogue:Clone()
	local v3 = ""
	local total = 0
	local total2 = 0
	local total3 = 0

	if v2:GetAttribute("Created") then
		v2:SetAttribute("Created", os.clock())
	else
		local template = v2:WaitForChild("Holder"):WaitForChild("Template")
		local imageLabel = template:WaitForChild("ImageLabel")

		if type(imageLabel:GetAttribute("DefaultPosXScale")) ~= "number" then
			local position = imageLabel.Position
			imageLabel:SetAttribute("DefaultPosXScale", position.X.Scale)
			imageLabel:SetAttribute("DefaultPosXOffset", position.X.Offset)
			imageLabel:SetAttribute("DefaultPosYScale", position.Y.Scale)
			imageLabel:SetAttribute("DefaultPosYOffset", position.Y.Offset)
		end

		imageLabel.BackgroundTransparency = 1
		v2.Holder.Position -= UDim2.new(0, 0, 0, #CollectionService:GetTagged("KJUI") * 100)
		imageLabel.Position -= UDim2.new(0, 0, 0, 100)
		imageLabel.ImageTransparency = 1
		local name2 = template:WaitForChild("Name")
		name2.Position -= UDim2.new(0, 0, 0, 100)
		local name_2 = template:WaitForChild("Name")
		name_2.TextTransparency = 1
		local name_3 = template:WaitForChild("Name")
		name_3.TextStrokeTransparency = 1
		game.TweenService:Create(imageLabel, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = imageLabel.Position + UDim2.new(0, 0, 0, 100),
			ImageTransparency = 0
		}):Play()
		game.TweenService:Create(
			template:WaitForChild("Name"),
			TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Position = template:WaitForChild("Name").Position + UDim2.new(0, 0, 0, 100),
				TextTransparency = 0,
				TextStrokeTransparency = 0
			}
		):Play()
		task.spawn(function()
			v2:SetAttribute("Created", os.clock())

			repeat
				task.wait()
			until os.clock() - v2:GetAttribute("Created") > 5 or not v2.Parent

			v2.Name = "deleting"
			retireTexts(v2.Holder.Template)
			game.TweenService:Create(imageLabel, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Position = imageLabel.Position - UDim2.new(0, 0, 0, 100),
				ImageTransparency = 1
			}):Play()
			game.TweenService:Create(
				template:WaitForChild("Name"),
				TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
				{
					Position = template:WaitForChild("Name").Position - UDim2.new(0, 0, 0, 100),
					TextTransparency = 1,
					TextStrokeTransparency = 1
				}
			):Play()
			task.delay(1, function()
				v2:Destroy()
			end)
		end)
	end

	v2.Parent = localPlayer.PlayerGui
	v2.Enabled = true
	v2.Name = name .. "KJUI"
	v2:AddTag("KJUI")
	local holder = v2:WaitForChild("Holder")
	local template = holder:WaitForChild("Template")
	local name2 = template:WaitForChild("Name")
	name2.Text = name
	local imageLabel = template:FindFirstChild("ImageLabel")
	local v4

	if type(v) == "table" then
		v4 = v.__MoveEditorCustomText == true
	else
		v4 = false
	end

	local textColor = type(v) == "table" and toColor3FromAny(v.NameColor)

	if textColor then
		name2.TextColor3 = textColor
	end

	if imageLabel and imageLabel:IsA("ImageLabel") then
		local defaultImage = imageLabel:GetAttribute("DefaultImage")

		if type(defaultImage) ~= "string" then
			defaultImage = imageLabel.Image
			imageLabel:SetAttribute("DefaultImage", defaultImage)
		end

		local defaultPosXScale = imageLabel:GetAttribute("DefaultPosXScale")
		local defaultPosXOffset = imageLabel:GetAttribute("DefaultPosXOffset")
		local defaultPosYScale = imageLabel:GetAttribute("DefaultPosYScale")
		local defaultPosYOffset = imageLabel:GetAttribute("DefaultPosYOffset")

		if type(defaultPosXScale) ~= "number" or type(defaultPosXOffset) ~= "number" or type(defaultPosYScale) ~= "number" or type(defaultPosYOffset) ~= "number" then
			local position = imageLabel.Position
			defaultPosXScale = position.X.Scale
			defaultPosXOffset = position.X.Offset
			defaultPosYScale = position.Y.Scale
			defaultPosYOffset = position.Y.Offset
			imageLabel:SetAttribute("DefaultPosXScale", defaultPosXScale)
			imageLabel:SetAttribute("DefaultPosXOffset", defaultPosXOffset)
			imageLabel:SetAttribute("DefaultPosYScale", defaultPosYScale)
			imageLabel:SetAttribute("DefaultPosYOffset", defaultPosYOffset)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setImageDefaultPosition()
			imageLabel.Position = UDim2.new(defaultPosXScale, defaultPosXOffset, defaultPosYScale, defaultPosYOffset)
		end

		imageLabel.BackgroundTransparency = 1

		if v4 then
			local iconValue = normalizeIconValue(type(v) ~= "table" and "" or v.Icon or "")

			if iconValue == "" then
				imageLabel.Image = defaultImage
				imageLabel.Visible = false
				imageLabel.ImageTransparency = 1
				setImageDefaultPosition() -- equivalent call inferred; original call site unknown
			else
				imageLabel.Image = iconValue
				imageLabel.Visible = true
				imageLabel.ImageTransparency = 0
				imageLabel.Position = UDim2.new(
					defaultPosXScale,
					defaultPosXOffset,
					defaultPosYScale - 0.1,
					defaultPosYOffset
				)
				warn(iconValue)
				warn(imageLabel)
			end
		else
			imageLabel.Image = defaultImage
			imageLabel.Visible = true
			imageLabel.ImageTransparency = 0
			setImageDefaultPosition() -- equivalent call inferred; original call site unknown
		end
	end

	for _, item in items do
		v3 ..= item.Text
	end

	local v6 = false

	for _, item in pairs(items) do
		if not item.HigherUp then
			continue
		end

		TweenService:Create(v2.Holder, TweenInfo.new(0.2), {
			Position = resolveHigherUpHolderPosition(holder, v4)
		}):Play()
		v6 = true
	end

	if not v6 and v2.Holder.Position ~= uDim then
		TweenService:Create(v2.Holder, TweenInfo.new(1), {
			Position = uDim
		}):Play()
	end

	retireTexts(v2.Holder.Template)

	for _, item in items do
		total += resolveGapBefore(item)
		local v7 = string.split(item.Text, "")
		local sourceSansBold = item.Bold and Enum.Font.SourceSansBold or item.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans

		for _, v8 in v7 do
			total += TextService:GetTextSize(v8, 25, sourceSansBold, Vector2.new(100, 100)).X
		end
	end

	for _, item in items do
		total2 += resolveGapBefore(item)
		local v7 = string.split(item.Text, "")
		local sourceSansBold = item.Bold and Enum.Font.SourceSansBold or item.Italic and Enum.Font.SourceSansItalic or Enum.Font.SourceSans

		for _, text in v7 do
			local textSize = TextService:GetTextSize(text, 25, sourceSansBold, Vector2.new(100, 100))
			local textLabel = Instance.new("TextLabel")
			UDim2.new(0.5, total2 - total / 2 // 1, 0.5, 0)
			textLabel.AnchorPoint = Vector2.new(0, 0.5)
			textLabel.Position = UDim2.new(0.5, total2 - total / 2 // 1, 0.5, 10)
			textLabel.Size = UDim2.new(0, textSize.X, 0, textSize.Y)
			textLabel.Text = text
			textLabel.Name = "letter"
			textLabel.Font = sourceSansBold
			textLabel.TextSize = 25
			textLabel.Parent = v2.Holder.Template
			textLabel.BackgroundTransparency = 1
			textLabel.TextStrokeColor3 = item.TextStrokeColor
			textLabel.TextStrokeTransparency = 0
			textLabel.TextStrokeTransparency = 1
			textLabel.TextTransparency = 1
			local v9 = item
			local v11 = total2
			task.delay(total3, function()
				local lastTime = os.clock()

				repeat
					local v12 = math.min((os.clock() - lastTime) / 0.35, 1)
					local v13 = math.min((os.clock() - lastTime) / v9.Shake.Lifetime, 1)
					local uDim4 = not v9.Shake.Enabled and UDim2.new(0, 0, 0, 0) or UDim2.new(
						0,
						math.random(-v9.Shake.Intensity, v9.Shake.Intensity) * (1 - v13),
						0,
						math.random(-v9.Shake.Intensity, v9.Shake.Intensity) * (1 - v13)
					)
					local textTransparency = 1 - easeOutQuad(v12)
					textLabel.TextStrokeTransparency = (1 - v12) ^ 10
					textLabel.TextTransparency = textTransparency
					textLabel.TextSize = 25 + 25 * textTransparency
					textLabel.TextColor3 = getColor(v12, v9.Color.Keypoints)
					textLabel.Position = UDim2.new(0.5, v11 - total / 2 // 1, 0.5, 0) + uDim4
					task.wait()
				until os.clock() - lastTime > math.max(0.35, v9.Shake.Lifetime) or not textLabel or not textLabel:IsDescendantOf(v2) or textLabel:GetAttribute("Ending")

				if textLabel then
					textLabel.TextStrokeTransparency = 0
					textLabel.TextTransparency = 0
					textLabel.TextSize = 25
					textLabel.TextColor3 = v9.Color.Keypoints[#v9.Color.Keypoints].Value
					textLabel.Position = UDim2.new(0.5, v11 - total / 2 // 1, 0.5, 0)
				end
			end)
			total3 += item.TypeSpeed
			total2 += textSize.X
		end
	end
end

function TekrinnDialogue.Speak(p, p2)
	doText(p2, p)
end

return TekrinnDialogue