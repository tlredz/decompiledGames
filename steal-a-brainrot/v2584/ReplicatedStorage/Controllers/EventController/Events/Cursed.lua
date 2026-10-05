local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Cursed = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Spr)
require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()

function Cursed.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone = maid:Clone(script.AtmosphereCursed)
	clone.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.SkyCursed)
	clone_2.Parent = Lighting
	local v = true
	maid:Add(function()
		v = false
	end)
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("CursedEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("CursedEvent", "GrassRecolor")
	end)
	EffectController:Run("CursedEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("CursedEvent", "WallRecolor")
	end)
	EffectController:Run("CursedEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("CursedEvent", "WallBottomRecolor")
	end)

	if not ServerData.IsJumpLTMServer() then
		if ServerData.IsTsunamiServer() then
			local clone_3 = maid:Clone(script.CursedMapTsunami)
			clone_3.Parent = workspace
		elseif ServerData.IsBiggerServer() then
			local clone_4 = maid:Clone(script.CursedMapBigger)
			clone_4.Parent = workspace
		else
			local clone_5 = maid:Clone(script.CursedMap)
			clone_5.Parent = workspace
		end
	end

	maid:Add(Observers.observeTag("HideInCursed", function(p)
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

function Cursed.OnStop(_)
	maid:Destroy()
end

function Cursed.OnLoad(_) end

return Cursed