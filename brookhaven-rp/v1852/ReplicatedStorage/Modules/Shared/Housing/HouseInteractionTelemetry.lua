local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local LotRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.LotRoot)
local PropertyRoot = require(ReplicatedStorage.Modules.Shared.Components.Housing.PropertyRoot)
return {
	BuildPayload = function(p, data)
		local component = ComponentUtil.FindComponentByAncestor(p, "PropertyRoot", PropertyRoot)

		if component == nil then
			return nil
		end

		local component2 = ComponentUtil.FindComponentByAncestor(p, "LotRoot", LotRoot)

		if component2 == nil then
			return nil
		end

		local v = {
			houseId = component:GetDisplayName(),
			lot = component2:GetId(),
			interactionObject = data.interactionObject,
			primaryAction = data.primaryAction
		}

		if data.actionItem ~= nil then
			v.actionItem = data.actionItem
		end

		return v
	end
}