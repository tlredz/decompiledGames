local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local BombardiroCrocodilo = {}
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Controllers.AnimalController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
require(ReplicatedStorage.Shared.ShakePresets)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Shared.TweenPivot)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Packages.Shake)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local svininaBombardino = script["Svinina Bombardino"]
local bombardiroCrocodilo = script["Bombardiro Crocodilo"]
local remoteEvent = Net:RemoteEvent("EventService/Bombardiro Crocodilo/SpawnBomb")
local remoteEvent2 = Net:RemoteEvent("EventService/Bombardiro Crocodilo/Explode")
local name = script.Name
local maid = Trove.new()
local _ = workspace.CurrentCamera
local v = {}

function BombardiroCrocodilo.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	workspace:GetServerTimeNow()
	ReplicatedStorage:SetAttribute("BombardiroCrocodiloEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("BombardiroCrocodiloEvent", nil)
	end)
	maid:Add(task.delay(activeEventData.startedAt + 8 - workspace:GetServerTimeNow(), function()
		if not ServerData.IsJumpLTMServer() then
			local clone

			if ServerData.IsTsunamiServer() then
				clone = maid:Clone(script.PlanesbgTsunami)
			else
				clone = maid:Clone(script.Planesbg)
			end

			VFX.enable(clone)
			clone.Parent = workspace

			if ServerData.IsBiggerServer() then
				ClientEventUtils.resizeEffects(clone, 2)
			end
		end

		ReplicatedStorage:SetAttribute("BombardiroCrocodiloEventSoundTrack", true)
		SoundController:UpdateOST()
		maid:Add(function()
			ReplicatedStorage:SetAttribute("BombardiroCrocodiloEventSoundTrack", nil)
			SoundController:UpdateOST()
			EffectController:Activate("Blink")
		end)
	end))
	SoundController:UpdateOST()
	CycleController:Update()
	local maid2 = maid:Extend()
	local v2 = table.create(3)
	maid2:Add(function()
		table.clear(v2)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Bombardiro Event")
		total += dt

		for k, v3 in v2 do
			if not (v3.target and v3.targetAttachment) then
				continue
			end

			v3.beam.First.Enabled = true
			v3.beam.Second.Enabled = true
			local v4 = math.clamp(total - k + 1, 0, 1)
			local worldPosition = v3.beam.WorldPosition
			v3.targetAttachment.Position = worldPosition + (v3.target:GetPivot().Position - worldPosition) * v4
		end

		debug.profileend()
	end))
	maid2:Add(Observers.observeTag("BombardiroCrocodiloPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local bombardiroIndex = parent:GetAttribute("BombardiroIndex")
		v2[bombardiroIndex] = {
			beam = clone,
			target = nil
		}
		local v3 = Observers.observeTag("BombardiroCrocodiloPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("BombardiroIndex") == parent:GetAttribute("BombardiroIndex") % 3 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v4 = v2[parent:GetAttribute("BombardiroIndex")]
			v4.target = target
			v4.beam.First.Attachment0 = attachment
			v4.beam.Second.Attachment0 = attachment
			v4.targetAttachment = attachment
			return function()
				attachment:Destroy()
			end
		end)
		return function()
			clone2:Destroy()
			clone:Destroy()
			v3()
			v2[bombardiroIndex] = nil
		end
	end))
	local parents = {}
	maid:Add(Observers.observeTag("BombardiroPlane", function(parent)
		local clone = bombardiroCrocodilo:Clone()
		clone.PrimaryPart.Anchored = true

		for _, child in clone["Svinina Bombardino"]:GetChildren() do
			if child.Name ~= "RootPart" then
				child.Transparency = 1
			end
		end

		if FFlags:GetInstant("Optimisation.HumanoidBrainrotModels", ServerData.IsNewPlayersServer()) then
			local animationController = clone:FindFirstChild("AnimationController")

			if animationController then
				animationController:Destroy()
			end

			local humanoid = Instance.new("Humanoid", clone)
			Instance.new("Animator", humanoid)
			humanoid.Name = "AnimationController"
			humanoid.EvaluateStateMachine = false
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.PlatformStand = true
			humanoid.Parent = clone
		end

		clone.Parent = parent
		local thread = task.delay(5, function()
			for _, child in clone["Svinina Bombardino"]:GetChildren() do
				if child.Name ~= "RootPart" then
					child.Transparency = 0
				end
			end
		end)
		v[parent.Name] = clone
		table.insert(parents, parent)
		return function()
			local index = table.find(parents, parent)

			if index then
				table.remove(parents, index)
			end

			clone:Destroy()
			v[parent.Name] = nil

			if coroutine.status(thread) == "suspended" then
				pcall(task.cancel, thread)
			end
		end
	end))
	maid:Add(RunService.PreRender:Connect(function(_)
		debug.profilebegin("Bombardiro Crocodilo:BulkMoveTo")
		local primaryParts = {}
		local cFrames = {}

		for _, v3 in parents do
			local v4 = v[v3.Name]

			if not v4 then
				continue
			end

			table.insert(primaryParts, v4.PrimaryPart)
			table.insert(cFrames, v3.CFrame)
		end

		workspace:BulkMoveTo(primaryParts, cFrames, Enum.BulkMoveMode.FireCFrameChanged)
		debug.profileend()
	end))
end

function BombardiroCrocodilo.OnStop(_)
	maid:Destroy()
end

function BombardiroCrocodilo.OnLoad(_)
	local function playExplosion(cFrame: CFrame, value: string?)
		local clone = script[value or "Explosion"]:Clone()
		clone.CFrame = cFrame
		clone.Parent = workspace
		VFX.emit(clone)
		task.delay(5, function()
			clone:Destroy()
		end)
	end

	remoteEvent.OnClientEvent:Connect(function(p: string, position: Vector3, vector2: Vector3)
		local v2 = v[p]

		if v2 and v2:FindFirstChild("Svinina Bombardino") then
			for _, child in v2["Svinina Bombardino"]:GetChildren() do
				if child.Name == "RootPart" then
					continue
				end

				child.Transparency = 1
				local v3 = child
				task.delay(1, function()
					v3.Transparency = 0
				end)
			end
		end

		local clone = svininaBombardino:Clone()
		clone.PrimaryPart.Anchored = true
		clone:PivotTo(CFrame.new(position))
		local clone2 = ReplicatedStorage.Sounds.Events["Bombardiro Crocodilo"].DroppingBomb:Clone()
		clone2.Parent = clone
		clone.Parent = workspace
		clone2:Play()
		local total = 0
		local timeToGround = MathUtils.calculateTimeToGround(position.y, vector2.y)
		local postSimulationConnection = nil
		postSimulationConnection = RunService.PostSimulation:Connect(function(dt)
			debug.profilebegin("Bombardiro Crocodilo:Bomb")
			total += dt
			local v3 = total / timeToGround
			clone:PivotTo(CFrame.new(position - vector.create(0, MathUtils.simulateGravity(total), 0)) * CFrame.Angles(
				-total * 3.141592653589793 * 2,
				0,
				0
			))
			debug.profileend()

			if v3 >= 1 then
				postSimulationConnection:Disconnect()

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("BasePart") then
						descendant.Transparency = 1
					elseif descendant:IsA("ParticleEmitter") then
						descendant:Destroy()
					end
				end

				task.wait(3)
				clone:Destroy()
			end
		end)
	end)
	remoteEvent2.OnClientEvent:Connect(function(cframe, p)
		if typeof(cframe) ~= "CFrame" then
			cframe = CFrame.new(cframe)
		end

		playExplosion(cframe, p)
	end)
end

return BombardiroCrocodilo