local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Utils = require(ReplicatedStorage.Common.Utils)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client
local ExistCounterController = require(ReplicatedStorage.Controllers.Trading.ExistCounterController)
return Observers.observeTag("ExistCountLabel", function(instance)
	local v = assert(instance:GetAttribute("ItemType"))
	local itemToKey = client:ItemToKey(v, {
		Name = assert(instance:GetAttribute("ItemName"))
	})
	local text = instance.Text

	local function updateText()
		local v3 = ExistCounterController:Get(v, itemToKey)
		instance.Text = string.format(text, not v3 and "???" or Utils.ValueConvertor:AddCommas(v3))
	end

	local maid = Trove.new()
	maid:Add(ExistCounterController:OnUpdated(v, itemToKey, updateText))
	task.spawn(updateText)
	local replion = Replion.Client:GetReplion("Data")

	if replion then
		instance.Visible = not replion:Get({
			"Settings",
			"Misc",
			"Hide Exist Count Label",
			"Enabled"
		})
		maid:Add(replion:OnDescendantChange({ "Settings", "Misc", "Hide Exist Count Label" }, function()
			instance.Visible = not replion:Get({
				"Settings",
				"Misc",
				"Hide Exist Count Label",
				"Enabled"
			})
		end))
	end

	return function()
		maid:Destroy()
		instance.Text = text
	end
end, { workspace })