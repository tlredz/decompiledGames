local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "HideIfNotUSA"
})

function v:UpdateVisibility(visible: boolean)
	if self.Instance:IsA("BasePart") or self.Instance:IsA("Texture") or self.Instance:IsA("MeshPart") or self.Instance:IsA("Decal") then
		self.Instance.Transparency = visible and 0 or 1
	elseif self.Instance:IsA("ClickDetector") then
		self.Instance.MaxActivationDistance = visible and 30 or 0
	elseif self.Instance:IsA("TextLabel") then
		self.Instance.Visible = visible
	end
end

function v:RefreshItemVisibility()
	if PlayerLocalizationController.IsPlayerFromUS() then
		self:UpdateVisibility(true)
	else
		self:UpdateVisibility(false)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if (self.Instance:IsA("BasePart") or self.Instance:IsA("Texture") or self.Instance:IsA("MeshPart") or self.Instance:IsA("Decal")) and self.Instance.Transparency == 1 then
		return
	end

	self._Janitor:Add(PlayerLocalizationController.CountryRegionChanged:Connect(function()
		self:RefreshItemVisibility()
	end))
	self:RefreshItemVisibility()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v