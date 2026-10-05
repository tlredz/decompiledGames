local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local v = nil
local Forcefield = {
	AbilityName = "Forcefield",
	AbilityCooldown = 30,
	CanUseAbility = function(_, instance)
		if not instance.PrimaryPart or instance:GetAttribute("PULSED") and not instance:GetAttribute("teamVIP") then
			return false
		end

		return not instance:GetAttribute("AbilityCooldown")
	end,
	GetBaseForcefieldTime = function(self, p: number)
		return p * 1.1666666666666667 + 7
	end
}

function Forcefield:RegisterCooldown(instance, p: number)
	local baseForcefieldTime = Forcefield:GetBaseForcefieldTime(p)
	local v2 = 30 - p * 3.75 + 0.30000000000000004 + baseForcefieldTime
	instance:SetAttribute("AbilityCooldown", true)
	task.delay(v2, function()
		if instance:IsDescendantOf(workspace) then
			instance:SetAttribute("AbilityCooldown", nil)
		end
	end)
end

function Forcefield.ServerInit(_, p, p2: number, flag: boolean)
	if not v then
		local MapManager = require(ServerScriptService.Game.CoreGameModules.MapManager)
		v = MapManager
	end

	if not flag then
		Forcefield:RegisterCooldown(p, p2)
	end
end

function Forcefield.ServerStart(_, instance, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local baseForcefieldTime = Forcefield:GetBaseForcefieldTime(p)
	local v2

	if p == 2 then
		v2 = ReplicatedStorage.Misc.MaxShield
	else
		v2 = ReplicatedStorage.Misc.Shield
	end

	local clone = v2:Clone()
	local originalDifficulty = instance:GetAttribute("OriginalDifficulty") or instance:GetAttribute("Difficulty")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setTargetState(flag: boolean, _: boolean)
		if instance:IsDescendantOf(workspace) then
			instance:SetAttribute("Difficulty", flag and "Impossible" or originalDifficulty)
		end
	end

	local valueChangedConnection = nil
	valueChangedConnection = workspace.ShowdownActive:GetPropertyChangedSignal("Value"):Connect(function()
		if workspace.ShowdownActive.Value then
			valueChangedConnection:Disconnect()
			setTargetState(true) -- equivalent call inferred; original call site unknown
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ballAdded(flag: boolean)
		local currentBall = v.getCurrentBall()
		local v3 = currentBall and v.getPlayerFromCharacterInMatch(instance)

		if v3 then
			currentBall:changeForcefieldStatus(v3, flag)
		end
	end

	local childAddedConnection = workspace.Balls.ChildAdded:Connect(function()
		task.wait(0.016666666666666666)
		ballAdded(true) -- equivalent call inferred; original call site unknown
	end)
	task.delay(baseForcefieldTime, function()
		if childAddedConnection.Connected then
			childAddedConnection:Disconnect()
		end

		if typeof(valueChangedConnection) == "RBXScriptConnection" and valueChangedConnection.Connected then
			valueChangedConnection:Disconnect()
		end

		setTargetState(false) -- equivalent call inferred; original call site unknown
		ballAdded(false) -- equivalent call inferred; original call site unknown
	end)
	setTargetState(true) -- equivalent call inferred; original call site unknown
	ballAdded(true) -- equivalent call inferred; original call site unknown
	local inner = clone.inner
	clone.Size = createVector(0.01, 0.01, 0.01)
	clone.Parent = humanoidRootPart
	clone.CFrame = clone.Parent.CFrame
	clone.WeldConstraint.Part1 = clone.Parent
	task.delay(baseForcefieldTime + 1, function()
		clone:Destroy()
	end)
	local v3 = math.sqrt(getMass(instance) / 10)
	local size = createVector(7, 7, 7) * v3
	local size2 = createVector(6, 6, 6) * v3
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{
			Size = size
		}
	)
	local tween2 = TweenService:Create(
		inner,
		TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false),
		{
			Size = size2
		}
	)
	tween:Play()
	tween2:Play()
	clone.Shield:Play()
	clone.Sound:Play()
	task.wait(0.1)
	tween:Pause()
	local v6 = baseForcefieldTime - 0.2

	while v6 > 0 do
		v6 -= task.wait()
	end

	task.wait(0.2)

	if clone and clone:IsDescendantOf(workspace) then
		local shieldDeactivate = clone:FindFirstChild("ShieldDeactivate")

		if shieldDeactivate then
			shieldDeactivate:Play()
		end

		local sound = clone:FindFirstChild("Sound")

		if sound then
			sound:Stop()
		end
	end

	TweenService:Create(inner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false), {
		Size = createVector(0.01, 0.01, 0.01)
	}):Play()
	tween:Play()
end

function getMass(folder)
	local total = 0

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			total += part.Mass
		end
	end

	return total
end

return Forcefield