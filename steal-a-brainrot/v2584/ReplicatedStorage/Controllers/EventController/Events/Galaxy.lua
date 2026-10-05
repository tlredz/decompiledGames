local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Galaxy = {}
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local name = script.Name
local UFO = ReplicatedStorage.Models.Events.UFO.UFO
local maid = Trove.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function createUFOVisuals()
	local maid2 = maid:Extend()
	maid2:Add(Observers.observeTag("GalaxyUFO", function(part)
		if not part:IsA("BasePart") then
			return nil
		end

		local maid3 = maid2:Extend()
		local clone = maid3:Clone(UFO)

		for _, part2 in clone:GetDescendants() do
			if part2:IsA("BasePart") then
				part2.Anchored = true
			end
		end

		clone.Parent = workspace
		maid3:Add(RunService.PostSimulation:Connect(function()
			debug.profilebegin("Galaxy:MoveUFO")

			if clone.PrimaryPart and part.Parent then
				clone:PivotTo(part.CFrame)
			else
				maid3:Destroy()
			end

			debug.profileend()
		end))
		return function()
			maid3:Destroy()
		end
	end))
end

function Galaxy.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereGalaxy)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.SkyGalaxy)
	clone_3.Parent = Lighting
	EffectController:Run("GalaxyEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("GalaxyEvent", "GrassRecolor")
	end)
	EffectController:Run("GalaxyEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("GalaxyEvent", "WallRecolor")
	end)

	if not ServerData.IsJumpLTMServer() then
		if ServerData.IsTsunamiServer() then
			local clone_4 = maid:Clone(script.GalaxyMapTsunami)
			clone_4.Parent = workspace
		elseif ServerData.IsBiggerServer() then
			local clone_5 = maid:Clone(script.GalaxyMapBigger)
			clone_5.Parent = workspace
		else
			local clone_6 = maid:Clone(script.GalaxyMap)
			clone_6.Parent = workspace
		end
	end

	maid:Add(Observers.observeTag("HideInGalaxy", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.GalaxyWeather))
	else
		local clone

		if ServerData.IsTsunamiServer() then
			clone = script.GalaxyWeatherTsunami:Clone()
		else
			clone = script.GalaxyWeather:Clone()
		end

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone, 2)
		end

		clone.Parent = workspace
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
	createUFOVisuals() -- equivalent call inferred; original call site unknown
end

function Galaxy.OnStop(_)
	maid:Destroy()
end

function Galaxy.OnLoad(_) end

return Galaxy