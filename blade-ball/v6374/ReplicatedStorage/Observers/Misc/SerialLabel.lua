local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local Players = game:GetService("Players")
local _ = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Utils = require(ReplicatedStorage.Common.Utils)
local Inventory = require(ReplicatedStorage.Shared.Inventory)
local client = Inventory.Client
local ExistCounterController = require(ReplicatedStorage.Controllers.Trading.ExistCounterController)
return Observers.observeTag("SerialLabel", function(instance)
	local v = assert(instance:GetAttribute("ItemType"))
	local name = assert(instance:GetAttribute("ItemName"))
	local maid = Trove.new()
	local itemToKey = client:ItemToKey(v, {
		Name = name
	})
	local text = instance.Text
	local fn
	local replion = Replion.Client:GetReplion("Data")

	local function updateText()
		local v3 = ExistCounterController:Get(v, itemToKey)
		local v4 = fn and fn()
		instance.Visible = v4 ~= nil and not (replion and replion:Get({
			"Settings",
			"Misc",
			"Hide Serial Label",
			"Enabled"
		}))

		if v4 then
			instance.Text = string.format(
				text,
				Utils.ValueConvertor:AddCommas(v4),
				not v3 and "???" or Utils.ValueConvertor:AddCommas(v3)
			)
		end
	end

	if v == "Emote" and (instance:IsDescendantOf(workspace.Alive) or instance:IsDescendantOf(workspace.Dead)) then
		local model = instance:FindFirstAncestorWhichIsA("Model")

		if model then
			fn = function()
				return model:GetAttribute("CurrentEmoteSerial") or model:GetAttribute("CurrentEmotePassiveSerial")
			end

			maid:Add(model:GetAttributeChangedSignal("CurrentEmotePassiveSerial"):Connect(updateText))
			maid:Add(model:GetAttributeChangedSignal("CurrentEmoteSerial"):Connect(updateText))
		end
	else
		fn = function()
			return nil
		end
	end

	maid:Add(ExistCounterController:OnUpdated(v, itemToKey, updateText))
	task.spawn(updateText)

	if replion then
		maid:Add(replion:OnDescendantChange({ "Settings", "Misc", "Hide Serial Label" }, updateText))
	end

	return function()
		maid:Destroy()
		instance.Text = text
	end
end, { workspace })