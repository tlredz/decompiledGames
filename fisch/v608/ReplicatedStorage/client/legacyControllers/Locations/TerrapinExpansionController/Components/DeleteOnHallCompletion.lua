local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedTerrapinExpansion)
local module = require("../LocalDataState")
local v = Component.new({
	Tag = "DeleteOnHallCompletion",
	Ancestors = { Workspace }
})

function v:Construct()
	self.Instance:GetAttribute("UID")
	self.DataObserver = module:observe(function(p)
		if not p then
			return
		end

		local flag = true

		for _, passageRequirement in p.HallOfWhispers.PassageRequirements do
			if passageRequirement then
				continue
			end

			flag = false
			break
		end

		if flag then
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