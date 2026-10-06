-- equivalent calls inferred from this helper; original call sites unknown
local function PlayPunch(object, p: number)
	object:Sound("Punch" .. (p - 1) % 2 + 1, {
		Group = object.Fighter,
		MaxVoices = 3
	})
end

local steps = {
	{
		Marker = "Aura",
		Run = function(object)
			object:Sound("Aura")

			if object.Effect then
				object:Enable(object.Effect.Wind)
			end
		end
	},
	{
		Marker = "Hit Start",
		Run = function(object)
			local v2 = {
				Group = object.Fighter,
				MaxVoices = 3
			}
			object:Sound("Punch" .. 1, v2)

			if object.Effect then
				object:Enable(object.Effect.Impacts)
			end

			object:Shake({
				Amplitude = 1.5,
				Frequency = 0.05,
				SustainTime = 1.5,
				FadeOutTime = 0.23
			})
		end
	}
}

for i = 2, 9 do
	local v2 = i
	table.insert(steps, {
		Time = (i - 1) / 9 * 1.73 + 0.35,
		Run = function(object)
			PlayPunch(object, v2) -- equivalent call inferred; original call site unknown
		end
	})
end

table.insert(steps, {
	Marker = "Hit End",
	Run = function(object)
		local v2 = {
			Group = object.Fighter,
			MaxVoices = 3
		}
		object:Sound("Punch" .. 2, v2)

		if object.Effect then
			object:Disable(object.Effect)
			object:Debris(object.Effect, 3)
		end
	end
})
return {
	Setup = function(instance)
		instance.Effect = instance:Cache(instance:Clone("Effect"))

		if instance.Effect then
			instance.Effect:PivotTo(instance.HRP.CFrame)
			instance:SetPart0(instance.Effect, instance.HRP)
		end
	end,
	Steps = steps
}