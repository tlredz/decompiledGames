local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RaycastHelper = {
	Crater = RaycastParams.new()
}
RaycastHelper.Crater.FilterDescendantsInstances = { workspace.Map, Workspace.Map:FindFirstChild("Trees") }
local crater = RaycastHelper.Crater
local v2

if not (workspace.Map:FindFirstChild("DetachedMaps") == nil or workspace.Map.DetachedMaps:FindFirstChild("ParkourTraining") == nil) then
	v2 = workspace.Map.DetachedMaps.ParkourTraining:FindFirstChild("Trees") or nil
end

crater.ExcludeInstances = { v2 }
RaycastHelper.Crater.FilterType = Enum.RaycastFilterType.Include

if RunService:IsClient() then
	task.spawn(function()
		if workspace.Debree:FindFirstChild("Important") ~= nil then
			local swapEffectBG = workspace.Debree.Important:WaitForChild("SwapEffectBG", 5)
			RaycastHelper.Crater.FilterDescendantsInstances = { workspace.Map, swapEffectBG }
		end
	end)
end

RaycastHelper.Map = RaycastParams.new()
RaycastHelper.Map.FilterDescendantsInstances = { workspace.Map }
RaycastHelper.Map.FilterType = Enum.RaycastFilterType.Include
RaycastHelper.Ground = RaycastParams.new()
RaycastHelper.Ground.FilterDescendantsInstances = { Workspace.Map }
RaycastHelper.Ground.FilterType = Enum.RaycastFilterType.Include
RaycastHelper.Humanoids = OverlapParams.new()
RaycastHelper.Humanoids.FilterType = Enum.RaycastFilterType.Include
RaycastHelper.Humanoids.MaxParts = 350
task.spawn(function()
	RaycastHelper.Humanoids.FilterDescendantsInstances = { workspace:WaitForChild("Humanoids") }
end)
local isServer = RunService:IsServer()

if isServer then
	local v3 = {}
	local v4 = {}

	function RaycastHelper.GetDynamicRaycastParams(p: string, value: number?, flag: boolean?)
		if p == nil then
			return
		end

		if v3[p] ~= nil and not flag then
			return v3[p]
		end

		local raycastParams = RaycastParams.new()
		v3[p] = raycastParams
		task.delay(value or 10, function()
			v3[p] = nil
		end)
		return raycastParams, true
	end

	function RaycastHelper.GetDynamicOverlapParams(p: string, value: number?, flag: boolean?)
		if p == nil then
			return
		end

		if v4[p] ~= nil and not flag then
			return v4[p]
		end

		local overlapParams = OverlapParams.new()
		v4[p] = overlapParams
		task.delay(value or 10, function()
			v4[p] = nil
		end)
		return overlapParams, true
	end

	function RaycastHelper.ReleaseDynamicParams(p: string?)
		if p == nil then
			return
		end

		v3[p] = nil
		v4[p] = nil
	end
else
	local localPlayer = game.Players.LocalPlayer
	RaycastHelper.EverythingExceptPlayer = RaycastParams.new()
	RaycastHelper.EverythingExceptPlayer.FilterType = Enum.RaycastFilterType.Exclude
	RaycastHelper.EveryHumanoidExceptPlayer = RaycastParams.new()
	RaycastHelper.EveryHumanoidExceptPlayer.FilterType = Enum.RaycastFilterType.Exclude

	function updchar()
		RaycastHelper.EveryHumanoidExceptPlayer.FilterDescendantsInstances = {
			localPlayer.Character,
			workspace.Debree,
			workspace.Map
		}
		RaycastHelper.EverythingExceptPlayer.FilterDescendantsInstances = { localPlayer.Character, workspace.Debree }
	end

	if localPlayer.Character ~= nil then
		updchar()
	end

	localPlayer.CharacterAdded:Connect(updchar)
end

RaycastHelper.Everything_Except_Debree = RaycastParams.new()
RaycastHelper.Everything_Except_Debree.FilterDescendantsInstances = { workspace.Debree }
RaycastHelper.Everything_Except_Debree.FilterType = Enum.RaycastFilterType.Exclude
local find_character_from_descendant = require(ReplicatedStorage.CAM.Global.Utility.find_character_from_descendant)
local Allegiance = require(ReplicatedStorage.CAM.Global.Allegiance)
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function pointBlankCharacter(vector2: Vector3, vector3: Vector3, p: number, filterDescendantsInstances)
	overlapParams.FilterDescendantsInstances = filterDescendantsInstances
	local v3 = 1e999
	local v4 = nil
	local v5 = nil

	for _, v6 in workspace:GetPartBoundsInRadius(vector2, p + 2, overlapParams) do
		local v7 = find_character_from_descendant(v6)

		if v7 == nil then
			continue
		end

		local humanoidRootPart = v7:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart == nil then
			continue
		end

		local v8 = humanoidRootPart.Position - vector2

		if vector.dot(v8, vector3) < 0 then
			continue
		end

		local v9 = vector.magnitude(v8)

		if not (v9 < v3) then
			continue
		end

		v5 = humanoidRootPart
		v4 = v7
		v3 = v9
	end

	return v4, v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function characterInRange(vector2: Vector3, instance, p: number)
	if instance == nil then
		return false
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	return humanoidRootPart == nil or vector.magnitude(humanoidRootPart.Position - vector2) <= p
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

-- equivalent calls inferred from this helper; original call sites unknown
local function safeDirection(vector2: Vector3, vector3: Vector3)
	if typeof(vector2) ~= "Vector3" or typeof(vector3) ~= "Vector3" then
		return nil
	end

	local v3 = vector3 - vector2
	local v4 = vector.magnitude(v3)

	if v4 == v4 and v4 ~= 1e999 and not (v4 < 0.05) then
		return v3 / v4
	end

	return nil
end

function RaycastHelper.MaximizeRayClient(vector2: Vector3, vector3: Vector3, p: number, flag: boolean?, p2: number?, p3: number?, p4: number?, p5)
	if isServer or (vector2 == nil or vector3 == nil or p == nil) then
		return
	end

	local v3 = safeDirection(vector2, vector3) -- equivalent call inferred; original call site unknown

	if v3 == nil then
		return
	end

	local v4 = v3 * p
	local v5 = nil
	local normal = nil
	local instance = nil
	local raycastResult = workspace:Raycast(vector2, v4, RaycastHelper.Crater)
	local position

	if raycastResult == nil or raycastResult.Position == nil then
		position = vector2 + v4
	else
		position = raycastResult.Position
		normal = raycastResult.Normal
		instance = raycastResult.Instance
	end

	local character = Players.LocalPlayer.Character

	if flag then
		local everyHumanoidExceptPlayer = RaycastHelper.EveryHumanoidExceptPlayer
		local partyId

		if character ~= nil then
			partyId = character:GetAttribute("partyId")
		end

		if partyId ~= nil and partyId ~= "" or Players.LocalPlayer.Team ~= nil or Allegiance.ServerPvpOff() then
			local filterDescendantsInstances = everyHumanoidExceptPlayer.FilterDescendantsInstances

			for _, v6 in Players:GetPlayers() do
				local character2 = v6.Character

				if character2 ~= nil and Allegiance.Protected(character, character2) then
					table.insert(filterDescendantsInstances, character2)
				end
			end

			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			everyHumanoidExceptPlayer = raycastParams
		end

		local raycastResult2 = nil

		if p2 then
			local v6, v7 = pointBlankCharacter(vector2, v3, p2, everyHumanoidExceptPlayer.FilterDescendantsInstances)

			if v6 ~= nil then
				-- equivalent call inferred; original call site unknown
				if not characterInRange(vector2, v6, p) then
					v6 = nil
				end
			end

			if v6 ~= nil then
				position = v7.Position
				normal = -v3
				instance = v7
				v5 = v6
			end
		end

		if v5 == nil then
			if p2 then
				local v6 = v3 * 2
				raycastResult2 = workspace:Spherecast(vector2 - v6, p2, v4 + v6, everyHumanoidExceptPlayer)
			else
				raycastResult2 = workspace:Raycast(vector2, v4, everyHumanoidExceptPlayer)
			end
		end

		if v5 == nil and raycastResult2 ~= nil and raycastResult2.Instance ~= nil then
			local v6 = find_character_from_descendant(raycastResult2.Instance)

			if v6 == nil then
				position = raycastResult2.Position
				normal = raycastResult2.Normal
				instance = raycastResult2.Instance
				v5 = nil
			else
				-- equivalent call inferred; original call site unknown
				if characterInRange(vector2, v6, p) then
					position = raycastResult2.Position
					normal = raycastResult2.Normal
					instance = raycastResult2.Instance
					v5 = v6
				end
			end
		end
	end

	if (flag and v5 == nil or not flag) and p3 ~= nil then
		local v6 = p5 or RaycastHelper.EverythingExceptPlayer
		local raycastResult2

		if p2 == nil then
			raycastResult2 = workspace:Raycast(
				position + vector.create(0, math.min(p3 - 1, 2), 0),
				vector.create(0, -p3, 0),
				v6
			)
		else
			raycastResult2 = workspace:Spherecast(
				position + vector.create(0, math.min(p3 - 1, 2), 0),
				p2,
				vector.create(0, -p3, 0),
				v6
			)
		end

		if raycastResult2 ~= nil and raycastResult2.Instance ~= nil then
			if v5 == nil and flag then
				v5 = find_character_from_descendant(raycastResult2.Instance)

				if v5 ~= nil then
					-- equivalent call inferred; original call site unknown
					if not characterInRange(vector2, v5, p) then
						v5 = nil
					end
				end

				if v5 ~= nil and Allegiance.Protected(character, v5) then
					v5 = nil
				end
			end

			position = raycastResult2.Position
			normal = raycastResult2.Normal
			instance = raycastResult2.Instance
		end
	end

	if v5 == nil and p4 ~= nil then
		position += vector.create(0, p4, 0)
	end

	return position, normal, instance, v5
end

function RaycastHelper.MaximizeRayServer(instance, vector2: Vector3, vector3: Vector3, p: number, flag: boolean?, p2: number?, p3: number?, p4: number?, raycastParams2)
	if not isServer or (vector2 == nil or vector3 == nil or p == nil) then
		return
	end

	local v3 = safeDirection(vector2, vector3) -- equivalent call inferred; original call site unknown

	if v3 == nil then
		return
	end

	local v4 = v3 * p
	local v5 = nil
	local normal = nil
	local instance2 = nil
	local raycastResult = workspace:Raycast(vector2, v4, RaycastHelper.Crater)
	local position

	if raycastResult == nil or raycastResult.Position == nil then
		position = vector2 + v4
	else
		position = raycastResult.Position
		normal = raycastResult.Normal
		instance2 = raycastResult.Instance
	end

	if flag then
		local raycastParams3 = RaycastParams.new()
		raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
		local characters = { instance, workspace.Debree, workspace.Map }
		local partyId = instance:GetAttribute("partyId")
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if partyId ~= nil and partyId ~= "" or playerFromCharacter ~= nil and playerFromCharacter.Team ~= nil or Allegiance.ServerPvpOff() then
			for _, v6 in Players:GetPlayers() do
				local character = v6.Character

				if character ~= nil and Allegiance.Protected(instance, character) then
					table.insert(characters, character)
				end
			end
		end

		raycastParams3.FilterDescendantsInstances = characters
		local raycastResult2 = nil

		if p2 then
			local v6, v7 = pointBlankCharacter(vector2, v3, p2, raycastParams3.FilterDescendantsInstances)

			if v6 ~= nil then
				-- equivalent call inferred; original call site unknown
				if not characterInRange(vector2, v6, p) then
					v6 = nil
				end
			end

			if v6 ~= nil then
				position = v7.Position
				normal = -v3
				instance2 = v7
				v5 = v6
			end
		end

		if v5 == nil then
			if p2 then
				local v6 = v3 * 2
				raycastResult2 = workspace:Spherecast(vector2 - v6, p2, v4 + v6, raycastParams3)
			else
				raycastResult2 = workspace:Raycast(vector2, v4, raycastParams3)
			end
		end

		if v5 == nil and raycastResult2 ~= nil and raycastResult2.Instance ~= nil then
			local v6 = find_character_from_descendant(raycastResult2.Instance)

			if v6 == nil then
				position = raycastResult2.Position
				normal = raycastResult2.Normal
				instance2 = raycastResult2.Instance
				v5 = nil
			else
				-- equivalent call inferred; original call site unknown
				if characterInRange(vector2, v6, p) then
					position = raycastResult2.Position
					normal = raycastResult2.Normal
					instance2 = raycastResult2.Instance
					v5 = v6
				end
			end
		end
	end

	if (flag and v5 == nil or not flag) and p3 ~= nil then
		if not raycastParams2 then
			raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams2.FilterDescendantsInstances = { instance, workspace.Debree }
		end

		local raycastResult2

		if p2 == nil then
			raycastResult2 = workspace:Raycast(
				position + vector.create(0, math.min(p3 - 1, 2), 0),
				vector.create(0, -p3, 0),
				raycastParams2
			)
		else
			raycastResult2 = workspace:Spherecast(
				position + vector.create(0, math.min(p3 - 1, 2), 0),
				p2,
				vector.create(0, -p3, 0),
				raycastParams2
			)
		end

		if raycastResult2 ~= nil and raycastResult2.Instance ~= nil then
			if v5 == nil and flag then
				v5 = find_character_from_descendant(raycastResult2.Instance)

				if v5 ~= nil then
					-- equivalent call inferred; original call site unknown
					if not characterInRange(vector2, v5, p) then
						v5 = nil
					end
				end

				if v5 ~= nil and Allegiance.Protected(instance, v5) then
					v5 = nil
				end
			end

			normal = raycastResult2.Normal
			position = raycastResult2.Position
			instance2 = raycastResult2.Instance
		end
	end

	if v5 == nil and p4 ~= nil then
		position += vector.create(0, p4, 0)
	end

	return position, normal, instance2, v5
end

local overlapParams2 = OverlapParams.new()
overlapParams2.FilterType = Enum.RaycastFilterType.Include
overlapParams2.FilterDescendantsInstances = { workspace.Map }
overlapParams2.RespectCanCollide = true
local part = Instance.new("Part")
part.Size = createVector(1, 1, 1)
part.Anchored = true
part.CanCollide = false

function RaycastHelper.ResolveCarryRelease(vector2: Vector3, cframe: CFrame, vector3: Vector3?)
	if vector3 ~= nil then
		local v3 = cframe.Position - vector3

		if v3.Magnitude > 0.001 then
			local raycastResult = workspace:Raycast(vector3, v3, RaycastHelper.Crater)

			if raycastResult ~= nil and math.abs(raycastResult.Normal.Y) < 0.5 then
				return CFrame.new(raycastResult.Position + raycastResult.Normal * 2) * cframe.Rotation
			end
		end
	end

	local v3 = cframe.Position - vector2
	local v4

	if v3.Magnitude > 0.001 then
		local raycastResult = workspace:Raycast(vector2, v3, RaycastHelper.Crater)

		if raycastResult == nil then
			v4 = cframe
		else
			v4 = CFrame.new(raycastResult.Position + raycastResult.Normal * 2) * cframe.Rotation
		end
	else
		v4 = cframe
	end

	local position = v4.Position
	part.CFrame = CFrame.new(position)
	local v5 = #workspace:GetPartsInPart(part, overlapParams2) > 0

	if not v5 and workspace:Raycast(position, createVector(0, -50, 0), RaycastHelper.Crater) ~= nil then
		return v4
	end

	if v5 then
		local v6 = vector2 - position

		for i = 1, v6.Magnitude do
			local v7 = position + v6.Unit * i
			part.CFrame = CFrame.new(v7)

			if #workspace:GetPartsInPart(part, overlapParams2) == 0 and workspace:Raycast(
				v7,
				createVector(0, -50, 0),
				RaycastHelper.Crater
			) ~= nil then
				return CFrame.new(v7) * cframe.Rotation
			end
		end
	end

	local raycastResult = workspace:Raycast(
		position + createVector(0, 50, 0),
		createVector(0, -50, 0),
		RaycastHelper.Crater
	)

	if raycastResult ~= nil and raycastResult.Instance.Transparency < 1 then
		return CFrame.new(raycastResult.Position + raycastResult.Normal * 2) * cframe.Rotation
	end

	if v5 or raycastResult ~= nil then
		return v4
	end

	local raycastResult2 = workspace:Raycast(position, createVector(0, 300, 0), RaycastHelper.Crater)

	if raycastResult2 == nil or not (raycastResult2.Instance.Transparency < 1) then
		return v4
	end

	local instance = raycastResult2.Instance
	local v6

	if instance:IsA("Terrain") then
		v6 = raycastResult2.Position.Y + 50
	else
		v6 = instance.Position.Y + instance.Size.Magnitude / 2 + 1
	end

	local v7 = v6 - raycastResult2.Position.Y + 1
	local raycastResult3 = workspace:Raycast(
		Vector3.new(position.X, v6, position.Z),
		Vector3.new(0, -v7, 0),
		RaycastHelper.Crater
	)

	if raycastResult3 ~= nil and raycastResult3.Instance.Transparency < 1 then
		return CFrame.new(raycastResult3.Position + raycastResult3.Normal * 2) * cframe.Rotation
	end

	return v4
end

function RaycastHelper.ResolveGrabPin(vector2: Vector3, cframe: CFrame, p: number)
	local v3 = vector2 - cframe.LookVector * 1.5
	local v4 = (cframe.Position - vector2).Magnitude + p + 1.5
	local raycastResult = workspace:Raycast(v3, cframe.LookVector * v4, RaycastHelper.Crater)

	if raycastResult == nil or math.abs(raycastResult.Normal.Y) >= 0.5 then
		return cframe
	end

	local v5 = v4 - (raycastResult.Position - v3).Magnitude

	if v5 <= 0 then
		return cframe
	end

	return cframe * CFrame.new(0, 0, v5)
end

return RaycastHelper