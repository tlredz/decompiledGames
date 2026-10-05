local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GlobalParams = require(ReplicatedStorage.Util.GlobalParams)
return function(folder, p, flag: boolean?)
	local worldPosition = folder:IsA("Attachment") and folder.WorldPosition or folder:IsA("Model") and folder:GetPivot().Position or folder.Position
	local v = p or workspace:Raycast(worldPosition, createVector(-0, -100, -0), GlobalParams)

	for _, emitter in folder:GetDescendants() do
		if not (emitter:IsA("ParticleEmitter") and emitter.Name == "ColorSmoke") then
			continue
		end

		if v then
			if v and flag then
				local clone = emitter:Clone()
				print("[Debug] Cloned 'ColorSmoke' Particle ")
				emitter.Enabled = false
				local v2 = emitter
				task.delay(v2.Lifetime.Max, function()
					v2:Destroy()
					v2 = nil
				end)
				clone.Parent = emitter.Parent
				emitter = clone
			end

			emitter.Color = ColorSequence.new(v.Instance.Color) or emitter.Color
		else
			emitter:Destroy()
			print("No Ray Results")
		end
	end
end