local AnalyticsClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("GuiService")
game:GetService("UserInputService")
game:GetService("ReplicatedStorage")

function getPlatform()
	return Client.Utility.GetPlatform()
end

function TrackFirstPerson()
	local total = 0
	local total2 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function SendFirstPerson()
		Client.Events.AnalyticsTimeFirstPerson:FireServer(total2, total)
		total = 0
		total2 = 0
	end

	task.spawn(function()
		local total3 = 0

		while true do
			total3 += wait(5)

			if Client.FirstPersonModule.IsVisible() then
				total2 += 5
			else
				total += 5
			end

			if not (total3 > 60) then
				continue
			end

			total3 = 0
			SendFirstPerson() -- equivalent call inferred; original call site unknown
		end
	end)
end

function AnalyticsClient.Init()
	Client.Events.RegisterDevice:FireServer(getPlatform())
	TrackFirstPerson()
end

return AnalyticsClient