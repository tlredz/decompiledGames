game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local ChicleteiraBicicleteira = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Utils.MathUtils)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Spr = require(ReplicatedStorage.Packages.Spr)
local VFX = require(ReplicatedStorage.Shared.VFX)
require(ReplicatedStorage.Shared.Snapshot)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Chicleteira Bicicleteira/SpawnChicleteira")
local remoteEvent2 = Net:RemoteEvent("EventService/Chicleteira Bicicleteira/Burst")
local maid = Trove.new()

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v = table.create(2)
	maid2:Add(function()
		table.clear(v)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Chicleteira Event")
		total += dt

		for k, v2 in v do
			if not (v2.target and v2.targetAttachment) then
				continue
			end

			v2.beam.First.Enabled = true
			v2.beam.Second.Enabled = true
			local v3 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v2.beam.WorldPosition
			v2.targetAttachment.Position = worldPosition + (v2.target:GetPivot().Position - worldPosition) * v3
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("ChicleteiraPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX[`Torso{parent:GetAttribute("ChicleteiraIndex") % 2 + 1}`]:Clone()
		clone2.Parent = parent
		local clone3 = script.PlayerVFX[`vfxTorso{parent:GetAttribute("ChicleteiraIndex") % 2 + 1}`]:Clone()
		local children = {}

		for _, child in clone3:GetChildren() do
			child.Parent = parent
			table.insert(children, child)
		end

		clone3:Destroy()
		local chicleteiraIndex = parent:GetAttribute("ChicleteiraIndex")
		v[chicleteiraIndex] = {
			beam = clone,
			target = nil
		}
		local v2 = Observers.observeTag("ChicleteiraPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("ChicleteiraIndex") == parent:GetAttribute("ChicleteiraIndex") % 2 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v3 = v[parent:GetAttribute("ChicleteiraIndex")]
			v3.target = target
			v3.beam.First.Attachment0 = attachment
			v3.beam.Second.Attachment0 = attachment
			v3.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		return function()
			clone2:Destroy()
			clone:Destroy()

			for _, v3 in children do
				v3:Destroy()
			end

			v2()
			v[chicleteiraIndex] = nil
		end
	end))
end

function ChicleteiraBicicleteira.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("ChicleteiraBicicleteiraEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("ChicleteiraBicicleteiraEvent", nil)
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	maid:Add(task.delay(activeEventData.startedAt + 2 - workspace:GetServerTimeNow(), function()
		if not ServerData.IsJumpLTMServer() then
			if ServerData.IsBiggerServer() then
				local clone = maid:Clone(script.MapBigger)
				clone.Parent = workspace
			else
				local clone_2 = maid:Clone(script.Map)
				clone_2.Parent = workspace
			end

			maid:Add(Observers.observeTag("HideInChicleteiraBicicleteira", function(p)
				local parent = p.Parent
				p.Parent = script
				return function()
					pcall(function()
						p.Parent = parent
					end)
				end
			end, { workspace, script }))
			EffectController:Run("ChicleteiraBicicleteiraEvent", "GrassRecolor")
			maid:Add(function()
				EffectController:Stop("ChicleteiraBicicleteiraEvent", "GrassRecolor")
			end)
			EffectController:Run("ChicleteiraBicicleteiraEvent", "WallRecolor")
			maid:Add(function()
				EffectController:Stop("ChicleteiraBicicleteiraEvent", "WallRecolor")
			end)
		end

		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
		EffectController:Activate("Blink")
	end))
	maid:Add(Observers.observeTag("Event_ChicleteiraBicicleteira", function(parent)
		local pivot = parent:GetPivot() * CFrame.fromOrientation(0, 3.141592653589793, 0)
		local maid2 = Trove.new()
		local clone = maid2:Clone(script["Standing Chicleteira Bicicleteira"])
		clone:PivotTo(pivot - Vector3.new(0, clone:GetExtentsSize().Y, 0))
		clone.Parent = parent
		local track = clone.AnimationController.Animator:LoadAnimation(script.Idle)
		maid2:Add(track, "Stop")
		maid2:Add(track)
		track.Looped = true
		track.Priority = Enum.AnimationPriority.Idle
		track:Play()
		local track2 = clone.AnimationController.Animator:LoadAnimation(script.Painting)
		maid2:Add(track2, "Stop")
		maid2:Add(track2)
		track2.Looped = false
		track2.Priority = Enum.AnimationPriority.Action4
		maid2:Add(track:GetMarkerReachedSignal("Shake"):Connect(function(...)
			if track2.IsPlaying then
				return
			end

			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Chicleteira Bicicleteira"].Shake,
					pivot.Position
				)
			end)
		end))
		maid2:Add(parent:GetAttributeChangedSignal("ForceSpray"):Connect(function()
			if not parent:GetAttribute("ForceSpray") then
				return
			end

			task.spawn(function()
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Chicleteira Bicicleteira"].Spray,
					pivot.Position
				)
			end)
			track2:Stop(0)
			track2:Play()
			task.wait(0.3)
			VFX.enable(clone.Handle.vfx)
			task.wait(1)
			VFX.disable(clone.Handle.vfx)
		end))
		maid2:Add(task.spawn(function()
			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Events["Chicleteira Bicicleteira"].Ground,
				pivot.Position
			)
		end))
		maid2:Add(Timer.Simple(0.1, function()
			local forceSpray = parent:GetAttribute("ForceSpray")
			local v2 = forceSpray and ClientEventUtils.getAnimalPosition(forceSpray)

			if not v2 then
				Spr.target(clone, 1, 2, {
					Pivot = pivot
				})
				return
			end

			local vector = Vector3.new(v2.X, pivot.Y, v2.Z)
			Spr.target(clone, 1, 2, {
				Pivot = CFrame.lookAt(pivot.Position, vector) * CFrame.fromOrientation(0, 3.141592653589793, 0)
			})
		end, true))
		return maid2:WrapClean()
	end, { workspace }))
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
end

function ChicleteiraBicicleteira.OnStop(_)
	maid:Destroy()
end

function ChicleteiraBicicleteira.OnLoad(_)
	remoteEvent2.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Chicleteira Bicicleteira"].Hit })
	end)
	remoteEvent.OnClientEvent:Connect(function(cframe: CFrame, cframe2: CFrame, p: number, cframe3: CFrame?)
		local clone = script["Chicleteira Bicicleteira"]:Clone()
		clone:PivotTo(cframe3 or cframe)
		clone.Parent = workspace
		local track = clone.AnimationController.Animator:LoadAnimation(script.Walk)
		track.Looped = true
		track:Play()
		track:AdjustSpeed(2)
		local clone2 = maid:Clone(ReplicatedStorage.Sounds.Events["Chicleteira Bicicleteira"].Bike)
		clone2.Parent = clone.PrimaryPart
		clone2:Play()
		local v = math.abs(cframe2.Z - cframe.Z) / p
		local total = 0
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			total += dt
			local v2 = math.clamp(total / v, 0, 1)

			if v2 >= 1 and postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
				clone:Destroy()
			end

			if cframe3 == nil then
				clone:PivotTo(cframe:Lerp(cframe2, v2), v2)
				return
			end

			local lerped = cframe:Lerp(cframe2, v2)
			local lerped2 = cframe3:Lerp(cframe2, v2)
			local v3 = math.clamp(v2 / 0.05, 0, 1)
			local v4 = 5 + (lerped2.Y - lerped.Y)
			local v5 = math.lerp(lerped2.Y, lerped.Y, v3) + math.sin(3.141592653589793 * v3) * v4
			clone:PivotTo(CFrame.new(lerped.X, v5, lerped2.Z) * lerped.Rotation)
		end)
	end)
end

return ChicleteiraBicicleteira