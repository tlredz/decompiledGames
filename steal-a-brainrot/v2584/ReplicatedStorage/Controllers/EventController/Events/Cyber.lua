local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local VFX = require(ReplicatedStorage.Shared.VFX)
local color = Color3.fromRGB(70, 210, 255)
local name = script.Name
local maid = Trove.new()
local v = nil
local Cyber = {}

function Cyber.OnStart(_)
	assert((EventController:GetActiveEventData(name)))
	EffectController:Activate("Blink")
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	EffectController:Run("CyberEvent", "GrassRecolor")
	maid:Add(function()
		EffectController:Stop("CyberEvent", "GrassRecolor")
	end)
	EffectController:Run("CyberEvent", "WallRecolor")
	maid:Add(function()
		EffectController:Stop("CyberEvent", "WallRecolor")
	end)
	EffectController:Run("CyberEvent", "WallBottomRecolor")
	maid:Add(function()
		EffectController:Stop("CyberEvent", "WallBottomRecolor")
	end)
	local clone, track

	if ServerData.IsJumpLTMServer() then
		clone = nil
		track = nil
	else
		if ServerData.IsBiggerServer() then
			clone = maid:Clone(script.BiggerCyberMap)
		else
			clone = maid:Clone(script.CyberMap)
		end

		clone.Parent = workspace
		local beaconAnimation = script.BeaconAnimation
		track = clone.Beacon.AnimationController.Animator:LoadAnimation(beaconAnimation)
		maid:Add(function()
			track:Stop()
			track:Destroy()
		end)
	end

	local count = 0
	maid:Add(Net:RemoteEvent("GameService/CyberBeaconAnimation").OnClientEvent:Connect(function(_: CFrame?, _: number?, flag: boolean?)
		if clone and track and not flag and clone:IsDescendantOf(workspace) then
			track:Stop(0)
			track:Play()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Sfx.CyberSpawn, clone.Beacon:GetPivot().Position, false)
			VFX.emit(clone.Beacon)
		end

		count += 1
		local v2 = count
		task.spawn(function()
			local map = workspace:FindFirstChild("Map")
			local cave = map and map:FindFirstChild("Cave")
			local collisions = cave and cave:FindFirstChild("Collisions")

			if not collisions then
				return
			end

			local descendants = collisions:QueryDescendants("BasePart")

			if #descendants == 0 then
				return
			end

			if not v then
				local colorsByDescendant = {}

				for _, descendant in descendants do
					colorsByDescendant[descendant] = descendant.Color
				end

				v = colorsByDescendant
			end

			assert(v)

			local function stillActive()
				return v2 == count
			end

			for _, descendant in descendants do
				CreateTween(
					descendant,
					TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0.5),
					{
						Color = color
					}
				)
			end

			task.wait(1.7)

			if v2 ~= count then
				return
			end

			for _ = 1, 2 do
				if v2 ~= count then
					return
				end

				for _, descendant in descendants do
					descendant.Color = v[descendant]
				end

				task.wait(0.1)

				if v2 ~= count then
					return
				end

				for _, descendant in descendants do
					descendant.Color = color
				end

				task.wait(0.1)
			end

			if v2 ~= count then
				return
			end

			for _, descendant in descendants do
				CreateTween(descendant, TweenInfo.new(0.5), {
					Color = v[descendant]
				})
			end
		end)
	end))
	local atmosphere = Lighting:FindFirstChild("Atmosphere")

	if atmosphere then
		atmosphere.Parent = script
		maid:Add(function()
			atmosphere.Parent = Lighting
		end)
	end

	local clone_2 = maid:Clone(script.AtmosphereCyber)
	clone_2.Parent = Lighting
	local cartoon = Lighting:FindFirstChild("Cartoon")

	if cartoon then
		cartoon.Parent = script
		maid:Add(function()
			cartoon.Parent = Lighting
		end)
	end

	local clone_3 = maid:Clone(script.SkyCyber)
	clone_3.Parent = Lighting
	maid:Add(Observers.observeTag("HideInCyber", function(p)
		local parent = p.Parent
		p.Parent = script
		return function()
			pcall(function()
				p.Parent = parent
			end)
		end
	end, { workspace, script }))
	maid:Add(Observers.observeTag("ShowInCyber", function(instance)
		local parent = instance.Parent
		local v2 = false
		local destroyingConnection = parent.Destroying:Once(function()
			v2 = true
			instance:Destroy()
		end)
		instance.Parent = script
		return function()
			destroyingConnection:Disconnect()

			if not v2 then
				pcall(function()
					instance.Parent = parent
				end)
			end
		end
	end, { workspace, script }))
	CycleController:Update()
	SoundController:UpdateOST()
end

function Cyber.OnStop(_)
	maid:Destroy()
end

function Cyber.OnLoad(_) end

return Cyber