local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local Water = {}
require(ReplicatedStorage.Controllers.TsunamiEventController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
require(ReplicatedStorage.Shared.Snapshot)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Water/Burst")
local maid = Trove.new()
local v = {}

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v2 = table.create(4)
	maid2:Add(function()
		table.clear(v2)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Water Event")
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
	maid2:Add(Observers.observeTag("WaterPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local waterIndex = parent:GetAttribute("WaterIndex")
		v2[waterIndex] = {
			beam = clone,
			target = nil
		}
		local v3 = Observers.observeTag("WaterPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("WaterIndex") == parent:GetAttribute("WaterIndex") % 4 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v4 = v2[parent:GetAttribute("WaterIndex")]
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
			v2[waterIndex] = nil
		end
	end))
end

local function createSharks()
	local parents = {}
	maid:Add(Observers.observeTag("WaterShark", function(parent)
		local sharkType = parent:GetAttribute("SharkType") or "Orcalero Orcala"
		local v2 = script[sharkType]
		local clone = v2:Clone()
		clone.PrimaryPart.Anchored = true
		clone.Parent = parent
		local orcaleroSwim

		if v2 == script["Orcalero Orcala"] then
			orcaleroSwim = script.OrcaleroSwim
		else
			orcaleroSwim = script.TralaleroSwim
		end

		local orcaleroAttack

		if v2 == script["Orcalero Orcala"] then
			orcaleroAttack = script.OrcaleroAttack
		else
			orcaleroAttack = script.TralaleroAttack
		end

		local track = clone.AnimationController.Animator:LoadAnimation(orcaleroSwim)
		track.Priority = Enum.AnimationPriority.Action
		local track2 = clone.AnimationController.Animator:LoadAnimation(orcaleroAttack)
		track2.Priority = Enum.AnimationPriority.Action4
		track2.Looped = false
		track:Play()

		local function fn()
			track:Stop(0)
			track:Destroy()
			track2:Stop(0)
			track2:Destroy()
		end

		local attackChangedConnection = parent:GetAttributeChangedSignal("Attack"):Connect(function()
			track2:Play()
		end)
		v[parent.Name] = clone
		table.insert(parents, parent)
		return function()
			local index = table.find(parents, parent)

			if index then
				table.remove(parents, index)
			end

			attackChangedConnection:Disconnect()
			clone:Destroy()
			v[parent.Name] = nil

			if type(fn) == "function" then
				fn()
				fn = nil
			end
		end
	end))
	maid:Add(RunService.PreRender:Connect(function(_)
		debug.profilebegin("WaterEvent:Update Sharks")
		local primaryParts = {}
		local cFrames = {}

		for _, v2 in parents do
			local v3 = v[v2.Name]

			if not v3 then
				continue
			end

			table.insert(primaryParts, v3.PrimaryPart)
			table.insert(cFrames, v2.CFrame)
		end

		workspace:BulkMoveTo(primaryParts, cFrames, Enum.BulkMoveMode.FireCFrameChanged)
		debug.profileend()
	end))
end

function Water.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("WaterEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("WaterEvent", nil)
		EffectController:Activate("Blink")
		EffectController:Stop(name, "GrassRecolor")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	maid:Add(task.delay(activeEventData.startedAt + 4 - workspace:GetServerTimeNow(), function()
		EffectController:Activate("Blink")
		local v2 = maid:Add(Instance.new("ColorCorrectionEffect"))
		v2.Brightness = 0.15
		v2.Contrast = 0.1
		v2.Saturation = -0.1
		v2.TintColor = Color3.fromRGB(113, 186, 234)
		v2.Parent = workspace.CurrentCamera
		local clone_2 = maid:Clone(script.Water)
		clone_2.Parent = workspace
		EffectController:Run(name, "GrassRecolor")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
		createSharks()
		maid:Add(Observers.observeCharacters(function(_, p)
			return Observers.observeChildren(p, function(parent)
				if parent.Name ~= "UpperTorso" then
					return nil
				end

				local clones = {}

				for _, child in script.PlayerBubbles:GetChildren() do
					local clone = child:Clone()
					clone.Parent = parent
					table.insert(clones, clone)
				end

				local v3 = Observers.observeChildren(p, function(humanoid)
					if not humanoid:IsA("Humanoid") then
						return nil
					end

					local moveDirectionChangedConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
						local enabled = humanoid.MoveDirection ~= createVector(0, 0, 0)

						for _, v5 in clones do
							v5.Enabled = enabled
						end
					end)
					return function()
						moveDirectionChangedConnection:Disconnect()
					end
				end)
				return function()
					for _, v4 in clones do
						v4:Destroy()
					end

					table.clear(clones)
					v3()
				end
			end)
		end))

		if not ServerData.IsJumpLTMServer() then
			maid:Add(function()
				workspace.Gravity = 196.2
			end)
			maid:Add(RunService.PostSimulation:Connect(function(_)
				debug.profilebegin("Water:Gravity")
				workspace.Gravity = 29.429999999999996
				debug.profileend()
			end))
		end
	end))
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
end

function Water.OnStop(_)
	maid:Destroy()
end

function Water.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(p: string, p2: string, vector2: Vector3?)
		local v2 = v[p]

		if v2 then
			v2.Parent:SetAttribute("Attack", not v2.Parent:GetAttribute("Attack"))
		end

		ClientEventUtils.playBurst(
			script.Burst,
			vector2 or p2,
			{ ReplicatedStorage.Sounds.Events.Water["Brainrot Hit"] }
		)
	end)
end

return Water