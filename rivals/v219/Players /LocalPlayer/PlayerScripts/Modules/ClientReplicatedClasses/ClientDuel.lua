local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Signal = require(ReplicatedStorage.Modules.Signal)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local Pages = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.Pages)
local DuelInterface = require(script:WaitForChild("DuelInterface"))
local BeginnerDuel = require(script:WaitForChild("BeginnerDuel"))
local ChickenGame = require(script:WaitForChild("ChickenGame"))
local ClientMap = require(script:WaitForChild("ClientMap"))
local maps = Players.LocalPlayer.PlayerScripts.Modules.Maps
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object.new(temp_serial)
	local self = setmetatable(ReplicatedClass.new(temp_serial), object)
	self.DuelerAdded = Signal.new()
	self.DuelerRemoved = Signal.new()
	self.MapAdded = Signal.new()
	self.SpectateThisPlayer = Signal.new()
	self.Duelers = {}
	self.Map = nil
	self.DuelInterface = DuelInterface.new(self)
	self.LocalDueler = nil
	self.IsRanked = SeasonLibrary:IsRankedQueue(self:Get("QueueName"))
	self.ChickenGame = ChickenGame.new(self)
	self.BeginnerDuel = BeginnerDuel.new(self)
	self.Data.IsSpectating = false
	self.Data.LastRoundStartingStatus = nil
	self.Data.DuelMusic = nil
	self._temp_serial = temp_serial
	self._connections = {}
	self._client_fighters = {}
	self._duelers_by_player = {}
	self:_Init()
	return self
end

function object:IsRendered()
	return CONSTANTS.SHOULD_ALWAYS_REPLICATE() or self.LocalDueler or self == SpectateController.CurrentDuelSubject
end

function object:CanLeave()
	if Pages.PageSystem.CurrentPage then
		return false
	end

	return self:Get("IsCurrentArcadeDuel") or self:Get("RoundNum") > 1 and self:Get("Status") == "RoundFinished" and not self:Get("CanTrackStatistics") or self:Get("WasSelfQueued")
end

function object:GetDueler(p2)
	if self._duelers_by_player[p2] then
		return self._duelers_by_player[p2]
	end

	for k, dueler in pairs(self.Duelers) do
		if dueler.Player == p2 or dueler:Get("ObjectID") == p2 then
			return dueler, k
		end
	end
end

function object:GetFighters()
	return table.clone(self._client_fighters)
end

function object.CountTeam(p, p2)
	local total = 0

	for _, dueler in pairs(p.Duelers) do
		total += dueler:Get("TeamID") == p2 and 1 or 0
	end

	return total
end

function object:LeaveDuelRequest()
	if self:CanLeave() then
		Pages.PageSystem:OpenPage("LeaveDuel", true)
	end
end

function object:ReplicateFromServer(p, ...)
	if p == "DuelerAdded" then
		self:_DuelerAdded(...)
	elseif p == "DuelerRemoved" then
		self:_DuelerRemoved(...)
	elseif p == "DuelerChanged" then
		self:_DuelerChanged(...)
	elseif p == "MapAdded" then
		self:_MapAdded(...)
	elseif p == "MapChanged" then
		local v = ...
		local v2 = self:FromEnum(v) or v

		if self.Map then
			self.Map:ReplicateFromServer(v2, select(2, ...))
		end
	elseif p == "RoundStarting" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...
		local v3 = self:FromEnum(v2)
		self:SetReplicate("LastRoundStartingStatus", v3)

		if v3 == "MatchPoint" then
			self.DuelInterface.MatchPoint:Play(false)
		elseif v3 == "SuddenDeath" then
			self.DuelInterface.MatchPoint:Play(true)
		end

		self.DuelInterface.Timer:Set(v)
	elseif p == "RoundStart" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Timer:Set(...)
	elseif p == "RoundFinish" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...
		self.DuelInterface.Timer:Pause(v2)
		self.DuelInterface.RoundResult:Play(v)
	elseif p == "FinalResults" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.FinalResults:Play(...)
	elseif p == "Countdown" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Timer:Set(...)
	elseif p == "ChosenMapEffect" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Voting:PlayMapChosenEffect(...)
	elseif p == "PauseTimer" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Timer:Pause(...)
	elseif p == "RespawnNowAnimation" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...

		if not self.LocalDueler or v ~= self.LocalDueler.Player then
			return
		end

		self.DuelInterface.Buttons:RespawnNowAnimation(v2)
	elseif p == "ChickenGamesRedLight" then
		if not self:IsRendered() then
			return
		end

		self.ChickenGame:RedLight(...)
	elseif p == "ChickenGamesGreenLight" then
		if not self:IsRendered() then
			return
		end

		self.ChickenGame:GreenLight(...)
	elseif p == "ChickenGamesElimination" then
		if not self:IsRendered() then
			return
		end

		self.ChickenGame:Elimination(...)
	elseif p == "ChickenGamesStop" then
		if not self:IsRendered() then
			return
		end

		self.ChickenGame:Stop(...)
	elseif p == "TimerStopwatchStarted" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Timer:StopwatchStart(...)
	elseif p == "TimerStopwatchFinished" then
		if not self:IsRendered() then
			return
		end

		self.DuelInterface.Timer:StopwatchFinish(...)
	elseif p == "SpectateThisPlayer" then
		if not self:IsRendered() then
			return
		end

		local v, v2 = ...

		if v and v2 then
			self.SpectateThisPlayer:Fire(v, v2)
		end
	else
		ReplicatedClass.ReplicateFromServer(self, p, ...)
	end
end

function object:Destroy()
	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	for _, dueler in pairs(self.Duelers) do
		dueler:Destroy()
	end

	self._client_fighters = {}
	self._duelers_by_player = {}

	if self.Map then
		self.Map:Destroy()
	end

	self.DuelInterface:Destroy()
	self.ChickenGame:Destroy()
	self.BeginnerDuel:Destroy()
	self.DuelerAdded:Destroy()
	self.DuelerRemoved:Destroy()
	self.MapAdded:Destroy()
	self.SpectateThisPlayer:Destroy()
	ReplicatedClass.Destroy(self)
end

function object:_UpdateAllies()
	local dueler = self:GetDueler(Players.LocalPlayer)
	local teamID = dueler and dueler:Get("TeamID")

	for _, dueler2 in pairs(self.Duelers) do
		local v

		if teamID then
			if dueler2 == dueler then
				v = false
			else
				v = teamID == dueler2:Get("TeamID")
			end
		else
			v = teamID
		end

		dueler2:SetAlly(v)
	end
end

function object:_DuelerChanged(p, p2, ...)
	local dueler = self:GetDueler(p)

	if not dueler then
		return
	end

	dueler:ReplicateFromServer(self:FromEnum(p2) or p2, ...)
end

function object:_DuelerAdded(p)
	if self:GetDueler(p[self:ToEnum("Data")][self:ToEnum("ObjectID")]) then
		return
	end

	local v = p[self:ToEnum("ClientReplicatedClassType")]
	local v2 = FighterController:WaitForFighter(p[self:ToEnum("Player")])
	local replicatedClass = ReplicatedClass:GetReplicatedClass(self:FromEnum(v) or v).new(p, v2, self)
	table.insert(self.Duelers, replicatedClass)
	table.insert(self._client_fighters, v2)
	self._duelers_by_player[replicatedClass.Player] = replicatedClass
	local localDueler

	if v2.IsLocalPlayer then
		localDueler = replicatedClass
	else
		localDueler = self.LocalDueler
	end

	self.LocalDueler = localDueler
	self.DuelerAdded:Fire(replicatedClass)
end

function object:_DuelerRemoved(p)
	local dueler, v = self:GetDueler(p)

	if not v then
		return
	end

	if dueler == self.LocalDueler then
		self.LocalDueler = nil
	end

	local index = dueler.ClientFighter and table.find(self._client_fighters, dueler.ClientFighter)

	if index then
		table.remove(self._client_fighters, index)
	end

	table.remove(self.Duelers, v)
	self._duelers_by_player[dueler.Player] = nil
	self.DuelerRemoved:Fire(dueler)
	dueler:Destroy()
end

function object:_MapAdded(p)
	local v = p[self:ToEnum("Name")]
	self.Map = (maps:FindFirstChild(v) and require(maps[v]) or ClientMap).new(p, self)
	self.MapAdded:Fire(self.Map)
end

function object:_Setup()
	for _, dueler in pairs(self._temp_serial.Duelers) do
		task.spawn(self._DuelerAdded, self, dueler)
	end

	if self._temp_serial.Map then
		task.spawn(self._MapAdded, self, self._temp_serial.Map)
	end

	self._temp_serial = nil
end

function object:_Init()
	self.DuelerAdded:Connect(function()
		self:_UpdateAllies()
	end)
	self:_Setup()
	self:_UpdateAllies()
end

return object