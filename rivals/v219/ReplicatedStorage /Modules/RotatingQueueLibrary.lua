local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local ServerOsTime = require(ReplicatedStorage.Modules.ServerOsTime)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local _ = CONSTANTS.IS_TESTING_SERVER
local v = nil
local v2 = v or 86400
local v3 = math.floor(1755837328 / v2)
local RotatingQueueLibrary = {
	Info = {},
	Order = {},
	IsNewRelease = function(self)
		return self:GetCycle() <= 20539
	end,
	GetOsTime = function(self)
		return ServerOsTime:Get() - -590400
	end,
	GetCycle = function(self)
		return (math.floor(self:GetOsTime() / v2))
	end,
	GetTimeUntilNext = function(self)
		if self:IsNewRelease() then
			return 1774065600 - ServerOsTime:Get()
		end

		return (self:GetCycle() + 1) * v2 - self:GetOsTime()
	end
}

function RotatingQueueLibrary:GetCurrent()
	if self:IsNewRelease() then
		return RotatingQueueLibrary.Info.spleef
	end

	local v4 = math.max(CONSTANTS.IS_STUDIO and not v and 0 or -1e999, self:GetCycle() - v3)
	local v5 = RotatingQueueLibrary.Order[v4 % #RotatingQueueLibrary.Order + 1]
	return RotatingQueueLibrary.Info[v5]
end

function RotatingQueueLibrary:IsValidQueueName(p)
	return table.find(self:GetCurrent().QueueNames, p)
end

local function add_rotating_queues(name, ...)
	local v4 = {
		Name = name,
		QueueNames = { ... }
	}
	RotatingQueueLibrary.Info[name] = v4
	table.insert(RotatingQueueLibrary.Order, name)

	for _, queueName in pairs(v4.QueueNames) do
		assert(DuelLibrary.MatchmakingQueues[queueName] ~= nil, queueName)
	end
end

add_rotating_queues("juggernaut", "ltm_juggernaut_1v7")
add_rotating_queues("swiftstandoff", "ltm_swiftstandoff_1v1", "ltm_swiftstandoff_2v2", "ltm_swiftstandoff_3v3")
add_rotating_queues(
	"defaultduel_bunnysniping",
	"ltm_defaultduel_1v1",
	"ltm_defaultduel_2v2",
	"ltm_bunnysniping_2v2",
	"ltm_bunnysniping_3v3"
)
add_rotating_queues("tagteam", "ltm_tagteam_3v3", "ltm_tagteam_5v5")
add_rotating_queues(
	"chickengame",
	"ltm_chickengames_1v1",
	"ltm_chickengames_2v2",
	"ltm_chickengames_3v3",
	"ltm_chickengames_4v4"
)
add_rotating_queues("rivalsrng", "ltm_rivalsrng_1v1", "ltm_rivalsrng_2v2", "ltm_rivalsrng_3v3")
add_rotating_queues("headhoncho", "ltm_headhoncho_3v3", "ltm_headhoncho_4v4", "ltm_headhoncho_5v5")
add_rotating_queues("hardcoreparkour", "ltm_hardcoreparkour_1v1", "ltm_hardcoreparkour_2v2", "ltm_hardcoreparkour_5v5")
add_rotating_queues("doubletrouble", "ltm_doubletrouble_1v1", "ltm_doubletrouble", "ltm_doubletrouble_3v3")
add_rotating_queues("mirrormatchup", "ltm_mirrormatchup_1v1", "ltm_mirrormatchup_2v2", "ltm_mirrormatchup_3v3")
add_rotating_queues(
	"limitlessloadout",
	"ltm_limitlessloadout_1v1",
	"ltm_limitlessloadout_2v2",
	"ltm_limitlessloadout_3v3"
)
add_rotating_queues("threeteams", "1v1v1", "2v2v2", "3v3v3")
add_rotating_queues("spleef", "ltm_spleef_8v8")
return RotatingQueueLibrary