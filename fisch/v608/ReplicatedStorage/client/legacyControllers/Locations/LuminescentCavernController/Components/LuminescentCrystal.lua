local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local modules = ReplicatedStorage.shared.modules
local LuminescentCavern = require(modules.LuminescentCavern)
local module = require("../LocalDataState")
local v = Component.new({
	Tag = LuminescentCavern.Enums.CollectionService.LuminescentCrystal,
	Ancestors = { Workspace }
})

function v:Construct()
	self.UID = self.Instance:GetAttribute("UID")
	self.UID = tostring(self.UID)
	local flag = false
	self.Observer = module:observe(function(p)
		if flag or not p then
			return
		end

		if p.KeystoneData.Wixie.CrystalsCollected[self.UID] then
			flag = true
			self.Instance:Destroy()
			task.defer(function()
				if self.Observer then
					self.Observer()
					self.Observer = nil
				end
			end)
		end
	end, true)
end

function v:Stop()
	if self.Observer then
		self.Observer()
		self.Observer = nil
	end
end

return v