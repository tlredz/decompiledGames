local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UnlockableController = require(ReplicatedStorage.Modules.Client.PlayerData.UnlockableController)
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "UnlockableAlternateText"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local unlockableAlternateText_Text = self.Instance:GetAttribute("UnlockableAlternateText_Text")
	assert(typeof(unlockableAlternateText_Text) == "string")
	local unlockableAlternateText_Item = self.Instance:GetAttribute("UnlockableAlternateText_Item")
	assert(typeof(unlockableAlternateText_Item) == "string")

	if UnlockableController.IsFeatureUnlocked(unlockableAlternateText_Item, nil) then
		self.Instance.Text = unlockableAlternateText_Text
	else
		self._Janitor:Add(UnlockableController.OnItemUnlocked:Connect(function(p2)
			if p2 == unlockableAlternateText_Item then
				self.Instance.Text = unlockableAlternateText_Text
			end
		end))
	end
end

function v:Stop()
	self._Janitor:Destroy()
end

return v