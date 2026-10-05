local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

if not RunService:IsClient() then
	return function() end
end

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local templates = script:WaitForChild("Templates")
local edgeIndicator = script:WaitForChild("EdgeIndicator")
edgeIndicator.Visible = false
local v = {
	boss = "Boss",
	default = "Boss",
	normal = "Boss",
	raid = "RaidBoss",
	raidboss = "RaidBoss",
	["raid boss"] = "RaidBoss",
	awakened = "Awakened Boss",
	awakenedboss = "Awakened Boss",
	["awakened boss"] = "Awakened Boss"
}
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function billboardSizeFor(p: number)
	local v3 = math.round(p * 0.11)
	return UDim2.fromOffset(v3, v3)
end

local v3 = 0
local uDim = UDim2.fromOffset(119, 119)

local function getCamera()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		return currentCamera
	end

	workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
	return workspace.CurrentCamera
end

local function ScreenGui()
	local v4 = v2

	if v4 and v4.Parent then
		return v4
	end

	local bossEdgeGui = playerGui:FindFirstChild("BossEdgeGui")

	if bossEdgeGui and bossEdgeGui:IsA("ScreenGui") then
		v2 = bossEdgeGui
		return bossEdgeGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BossEdgeGui"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v2 = screenGui
	return screenGui
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function distanceTransparency(p: number)
	if p <= 0 then
		return 0
	end

	if p <= 500 then
		return p / 500 * 0.75
	end

	if p <= 750 then
		return 0.75
	end

	if p <= 1000 then
		return (p - 750) / 250 * 0.25 + 0.75
	end

	return 1
end

local function picky(value)
	if typeof(value) ~= "string" or value == "" or not value then
		value = nil
	end

	return value
end

local function resolveType(childName)
	if typeof(childName) ~= "string" or childName == "" or not childName then
		childName = nil
	end

	if not childName then
		return nil
	end

	if templates:FindFirstChild(childName) then
		return childName
	end

	local v4 = v[string.lower(childName)]

	if v4 and templates:FindFirstChild(v4) then
		return v4
	end

	return nil
end

local function inferType(instance)
	local bossIndicatorType = instance:GetAttribute("BossIndicatorType")

	if typeof(bossIndicatorType) ~= "string" or bossIndicatorType == "" or not bossIndicatorType then
		bossIndicatorType = nil
	end

	if bossIndicatorType then
		if not templates:FindFirstChild(bossIndicatorType) then
			bossIndicatorType = v[string.lower(bossIndicatorType)]

			if not (bossIndicatorType and templates:FindFirstChild(bossIndicatorType)) then
				bossIndicatorType = nil
			end
		end
	else
		bossIndicatorType = nil
	end

	if bossIndicatorType then
		return bossIndicatorType
	end

	if instance:GetAttribute("RaidBoss") then
		return "RaidBoss"
	end

	return "Boss"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function templateFor(bossType: string)
	return ((templates:FindFirstChild(bossType) or templates:WaitForChild("Boss")):WaitForChild("BossIndicator"))
end

local v4 = {}
local renderSteppedConnection = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupIfEmpty()
	if #v4 > 0 then
		return
	end

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	local v5 = v2

	if v5 and v5.Parent then
		v5:Destroy()
	end

	v2 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyWorldBB(p)
	if p.worldBB then
		p.worldBB:Destroy()
	end

	p.worldBB = nil
	p.worldIcon = nil
	p.worldGlow = nil
	p.worldArrow = nil
end

local function removeTracked(p)
	for i, v5 in ipairs(v4) do
		if v5.model ~= p then
			continue
		end

		if v5.diedConn then
			v5.diedConn:Disconnect()
			v5.diedConn = nil
		end

		if v5.healthConn then
			v5.healthConn:Disconnect()
			v5.healthConn = nil
		end

		if v5.ancestryConn then
			v5.ancestryConn:Disconnect()
			v5.ancestryConn = nil
		end

		destroyWorldBB(v5) -- equivalent call inferred; original call site unknown

		if v5.edgeFrame then
			v5.edgeFrame:Destroy()
		end

		table.remove(v4, i)
		break
	end

	cleanupIfEmpty() -- equivalent call inferred; original call site unknown
end

local function syncBillboardSize(Y: number)
	if not (Y > 0) or Y == v3 then
		return uDim
	end

	v3 = Y
	uDim = billboardSizeFor(Y)

	for _, v5 in ipairs(v4) do
		if v5.worldBB then
			v5.worldBB.Size = uDim
		end
	end

	return uDim
end

local function studsUp(model, hrp)
	local success, result, v5 = pcall(function()
		return model:GetBoundingBox()
	end)

	if success and typeof(result) == "CFrame" then
		return (math.max(3.5, result.Position.Y + v5.Y * 0.5 - hrp.Position.Y + 1))
	end

	return 3.5
end

local function applyType(state, bossType: string)
	state.bossType = bossType
	local v5 = templateFor(bossType) -- equivalent call inferred; original call site unknown
	local icon = v5:FindFirstChild("Icon")
	local glow = v5:FindFirstChild("Glow")
	local pointerArrow = v5:FindFirstChild("PointerArrow")
	destroyWorldBB(state) -- equivalent call inferred; original call site unknown
	local clone = v5:Clone()
	clone.Name = "BossWorldBB"
	clone.Adornee = state.hrp
	clone.Enabled = true
	clone.AlwaysOnTop = true
	clone.MaxDistance = 5000
	clone.StudsOffsetWorldSpace = Vector3.new(0, studsUp(state.model, state.hrp), 0)
	local currentCamera = workspace.CurrentCamera
	local v7

	if currentCamera then
		v7 = currentCamera.ViewportSize.Y
	else
		v7 = v3
	end

	clone.Size = syncBillboardSize(v7)
	clone.Parent = state.hrp
	state.worldBB = clone
	state.worldIcon = clone:FindFirstChild("Icon")
	state.worldGlow = clone:FindFirstChild("Glow")
	state.worldArrow = clone:FindFirstChild("PointerArrow")
	state.edgeIcon.ImageContent = icon.ImageContent
	state.edgeGlow.ImageContent = glow.ImageContent
	state.edgeGlow.ImageColor3 = glow.ImageColor3
	state.edgeArrow.ImageContent = pointerArrow.ImageContent
end

local function hookBoss(model, HRP, bossType: string)
	local parent2 = ScreenGui()
	local clone = edgeIndicator:Clone()
	clone.Name = "BossEdgeUI"
	clone.Visible = false
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Parent = parent2
	local cluster = clone:WaitForChild("Cluster")
	local v6 = {
		model = model,
		hrp = HRP,
		bossType = bossType,
		edgeFrame = clone,
		edgeArrow = clone:WaitForChild("PointerArrow"),
		edgeCluster = cluster,
		edgeIcon = cluster:WaitForChild("Icon"),
		edgeGlow = cluster:WaitForChild("Glow")
	}
	applyType(v6, bossType)
	table.insert(v4, v6)
	v6.ancestryConn = model.AncestryChanged:Connect(function(_, parent)
		if not parent then
			removeTracked(model)
		end
	end)
	local humanoid = model:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return v6
	end

	if humanoid.Health <= 0 then
		destroyWorldBB(v6) -- equivalent call inferred; original call site unknown
	end

	v6.healthConn = humanoid.HealthChanged:Connect(function(p)
		if p <= 0 then
			destroyWorldBB(v6) -- equivalent call inferred; original call site unknown
		end
	end)
	v6.diedConn = humanoid.Died:Connect(function()
		task.defer(removeTracked, model)
	end)
	return v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAll(p)
	if p.worldBB then
		p.worldBB.Enabled = false
	end

	if p.edgeFrame then
		p.edgeFrame.Visible = false
	end
end

local function onRenderStepped()
	local DISTANCE_EPSILON = 0.001

	if #v4 == 0 then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
		currentCamera = workspace.CurrentCamera
	end

	local viewportSize = currentCamera.ViewportSize
	local vector = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.5)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local v5 = viewportSize.Y * 0.085
	local v6 = viewportSize.Y * 0.09
	syncBillboardSize(viewportSize.Y)
	local edgeArrow = v4[1].edgeArrow
	local v7 = math.min(edgeArrow.AbsoluteSize.X * 0.5, viewportSize.X * 0.5)
	local v8 = math.min(edgeArrow.AbsoluteSize.Y * 0.5, viewportSize.Y * 0.5)
	local v9 = viewportSize.X - v7
	local v10 = viewportSize.Y - v8
	local v11 = v9 - v7
	local v12 = v10 - v8
	local v13 = 2 * (v11 + v12)

	if v13 <= 0 then
		return
	end

	local models = {}
	local v14 = {}

	for _, v15 in ipairs(v4) do
		if v15.hrp and v15.hrp.Parent and v15.model and v15.model.Parent then
			local position = v15.hrp.Position
			local worldToViewportPoint, v16 = currentCamera:WorldToViewportPoint(position)
			local dist = not humanoidRootPart and 0 or (position - humanoidRootPart.Position).Magnitude

			if humanoidRootPart and dist > 5000 then
				table.insert(models, v15.model)
				hideAll(v15) -- equivalent call inferred; original call site unknown
			else
				local v18 = distanceTransparency(dist)
				local position2

				if humanoidRootPart then
					position2 = humanoidRootPart.Position or position
				else
					position2 = position
				end

				local vector2 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z)

				if vector2.Magnitude < DISTANCE_EPSILON then
					hideAll(v15) -- equivalent call inferred; original call site unknown
				else
					local cFrame = currentCamera.CFrame
					local lookVector = cFrame.LookVector
					local rightVector = cFrame.RightVector
					local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
					local vector4 = Vector3.new(rightVector.X, 0, rightVector.Z)

					if not (vector3.Magnitude < DISTANCE_EPSILON or vector4.Magnitude < DISTANCE_EPSILON) then
						local unit = vector3.Unit
						local dot = vector2:Dot(vector4.Unit)
						local dot2 = vector2:Dot(unit)
						local vector5 = Vector2.new(dot, -dot2)

						if vector5.Magnitude < DISTANCE_EPSILON then
							vector5 = Vector2.new(0, -1)
						end

						local unit2 = vector5.Unit
						local angle = math.deg((math.atan2(unit2.Y, unit2.X))) - 90

						if v16 then
							if worldToViewportPoint.Z > 0 and worldToViewportPoint.X >= 0 and worldToViewportPoint.X <= viewportSize.X and worldToViewportPoint.Y >= 0 then
								v16 = worldToViewportPoint.Y <= viewportSize.Y
							else
								v16 = false
							end
						end

						if v16 then
							if v15.worldBB then
								v15.worldBB.Enabled = true

								if v15.worldIcon then
									v15.worldIcon.ImageTransparency = v18
								end

								if v15.worldGlow then
									v15.worldGlow.ImageTransparency = v18
								end

								if v15.worldArrow then
									v15.worldArrow.ImageTransparency = v18
								end
							end

							v15.edgeFrame.Visible = false
						else
							if v15.worldBB then
								v15.worldBB.Enabled = false
							end

							v15.edgeFrame.Visible = true
							local X = unit2.X
							local Y = unit2.Y
							local v20 = X == 0 and 1e999 or viewportSize.X * 0.5 / math.abs(X) or 1e999
							local v21 = Y == 0 and 1e999 or viewportSize.Y * 0.5 / math.abs(Y) or 1e999
							local v22

							if v20 <= v21 then
								v22 = X < 0 and "left" or "right"
							else
								v22 = Y < 0 and "top" or "bottom"
							end

							local v23, v24

							if v22 == "left" then
								v23 = math.clamp(vector.Y + Y * v20, v8, v10)
								v24 = v7
							elseif v22 == "right" then
								v23 = math.clamp(vector.Y + Y * v20, v8, v10)
								v24 = v9
							elseif v22 == "top" then
								v24 = math.clamp(vector.X + X * v21, v7, v9)
								v23 = v8
							else
								v24 = math.clamp(vector.X + X * v21, v7, v9)
								v23 = v10
							end

							local v25

							if v22 == "bottom" then
								v25 = v24 - v7
							elseif v22 == "right" then
								v25 = v11 + (v10 - v23)
							elseif v22 == "top" then
								v25 = v11 + v12 + (v9 - v24)
							else
								v25 = v11 + v12 + v11 + (v23 - v8)
							end

							table.insert(v14, {
								t = v15,
								s = v25,
								dir2 = unit2,
								dist = dist,
								angle = angle,
								alpha = v18,
								sAdj = nil
							})
						end
					end
				end
			end
		else
			if v15.model then
				table.insert(models, v15.model)
			end

			hideAll(v15) -- equivalent call inferred; original call site unknown
		end
	end

	for _, v15 in ipairs(models) do
		removeTracked(v15)
	end

	if not (#v4 ~= 0 and #v14 ~= 0) then
		return
	end

	table.sort(v14, function(a, b)
		return a.s < b.s
	end)
	local count = #v14

	if count > 1 then
		local v15 = -1e999
		local v16 = 1

		for i = 1, count - 1 do
			local v17 = v14[i + 1].s - v14[i].s

			if not (v15 < v17) then
				continue
			end

			v16 = i
			v15 = v17
		end

		if v15 < v14[1].s + v13 - v14[count].s then
			v16 = count
		end

		local v17 = v16 % count + 1
		local s = v14[v17].s
		local v18 = {}

		for i = 0, count - 1 do
			local v19 = v14[(v17 - 1 + i) % count + 1]
			local sAdj = v19.s - s

			if sAdj < 0 then
				sAdj += v13
			end

			v19.sAdj = sAdj
			table.insert(v18, v19)
		end

		for i = 2, count do
			local v19 = v18[i - 1]
			local v20 = v18[i]

			if v20.sAdj and v19.sAdj and v20.sAdj - v19.sAdj < v6 then
				v20.sAdj = v19.sAdj + v6
			end
		end

		v14 = v18

		for _, v19 in ipairs(v18) do
			v19.s = ((v19.sAdj or 0) + s) % v13
		end
	end

	for _, v15 in ipairs(v14) do
		local t = v15.t
		local v16 = v15.s % v13
		local v17, v18

		if v16 < v11 then
			v17 = v7 + v16
			v18 = v10
		elseif v16 < v11 + v12 then
			v18 = v10 - (v16 - v11)
			v17 = v9
		elseif v16 < v11 + v12 + v11 then
			v17 = v9 - (v16 - (v11 + v12))
			v18 = v8
		else
			v18 = v8 + (v16 - (v11 + v12 + v11))
			v17 = v7
		end

		t.edgeFrame.Position = UDim2.fromOffset(v17, v18)
		t.edgeArrow.Rotation = v15.angle
		t.edgeArrow.ImageTransparency = v15.alpha
		local v19 = math.atan2(v15.dir2.Y, v15.dir2.X) + 3.141592653589793
		local v20 = math.cos(v19) * v5
		local v21 = math.sin(v19) * v5
		t.edgeCluster.Position = UDim2.new(0.5, v20, 0.5, v21)
		t.edgeIcon.ImageTransparency = v15.alpha
		t.edgeGlow.ImageTransparency = v15.alpha
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RenderLoop()
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(onRenderStepped)
	end
end

local function BossEdgeEffect(part, _)
	RenderLoop() -- equivalent call inferred; original call site unknown
	ScreenGui()
	local HRP = nil
	local bossType = nil

	if typeof(part) == "table" then
		HRP = part.HRP or part.hrp or part[1]
		bossType = part.BossType or part.Type or part[4]
	elseif typeof(part) == "Instance" and part:IsA("BasePart") then
		HRP = part
	end

	if not (HRP and HRP.Parent) then
		return
	end

	local model = HRP:FindFirstAncestorOfClass("Model")

	if not model then
		return
	end

	if typeof(part) == "table" and part.Remove == true then
		removeTracked(model)
		return
	end

	if typeof(bossType) ~= "string" or bossType == "" or not bossType then
		bossType = nil
	end

	if bossType then
		if not templates:FindFirstChild(bossType) then
			bossType = v[string.lower(bossType)]

			if not (bossType and templates:FindFirstChild(bossType)) then
				bossType = nil
			end
		end
	else
		bossType = nil
	end

	if not bossType then
		local bossIndicatorType = model:GetAttribute("BossIndicatorType")

		if typeof(bossIndicatorType) ~= "string" or bossIndicatorType == "" or not bossIndicatorType then
			bossIndicatorType = nil
		end

		if bossIndicatorType then
			if not templates:FindFirstChild(bossIndicatorType) then
				bossIndicatorType = v[string.lower(bossIndicatorType)]

				if not (bossIndicatorType and templates:FindFirstChild(bossIndicatorType)) then
					bossIndicatorType = nil
				end
			end
		else
			bossIndicatorType = nil
		end

		bossType = bossIndicatorType or model:GetAttribute("RaidBoss") and "RaidBoss" or "Boss"
	end

	for _, v5 in ipairs(v4) do
		if v5.hrp ~= HRP then
			continue
		end

		if v5.bossType ~= bossType then
			applyType(v5, bossType)
		end

		return
	end

	hookBoss(model, HRP, bossType)
end

return BossEdgeEffect