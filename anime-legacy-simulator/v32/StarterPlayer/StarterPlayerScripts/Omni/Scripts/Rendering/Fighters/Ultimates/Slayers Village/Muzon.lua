local createVector = vector.create

-- equivalent calls inferred from this helper; original call sites unknown
local function PlaySlash(object, p: number)
	object:Sound("Slash" .. (p - 1) % 3 + 1, {
		Group = object.Fighter,
		MaxVoices = 3
	})
end

local steps = {
	{
		Time = 0.14,
		Run = function(object)
			object:Sound("Charge")
		end
	},
	{
		Marker = "HitStart",
		Run = function(instance)
			instance:Sound("Impact")
			local v2 = {
				Group = instance.Fighter,
				MaxVoices = 3
			}
			instance:Sound("Slash" .. 1, v2)
			instance.Effect = instance:Cache(instance:Clone("Effect"))

			if instance.Effect then
				instance.Effect:ScaleTo(instance.Enemy.ModelScale)
				instance.Effect:PivotTo(instance.GoalCFrame)
			end

			instance:Shake({
				Position = instance.Origin.Position,
				Amplitude = 2,
				Frequency = 0.05,
				SustainTime = 1.35,
				FadeOutTime = 0.1
			})
			instance:Impact({
				Position = instance.Origin.Position,
				Duration = 0.25,
				TintColor = Color3.fromRGB(122, 14, 14)
			})
			instance:Blur({
				Position = instance.Origin.Position,
				Size = 20
			})
			instance.Fighter.Offset.Value = createVector(0, 0, -20)
		end
	}
}

for i = 2, 9 do
	local v2 = i
	table.insert(steps, {
		Time = (i - 1) / 9 * 1.4 + 0.6,
		Run = function(object)
			PlaySlash(object, v2) -- equivalent call inferred; original call site unknown
		end
	})
end

table.insert(steps, {
	Marker = "HitEnd",
	Run = function(object)
		local v2 = {
			Group = object.Fighter,
			MaxVoices = 3
		}
		object:Sound("Slash" .. 1, v2)

		if object.Effect then
			object:Disable(object.Effect)
			object:Debris(object.Effect, 3)
		end
	end
})
return {
	Steps = steps,
	Cleanup = function(p)
		p.Fighter.Offset.Value = createVector(0, 0, 0)
	end
}