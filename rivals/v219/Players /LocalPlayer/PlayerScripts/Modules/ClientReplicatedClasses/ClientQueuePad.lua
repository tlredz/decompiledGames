local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BaseQueuePad = require(ReplicatedStorage.Modules.ReplicatedClass.BaseQueuePad)
local Signal = require(ReplicatedStorage.Modules.Signal)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local QueuePadTerminal = require(script:WaitForChild("QueuePadTerminal"))
local QueuePadVisuals = require(script:WaitForChild("QueuePadVisuals"))
local v = {
	"Model",
	"CanSelfQueue",
	"NumTeams",
	"PlayersPerTeam",
	"InfinitePlayersPerTeam",
	"QueueName",
	"IsStarting",
	"IsLocked",
	"PlayersWaiting"
}
local object = setmetatable({}, BaseQueuePad)
object.__index = object

function object.new(p)
	local self = setmetatable(BaseQueuePad.new(p), object)
	self.Activity = Signal.new()
	self.LocalPlayerActivity = Signal.new()
	self.Visuals = QueuePadVisuals.new(self)
	self.Terminal = QueuePadTerminal.new(self)
	self._was_local_player_here = nil
	self:_Init()
	return self
end

function object.GetClientFightersWaiting(object2)
	local result = {}

	for k, v2 in pairs(object2:Get("PlayersWaiting")) do
		local fighters = {}

		for k2, _ in pairs(v2) do
			local fighter = FighterController:GetFighter((tonumber(k2)))

			if fighter then
				table.insert(fighters, fighter)
			end
		end

		result[k] = fighters
	end

	return result
end

function object.GetTeleportPosition(object2)
	local v2 = {}

	for i = 1, object2:Get("NumTeams") do
		table.insert(
			v2,
			{
				object2:Get("Model"):WaitForChild("Important"):WaitForChild("Team" .. i).Position,
				(object2:CountTeam(i))
			}
		)
	end

	table.sort(v2, function(a, b)
		return a[2] < b[2]
	end)
	return v2[1][1]
end

function object.Destroy(data)
	data.Activity:Destroy()
	data.LocalPlayerActivity:Destroy()
	data.Visuals:Destroy()
	data.Terminal:Destroy()
	BaseQueuePad.Destroy(data)
end

function object:_DetectLocalPlayerActivity()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update(p)
		self.Activity:Fire(p)
		local was_local_player_here = self:IsInQueue(Players.LocalPlayer) ~= nil

		if was_local_player_here or self._was_local_player_here then
			self.LocalPlayerActivity:Fire(p)
		end

		self._was_local_player_here = was_local_player_here
	end

	for _, v2 in pairs(v) do
		local v3 = v2
		self:GetDataChangedSignal(v2):Connect(function()
			update(v3) -- equivalent call inferred; original call site unknown
		end)
	end

	update(nil) -- equivalent call inferred; original call site unknown
end

function object:_Init()
	self:_DetectLocalPlayerActivity()
end

return object