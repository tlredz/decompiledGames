local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local LobbyElement = require(Players.LocalPlayer.PlayerScripts.Modules.LobbyElement)
local object = setmetatable({}, LobbyElement)
object.__index = object

function object._new(...)
	local self = setmetatable(LobbyElement.new(...), object)
	self:_Init()
	return self
end

function object.Update(object2, _)
	for _, v in pairs(CollectionService:GetTagged("LobbyDuelsSign")) do
		local now = tick()
		v.Yellow:PivotTo(object2:_GetOriginalPivot(v.Yellow) + Vector3.new(0, math.cos(now) ^ 3 - math.sin(now) ^ 3, 0) * 0.5)
		v.Purple:PivotTo(object2:_GetOriginalPivot(v.Purple) + Vector3.new(
			0,
			math.cos(now - 3.141592653589793) ^ 3 - math.sin(now - 3.141592653589793) ^ 3,
			0
		) * 0.5)
	end
end

function object:_Setup()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function object_added(instance)
		local duels = instance:WaitForChild("Screen"):WaitForChild("Duels")
		duels.Enabled = CONSTANTS.QUEUES_ACTIVE
		local play = instance:WaitForChild("Screen"):WaitForChild("Play")
		play.Enabled = not CONSTANTS.QUEUES_ACTIVE
	end

	CollectionService:GetInstanceAddedSignal("LobbyDuelsSign"):Connect(object_added)

	for _, v in pairs(CollectionService:GetTagged("LobbyDuelsSign")) do
		object_added(v) -- equivalent call inferred; original call site unknown
	end
end

function object:_Init()
	self:_Setup()
end

return object._new()