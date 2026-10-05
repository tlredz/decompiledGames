local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PlayerDataController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local NotificationSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("NotificationSlot"))
local UILibrary = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("UILibrary"))
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.NotificationSent = Signal.new()
	self.Frame = UILibrary:GetTo("MainFrame", "Notifications")
	self._queue = {}
	self._is_playing_queue = false
	self:_Init()
	return self
end

function class.Play(p, p2, p3, p4, p5, p6, p7, p8)
	p.NotificationSent:Fire(p2, p3, p4, p5)

	if p8 or PlayerDataController:GetSetting("Notifications Delivery") == "Muted" then
		return
	end

	local v = NotificationSlot.new(p2, p3, p4, p5)
	v:SetParent(p.Frame.Container)
	v:PlaySize(p6, 5)
	v:PlaySound(p7)
	v:PlayGlow()
	BetterDebris:AddItem(v, 10)
end

function class:Queue(...)
	table.insert(self._queue, { ... })
	self:_PlayQueue()
end

function class:_PlayQueue()
	if self._is_playing_queue or PlayerDataController:GetSetting("Notifications Delivery") == "Lobby" and self._local_fighter and self._local_fighter:Get("IsInDuel") then
		return
	end

	self._is_playing_queue = true
	local flag = true

	while #self._queue > 0 do
		if flag then
			wait(0.25)
			flag = false
		end

		local v = 1 - (math.min(5, #self._queue) - 1) * 0.1
		local v2 = 1

		while true do
			local v3 = v2 <= 5 and table.remove(self._queue, 1)

			if not v3 then
				break
			end

			local v4, v5, v6, v7, v8, v9 = table.unpack(v3)
			task.spawn(self.Play, self, v4, v5, v6, v7, (v8 or 1) * v, nil, v9)

			if v9 then
				continue
			end

			wait(0.1)
			v2 += 1
		end

		wait(5)
	end

	self._is_playing_queue = false
end

function class:_HookFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_PlayQueue()
	end)
	self:_PlayQueue()
end

function class:_Init()
	ReplicatedStorage.Remotes.Data.PlayNotification.OnClientEvent:Connect(function(...)
		self:Queue(...)
	end)
	task.defer(self._HookFighter, self)
end

return class._new()