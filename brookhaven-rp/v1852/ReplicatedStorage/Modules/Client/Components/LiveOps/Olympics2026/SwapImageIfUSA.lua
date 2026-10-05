local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local PlayerLocalizationController = require(ReplicatedStorage.Modules.Client.Player.PlayerLocalizationController)
local v = Component.new({
	Tag = "SwapImageIfUSA"
})

function v:UpdateImage(p2)
	if self.Instance:IsA("Decal") then
		self.Instance.ColorMapContent = p2
	elseif self.Instance:IsA("ImageLabel") or self.Instance:IsA("ImageButton") then
		self.Instance.Image = p2
	end
end

function v:RefreshImage()
	if PlayerLocalizationController.IsPlayerFromUS() then
		self:UpdateImage(self.usImage)
	else
		self:UpdateImage(self.defaultImage)
	end
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	if self.Instance:IsA("Decal") then
		self.defaultImage = self.Instance.ColorMapContent
		self.usImage = Content.fromAssetId(self.Instance:GetAttribute("USImage"))
	elseif self.Instance:IsA("ImageLabel") or self.Instance:IsA("ImageButton") then
		self.defaultImage = self.Instance.Image
		self.usImage = self.Instance:GetAttribute("USImage")
	end

	self._Janitor:Add(PlayerLocalizationController.CountryRegionChanged:Connect(function()
		self:RefreshImage()
	end))
	self:RefreshImage()
end

function v:Stop()
	self._Janitor:Destroy()
end

return v