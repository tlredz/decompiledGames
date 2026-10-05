local RunService = game:GetService("RunService")
local module = require("../SimpleFetchQuests")
local SimpleFetchQuests = {}

for k, v in module do
	SimpleFetchQuests[`SFQ-{k}`] = {
		DisplayName = v.QuestName or k,
		Icon = v.Icon or "rbxassetid://18162767851",
		IconColor = v.IconColor or Color3.fromRGB(0, 0, 0),
		QuestType = v.Type or "Side",
		AcceptIndicatorTag = k,
		NavigationTargets = not v.NoNavigate and ({
			{
				Zone = v.Location,
				Tags = { k },
				AllComplete = true
			}
		} or nil) or nil,
		ExpiresAt = v.ExpiresAt,
		Description = v.QuestDescription or "",
		CompletedDescription = v.CompleteDescription or "",
		DisplayList = v.DisplayObjectives,
		List = RunService:IsClient() and v.DisplayObjectives or v.Objectives,
		Rewards = v.Rewards
	}
end

return SimpleFetchQuests