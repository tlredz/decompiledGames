local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local CorruptedAnnouncement = require(script.Parent.CorruptedAnnouncement)
local CorruptedPlate = require(script.Parent.CorruptedPlate)
local Lanes = require(script.Parent.Lanes)
local RareSpawnText = require(script.Parent.RareSpawnText)
local msgNotif = ReplicatedStorage.Assets.UI.Notifs.MsgNotif
local v = {
	Feed = true,
	Banner = true
}
local playbackSpeed = { 0.85, 1.15 }
local playbackSpeed2 = { 0.92, 1.08 }
local tweenInfo = TweenInfo.new(2.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function expectKind(p, p2: string, p3: string)
	if p ~= nil and typeof(p) ~= p2 then
		error(`toast field {p3} expects a {p2}, got {typeof(p)}`, 3)
	end
end

local function validate(data)
	if typeof(data) ~= "table" then
		error(`Toast.Show expects a request table, got {typeof(data)}`, 3)
	end

	if typeof(data.Text) ~= "string" then
		error("a toast needs a string Text", 3)
	end

	if typeof(data.Seconds) ~= "number" then
		error("a toast needs a numeric Seconds", 3)
	end

	local lane = data.Lane

	if lane ~= nil and (typeof(lane) ~= "string" or v[lane] ~= true) then
		error(`toast field Lane expects "Feed" or "Banner", got {tostring(lane)}`, 3)
	end

	local color = data.Color

	if color ~= nil and typeof(color) ~= "Color3" then
		error(`toast field Color expects a Color3, got {typeof(color)}`, 3)
	end

	local strokeColor = data.StrokeColor

	if strokeColor ~= nil and typeof(strokeColor) ~= "Color3" then
		error(`toast field StrokeColor expects a Color3, got {typeof(strokeColor)}`, 3)
	end

	local image = data.Image

	if image ~= nil and typeof(image) ~= "string" then
		error(`toast field Image expects a string, got {typeof(image)}`, 3)
	end

	local wrapText = data.WrapText

	if wrapText ~= nil and typeof(wrapText) ~= "boolean" then
		error(`toast field WrapText expects a boolean, got {typeof(wrapText)}`, 3)
	end

	local singleLine = data.SingleLine

	if singleLine ~= nil and typeof(singleLine) ~= "boolean" then
		error(`toast field SingleLine expects a boolean, got {typeof(singleLine)}`, 3)
	end

	local delayInRound = data.DelayInRound

	if delayInRound ~= nil and typeof(delayInRound) ~= "boolean" then
		error(`toast field DelayInRound expects a boolean, got {typeof(delayInRound)}`, 3)
	end

	local unique = data.Unique

	if unique ~= nil and typeof(unique) ~= "boolean" then
		error(`toast field Unique expects a boolean, got {typeof(unique)}`, 3)
	end

	local uniqueKey = data.UniqueKey

	if uniqueKey ~= nil and typeof(uniqueKey) ~= "string" then
		error(`toast field UniqueKey expects a string, got {typeof(uniqueKey)}`, 3)
	end

	local corrupted = data.Corrupted

	if corrupted ~= nil and typeof(corrupted) ~= "boolean" then
		error(`toast field Corrupted expects a boolean, got {typeof(corrupted)}`, 3)
	end

	local sound = data.Sound

	if sound ~= nil and typeof(sound) ~= "string" and typeof(sound) ~= "number" then
		error(`toast field Sound expects an asset id, got {typeof(sound)}`, 3)
	end

	local gradient = data.Gradient

	if gradient ~= nil and (typeof(gradient) ~= "Instance" or not gradient:IsA("UIGradient")) then
		error("toast field Gradient expects a UIGradient", 3)
	end

	local preText = data.PreText

	if preText ~= nil then
		if preText ~= nil and typeof(preText) ~= "table" then
			error(`toast field PreText expects a table, got {typeof(preText)}`, 3)
		end

		local text = preText.Text

		if text ~= nil and typeof(text) ~= "string" then
			error(`toast field PreText.Text expects a string, got {typeof(text)}`, 3)
		end

		local color2 = preText.Color

		if color2 ~= nil and typeof(color2) ~= "Color3" then
			error(`toast field PreText.Color expects a Color3, got {typeof(color2)}`, 3)
		end

		local strokeColor2 = preText.StrokeColor

		if strokeColor2 ~= nil and typeof(strokeColor2) ~= "Color3" then
			error(`toast field PreText.StrokeColor expects a Color3, got {typeof(strokeColor2)}`, 3)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function outlined(p: string, color: Color3)
	return (`<stroke color="#{color:ToHex()}" thickness="{2}" joins="round">{p}</stroke>`)
end

local function tinted(p: string, color: Color3)
	return (`<font color="#{color:ToHex()}">{p}</font>`)
end

local function compose(p: string, color: Color3?, color2: Color3?)
	local v5 = outlined(p, color2 or Color3.new()) -- equivalent call inferred; original call site unknown

	if color == nil then
		return v5
	end

	return (`<font color="#{color:ToHex()}">{v5}</font>`)
end

local function isAlertTint(color: Color3)
	return color.R >= 0.999 and color.G <= 0.001 and color.B <= 0.001
end

local function playCue(p, color: Color3?)
	local sound = p.Sound

	if sound ~= nil then
		Audio.Play(sound, script, {
			PlaybackSpeed = playbackSpeed2
		})
		return
	end

	if color ~= nil then
		local v5

		if color.R >= 0.999 and color.G <= 0.001 then
			v5 = color.B <= 0.001
		else
			v5 = false
		end

		if v5 then
			Audio.Play(17208372272, script)
			return
		end
	end

	Audio.Play("rbxassetid://133842042346471", script, {
		PlaybackSpeed = playbackSpeed,
		Volume = 0.55
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleFactor(instance)
	local uIScale = instance:FindFirstChildOfClass("UIScale")

	if uIScale == nil or not (uIScale.Scale > 0) then
		return 1
	end

	return uIScale.Scale
end

local function plateRoom(instance, instance2, list)
	local v5 = scaleFactor(instance) -- equivalent call inferred; original call site unknown
	local uIListLayout = instance2:FindFirstChildOfClass("UIListLayout")
	local v6 = uIListLayout == nil and 0 or uIListLayout.Padding.Offset
	local v7 = instance2.AbsoluteSize.X / v5

	for _, guiObject in instance2:GetChildren() do
		if not (guiObject:IsA("GuiObject") and guiObject.Visible and table.find(list, guiObject) == nil) then
			continue
		end

		v7 -= guiObject.AbsoluteSize.X / v5 + v6
	end

	return v7, instance2.AbsoluteSize.Y / v5
end

local function lineWidth(item, size: number)
	local getTextBoundsParams = Instance.new("GetTextBoundsParams")
	getTextBoundsParams.Font = item.FontFace
	getTextBoundsParams.Size = size
	getTextBoundsParams.Text = item.ContentText
	getTextBoundsParams.Width = 0
	local success, textBoundsAsync = pcall(TextService.GetTextBoundsAsync, TextService, getTextBoundsParams)

	if success and typeof(textBoundsAsync) == "Vector2" and textBoundsAsync.X > 0 then
		return textBoundsAsync.X
	end

	return nil
end

local function fitOneLine(items, p: number, size: number)
	if p <= 0 or size <= 0 then
		return false
	end

	local total = 0

	for _, item in items do
		if not item.Visible then
			continue
		end

		local v5 = lineWidth(item, size)

		if v5 == nil then
			for _, item2 in items do
				item2.TextWrapped = true
				item2.TextScaled = true
			end

			return true
		else
			total += v5
		end
	end

	local v5

	if total > 0 then
		v5 = size * (p * 0.96) / total
	else
		v5 = size
	end

	local textSize = math.max(math.floor((math.min(size, v5))), 12)

	for _, item in items do
		item.TextSize = textSize
	end

	return true
end

local function iconSlot(parent)
	local iconSlot2 = parent:FindFirstChild("IconSlot")

	if iconSlot2 ~= nil and iconSlot2:IsA("Frame") then
		return iconSlot2
	end

	local frame = Instance.new("Frame")
	frame.Name = "IconSlot"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint.Parent = frame
	frame.Parent = parent
	return frame
end

local function seatIcon(plate, icon, iconLines: number?, iconScale: number?)
	local v5 = iconScale or 1

	if iconLines == nil or iconLines < 2 then
		if v5 ~= 1 then
			icon.Size = UDim2.fromScale(icon.Size.X.Scale * v5, icon.Size.Y.Scale * v5)
		end
	else
		local uIAspectRatioConstraint = icon:FindFirstChildOfClass("UIAspectRatioConstraint")
		local v6 = uIAspectRatioConstraint == nil and 1 or uIAspectRatioConstraint.AspectRatio
		local v7 = 1.125 * v5 / iconLines
		local parent = iconSlot(plate)
		local uIAspectRatioConstraint2 = parent:FindFirstChildOfClass("UIAspectRatioConstraint")

		if uIAspectRatioConstraint2 ~= nil then
			uIAspectRatioConstraint2.AspectRatio = v6 * v7
		end

		parent.LayoutOrder = icon.LayoutOrder
		parent.Size = UDim2.fromScale(1, 1)
		parent.ZIndex = icon.ZIndex
		icon.Parent = parent
		icon.AnchorPoint = Vector2.new(0.5, 1)
		icon.Position = UDim2.fromScale(0.5, 1)
		icon.Size = UDim2.fromScale(1, v7)
	end
end

local function prefixLabel(parent, instance)
	local preText = parent:FindFirstChild("PreText")

	if preText ~= nil and preText:IsA("TextLabel") then
		return preText
	end

	local clone = instance:Clone()
	clone.Name = "PreText"
	clone.Parent = parent
	return clone
end

local function applyFont(body, font)
	if typeof(font) == "Font" then
		body.FontFace = font
	elseif typeof(font) == "table" and typeof(font.Family) == "string" then
		local success, result = pcall(Font.new, font.Family, font.Weight or Enum.FontWeight.Regular)

		if success then
			body.FontFace = result
		end
	end
end

local function speaksAsSammy(p)
	local preText = p.PreText
	local text

	if preText ~= nil then
		text = preText.Text
	end

	return text ~= nil and string.sub(text, 1, 21) == "Mind Controlled Sammy"
end

local function settleText(data, clone, plate, body, preText)
	if data.SingleLine then
		local v5 = { body, preText }

		-- equivalent calls inferred from this helper; original call sites unknown
		local function attempt()
			local v6, size = plateRoom(clone, plate, v5)
			return (fitOneLine(v5, v6, size))
		end

		if not attempt() then
			task.delay(0, function()
				if clone.Parent ~= nil then
					local v6, size = plateRoom(clone, plate, v5)
					fitOneLine(v5, v6, size)
				end
			end)
		end
	elseif data.WrapText then
		task.delay(0, function()
			if clone.Parent == nil then
				return
			end

			local v5 = plateRoom(clone, plate, { body })
			local uISizeConstraint = Instance.new("UISizeConstraint")
			uISizeConstraint.MaxSize = Vector2.new(math.max(v5, 128), 1e999)
			uISizeConstraint.Parent = body
		end)
	end
end

local function buildSammy(data)
	local banner, v6, finish = CorruptedAnnouncement.Create(data.Text, "Mind Controlled Sammy:")
	return {
		banner = banner,
		begin = function()
			playCue(data, data.Color)
			v6()
		end,
		finish = finish
	}
end

local function buildPlate(data)
	local clone = msgNotif:Clone()
	local backdrop = clone:FindFirstChild("Backdrop")
	local plate = clone:FindFirstChild("Plate")
	local body = plate:FindFirstChild("Body")
	local preText = plate:FindFirstChild("PreText")

	if preText == nil or not preText:IsA("TextLabel") then
		preText = body:Clone()
		preText.Name = "PreText"
		preText.Parent = plate
	end

	local color = data.Color or Color3.new(1, 1, 1)
	local parsed = RareSpawnText.Parse(data.Text)
	local v5 = nil
	local v6 = nil

	if parsed then
		body.AutoLocalize = false
	end

	local text = outlined(data.Text, data.StrokeColor or Color3.new()) -- equivalent call inferred; original call site unknown

	if color ~= nil then
		text = `<font color="#{color:ToHex()}">{text}</font>`
	end

	body.Text = text
	body.TextColor3 = color
	local uIStroke = body:FindFirstChild("UIStroke")

	if uIStroke ~= nil and uIStroke:IsA("UIStroke") and data.StrokeColor ~= nil then
		uIStroke.Color = data.StrokeColor
	end

	preText.LayoutOrder = math.max(body.LayoutOrder - 1, 0)
	preText.TextColor3 = color
	preText.ZIndex = body.ZIndex
	local preText2 = data.PreText
	local v8 = (preText2 == nil or preText2.Text == nil) and "" or preText2.Text
	local text2

	if preText2 == nil or v8 == "" then
		text2 = ""
	else
		local color2 = preText2.Color
		text2 = `<stroke color="#{(preText2.StrokeColor or Color3.new()):ToHex()}" thickness="{2}" joins="round">{v8}</stroke>`

		if color2 ~= nil then
			text2 = `<font color="#{color2:ToHex()}">{text2}</font>`
		end
	end

	preText.Text = text2
	preText.Visible = v8 ~= ""

	if data.Size ~= nil then
		clone.Size = data.Size
	end

	if data.Corrupted == true then
		clone.Size = UDim2.fromScale(clone.Size.X.Scale, clone.Size.Y.Scale * 1.22)
		plate.Size = UDim2.fromScale(plate.Size.X.Scale, plate.Size.Y.Scale / 1.22)
	end

	if data.Gradient ~= nil then
		local clone_2 = data.Gradient:Clone()
		clone_2.Parent = body
	end

	if data.Font ~= nil then
		applyFont(body, data.Font)
	end

	backdrop.Visible = data.ShowShadow == true

	if data.SingleLine then
		for _, v10 in { body, preText } do
			v10.TextScaled = false
			v10.TextWrapped = false
		end
	end

	if data.Image ~= nil then
		local icon = plate:FindFirstChild("Icon")

		if icon ~= nil and icon:IsA("ImageLabel") then
			icon.Image = data.Image
			icon.Visible = true
			seatIcon(plate, icon, data.IconLines, data.IconScale)
		end
	end

	return {
		banner = clone,
		begin = function()
			playCue(data, color)
			settleText(data, clone, plate, body, preText)

			if data.Corrupted == true then
				v6 = CorruptedPlate.Attach(clone, plate)
			end

			if parsed then
				v5 = RareSpawnText.Localize(parsed, body, function(p: string)
					if clone.Parent == nil then
						return
					end

					local v10 = body
					local v11 = color
					local text3 = outlined(p, data.StrokeColor or Color3.new()) -- equivalent call inferred; original call site unknown

					if v11 ~= nil then
						text3 = `<font color="#{v11:ToHex()}">{text3}</font>`
					end

					v10.Text = text3
					settleText(data, clone, plate, body, preText)
				end)
			end

			task.delay(0.8, function()
				if clone.Parent ~= nil then
					TweenService:Create(backdrop, tweenInfo, {
						ImageTransparency = 1
					}):Play()
				end
			end)
		end,
		finish = function()
			if v5 then
				v5()
			end

			if v6 then
				v6()
			end
		end
	}
end

return table.freeze({
	Show = function(data)
		validate(data)
		local preText = data.PreText
		local text

		if preText ~= nil then
			text = preText.Text
		end

		local v5

		if text == nil then
			v5 = false
		else
			v5 = string.sub(text, 1, 21) == "Mind Controlled Sammy"
		end

		local v6

		if v5 then
			v6 = buildSammy(data)
		else
			v6 = buildPlate(data)
		end

		local uniqueKey

		if data.Unique == true then
			uniqueKey = data.Text
		else
			uniqueKey = data.UniqueKey
		end

		Lanes.Schedule({
			Lane = data.Lane or "Feed",
			Frame = v6.banner,
			Seconds = data.Seconds,
			UniqueKey = uniqueKey,
			DelayInRound = data.DelayInRound,
			OnShown = v6.begin,
			OnRetired = v6.finish
		})
	end
})