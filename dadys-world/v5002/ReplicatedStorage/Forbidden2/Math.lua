local Math = {}
local parent = script.Parent
local stdfunctions = require(parent:WaitForChild("Standard"):WaitForChild("stdfunctions"))

function Math.LineOfSight(p, p2, options: string, flag: boolean)
	local v = {
		range = 50,
		SeeThroughTransparentParts = false,
		filterTable = "default"
	}

	for k, v3 in pairs(options or {}) do
		v[k] = v3
	end

	local count = 0
	local v3 = {}
	local flag2 = false
	local folder = nil

	local function findBasePart(character, type: string)
		count += 1

		if type == "Player" then
			character = character.Character

			if character == nil then
				print("character does not exist")
				return false
			else
				type = "Model"
			end
		end

		if type == "Part" then
			v3[count] = character
		elseif type == "Model" then
			if count == 2 then
				flag2 = true
				folder = character
			end

			if character.PrimaryPart ~= nil then
				v3[count] = character.PrimaryPart
				return
			end

			if character:FindFirstChild("Humanoid") then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					flag2 = false
					folder = nil
				end

				if humanoidRootPart ~= nil then
					v3[count] = humanoidRootPart
					return
				end
			end

			v3[count] = character:GetChildren()[1]
		end
	end

	local type = stdfunctions.GetType(p)
	local type2 = stdfunctions.GetType(p2)
	local basePart = findBasePart(p, type)
	local basePart2 = findBasePart(p2, type2)

	if not flag then
		if basePart ~= nil then
			warn(basePart)
			return basePart
		end

		if basePart2 ~= nil then
			warn(basePart2)
			return basePart2
		end
	end

	local v4 = v3[1]
	local v5 = v3[2]
	local unit = (v5.Position - v4.Position).Unit
	local raycastParams = RaycastParams.new()
	local instances = { v4.Parent }

	if v.filterTable == "default" then
		raycastParams.FilterDescendantsInstances = instances
	else
		raycastParams.FilterDescendantsInstances = v.filterTable
	end

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastResult = nil

	local function raycast()
		raycastResult = nil
		raycastParams.FilterDescendantsInstances = instances
		raycastResult = workspace:Raycast(v4.Position, unit * v.range, raycastParams)

		if raycastResult then
			if raycastResult.Instance == v5 then
				return true
			end

			if flag2 then
				for _, descendant in pairs(folder:GetDescendants()) do
					if descendant == raycastResult.Instance then
						return true
					end
				end
			end

			return false
		elseif raycastResult == nil or not raycastResult then
			return false
		end
	end

	if not v.SeeThroughTransparentParts or v.SeeThroughTransparentParts == nil then
		return (raycast())
	end

	if v.SeeThroughTransparentParts then
		while true do
			local v7 = raycast()

			if not v7 then
				local transparency = 0
				local _, _ = pcall(function()
					transparency = raycastResult.Instance.Transparency
				end)

				if transparency > 0 then
					table.insert(instances, raycastResult.Instance)
				end

				if not (transparency > 0) then
					return v7
				end
			end

			if v7 then
				return v7
			end
		end
	end
end

function Math:Round()
	local type = stdfunctions.GetType(self)

	if type == "Vector3" then
		return (Vector3.new(math.round(self.X), math.round(self.X), (math.round(self.Z))))
	elseif type == "Number" then
		return (math.round(self))
	elseif type == "Integer" then
		return self
	end

	if type ~= "CFrame" then
		return
	end

	self.X = math.round(self.X)
	self.Y = math.round(self.Y)
	self.Z = math.round(self.Z)
	return self
end

function Math.InLocalView(model, flag: boolean)
	local v2 = true
	local localPlayer = game.Players.LocalPlayer
	local currentCamera = game.Workspace.CurrentCamera

	if model:IsA("Model") and model.PrimaryPart ~= nil then
		local _ = model.PrimaryPart
	end

	local worldToViewportPoint, v3 = currentCamera:WorldToViewportPoint(model.Position)
	local viewportPointToRay = currentCamera:ViewportPointToRay(worldToViewportPoint.X, worldToViewportPoint.Y, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local raycastResult = workspace:Raycast(
		viewportPointToRay.Origin,
		viewportPointToRay.Direction * 1000,
		raycastParams
	)

	if raycastResult == nil then
		return false
	end

	local v4 = raycastResult.Instance == model or false

	if flag then
		v2 = Math.LineOfSight(localPlayer.Character, model, {
			range = 100,
			SeeThroughTransparentParts = true,
			filterTable = { localPlayer.Character }
		})
	end

	if v3 and v4 and v2 then
		return true
	end

	return false
end

return Math