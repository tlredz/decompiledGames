local createVector = vector.create
local Debris = require(game.ReplicatedStorage.Util.Debris)
local FX = require(game.ReplicatedStorage.FX)
local splashRing = FX:WaitForChild("RaceAwakenings").SplashRing
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local splashRing2 = character:FindFirstChild("splashRing")
	local humanoid = nil
	local flag = false
	local v = false
	local updateRing

	if splashRing2 or not character:FindFirstChild("Humanoid") or character.Humanoid.ClassName ~= "Humanoid" then
		updateRing = function() end
	else
		splashRing2 = splashRing.splashRing:Clone()
		humanoid = character.Humanoid
		local renderSteppedConnection = nil
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not (character and character:IsDescendantOf(game)) or humanoid.Health <= 0 then
				return renderSteppedConnection:Disconnect()
			end

			local v2 = CFrame.new(0, -character.Humanoid.HipHeight - humanoidRootPart.Size.Y / 2 + 0.3, 0) * CFrame.Angles(
				0,
				0,
				1.5707963267948966
			)
			splashRing2.CFrame = humanoidRootPart.CFrame * v2
			splashRing2.Attachment.WorldCFrame = CFrame.new(
				splashRing2.CFrame.p * createVector(1, 0, 1),
				createVector(0, 0, 0)
			) + Vector3.new(0, splashRing2.CFrame.p.Y, 0)
		end)
		local clone = nil
		local ambientReverbChangedConnection = nil

		updateRing = function()
			local children = splashRing2:FindFirstChild("Levels") and splashRing2.Levels:GetChildren() or {}

			if #children == 0 or v then
				if ambientReverbChangedConnection then
					ambientReverbChangedConnection:Disconnect()
				end

				if clone then
					clone:Destroy()
				end

				local SoundService = game:GetService("SoundService")

				if SoundService:GetAttribute("RealReverb") then
					local SoundService2 = game:GetService("SoundService")
					local reverbType = Enum.ReverbType
					local SoundService3 = game:GetService("SoundService")
					SoundService2.AmbientReverb = reverbType[SoundService3:GetAttribute("RealReverb")]
				end

				if not splashRing2:IsDescendantOf(workspace) then
					renderSteppedConnection:Disconnect()
					return
				end

				Debris:AddItem(splashRing2, 3, function()
					renderSteppedConnection:Disconnect()
				end)

				for _, emitter in pairs(splashRing2:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				splashRing2.Name = "Debris"
				splashRing2.Parent = workspace._WorldOrigin
			else
				local v2 = 0

				for _, v3 in pairs(children) do
					v2 = math.max(v3.Value, v2)
				end

				for i = 1, 5 do
					local findFirstChild = splashRing2:FindFirstChild("Level" .. i, true)
					findFirstChild.Enabled = i <= v2
				end
			end
		end

		splashRing2.Levels.ChildAdded:Connect(updateRing)
		splashRing2.Levels.ChildRemoved:Connect(updateRing)
		splashRing2.Parent = character
		local v2 = CFrame.new(0, -character.Humanoid.HipHeight - humanoidRootPart.Size.Y / 2 + 0.3, 0) * CFrame.Angles(
			0,
			0,
			1.5707963267948966
		)
		Instance.new("Weld", splashRing2)
		splashRing2.CFrame = humanoidRootPart.CFrame * v2

		if character == game.Players.LocalPlayer.Character then
			clone = splashRing.UnderwaterBubbles:Clone()
			clone.Parent = game.Players.LocalPlayer.PlayerGui
			clone:Play()
			local SoundService = game:GetService("SoundService")
			local SoundService2 = game:GetService("SoundService")
			SoundService:SetAttribute("RealReverb", SoundService2.AmbientReverb.Name)
			local SoundService3 = game:GetService("SoundService")
			SoundService3.AmbientReverb = Enum.ReverbType.UnderWater
			local SoundService4 = game:GetService("SoundService")
			ambientReverbChangedConnection = SoundService4:GetPropertyChangedSignal("AmbientReverb"):Connect(function()
				local SoundService5 = game:GetService("SoundService")
				local SoundService6 = game:GetService("SoundService")
				SoundService5:SetAttribute("RealReverb", SoundService6.AmbientReverb.Name)
				local SoundService7 = game:GetService("SoundService")
				SoundService7.AmbientReverb = Enum.ReverbType.UnderWater
			end)
		end
	end

	if splashRing2 then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Level"
		numberValue.Value = player.Level
		numberValue.Parent = splashRing2.Levels
		local diedConnection = nil

		if humanoid then
			diedConnection = humanoid.Died:Connect(function()
				if flag then
					return
				end

				flag = true
				v = true
				diedConnection:Disconnect()
				numberValue:Destroy()
				updateRing()
			end)
		end

		task.wait(player.Expires - workspace:GetServerTimeNow())
		flag = true

		if diedConnection then
			diedConnection:Disconnect()
			diedConnection = nil
		end

		numberValue:Destroy()
		updateRing()
	end
end