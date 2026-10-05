return function(object)
	local v = nil
	local forcefield = game.ReplicatedStorage.ClientComponents.EasterEgg.EggModels["Falling Sky Egg (Forcefield)"].forcefield
	object.Maid:GiveTask(task.spawn(function()
		while task.wait() do
			local v2 = not object.State.Collectable

			if v == v2 then
				continue
			end

			v = v2

			if v2 then
				local clone = forcefield:Clone()
				clone.CanCollide = false
				clone.Size *= 1.1
				clone.Parent = object.Egg
				object.Maid:GiveTask(task.spawn(function()
					local HSV, v4, v5 = Color3.toHSV(clone.Color)

					while clone.Parent do
						task.wait()
						clone.Color = Color3.fromHSV(HSV, math.sin(tick() * 1) * 0.5 + 0.5, v5)
					end
				end))
				local weld = Instance.new("Weld", clone)
				weld.Part0 = object.Egg:WaitForChild("indra egg")
				weld.Part1 = clone
				local clone2 = forcefield:Clone()
				clone2.CanCollide = false
				clone2.Size *= 1.2
				clone2.Parent = clone
				object.Maid:GiveTask(task.spawn(function()
					local HSV, v5, v6 = Color3.toHSV(Color3.new(0, 0, 1))

					while clone2.Parent do
						task.wait()
						clone2.Color = Color3.fromHSV(HSV, math.sin(tick() * 1.1) * 0.5 + 0.5, v6)
					end
				end))
				local weld2 = Instance.new("Weld", clone2)
				weld2.Part0 = clone
				weld2.Part1 = clone2
			else
				local forcefield2 = object.Egg:FindFirstChild("forcefield")

				if forcefield2 then
					forcefield2:Destroy()
				end

				local Effect = require(game.ReplicatedStorage.Effect)
				local death = Effect.new("Death")
				local model = Instance.new("Model")
				model.Name = ""
				Instance.new("Humanoid", model)
				local part = Instance.new("Part", model)
				part.Name = "HumanoidRootPart"
				local boundingBox, size = object.Egg:GetBoundingBox()
				part.CFrame = boundingBox
				part.Size = size
				part.Color = Color3.fromRGB(255, 255, 255)
				part.Transparency = 0.5
				local part2 = Instance.new("Part", model)
				part2.Name = "Head"
				local boundingBox2, size2 = object.Egg:GetBoundingBox()
				part2.CFrame = boundingBox2
				part2.Size = size2
				part2.Color = Color3.fromRGB(255, 255, 255)
				part2.Transparency = 0.5
				death:replicate({
					Character = model
				})
			end
		end
	end))
	object:ConnectTouched()
end