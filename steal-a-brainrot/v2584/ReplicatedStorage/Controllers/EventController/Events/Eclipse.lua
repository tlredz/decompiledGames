local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local VFX = require(ReplicatedStorage.Shared.VFX)
local name = script.Name
local maid = Trove.new()

local function loadTrack(instance, animation)
	if not (instance and animation and animation:IsA("Animation")) then
		return nil
	end

	local animationController = instance:FindFirstChildOfClass("AnimationController")
	local animator = animationController and animationController:FindFirstChildOfClass("Animator")

	if not animator then
		return nil
	end

	local track = animator:LoadAnimation(animation)
	maid:Add(function()
		track:Stop(0)
		track:Destroy()
	end)
	return track
end

local Eclipse = {}

function Eclipse.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	maid:Clean()
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("EclipseEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("EclipseEvent", "GrassRecolor")
	end)
	EffectController:Run("EclipseEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("EclipseEvent", "WallRecolor")
	end)
	EffectController:Run("EclipseEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("EclipseEvent", "WallBottomRecolor")
	end)
	local eclipseAtmosphere = script:FindFirstChild("EclipseAtmosphere")

	if eclipseAtmosphere then
		local atmosphere = Lighting:FindFirstChild("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(eclipseAtmosphere)
		clone_2.Parent = Lighting
	end

	local eclipseSky = script:FindFirstChild("EclipseSky")

	if eclipseSky then
		local cartoon = Lighting:FindFirstChild("Cartoon") or Lighting:FindFirstChildOfClass("Sky")

		if cartoon then
			cartoon.Parent = script
			maid:Add(function()
				cartoon.Parent = Lighting
			end)
		end

		local clone_3 = maid:Clone(eclipseSky)
		clone_3.Parent = Lighting
	end

	local eclipseMap = script:FindFirstChild("EclipseMap")
	local isJumpLTMServer = ServerData.IsJumpLTMServer()

	if eclipseMap and (isJumpLTMServer or not (ServerData.IsTsunamiServer() or ServerData.IsBiggerServer())) then
		local clone = maid:Clone(eclipseMap)

		if isJumpLTMServer then
			for _, childName in { "Ground", "Walls", "Carpet" } do
				local child = clone:FindFirstChild(childName)

				if child then
					child:Destroy()
				end
			end

			local VFX2 = clone:FindFirstChild("VFX")

			if VFX2 then
				maid:Add(JumpLTMWeather.Cover(VFX2))
				VFX2:Destroy()
			end
		end

		clone.Parent = workspace

		if not isJumpLTMServer then
			maid:Add(Observers.observeTag("HideInEclipse", function(p)
				local parent = p.Parent
				p.Parent = script
				return function()
					pcall(function()
						p.Parent = parent
					end)
				end
			end, { workspace, script }))
		end

		local sun = clone:FindFirstChild("Sun")
		local v = loadTrack(sun, script:FindFirstChild("SunIdle"))

		if v then
			v:Play()
		end

		local v2 = loadTrack(
			clone:FindFirstChild("AnimatedComponents"),
			script:FindFirstChild("AnimatedComponentsLoop")
		)

		if v2 then
			v2:Play()
		end

		local v3 = loadTrack(sun, script:FindFirstChild("SunBurst"))

		if v3 then
			v3.Looped = false
			v3.Priority = Enum.AnimationPriority.Action2

			if v then
				maid:Add(v3.Stopped:Connect(function()
					v.TimePosition = 0
				end))
			end

			local mutationEmit = sun and sun:FindFirstChild("MutationEmit", true)
			maid:Add(Net:RemoteEvent("GameService/EclipseSunBurst").OnClientEvent:Connect(function()
				v3:Stop(0)
				v3:Play(0.4)

				if mutationEmit then
					VFX.emit(mutationEmit)
				end
			end))
		end
	end

	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Eclipse.OnStop(_)
	maid:Clean()
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Eclipse.OnLoad(_) end

return Eclipse