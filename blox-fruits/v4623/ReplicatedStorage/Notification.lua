local Feed = require(script.Feed)
require(script.Types)
local RunService = game:GetService("RunService")
local playerGui

if RunService:IsClient() then
	playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
else
	playerGui = game.StarterGui
end

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 200
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Name = "Notifications"
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Name = "NotificationStack"
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, workspace:GetAttribute("MAP") == "Dungeons" and 0.1 or 0, 4)
frame.Size = UDim2.new(1, 0, 1 - frame.Position.Y.Scale, -4)
frame.Parent = screenGui
local v = Feed.new(frame, playerGui)
local v2 = {
	DEFAULT_MESSAGE = "<EMPTY MESSAGE>",
	DEFAULT_DURATION = 6,
	X_MARGIN = 12,
	LABEL_TEMPLATE = script:WaitForChild("NotificationTemplate")
}
local uIPadding = Instance.new("UIPadding")
uIPadding.Parent = screenGui
local v3 = nil
local v4 = {}

local function updatePadding()
	local total = 0

	for k in v4 do
		total += k.Value
	end

	if v3 and v3.AbsoluteContentSize.Y > 0 then
		total += v3.AbsoluteContentSize.Y + 5
	end

	uIPadding.PaddingTop = UDim.new(0, total)
	script:SetAttribute("Offset", total)
end

local function trackPadding(numberValue)
	if numberValue:IsA("NumberValue") and not v4[numberValue] then
		v4[numberValue] = { numberValue.Changed:Connect(updatePadding), numberValue.AncestryChanged:Connect(function()
				if numberValue.Parent ~= script then
					for _, connection in v4[numberValue] do
						connection:Disconnect()
					end

					v4[numberValue] = nil
					updatePadding()
				end
			end) }
		updatePadding()
	end
end

script.ChildAdded:Connect(trackPadding)

for _, child in script:GetChildren() do
	trackPadding(child)
end

updatePadding()
task.spawn(function()
	local listLayout = playerGui:WaitForChild("Main"):WaitForChild("TopHUDList"):WaitForChild("ListLayout")

	if listLayout:IsA("UIListLayout") then
		v3 = listLayout
		listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePadding)
		updatePadding()
	end
end)
task.spawn(function()
	while task.wait(0.05) do
		v:Update()
	end
end)
local Notification = {}
Notification.__index = Notification
local LocalizationService = game:GetService("LocalizationService")
local v5 = {
	ColorShortcuts = {}
}
v5.ColorShortcuts.White = Color3.new(1, 1, 1)
v5.ColorShortcuts.Black = Color3.new(0, 0, 0)
v5.ColorShortcuts.Red = Color3.new(1, 0.4, 0.4)
v5.ColorShortcuts.Green = Color3.new(0.4, 1, 0.4)
v5.ColorShortcuts.Purple = Color3.new(1, 0, 1)
v5.ColorShortcuts.Blue = Color3.new(0.55, 0.6, 1)
v5.ColorShortcuts.Cyan = Color3.new(0.4, 0.85, 1)
v5.ColorShortcuts.Orange = Color3.new(1, 0.5, 0.2)
v5.ColorShortcuts.Yellow = Color3.new(1, 0.9, 0.2)
v5.ColorShortcuts.ValorCyan = Color3.fromRGB(85, 255, 255)
local v6 = {
	["<"] = "&lt;",
	[">"] = "&gt;"
}

local function fix(p: number)
	return (math.floor(p * 255 + 0.499))
end

local function pretranslate(value: string)
	local v7 = {}
	local v8 = {}
	return value:gsub("<Color=([^%s>]+)>", function(p)
		v7[p] = (v7[p] or 0) + 1
		return ("{color%s_%s}"):format(tostring(v7[p]), p)
	end):gsub("<AnimateYield=([0-9%.]+)>", function(p)
		v7[p] = (v7[p] or 0) + 1
		return ("{yield%s_%s}"):format(tostring(v7[p]), (tostring((math.floor((tonumber(p) or 0) * 1000)))))
	end):gsub("%b<>", function(value2)
		if value2:match("AnimateStyle") or value2:match("AnimateStepFrequency") or value2:match("AnimateStepTime") then
			return ""
		end

		local v9 = value2:sub(2)
		local v10 = v9:sub(1, #v9 - 1)
		v7.Items = (v7.Items or 0) + 1
		v8[v7.Items] = v10
		return "{item" .. v7.Items .. "}"
	end), v8
end

local function postTranslate(value: string, p)
	return (value:gsub("{color%d+_([^}]+)}", function(value2)
		return "<Color=" .. value2:gsub(" ", "") .. ">"
	end):gsub("{yield%d+_(%d+)}", function(p2)
		return "<AnimateYield=" .. (tonumber(p2) or 0) / 1000 .. ">"
	end):gsub("{item(%d+)}", function(p2)
		return "<" .. p[assert((tonumber(p2)))] .. ">"
	end))
end

local function translateText(clone, p: string)
	local translatorForPlayer = nil
	local _, result = pcall(function()
		translatorForPlayer = LocalizationService:GetTranslatorForPlayer(game.Players.LocalPlayer)
	end)

	if not translatorForPlayer then
		warn("NO TRANSLATOR BRO", result)
		return p
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.TextTransparency = 1
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(0, 0, 0, 0)
	textLabel.Name = "TranslateMe"
	local text, v8 = pretranslate(p)
	textLabel.Text = text
	textLabel.Parent = clone
	local v9 = text
	pcall(function()
		v9 = translatorForPlayer:Translate(textLabel, text)
	end)

	for k, v10 in pairs(v8) do
		local v11 = k
		local v12 = v10
		pcall(function()
			v8[v11] = translatorForPlayer:Translate(workspace, v12)
		end)
	end

	return (postTranslate(v9, v8))
end

function Notification.new(p: string?, p2: number?, flag: boolean?)
	local clone = v2.LABEL_TEMPLATE:Clone()
	clone.AutoLocalize = false
	local v7 = { clone, (clone:FindFirstChild("TextLabel")) }

	for _, v8 in ipairs(v7) do
		v8.AutoLocalize = false
		v8.RichText = true
		v8.Text = ""
	end

	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Size = UDim2.new(1, -2 * v2.X_MARGIN, 0, clone.Size.Y.Offset)
	clone.Text = ""
	clone.Visible = false
	clone.Parent = frame
	local v8 = translateText(clone, p or v2.DEFAULT_MESSAGE):gsub("<Color=/>", "\14/font\15")

	for k, colorShortcut in pairs(v5.ColorShortcuts) do
		v8 = v8:gsub(
			"<Color=" .. k .. ">",
			"\14" .. "font color=" .. "\"" .. "rgb(" .. math.floor(colorShortcut.R * 255 + 0.499) .. "," .. math.floor(colorShortcut.G * 255 + 0.499) .. "," .. math.floor(colorShortcut.B * 255 + 0.499) .. ")\"\15"
		)
	end

	for k, v9 in pairs(v6) do
		v8 = v8:gsub(k, v9)
	end

	local text = v8:gsub("\14", "<"):gsub("\15", ">")

	for _, v10 in ipairs(v7) do
		v10.Text = text
	end

	return (setmetatable({
		Label = clone,
		Duration = p2 or v2.DEFAULT_DURATION,
		Prioritized = flag or false,
		CreationTime = 0,
		Displayed = false
	}, Notification))
end

function Notification.Dead(p)
	return tick() - p.CreationTime > p.Duration
end

function Notification:Display()
	if self.Displayed then
		return false
	end

	self.Displayed = true
	v:Add(self)
	return true
end

return Notification