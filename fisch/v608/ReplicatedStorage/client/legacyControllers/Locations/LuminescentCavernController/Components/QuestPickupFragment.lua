local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../LocalDataState")
require("../Utility")
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.QuestPickupFragment,
	Ancestors = { Workspace }
})

function v:Construct()
	self.DataObserver = module:observe(function(p)
		if p and p.KeystoneData and p.KeystoneData.Fragments and p.KeystoneData.Fragments.Collected and p.KeystoneData.Fragments.Collected[LuminescentCavern.Enums.CrownFragment.Cepo] then
			self:OnCollected()
		end
	end, true)
end

function v:Stop()
	if self.DataObserver then
		self.DataObserver()
		self.DataObserver = nil
	end
end

function v:OnCollected()
	self.Instance:Destroy()
end

return v