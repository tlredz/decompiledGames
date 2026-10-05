local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("RSVPService/Prompt")
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function(p: string)
			pcall(function()
				local eventRsvpStatusAsync = SocialService:GetEventRsvpStatusAsync((tostring(p)))

				if eventRsvpStatusAsync == Enum.RsvpStatus.None or eventRsvpStatusAsync == Enum.RsvpStatus.NotGoing then
					SocialService:PromptRsvpToEventAsync((tostring(p)))
				end
			end)
		end)
	end
}