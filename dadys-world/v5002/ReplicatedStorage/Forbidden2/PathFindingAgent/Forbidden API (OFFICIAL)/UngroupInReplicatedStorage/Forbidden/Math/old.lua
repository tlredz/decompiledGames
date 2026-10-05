local createVector = vector.create
local Old = {}
local parent = script.Parent
local stdfunctions = require(parent:WaitForChild("Standard"):WaitForChild("stdfunctions"))
local MathVisualization = require(script:WaitForChild("MathVisualization"))

function Old.LineOfSight(p, p2, p3, flag: boolean?)
	if p == nil then
		warn("Object1 was nil!")
		return false
	end

	if p2 == nil then
		warn("Object2 was nil!")
		return false
	end

	local v = p3 == nil and {} or p3
	local v2 = {
		range = 50,
		MinimumTransparency = 0.01,
		SeeThroughTransparentParts = false,
		SeeThroughNonCollidable = false,
		filterTable = "default",
		filterAttempts = 15,
		OffsetFromOrigin = createVector(0, 0, 0),
		OffsetFromTarget = createVector(0, 0, 0),
		VisualizeRaycast = false,
		OutputCollision = false
	}

	for k, v4 in pairs(v) do
		v2[k] = v4
	end

	local count = 0
	local v4 = {}
	local flag2 = false
	local folder = nil

	local function findBasePart(character, type: string)
		count += 1

		if type == "Player" then
			character = character.Character

			if character == nil then
				warn("character does not exist")
				return false
			else
				type = "Model"
			end
		end

		if type == "Part" then
			v4[count] = character
		elseif type == "Model" then
			if count == 2 then
				flag2 = true
				folder = character
			end

			if character.PrimaryPart ~= nil then
				v4[count] = character.PrimaryPart
				return
			end

			if character:FindFirstChild("Humanoid") then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoidRootPart then
					flag2 = false
					folder = nil
				end

				if humanoidRootPart ~= nil then
					v4[count] = humanoidRootPart
					return
				end
			end

			v4[count] = character:GetChildren()[1]
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

	local v5 = v4[1]
	local v6 = v4[2]
	local v7 = v5.CFrame.Position + v2.OffsetFromOrigin
	local v8 = v6.CFrame.Position + v2.OffsetFromTarget
	local unit = (v8 - v7).Unit
	local raycastParams = RaycastParams.new()

	local function shallowCopy(items)
		local result = {}

		for k, item in pairs(items) do
			result[k] = item
		end

		return result
	end

	local filterDescendantsInstances = type == "Model" and { p } or { v5 }

	if v2.filterTable ~= "default" then
		local filterTable = v2.filterTable
		filterDescendantsInstances = {}

		for k, v10 in pairs(filterTable) do
			filterDescendantsInstances[k] = v10
		end
	end

	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.CollisionGroup = v5.CollisionGroup
	local raycastResult = nil

	local function raycast()
		raycastResult = nil
		raycastResult = workspace:Raycast(v7, unit * v2.range, raycastParams)

		if v2.OutputCollision and not raycastResult then
			print("No result")
		end

		if raycastResult then
			if raycastResult.Instance == v6 then
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

	if v2.SeeThroughTransparentParts and v2.SeeThroughTransparentParts ~= nil then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function isTransparent(instance)
			if not v2.SeeThroughTransparentParts then
				return false
			end

			local transparency = 0
			local _, result = pcall(function()
				transparency = instance.Transparency
			end)

			if result then
				transparency = 0
			end

			return instance.Transparency >= v2.MinimumTransparency
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function isNonCollidable(instance)
			if not v2.SeeThroughNonCollidable then
				return false
			end

			local canCollide = true
			local _, result = pcall(function()
				canCollide = instance.CanCollide
			end)
			canCollide = result and true or canCollide
			return not canCollide
		end

		if v2.SeeThroughTransparentParts or v2.SeeThroughNonCollidable then
			local filterAttempts = v2.filterAttempts
			local count2 = 0

			while true and count2 < filterAttempts do
				count2 += 1

				if raycast() then
					if v2.VisualizeRaycast then
						MathVisualization.VisualizeRaycast(p, v7, v8, true)
					end

					return true
				else
					if not (raycastResult and raycastResult.Instance ~= nil) then
						return false
					end

					-- equivalent call inferred; original call site unknown
					if not isTransparent(raycastResult.Instance) then
						-- equivalent call inferred; original call site unknown
						if not isNonCollidable(raycastResult.Instance) then
							if v2.VisualizeRaycast then
								MathVisualization.VisualizeRaycast(p, v7, v8, false)
							end

							return false
						end
					end

					table.insert(filterDescendantsInstances, raycastResult.Instance)
					raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				end
			end

			if filterAttempts <= count2 then
				warn("Exceeded maximum iterations in LineOfSight function.")

				if v2.VisualizeRaycast then
					MathVisualization.VisualizeRaycast(p, v7, v8, false)
				end

				return false
			end
		end
	else
		local v10 = raycast()

		if v2.VisualizeRaycast then
			MathVisualization.VisualizeRaycast(p, v7, v8, v10)
		end

		return v10
	end
end

function Old:Round()
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

function Old.IsOnScreen(model, flag: boolean)
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
		v2 = Old.LineOfSight(localPlayer.Character, model, {
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

function Old.IsInView(instance, instance2, p: number, flag: boolean, p2)
	local v = p == nil and 70 or p

	if flag == nil then
		flag = false
	end

	local v2 = v < 0 and 0 or v
	local v3 = v2 > 180 and 180 or v2
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		error("[Forbidden.Math.InPlayerView] The NPC provided does not contain a HumanoidRootPart!")
	end

	local v4 = p2 == nil and {} or p2

	if v4.filterTable == nil then
		v4.filterTable = { instance }
	end

	local primaryPart = nil

	local function getBase()
		if instance2:IsA("Folder") then
			print("code is working")
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 == nil then
				if nil == nil then
					local children = instance2:GetChildren()

					if #children > 0 then
						primaryPart = children[1]
					end

					return
				end
			else
				primaryPart = humanoidRootPart2

				for _, child in instance2:GetChildren() do
					if child ~= primaryPart then
						table.insert(v4.filterTable, child)
					end
				end

				return
			end
		end

		if instance2:IsA("Model") then
			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				primaryPart = humanoidRootPart2
				return
			end

			if instance2.PrimaryPart then
				primaryPart = instance2.PrimaryPart
				return
			end

			local children = instance2:GetChildren()

			if #children > 0 then
				primaryPart = children[1]
				return
			else
				error("[Forbidden.Math.IsInView] No objects in the model!")
			end
		end

		if not instance2:IsA("BasePart") then
			return
		end

		primaryPart = instance2
	end

	getBase()

	if primaryPart == nil then
		error("[Forbidden.Math.IsInView] Could not decide best base part for the IsInView check")
	end

	if instance2:IsA("Model") then
		for _, child in instance2:GetChildren() do
			if not ((child:IsA("BasePart") or child:IsA("Accessory")) and child ~= primaryPart) then
				continue
			end

			table.insert(v4.filterTable, child)
		end
	end

	if not flag or Old.LineOfSight(humanoidRootPart, primaryPart, v4) then
		local lookVector = humanoidRootPart.CFrame.LookVector
		local position = primaryPart.Position

		if math.acos((lookVector:Dot((position - humanoidRootPart.Position).Unit))) < v3 * 0.017453292519943295 then
			return true
		end
	end

	return false
end

return Old