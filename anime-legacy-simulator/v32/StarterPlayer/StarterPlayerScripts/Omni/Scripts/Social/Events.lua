local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Omni = require(ReplicatedStorage:WaitForChild("Omni"))
local Events = {}

local function GetNextEvent()
	local success, result = pcall(function()
		return Omni.Services.SocialService:GetUpcomingExperienceEventsAsync()
	end)

	if not success then
		return
	end

	for _, v in result do
		if not (v.HasStarted or v.HasEnded) then
			return v
		end
	end
end

function Events.PromptToFollow()
	local nextEvent = GetNextEvent()

	if not (nextEvent and nextEvent.UserRsvpStatus ~= Enum.RsvpStatus.Going) then
		return
	end

	pcall(function()
		return Omni.Services.SocialService:PromptRsvpToEventAsync(nextEvent.Id)
	end)
end

Omni.Libs.ThreadSaver.New(function()
	while task.wait(900) do
		Events.PromptToFollow()
	end
end)
return Events