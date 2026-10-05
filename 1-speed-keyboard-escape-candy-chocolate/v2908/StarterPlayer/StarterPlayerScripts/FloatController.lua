local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local flag = true
local descendantAddedConnection = nil
local descendantRemovingConnection = nil
local getFloatingObjects

getFloatingObjects = function(instance)
	local result = {}

	for _, child in ipairs(instance:GetChildren()) do
		if child:IsA("Model") then
			table.insert(result, child)
		elseif child:IsA("BasePart") then
			table.insert(result, child)
		elseif child:IsA("Folder") then
			for _, v5 in ipairs(getFloatingObjects(child)) do
				table.insert(result, v5)
			end
		end
	end

	return result
end

local function getInitialCFrame(instance)
	local pivot = v[instance]

	if pivot then
		return pivot
	end

	if instance:IsA("Model") then
		pivot = instance:GetPivot()
	elseif instance:IsA("BasePart") then
		pivot = instance.CFrame
	end

	if pivot then
		v[instance] = pivot
	end

	return pivot
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupCacheFor(p)
	v[p] = nil
	v2[p] = nil
	v4[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCellKey(p: number, p2: number)
	return tostring(p) .. "_" .. tostring(p2)
end

local function buildSpatialGrid(floatFolder)
	table.clear(v3)
	local floatingObjects = getFloatingObjects(floatFolder)
	local v5 = {}

	for _, instance in ipairs(floatingObjects) do
		v5[instance] = true
		local pivot = v[instance]

		if not pivot then
			if instance:IsA("Model") then
				pivot = instance:GetPivot()
			elseif instance:IsA("BasePart") then
				pivot = instance.CFrame
			end

			if pivot then
				v[instance] = pivot
			end
		end

		if not pivot then
			continue
		end

		local position = pivot.Position
		local cellKey = getCellKey(math.floor(position.X / 200), math.floor(position.Z / 200)) -- equivalent call inferred; original call site unknown
		local instances = v3[cellKey]

		if not instances then
			instances = {}
			v3[cellKey] = instances
		end

		table.insert(instances, instance)
	end

	for k in pairs(v) do
		if v5[k] then
			continue
		end

		cleanupCacheFor(k) -- equivalent call inferred; original call site unknown
	end
end

local function setupFolderListeners(floatFolder)
	if descendantAddedConnection then
		descendantAddedConnection:Disconnect()
	end

	if descendantRemovingConnection then
		descendantRemovingConnection:Disconnect()
	end

	descendantAddedConnection = floatFolder.DescendantAdded:Connect(function(_)
		flag = true
	end)
	descendantRemovingConnection = floatFolder.DescendantRemoving:Connect(function(descendant)
		cleanupCacheFor(descendant) -- equivalent call inferred; original call site unknown
		flag = true
	end)
end

RunService.RenderStepped:Connect(function(dt)
	local floatFolder = Workspace:FindFirstChild("FloatFolder")

	if floatFolder and floatFolder:IsA("Folder") then
		if not descendantAddedConnection then
			setupFolderListeners(floatFolder)
			flag = true
		end

		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local position = humanoidRootPart.Position

		if flag then
			buildSpatialGrid(floatFolder)
			flag = false
		end

		local v5 = math.floor(position.X / 200)
		local v6 = math.floor(position.Z / 200)
		local v7 = {}

		for i = -1, 1 do
			for i2 = -1, 1 do
				local cellKey = getCellKey(v5 + i, v6 + i2) -- equivalent call inferred; original call site unknown
				local v10 = v3[cellKey]

				if not v10 then
					continue
				end

				for _, instance in ipairs(v10) do
					local pivot = v[instance]

					if not pivot then
						if instance:IsA("Model") then
							pivot = instance:GetPivot()
						elseif instance:IsA("BasePart") then
							pivot = instance.CFrame
						end

						if pivot then
							v[instance] = pivot
						end
					end

					if not pivot then
						continue
					end

					local v11 = position - pivot.Position

					if not (v11.X * v11.X + v11.Y * v11.Y + v11.Z * v11.Z <= 40000) then
						continue
					end

					v7[instance] = true
					v4[instance] = true
				end
			end
		end

		local now = os.clock()

		for instance, _ in pairs(v4) do
			if instance.Parent then
				local v8 = v2[instance]

				if not v8 then
					local pivot = v[instance]

					if not pivot then
						if instance:IsA("Model") then
							pivot = instance:GetPivot()
						elseif instance:IsA("BasePart") then
							pivot = instance.CFrame
						end

						if pivot then
							v[instance] = pivot
						end
					end

					if pivot then
						v8 = {
							weight = 0,
							initialCF = pivot,
							phaseOffset = math.random() * 3.141592653589793 * 2
						}
						v2[instance] = v8
						local v9 = instance
						instance.Destroying:Connect(function()
							cleanupCacheFor(v9) -- equivalent call inferred; original call site unknown
						end)
					end
				end

				if v8 then
					local weight = v7[instance] and 1 or 0

					if v8.weight ~= weight then
						local v10 = weight - v8.weight
						local v11 = dt * 2

						if math.abs(v10) < v11 then
							v8.weight = weight
						else
							v8.weight += math.sign(v10) * v11
						end
					end

					if v8.weight > 0 then
						local v10 = now + v8.phaseOffset
						local v11 = math.sin(v10 * 0.6) * 3 * v8.weight
						local v12 = math.cos(v10 * 0.4) * 0.10471975511965978 * v8.weight
						local v13 = math.sin(v10 * 0.3) * 0.10471975511965978 * v8.weight
						local cFrame = v8.initialCF * CFrame.new(0, v11, 0) * CFrame.fromEulerAnglesXYZ(v12, 0, v13)

						if instance:IsA("Model") then
							instance:PivotTo(cFrame)
						elseif instance:IsA("BasePart") then
							instance.CFrame = cFrame
						end
					else
						if instance:IsA("Model") then
							instance:PivotTo(v8.initialCF)
						elseif instance:IsA("BasePart") then
							instance.CFrame = v8.initialCF
						end

						v4[instance] = nil
					end
				end
			else
				cleanupCacheFor(instance) -- equivalent call inferred; original call site unknown
			end
		end
	else
		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
			descendantAddedConnection = nil
		end

		if descendantRemovingConnection then
			descendantRemovingConnection:Disconnect()
			descendantRemovingConnection = nil
		end

		if next(v2) ~= nil or next(v) ~= nil or next(v3) ~= nil or next(v4) ~= nil then
			table.clear(v2)
			table.clear(v)
			table.clear(v3)
			table.clear(v4)
			flag = true
		end
	end
end)