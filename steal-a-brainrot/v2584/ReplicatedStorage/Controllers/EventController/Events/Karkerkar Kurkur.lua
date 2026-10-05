local createVector = vector.create
game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ContentProvider")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Shared.EventTypes)
local KarkerkarKurkur = {}
local EncryptedAssetsController = require(ReplicatedStorage.Controllers.EncryptedAssetsController)
local EffectController = require(ReplicatedStorage.Controllers.EffectController)
require(ReplicatedStorage.Controllers.AnimalController)
local SoundController = require(ReplicatedStorage.Controllers.SoundController)
local CycleController = require(ReplicatedStorage.Controllers.CycleController)
local EventController = require(ReplicatedStorage.Controllers.EventController)
local ClientEventUtils = require(ReplicatedStorage.Controllers.EventController.ClientEventUtils)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Shared.MapInformation)
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Utils.MathUtils)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local VFX = require(ReplicatedStorage.Shared.VFX)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
require(ReplicatedStorage.Shared.Snapshot)
local localPlayer = Players.LocalPlayer
local karkerkarKurkur = ReplicatorClient.get("KarkerkarKurkur")
local name = script.Name
local karkerMusic = SoundService.Cutscene.WorkspaceSounds.KarkerMusic
local remoteEvent = Net:RemoteEvent("EventService/Karkerkar Kurkur/Spawn")
local maid = Trove.new()

local function initActivationVisual()
	local maid2 = maid:Extend()
	local v = table.create(4)
	maid2:Add(function()
		table.clear(v)
	end)
	local total = 0
	maid2:Add(RunService.PreRender:Connect(function(dt: number)
		debug.profilebegin("Karkerkar Kurkur Event")
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
	maid2:Add(Observers.observeTag("KarkerkarKurkurPlayerVFX", function(parent)
		local clone = script.PlayerVFX.Beam:Clone()
		clone.Parent = parent
		local clone2 = script.PlayerVFX.Torso:Clone()
		clone2.Parent = parent
		local karkerkarKurkurIndex = parent:GetAttribute("KarkerkarKurkurIndex")
		v[karkerkarKurkurIndex] = {
			beam = clone,
			target = nil
		}
		local v2 = Observers.observeTag("KarkerkarKurkurPlayerVFX", function(target)
			if not (target ~= parent and target:GetAttribute("KarkerkarKurkurIndex") == parent:GetAttribute("KarkerkarKurkurIndex") % 4 + 1) then
				return nil
			end

			local attachment = Instance.new("Attachment")
			attachment.Position = clone.WorldPosition
			attachment.Parent = workspace.Terrain
			local v3 = v[parent:GetAttribute("KarkerkarKurkurIndex")]
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
			v[karkerkarKurkurIndex] = nil
		end
	end))
end

function KarkerkarKurkur.OnStart(_)
	local activeEventData = EventController:GetActiveEventData(name)
	assert(activeEventData)
	maid:Add(function()
		EffectController:Activate("Blink")
		CycleController:Update()
		SoundController:UpdateOST()
		SoundController:UpdateAmbience()
	end)
	CycleController:Update()
	SoundController:UpdateOST()
	SoundController:UpdateAmbience()
	local v = maid:Add(Instance.new("Sound"))
	v.RollOffMode = Enum.RollOffMode.InverseTapered
	v.RollOffMinDistance = 35
	v.RollOffMaxDistance = 175
	v.Looped = true
	v.SoundId = "rbxassetid://124977112693561"
	v.Volume = 0.15
	v.SoundGroup = karkerMusic
	local clone = maid:Clone(ReplicatedStorage.Sounds.Events["Karkerkar Kurkur"]["Music Box"])
	local v2 = maid:Add(Instance.new("Sound"))
	v2.SoundId = "rbxassetid://124977112693561"
	v2.Volume = 0
	v2.SoundGroup = karkerMusic
	v2.Looped = true
	v2.Parent = SoundService
	maid:Add(v:GetPropertyChangedSignal("TimePosition"):Connect(function()
		v2.TimePosition = v.TimePosition
	end))
	karkerMusic:SetAttribute("Paused", false)
	karkerMusic.Volume = 1
	maid:Add(task.delay(activeEventData.startedAt + 4 - workspace:GetServerTimeNow(), function()
		local karkerkarKurkurEventCFrame = ReplicatedStorage:GetAttribute("KarkerkarKurkurEventCFrame") or workspace.Events["Karkerkar Kurkur"].MapCenterGround.Position
		local clone2 = maid:Clone(script.AreaVFX)
		clone2:PivotTo(CFrame.new(karkerkarKurkurEventCFrame))
		clone2.Parent = workspace

		if ServerData.IsBiggerServer() then
			ClientEventUtils.resizeEffects(clone2, 2)
		end

		local isPaused = false

		local function updatePromptsState()
			local v3 = isPaused and not localPlayer:GetAttribute("KarkerkarKurkurEventSeated")

			for _, v4 in CollectionService:GetTagged("KarkerkarSitPrompt") do
				v4.Enabled = not (v3 and v4:GetAttribute("Taken")) and v3
			end
		end

		local function updateState()
			local v3 = karkerkarKurkur:TryIndex({ "state" })

			if not v3 or next(v3) == nil then
				isPaused = false
				return
			end

			local serverTimeNow = workspace:GetServerTimeNow()

			if v3.StateChangeTime <= serverTimeNow then
				v3.IsPaused = not v3.IsPaused
			end

			isPaused = v3.IsPaused
			updatePromptsState()
			local timePosition = (v3.ElapsedSoundTime + (serverTimeNow - v3.ReplicationTime)) % v.TimeLength

			if v3.IsPaused then
				if not karkerMusic:GetAttribute("Paused") then
					karkerMusic:SetAttribute("Paused", true)
					VFX.disable(clone2.Area)
					CreateTween(karkerMusic, TweenInfo.new(1), {
						Volume = 0
					})

					if clone then
						clone:Play()
					end
				end
			elseif karkerMusic:GetAttribute("Paused") then
				karkerMusic:SetAttribute("Paused", false)
				VFX.enable(clone2.Area)
				v.TimePosition = timePosition
				v2.TimePosition = timePosition
				CreateTween(karkerMusic, TweenInfo.new(1), {
					Volume = 1
				})

				if clone then
					clone:Stop()
				end
			end
		end

		maid:Add(karkerkarKurkur:Listen({ "state" }, updateState))
		maid:Add(localPlayer:GetAttributeChangedSignal("KarkerkarKurkurEventSeated"):Connect(updatePromptsState))
		maid:Add(Timer.Simple(0.1, updateState, true))
		maid:Add(Observers.observeTag("KarkerkarSitPrompt", function(object)
			updatePromptsState()
			local takenChangedConnection = object:GetAttributeChangedSignal("Taken"):Connect(updatePromptsState)
			return function()
				takenChangedConnection:Disconnect()
				updatePromptsState()
			end
		end, { workspace }))
		maid:Add(task.spawn(function()
			EncryptedAssetsController:WaitForAssetId("rbxassetid://124977112693561")
			v.SoundId = "rbxassetid://124977112693561"
			v2.SoundId = "rbxassetid://124977112693561"
			local parent = maid:Add(Instance.new("Part"))
			parent.Transparency = 1
			parent.CFrame = CFrame.new(karkerkarKurkurEventCFrame) + createVector(0, 5, 0)
			parent.Anchored = true
			parent.CanCollide = false
			parent.CanQuery = false
			parent.CanTouch = false
			parent.Parent = workspace
			clone.Parent = parent
			v.Parent = parent
			os.clock()

			while not v.IsLoaded do
				task.wait()
			end

			task.spawn(updateState)
			v:Play()

			while not v2.IsLoaded do
				task.wait()
			end

			v2:Play()
		end))
		maid:Add(task.spawn(updatePromptsState))
		local v3 = {}
		local positions = {}
		local v4 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function addAttachment(p, p2: string)
			if not table.find(v3, p) then
				v4[p] = p2
				positions[p] = p.Position
				table.insert(v3, p)
			end
		end

		for k, folder in { clone2.Visualizer1, clone2.Visualizer2 } do
			for _, beam in folder:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				local v5 = k == 1 and "Inner" or "Outer"
				addAttachment(beam.Attachment0, v5) -- equivalent call inferred; original call site unknown
				addAttachment(beam.Attachment1, v5) -- equivalent call inferred; original call site unknown
			end
		end

		local v5 = 0
		maid:Add(RunService.PreRender:Connect(function(dt: number)
			debug.profilebegin("Karkerkar Kurkur Musical Chairs Event")
			clone2.Area.Spin.CFrame *= CFrame.fromOrientation(0, dt * 0.7853981633974483, 0)

			for _, child in clone2.Area.Spin:GetChildren(), nil, nil do
				local name2 = tonumber(child.Name) or 0
				child.Position = Vector3.new(
					child.Position.X,
					-(math.sin((os.clock() + name2) * 2) * 3 + 4.5),
					child.Position.Z
				)
			end

			local v6 = math.clamp(karkerMusic.Volume / 1, 0, 1)
			local v7 = math.clamp(v2.PlaybackLoudness / 400, 0, 1) * v6
			v5 = v7 + (v5 - v7) * math.exp(dt * -10)
			local v8 = math.lerp(-18, -7, v6)

			for _, v9 in v3 do
				local v10 = v4[v9] == "Outer" and 4.353 or 3.9
				local v11 = positions[v9]
				v9.Position = Vector3.new(v11.X, math.lerp(v8, v10, v5), v11.Z)
			end

			debug.profileend()
		end))
	end))
	maid:Add(task.spawn(function()
		initActivationVisual()
	end))
end

function KarkerkarKurkur.OnStop(_)
	maid:Destroy()
end

function KarkerkarKurkur.OnLoad(_)
	remoteEvent.OnClientEvent:Connect(function(cframe: CFrame)
		local clone = script.SpawnVFX:Clone()
		clone:PivotTo(cframe + createVector(0, 0.05, 0))
		clone.Parent = workspace
		VFX.emit(clone)
		task.delay(7, function()
			clone:Destroy()
		end)
		task.delay(2, function()
			SoundController:PlaySound(ReplicatedStorage.Sounds.Events["Karkerkar Kurkur"].Spawn, cframe.Position, false)
		end)
	end)
end

return KarkerkarKurkur