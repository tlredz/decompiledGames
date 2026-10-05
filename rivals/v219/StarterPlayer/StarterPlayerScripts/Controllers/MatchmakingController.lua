local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass)
local Signal = require(ReplicatedStorage.Modules.Signal)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local v = {
	"ServerRegion",
	"MatchmadeStatus",
	"MatchmadeExpectedPlayers",
	"MatchmadeConnectedPlayers",
	"MatchmadeGameOver",
	"MatchmadeCountdown",
	"MatchmadeRematchAvailable",
	"MatchmadeRematchCount",
	"MatchmadeRematchGoal",
	"MatchmadeRematchSuccess"
}
local object = setmetatable({}, ReplicatedClass)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedClass.new(), object)
	self.MatchmadeDuelEnded = Signal.new()
	self.RematchDetailsChanged = Signal.new()
	self:_Init()
	return self
end

function object.IsMatchmadeDuelOver(object2)
	return CONSTANTS.IS_MATCHMAKING_SERVER and object2:Get("MatchmadeGameOver")
end

function object.IsRematchAvailable(object2)
	return object2:Get("MatchmadeRematchSuccess") or object2:Get("MatchmadeRematchCount") and object2:Get("MatchmadeRematchGoal") and object2:Get("MatchmadeRematchAvailable")
end

function object:QueueInto(p)
	return ReplicatedStorage.Remotes.Matchmaking.JoinQueue:InvokeServer(p)
end

function object.TryLeaveQueue(_)
	ReplicatedStorage.Remotes.Matchmaking.TryLeaveQueue:FireServer()
end

function object:_OnboardingQueue()
	if CONSTANTS.IS_STUDIO or CONSTANTS.IS_PRIVATE_HUB_SERVER or PlayerDataController:GetStatistic("StatisticDuelsPlayed") > 0 then
		return
	end

	self:QueueInto(CONSTANTS.BEGINNER_QUEUE_NAME)
end

function object:_Setup()
	for _, v2 in pairs(v) do
		-- equivalent calls inferred from this helper; original call sites unknown
		local v4 = v2

		local function update()
			self:SetReplicate(v4, workspace:GetAttribute(v4))
		end

		local v5 = v2
		local v6 = string.find(v2, "Rematch")
		workspace:GetAttributeChangedSignal(v2):Connect(function()
			update() -- equivalent call inferred; original call site unknown

			if v6 then
				self.RematchDetailsChanged:Fire()
			end
		end)
		update() -- equivalent call inferred; original call site unknown
	end
end

function object:_Init()
	self:GetDataChangedSignal("MatchmadeGameOver"):Connect(function()
		self.MatchmadeDuelEnded:Fire()
	end)
	self:_Setup()
	task.defer(self._OnboardingQueue, self)
end

return object._new()