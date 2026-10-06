return {
	Setup = function(instance)
		local rightHand = instance.Model:FindFirstChild("RightHand")

		if not rightHand then
			return
		end

		local rootPart = rightHand:FindFirstChild("RootPart") or Instance.new("Motor6D")
		rootPart.Name = "RootPart"
		rootPart.Part0 = rightHand
		rootPart.C0 = CFrame.new(-0.001, -0.214, -0.008) * CFrame.Angles(0, 1.5707963267948966, 0)
		rootPart.Parent = rightHand
		local clone = instance:Clone("ClimaTact")

		if clone then
			rootPart.Part1 = clone.Roots.RootPart
			instance:AttachToModel(clone)
			instance.ClimaTact = clone
		end
	end,
	Steps = {
		{
			Marker = "Cast",
			Run = function(instance)
				instance:Sound("Storm")
				instance.Effect = instance:Cache(instance:Clone("Effect"))

				if instance.Effect then
					instance.Effect:PivotTo(CFrame.new(instance.Goal))
				end
			end
		},
		{
			Marker = "Explode",
			Run = function(object)
				object:Sound("Thunder")

				if object.Effect then
					object:Emit(object.Effect)
				end

				object:Shake({
					Amplitude = 2,
					Frequency = 0.1,
					FadeOutTime = 0.5
				})
				object:Impact({
					Duration = 0.25,
					TintColor = Color3.fromRGB(255, 252, 60)
				})
				object:Blur({
					Size = 20
				})
				object:Rock("Crater", CFrame.new(object.Goal), 7, 7, 13, false)
			end
		},
		{
			Marker = "Finish",
			Run = function(instance)
				if instance.Effect then
					instance:Disable(instance.Effect)
					instance:Debris(instance.Effect, 3)
				end

				if instance.ClimaTact then
					instance:Destroy(instance.ClimaTact)
				end
			end
		}
	}
}