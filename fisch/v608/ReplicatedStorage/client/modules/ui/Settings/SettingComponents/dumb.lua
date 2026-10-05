local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("GuiService")
local Trove = require(ReplicatedStorage.packages.Trove)
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.client.legacyControllers.SettingsController)
require(ReplicatedStorage.shared.playerSettings.Types)
require("../Types")
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local groupRewards = legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("groupRewards")
local _ = ReplicatedStorage.resources.sounds.sfx.ui
local Dumb = {}
Dumb.__index = Dumb

function Dumb.GetLocalizedName(p)
	return (p.GuiObject:FindFirstChild("title") or p.GuiObject:FindFirstChild("Label")).LocalizedText
end

function Dumb.new(config, p)
	if config.Id == "groupReward" and groupRewards.Value then
		return nil, nil
	end

	local object = setmetatable({}, Dumb)
	object.Trove = Trove.new()
	object.Config = config
	object.Value = p
	local guiObject = object.Trove:Add(script:WaitForChild(config.Id):Clone())
	guiObject.LayoutOrder = config.Order
	guiObject.Name = config.Id
	object.GuiObject = guiObject
	return object, guiObject
end

function Dumb:Destroy()
	self.Trove:Destroy()
	table.clear(self)
end

return Dumb