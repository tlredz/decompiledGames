local createVector = vector.create
local Debris = require(game.ReplicatedStorage.Util.Debris)
local FX = require(game.ReplicatedStorage.FX)
local lightningRing = FX:WaitForChild("RaceAwakenings").LightningRing
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local sparksRing = character:FindFirstChild("sparksRing")
	local v = false
	local flag = false
	local humanoid, updateRing

	if sparksRing or not character:FindFirstChild("Humanoid") or character.Humanoid.ClassName ~= "Humanoid" then
		humanoid = nil

		updateRing = function() end
	else
		sparksRing = lightningRing.sparksRing:Clone()
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
			sparksRing.CFrame = humanoidRootPart.CFrame * v2
			sparksRing.Attachment.WorldCFrame = CFrame.new(
				sparksRing.CFrame.p * createVector(1, 0, 1),
				createVector(0, 0, 0)
			) + Vector3.new(0, sparksRing.CFrame.p.Y, 0)
		end)

		updateRing = function()
			local children = sparksRing:FindFirstChild("Levels") and sparksRing.Levels:GetChildren() or {}

			if #children == 0 or v then
				if not sparksRing:IsDescendantOf(workspace) then
					renderSteppedConnection:Disconnect()
					return
				end

				Debris:AddItem(sparksRing, 3, function()
					renderSteppedConnection:Disconnect()
				end)

				for _, emitter in pairs(sparksRing:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end

				sparksRing.Name = "Debris"
				sparksRing.Parent = workspace._WorldOrigin
			else
				local v2 = 0

				for _, v3 in pairs(children) do
					v2 = math.max(v3.Value, v2)
				end

				for i = 1, 5 do
					local findFirstChild = sparksRing:FindFirstChild("Level" .. i, true)
					findFirstChild.Enabled = i <= v2
				end
			end
		end

		sparksRing.Levels.ChildAdded:Connect(updateRing)
		sparksRing.Levels.ChildRemoved:Connect(updateRing)
		sparksRing.Parent = character
		local v2 = CFrame.new(0, -character.Humanoid.HipHeight - humanoidRootPart.Size.Y / 2 + 0.3, 0) * CFrame.Angles(
			0,
			0,
			1.5707963267948966
		)
		Instance.new("Weld", sparksRing)
		sparksRing.CFrame = humanoidRootPart.CFrame * v2
		local Sound = require(game.ReplicatedStorage.Util.Sound)
		Sound:Play("ElectricLoopable2", sparksRing)
	end

	if sparksRing then
		local numberValue = Instance.new("NumberValue")
		numberValue.Name = "Level"
		numberValue.Value = player.Level
		numberValue.Parent = sparksRing.Levels
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