local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
return {
	OpenChest = function(instance, flag: boolean)
		local chestLid = instance:WaitForChild("ChestLid")

		if flag then
			chestLid:Destroy()
			return
		end

		local pivot = chestLid:GetPivot()
		Client.Events.RequestOpenItemChest:FireServer(instance)
		task.spawn(function()
			for _, emitter in pairs(instance.ItemDrop.Attachment:GetChildren()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
				end
			end
		end)

		for _, part in pairs(chestLid:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
		end

		local v = 0
		local total = 0
		Client.TweenModule.new(function(p, p2)
			total += 240 * p2
			local v2 = v + p
			local v3 = pivot + Vector3.new(0, v2, 0)
			local v4 = 1

			if p < 0.1 then
				v4 *= p / 0.1
			end

			local v5 = math.sin((math.rad(total)))
			local v6 = math.cos((math.rad(total)))
			chestLid:PivotTo(v3 * CFrame.Angles(math.rad(v5) * 8 * v4, 0, math.rad(v6) * 8 * v4) + -CFrame.Angles(
				0,
				math.rad(total),
				0
			).LookVector * 0.8 * v4)
		end, 5):Play()
		Client.TweenModule.new(function(p)
			v = 4 * p
		end, 2, "Expo"):Play()
		task.delay(0.25, function()
			local parts = {}

			for _, part in pairs(chestLid:GetDescendants()) do
				if part:IsA("BasePart") then
					table.insert(parts, part)
				end
			end

			Client.TweenModule.new(function(_, p)
				for _, v2 in pairs(parts) do
					v2.Transparency += p
				end
			end, 1.5):Play()
			task.wait(1.5)
			chestLid:Destroy()
		end)
	end
}