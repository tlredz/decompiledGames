local _001_TrafficCones = workspace:WaitForChild("WorkspaceCom"):FindFirstChild("001_TrafficCones")
return {
	Name = "prop_getPropOwner",
	Aliases = {},
	Description = "Gets the owner of a prop",
	Group = "Prop",
	Args = {},
	ClientRun = function(p)
		local mouse = p.Executor:GetMouse()

		if not mouse.Target then
			return "No prop found"
		end

		for _, model in ipairs(_001_TrafficCones:GetChildren()) do
			if model:IsA("Model") and mouse.Target:IsDescendantOf(model) then
				return model.Name:sub(5)
			end
		end

		return "No prop found"
	end
}