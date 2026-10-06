local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages:WaitForChild("Net"))
local service = ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service")
local Config = require(service:WaitForChild("Config"))
local ExperienceService = require(service:WaitForChild("ExperienceService"))
local PlayerData = require(service:WaitForChild("PlayerData"))
local client = PlayerData.client
local PlayerThumbnail = require(service:WaitForChild("PlayerThumbnail"))
local GameModeRegistry = require(ReplicatedStorage.Engine.Service.GameModeRegistry)
local v = {
	TwoVTwo = "2v2模式"
}

local function getRaceConfig(p: string?)
	local raceCnId = GameModeRegistry.get(p).raceCnId
	return Config.race.byCnId[raceCnId], raceCnId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getDuelRewardCoins(gameMode: string?)
	local raceCnId = GameModeRegistry.get(gameMode).raceCnId
	local v2 = Config.race.byCnId[raceCnId]
	local rewardCoins = v2 and v2.rewardCoins

	if typeof(rewardCoins) == "number" and rewardCoins >= 0 then
		return (math.floor(rewardCoins))
	end

	return 0
end

local function getGameModeName(p: string?)
	local raceCnId = GameModeRegistry.get(p).raceCnId
	local v2 = Config.race.byCnId[raceCnId]

	if v2 and typeof(v2.name) == "string" then
		return v2.name
	end

	return raceCnId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSeatUserId(p, seatName: string)
	local v2 = p.seats and p.seats[seatName]
	return v2 and v2.userId
end

local function getSeats(p)
	local table = p.table
	local v2

	if table then
		v2 = GameModeRegistry.getForTable(table)
	else
		v2 = GameModeRegistry.get(nil)
	end

	return v2.seats
end

local function isGameModeUnlocked(p)
	local table = p.table
	local v2

	if table then
		v2 = GameModeRegistry.getForTable(table).id
	else
		v2 = GameModeRegistry.get(nil).id
	end

	local v3 = v[v2]
	return not v3 or ExperienceService.isFeatureUnlocked(client.exp.total(), v3)
end

local function isQuickJoinable(p)
	if not isGameModeUnlocked(p) or p.state ~= "Waiting" then
		return false
	end

	local count = 0
	local table = p.table
	local v2

	if table then
		v2 = GameModeRegistry.getForTable(table)
	else
		v2 = GameModeRegistry.get(nil)
	end

	local seats = v2.seats

	for _, seat in ipairs(seats) do
		if getSeatUserId(p, seat.seatName) ~= nil then
			count += 1
		end
	end

	return count > 0 and count < #seats
end

local flag = false
local localPlayer = nil
local v2 = nil
local parent = nil
local _1v1 = nil
local _2v2 = nil
local v4 = {}
local v5 = {}
local count = 0
local v6 = false
local v7 = true

-- equivalent calls inferred from this helper; original call sites unknown
local function syncVisibility()
	local visible = next(v4) ~= nil and v6 and v7
	parent.Visible = visible
	v2.Visible = visible
end

local QuickJoin = {
	SetTabActive = function(flag2: boolean)
		v7 = flag2

		if flag then
			syncVisibility() -- equivalent call inferred; original call site unknown
		end
	end
}

local function trackLocalCharacter(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 10)

	if humanoid and humanoid:IsA("Humanoid") then
		v6 = humanoid.Health > 0
		syncVisibility() -- equivalent call inferred; original call site unknown
		humanoid.Died:Connect(function()
			if localPlayer.Character == character then
				v6 = false
				syncVisibility() -- equivalent call inferred; original call site unknown
			end
		end)
	else
		v6 = false
		syncVisibility() -- equivalent call inferred; original call site unknown
	end
end

local function removeRow(p, flag2: boolean?)
	local v8 = v4[p]

	if v8 then
		v4[p] = nil
		v8:Destroy()
		syncVisibility() -- equivalent call inferred; original call site unknown
	end

	if flag2 ~= false then
		v5[p] = nil
	end
end

local function bindRowOnce(clone, table)
	local button = clone:FindFirstChild("加入按钮") or clone:FindFirstChild("Join")

	if button and button:IsA("TextButton") then
		ButtonActions.Bind(button, function()
			if not v6 then
				return
			end

			local v8 = v5[table]

			if not (v8 and isQuickJoinable(v8)) then
				return
			end

			local v9 = nil
			local table2 = v8.table
			local v10

			if table2 then
				v10 = GameModeRegistry.getForTable(table2)
			else
				v10 = GameModeRegistry.get(nil)
			end

			for _, v12 in ipairs(v10.seats) do
				local seatName = v12.seatName

				if getSeatUserId(v8, seatName) ~= nil then
					continue
				end

				v9 = seatName
				break
			end

			if not v9 then
				return
			end

			Net:RemoteEvent("DuelTableJoinRequest"):FireServer(table, v9)
		end)
	end
end

local function renderRow(clone, table, p)
	local gameMode = table:GetAttribute("GameMode")

	if typeof(gameMode) ~= "string" then
		gameMode = nil
	end

	local firstChild = clone:FindFirstChild("信息")
	local label = firstChild and firstChild:FindFirstChild("玩法名称")

	if label and label:IsA("TextLabel") then
		local raceCnId = GameModeRegistry.get(gameMode).raceCnId
		local v8 = Config.race.byCnId[raceCnId]

		if v8 and typeof(v8.name) == "string" then
			raceCnId = v8.name
		end

		label.Text = raceCnId
	end

	local label2 = clone:FindFirstChild("奖励数值", true)

	if label2 and label2:IsA("TextLabel") then
		label2.Text = "Win " .. tostring(getDuelRewardCoins(gameMode))
	end

	local table2 = p.table
	local v8

	if table2 then
		v8 = GameModeRegistry.getForTable(table2)
	else
		v8 = GameModeRegistry.get(nil)
	end

	for _, v9 in ipairs(v8.seats) do
		local seatName = v9.seatName
		local image = clone:FindFirstChild(seatName)

		if not (image and image:IsA("ImageLabel")) then
			continue
		end

		local guiObject = image:FindFirstChild("问号")
		local seatUserId = getSeatUserId(p, seatName) -- equivalent call inferred; original call site unknown

		if seatUserId then
			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end

			PlayerThumbnail.applyAsync(image, seatUserId)
		else
			image.Image = ""

			if guiObject and guiObject:IsA("GuiObject") then
				guiObject.Visible = true
			end
		end
	end
end

local function applyState(p)
	local table = p.table

	if not (table and table:IsA("Model")) then
		return
	end

	v5[table] = p

	if isQuickJoinable(p) then
		local clone = v4[table]

		if not clone then
			local v8

			if GameModeRegistry.getForTable(table).id == "TwoVTwo" then
				v8 = _2v2
			else
				v8 = _1v1
			end

			clone = v8:Clone()
			count += 1
			clone.Name = "行_" .. tostring(count)
			clone.Visible = true
			clone.LayoutOrder = table:GetAttribute("TableIndex") or 0
			clone.Parent = parent
			v4[table] = clone
			bindRowOnce(clone, table)
		end

		renderRow(clone, table, p)
		syncVisibility() -- equivalent call inferred; original call site unknown
	else
		local v8 = v4[table]

		if v8 then
			v4[table] = nil
			v8:Destroy()
			syncVisibility() -- equivalent call inferred; original call site unknown
		end
	end
end

local function connectNetwork()
	Net:RemoteEvent("DuelTableState").OnClientEvent:Connect(function(p)
		if type(p) ~= "table" then
			return
		end

		if p.table then
			applyState(p)
			return
		end

		local tables = p.tables

		if type(tables) == "table" then
			local v8 = {}

			for _, table in tables do
				if not (type(table) == "table" and table.table) then
					continue
				end

				v8[table.table] = true
				applyState(table)
			end

			for k in v4 do
				if v8[k] then
					continue
				end

				local v9 = v4[k]

				if v9 then
					v4[k] = nil
					v9:Destroy()
					syncVisibility() -- equivalent call inferred; original call site unknown
				end

				v5[k] = nil
			end
		end
	end)
	Net:RemoteEvent("DuelTableStateRequest"):FireServer()
end

function QuickJoin.Init()
	if flag then
		return
	end

	flag = true
	localPlayer = Players.LocalPlayer
	v2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("右侧菜单"):WaitForChild("右侧区域"):WaitForChild("快速加入")
	parent = v2:WaitForChild("列表")
	_1v1 = parent:WaitForChild("1v1模板")
	_2v2 = parent:WaitForChild("2v2模板")

	for _, frame in parent:GetChildren() do
		if frame ~= _1v1 and frame:IsA("Frame") and frame.Name == _1v1.Name then
			frame:Destroy()
		end
	end

	_1v1.Parent = nil
	_2v2.Parent = nil
	parent.Visible = false
	v2.Visible = false
	local character = localPlayer.Character

	if character then
		trackLocalCharacter(character)
	end

	localPlayer.CharacterAdded:Connect(trackLocalCharacter)
	client.exp.total.Changed(function()
		for _, v8 in v5 do
			applyState(v8)
		end
	end)
	connectNetwork()
end

return QuickJoin