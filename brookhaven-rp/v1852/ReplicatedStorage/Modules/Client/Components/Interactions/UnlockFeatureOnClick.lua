local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local v = Component.new({
	Tag = "UnlockFeatureOnClick"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local feature = self.Instance:GetAttribute("Feature")

	if not feature then
		warn("UnlockFeatureOnClick: Feature attribute not defined")
	elseif self.Instance:IsA("GuiButton") then
		self._Janitor:Add(self.Instance.Activated:Connect(function()
			Remotes.fireServerComponent(self.Instance, "UnlockFeature")
		end))

		if UnlockableController.IsFeatureUnlocked(feature) then
			self:OnUnlock()
		end

		self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
			if p == feature then
				self:OnUnlock()
			end
		end))
	end
end

function v:OnUnlock()
	local visualTextLabel = self.Instance:FindFirstChild("VisualTextLabel")

	if visualTextLabel then
		visualTextLabel.Value.Text = "Unlocked"
	end

	if self.Instance:GetAttribute("UnlockedColor3") then
		self.Instance.BackgroundColor3 = self.Instance:GetAttribute("UnlockedColor3")
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v