local Title = {}
local HttpService = game:GetService("HttpService")
game:GetService("RunService")
local Titles = require(game.ReplicatedStorage.Assets.Data.Store.Titles)
local __ = require(game.ReplicatedStorage.Assets.Data.Store.Titles.__)
local UserTypes = require(game.ReplicatedStorage.Assets.Data.UserTypes)
local Animator = require(script.Animator)
local v = {
	Verified = utf8.char(57344),
	Premium = utf8.char(57345)
}

local function convertTitleInfo_JSONDecodedToRoblox(state)
	local color = state.Color
	state.Color = Color3.fromRGB(color[1], color[2], color[3])
	local strokeColor = state.StrokeColor
	state.StrokeColor = Color3.fromRGB(strokeColor[1], strokeColor[2], strokeColor[3])
	local font = state.Font
	state.Font = Enum.Font[font]
	local gradient = state.Gradient

	if not gradient then
		return state
	end

	local colorSequenceKeypoints = {}

	for _, v2 in gradient do
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(v2[1], Color3.fromRGB(v2[2], v2[3], v2[4])))
	end

	state.Gradient = ColorSequence.new(colorSequenceKeypoints)
	return state
end

local function convertTitleInfo_JSONEncodedToRoblox(json)
	local success, result = pcall(function()
		return HttpService:JSONDecode(json)
	end)

	if success then
		return (convertTitleInfo_JSONDecodedToRoblox(result))
	end

	warn("JSON Encoding failed:", result)
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function color3ToJSON(color: Color3)
	return { color.R * 255, color.G * 255, color.B * 255 }
end

local function convertTitleInfo_RobloxToJSON(state)
	if state.Color then
		state.Color = color3ToJSON(state.Color)
	end

	if state.StrokeColor then
		state.StrokeColor = color3ToJSON(state.StrokeColor)
	end

	if state.Font then
		state.Font = state.Font.Name
	end

	if state.Gradient then
		local gradient = {}

		for _, keypoint in state.Gradient.Keypoints do
			table.insert(gradient, {
				keypoint.Time,
				keypoint.Value.R * 255,
				keypoint.Value.G * 255,
				keypoint.Value.B * 255
			})
		end

		state.Gradient = gradient
	end

	local success, result = pcall(function()
		return HttpService:JSONEncode(state)
	end)

	if success then
		return result
	end

	warn("Custom Title Failed:", result)
	return false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildBadgeList(list)
	if #list == 0 then
		return ""
	end

	return table.concat(list, "") .. " "
end

function Title.GetDisplayNameGiven(_, p: string, flag: boolean, flag2: boolean, p2: string?, options)
	local v2 = {}
	local v3 = options or {}

	if p2 and UserTypes[p2] and not v3.HideUserTypeBadge then
		if v3.UserTypeSize then
			table.insert(v2, (`<font size="{v3.UserTypeSize}">{UserTypes[p2]}</font>`))
		else
			table.insert(v2, UserTypes[p2])
		end
	elseif flag2 then
		table.insert(v2, v.Verified)
	elseif flag then
		table.insert(v2, v.Premium)
	end

	return (`{buildBadgeList(v2)}{p}`)
end

function Title.Construct(_, p, p2, value)
	local title = Titles[value]

	if title == nil and value ~= nil and typeof(value) ~= "boolean" then
		for _, v2 in pairs(__) do
			if v2.Display:lower() == value:lower() then
				title = v2
			end
		end

		if title == nil then
			local gotTitles = game.ReplicatedStorage.Assets.Data.Store.Titles.__:GetAttribute("GotTitles")

			if gotTitles then
				local v2 = nil
				pcall(function()
					local HttpService2 = game:GetService("HttpService")
					v2 = HttpService2:JSONDecode(gotTitles)
				end)

				if v2 then
					for _, v3 in pairs(v2) do
						if v3.Display:lower() == value:lower() then
							title = convertTitleInfo_JSONDecodedToRoblox(v3)
						end
					end
				end
			end
		end
	end

	Title:ConstructWithInfo(p, p2, title)
end

function Title:ConstructWithInfo(player, billboardGui, data)
	local v2 = player:GetAttribute("UseMasculineTitles") and true or false
	local display

	if data then
		display = data.Display or nil
	end

	local titleDisplay = billboardGui:FindFirstChild("TitleDisplay") or billboardGui:FindFirstChildOfClass("CanvasGroup")
	local label = titleDisplay:FindFirstChild("Label", true)
	local title = titleDisplay:FindFirstChild("Title", true)
	local character = player.Character or player.CharacterAdded:Wait()
	local v3

	if character:HasTag("Clone") then
		v3 = character:WaitForChild("FakeHumanoid", 1e999)
	else
		v3 = character:WaitForChild("Humanoid", 1e999)
	end

	label.Text = v3.DisplayName

	if billboardGui:GetAttribute("InternalActiveTitle") == display and billboardGui:GetAttribute("IsMasculine") == v2 then
		return
	end

	if billboardGui:IsA("BillboardGui") then
		billboardGui.Brightness = 1
	end

	billboardGui:SetAttribute("IsMasculine", v2)
	billboardGui:SetAttribute("InternalActiveTitle", display)
	Animator:RemoveTitleAnimation(titleDisplay)
	title.Text = ""

	if not data then
		title.Text = ""
		return
	end

	local display2 = data.Display
	local strokeColor = data.StrokeColor
	local color = data.Color

	if not v2 and data.Other then
		display2 = data.Other
		strokeColor = data.OtherStrokeColor or data.StrokeColor
		color = data.OtherColor or data.Color
	end

	if data.Bold == true then
		if data.DontWrapInBrackets then
			title.Text = "<b>" .. display2 .. "</b>"
		else
			title.Text = "<b>[" .. display2 .. "]</b>"
		end
	elseif data.DontWrapInBrackets then
		title.Text = display2
	else
		title.Text = "[" .. display2 .. "]"
	end

	local italic = data.Italic and Enum.FontStyle.Italic or Enum.FontStyle.Normal

	if data.Size then
		title.Size = UDim2.new(1, 0, 0.5, data.Size)
		title.Position = UDim2.new(0.5, 0, 0.5, -data.Size)
	else
		title.Size = UDim2.new(1, 0, 0.5, 0)
		title.Position = UDim2.new(0.5, 0, 0.5, 0)
	end

	local font = pcall(Font.new, data.Font) and Font.new(data.Font) or Font.fromEnum(data.Font or Enum.Font.Kalam)
	local animationStroke = title:FindFirstChild("AnimationStroke")
	font.Style = italic
	title.FontFace = font
	title.TextStrokeColor3 = strokeColor or Color3.new(0, 0, 0)
	title.TextStrokeTransparency = data.StrokeTransparency or 0.25
	title.TextColor3 = color or Color3.new(1, 1, 1)

	for _, uIGradient in title:GetChildren() do
		if uIGradient:IsA("UIGradient") then
			uIGradient:Destroy()
		end
	end

	if animationStroke then
		animationStroke:Destroy()
	end

	if data.Gradient then
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Name = "TitleGradient"
		uIGradient.Color = data.Gradient
		uIGradient.Rotation = data.GradientRotation or 0
		uIGradient.Parent = title
		title.TextColor3 = Color3.new(1, 1, 1)
	end

	if data.Animation then
		Animator:SetTitleAnimation(titleDisplay, data.Animation)
	end
end

Title.ConvertTitleInfo_JSONEncodedToRoblox = convertTitleInfo_JSONEncodedToRoblox
Title.ConvertTitleInfo_RobloxToJSON = convertTitleInfo_RobloxToJSON
return Title