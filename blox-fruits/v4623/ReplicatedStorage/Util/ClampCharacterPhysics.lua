local function ClampCharacterPhysics(instance, _: number)
	local RunService = game:GetService("RunService")
	RunService.Heartbeat:Once(function(_: number)
		local assemblyLinearVelocity = instance.AssemblyLinearVelocity
		local magnitude = assemblyLinearVelocity.Magnitude

		if magnitude > 300 then
			instance.AssemblyLinearVelocity = assemblyLinearVelocity.Unit * math.clamp(magnitude, 0, 300)
		end
	end)
end

return ClampCharacterPhysics