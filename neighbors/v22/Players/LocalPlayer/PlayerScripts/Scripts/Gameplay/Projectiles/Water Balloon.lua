return {
	Impact = function(_, data, _)
		math.random(3, 5)
		local clone = script.HitEffect:Clone()
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = clone
		weldConstraint.Part1 = data.Instance
		clone.CFrame = CFrame.new(data.Position, data.Position + data.Normal)
		weldConstraint.Parent = clone
		clone.Parent = data.Instance

		for _, emitter in clone.Attachment:GetChildren() do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 3)
	end
}