local createVector = vector.create
local model = nil
local models = {}
return function(value: string)
	local v = value or "PART_DEBUG"
	local RunService = game:GetService("RunService")
	local v2 = RunService:IsClient() and "Client" or "Server"

	if not model then
		model = Instance.new("Model")
		model.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		model.Name = "PART_DEBUGGER_" .. v2
		model.Parent = workspace._WorldOrigin
	end

	if not models[v] then
		models[v] = Instance.new("Model")
		models[v].ModelStreamingMode = Enum.ModelStreamingMode.Persistent
		models[v].Name = v .. v2
		models[v].Parent = model
	end

	local part = Instance.new("Part")
	part.Name = debug.traceback()
	part.CanQuery = false
	part.CanTouch = false
	part.CanCollide = false
	part.CastShadow = false
	part.BrickColor = BrickColor.Red()
	part.Transparency = 0.9
	part.Anchored = true
	part.Size = createVector(1, 1, 1)
	part.Parent = models[v]
	return part
end