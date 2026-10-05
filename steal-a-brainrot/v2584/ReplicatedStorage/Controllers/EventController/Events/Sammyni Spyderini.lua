local createVector = vector.create
game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Shared.EventTypes)
local SammyniSpyderini = {}
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
require(ReplicatedStorage.Shared.TweenPivot)
local Observers = require(ReplicatedStorage.Packages.Observers)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Utils.MathUtils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Shared.VFX)
local MapInformation = require(ReplicatedStorage.Shared.MapInformation)
require(ReplicatedStorage.Shared.Snapshot)
local name = script.Name
local remoteEvent = Net:RemoteEvent("EventService/Sammyni Spyderini/Burst")
local maid = Trove.new()
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map"), workspace:WaitForChild("Plots") }

local function createHole(position: Vector3, duration: number)
	local raycastResult = workspace:Raycast(position, createVector(-0, -25, -0), raycastParams)

	if raycastResult then
		position = raycastResult.Position
	end

	local clone = script.Hole:Clone()
	clone.CFrame = CFrame.new(position + createVector(0, 0.01, 0)) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Size = createVector(0.01, 0.01, 0.01)
	clone.Parent = workspace
	CreateTween(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = createVector(0.01, 8, 8)
	})
	task.delay(duration, function()
		CreateTween(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = createVector(0.01, 0.01, 0.01)
		}).Completed:Wait()
		clone:Destroy()
	end)
end

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v = table.create(4)
	maid2:Add(function()
		table.clear(v)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Sammyni Spyderini Event")
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
	maid2:Add(Observers.observeTag("SammyniSpyderiniPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local sammyniSpyderiniIndex = parent:GetAttribute("SammyniSpyderiniIndex")
		v[sammyniSpyderiniIndex] = {
			beam = clone,
			target = nil
		}
		local v2 = Observers.observeTag("SammyniSpyderiniPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("SammyniSpyderiniIndex") == parent:GetAttribute("SammyniSpyderiniIndex") % 4 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v3 = v[parent:GetAttribute("SammyniSpyderiniIndex")]
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
			v2()
			v[sammyniSpyderiniIndex] = nil
		end
	end))
end

function SammyniSpyderini.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	ReplicatedStorage:SetAttribute("SammyniSpyderiniEvent", true)
	maid:Add(function()
		ReplicatedStorage:SetAttribute("SammyniSpyderiniEvent", nil)
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	maid:Add(Observers.observeTag("SammyniSpyderini", function(parent)
		local maid2 = Trove.new()
		local humanoidRootPart = parent:WaitForChild("HumanoidRootPart")
		local clone = maid2:Clone(script["Sammyni Spyderini"])
		local v = maid2:Add(Instance.new("Weld"))
		v.Part0 = clone.PrimaryPart
		v.Part1 = humanoidRootPart
		v.C0 = CFrame.Angles(0, 3.141592653589793, 0)
		v.Parent = clone.PrimaryPart
		clone.Parent = parent
		local animator = clone.AnimationController.Animator
		local track = animator:LoadAnimation(script.Idle)
		track.Priority = Enum.AnimationPriority.Idle
		local track2 = animator:LoadAnimation(script.Walk)
		track2.Priority = Enum.AnimationPriority.Movement
		local track3 = animator:LoadAnimation(script.Attack)
		local track4 = animator:LoadAnimation(script.Ground)
		track4.Looped = true
		local track5 = animator:LoadAnimation(script.InitialGround)
		track5.Looped = true
		local track6 = animator:LoadAnimation(script.Jump)
		track:Play()
		maid2:Add(track4:GetMarkerReachedSignal("Freeze"):Connect(function()
			track4:AdjustSpeed(0)
		end))
		maid2:Add(track5:GetMarkerReachedSignal("Freeze"):Connect(function()
			track5:AdjustSpeed(0)
		end))
		local flag = nil

		local function updateGround()
			if parent:GetAttribute("InitialGround") then
				flag = true
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Sammyni Spyderini"].EnterHole,
					humanoidRootPart.Position,
					false
				)
				createHole(humanoidRootPart.Position, 1.5)

				if not track5.IsPlaying then
					track5:Play()
				end
			elseif parent:GetAttribute("Ground") then
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Sammyni Spyderini"].EnterHole,
					humanoidRootPart.Position,
					false
				)
				createHole(humanoidRootPart.Position, 1.5)

				if not track4.IsPlaying then
					if flag then
						track4.TimePosition = 0.6
					end

					track4:Play(flag and 0 or nil)

					if flag then
						track4.TimePosition = 0.6
					end
				end

				flag = false
			else
				flag = false
				SoundController:PlaySound(
					ReplicatedStorage.Sounds.Events["Sammyni Spyderini"].LeaveHole,
					humanoidRootPart.Position,
					false
				)
				createHole(humanoidRootPart.Position, 1.5)
				track6:Play()
				track4:Stop()
				track5:Stop()
			end
		end

		maid2:Add(task.defer(function()
			if parent:GetAttribute("IsRunning") then
				track2:Play()
			end
		end))
		maid2:Add(parent:GetAttributeChangedSignal("IsRunning"):Connect(function()
			if parent:GetAttribute("IsRunning") then
				track2:Play()
			else
				track2:Stop()
			end
		end))

		if parent:GetAttribute("Ground") and not track4.IsPlaying then
			track4.TimePosition = 0.6
			track4:Play(0)
			track4.TimePosition = 0.6
		end

		maid2:Add(parent:GetAttributeChangedSignal("Ground"):Connect(updateGround))
		maid2:Add(parent:GetAttributeChangedSignal("InitialGround"):Connect(updateGround))
		maid2:Add(parent:GetAttributeChangedSignal("AttackAnimation"):Connect(function()
			track3:Play()
		end))
		return maid2:WrapClean()
	end))
	local v = activeEventData.startedAt + 5 - workspace:GetServerTimeNow()
	maid:Add(task.delay(v, function()
		if v > 1 then
			SoundController:PlaySound(
				ReplicatedStorage.Sounds.Events["Sammyni Spyderini"].Expanding,
				MapInformation.MapCenter.Position,
				false
			)
		end

		local clones = {}

		if not ServerData.IsJumpLTMServer() then
			if ServerData.IsBiggerServer() then
				for _, child in script.WebBigger:GetChildren() do
					table.insert(clones, (maid:Clone(child)))
				end
			else
				clones = { maid:Clone(script.Web_Main) }
			end
		end

		for _, folder in clones do
			local mapCenter = folder:FindFirstChild("MapCenter") or MapInformation.MapCenter

			for _, child in folder.Lines:GetChildren() do
				local size = child.Size
				child.Size = createVector(0, 1, 1)
				CreateTween(
					child,
					TweenInfo.new(size.Magnitude / 150, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
					{
						Size = size
					}
				)
			end

			for _, part in folder:GetDescendants() do
				if part:IsDescendantOf(folder.Lines) or not part:IsA("BasePart") then
					continue
				end

				local size = part.Size
				part.Size = createVector(0, 1, 1)
				local transparency = part.Transparency
				part.Transparency = 1
				local v2 = ((part.Position - mapCenter.Position) * createVector(1, 0, 1)).Magnitude * 2 / 150
				local v3 = part
				task.delay(v2, function()
					v3.Transparency = transparency
				end)
				CreateTween(part, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, v2), {
					Size = size
				})
			end

			folder.Parent = workspace
		end

		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end))
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
end

function SammyniSpyderini.OnStop(_)
	maid:Destroy()
end

function SammyniSpyderini.OnLoad(_)
	task.spawn(pcall, function()
		ContentProvider:PreloadAsync(script:GetChildren())
	end)
	remoteEvent.OnClientEvent:Connect(function(p: string)
		ClientEventUtils.playBurst(script.Burst, p, { ReplicatedStorage.Sounds.Events["Sammyni Spyderini"].Hit })
	end)
end

return SammyniSpyderini