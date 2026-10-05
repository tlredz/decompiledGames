local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Packages.Signal)
local WearingController = require(ReplicatedStorage.Modules.Client.AvatarEditor.WearingController)
local AccessoryAdjustmentsConstants = require(ReplicatedStorage.Modules.Shared.Game.AccessoryAdjustmentsConstants)
local AccessoryAdjustmentsState = {}
local localPlayer = Players.LocalPlayer
AccessoryAdjustmentsState.SelectionChanged = Signal.new()
AccessoryAdjustmentsState.ResetRequested = Signal.new()
local v = nil
local v2 = nil
local v3 = false
local color = Color3.fromRGB(40, 180, 90)

function AccessoryAdjustmentsState:SetSelectedAsset()
	local id

	if self ~= nil then
		id = tonumber(self.id)
	end

	local v4

	if v ~= nil then
		v4 = tonumber(v.id)
	end

	local v5 = id ~= v4
	v = self

	if self ~= nil then
		self.Instance = nil
		local character = localPlayer.Character

		if character ~= nil then
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if humanoid ~= nil and id ~= nil then
				for _, instance in humanoid:GetAccessories() do
					if tonumber(instance:GetAttribute("AssetId")) ~= id then
						continue
					end

					self.Instance = instance
					break
				end
			end
		end
	end

	if self ~= nil and self.Instance == nil then
		WearingController.SetAccessoryAdjustment(self.id, AccessoryAdjustmentsConstants.createDefaultAdjustment())
	end

	if v5 == true then
		AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
		AccessoryAdjustmentsState.SelectionChanged:Fire(self)
	end
end

function AccessoryAdjustmentsState.GetSelectedAsset()
	return v
end

function AccessoryAdjustmentsState.GetSelectedAssetId()
	if v == nil then
		return nil
	end

	return (tonumber(v.id))
end

function AccessoryAdjustmentsState.RequestReset()
	if AccessoryAdjustmentsState.GetSelectedAssetId() == nil then
		return
	end

	AccessoryAdjustmentsState.ResetRequested:Fire(AccessoryAdjustmentsState.GetSelectedAssetId())
end

function AccessoryAdjustmentsState.SetAccessoryAdjustmentsPanelOpen(flag: boolean)
	v3 = flag
end

function AccessoryAdjustmentsState.IsAccessoryAdjustmentsPanelOpen()
	return v3
end

function AccessoryAdjustmentsState.GetSelectedAccessoryInstance()
	if v == nil then
		return nil
	end

	local instance = v.Instance

	if instance == nil or not instance:IsA("Accessory") or instance.Parent == nil then
		return nil
	end

	return instance
end

function AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
	if v2 ~= nil then
		v2:Destroy()
		v2 = nil
	end
end

function AccessoryAdjustmentsState.BeginLiveAdjustmentHighlight()
	AccessoryAdjustmentsState.EndLiveAdjustmentHighlight()
	local selectedAccessoryInstance = AccessoryAdjustmentsState.GetSelectedAccessoryInstance()

	if selectedAccessoryInstance == nil then
		return
	end

	local parent = selectedAccessoryInstance.Parent

	if parent == nil or parent:IsA("Model") ~= true then
		return
	end

	local handle = selectedAccessoryInstance:FindFirstChild("Handle")

	if handle == nil then
		handle = selectedAccessoryInstance
	elseif not handle:IsA("BasePart") then
		handle = selectedAccessoryInstance
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = "AccessoryAdjustmentHighlight"
	highlight.Adornee = handle
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.55
	highlight.OutlineTransparency = 0.25
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = parent
	v2 = highlight
end

return AccessoryAdjustmentsState