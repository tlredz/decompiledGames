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

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshIgnoreList()
	local v7 = 1
	filterDescendantsInstances = {}

	for _, v8 in pairs(v6) do
		filterDescendantsInstances[v7] = v8
		v7 += 1
	end
end

local function playerAdded(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v6[player] = character
		refreshIgnoreList() -- equivalent call inferred; original call site unknown
	end

	local function characterRemoving()
		characterAdded(nil) -- equivalent call inferred; original call site unknown
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

for _, v7 in ipairs(Players:GetPlayers()) do
	playerAdded(v7)
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

	if (trussPart.Name == "structure base home" and 0.65 or 0.25) > getTotalTransparency(trussPart) then
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

local v7 = {
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
			local part, v8 = workspace:FindPartOnRayWithIgnoreList(new(p, p2), filterDescendantsInstances, false, true)

			if part then
				if part.CanCollide then
					local v9 = filterDescendantsInstances

					for i = #v9, count + 1, -1 do
						v9[i] = nil
					end

					return v8, true
				else
					filterDescendantsInstances[#filterDescendantsInstances + 1] = part
				end
			end

			if part then
				continue
			end

			local v9 = filterDescendantsInstances

			for i = #v9, count + 1, -1 do
				v9[i] = nil
			end

			break
		end
	end

	return p + p2, false
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local v8 = #filterDescendantsInstances
	local v9 = p3 + nearPlaneZ
	local v10 = p + p2 * v9
	local v11 = 1e999
	local v12 = 1e999
	local count = 0

	if userFlag then
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		local v13 = p

		while true do
			local raycastResult = workspace:Raycast(v13, v10 - v13, raycastParams)

			if not raycastResult then
				break
			end

			count += 1
			local instance = raycastResult.Instance
			local position = raycastResult.Position
			local magnitude = (position - p).Magnitude

			if count >= 64 then
				v12 = magnitude
			else
				local canCollide

				if (instance.Name == "structure base home" and 0.65 or 0.25) > getTotalTransparency(instance) then
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

					if workspace:Raycast(v10, position - v10, raycastParams2) then
						local v14

						if p4 then
							v14 = workspace:Raycast(p4, v10 - p4, raycastParams2) or workspace:Raycast(
								v10,
								p4 - v10,
								raycastParams2
							)
						else
							v14 = false
						end

						if v14 then
							v12 = magnitude
						elseif v9 < v11 then
							v11 = magnitude
						end
					else
						v12 = magnitude
					end
				end
			end

			raycastParams:AddToFilter(instance)
			v13 = position - p2 * 0.001

			if v12 < 1e999 or not instance then
				break
			end
		end
	else
		local v13 = p

		while true do
			local trussPart, v14 = workspace:FindPartOnRayWithIgnoreList(
				new(v13, v10 - v13),
				filterDescendantsInstances,
				false,
				true
			)
			count += 1

			if trussPart then
				local v15 = count >= 64
				local canCollide

				if (trussPart.Name == "structure base home" and 0.65 or 0.25) > getTotalTransparency(trussPart) then
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

				if canCollide or v15 then
					local v16 = { trussPart }
					local part = workspace:FindPartOnRayWithWhitelist(new(v10, v14 - v10), v16, true)
					local magnitude = (v14 - p).Magnitude

					if part and not v15 then
						local v17

						if p4 then
							v17 = workspace:FindPartOnRayWithWhitelist(new(p4, v10 - p4), v16, true) or workspace:FindPartOnRayWithWhitelist(
								new(v10, p4 - v10),
								v16,
								true
							)
						else
							v17 = false
						end

						if v17 then
							v12 = magnitude
						elseif v9 < v11 then
							v11 = magnitude
						end
					else
						v12 = magnitude
					end
				end

				filterDescendantsInstances[#filterDescendantsInstances + 1] = trussPart
				v13 = v14 - p2 * 0.001
			end

			if not (v12 < 1e999 or not trussPart) then
				continue
			end

			local v15 = filterDescendantsInstances

			for i = #v15, v8 + 1, -1 do
				v15[i] = nil
			end

			break
		end
	end

	debug.profileend()
	return v11 - nearPlaneZ, v12 - nearPlaneZ
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v8 = -data.lookVector
	local v9

	if userFlag2 then
		v9 = v:getCamera()
	else
		v9 = currentCamera
	end

	currentCamera = v9
	local viewportSize = currentCamera.ViewportSize
	local v10 = 1e999
	local v11 = 1e999

	for i = 0, 1 do
		local v12 = rightVector * ((i - 0.5) * v3)

		for i2 = 0, 1 do
			local v13 = upVector * ((i2 - 0.5) * v4)
			local v15, v16 = queryPoint(
				p2 + nearPlaneZ * (v12 + v13),
				v8,
				p,
				currentCamera:ViewportPointToRay(viewportSize.x * i, viewportSize.y * i2).Origin
			)

			if v16 < v10 then
				v10 = v16
			end

			if v15 < v11 then
				v11 = v15
			end
		end
	end

	debug.profileend()
	return v11, v10
end

local function testPromotion(data, p, data2)
	debug.profilebegin("testPromotion")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v8 = -data.lookVector
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

	for _, v10 in ipairs(v7) do
		local collisionPoint = getCollisionPoint(p2, rightVector * v10.x + upVector * v10.y)

		if queryPoint(collisionPoint, (p2 + v8 * p - collisionPoint).Unit, p) == 1e999 then
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
	local v8, v9 = queryViewport(p, p2)

	if not (v9 < p2) then
		v9 = p2
	end

	if v8 < v9 and testPromotion(p, p2, p3) then
		v9 = v8
	end

	rootPart = nil
	debug.profileend()
	return v9
end

return Popper