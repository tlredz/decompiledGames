local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local adminAbuse = ReplicatedStorage:WaitForChild("AdminAbuse")
local PartyEvent = require(adminAbuse:WaitForChild("PartyEvent"))
local SharedSyncedEvent = require(adminAbuse:WaitForChild("SharedSyncedEvent"))
local VariantBattleLeaderboardUI = require(adminAbuse:WaitForChild("Modules"):WaitForChild("Shared"):WaitForChild("VariantBattleLeaderboardUI"))
local EventsConfig = require(ReplicatedStorage:WaitForChild("EventsConfig"))
local Janitor = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("Janitor"))
local slapBattle = EventsConfig.SlapBattle
local localPlayer = Players.LocalPlayer
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function formatClock(p: number)
	local v2 = math.max(0, (math.floor(p)))
	return string.format("%d:%02d", math.floor(v2 / 60), v2 % 60)
end

local function getLiveCharacter()
	local character = localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if character and humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return character, humanoidRootPart
	end

	return nil, nil
end

local function getHitRemote()
	local remotes = adminAbuse:FindFirstChild("Remotes")
	local remoteEvent = remotes and remotes:FindFirstChild(slapBattle.HitRemoteName)

	if remoteEvent and remoteEvent:IsA("RemoteEvent") then
		return remoteEvent
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSwingSound(parent)
	local sound = Instance.new("Sound")
	sound.SoundId = slapBattle.SwingSoundId
	sound.Volume = slapBattle.SwingSoundVolume
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.RollOffMinDistance = 10
	sound.RollOffMaxDistance = 150
	sound.Parent = parent
	sound:Play()
	Debris:AddItem(sound, 4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getHitCenter(instance)
	return instance.Position + instance.CFrame.LookVector * slapBattle.SwingDistanceStuds
end

local function findTarget(_, humanoidRootPart)
	local hitCenter = getHitCenter(humanoidRootPart) -- equivalent call inferred; original call site unknown
	local v2 = 1e999
	local v3 = nil

	for _, v4 in Players:GetPlayers() do
		local character = v4.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart2 = character and character:FindFirstChild("HumanoidRootPart")

		if not (v4 ~= localPlayer and humanoid and humanoid.Health > 0 and humanoidRootPart2) then
			continue
		end

		if not humanoidRootPart2:IsA("BasePart") then
			continue
		end

		local magnitude = (humanoidRootPart2.Position - hitCenter).Magnitude

		if not (magnitude <= slapBattle.SlapHitRadiusStuds and magnitude < v2) then
			continue
		end

		v3 = v4
		v2 = magnitude
	end

	return v3
end

local function setToolHidden(folder, flag: boolean)
	local localTransparencyModifier = flag and 1 or 0

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = localTransparencyModifier
		end
	end
end

local function getSwingLookPart(instance)
	local parent = instance.Parent
	local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart
	end

	local handle = instance:FindFirstChild("Handle")

	if handle and handle:IsA("BasePart") then
		return handle
	end

	return nil
end

local function collectSwingClones(folder, folder2)
	local result = {}

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone = part:Clone()
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Massless = true
		clone.Parent = folder2
		local meshes = {}

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("Weld") or descendant:IsA("Motor6D") or descendant:IsA("WeldConstraint") then
				descendant:Destroy()
			elseif descendant:IsA("DataModelMesh") then
				table.insert(meshes, {
					mesh = descendant,
					scale = descendant.Scale
				})
			end
		end

		table.insert(result, {
			source = part,
			clone = clone,
			size = part.Size,
			meshes = meshes
		})
	end

	return result
end

local function animateTool(p, folder)
	local v2 = v[folder]

	if v2 then
		v2:Cleanup()
	end

	local folder2 = Instance.new("Folder")
	folder2.Name = "GloveSwingVisual"
	folder2.Parent = workspace.CurrentCamera
	local v3 = collectSwingClones(folder, folder2)

	if #v3 == 0 then
		folder2:Destroy()
		return
	end

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 1
		end
	end

	local numberValue = Instance.new("NumberValue")
	local numberValue2 = Instance.new("NumberValue")
	numberValue.Value = 0
	numberValue2.Value = 1

	local function applyVisual()
		local v4 = folder
		local parent = v4.Parent
		local humanoidRootPart = parent and parent:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
			humanoidRootPart = v4:FindFirstChild("Handle")

			if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end
		end

		local v5 = not humanoidRootPart and createVector(0, 0, 0) or humanoidRootPart.CFrame.LookVector * numberValue.Value
		local value = numberValue2.Value

		for _, v6 in v3 do
			if not v6.source.Parent then
				continue
			end

			v6.clone.CFrame = v6.source.CFrame + v5
			v6.clone.Size = v6.size * value

			for _, mesh in v6.meshes do
				mesh.mesh.Scale = mesh.scale * value
			end
		end
	end

	local tweenInfo = TweenInfo.new(slapBattle.SwingOutSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfo2 = TweenInfo.new(slapBattle.SwingReturnSeconds, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = slapBattle.SwingDistanceStuds
	})
	local tween2 = TweenService:Create(numberValue2, tweenInfo, {
		Value = slapBattle.SwingScale
	})
	local tween3 = TweenService:Create(numberValue, tweenInfo2, {
		Value = 0
	})
	local tween4 = TweenService:Create(numberValue2, tweenInfo2, {
		Value = 1
	})
	local renderSteppedConnection = RunService.RenderStepped:Connect(applyVisual)
	local maid = Janitor.new()
	maid:Add(folder2)
	maid:Add(numberValue)
	maid:Add(numberValue2)
	maid:Add(renderSteppedConnection)
	maid:Add(tween)
	maid:Add(tween2)
	maid:Add(tween3)
	maid:Add(tween4)
	maid:Add(tween.Completed:Connect(function()
		tween3:Play()
		tween4:Play()
	end))
	maid:Add(tween4.Completed:Connect(function()
		maid:Cleanup()
	end))
	maid:Add(function()
		if v[folder] == maid then
			v[folder] = nil
		end

		for _, part in folder:GetDescendants() do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end)
	p.janitor:Add(maid, "Cleanup")
	v[folder] = maid
	applyVisual()
	tween:Play()
	tween2:Play()
end

local v2 = PartyEvent.new({
	DisplayName = slapBattle.DisplayName,
	NeedsDuration = slapBattle.NeedsDuration,
	MaxDurationSeconds = slapBattle.MaxDurationSeconds,
	DefaultDurationSeconds = slapBattle.DefaultDurationSeconds,
	RequiresRespawnRefire = false,
	SkipDoorTransition = slapBattle.SkipDoorTransition,
	IsAdminAbuse = slapBattle.IsAdminAbuse,
	Sounds = slapBattle.Sounds
})

function v2:OnStart(p, p2, _, _)
	self._board = VariantBattleLeaderboardUI.new({
		title = string.upper(slapBattle.DisplayName),
		accentColor = Color3.fromRGB(255, 94, 126),
		secondaryColor = Color3.fromRGB(168, 86, 255),
		scoreLabel = slapBattle.ScoreLabel,
		icon = "rbxassetid://85427441661020"
	})
	self._leaderboard = {}
	self._phase = "running"
	self._combatEndsAt = nil
	local v3 = SharedSyncedEvent.new(slapBattle.SyncChannelName)
	v3:onChange("Leaderboard", function(leaderboard)
		if type(leaderboard) == "table" then
			self._leaderboard = leaderboard
			self._board:Update(leaderboard, localPlayer.UserId)
		end
	end)
	v3:onChange("Phase", function(phase)
		if type(phase) == "string" then
			self._phase = phase
		end
	end)
	v3:onChange("CombatEndsAt", function(combatEndsAt)
		if type(combatEndsAt) == "number" then
			self._combatEndsAt = combatEndsAt
		end
	end)
	v3:onFire("Notify", function(value)
		if type(value) == "string" then
			local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
			NotificationSystem:ShowGeneralNotification(value, Color3.fromRGB(255, 185, 80))
		end
	end)
	v3:onFire("ItemReward", function(data)
		if type(data) ~= "table" or data.userId ~= localPlayer.UserId or type(data.itemKey) ~= "string" then
			return
		end

		local rank

		if type(data.rank) == "number" then
			rank = data.rank
		end

		local v4

		if rank then
			v4 = string.format("Top %d!", rank)
		end

		local ItemRewardUISystem = require(ReplicatedStorage:WaitForChild("ItemRewardUISystem"))
		ItemRewardUISystem.playForItemKey(data.itemKey, v4, (tonumber(data.tier)))
	end)
	v3:onFire("SlapSwing", function(p3)
		if type(p3) ~= "table" then
			return
		end

		local attackerUserId = p3.attackerUserId

		if type(attackerUserId) ~= "number" or attackerUserId == localPlayer.UserId then
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(attackerUserId)
		local character = playerByUserId and playerByUserId.Character
		local tool = character and character:FindFirstChild(slapBattle.ToolName)

		if tool and tool:IsA("Tool") then
			animateTool(p, tool)
		end
	end)
	local v4 = {}
	local v5 = 0

	local function bindTool(tool)
		if not tool:IsA("Tool") or tool.Name ~= slapBattle.ToolName or v4[tool] then
			return
		end

		v4[tool] = true
		p.janitor:Add(tool.Activated:Connect(function()
			local now = os.clock()

			if now - v5 < slapBattle.SlapCooldownSeconds then
				return
			end

			v5 = now
			animateTool(p, tool)
			local handle = tool:FindFirstChild("Handle")
			local character = localPlayer.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if not (character and humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
				humanoidRootPart = nil
			end

			if handle and handle:IsA("BasePart") then
				playSwingSound(handle) -- equivalent call inferred; original call site unknown
			elseif humanoidRootPart then
				playSwingSound(humanoidRootPart) -- equivalent call inferred; original call site unknown
			end

			local character2 = localPlayer.Character
			local humanoidRootPart2 = character2 and character2:FindFirstChild("HumanoidRootPart")

			if not (character2 and humanoidRootPart2 and humanoidRootPart2:IsA("BasePart")) then
				character2 = nil
				humanoidRootPart2 = nil
			end

			local remotes = adminAbuse:FindFirstChild("Remotes")
			local remoteEvent = remotes and remotes:FindFirstChild(slapBattle.HitRemoteName)

			if not (remoteEvent and remoteEvent:IsA("RemoteEvent")) then
				remoteEvent = nil
			end

			if self._activeSession == p and character2 and humanoidRootPart2 and remoteEvent then
				local target = findTarget(character2, humanoidRootPart2)
				remoteEvent:FireServer(not target and 0 or target.UserId)
			end
		end))
	end

	local backpack = localPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, child in backpack:GetChildren() do
			bindTool(child)
		end

		p.janitor:Add(backpack.ChildAdded:Connect(bindTool))
	end

	local maid = Janitor.new()

	local function bindCharacter(instance)
		maid:Cleanup()

		for _, child in instance:GetChildren() do
			bindTool(child)
		end

		maid:Add(instance.ChildAdded:Connect(bindTool))
	end

	bindCharacter(p2)
	p.janitor:Add(self._board, "Destroy")
	p.janitor:Add(v3, "destroy")
	p.janitor:Add(maid, "Cleanup")
	p.janitor:Add(localPlayer.CharacterAdded:Connect(bindCharacter))
end

function v2:OnRender(_, _: number, _, _, _)
	if not self._board then
		return
	end

	if self._phase == "running" and type(self._combatEndsAt) == "number" then
		self._board:SetPhaseText("Time left  " .. formatClock(self._combatEndsAt - workspace:GetServerTimeNow()))
	elseif self._phase == "ended" then
		self._board:SetPhaseText("Results")
	end
end

function v2:OnStop(_)
	self._board = nil
	self._leaderboard = nil
	self._phase = nil
	self._combatEndsAt = nil
end

function v2:Fire(...)
	if self._activeSession then
		return
	end

	PartyEvent.Fire(self, ...)
end

return v2