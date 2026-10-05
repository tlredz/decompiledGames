local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Bloodmoon = {}
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
require(ReplicatedStorage.Packages.Spring)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
require(ReplicatedStorage.Packages.Net)
local _ = script.Name
local maid = Trove.new()

function Bloodmoon.OnStart(_)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone = maid:Clone(script.AtmosphereBloodmoon)
	clone.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.SkyBloodmoon)
	clone_2.Parent = Lighting
	CycleController:Update()
	SoundController:UpdateOST()
end

function Bloodmoon.OnStop(_)
	maid:Destroy()
end

function Bloodmoon.OnLoad(_) end

return Bloodmoon