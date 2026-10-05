local createVector = vector.create
local DebugVisualization = {}
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
game:GetService("TweenService")
local Permissions = require(ReplicatedStorage.Modules.Shared.Permissions)
local GameUtil = require(ReplicatedStorage.Modules.Shared.Game.GameUtil)
local localPlayer = Players.LocalPlayer
local isStudio = RunService:IsStudio()
local isRunning = RunService:IsRunning()
local v = {}
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil

local function GetColorDelta(rawColor: Color3, fillColor: Color3)
	local function RGBToXYZ(data)
		local v8

		if data.R < 0.04045 then
			v8 = data.R / 12.92
		else
			v8 = ((data.R + 0.055) / 1.055) ^ 2.4
		end

		local v9

		if data.G < 0.04045 then
			v9 = data.G / 12.92
		else
			v9 = ((data.G + 0.055) / 1.055) ^ 2.4
		end

		local v10

		if data.B < 0.04045 then
			v10 = data.B / 12.92
		else
			v10 = ((data.B + 0.055) / 1.055) ^ 2.4
		end

		return
			v8 * 0.4124 + v9 * 0.3576 + v10 * 0.1805,
			v8 * 0.2126 + v9 * 0.7152 + v10 * 0.0722,
			v8 * 0.0193 + v9 * 0.1192 + v10 * 0.9505
	end

	local function XYZToLAB(p: number, p2: number, p3: number)
		local v8 = p / 0.95047
		local v9 = p3 / 1.08883
		local v10

		if v8 > 0.008856 then
			v10 = math.pow(v8, 0.3333333333333333)
		else
			v10 = v8 * 7.787 + 0.13793103448275862
		end

		local v11

		if p2 > 0.008856 then
			v11 = math.pow(p2, 0.3333333333333333)
		else
			v11 = p2 * 7.787 + 0.13793103448275862
		end

		local v12

		if v9 > 0.008856 then
			v12 = math.pow(v9, 0.3333333333333333)
		else
			v12 = v9 * 7.787 + 0.13793103448275862
		end

		return v11 * 116 - 16, (v10 - v11) * 500, (v11 - v12) * 200
	end

	local v8, v9, v10 = XYZToLAB(RGBToXYZ(rawColor))
	local v11, v12, v13 = XYZToLAB(RGBToXYZ(fillColor))
	return (math.sqrt((v8 - v11) ^ 2 + (v9 - v12) ^ 2 + (v10 - v13) ^ 2))
end

local v8 = nil
local v9 = nil

local function GetFallbackPosition()
	if v8 and v8.Parent == localPlayer.Character then
		return v8.Position
	end

	local v10

	if localPlayer and localPlayer.Character then
		v10 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	v8 = v10
	local position

	if v8 then
		position = v8.Position
	end

	if position then
		v9 = position
	end

	return v9 or createVector(0, 0, 0)
end

local function InvertColor(color: Color3)
	local HSV, v10, v11 = color:ToHSV()
	return Color3.fromHSV((HSV + 0.5) % 1, v10, v11)
end

local function ShiftColorHue(color: Color3, p: number)
	local HSV, v10, v11 = color:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, v10, v11)
end

local function SlerpVector3(vector2: Vector3, vector3: Vector3, p: number)
	if p <= 0 then
		return vector2
	end

	if p >= 1 then
		return vector3
	end

	local unit = vector2.Unit
	local unit2 = vector3.Unit
	local v10 = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))

	if v10 < 0.00001 then
		return vector2:Lerp(vector3, p)
	end

	local v11 = math.sin(v10)
	local v12 = math.sin((1 - p) * v10) / v11
	local v13 = math.sin(p * v10) / v11
	return (unit * v12 + unit2 * v13) * (vector2.Magnitude * (1 - p) + vector3.Magnitude * p)
end

local function CastVectorToLocalFlatPlanarSurface(vector2: Vector3, vector3: Vector3)
	if vector3.Magnitude < 0.001 then
		return CFrame.identity
	end

	local unit = (vector2.Unit - vector2.Unit:Dot(vector3.Unit) * vector3.Unit).Unit
	local unit2 = unit:Cross(vector3.Unit).Unit
	return CFrame.fromMatrix(createVector(0, 0, 0), unit2, vector3.Unit, -unit)
end

local function Clone(folder)
	if isStudio and not isRunning then
		if not folder.Archivable then
			folder.Archivable = true
		end

		for _, descendant in folder:GetDescendants() do
			if not descendant.Archivable then
				descendant.Archivable = true
			end
		end
	end

	local clone = folder:Clone()

	if isStudio and not isRunning then
		folder.Archivable = false

		for _, descendant in clone:GetDescendants() do
			descendant.Archivable = false
		end

		clone.Archivable = false

		for _, descendant in folder:GetDescendants() do
			descendant.Archivable = false
		end
	end

	return clone
end

local function Create(className: string, parent)
	local instance = Instance.new(className, parent)

	if isStudio and not isRunning then
		instance.Archivable = false
	end

	return instance
end

local function FromExisting(instance)
	local v10 = not instance.Archivable

	if not instance.Archivable then
		instance.Archivable = true
	end

	local instance2 = Instance.fromExisting(instance)

	if isStudio and not isRunning or v10 then
		instance2.Archivable = false
	end

	return instance2
end

local function ConstructPrefabMeshOrFallbackToAssetID(p: number, callback)
	local v10 = nil
	xpcall(function()
		v10 = AssetService:CreateEditableMesh()
	end, function(p2: string)
		warn("DebugVisualization - Failed to create new EditableMesh:", p2)
	end)

	if not v10 then
		return AssetService:CreateMeshPartAsync(Content.fromAssetId(p), {
			CollisionFidelity = Enum.CollisionFidelity.Box,
			RenderFidelity = Enum.RenderFidelity.Precise,
			FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
		})
	end

	callback(v10)
	return (AssetService:CreateMeshPartAsync(Content.fromObject(v10), {
		CollisionFidelity = Enum.CollisionFidelity.PreciseConvexDecomposition,
		RenderFidelity = Enum.RenderFidelity.Precise
	}))
end

local function LerpVectorAlongUpAxis(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	local v10 = CastVectorToLocalFlatPlanarSurface(vector2, vector4).LookVector:Angle(
		CastVectorToLocalFlatPlanarSurface(vector3, vector4).LookVector,
		vector4
	) * p
	return (CFrame.lookAlong(createVector(0, 0, 0), vector2, vector4) * CFrame.Angles(0, v10, 0)).LookVector
end

local function ApplyCustomPropertiesToPart(p, items)
	if not items then
		return
	end

	for k, item in items do
		p[k] = item
	end
end

local function MakeCylinderPartSmoothCapped(parent, flag: boolean, flag2: boolean)
	local v10 = math.min(parent.Size.X, parent.Size.Y) / 2
	local Z = parent.Size.Z

	if Z < v10 * ((flag and 1 or 0) + (flag2 and 1 or 0)) then
		v10 = Z / math.max((flag and 1 or 0) + (flag2 and 1 or 0), 1)
	end

	local v11 = Z - v10 * ((flag and 1 or 0) + (flag2 and 1 or 0))
	local v12 = v11 < 0 and 0 or v11
	parent.Size = Vector3.new(parent.Size.X, parent.Size.Y, v12)
	local v13 = 0

	if flag and flag2 then
		v13 = 0
	elseif flag then
		v13 = v10 / 2
	elseif flag2 then
		v13 = -v10 / 2
	end

	parent.CFrame *= CFrame.new(0, 0, v13)

	if flag then
		local clone = Clone(v2)
		clone.Name = "TopCap"
		clone.Color = parent.Color
		clone.Material = parent.Material
		clone.Transparency = parent.Transparency
		clone.Size = Vector3.new(v10 * 2, v10, v10 * 2)
		clone.CFrame = parent.CFrame * CFrame.new(0, 0, parent.Size.Z / 2 + v10 / 2) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		clone.Parent = parent
	end

	if flag2 then
		local clone = Clone(v2)
		clone.Name = "BottomCap"
		clone.Color = parent.Color
		clone.Material = parent.Material
		clone.Transparency = parent.Transparency
		clone.Size = Vector3.new(v10 * 2, v10, v10 * 2)
		clone.CFrame = parent.CFrame * CFrame.new(0, 0, -(parent.Size.Z / 2 + v10 / 2)) * CFrame.Angles(
			-1.5707963267948966,
			0,
			0
		)
		clone.Parent = parent
	end

	if v12 == 0 then
		parent.Transparency = 1
	end
end

local function AddArrowToEndOfCylinder(parent, vector2: Vector3, p: number, p2: number, flag: boolean?, p3: number?, p4: number?)
	local v10 = p3 or math.rad((math.lerp(90, 135, (math.clamp(vector2.Magnitude / (p * 2), 0, 1)))))
	local v11 = p4 or math.clamp((vector2.Magnitude - p / 4) / math.sin(v10), 0, p * 3.141592653589793 * 2)

	for i = 1, p2 do
		local parent2 = Clone(v3)
		parent2.Name = "ArrowLimb"
		parent2.Color = parent.Color
		parent2.Material = parent.Material
		parent2.Transparency = parent.Transparency
		parent2.Size = Vector3.new(p, p, v11)
		parent2.Parent = parent
		MakeCylinderPartSmoothCapped(parent2, true, true)
		local v13 = math.rad(360 / p2 * (i - 1))
		parent2:PivotTo(parent.CFrame * CFrame.new(0, 0, -(parent.Size.Z * (flag and -1 or 1)) / 2) * CFrame.Angles(
			0,
			0,
			v13
		) * CFrame.Angles(v10, 0, 0) * CFrame.new(
			0,
			0,
			-(v11 / 2 - p / 2 + (p - parent2:FindFirstChild("TopCap").Size.Y * 2) / 2)
		))
	end
end

local function ValidatePropertiesAgainstIllegals(properties, p)
	if not (properties and p) then
		return
	end

	for k, _ in properties do
		if p[k] then
			error((`DebugVisualization - Illegal property name provided in config: cannot specify "{k}" in this table`))
		end
	end
end

function DebugVisualization.NewContext(p: string)
	local v10 = true

	if p == "InStudio" then
		v10 = isStudio
	elseif p == "InDevPlaces" then
		v10 = GameUtil.isDevPlace() or GameUtil.isQAPlace()
	elseif p == "ForAdmins" then
		v10 = Permissions.hasAdminAccess(localPlayer)
	elseif p == "Disabled" then
		v10 = false
	end

	if not v10 then
		local v11 = {}
		return (setmetatable(v11, {
			__index = function(_, _: string)
				return function()
					return v11
				end
			end,
			__call = function()
				return v11
			end
		}))
	end

	local object = setmetatable({}, {
		__mode = "v"
	})

	local function GetPlaceholderPrefabForID(prefabIdWhichIsStillLoading: number)
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", prefabIdWhichIsStillLoading)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		return meshPart
	end

	local connections = {}

	local function PrefabHL(instance)
		if not instance:GetAttribute("NormalColor") then
			instance:SetAttribute("NormalColor", instance.FillColor)
		end

		instance.FillColor = Color3.new(0, 0, 0):Lerp(
			Color3.new(0.815686, 0.023529, 0.392157),
			math.sin(tick() * 3.141592653589793 * 4) / 2 + 0.5
		)
	end

	local v11

	if RunService:IsServer() then
		v11 = RunService.Stepped
	else
		v11 = RunService.RenderStepped
	end

	table.insert(connections, v11:Connect(function()
		for _, v12 in CollectionService:GetTagged("DebugVisualizationHighlight"), nil, nil do
			PrefabHL(v12)
		end
	end))
	table.insert(
		connections,
		CollectionService:GetInstanceAddedSignal("DebugVisualizationHighlight"):Connect(function(p2)
			PrefabHL(p2)
		end)
	)
	local v12 = 0

	local function FinishedLoadingAPrefab()
		v12 -= 1

		if v12 <= 0 then
			for _, v13 in CollectionService:GetTagged("DebugVisualization_PrefabStillLoading"), nil, nil do
				local v14 = v[v13:GetAttribute("PrefabIdWhichIsStillLoading")]

				if v14 then
					task.spawn(v13.ApplyMesh, v13, v14)
				end

				for _, texture in v13:GetChildren() do
					if texture:IsA("Texture") and texture.Name == "PlaceholderTextureWhileStillLoading" then
						texture:Destroy()
					end
				end

				v13.Material = Enum.Material.Neon
				v13:RemoveTag("DebugVisualization_PrefabStillLoading")
				v13:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			for _, connection in connections do
				connection:Disconnect()
			end

			local v13

			if RunService:IsServer() then
				v13 = RunService.Stepped
			else
				v13 = RunService.RenderStepped
			end

			v13:Wait()

			for _, v14 in CollectionService:GetTagged("DebugVisualizationHighlight") do
				if v14:GetAttribute("NormalColor") then
					v14.FillColor = v14:GetAttribute("NormalColor")
				end
			end
		end
	end

	local MeshGeometryBuilders = require(script:WaitForChild("MeshGeometryBuilders"))

	local function LoadMeshPrefab(prefabIdWhichIsStillLoading: number, callback)
		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", prefabIdWhichIsStillLoading)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		callback(meshPart)
		task.spawn(function()
			local v13 = nil

			if MeshGeometryBuilders[prefabIdWhichIsStillLoading] then
				pcall(function()
					v13 = ConstructPrefabMeshOrFallbackToAssetID(
						prefabIdWhichIsStillLoading,
						MeshGeometryBuilders[prefabIdWhichIsStillLoading]
					)
				end)
			end

			if not v13 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v13 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(prefabIdWhichIsStillLoading), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v13 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {prefabIdWhichIsStillLoading} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v13 then
				v[prefabIdWhichIsStillLoading] = v13
				v13.Anchored = true
				v13.CanCollide = false
				v13.CanQuery = false
				v13.CastShadow = false
				v13.CanTouch = false
				v13.Material = Enum.Material.Neon
				v13.Massless = true

				if isStudio and not isRunning then
					v13.Archivable = false
				end

				callback(v13)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {prefabIdWhichIsStillLoading} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v2 then
		local function fn(p2)
			v2 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 2506127037)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v2 = meshPart
		local v13 = 2506127037
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v3 then
		local function fn(p2)
			v3 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 14945731824)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v3 = meshPart
		local v13 = 14945731824
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v4 then
		local function fn(p2)
			v4 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 134653856420428)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v4 = meshPart
		local v13 = 134653856420428
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v5 then
		local function fn(p2)
			v5 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 135384238901086)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v5 = meshPart
		local v13 = 135384238901086
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v6 then
		local function fn(p2)
			v6 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 137287050553068)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v6 = meshPart
		local v13 = 137287050553068
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	if not v7 then
		local function fn(p2)
			v7 = p2
		end

		v12 += 1
		local meshPart = Instance.new("MeshPart", nil)

		if isStudio and not isRunning then
			meshPart.Archivable = false
		end

		meshPart.Anchored = true
		meshPart.CanCollide = false
		meshPart.CanQuery = false
		meshPart.CanTouch = false
		meshPart.CastShadow = false
		meshPart.Material = Enum.Material.DiamondPlate
		meshPart.Transparency = 0
		meshPart.Massless = true
		meshPart:SetAttribute("PrefabIdWhichIsStillLoading", 104528104155128)
		meshPart:AddTag("DebugVisualization_PrefabStillLoading")
		v7 = meshPart
		local v13 = 104528104155128
		task.spawn(function()
			local v14 = nil

			if MeshGeometryBuilders[v13] then
				pcall(function()
					v14 = ConstructPrefabMeshOrFallbackToAssetID(v13, MeshGeometryBuilders[v13])
				end)
			end

			if not v14 then
				for i = 1, 10 do
					pcall(function()
						local AssetService2 = game:GetService("AssetService")
						v14 = AssetService2:CreateMeshPartAsync(Content.fromAssetId(v13), {
							CollisionFidelity = Enum.CollisionFidelity.Box,
							RenderFidelity = Enum.RenderFidelity.Precise,
							FluidFidelity = Enum.FluidFidelity.UseCollisionGeometry
						})
					end)

					if v14 then
						break
					end

					warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab based on Asset ID {v13} - retrying... \{{i}}`))
					task.wait(i * 0.1)
				end
			end

			if v14 then
				v[v13] = v14
				v14.Anchored = true
				v14.CanCollide = false
				v14.CanQuery = false
				v14.CastShadow = false
				v14.CanTouch = false
				v14.Material = Enum.Material.Neon
				v14.Massless = true

				if isStudio and not isRunning then
					v14.Archivable = false
				end

				fn(v14)
				Debris:AddItem(meshPart, 0)
			else
				warn((`DebugVisualization::LoadMeshPrefab: Failed to load prefab with ID {v13} - falling back to a default 'block' Part - this will most likely result in very odd looking debug graphics!`))
				meshPart:RemoveTag("DebugVisualization_PrefabStillLoading")
				meshPart:SetAttribute("PrefabIdWhichIsStillLoading", nil)
			end

			FinishedLoadingAPrefab()
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetColorID(fillColor: Color3)
		return (`{math.round(fillColor.R * 255)},{math.round(fillColor.G * 255)},{math.round(fillColor.B * 255)}`)
	end

	local function GetHighlightModelForColor(fillColor: Color3)
		local name = GetColorID(fillColor) -- equivalent call inferred; original call site unknown
		local v14 = object[name]
		local highlight

		if object[name] then
			highlight = object[name]:FindFirstChild("Highlight")
		end

		if v14 and highlight then
			return v14, highlight
		end

		if v14 then
			Debris:AddItem(v14, 0)
			object[name] = nil
		end

		for _, v15 in object do
			local highlight2

			if v15 then
				highlight2 = v15:FindFirstChild("Highlight")
			end

			if not (v15 and highlight2 and GetColorDelta(v15:GetAttribute("RawColor"), fillColor) < 0.05) then
				continue
			end

			object[name] = v15
			return v15, highlight2
		end

		local model = Instance.new("Model", nil)

		if isStudio and not isRunning then
			model.Archivable = false
		end

		object[name] = model
		model.Name = name
		model:SetAttribute("RawColor", fillColor)
		model.Archivable = false
		local highlight2 = Instance.new("Highlight", nil)

		if isStudio and not isRunning then
			highlight2.Archivable = false
		end

		highlight2:AddTag("DebugVisualizationHighlight")
		highlight2.FillColor = fillColor
		highlight2.FillTransparency = 0.5
		highlight2.OutlineTransparency = 0.9
		highlight2.OutlineColor = Color3.new(fillColor.R * 0.25, fillColor.G * 0.25, fillColor.B * 0.25)
		highlight2.Parent = model
		highlight2.Adornee = model
		model.ChildRemoved:Connect(function()
			if #model:GetChildren() == 1 then
				object[name] = nil
				model:Destroy()

				if highlight2 then
					highlight2:Destroy()
				end
			end
		end)
		model.Parent = workspace.Terrain
		return model, highlight2
	end

	local v13 = {}
	local now = tick()

	local function PerformRetainedStateGarbageCollection()
		now = tick()
		local v14 = {}

		for k, v15 in v13 do
			if now > v15.expiry then
				table.insert(v14, k)
			end
		end

		for _, v15 in v14 do
			v13[v15] = nil
		end
	end

	local v14 = {
		Retain = function(callback, value: number?, p2)
			if p2 == nil then
				local v16, v17, v18, v19, v20 = debug.info(2, "slna")
				p2 = `{v16}:{v17}:{tostring(v18)}:{v19}:{tostring(v20)}`
			end

			local now2 = tick()

			if now2 - now >= 1 then
				PerformRetainedStateGarbageCollection()
			end

			local v16 = v13[p2]

			if v16 and v16.expiry <= now2 then
				v13[p2] = nil
				v16 = nil
			end

			local valuePack

			if v16 then
				valuePack = { callback(unpack(v16.valuePack)) }
			else
				valuePack = { callback() }
			end

			v13[p2] = next(valuePack) and {
				expiry = now2 + (value or 10),
				valuePack = valuePack
			} or nil
		end,
		DoWithRetainedValue = function(p2, callback)
			local now2 = tick()

			if now2 - now >= 1 then
				PerformRetainedStateGarbageCollection()
			end

			local v15 = v13[p2]

			if v15 and v15.expiry <= now2 then
				v13[p2] = nil
				v15 = nil
			end

			if v15 then
				callback(unpack(v15.valuePack))
			end
		end,
		ClearRetainedValue = function(p2)
			v13[p2] = nil
		end,
		DoIfDebuggingEnabled = function(callback)
			callback()
		end
	}
	local v15 = {}

	function v14.VisualizeVector(vector2: Vector3, color: Color3, duration: number, position: Vector3?, value: number?, p2: string?, value2)
		local v16 = position ~= nil

		if not position then
			if v8 and v8.Parent == localPlayer.Character then
				position = v8.Position
			else
				local v17

				if localPlayer and localPlayer.Character then
					v17 = localPlayer.Character:FindFirstChild("HumanoidRootPart")
				end

				v8 = v17
				local position2

				if v8 then
					position2 = v8.Position
				end

				if position2 then
					v9 = position2
				end

				position = v9 or createVector(0, 0, 0)
			end
		end

		local v17 = math.max(value or 0.1, 0.00001)
		local v18 = (typeof(value2) == "boolean" or typeof(value2) == "number") and {
			arrowHeads = value2,
			properties = {}
		} or typeof(value2) ~= "table" and {
			arrowHeads = false,
			bottomArrowHeads = false,
			properties = {}
		} or value2
		ValidatePropertiesAgainstIllegals(v18.properties, {
			Color = true,
			BrickColor = true
		})
		local skipHighlight = v18.properties and v18.properties.skipHighlight

		if v18.properties then
			v18.properties.skipHighlight = nil
		end

		if p2 and v15[p2] then
			v15[p2]:Destroy()
			v15[p2] = nil
		end

		local v19 = vector2 ~= vector2 and createVector(0, -1000, 0) or vector2
		local v20 = not v16 and 5 or v19.Magnitude
		local properties = Clone(v3)
		properties.Name = "VectorBody"
		properties.Color = color
		properties.Size = Vector3.new(v17, v17, v20)
		properties.CFrame = CFrame.new(position, position + v19) * CFrame.new(0, 0, -(v20 / 2)) * CFrame.Angles(
			0,
			0,
			not v18.specificRoll and 0 or v18.specificRoll % 6.283185307179586
		)
		local properties2 = v18.properties

		if properties2 then
			for k, property in properties2 do
				properties[k] = property
			end
		end

		if p2 then
			v15[p2] = properties
		end

		MakeCylinderPartSmoothCapped(properties, true, true)

		if v18.arrowHeads and v19.Magnitude > 0 then
			AddArrowToEndOfCylinder(
				properties,
				v19,
				v17,
				typeof(v18.arrowHeads) ~= "number" and 4 or v18.arrowHeads,
				false,
				v18.arrowHeadsAngle,
				v18.arrowHeadsLength
			)
		end

		if v18.bottomArrowHeads and v19.Magnitude > 0 then
			local v22

			if typeof(v18.bottomArrowHeads) == "number" then
				v22 = v18.bottomArrowHeads
			else
				v22 = typeof(v18.arrowHeads) ~= "number" and 4 or v18.arrowHeads
			end

			AddArrowToEndOfCylinder(
				properties,
				v19,
				v17,
				v22,
				true,
				v18.bottomArrowHeadsAngle,
				v18.bottomArrowHeadsLength
			)
		end

		if v18.hooks and v18.hooks.onDestroy then
			properties.Destroying:Once(v18.hooks.onDestroy)
		end

		if v18.hooks and v18.hooks.queryDescendants then
			local folder = Instance.new("Folder", nil)

			if isStudio and not isRunning then
				folder.Archivable = false
			end

			properties.Parent = folder

			for _, queryDescendant in v18.hooks.queryDescendants do
				local descendants = folder:QueryDescendants(queryDescendant.queryString)

				for _, descendant in descendants do
					queryDescendant.forEach(descendant, #descendants)
				end
			end

			local parent

			if skipHighlight then
				parent = workspace.Terrain
			else
				parent = GetHighlightModelForColor(color)
			end

			properties.Parent = parent
			folder:Destroy()
		else
			local parent

			if skipHighlight then
				parent = workspace.Terrain
			else
				parent = GetHighlightModelForColor(color)
			end

			properties.Parent = parent
		end

		Debris:AddItem(properties, duration)
		task.delay(duration, function()
			if p2 and v15[p2] == properties then
				v15[p2] = nil
			end
		end)
	end

	local v16 = {}

	function v14.VisualizeAngle(cframe: CFrame, vector2: Vector3, p2: number, p3: number, list, duration: number?, value: number?, p4, p5)
		local v17 = p5 or {
			arrowHeads = 1,
			hideThetaLabel = false,
			protractorMode = false,
			properties = {}
		}
		ValidatePropertiesAgainstIllegals(v17.properties, {
			Color = true,
			BrickColor = true
		})
		local skipHighlight = v17.properties and v17.properties.skipHighlight

		if v17.properties then
			v17.properties.skipHighlight = nil
		end

		local v18

		if typeof(list) == "Color3" then
			v18 = list
		else
			v18 = list[1]
		end

		if typeof(list) ~= "Color3" then
			list = list[2]
		end

		local v19 = math.max(value or 0.032, 0.00001)
		local v20 = p3 % 6.283185307179586

		if p3 < 0 then
			v20 -= 6.283185307179586
		end

		local ref = {}

		if p4 then
			if v16[p4] then
				for _, v22 in ipairs(v16[p4]) do
					v22:Destroy()
				end
			end

			v16[p4] = {
				ref = ref
			}
		end

		local position = cframe.Position
		local vector3 = not (vector2.Magnitude > 0) and createVector(1, 0, 0) or vector2.Unit

		if math.abs((vector3:Dot(createVector(0, 0, 1)))) == 1 then
			error("A pure Z-vector direction was provided to debugContext.VisualizeAngle - you cannot provide a local-space Z angle travel direction; this would result in a degenerate arc at best and NaN propogration at worst.")
		end

		local vector4 = cframe:VectorToWorldSpace(vector3)
		local unit = vector4:Cross(cframe.LookVector).Unit
		local cframe2 = CFrame.fromMatrix(position, vector4, unit, -cframe.LookVector)
		local v22 = math.max(6, (math.floor(math.abs(v20) / 0.12217304763960307)))
		local v23 = v20 / v22
		local v24 = {}
		local v25 = {}

		for i = 0, v22 - 1 do
			local v26 = v23 * i
			local v27 = v23 * (i + 1)
			local v28 = position + (cframe2 * CFrame.Angles(0, -v26, 0)).LookVector * p2
			local v29 = position + (cframe2 * CFrame.Angles(0, -v27, 0)).LookVector * p2
			local lerped = v18:Lerp(list, i / v22)
			local properties = Clone(v3)
			properties.Name = "AngleSegment"
			properties.Size = Vector3.new(v19, v19, (v29 - v28).Magnitude)
			properties.Color = lerped
			properties.CFrame = CFrame.new((v28 + v29) / 2, v29)
			local properties2 = v17.properties

			if properties2 then
				for k, property in properties2 do
					properties[k] = property
				end
			end

			if i == 0 then
				v24[1] = {
					CF = properties.CFrame * CFrame.new(0, 0, properties.Size.Z / 2),
					Part = properties
				}
			end

			if i == v22 - 1 then
				v24[2] = {
					CF = properties.CFrame * CFrame.new(0, 0, -properties.Size.Z / 2),
					Part = properties
				}
			end

			if p4 then
				table.insert(v16[p4], properties)
			end

			table.insert(ref, properties)
			local v30

			if skipHighlight then
				v30 = workspace.Terrain
			else
				v30 = GetHighlightModelForColor(lerped)
			end

			v25[properties] = v30
		end

		for i, v26 in ipairs(v24) do
			if typeof(v17.protractorMode) == "table" and v17.protractorMode[i] or v17.protractorMode == true then
				local position2 = v26.CF.Position
				local magnitude = (position2 - position).Magnitude
				local color

				if i == 1 then
					color = v18
				else
					color = list
				end

				local properties = Clone(v3)
				properties.Name = "ProtractorLine"
				properties.Size = Vector3.new(v19, v19, magnitude + v19)
				properties.Color = color
				local properties2 = v17.properties

				if properties2 then
					for k, property in properties2 do
						properties[k] = property
					end
				end

				properties.CFrame = CFrame.new(position, position2) * CFrame.new(0, 0, -magnitude / 2)
				MakeCylinderPartSmoothCapped(properties, true, true)
				local v28

				if skipHighlight then
					v28 = workspace.Terrain
				else
					v28 = GetHighlightModelForColor(color)
				end

				v25[properties] = v28

				if p4 then
					table.insert(v16[p4], properties)
				end

				table.insert(ref, properties)
			end

			if i == 2 and v17.arrowHeads then
				local lookVector = v26.CF.LookVector
				local v27 = v26.Part.CFrame * CFrame.new(0, 0, v26.Part.Size.Z / 2)
				AddArrowToEndOfCylinder(
					v26.Part,
					CFrame.lookAlong(v27.Position, lookVector, v27.UpVector).LookVector,
					v19 or 0.032,
					1
				)
			else
				local v27

				if i == 1 then
					v27 = v18
				else
					v27 = list
				end

				local HSV, v28, v29 = v27:ToHSV()
				local color = Color3.fromHSV((HSV + 0.5) % 1, v28, v29)
				local part = Instance.new("Part", nil)

				if isStudio and not isRunning then
					part.Archivable = false
				end

				part.Name = "AngleBoundaryMarker"
				part.Anchored = true
				part.CanCollide = false
				part.CanQuery = false
				part.CanTouch = false
				part.Material = Enum.Material.Neon
				part.Massless = true
				part.Size = Vector3.new(v19 * 2, v19 * 2, 0.001)
				part.Color = color
				part.CFrame = v26.CF
				local properties = v17.properties

				if properties then
					for k, property in properties do
						part[k] = property
					end
				end

				local v30

				if skipHighlight then
					v30 = workspace.Terrain
				else
					v30 = GetHighlightModelForColor(color)
				end

				v25[part] = v30

				if p4 then
					table.insert(v16[p4], part)
				end

				table.insert(ref, part)
			end
		end

		if not v17.hideThetaLabel then
			local v26 = -v20 / 2
			local part = Instance.new("Part", nil)

			if isStudio and not isRunning then
				part.Archivable = false
			end

			part.Name = "AngleLabel"
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.Transparency = 1
			local v27 = math.max(1.25, p2 * 0.2)
			part.Size = Vector3.new(v27, v27 * 0.568, 0.001)
			local v28 = cframe2 * CFrame.Angles(0, v26, 0)
			part.CFrame = CFrame.lookAlong(
				position + v28.LookVector * (p2 + v19 / 2 + v27 * 0.568 / 2),
				(v28 * CFrame.Angles(0, 1.5707963267948966, 0)).LookVector,
				-v28.LookVector
			) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(0, 0, 3.141592653589793)
			v25[part] = workspace.Terrain

			if p4 then
				table.insert(v16[p4], part)
			end

			local surfaceGui = Instance.new("SurfaceGui", nil)

			if isStudio and not isRunning then
				surfaceGui.Archivable = false
			end

			surfaceGui.Adornee = part
			surfaceGui.Face = Enum.NormalId.Front
			surfaceGui.LightInfluence = 0
			surfaceGui.AlwaysOnTop = true
			surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize
			surfaceGui.CanvasSize = (workspace.CurrentCamera.ViewportSize * Vector2.new(0.04, 0.0515)):Max(Vector2.new(
				81,
				50
			))
			surfaceGui.Parent = part
			local textLabel = Instance.new("TextLabel", nil)

			if isStudio and not isRunning then
				textLabel.Archivable = false
			end

			textLabel.Size = UDim2.new(1, 0, 1, 0)
			textLabel.BackgroundTransparency = 1
			textLabel.BorderSizePixel = 0
			textLabel.Font = Enum.Font.RobotoMono
			textLabel.Text = `{math.round((math.deg(p3)))}°`
			textLabel.TextColor3 = v18:Lerp(list, 0.5)
			textLabel.TextStrokeTransparency = 0.2
			textLabel.TextScaled = true
			textLabel.Parent = surfaceGui
			local clone = Clone(surfaceGui)
			clone.Face = Enum.NormalId.Back
			clone.Parent = part
			table.insert(ref, part)
		end

		if v17.hooks and v17.hooks.onDestroy then
			next(v25).Destroying:Once(v17.hooks.onDestroy)
		end

		if v17.hooks and v17.hooks.queryDescendants then
			local folder = Instance.new("Folder", nil)

			if isStudio and not isRunning then
				folder.Archivable = false
			end

			for k, _ in v25 do
				k.Parent = folder
			end

			for _, queryDescendant in v17.hooks.queryDescendants do
				local descendants = folder:QueryDescendants(queryDescendant.queryString)

				for _, descendant in descendants do
					queryDescendant.forEach(descendant, #descendants)
				end
			end

			for k, parent in v25 do
				k.Parent = parent
			end

			folder:Destroy()
		else
			for k, parent in v25 do
				k.Parent = parent
			end
		end

		task.delay(duration, function()
			if p4 and v16[p4] and v16[p4].ref == ref then
				for _, v26 in ipairs(v16[p4]) do
					v26:Destroy()
				end

				v16[p4] = nil
			end

			for _, v26 in ref do
				v26:Destroy()
			end
		end)
	end

	function v14.VisualizeAngleFromTriangle(vector2: Vector3, vector3: Vector3, vector4: Vector3, color: Color3, p2: number, p3: number?, p4, p5)
		local vector5 = vector3 - vector2
		local vector6 = vector4 - vector2

		if vector5.Unit:Dot(vector6.Unit) >= 1 then
			v14.VisualizeAngle(
				CFrame.lookAlong(vector2, vector5, createVector(0, 1, 0)),
				createVector(1, 0, 0),
				vector5.Magnitude,
				0,
				color,
				p2,
				p3,
				p4,
				p5
			)
			return
		end

		local _ = vector6 - vector5
		local vector7 = (vector4 - vector2):Cross(vector3 - vector2)

		if vector7.Magnitude < 0.001 then
			local v17 = math.abs((vector5.Unit:Dot(createVector(0, 1, 0)))) == 1 and createVector(0, 0, 1) or createVector(
				0,
				1,
				0
			)
			vector7 = vector5.Unit:Cross(v17).Unit:Cross(vector5.Unit)
		end

		local angle = vector6:Angle(vector5, vector7)
		local v17 = (vector6:Dot(vector6) * vector5:Cross(vector7) - vector5:Dot(vector5) * vector6:Cross(vector7)) / (2 * vector7:Dot(vector7))
		local _ = vector2 + v17
		local v18 = math.acos(vector5.Magnitude * (1 - math.cos(angle / 2)) / ((createVector(0, 0, 0) - v17).Magnitude * (1 - math.cos(angle / 2))))
		local _ = (createVector(0, 0, 0) - v17).Magnitude * (1 - math.cos(v18 / 2))
		local cframe = CFrame.fromMatrix(
			vector2,
			(CFrame.lookAlong(createVector(0, 0, 0), vector5, vector7) * CFrame.Angles(0, -1.5707963267948966, 0)).LookVector,
			vector7.Unit,
			-vector5.Unit
		)
		v14.VisualizeAngle(cframe, createVector(1, 0, 0), vector5.Magnitude, angle, color, p2, p3, p4, p5)
	end

	function v14.DefinePiecewiseExpression()
		local v17 = nil
		local flag = false
		local v18 = nil
		local v19 = nil
		local flag2 = false
		local v20 = {}

		function v20.WhichDoes(_, callback)
			if flag2 then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call WhichDoes after FinallyDoes has been called; this is now considered a finalized expression and you may only call Evaluate on it.")
			end

			if flag then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call WhichDoes while awaiting an Until condition; this defies a sensical logic flow.")
			end

			v19 = callback
			v18 = callback
			flag = true
			return v20
		end

		function v20.Until(_, p2)
			if flag2 then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call Until after FinallyDoes has been called")
			end

			if not flag then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call Until without a preceding WhichDoes or ThenDoes")
			end

			if not v18 then
				error("DebugVisualization.DefinePiecewiseExpression: Internal error - lastFunction is nil")
			end

			if not (v17 or p2) then
				v17 = v18
			end

			flag = false
			v18 = nil
			return v20
		end

		function v20.ThenDoes(_, callback)
			if flag2 then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call ThenDoes after FinallyDoes has been called")
			end

			if flag then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call ThenDoes while awaiting an Until condition - did you forget to call Until?")
			end

			if not v17 then
				v18 = callback
				flag = true
			end

			return v20
		end

		function v20.FinallyDoes(_, callback)
			if flag2 then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call FinallyDoes more than once")
			end

			if flag then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call FinallyDoes while awaiting an Until condition - did you forget to call Until?")
			end

			flag2 = true

			if not v17 then
				v17 = callback
			end

			return v20
		end

		function v20.Evaluate(_)
			if flag then
				error("DebugVisualization.DefinePiecewiseExpression: Cannot call Evaluate while awaiting an Until condition - did you forget to call Until or FinallyDoes?")
			end

			if not v17 then
				if v19 then
					return v19()
				else
					error("DebugVisualization.DefinePiecewiseExpression: No function was selected - did you forget to call FinallyDoes?")
				end
			end

			return v17()
		end

		return v20
	end

	return v14
end

return DebugVisualization