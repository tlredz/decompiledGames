local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local MatchmakingQueueSlot = require(Players.LocalPlayer.PlayerScripts.Modules.BaseMatchmakingQueueSlot.MatchmakingQueueSlot)
local Queues = {}
Queues.__index = Queues

function Queues.new(page)
	local self = setmetatable({}, Queues)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("Queues")
	self:_Init()
	return self
end

function Queues:Open() end

function Queues.Close(_) end

function Queues._Generate(p, p2)
	local v = Utility:WaitForChildRecursive(p.Frame, p2, 3)

	if not v then
		return
	end

	MatchmakingQueueSlot.new(p2, v).QueueStatus:Connect(function(value)
		if value == "Success" then
			p.Page.Closed:Fire()
		else
			p.Page.PromptSystem:Open("ErrorMessage", "Whoops!", value or "Server failed to respond, please try again")
		end
	end)
end

function Queues:_Setup()
	for _, rankedQueue in pairs(SeasonLibrary.CurrentSeason.RankedQueues) do
		task.defer(self._Generate, self, rankedQueue[1])
	end
end

function Queues:_Init()
	self:_Setup()
end

return Queues