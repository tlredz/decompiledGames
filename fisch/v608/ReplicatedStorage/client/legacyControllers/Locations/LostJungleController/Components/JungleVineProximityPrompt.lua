game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
return (Component.new({
	Tag = "JungleVineProximityPrompt",
	Ancestors = { Workspace }
}))