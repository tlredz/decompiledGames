return {
	Setup = function(instance)
		local clone = instance:Clone("Wings")

		if clone then
			instance:SetPart0(clone, instance.HRP)
			instance:AttachToModel(clone)
			instance.Wings = clone
		end
	end,
	Steps = {
		{
			Marker = "Cast",
			Run = function(instance)
				instance:Sound("Cast")
				instance.Effect = instance:Cache(instance:Clone("Effect"))

				if instance.Effect then
					instance.Effect:PivotTo(CFrame.new(instance.Goal))
				end
			end
		},
		{
			Marker = "Explode",
			Run = function(instance)
				instance:Sound("Explosion")

				if instance.Effect then
					instance:Disable(instance.Effect)
					instance:Debris(instance.Effect, 3)
				end

				local clone = instance:Clone("Explosion")

				if clone then
					clone.Position = instance.Goal - Vector3.new(0, instance.Enemy.MediumSize - 0.5, 0)
					instance:Cache(clone)
					instance:Emit(clone)
					instance:Debris(clone, 10)
				end

				instance:Shake({
					Amplitude = 1,
					Frequency = 1,
					FadeOutTime = 1
				})
				instance:Impact({
					Duration = 1,
					TintColor = Color3.fromRGB(255, 95, 202)
				})
				instance:Blur({
					InTime = 0.1,
					OutTime = 0.9,
					Size = 30
				})
			end
		},
		{
			Marker = "Finish",
			Run = function(instance)
				if instance.Wings then
					instance:Destroy(instance.Wings)
				end
			end
		}
	}
}