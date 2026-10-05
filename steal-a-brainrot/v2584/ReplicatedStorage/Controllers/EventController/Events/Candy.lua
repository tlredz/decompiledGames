local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Candy = {}
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Net)
local _ = script.Name
local maid = Trove.new()

function Candy.OnStart(_)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereCandy)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.SkyCandy)
	clone_3.Parent = Lighting

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.CandyWeather))
	else
		local clone

		if ServerData.IsTsunamiServer() then
			clone = script.CandyWeatherTsunami:Clone()
		else
			clone = script.CandyWeather:Clone()
		end

		clone.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone, 2)
		end

		maid:Add(function()
			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(4)
			clone:Destroy()
		end)
	end

	CycleController:Update()
	SoundController:UpdateOST()
end

function Candy.OnStop(_)
	maid:Destroy()
end

function Candy.OnLoad(_) end

return Candy