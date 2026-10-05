local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local simplesignal = require(ReplicatedStorage.Packages.simplesignal)
local Multipliers = {}
local v = {}

local function now()
	return workspace:GetServerTimeNow()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resolvePlayer(p)
	if p ~= nil then
		return p
	end

	assert(RunService:IsClient(), "Multipliers: the server must pass a player")
	return Players.LocalPlayer
end

local evaluate

evaluate = function(state)
	local value = state.Started.Value
	local value2 = state.Duration.Value
	local status

	if state.Values:FindFirstChild(state.Kind) == nil and value2 ~= -1 then
		local v3 = value + value2 - workspace:GetServerTimeNow()

		if value2 > 0 then
			status = v3 > 0
		else
			status = false
		end

		if status then
			state.Token += 1
			local token = state.Token
			task.delay(v3 + 0.05, function()
				if state.Token ~= token then
					return
				end

				evaluate(state)
			end)
		end
	else
		status = true
	end

	if status ~= state.Status then
		state.Status = status
		state.Signal:Fire(status)
	end
end

local function getState(childName: string, p)
	local v2 = v[p]

	if v2 == nil then
		v2 = {}
		v[p] = v2
	end

	local v3 = v2[childName]

	if v3 ~= nil then
		return v3
	end

	local child = Utility.GetData(p, true):WaitForChild("Multipliers"):WaitForChild(childName)
	local getvaluesfolder = Utility.getvaluesfolder(p, true)
	local v4 = {
		Kind = childName,
		Signal = simplesignal.new(),
		Status = false,
		Started = child:WaitForChild("Started"),
		Duration = child:WaitForChild("Duration"),
		Values = getvaluesfolder,
		Token = 0,
		Connections = {}
	}

	if v2[childName] ~= nil then
		v4.Signal:Destroy()
		return v2[childName]
	end

	v2[childName] = v4
	table.insert(v4.Connections, v4.Started.Changed:Connect(function()
		evaluate(v4)
	end))
	table.insert(v4.Connections, v4.Duration.Changed:Connect(function()
		evaluate(v4)
	end))

	local function onPin(p2)
		if p2.Name == childName then
			evaluate(v4)
		end
	end

	table.insert(v4.Connections, getvaluesfolder.ChildAdded:Connect(onPin))
	table.insert(v4.Connections, getvaluesfolder.ChildRemoved:Connect(onPin))
	evaluate(v4)
	return v4
end

function Multipliers.GetValue(kind: string, localPlayer)
	if localPlayer == nil then
		assert(RunService:IsClient(), "Multipliers: the server must pass a player")
		localPlayer = Players.LocalPlayer
	end

	local v3 = getState(kind, localPlayer)
	local started = v3.Started.Value
	local duration = v3.Duration.Value
	local remaining = 0

	if v3.Values:FindFirstChild(v3.Kind) == nil and duration ~= -1 then
		if duration > 0 then
			remaining = math.max(0, started + duration - workspace:GetServerTimeNow())
		end
	else
		remaining = -1
	end

	return {
		Status = v3.Status,
		Started = started,
		Duration = duration,
		Remaining = remaining
	}
end

function Multipliers.Changed(kind: string, localPlayer)
	if localPlayer == nil then
		assert(RunService:IsClient(), "Multipliers: the server must pass a player")
		localPlayer = Players.LocalPlayer
	end

	return getState(kind, localPlayer).Signal
end

Multipliers.Kinds = {
	Exp = { "Exp2X" },
	Wen = { "Wen2X" },
	Mastery = { "Mastery2X" },
	Luck = { "Luck2X", "Luck4X" },
	Souls = { "Souls2X" }
}

function Multipliers.FactorOf(value: string)
	return tonumber(string.match(value, "(%d+)X$")) or 1
end

local v2 = {}
local v3 = {
	Exp = "EXP",
	Wen = "Wen",
	Mastery = "Mastery",
	Luck = "Luck",
	Souls = "Souls"
}

for k, kind in Multipliers.Kinds do
	for _, v4 in kind do
		v2[v4] = k
	end
end

function Multipliers.DisplayName(p: string)
	local v4 = v2[p]
	assert(v4 ~= nil, (`Multipliers: unknown kind "{tostring(p)}"`))
	return (`{Multipliers.FactorOf(p)}x {v3[v4] or v4}`)
end

function Multipliers.TagOf(p: string, p2)
	local _, v4 = Multipliers.GetFactor(p, p2)

	if v4 == nil then
		return nil
	end

	return (Multipliers.DisplayName(v4))
end

function Multipliers.GetFactor(p: string, p2)
	local kind = Multipliers.Kinds[p]
	assert(kind ~= nil, (`Multipliers: unknown family "{tostring(p)}"`))
	local v4 = 1
	local v5 = nil

	for _, v6 in kind do
		if not Multipliers.GetValue(v6, p2).Status then
			continue
		end

		local factor = Multipliers.FactorOf(v6)

		if not (v4 < factor) then
			continue
		end

		v5 = v6
		v4 = factor
	end

	return v4, v5
end

function Multipliers.WindowApplies(p: string?)
	return p == "NpcReward" or p == "Quest"
end

function Multipliers.DropLuck(p)
	local getStat = PlayerStatResolver.GetStat
	local player = resolvePlayer(p) -- equivalent call inferred; original call site unknown
	return math.max(0, getStat(player, "Drop Luck Factor") or 0) + 1 + (Multipliers.GetFactor("Luck", p) - 1)
end

function Multipliers.ExpGain(p, p2: string?)
	local player = resolvePlayer(p) -- equivalent call inferred; original call site unknown
	local v4 = math.max(0, PlayerStatResolver.GetStat(player, "Exp Factor") or 0)

	if p2 == "Quest" then
		v4 += math.max(0, PlayerStatResolver.GetStat(player, "Quest Exp Factor") or 0)
	end

	local v5 = not Multipliers.WindowApplies(p2) and 0 or Multipliers.GetFactor("Exp", p) - 1
	return v4 + 1 + v5
end

function Multipliers.LevelCostFactor(p: number)
	local levelCostCurve = gameSettings.levelCostCurve
	local v4 = levelCostCurve[1]

	if p <= v4.Level then
		return v4.Divisor
	end

	for i = 2, #levelCostCurve do
		local v5 = levelCostCurve[i]

		if p <= v5.Level then
			local v6 = (p - v4.Level) / math.max(v5.Level - v4.Level, 1)
			return v4.Divisor + (v5.Divisor - v4.Divisor) * v6
		else
			v4 = v5
		end
	end

	return v4.Divisor
end

function Multipliers.WenGain(p, p2: string?)
	if Multipliers.WindowApplies(p2) then
		return (Multipliers.GetFactor("Wen", p))
	end

	return 1
end

function Multipliers.WenGainTag(p, p2: string?)
	local v4 = math.round(Multipliers.WenGain(p, p2) * 100) / 100

	if v4 == 1 then
		return nil
	end

	return (`{v4}x`)
end

function Multipliers.ExpGainTag(p, p2: string?)
	local v4 = math.round(Multipliers.ExpGain(p, p2) * 100) / 100

	if v4 == 1 then
		return nil
	end

	return (`{v4}x`)
end

function Multipliers.RunsHere()
	return not gameSettings.IsMenu and MinigameSettings.Get("NoMultiplierClock") ~= true
end

local function windowsOf(instance)
	local multipliers = instance:FindFirstChild("Multipliers")

	if multipliers == nil then
		return {}
	end

	return (multipliers:GetChildren())
end

function Multipliers.PauseSlot(instance)
	assert(RunService:IsServer(), "Multipliers: only the server pauses a slot")
	local multipliers = instance:FindFirstChild("Multipliers")

	for _, v4 in multipliers == nil and {} or multipliers:GetChildren() do
		local started = v4:FindFirstChild("Started")
		local duration = v4:FindFirstChild("Duration")

		if started == nil or duration == nil or duration.Value <= 0 or started.Value == 0 then
			continue
		end

		local v5 = started.Value + duration.Value - workspace:GetServerTimeNow()
		started.Value = 0
		duration.Value = math.max(0, (math.floor(v5)))
	end
end

function Multipliers.ResumeSlot(instance)
	assert(RunService:IsServer(), "Multipliers: only the server resumes a slot")
	local multipliers = instance:FindFirstChild("Multipliers")

	for _, v4 in multipliers == nil and {} or multipliers:GetChildren() do
		local started = v4:FindFirstChild("Started")
		local duration = v4:FindFirstChild("Duration")

		if not (started ~= nil and duration ~= nil and duration.Value > 0 and started.Value == 0) then
			continue
		end

		if not Multipliers.RunsHere() then
			continue
		end

		started.Value = workspace:GetServerTimeNow()
	end
end

function Multipliers.ForgetPlayer(p)
	local v4 = v[p]

	if v4 == nil then
		return
	end

	v[p] = nil

	for _, v5 in v4 do
		v5.Token += 1

		for _, connection in v5.Connections do
			connection:Disconnect()
		end

		v5.Signal:Destroy()
	end
end

return Multipliers