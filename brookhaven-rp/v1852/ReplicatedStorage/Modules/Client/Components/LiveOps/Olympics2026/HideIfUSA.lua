local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "HideIfUSA"
})

function v:UpdateVisibility(flag: boolean)
	if self.Instance:IsA("BasePart") or self.Instance:IsA("Texture") or self.Instance:IsA("MeshPart") or self.Instance:IsA("Decal") then
		self.Instance.Transparency = flag and 0 or 1
	elseif self.Instance:IsA("ClickDetector") then
		self.Instance.MaxActivationDistance = flag and 30 or 0
	end
end

function v:RefreshItemVisibility()
	if PlayerLocalizationController.IsPlayerFromUS() then
		self:UpdateVisibility(false)
	else
		self:UpdateVisibility(true)
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