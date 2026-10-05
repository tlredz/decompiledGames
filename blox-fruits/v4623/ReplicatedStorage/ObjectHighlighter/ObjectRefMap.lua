local createInstanceCopy = require(script.Parent.createInstanceCopy)
return {
	fromModel = function(folder, p)
		local v = false
		local primaryPart = nil
		local v3 = {}
		local globalMap = {}
		local instanceCopiesByHumanoid = {}
		local model

		if not p then
			model = Instance.new("Model")

			for _, humanoid in ipairs(folder:GetDescendants()) do
				local instanceCopy = createInstanceCopy(humanoid)

				if not instanceCopy then
					continue
				end

				instanceCopy.Parent = model
				globalMap[humanoid] = { instanceCopy }

				if instanceCopy:IsA("BasePart") then
					instanceCopiesByHumanoid[humanoid] = instanceCopy

					if not primaryPart and humanoid == folder.PrimaryPart then
						primaryPart = instanceCopy
					end
				elseif humanoid:IsA("Humanoid") and not v then
					v = true
				end
			end

			model.PrimaryPart = primaryPart
		end

		v3.map = instanceCopiesByHumanoid
		v3.rbx = model
		v3.worldModel = folder
		v3.globalMap = globalMap
		return v3
	end
}