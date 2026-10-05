local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HideGuiObjectIfPlayerCannotSeeAdvertisement"
})
local PolicyService = game:GetService("PolicyService")

function v:Construct()
	self._Janitor = Janitor.new()
end

function v.Start(p)
	p.Instance.Visible = false

	if PolicyService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer).AreAdsAllowed then
		p.Instance.Visible = true
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v