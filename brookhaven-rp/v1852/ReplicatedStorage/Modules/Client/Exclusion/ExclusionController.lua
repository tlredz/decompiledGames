local ExclusionController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
local UGCExcludeConfig = require(ReplicatedStorage.Modules.Shared.DB.Moderation.UGCExcludeConfig)
local v = nil
ExclusionController.OnPlayerExclusionGroupsChanged = Signal.new()
ExclusionController.OnPlayerExclusionGroupsCleared = Signal.new()

function ExclusionController.IsGroupExcluded(p: string)
	local expect = v.GetSessionReplicaPromise():expect()
	return expect.Data.ActiveExclusionGroups and expect.Data.ActiveExclusionGroups[p] or false
end

function ExclusionController.GetExclusionMessage(p: string)
	local config = UGCExcludeConfig.GetConfig()
	local character = Players.LocalPlayer.Character

	if not character then
		return p
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return p
	end

	local appliedDescription = humanoid:GetAppliedDescription()

	if not appliedDescription then
		return p
	end

	for _, v2 in appliedDescription:GetAccessories(true) do
		if not config[tostring(v2.AssetId)] then
			continue
		end

		local name = v2.AccessoryType.Name
		return (`You can't use this while wearing a {string.gsub(name, "%s*(%l)(%u)", "%1 %2")}!`)
	end

	if appliedDescription.Shirt ~= 0 and config[tostring(appliedDescription.Shirt)] then
		return "You can't use this while wearing that shirt!"
	end

	if appliedDescription.Pants == 0 or not config[tostring(appliedDescription.Pants)] then
		return p
	end

	return "You can't use this while wearing those pants!"
end

function ExclusionController.FrameworkInit()
	local ReplicatedDataController = require(ReplicatedStorage.Modules.Client.Data.ReplicatedDataController)
	v = ReplicatedDataController
end

function ExclusionController.FrameworkStart()
	v.GetSessionReplicaPromise():expect():OnSet({ "ActiveExclusionGroups" }, function(items)
		if next(items) then
			ExclusionController.OnPlayerExclusionGroupsChanged:Fire(items)
		else
			ExclusionController.OnPlayerExclusionGroupsCleared:Fire()
		end
	end)
end

return ExclusionController