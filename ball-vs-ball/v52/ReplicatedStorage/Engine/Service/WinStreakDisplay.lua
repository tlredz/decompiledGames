local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Observers"))
local ServerTeleport = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("ServerTeleport"))
local PlayerData = require(script.Parent:WaitForChild("PlayerData"))
local ServerTypeService = require(script.Parent:WaitForChild("ServerTypeService"))
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("悬浮UI"):WaitForChild("Rig"):WaitForChild("连胜")
local v2 = {}
local v3 = {}

local function refresh(p)
	local v4 = v2[p]

	if not v4 then
		return
	end

	local winStreak = PlayerData.server[p].winStreak()
	local textLabel = v4:FindFirstChild("TextLabel")

	if textLabel and textLabel:IsA("TextLabel") then
		textLabel.Text = "🔥" .. tostring(winStreak)
	end

	v4.Enabled = winStreak >= 1 and not v3[p]
end

local function mountBillboard(p, instance)
	local head = instance:WaitForChild("Head", 5)

	if not (head and head:IsA("BasePart")) then
		return function() end
	end

	PlayerData.server.Service:waitForData(p)

	if instance.Parent == nil then
		return function() end
	end

	if ServerTeleport.getServerType() == ServerTypeService.TRADE_POOL_NAME then
		return function() end
	end

	local clone = v:Clone()
	clone.Name = "连胜"
	clone.Adornee = head
	clone.Parent = head
	v2[p] = clone
	refresh(p)
	return function()
		if v2[p] == clone then
			v2[p] = nil
		end

		clone:Destroy()
	end
end

local WinStreakDisplay = {}

function WinStreakDisplay.init()
	Observers.observeCharacter(function(p, p2)
		return (mountBillboard(p, p2))
	end)
end

function WinStreakDisplay.recordWin(p)
	local v4 = 0
	PlayerData.server[p].winStreak(function(p2: number)
		v4 = p2 + 1
		return v4
	end)
	PlayerData.server[p].maxWinStreak(function(p2: number)
		return (math.max(p2, v4))
	end)
	refresh(p)
end

function WinStreakDisplay.recordLoss(p)
	local winStreak = PlayerData.server[p].winStreak()
	PlayerData.server[p].lastStreak(winStreak)
	PlayerData.server[p].winStreak(0)
	refresh(p)
	return winStreak
end

function WinStreakDisplay.setStreak(p, p2: number)
	PlayerData.server[p].winStreak(p2)
	PlayerData.server[p].maxWinStreak(function(p3: number)
		return (math.max(p3, p2))
	end)
	refresh(p)
end

function WinStreakDisplay.setInBattle(p, flag: boolean)
	v3[p] = flag
	refresh(p)
end

return WinStreakDisplay