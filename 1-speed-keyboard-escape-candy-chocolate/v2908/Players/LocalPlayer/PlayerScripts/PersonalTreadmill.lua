local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local UpgradeMultipliers = require(ReplicatedStorage._FRAMEWORK.Libraries.UpgradeMultipliers)
local NotificationSystem = require(ReplicatedStorage:WaitForChild("NotificationSystem"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local SoundManager = require(ReplicatedStorage:WaitForChild("SoundManager"))
local PersonalTreadmill2 = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("PersonalTreadmill"))
local localPlayer = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local personalTreadmillStep = remotes:WaitForChild("PersonalTreadmillStep")
local personalTreadmillSync = remotes:WaitForChild("PersonalTreadmillSync")
local treadmillSignal = remotes:WaitForChild("TreadmillSignal")
local v = false
local pos = nil
local mult = 1
local v2 = 0
local v3 = false

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutBack(p: number)
	return (p - 1) ^ 3 * 2.70158 + 1 + (p - 1) ^ 2 * 1.70158
end

local function playBounce(model)
	local scale = model:GetScale()
	model:ScaleTo(scale * 0.5)
	local total = 0

	while total < 0.3 do
		total += RunService.Heartbeat:Wait()
		model:ScaleTo(scale * (easeOutBack(math.clamp(total / 0.3, 0, 1)) * 0.5 + 0.5))
	end

	model:ScaleTo(scale)
end

local object = setmetatable({}, {
	__mode = "k"
})

local function handleMat(model)
	if not model:IsA("Model") or object[model] then
		return
	end

	object[model] = true
	print(model)
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyCollision(part)
		if v4 and part:IsA("BasePart") then
			part.CanCollide = true
		end
	end

	local function refreshOwner()
		v4 = model:GetAttribute("OwnerUserId") == localPlayer.UserId
		print(v4)

		if v4 then
			for _, descendant in ipairs(model:GetDescendants()) do
				applyCollision(descendant) -- equivalent call inferred; original call site unknown
			end
		end
	end

	local descendantAddedConnection = model.DescendantAdded:Connect(applyCollision)
	local ownerUserIdChangedConnection = model:GetAttributeChangedSignal("OwnerUserId"):Connect(refreshOwner)
	refreshOwner()
	model.Destroying:Once(function()
		descendantAddedConnection:Disconnect()
		ownerUserIdChangedConnection:Disconnect()
	end)
	task.defer(function()
		playBounce(model)
	end)
end

local PersonalTreadmill = {}

function PersonalTreadmill.init(_)
	task.spawn(function()
		local child = workspace:WaitForChild(PersonalTreadmill2.WORKSPACE_FOLDER, 30)

		if not child then
			return
		end

		for _, child2 in ipairs(child:GetChildren()) do
			handleMat(child2)
		end

		child.ChildAdded:Connect(handleMat)
	end)
	personalTreadmillSync.OnClientEvent:Connect(function(data)
		v = data.active == true

		if not v then
			pos = nil
			return
		end

		pos = data.pos
		mult = data.mult or 1
		SoundManager:Play("SUCCESS")
	end)
	localPlayer.CharacterAdded:Connect(function()
		v = false
		pos = nil
		v3 = false
	end)
	RunService.Heartbeat:Connect(function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not humanoidRootPart or humanoid.Health <= 0 then
			return
		end

		if v and pos then
			local v4 = (Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z) - Vector3.new(
				pos.X,
				0,
				pos.Z
			)).Magnitude <= PersonalTreadmill2.STEP_DISTANCE

			if v4 ~= v3 then
				v3 = v4
				treadmillSignal:FireServer(v4)
			end

			if v4 then
				local now = os.clock()
				local XP_TIME_BASED = Config.XP_TIME_BASED
				local v5 = math.clamp(
					(humanoid.WalkSpeed - XP_TIME_BASED.MIN_SPEED) / (XP_TIME_BASED.MAX_SPEED - XP_TIME_BASED.MIN_SPEED),
					0,
					1
				)

				if XP_TIME_BASED.MAX_COOLDOWN - v5 * (XP_TIME_BASED.MAX_COOLDOWN - XP_TIME_BASED.MIN_COOLDOWN) <= now - v2 then
					v2 = now
					personalTreadmillStep:FireServer()
					local v6 = ClientState:Get()
					local trail = UpgradeMultipliers.trail(v6.EquippedTrail or "None")
					NotificationSystem:ShowPlusOne(
						v6.StepBonus,
						v6.SpeedBoostMultiplier,
						trail,
						mult,
						v6.BonusXPMultiplier or 1
					)
				end
			end
		elseif v3 then
			v3 = false
			treadmillSignal:FireServer(false)
		end
	end)
end

function PersonalTreadmill.isActive(_)
	return v
end

return PersonalTreadmill