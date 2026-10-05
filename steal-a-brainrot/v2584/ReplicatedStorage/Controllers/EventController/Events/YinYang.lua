local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local Observers = require(ReplicatedStorage.Packages.Observers)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()
local YinYang = {}

function YinYang.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereYinYang)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone = maid:Clone(script.SkyYinYang)
	clone.Parent = Lighting
	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		clone.SkyboxOrientation += Vector3.new(0, -dt * 0.36, 0)
	end))
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("YinYangEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("YinYangEvent", "GrassRecolor")
	end)
	EffectController:Run("YinYangEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("YinYangEvent", "WallRecolor")
	end)
	EffectController:Run("YinYangEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("YinYangEvent", "WallBottomRecolor")
	end)

	if not ServerData.IsJumpLTMServer() then
		if ServerData.IsTsunamiServer() then
			local clone_3 = maid:Clone(script.YinYangMapTsunami)
			clone_3.Parent = workspace
		elseif ServerData.IsBiggerServer() then
			local clone_4 = maid:Clone(script.YinYangMapBigger)
			clone_4.Parent = workspace
		else
			local clone_5 = maid:Clone(script.YinYangMap)
			clone_5.Parent = workspace
		end
	end

	if ServerData.IsJumpLTMServer() then
		maid:Add(JumpLTMWeather.Cover(script.YinYangWeather))
	else
		local clone2

		if ServerData.IsTsunamiServer() then
			clone2 = script.YinYangWeatherTsunami:Clone()
		else
			clone2 = script.YinYangWeather:Clone()
		end

		clone2.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone2, 2)
		end

		maid:Add(function()
			VFX.disable(clone2)
			task.wait(4)
			clone2:Destroy()
		end)
	end

	maid:Add(Observers.observeTag("HideInYinYang", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
end

function YinYang.OnStop(_)
	maid:Destroy()
end

function YinYang.OnLoad(_) end

return YinYang