local Players = game:GetService("Players")
local commonUtils = script.Parent.Parent.Parent:WaitForChild("CommonUtils")
local FlagUtil = require(commonUtils:WaitForChild("FlagUtil"))
local CameraWrapper = require(commonUtils:WaitForChild("CameraWrapper"))
local ConnectionUtil = require(commonUtils:WaitForChild("ConnectionUtil"))
local userFlag = FlagUtil.getUserFlag("UserRaycastUpdateAPI")
local userFlag2 = FlagUtil.getUserFlag("UserCurrentCameraUpdate2")
local userFlag3 = FlagUtil.getUserFlag("UserPlayerConnectionMemoryLeak")
local v

if userFlag2 then
	v = CameraWrapper.new()
else
	v = nil
end

local currentCamera

if userFlag2 then
	currentCamera = nil
else
	currentCamera = game.Workspace.CurrentCamera
end

if userFlag2 then
	v:Enable()
end

local min = math.min
local tan = math.tan
local rad = math.rad
local new = Ray.new
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local raycastParams2 = RaycastParams.new()
raycastParams2.IgnoreWater = true
raycastParams2.FilterType = Enum.RaycastFilterType.Include
local v2

if userFlag3 then
	v2 = ConnectionUtil.new()
else
	v2 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTotalTransparency(p)
	return 1 - (1 - p.Transparency) * (1 - p.LocalTransparencyModifier)
end

local function eraseFromEnd(list, p)
	for i = #list, p + 1, -1 do
		list[i] = nil
	end
end

local v3 = nil
local v4 = nil
local nearPlaneZ

if userFlag2 then
	local function updateProjection()
		local camera = v:getCamera()
		local v5 = rad(camera.FieldOfView)
		local viewportSize = camera.ViewportSize
		local v6 = viewportSize.X / viewportSize.Y
		v4 = tan(v5 / 2) * 2
		v3 = v6 * v4
	end

	v:Connect("FieldOfView", updateProjection)
	v:Connect("ViewportSize", updateProjection)
	local camera = v:getCamera()
	local fieldOfView = rad(camera.FieldOfView)
	local viewportSize = camera.ViewportSize
	local v5 = viewportSize.X / viewportSize.Y
	v4 = tan(fieldOfView / 2) * 2
	v3 = v5 * v4
	nearPlaneZ = v:getCamera().NearPlaneZ
	v:Connect("NearPlaneZ", function()
		nearPlaneZ = v:getCamera().NearPlaneZ
	end)
else
	local function updateProjection()
		local v5 = rad(currentCamera.FieldOfView)
		local viewportSize = currentCamera.ViewportSize
		local v6 = viewportSize.X / viewportSize.Y
		v4 = tan(v5 / 2) * 2
		v3 = v6 * v4
	end

	currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
	currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)
	local fieldOfView = rad(currentCamera.FieldOfView)
	local viewportSize = currentCamera.ViewportSize
	local v5 = viewportSize.X / viewportSize.Y
	v4 = tan(fieldOfView / 2) * 2
	v3 = v5 * v4
	nearPlaneZ = currentCamera.NearPlaneZ
	currentCamera:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
		nearPlaneZ = currentCamera.NearPlaneZ
	end)
end

local filterDescendantsInstances = {}
local v6 = {}
local v7 = {
	workspace.Monster,
	workspace.PlayerCharacters,
	workspace.CharacterWorkshop,
	workspace.Effects,
	workspace.MOB,
	workspace.CurrentCamera,
	workspace.SeaMonster,
	workspace.Ships,
	workspace.AllNPC,
	workspace.AllDroppedFruit,
	workspace.FlagConquest
}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshIgnoreList()
	local v8 = 1
	filterDescendantsInstances = {}

	for _, v9 in pairs(v6) do
		filterDescendantsInstances[v8] = v9
		v8 += 1
	end
end

local function playerAdded(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v6[player] = character

		for _, v8 in pairs(v7) do
			table.insert(v6, v8)
		end

		refreshIgnoreList() -- equivalent call inferred; original call site unknown
	end

	local function characterRemoving()
		v6[player] = nil
		refreshIgnoreList() -- equivalent call inferred; original call site unknown
	end

	if userFlag3 then
		v2:trackConnection(`{player.UserId}CharacterAdded`, player.CharacterAdded:Connect(characterAdded))
		v2:trackConnection(`{player.UserId}CharacterRemoving`, player.CharacterRemoving:Connect(characterRemoving))
	else
		player.CharacterAdded:Connect(characterAdded)
		player.CharacterRemoving:Connect(characterRemoving)
	end

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end
end

local function playerRemoving(p)
	v6[p] = nil
	refreshIgnoreList() -- equivalent call inferred; original call site unknown

	if userFlag3 then
		v2:disconnect((`{p.UserId}CharacterAdded`))
		v2:disconnect((`{p.UserId}CharacterRemoving`))
	end
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v8 in ipairs(Players:GetPlayers()) do
	playerAdded(v8)
end

refreshIgnoreList() -- equivalent call inferred; original call site unknown
local rootPart = nil
local rootPart2 = nil

if userFlag2 then
	v:Connect("CameraSubject", function()
		local cameraSubject = v:getCamera().CameraSubject

		if cameraSubject and cameraSubject:IsA("Humanoid") then
			rootPart2 = cameraSubject.RootPart
		elseif cameraSubject and cameraSubject:IsA("BasePart") then
			rootPart2 = cameraSubject
		else
			rootPart2 = nil
		end
	end)
else
	currentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
		local cameraSubject = currentCamera.CameraSubject

		if cameraSubject:IsA("Humanoid") then
			rootPart2 = cameraSubject.RootPart
		elseif cameraSubject:IsA("BasePart") then
			rootPart2 = cameraSubject
		else
			rootPart2 = nil
		end
	end)
end

local function canOcclude(trussPart)
	local canCollide

	if getTotalTransparency(trussPart) < 0.25 then
		canCollide = trussPart.CanCollide

		if canCollide then
			if rootPart == (trussPart:GetRootPart() or trussPart) then
				canCollide = false
			else
				canCollide = not trussPart:IsA("TrussPart")
			end
		end
	else
		canCollide = false
	end

	return canCollide
end

local v8 = {
	Vector2.new(0.4, 0),
	Vector2.new(-0.4, 0),
	Vector2.new(0, -0.4),
	Vector2.new(0, 0.4),
	Vector2.new(0, 0.2)
}

local function getCollisionPoint(p, p2)
	if userFlag then
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances

		repeat
			local raycastResult = workspace:Raycast(p, p2, raycastParams)

			if raycastResult then
				if raycastResult.Instance.CanCollide then
					return raycastResult.Position, true
				else
					raycastParams:AddToFilter(raycastResult.Instance)
				end
			end
		until not raycastResult
	else
		local count = #filterDescendantsInstances

		while true do
			local part, v9 = workspace:FindPartOnRayWithIgnoreList(new(p, p2), filterDescendantsInstances, false, true)

			if part then
				if part.CanCollide then
					local v10 = filterDescendantsInstances

					for i = #v10, count + 1, -1 do
						v10[i] = nil
					end

					return v9, true
				else
					filterDescendantsInstances[#filterDescendantsInstances + 1] = part
				end
			end

			if part then
				continue
			end

			local v10 = filterDescendantsInstances

			for i = #v10, count + 1, -1 do
				v10[i] = nil
			end

			break
		end
	end

	return p + p2, false
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local v9 = #filterDescendantsInstances
	local v10 = p3 + nearPlaneZ
	local v11 = p + p2 * v10
	local v12 = 1e999
	local v13 = 1e999
	local count = 0

	if userFlag then
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local v14 = p

		while true do
			local raycastResult = workspace:Raycast(v14, v11 - v14, raycastParams)

			if not raycastResult then
				break
			end

			count += 1
			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local magnitude = (position - p).Magnitude

			if count >= 64 then
				v13 = magnitude
			else
				local canCollide

				if getTotalTransparency(instance) < 0.25 then
					canCollide = instance.CanCollide

					if canCollide then
						if rootPart == (instance:GetRootPart() or instance) then
							canCollide = false
						else
							canCollide = not instance:IsA("TrussPart")
						end
					end
				else
					canCollide = false
				end

				if canCollide then
					raycastParams2.FilterDescendantsInstances = { instance }

					if workspace:Raycast(v11, position - v11, raycastParams2) then
						local v15

						if p4 then
							v15 = workspace:Raycast(p4, v11 - p4, raycastParams2) or workspace:Raycast(
								v11,
								p4 - v11,
								raycastParams2
							)
						else
							v15 = false
						end

						if v15 then
							v13 = magnitude
						elseif v10 < v12 then
							v12 = magnitude
						end
					else
						v13 = magnitude
					end
				end
			end

			raycastParams:AddToFilter(instance)
			v14 = position - p2 * 0.001

			if v13 < 1e999 or not instance then
				break
			end
		end
	else
		local v14 = p

		while true do
			local trussPart, v15 = workspace:FindPartOnRayWithIgnoreList(
				new(v14, v11 - v14),
				filterDescendantsInstances,
				false,
				true
			)
			count += 1

			if trussPart then
				local v16 = count >= 64
				local canCollide

				if getTotalTransparency(trussPart) < 0.25 then
					canCollide = trussPart.CanCollide

					if canCollide then
						if rootPart == (trussPart:GetRootPart() or trussPart) then
							canCollide = false
						else
							canCollide = not trussPart:IsA("TrussPart")
						end
					end
				else
					canCollide = false
				end

				if canCollide or v16 then
					local v17 = { trussPart }
					local part = workspace:FindPartOnRayWithWhitelist(new(v11, v15 - v11), v17, true)
					local magnitude = (v15 - p).Magnitude

					if part and not v16 then
						local v18

						if p4 then
							v18 = workspace:FindPartOnRayWithWhitelist(new(p4, v11 - p4), v17, true) or workspace:FindPartOnRayWithWhitelist(
								new(v11, p4 - v11),
								v17,
								true
							)
						else
							v18 = false
						end

						if v18 then
							v13 = magnitude
						elseif v10 < v12 then
							v12 = magnitude
						end
					else
						v13 = magnitude
					end
				end

				filterDescendantsInstances[#filterDescendantsInstances + 1] = trussPart
				v14 = v15 - p2 * 0.001
			end

			if not (v13 < 1e999 or not trussPart) then
				continue
			end

			local v16 = filterDescendantsInstances

			for i = #v16, v9 + 1, -1 do
				v16[i] = nil
			end

			break
		end
	end

	debug.profileend()
	return v12 - nearPlaneZ, v13 - nearPlaneZ
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v9 = -data.lookVector
	local v10

	if userFlag2 then
		v10 = v:getCamera()
	else
		v10 = currentCamera
	end

	currentCamera = v10
	local viewportSize = currentCamera.ViewportSize
	local v11 = 1e999
	local v12 = 1e999

	for i = 0, 1 do
		local v13 = rightVector * ((i - 0.5) * v3)

		for i2 = 0, 1 do
			local v14 = upVector * ((i2 - 0.5) * v4)
			local v16, v17 = queryPoint(
				p2 + nearPlaneZ * (v13 + v14),
				v9,
				p,
				currentCamera:ViewportPointToRay(viewportSize.x * i, viewportSize.y * i2).Origin
			)

			if v17 < v11 then
				v11 = v17
			end

			if v16 < v12 then
				v12 = v16
			end
		end
	end

	debug.profileend()
	return v12, v11
end

local function testPromotion(data, p, data2)
	debug.profilebegin("testPromotion")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v9 = -data.lookVector
	debug.profilebegin("extrapolate")
	local magnitude = (getCollisionPoint(p2, data2.posVelocity * 1.25) - p2).Magnitude
	local magnitude2 = data2.posVelocity.magnitude

	for i = 0, min(1.25, data2.rotVelocity.magnitude + magnitude / magnitude2), 0.0625 do
		local extrapolate = data2.extrapolate(i)

		if p <= queryPoint(extrapolate.p, -extrapolate.lookVector, p) then
			return false
		end
	end

	debug.profileend()
	debug.profilebegin("testOffsets")

	for _, v11 in ipairs(v8) do
		local collisionPoint = getCollisionPoint(p2, rightVector * v11.x + upVector * v11.y)

		if queryPoint(collisionPoint, (p2 + v9 * p - collisionPoint).Unit, p) == 1e999 then
			return false
		end
	end

	debug.profileend()
	debug.profileend()
	return true
end

local function Popper(p, p2, p3)
	debug.profilebegin("popper")
	rootPart = rootPart2 and rootPart2:GetRootPart() or rootPart2
	local v9, v10 = queryViewport(p, p2)

	if not (v10 < p2) then
		v10 = p2
	end

	if v9 < v10 and testPromotion(p, p2, p3) then
		v10 = v9
	end

	rootPart = nil
	debug.profileend()
	return v10
end

return Popper