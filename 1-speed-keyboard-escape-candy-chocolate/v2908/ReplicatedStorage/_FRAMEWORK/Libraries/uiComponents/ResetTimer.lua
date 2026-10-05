local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local VideUtil = require(script.Parent.Parent.Basics.VideUtil)
local create = Vide.create
local defaulted = VideUtil.defaulted
local read = VideUtil.read
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)

-- equivalent calls inferred from this helper; original call sites unknown
local function secondsToReset()
	return 86400 - os.time() % 86400
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatDuration(p: number)
	local v = p // 3600
	local v2 = p % 3600 // 60
	local v3 = p % 60
	return string.format("%02d:%02d:%02d", v, v2, v3)
end

local function ResetTimer(data)
	local source = Vide.source(secondsToReset())
	local thread = task.spawn(function()
		while true do
			task.wait(1)
			source(secondsToReset())
		end
	end)
	Vide.cleanup(thread)
	return create("TextLabel")({
		Name = data.Name or "ResetTimer",
		Size = data.Size or UDim2.fromScale(1, 0.1),
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		LayoutOrder = data.LayoutOrder or 0,
		Visible = defaulted(data.Visible, true),
		BackgroundTransparency = 1,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		Text = function()
			return read(defaulted(data.Prefix, "New quests in")) .. " " .. formatDuration(source())
		end,
		TextColor3 = defaulted(data.TextColor, Color3.fromRGB(255, 255, 255)),
		TextScaled = true,
		TextXAlignment = data.TextXAlignment or Enum.TextXAlignment.Center,
		create("UIStroke")({
			Color = defaulted(data.StrokeColor, Color3.fromRGB(74, 46, 0)),
			Thickness = 0.05,
			StrokeSizingMode = 1
		})
	})
end

return ResetTimer