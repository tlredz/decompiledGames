local RunService = game:GetService("RunService")
local import = _G.import("event")

if RunService:IsClient() then
	local import2 = _G.import("clientUtil")
	import.remoteConnect("freeze", function(p)
		import2.sound("IceSound")
		import.fire("freeze", p)
	end)
end

return {
	Frosty = {
		Info = {
			DisplayName = "Frosty",
			Description = "Freeze time",
			PetDescription = "Every 5 rounds, freeze time for 10 seconds",
			RotationCooldown = 5,
			TurnPlayer = true,
			Duration = 10
		},
		Triggers = function(_)
			return {
				{
					Event = "AnswerBegan",
					Condition = function()
						return true
					end
				}
			}
		end,
		Execute = function(p, object, _)
			local duration = p.Duration or 10
			local round = object.Round
			object:addEffect(object, "FrostyAura", {
				Duration = duration
			})
			object:addActivation("Round", function()
				task.defer(function()
					if object.Round ~= round then
						return
					end

					import.firePlayers(object:players(), "PauseTimer")
					import.firePlayers(object:players(), "freeze", duration)
				end)
			end)
			task.delay(duration, function()
				if object.Round ~= round then
					return
				end

				import.firePlayers(object:players(), "PlayTimer", object.RoundTimer)
			end)
		end
	}
}