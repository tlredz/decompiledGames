local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local random = Random.new()

function ConsumeParticles(cFrame)
	if localPlayer.Character then
		local v = false

		for _ = 1, math.random(7, 9) do
			task.spawn(function()
				local clone = game.ReplicatedStorage.Assets.Particles.Necromancer.TrailPart:Clone()
				clone.Parent = workspace.Particles
				clone.CFrame = cFrame
				local v2 = math.random(0, 360)
				local v3 = math.cos((math.rad(v2))) * 2
				local v4 = math.sin((math.rad(v2))) * 2
				local v5 = Vector3.new(v3, 1 + math.random(0, 1), v4) * 6
				local total = 0

				while true do
					local v6 = task.wait()
					total += v6

					if not localPlayer.Character or total >= 10 then
						break
					end

					clone.Position += v5.Unit * v6 * math.clamp(total / 3, 0.5, 1.5) * 50

					if (clone.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude < 0.5 then
						if not v then
							v = true
							Client.Sound.Play("CollectSoul")
						end

						task.wait(2)
						break
					else
						local v7 = localPlayer.Character.HumanoidRootPart.Position - clone.Position
						v5 = v5.Unit + v7.Unit * total
					end
				end

				clone:Destroy()
			end)
		end
	end
end

Client.Events.AddSoul:Connect(function(cFrame, p)
	local clone = game.ReplicatedStorage.Assets.Particles.Necromancer.Soul:Clone()
	clone:PivotTo(cFrame)
	clone.Parent = workspace.Particles
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.Transparency = 1
	part.Size = createVector(30, 30, 30)
	part.CFrame = cFrame
	part.Parent = workspace.Particles
	local flag = false

	local function consume()
		if flag then
			return
		end

		flag = true
		part:Destroy()
		ConsumeParticles(cFrame)
		Client.Events.NecromancerClaimSoul:FireServer(p)

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		task.delay(5, function()
			clone:Destroy()
		end)
	end

	local v = random:NextInteger(15, 30) / 10
	task.delay(v, function()
		if localPlayer.Character then
			local touchingParts = part:GetTouchingParts()

			for _, touchingPart in pairs(touchingParts) do
				if touchingPart == localPlayer.Character.PrimaryPart then
					consume()
				end
			end
		end

		if part.Parent then
			part.Touched:Connect(function(otherPart)
				if localPlayer.Character and otherPart == localPlayer.Character.PrimaryPart then
					consume()
				end
			end)
		end
	end)
end)
return {}