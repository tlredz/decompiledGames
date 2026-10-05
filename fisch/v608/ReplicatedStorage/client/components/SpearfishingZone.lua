game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
require(packages.Observers)
local modules = ReplicatedStorage.shared.modules
require(modules.FishRoaming)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "SpearfishingZone",
	Ancestors = { Workspace }
})

function v.Construct(_) end

function v.Stop(p)
	if p.Observer then
		p.Observer()
	end
end

return v