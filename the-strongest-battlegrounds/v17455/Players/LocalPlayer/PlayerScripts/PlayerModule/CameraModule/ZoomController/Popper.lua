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
local _ = { "DomanPart", "Hollow", "DestroyedPart" }
local v6 = {}
local v7 = {}
local now = 0
local TweenService = game:GetService("TweenService")

local function isTreePart(instance)
	if instance:GetAttribute("IsTree") or instance.Name:find("TreeRoot", 1, true) then
		return true
	end

	local parent = instance.Parent
	return parent ~= nil and (parent:FindFirstChild("TreeRoot") ~= nil or parent:FindFirstChild("breakedmodelTreeRoot") ~= nil)
end

local function fadeTree(object)
	v7[object] = true

	if v6[object] then
		return
	end

	local tween = TweenService:Create(object, TweenInfo.new(0.125), {
		LocalTransparencyModifier = 0.85
	})
	v6[object] = tween
	tween:Play()
end

local function restoreTrees(p)
	for k, v8 in pairs(v6) do
		if not (p or not v7[k]) then
			continue
		end

		v8:Cancel()
		v8:Destroy()
		v6[k] = nil

		if k.Parent then
			TweenService:Create(k, TweenInfo.new(0.125), {
				LocalTransparencyModifier = 0
			}):Play()
		else
			k.LocalTransparencyModifier = 0
		end
	end

	table.clear(v7)
end

local function canOcclude(part)
	if isTreePart(part) then
		fadeTree(part)
		return true
	end

	local canCollide

	if getTotalTransparency(part) < 0.25 then
		canCollide = part.CanCollide

		if canCollide then
			if part.CollisionGroup == "nocol" or part.CollisionGroup == "untouchable" then
				canCollide = false
			else
				canCollide = rootPart ~= (part:GetRootPart() or part)
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
	local count = #v4

	while true do
		local part, v9 = workspace:FindPartOnRayWithIgnoreList(new(p, p2), v4, false, true)

		if part then
			if part.CanCollide then
				local v10 = v4

				for i = #v10, count + 1, -1 do
					v10[i] = nil
				end

				return v9, true
			else
				v4[#v4 + 1] = part
			end
		end

		if part then
			continue
		end

		local v10 = v4

		for i = #v10, count + 1, -1 do
			v10[i] = nil
		end

		return p + p2, false
	end
end

local function queryPoint(p, p2, p3, p4)
	debug.profilebegin("queryPoint")
	local v9 = #v4
	local v10 = p3 + nearPlaneZ
	local v11 = p + p2 * v10
	local v12 = p
	local count = 0
	local v13 = 1e999
	local v14 = 1e999

	while true do
		local part, v15 = workspace:FindPartOnRayWithIgnoreList(new(v12, v11 - v12), v4, false, true)
		count += 1

		if part then
			local v16 = count >= 64

			if (canOcclude(part) or v16) and not isTreePart(part) then
				local v17 = { part }
				local part2 = workspace:FindPartOnRayWithWhitelist(new(v11, v15 - v11), v17, true)
				local magnitude = (v15 - p).Magnitude

				if part2 and not v16 then
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
					elseif v10 < v14 then
						v14 = magnitude
					end
				else
					v13 = magnitude
				end
			end

			v4[#v4 + 1] = part
			v12 = v15 - p2 * 0.001
		end

		if not (v13 < 1e999 or not part) then
			continue
		end

		local v16 = v4

		for i = #v16, v9 + 1, -1 do
			v16[i] = nil
		end

		debug.profileend()
		return v14 - nearPlaneZ, v13 - nearPlaneZ
	end
end

local function queryViewport(data, p)
	debug.profilebegin("queryViewport")
	local p2 = data.p
	local rightVector = data.rightVector
	local upVector = data.upVector
	local v9 = -data.lookVector
	local viewportSize2 = currentCamera.ViewportSize
	local v10 = 1e999
	local v11 = 1e999

	for i = 0, 1 do
		local v12 = rightVector * ((i - 0.5) * v)

		for i2 = 0, 1 do
			local v13 = upVector * ((i2 - 0.5) * v2)
			local v15, v16 = queryPoint(
				p2 + nearPlaneZ * (v12 + v13),
				v9,
				p,
				currentCamera:ViewportPointToRay(viewportSize2.x * i, viewportSize2.y * i2).Origin
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

	restoreTrees(false)
	now = os.clock()
	rootPart = nil
	debug.profileend()
	return v10
end

task.spawn(function()
	while task.wait(0.5) do
		if not (next(v6) and os.clock() - now > 0.5) then
			continue
		end

		restoreTrees(true)
	end
end)
return Popper