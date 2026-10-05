local Debris = game:GetService("Debris")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local _ = {
	SLOW_SPEED = 4,
	DURATION = 3,
	SOUND_ID = "rbxassetid://128475171868078",
	SOUND_VOL = 0.4
}
return {
	Run = function(player)
		local character = player.Character

		if not character then
			return
		end

		local humanoid = character:FindFirstChild("Humanoid")
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if not (humanoid and humanoidRootPart) then
			return
		end

		local sound = Instance.new("Sound")
		sound.Name = "TurtleSound"
		sound.SoundId = "rbxassetid://128475171868078"
		sound.Volume = 0.4
		sound.PlaybackSpeed = 0.6
		sound.Parent = SoundService
		sound:Play()
		Debris:AddItem(sound, 4)
		local v = os.clock() + 3
		humanoid:SetAttribute("TurtleResetTime", v)
		humanoid.WalkSpeed = 4
		task.delay(3, function()
			if humanoid and humanoid.Parent then
				local turtleResetTime = humanoid:GetAttribute("TurtleResetTime")

				if turtleResetTime and turtleResetTime <= v + 0.05 then
					local v2 = ClientState:Get()
					local customWalkSpeed = v2.CustomWalkSpeed and v2.CustomWalkSpeed > 0 and v2.CustomWalkSpeed or Config.CalculateMaxSpeed(v2.Level)
					humanoid.WalkSpeed = customWalkSpeed
				end
			end
		end)
	end
}