local createVector = vector.create
return {
	Impact = function(p, data, p2)
		if not p2 then
			local clone = script.Assets.WorldSplat:Clone()

			if p.Object.Name == "Snowball" then
				clone.Size = createVector(2, 2, 0.001)
				clone.Decal.Texture = "rbxassetid://15579546246"
				clone.Decal.Color3 = Color3.new(1, 1, 1)
			else
				clone.Decal.Color3 = p.SplatColor
			end

			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Part0 = clone
			weldConstraint.Part1 = data.Instance
			clone.CFrame = CFrame.new(data.Position, data.Position + data.Normal)
			weldConstraint.Parent = clone
			clone.Parent = data.Instance
			local Debris = game:GetService("Debris")
			Debris:AddItem(clone, 5)
		end

		local clone

		if p.Object.Name == "Snowball" then
			clone = script.Assets.SnowballMist:Clone()
			clone.Fire:Emit(15)
		else
			clone = script.Assets.SplatMist:Clone()
			clone.Particle.Color = ColorSequence.new(p.SplatColor:Lerp(Color3.new(0, 0, 0), 0.2))
			clone.Particle:Emit(clone.Particle.Rate)
		end

		clone.Position = data.Position
		clone.Parent = workspace
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 2)
	end
}