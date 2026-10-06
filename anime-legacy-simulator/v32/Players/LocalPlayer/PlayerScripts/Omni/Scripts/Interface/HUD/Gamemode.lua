local module = require("@game/ReplicatedStorage/Omni")
local module2 = require("@game/ReplicatedStorage/Omni/Utils/StateManager")
local gamemode = module.Interface:WaitForChild("HUD"):WaitForChild("Gamemode")
local information = gamemode:WaitForChild("Information")
local enemies = information:WaitForChild("Enemies")
local time = information:WaitForChild("Time")
local wave = information:WaitForChild("Wave")
local health = information:WaitForChild("Health")
local buttons = gamemode:WaitForChild("Buttons")
local main = buttons:WaitForChild("Leave"):WaitForChild("Main")
local main2 = buttons:WaitForChild("Spawn"):WaitForChild("Main")
local gamemodes = workspace:WaitForChild("Server"):WaitForChild("Enemies"):WaitForChild("Gamemodes")
local v = {}
local v2 = 0
local v3 = nil
local v4 = nil
local count = 0
local flag = false
local Gamemode = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearConnections()
	for _, connection in v do
		connection:Disconnect()
	end

	table.clear(v)
	flag = false
end

local function GetAliveEnemyCount()
	if not v3 then
		return 0
	end

	local count2 = 0

	for _, part in v3:GetChildren() do
		if part:IsA("BasePart") then
			count2 += 1
		end
	end

	return count2
end

local function GetDifficultyInfo(p)
	local state = v4 and v4:GetState("PartyDifficulty")

	if typeof(state) == "string" then
		return module.Shared.Gamemodes.GetDifficultyInfo(p, state) or {}
	end

	return {}
end

local function RefreshWave(p)
	if p.Type == "Dungeon" then
		wave.Title.Text = "ROOM:"
		local state = v4 and v4:GetState("RoomsCleared") or 0
		local state2 = v4 and v4:GetState("TotalGatedRooms") or 0
		wave.Value.Text = `{state}/{state2 > 0 and state2 or "?"}`
	else
		wave.Title.Text = "WAVE:"
		local state = v4 and v4:GetState("CurrentWave") or 0
		local difficultyInfo = GetDifficultyInfo(p)
		wave.Value.Text = `{state}/{difficultyInfo.MaxWave or "?"}`
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshEnemies()
	local aliveEnemyCount = GetAliveEnemyCount()
	local state = v4 and v4:GetState("WaveTotal") or 0
	enemies.Value.Text = `{aliveEnemyCount}/{state}`
end

local function MarkEnemiesDirty()
	flag = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RefreshHealth()
	local state = v4 and v4:GetState("Lives")
	local state2 = v4 and v4:GetState("MaxLives")

	if typeof(state) ~= "number" or typeof(state2) ~= "number" then
		health.Visible = false
		return
	end

	health.Visible = true
	health.Value.Text = `{state}/{state2}`
end

local function RefreshTime(p)
	local difficultyInfo = GetDifficultyInfo(p)

	if difficultyInfo.PrepareTime and (v4 and v4:GetState("CurrentWave") or 0) == 0 then
		local state = v4 and v4:GetState("CreatedAt") or workspace:GetServerTimeNow()
		local v6 = workspace:GetServerTimeNow() - state
		local v7 = math.max(0, difficultyInfo.PrepareTime - v6)
		time.Value.Text = v7 > 0 and `Starts in {module.Utils.Number:Time2((math.ceil(v7)))}` or "Starting..."
	elseif difficultyInfo.WaveTime then
		local state = v4 and v4:GetState("WaveStartedAt") or workspace:GetServerTimeNow()
		local v6 = workspace:GetServerTimeNow() - state
		local v7 = math.max(0, difficultyInfo.WaveTime - v6)
		time.Value.Text = module.Utils.Number:Time2((math.ceil(v7)))
	else
		if not p.TotalTime then
			time.Value.Text = "-"
			return
		end

		local state = v4 and v4:GetState("CreatedAt") or workspace:GetServerTimeNow()
		local v6 = workspace:GetServerTimeNow() - state
		local v7 = math.max(0, p.TotalTime - v6)
		time.Value.Text = module.Utils.Number:Time2((math.ceil(v7)))
	end
end

local function BindSession(p, instance)
	ClearConnections() -- equivalent call inferred; original call site unknown
	v4 = nil

	if instance then
		instance:WaitForChild("StateManager", 8)
		v4 = module2.Get(instance)
		v.StateHolderRemoved = instance.AncestryChanged:Connect(function(_, parent)
			if parent then
				return
			end

			v4 = nil
		end)
	end

	if v4 then
		v.WaveChanged = v4:OnStateChanged("CurrentWave", function()
			RefreshWave(p)
		end)
		v.RoomsClearedChanged = v4:OnStateChanged("RoomsCleared", function()
			RefreshWave(p)
		end)
		v.TotalGatedRoomsChanged = v4:OnStateChanged("TotalGatedRooms", function()
			RefreshWave(p)
		end)
		v.TotalChanged = v4:OnStateChanged("WaveTotal", RefreshEnemies)
		v.LivesChanged = v4:OnStateChanged("Lives", RefreshHealth)
	end

	v.ChildAdded = v3.ChildAdded:Connect(MarkEnemiesDirty)
	v.ChildRemoved = v3.ChildRemoved:Connect(MarkEnemiesDirty)
	RefreshWave(p)
	RefreshEnemies() -- equivalent call inferred; original call site unknown
	RefreshTime(p)
	RefreshHealth() -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function FindSessionFolder(childName: string, childName2: string)
	local v5 = gamemodes:FindFirstChild(childName) or gamemodes:WaitForChild(childName, 8)

	if v5 then
		return v5:FindFirstChild(childName2) or v5:WaitForChild(childName2, 8)
	end

	return nil
end

local function FindStateHolder(gamemode2: string, gamemodeSession: string)
	local v5 = workspace.Client.Maps:FindFirstChild(gamemode2) or workspace.Client.Maps:WaitForChild(gamemode2, 8)

	if not v5 then
		return nil
	end

	local gamemodeSessions = v5:FindFirstChild("GamemodeSessions") or v5:WaitForChild("GamemodeSessions", 8)

	if gamemodeSessions then
		return gamemodeSessions:FindFirstChild(gamemodeSession) or gamemodeSessions:WaitForChild(gamemodeSession, 8)
	end

	return nil
end

function Gamemode.Refresh()
	count += 1
	local v5 = count
	local gamemode2 = module.Data.Gamemode
	local gamemodeSession = module.Data.GamemodeSession

	if gamemode2 and gamemodeSession then
		local v6 = module.Shared.Gamemodes.List[gamemode2]

		if not v6 then
			gamemode.Visible = false
			return
		end

		gamemode.Visible = true
		task.spawn(function()
			local sessionFolder = FindSessionFolder(gamemode2, gamemodeSession) -- equivalent call inferred; original call site unknown

			if not (v5 == count and sessionFolder) then
				return
			end

			v3 = sessionFolder
			local stateHolder = FindStateHolder(gamemode2, gamemodeSession)

			if v5 ~= count then
				return
			end

			BindSession(v6, stateHolder)
		end)
	else
		gamemode.Visible = false
		ClearConnections() -- equivalent call inferred; original call site unknown
		v3 = nil
		v4 = nil
	end
end

function Gamemode.Init()
	module.Button:Create(main, "Small"):BindFunction("Click", function()
		module.Signal:Fire("General", "Gamemodes", "Leave")
	end)
	module.Button:Create(main2, "Small"):BindFunction("Click", function()
		module.Signal:Fire("General", "Gamemodes", "Recall")
	end)
	module:OnDataChanged({ "Gamemode" }, Gamemode.Refresh)
	module:OnDataChanged({ "GamemodeSession" }, Gamemode.Refresh)
	Gamemode.Refresh()
end

module.Services.RunService.Heartbeat:Connect(function()
	if not (gamemode.Visible and v3) then
		return
	end

	if flag then
		flag = false
		RefreshEnemies() -- equivalent call inferred; original call site unknown
	end

	local now = os.clock()

	if now - v2 < 0.5 then
		return
	end

	v2 = now
	local v5 = module.Shared.Gamemodes.List[module.Data.Gamemode]

	if not v5 then
		return
	end

	RefreshTime(v5)
end)
return Gamemode