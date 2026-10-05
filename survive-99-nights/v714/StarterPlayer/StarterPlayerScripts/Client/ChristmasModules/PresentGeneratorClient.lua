local PresentGeneratorClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)

function PresentAdded(instance)
	local pivot = instance:GetPivot()
	local v = pivot * CFrame.new(-7, 0, 0)
	Client.TweenModule.new(function(p)
		instance:PivotTo((v:Lerp(pivot, p)))
	end, 1.5):Play()
end

function GeneratorAdded(instance)
	if instance.Parent ~= workspace.Structures then
		return
	end

	local function countdown()
		local nextPresentTime = instance:GetAttribute("NextPresentTime")
		local countdownLabel = instance:WaitForChild("Main"):WaitForChild("CountdownLabel")

		while instance:GetAttribute("NextPresentTime") == nextPresentTime and instance.Parent do
			local v = nextPresentTime - workspace:GetServerTimeNow()
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

	instance:GetAttributeChangedSignal("NextPresentTime"):Connect(countdown)

	if instance:GetAttribute("NextPresentTime") then
		countdown()
	end
end

function PresentGeneratorClient.Init()
	Client.Utility.ForAllTagged("GeneratorPresent", PresentAdded)
	Client.Utility.ForAllTagged("PresentGenerator", GeneratorAdded)
end

return PresentGeneratorClient