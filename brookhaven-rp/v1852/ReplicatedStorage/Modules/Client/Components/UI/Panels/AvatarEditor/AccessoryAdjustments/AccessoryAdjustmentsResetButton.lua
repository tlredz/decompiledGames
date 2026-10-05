local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local AccessoryAdjustmentsConstants = require(ReplicatedStorage.Modules.Shared.Game.AccessoryAdjustmentsConstants)
local v = Component.new({
	Tag = "AccessoryAdjustmentsResetButton"
})
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local instance = self.Instance
	self._Janitor:Add(instance.MouseButton1Click:Connect(function()
		local selectedAssetId = AccessoryAdjustmentsState.GetSelectedAssetId()

		if selectedAssetId == nil then
			return
		end

		if WearingController.SetAccessoryAdjustment(
			selectedAssetId,
			AccessoryAdjustmentsConstants.createDefaultAdjustment()
		) == true then
			AccessoryAdjustmentsState.RequestReset()
		end
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v