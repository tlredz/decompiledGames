return {
	Steps = {
		{
			Time = 1.65,
			Run = function(object)
				object:Sound("Dash")
			end
		},
		{
			Marker = "Hit",
			Run = function(instance)
				instance:Sound("Sting")
				local v = instance.Goal - Vector3.new(0, instance.Enemy.MediumSize, 0)
				instance.Effect = instance:Cache(instance:Clone("Effect"))

				if instance.Effect then
					instance.Effect:PivotTo(CFrame.new(instance.GoalCFrame.Position) * instance.Origin.Rotation)
					instance:Emit(instance.Effect)
					instance:Enable(instance.Effect.Butterflies)
				end

				instance:Shake({
					Position = instance.Origin.Position,
					Amplitude = 2,
					Frequency = 0.05,
					FadeOutTime = 0.25
				})
				instance:Impact({
					Position = instance.Origin.Position,
					Duration = 0.25,
					TintColor = Color3.fromRGB(243, 28, 250)
				})
				instance:Blur({
					Position = instance.Origin.Position,
					Size = 20
				})
				instance:Rock("Explosion", CFrame.new(v), 8, 0.5, 1.6, false)
			end
		},
		{
			Marker = "End",
			Run = function(object)
				if object.Effect then
					object:Disable(object.Effect.Butterflies)
					object:Debris(object.Effect, 3)
				end
			end
		}
	}
}