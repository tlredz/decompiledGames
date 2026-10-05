local ChristmasWorkshopClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
Client.Events.TweenPresent:Connect(function(instance, cframe: CFrame, flag: boolean)
	if not instance then
		return
	end

	local pivot = instance:GetPivot()
	Client.TweenModule.new(function(p)
		local lerped = pivot:Lerp(cframe, p)
		instance:PivotTo(lerped)
		instance:SetAttribute("OrigCF", lerped)
	end, 1):Play()

	if flag then
		task.delay(0.75, function()
			Client.LavaClient.BurnItem(instance)
		end)
	end
end)

function FactoryAdded(instance)
	local countdownLabel = instance:WaitForChild("Main"):WaitForChild("CountdownLabel")

	local function countdown()
		local nextSpawnTime = instance:GetAttribute("NextSpawnTime")

		while instance:GetAttribute("NextSpawnTime") == nextSpawnTime and instance.Parent do
			local v = nextSpawnTime - workspace:GetServerTimeNow()
			local v2 = math.max(v - math.floor(v), 0)

			if v <= 0 then
				countdownLabel.Enabled = false
			else
				local v3 = math.floor(v / 60)
				local v4 = math.ceil(v % 60)
				local text = string.format("%01im %02is", v3, v4)
				countdownLabel.TextLabel.Text = text
				countdownLabel.Enabled = true
			end

			if v < 0 then
				task.wait(1)
			else
				task.wait(v2)
			end
		end
	end

	instance:GetAttributeChangedSignal("NextSpawnTime"):Connect(countdown)

	if instance:GetAttribute("NextSpawnTime") then
		countdown()
	end
end

function ChristmasWorkshopClient.Init()
	Client.Utility.ForAllTagged("PresentFactory", FactoryAdded)
end

return ChristmasWorkshopClient