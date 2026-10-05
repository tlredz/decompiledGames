local Astro = {}

function Astro.Initialize(instance, p)
	print("Astro Passive: Initializing Well Rested for", p.Name)
	local stats = instance:WaitForChild("Stats", 5)

	if not stats then
		warn("Astro Passive: Stats folder not found")
		return function() end
	end

	local staminaRegenModifier = stats:WaitForChild("StaminaRegenModifier", 5)

	if not staminaRegenModifier then
		warn("Astro Passive: StaminaRegenModifier not found after waiting")
		return function() end
	end

	local value = staminaRegenModifier.Value
	staminaRegenModifier.Value *= 1.5
	print("Astro Passive: Applied stamina regen boost (", value, "->", staminaRegenModifier.Value, ")")
	return function()
		print("Astro Passive: Cleaning up for", p.Name)
		local success, result = pcall(function()
			if staminaRegenModifier and staminaRegenModifier.Parent then
				staminaRegenModifier.Value /= 1.5
				print("Astro Passive: Removed stamina regen boost")
			end
		end)

		if not success then
			warn("Astro Passive: Cleanup error:", result)
		end
	end
end

function Astro.Activate(_, _, _) end

function Astro.Deactivate(_, _) end

function Astro.Cleanup(_, p)
	print("Astro Passive: Additional cleanup for", p.Name)
end

return Astro