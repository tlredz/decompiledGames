local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local AccessoryAdjustmentsConstants = require(ReplicatedStorage.Modules.Shared.Game.AccessoryAdjustmentsConstants)
local AccessoryAdjustmentsState = require(ReplicatedStorage.Modules.Client.AvatarEditor.AccessoryAdjustments.AccessoryAdjustmentsState)
local v = Component.new({
	Tag = "AccessoryAdjustmentsResetColorButton"
})

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

		WearingController.SetAccessoryColor(selectedAssetId, nil)
		local selectedAccessoryInstance = AccessoryAdjustmentsState.GetSelectedAccessoryInstance()

		if selectedAccessoryInstance == nil then
			return
		end

		local handle = selectedAccessoryInstance:FindFirstChild("Handle")

		if handle == nil then
			return
		end

		local child = handle:FindFirstChild(AccessoryAdjustmentsConstants.ACCESSORY_COLOR_SURFACE_APPEARANCE_NAME)

		if child == nil then
			return
		end

		child:Destroy()
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v