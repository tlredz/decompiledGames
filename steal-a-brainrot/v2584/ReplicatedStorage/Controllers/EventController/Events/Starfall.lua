local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
require(ReplicatedStorage.Shared.EventTypes)
local Starfall = {}
local Net = require(ReplicatedStorage.Packages.Net)
local Trove = require(ReplicatedStorage.Packages.Trove)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Shake = require(ReplicatedStorage.Packages.Shake)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local JumpLTMWeather = require(ReplicatedStorage.Controllers.EventController.JumpLTMWeather)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local remoteEvent = Net:RemoteEvent("EventService/Starfall/CreateStar")
local remoteEvent2 = Net:RemoteEvent("EventService/Starfall/ExplodeStar")
local name = script.Name
local v = Shake.new()
v.Amplitude = 1.5
v.Frequency = 0.1
v.FadeInTime = 0
v.FadeOutTime = 0.6
v.PositionInfluence = createVector(0.2, 0.2, 0.2)
v.RotationInfluence = createVector(2.5, 0.5, 0.5)
local maid = Trove.new()
local v2 = {}

function Starfall.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("Starfall", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("Starfall", nil)
	end)
	maid:Add(function()
		EffectController:Activate("Blink")
	end)
	local clone

	if ServerData.IsJumpLTMServer() then
		clone = nil
	elseif ServerData.IsTsunamiServer() then
		clone = maid:Clone(script.StarfallWeatherTsunami)
	else
		clone = maid:Clone(script.StarfallWeather)
	end

	if clone then
		VFX.disable(clone)
		clone.Parent = workspace
	end

	if clone and ServerData.IsBiggerServer() then
		ClientEventUtils.resizeEffects(clone, 2)
	end

	local v3 = activeEventData.startedAt + 4 - workspace:GetServerTimeNow()
	maid:Add(task.delay(v3, function()
		EffectController:Activate("Blink")
		local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")

		if atmosphere then
			atmosphere.Parent = script
			maid:Add(function()
				atmosphere.Parent = Lighting
			end)
		end

		local clone_2 = maid:Clone(script.Atmosphere)
		clone_2.Parent = Lighting

		if not ReplicatedStorage:GetAttribute("LaserCityEvent") then
			local sky = Lighting:FindFirstChildOfClass("Sky")

			if sky then
				sky.Parent = script
				maid:Add(function()
					sky.Parent = Lighting
				end)
			end

			local clone_3 = maid:Clone(script.Sky)
			clone_3.Parent = Lighting
		end

		if ServerData.IsJumpLTMServer() then
			maid:Add(JumpLTMWeather.Cover(script.StarfallWeather))
		elseif clone then
			VFX.enable(clone)
		end
	end))
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
end

function Starfall.OnStop(_)
	maid:Destroy()

	for _, v3 in v2 do
		if v3.Tween then
			v3.Tween:Cancel()
		end

		if v3.Model then
			v3.Model:Destroy()
		end
	end

	table.clear(v2)
end

function Starfall.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, position: Vector3, vector2: Vector3, duration: number)
		local clone = script.Meteor:Clone()
		clone:PivotTo(CFrame.new(position))
		clone.Parent = workspace
		local primaryPart = clone.PrimaryPart

		if primaryPart then
			local tween = TweenService:Create(primaryPart, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				CFrame = CFrame.lookAt(vector2, position)
			})
			tween:Play()
			v2[p] = {
				Model = clone,
				Tween = tween
			}
			tween.Completed:Once(function()
				if v2[p] then
					v2[p].Tween = nil
				end
			end)
		else
			warn("Starfall meteor model is missing a PrimaryPart!")
			clone:Destroy()
		end
	end)
	remoteEvent2.OnClientEvent:Connect(function(p: string, position: Vector3, p2)
		local v3 = v2[p]

		if v3 then
			task.spawn(function()
				SoundController:PlaySound(ReplicatedStorage.Sounds.Events.Starfall.Impact, position)
			end)

			if v3.Tween then
				v3.Tween:Cancel()
			end

			if v3.Model then
				local model = v3.Model

				for _, descendant in model:GetDescendants() do
					if descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false
					elseif descendant:IsA("BasePart") then
						descendant.Transparency = 1
					end
				end

				Debris:AddItem(model, 3)
			end

			v2[p] = nil
		end

		if p2 then
			ClientEventUtils.playBurst(script.StruckVFX, p2, { ReplicatedStorage.Sounds.Events.Starfall.BrainrotHit })
			return
		end

		local clone = script.Explosion:Clone()
		clone:PivotTo(CFrame.new(position))
		clone.Parent = workspace

		for _, emitter in clone:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v4 = emitter
			task.delay(emitter:GetAttribute("EmitDelay") or 0, function()
				v4:Emit(v4:GetAttribute("EmitCount") or 1)
			end)
		end

		Debris:AddItem(clone, 5)
		local magnitude = (workspace.CurrentCamera.CFrame.Position - position).Magnitude

		if magnitude <= 150 then
			local clone2 = v:Clone()
			local v4 = math.pow(1 - magnitude / 150, 2)
			clone2.Amplitude *= v4
			clone2.RotationInfluence *= v4
			maid:Add(ShakePresets.BindShakeToCamera(clone2))
			clone2:Start()
		end
	end)
end

return Starfall