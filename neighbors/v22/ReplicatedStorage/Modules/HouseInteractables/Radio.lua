game:GetService("ReplicatedStorage")
game:GetService("RunService")
local SoundService = game:GetService("SoundService")
game:GetService("TweenService")
local BaseInteractable = require(script.Parent.BaseInteractable)
local v = {
	15708078611,
	15717884519,
	15720429397,
	15840169591,
	95370226927778,
	15708078611,
	15841420825,
	15840819602,
	124588402711140,
	15708078611,
	15709023237,
	15840169209
}
return function(instance)
	local v2 = BaseInteractable.new()
	local v3 = {}

	for k, v4 in v do
		local sound = Instance.new("Sound")
		sound.Name = `Radio${v4}`
		sound.SoundId = `rbxassetid://{v4}`
		sound.RollOffMaxDistance = 45
		sound.RollOffMinDistance = 15
		sound.Volume = 1.5
		sound.RollOffMode = Enum.RollOffMode.InverseTapered
		sound.SoundGroup = SoundService.Radio
		sound.Parent = nil
		v3[k] = sound
	end

	local function GetPlaybackLoudness()
		local total = 0

		for _, v4 in v3 do
			total += v4.PlaybackLoudness
		end

		return total
	end

	local function GetPlaybackPosition(serverTimeNow: number)
		local total = 0

		for _, v4 in v3 do
			total += v4.TimeLength / v4.PlaybackSpeed
		end

		local v4 = serverTimeNow % total

		for _, v7 in v3 do
			local v8 = v7.TimeLength / v7.PlaybackSpeed

			if v4 - v8 < 0 then
				return v7, v4 * v7.PlaybackSpeed
			else
				v4 -= v8
			end
		end

		return nil, 0
	end

	function v2.Run(p)
		local state = p.State

		for _, part in instance:GetChildren() do
			if part.Name == "Light" and part:IsA("BasePart") then
				part.Material = state and Enum.Material.Neon or Enum.Material.SmoothPlastic
			end
		end

		if state then
			local click = instance:FindFirstChild("Click")
			local pushbutton = click and click:FindFirstChild("pushbutton")

			if pushbutton and pushbutton:IsA("Sound") then
				pushbutton:Play()
			end

			local v4, timePosition = GetPlaybackPosition(workspace:GetServerTimeNow())

			while p.State do
				for _, v6 in v3 do
					if v6 == v4 then
						v6.TimePosition = timePosition
						v6.Parent = instance.PrimaryPart
						v6:Play()
						v6.Ended:Wait()
					end

					v6.Parent = nil
				end

				local index = table.find(v3, v4)

				if index then
					local v6 = index + 1

					if not (#v3 < v6) then
						for i = v6, #v3 do
							if not p.State then
								break
							end

							local v7 = v3[i]
							v7.Parent = instance.PrimaryPart
							v7.TimePosition = 0
							v7:Play()
							v7.Ended:Wait()
							v7.Parent = nil
						end
					end
				end

				v4 = v3[1]
				timePosition = 0
			end
		else
			for _, v4 in v3 do
				v4.Parent = nil
				v4:Stop()
			end
		end
	end

	for _, parent in { instance:FindFirstChild("Click") } do
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.Parent = parent
		clickDetector.MaxActivationDistance = 12
		clickDetector.MouseClick:Connect(function()
			v2:ToggleState()
		end)
	end

	return v2
end