local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Trove = require(packages.Trove)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local v = Component.new({
	Tag = "CarbonCheeto",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
end

function v:FallAsleep()
	local snoring = self.Instance:FindFirstChild("Snoring", true)

	if snoring and snoring:IsA("Sound") and not snoring.IsPlaying then
		snoring:Play()
	end

	local instance

	if self.Instance.Name == "Carbon" then
		instance = self.Instance
	else
		instance = self.Instance:FindFirstChild("Carbon")
	end

	local humanoid = instance and instance:FindFirstChildWhichIsA("Humanoid")
	local sleep = instance and instance:FindFirstChild("sleep")

	if humanoid and sleep and sleep:IsA("Animation") then
		local v2 = humanoid:FindFirstChildWhichIsA("Animator")

		if not v2 then
			v2 = Instance.new("Animator")
			v2.Parent = humanoid
		end

		local track = v2:LoadAnimation(sleep)
		track.Priority = Enum.AnimationPriority.Action
		track.Looped = true
		track:Play()
	end
end

function v:Start()
	local questFinished = legacyLocalPlayerData.fetch():WaitForChild("QuestFinished")

	if questFinished:FindFirstChild("SFQ-Carbon") then
		self:FallAsleep()
	else
		self.trove:Connect(questFinished.ChildAdded, function(p)
			if p.Name == "SFQ-Carbon" then
				task.delay(6, function()
					if self.Instance.Parent then
						self:FallAsleep()
					end
				end)
			end
		end)
	end
end

function v.Stop(p)
	p.trove:Clean()
end

return v