local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local InteractionPrompt = require(ReplicatedStorage.Modules.Client.Components.Interactions.InteractionPrompt)
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local v = Component.new({
	Tag = "UnlockFeatureOnInteract"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self:GetComponent(InteractionPrompt).Interacted:Connect(function()
		if Remotes.invokeServerComponent(self.Instance, "UnlockFeature") then
			self.Instance:SetAttribute("InteractionDisabled", true)
			local purchaseSFX = Players.LocalPlayer.PlayerGui:FindFirstChild("PurchaseSFX")

			if purchaseSFX then
				purchaseSFX:Play()
			else
				warn("UnlockFeatureOnInteract: PurchaseSFX not found")
			end
		end
	end)
	self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p)
		if p == self.Instance:GetAttribute("Feature") then
			self.Instance:SetAttribute("InteractionDisabled", true)
		end
	end))

	if UnlockableController.IsFeatureUnlocked(self.Instance:GetAttribute("Feature")) then
		self.Instance:SetAttribute("InteractionDisabled", true)
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v