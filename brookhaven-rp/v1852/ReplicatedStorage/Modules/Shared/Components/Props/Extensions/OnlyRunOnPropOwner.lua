local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PropRoot = require(ReplicatedStorage.Modules.Client.Components.Props.PropRoot)
local ComponentUtil = require(ReplicatedStorage.Modules.Shared.Utils.ComponentUtil)
local Players = game:GetService("Players")
return {
	ShouldConstruct = function(p)
		local waitForAncestorComponent = ComponentUtil.FindAndWaitForAncestorComponent(p.Instance, "PropRoot", PropRoot)

		if not waitForAncestorComponent then
			error("OnlyRunOnPropOwner: No PropRoot found")
		end

		return waitForAncestorComponent:IsOwnedByPlayer(Players.LocalPlayer)
	end
}