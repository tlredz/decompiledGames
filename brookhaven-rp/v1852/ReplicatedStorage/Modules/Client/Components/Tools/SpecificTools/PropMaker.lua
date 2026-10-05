local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local AdIntegrationsController = require(ReplicatedStorage.Modules.Client.Ads.AdIntegrationsController)
local TagsUtil = require(ReplicatedStorage.Modules.Shared.Utils.TagsUtil)
local v = Component.new({
	Tag = "PropMaker"
})
local localPlayer = Players.LocalPlayer
local v2 = {
	MilitaryTurret = true,
	Spotlight = true,
	RotatingLight = true,
	WeightBench = true
}
local v3 = {
	Color = true,
	ModelMove2 = true,
	BodyPanels = true
}
local v4 = {
	"VehicleRoot",
	"Trailer",
	"ChinookHelicopter",
	"HotAirBalloon"
}

local function asModel(model)
	if model:IsA("Model") then
		return model
	end

	return model:FindFirstAncestorOfClass("Model")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSelectedPropName()
	local playersBag = localPlayer:FindFirstChild("PlayersBag")

	if playersBag == nil then
		return nil
	end

	local propName = playersBag:FindFirstChild("PropName")

	if propName == nil or not propName:IsA("StringValue") or propName.Value == "" then
		return nil
	end

	return propName.Value
end

local function getWeldTargetVehicle(part)
	if part == nil or not part:IsA("BasePart") or (part.Anchored or part:FindFirstChild("NoProp") ~= nil) then
		return nil
	end

	if TagsUtil.FindAncestorByTag(part, "PropRoot") ~= nil or TagsUtil.FindAncestorByTag(part, "PropEditable") ~= nil then
		return nil
	end

	local selectedPropName = getSelectedPropName() -- equivalent call inferred; original call site unknown

	if selectedPropName == nil or v2[selectedPropName] == true then
		return nil
	end

	for _, v5 in v4 do
		local ancestor = TagsUtil.FindAncestorByTag(part, v5)

		if ancestor ~= nil then
			return asModel(ancestor)
		end
	end

	local parent = part.Parent

	if parent == nil or v3[parent.Name] ~= true then
		return nil
	end

	local v5 = localPlayer.Name .. "Car"

	while parent ~= nil do
		if parent.Name == v5 and parent:IsA("Model") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = self._Janitor:Add(Janitor.new())
	self._highlightedVehicle = nil
	self._isEquipped = false
end

function v:_isLocalTool()
	local parent = self.Instance.Parent

	if parent == nil then
		return false
	end

	if parent:IsA("Backpack") then
		return parent.Parent == localPlayer
	end

	return Players:GetPlayerFromCharacter(parent) == localPlayer
end

function v:_clearVehicleHighlight()
	self._equipJanitor:Remove("VehicleHighlight")
	self._highlightedVehicle = nil
end

function v:_setVehicleHighlight(p)
	if p == self._highlightedVehicle then
		return
	end

	self:_clearVehicleHighlight()

	if p == nil then
		return
	end

	self._highlightedVehicle = p
	local highlight = Instance.new("Highlight")
	highlight.Name = "PropMakerVehicleWeldHighlight"
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.8
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Adornee = p
	highlight.Parent = p
	self._equipJanitor:Add(highlight, "Destroy", "VehicleHighlight")
end

function v:_onEquipped()
	if not self:_isLocalTool() or self._isEquipped then
		return
	end

	self._isEquipped = true
	AdIntegrationsController.NotifyPropMakerEquipped()
	local mouse = localPlayer:GetMouse()
	self._equipJanitor:Add(RunService.Heartbeat:Connect(function()
		self:_setVehicleHighlight(getWeldTargetVehicle(mouse.Target))
	end))
end

function v:_onUnequipped()
	if not self._isEquipped then
		return
	end

	self._isEquipped = false
	self._equipJanitor:Cleanup()
	self._highlightedVehicle = nil
	AdIntegrationsController.NotifyPropMakerUnequipped()
end

function v:Start()
	self._Janitor:Add(self.Instance.Equipped:Connect(function()
		self:_onEquipped()
	end))
	self._Janitor:Add(self.Instance.Unequipped:Connect(function()
		self:_onUnequipped()
	end))

	if self.Instance.Parent == localPlayer.Character then
		self:_onEquipped()
	end
end

function v:Stop()
	self._Janitor:Destroy()

	if self:_isLocalTool() then
		AdIntegrationsController.NotifyPropMakerUnequipped()
	end
end

return v