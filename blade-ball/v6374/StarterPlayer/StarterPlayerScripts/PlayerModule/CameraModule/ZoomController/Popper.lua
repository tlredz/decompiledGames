local Players = game:GetService("Players")
local currentCamera = game.Workspace.CurrentCamera
local min = math.min
local tan = math.tan
local rad = math.rad
local new = Ray.new

-- equivalent calls inferred from this helper; original call sites unknown
local function getTotalTransparency(p)
	return 1 - (1 - p.Transparency) * (1 - p.LocalTransparencyModifier)
end

local function eraseFromEnd(list, p)
	for i = #list, p + 1, -1 do
		list[i] = nil
	end
end

local v = nil
local v2 = nil

local function updateProjection()
	local v3 = rad(currentCamera.FieldOfView)
	local viewportSize = currentCamera.ViewportSize
	local v4 = viewportSize.X / viewportSize.Y
	v2 = tan(v3 / 2) * 2
	v = v4 * v2
end

currentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(updateProjection)
currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateProjection)
local fieldOfView = rad(currentCamera.FieldOfView)
local viewportSize = currentCamera.ViewportSize
local v3 = viewportSize.X / viewportSize.Y
v2 = tan(fieldOfView / 2) * 2
v = v3 * v2
local nearPlaneZ = currentCamera.NearPlaneZ
currentCamera:GetPropertyChangedSignal("NearPlaneZ"):Connect(function()
	nearPlaneZ = currentCamera.NearPlaneZ
end)
local v4 = {}
local v5 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshIgnoreList()
	local v6 = 1
	v4 = {}

	for _, v7 in pairs(v5) do
		v4[v6] = v7
		v6 += 1
	end
end

local function playerAdded(player)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function characterAdded(character)
		v5[player] = character
		refreshIgnoreList() -- equivalent call inferred; original call site unknown
	end

	local function characterRemoving()
		characterAdded(nil) -- equivalent call inferred; original call site unknown
	end

	player.CharacterAdded:Connect(characterAdded)
	player.CharacterRemoving:Connect(characterRemoving)

	if player.Character then
		characterAdded(player.Character) -- equivalent call inferred; original call site unknown
	end
end

local function playerRemoving(p)
	v5[p] = nil
	refreshIgnoreList() -- equivalent call inferred; original call site unknown
end

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

for _, v6 in ipairs(Players:GetPlayers()) do
	playerAdded(v6)
end

refreshIgnoreList() -- equivalent call inferred; original call site unknown
local rootPart = nil
local rootPart2 = nil
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

local v6 = {
	Vector2.new(0.4, 0),
	Vector2.new(-0.4, 0),
	Vector2.new(0, -0.4),
	Vector2.new(0, 0.4),
	Vector2.new(0, 0.2)
}

local function getCollisionPoint(p, p2)
	local count = #v4

	while true do
		local part, v7 = workspace:FindPartOnRayWithIgnoreList(new(p, p2), v4, false, true)

		if part then
			if part.CanCollide then
				local v8 = v4

				for i = #v8, count + 1, -1 do
					v8[i] = nil
				end

				return v7, true
			else
				v4[#v4 + 1] = part
			end
		end

		if part then
			continue
		end

		local v8 = v4

		for i = #v8, count + 1, -1 do
			v8[i] = nil
		end

		return p + p2, false
	end
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local v7 = #v4
	local v8 = p3 + nearPlaneZ
	local v9 = p + p2 * v8
	local v10 = p
	local count = 0
	local v11 = 1e999
	local v12 = 1e999

	while true do
		local trussPart, v13 = workspace:FindPartOnRayWithIgnoreList(new(v10, v9 - v10), v4, false, true)
		count += 1

		if trussPart then
			local v14 = count >= 64
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

			if canCollide or v14 then
				local v15 = { trussPart }
				local part = workspace:FindPartOnRayWithWhitelist(new(v9, v13 - v9), v15, true)
				local magnitude = (v13 - p).Magnitude

				if part and not v14 then
					local v16

					if p4 then
						v16 = workspace:FindPartOnRayWithWhitelist(new(p4, v9 - p4), v15, true) or workspace:FindPartOnRayWithWhitelist(
							new(v9, p4 - v9),
							v15,
							true
						)
					else
						v16 = false
					end

					if v16 then
						v11 = magnitude
					elseif v8 < v12 then
						v12 = magnitude
					end
				else
					v11 = magnitude
				end
			end

			v4[#v4 + 1] = trussPart
			v10 = v13 - p2 * 0.001
		end

		if not (v11 < 1e999 or not trussPart) then
			continue
		end

		local v14 = v4

		for i = #v14, v7 + 1, -1 do
			v14[i] = nil
		end

		debug.profileend()
		return v12 - nearPlaneZ, v11 - nearPlaneZ
	end
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v7 = -data.lookVector
	local viewportSize2 = currentCamera.ViewportSize
	local v8 = 1e999
	local v9 = 1e999

	for i = 0, 1 do
		local v10 = rightVector * ((i - 0.5) * v)

		for i2 = 0, 1 do
			local v11 = upVector * ((i2 - 0.5) * v2)
			local v13, v14 = queryPoint(
				p2 + nearPlaneZ * (v10 + v11),
				v7,
				p,
				currentCamera:ViewportPointToRay(viewportSize2.x * i, viewportSize2.y * i2).Origin
			)

			if v14 < v8 then
				v8 = v14
			end

			if v13 < v9 then
				v9 = v13
			end
		end
	end

	debug.profileend()
	return v9, v8
end

local function testPromotion(data, p, data2)
	debug.profilebegin("testPromotion")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v7 = -data.lookVector
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

	for _, v9 in ipairs(v6) do
		local collisionPoint = getCollisionPoint(p2, rightVector * v9.x + upVector * v9.y)

		if queryPoint(collisionPoint, (p2 + v7 * p - collisionPoint).Unit, p) == 1e999 then
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
	local v7, v8 = queryViewport(p, p2)

	if not (v8 < p2) then
		v8 = p2
	end

	if v7 < v8 and testPromotion(p, p2, p3) then
		v8 = v7
	end

	rootPart = nil
	debug.profileend()
	return v8
end

return Popper