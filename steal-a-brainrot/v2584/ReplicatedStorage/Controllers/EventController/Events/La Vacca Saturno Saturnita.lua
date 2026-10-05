local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local LaVaccaSaturnoSaturnita = {}
local _ = ReplicatedStorage.Models.Events["La Vacca"]
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.TsunamiEventController)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
local ShakePresets = require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.TweenPivot)
require(ReplicatedStorage.Datas.ServerData)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EventService/LaVacca/Comet")
local name = script.Name
local maid = Trove.new()
local currentCamera = workspace.CurrentCamera

function LaVaccaSaturnoSaturnita.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	workspace:GetServerTimeNow()
	local v = activeEventData.startedAt + 11 - workspace:GetServerTimeNow()

	if v > 0 then
		local maid2 = maid:Extend()
		local parent2 = maid2:Add(Instance.new("Model"))
		local primaryPart = maid2:Add(Instance.new("Part"))
		primaryPart.Name = "Center"
		primaryPart.Transparency = 1
		primaryPart.Anchored = true
		primaryPart.CanCollide = false
		primaryPart.CanQuery = false
		primaryPart.CanTouch = false
		primaryPart.Size = createVector(1, 1, 1)
		primaryPart.Position = ReplicatedStorage:GetAttribute("LaVaccaCenter") or MapInformation.MapCenter.Position
		primaryPart.Parent = parent2
		parent2.PrimaryPart = primaryPart
		parent2.Parent = workspace
		local v4 = table.create(3)
		maid2:Add(function()
			table.clear(v4)
		end)
		local total = 0
		maid2:Add(RunService.PreRender:Connect(function(dt: number)
			debug.profilebegin("La Vacca Event")
			total += dt

			for k, v5 in v4 do
				if not (v5.target and v5.targetAttachment) then
					continue
				end

				v5.beam.First.Enabled = true
				v5.beam.Second.Enabled = true
				local v6 = math.clamp(total - k + 1, 0, 1)
				local worldPosition = v5.beam.WorldPosition
				v5.targetAttachment.Position = worldPosition + (v5.target:GetPivot().Position - worldPosition) * v6
			end

			debug.profileend()
		end))
		maid2:Add(Observers.observeTag("LaVaccaModel", function(instance)
			instance.Parent = parent2
			local clone = script.PlayerVFX.Beam:Clone()
			clone.Parent = instance.PrimaryPart
			v4[instance:GetAttribute("LaVaccaIndex")] = {
				beam = clone,
				target = nil
			}
			local v5 = Observers.observeTag("LaVaccaModel", function(instance2)
				if not (instance2 ~= instance and instance2:GetAttribute("LaVaccaIndex") == instance:GetAttribute("LaVaccaIndex") % 3 + 1) then
					return nil
				end

				local attachment = Instance.new("Attachment")
				attachment.Position = clone.WorldPosition
				attachment.Parent = workspace.Terrain
				local v6 = v4[instance:GetAttribute("LaVaccaIndex")]
				v6.target = instance2.PrimaryPart
				v6.beam.First.Attachment0 = attachment
				v6.beam.Second.Attachment0 = attachment
				v6.targetAttachment = attachment
				return function()
					attachment:Destroy()
				end
			end)
			return function()
				v4[instance:GetAttribute("LaVaccaIndex")] = nil
				clone:Destroy()
				v5()
			end
		end))
		local cFrame = primaryPart.CFrame
		local clone = maid2:Clone(script.SummonVFX)
		clone:PivotTo(cFrame)
		clone.Parent = workspace
		local clone2 = maid2:Clone(script.SummonVFXBeam)
		clone2:PivotTo(cFrame)
		clone2.Parent = workspace
		maid2:Add(RunService.PostSimulation:Connect(function(_: number)
			debug.profilebegin("La Vacca Event Animation")
			local serverTimeNow = workspace:GetServerTimeNow()

			if serverTimeNow < activeEventData.startedAt + 3 then
				return
			end

			local v5 = math.clamp(1 - (activeEventData.startedAt + 11 - serverTimeNow) / 8, 0, 1)
			local v6 = v5 * v5 * 3.141592653589793 * 2 * 8
			local v7 = v5 * v5 * 150
			parent2:PivotTo(cFrame * CFrame.Angles(0, v6, 0) * CFrame.new(0, v7, 0))
			clone2.Beams.Position = Vector3.new(0, v7, 0)

			if v5 >= 1 then
				maid2:Clean()
			end

			debug.profileend()
		end))
		maid2:Add(Observers.observeTag("LaVaccaPlayerVFX", function(parent)
			local clone3 = script.PlayerVFX.Torso:Clone()
			clone3.Parent = parent
			return function()
				clone3:Destroy()
			end
		end, { workspace }))
	end

	maid:Add(task.delay(v, function()
		EffectController:Run(name, "Space")
		EffectController:Activate("Blink")
		maid:Add(function()
			EffectController:Activate("Blink")
		end)
		ReplicatedStorage:SetAttribute("LaVaccaEvent", true)
		SoundController:UpdateOST()
		CycleController:Update()
		maid:Add(function()
			ReplicatedStorage:SetAttribute("LaVaccaEvent", nil)
			EffectController:Stop(name, "Space")
		end)
	end))
	maid:Add(remoteEvent.OnClientEvent:Connect(function(position: Vector3, p)
		local cframe = CFrame.new(position)
		task.spawn(function()
			local v2

			if typeof(p) == "Vector3" then
				v2 = p
			else
				v2 = ClientEventUtils.getAnimalPosition(p)
			end

			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Events["La Vacca Saturno Saturnita"].CommetActivation,
				v2
			)
		end)
		local clone = script.Comet:Clone()
		clone:PivotTo(cframe)
		clone.Parent = workspace
		local total = 0
		local preRenderConnection = nil
		preRenderConnection = RunService.PreRender:Connect(function(dt: number)
			if not (preRenderConnection and preRenderConnection.Connected) then
				return
			end

			debug.profilebegin("La Vacca Commet Hit")
			total += dt
			local v2

			if typeof(p) == "Vector3" then
				v2 = p
			else
				v2 = ClientEventUtils.getAnimalPosition(p)
			end

			if not v2 then
				return
			end

			local cframe2 = CFrame.new(v2)
			local v3 = math.clamp(total / 1, 0, 1)
			clone:PivotTo(cframe:Lerp(cframe2, v3))

			if v3 >= 1 then
				preRenderConnection:Disconnect()

				if (currentCamera.CFrame.Position - cframe2.Position).Magnitude <= 70 then
					local clone2 = ShakePresets.Bump:Clone()
					maid:Add(clone2)
					clone2.Sustain = true
					maid:Add(ShakePresets.BindShakeToCamera(clone2, currentCamera))
					clone2:Start()
					maid:Add(task.delay(0.3, function()
						clone2:StopSustain()
					end))
				end

				ClientEventUtils.playBurst(
					script.CometBurst,
					p,
					{ ReplicatedStorage.Sounds.Events["La Vacca Saturno Saturnita"].CommetHit }
				)

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.Transparency = 1
					elseif descendant:IsA("ParticleEmitter") then
						descendant.Enabled = false
						descendant:Clear()
					end
				end

				task.delay(2, function()
					clone:Destroy()
				end)
			end

			debug.profileend()
		end)
	end))
end

function LaVaccaSaturnoSaturnita.OnStop(_)
	maid:Destroy()
end

function LaVaccaSaturnoSaturnita.OnLoad(_) end

return LaVaccaSaturnoSaturnita