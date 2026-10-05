local createVector = vector.create
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v = {
	0,
	3.141592653589793,
	0.7853981633974483,
	-0.7853981633974483,
	3.9269908169872414,
	2.356194490192345
}

-- equivalent calls inferred from this helper; original call sites unknown
local function flat(vector2: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z))
end

local function visibleBounds(folder)
	if folder == nil or folder.Parent == nil then
		return nil, nil
	end

	local v2 = nil
	local v3 = nil

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part.Transparency >= 1 then
			continue
		end

		local cFrame = part.CFrame
		local halfSize = part.Size / 2
		local v5 = cFrame.XVector:Abs() * halfSize.X + cFrame.YVector:Abs() * halfSize.Y + cFrame.ZVector:Abs() * halfSize.Z
		local v6 = cFrame.Position - v5
		local v7 = cFrame.Position + v5

		if v2 then
			v2 = v2:Min(v6)
		else
			v2 = v6
		end

		if v3 then
			v3 = v3:Max(v7)
		else
			v3 = v7
		end
	end

	return v2, v3
end

local function subjectCorners(items, vectors)
	table.clear(vectors)
	local v2 = nil
	local v3 = nil

	for _, item in items do
		local v4, v5 = visibleBounds(item.Model)

		if v4 == nil or v5 == nil then
			v4 = item.Fallback - createVector(1.5, 0, 1.5)
			v5 = v4 + createVector(3, 5, 3)
		end

		for _, v6 in { v4.X, v5.X } do
			for _, v7 in { v4.Y, v5.Y } do
				for _, v8 in { v4.Z, v5.Z } do
					table.insert(vectors, (Vector3.new(v6, v7, v8)))
				end
			end
		end

		if v2 then
			v2 = v2:Min(v4)
		else
			v2 = v4
		end

		if v3 then
			v3 = v3:Max(v5)
		else
			v3 = v5
		end
	end

	return (v2 + v3) / 2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function frameBasis(vector2: Vector3, vector3: Vector3)
	local v2 = vector3 * 0.9781476007338057 + createVector(0, 0.20791169, 0)
	return CFrame.lookAt(vector2 + v2, vector2)
end

local function fitDistance(items, vector2: Vector3, cframe: CFrame, p: number, p2: number)
	local v2 = math.tan(math.rad(p) / 2)
	local v3 = v2 * p2
	local v4 = 6

	for _, item in items do
		local vector3 = item - vector2
		local v5 = -vector3:Dot(cframe.LookVector)
		v4 = math.max(
			v4,
			math.abs((vector3:Dot(cframe.RightVector))) / (v3 * 0.8) + v5,
			math.abs((vector3:Dot(cframe.UpVector))) / (v2 * 0.42) + v5
		)
	end

	return v4 * 1.12
end

local function freeDistance(vector2: Vector3, vector3: Vector3, p: number, filterDescendantsInstances)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances

	for _ = 1, 8 do
		local raycastResult = Workspace:Raycast(vector2, vector3 * p, raycastParams)

		if raycastResult == nil then
			return p
		end

		local instance = raycastResult.Instance

		if instance:IsA("BasePart") and instance.Transparency >= 0.9 then
			raycastParams:AddToFilter(instance)
		else
			return raycastResult.Distance
		end
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function yawed(vector2: Vector3, p: number)
	return CFrame.fromAxisAngle(createVector(0, 1, 0), p):VectorToWorldSpace(vector2)
end

local function setBars(gui, flag: boolean)
	local barTop = gui:FindFirstChild("BarTop")
	local barBottom = gui:FindFirstChild("BarBottom")

	if barTop == nil or barBottom == nil then
		return
	end

	barTop.Visible = true
	barBottom.Visible = true
	local v2

	if flag then
		v2 = tweenInfo
	else
		v2 = tweenInfo2
	end

	TweenService:Create(barTop, v2, {
		Position = UDim2.fromScale(0, flag and 0 or -0.13)
	}):Play()
	TweenService:Create(barBottom, v2, {
		Position = UDim2.fromScale(0, flag and 0.87 or 1)
	}):Play()
end

local function freezeCharacter(character)
	local v2 = {}
	local animator = character and character:FindFirstChildWhichIsA("Animator", true)

	if animator then
		for _, v3 in animator:GetPlayingAnimationTracks() do
			v3:AdjustSpeed(0)
			table.insert(v2, v3)
		end
	end

	return function()
		for _, v3 in v2 do
			v3:AdjustSpeed(1)
		end
	end
end

local function attachTrail(scrambleHuman, maid)
	local primaryPart = scrambleHuman and scrambleHuman.PrimaryPart

	if scrambleHuman == nil or primaryPart == nil then
		return
	end

	local _, v2 = scrambleHuman:GetBoundingBox()

	for _, v3 in Vfx.Trail(primaryPart, v2.X) do
		maid:Add(v3)
	end
end

local function hideBystanders(playerByUserId, maid)
	local localTransparencyModifiersByDescendant = {}
	local enabledsByDescendant = {}
	local displayDistanceTypesByDescendant = {}
	local flag = false

	local function hide()
		for _, v2 in Players:GetPlayers() do
			local character = v2.Character

			if not (v2 ~= playerByUserId and character ~= nil) then
				continue
			end

			for _, descendant in character:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Decal") then
					if localTransparencyModifiersByDescendant[descendant] == nil then
						localTransparencyModifiersByDescendant[descendant] = descendant.LocalTransparencyModifier
					end

					descendant.LocalTransparencyModifier = 1
				elseif descendant:IsA("BillboardGui") and enabledsByDescendant[descendant] == nil then
					enabledsByDescendant[descendant] = descendant.Enabled
					descendant.Enabled = false
				elseif descendant:IsA("Humanoid") and displayDistanceTypesByDescendant[descendant] == nil then
					displayDistanceTypesByDescendant[descendant] = descendant.DisplayDistanceType
					descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
				end
			end
		end
	end

	local function restore()
		if flag then
			return
		end

		flag = true
		RunService:UnbindFromRenderStep("ScrambleFinalHitHide")

		for k, localTransparencyModifier in localTransparencyModifiersByDescendant do
			k.LocalTransparencyModifier = localTransparencyModifier
		end

		for k, enabled in enabledsByDescendant do
			k.Enabled = enabled
		end

		for k, displayDistanceType in displayDistanceTypesByDescendant do
			k.DisplayDistanceType = displayDistanceType
		end
	end

	hide()
	RunService:BindToRenderStep("ScrambleFinalHitHide", Enum.RenderPriority.Camera.Value + 1, hide)
	maid:Add(restore)
	task.delay(7.2, restore)
end

return {
	FinalHit = function(object, instance, object2, data)
		local currentCamera = Workspace.CurrentCamera

		if currentCamera == nil then
			return
		end

		local playerByUserId = Players:GetPlayerByUserId(data.UserId or 0)
		local at = data.At or createVector(0, 0, 0)
		local from = data.From or at
		local v3 = flat(at - from) -- equivalent call inferred; original call site unknown
		local unit = (v3.Magnitude < 0.1 and createVector(0, 0, 1) or v3).Unit
		local cross = unit:Cross(createVector(0, 1, 0))
		local cameraType = currentCamera.CameraType
		local fieldOfView = currentCamera.FieldOfView
		local cameraSubject = currentCamera.CameraSubject
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "ScrambleFinalHit"
		colorCorrectionEffect.Parent = Lighting
		local blurEffect = Instance.new("BlurEffect")
		blurEffect.Name = "ScrambleFinalHitBlur"
		blurEffect.Size = 0
		blurEffect.Parent = Lighting
		local maid = object:Extend()
		local v4 = HiddenUIHandler.Acquire()
		maid:Add(colorCorrectionEffect)
		maid:Add(blurEffect)
		maid:Add(v4)
		maid:Add(function()
			currentCamera.CameraType = cameraType
			currentCamera.FieldOfView = fieldOfView

			if cameraSubject and cameraSubject.Parent then
				currentCamera.CameraSubject = cameraSubject
			end

			setBars(object2.Gui, false)
		end)
		local scrambleHuman = instance:FindFirstChild("ScrambleHuman")
		hideBystanders(playerByUserId, maid)
		local v5 = freezeCharacter(playerByUserId and playerByUserId.Character)
		maid:Add(v5)
		currentCamera.CameraType = Enum.CameraType.Scriptable
		setBars(object2.Gui, true)
		object2:FlashScreen(Color3.new(1, 1, 1), 0.3, 1)
		Kit.Sound("FinalHit", nil, 1.5)
		Kit.Sound("Boom", nil, 1.2, 0.8)
		colorCorrectionEffect.Saturation = -1
		colorCorrectionEffect.Contrast = 0.9
		blurEffect.Size = 6
		task.delay(0.14, function()
			colorCorrectionEffect.Saturation = 0.35
			colorCorrectionEffect.Contrast = 0.25
			blurEffect.Size = 0
		end)
		Vfx.Burst("SpiderSlashes", Vfx.Frame("SpiderSlashes", at, unit), 0.8, 0.3)
		object2:Say(
			not playerByUserId and "FINAL HIT!" or `{string.upper(playerByUserId.DisplayName)}!`,
			"FINAL HIT",
			2.4
		)
		local v6 = {
			{
				Model = playerByUserId and playerByUserId.Character,
				Fallback = from - createVector(0, 3, 0)
			},
			{
				Model = scrambleHuman,
				Fallback = at
			}
		}
		local filterDescendantsInstances = {}

		for _, v8 in Players:GetPlayers() do
			if v8.Character then
				table.insert(filterDescendantsInstances, v8.Character)
			end
		end

		if scrambleHuman then
			table.insert(filterDescendantsInstances, scrambleHuman)
		end

		local v8 = {}
		local v9 = subjectCorners(v6, v8)
		local v10 = currentCamera.ViewportSize.X / math.max(currentCamera.ViewportSize.Y, 1)
		local vector2 = flat(v6[2].Fallback - v6[1].Fallback) -- equivalent call inferred; original call site unknown

		if scrambleHuman and playerByUserId and playerByUserId.Character then
			local v12, v13 = visibleBounds(scrambleHuman)
			local v14, v15 = visibleBounds(playerByUserId.Character)

			if v12 and v13 and v14 and v15 then
				local v16 = (v12 + v13) / 2 - (v14 + v15) / 2
				vector2 = Vector3.new(v16.X, 0, v16.Z)
			end
		end

		local v12

		if vector2.Magnitude > 0.1 then
			v12 = vector2.Unit:Cross(createVector(0, 1, 0))
		else
			v12 = cross
		end

		local v13 = v12
		local v14 = -1
		local total = 38

		for _, v16 in v do
			local v17 = yawed(v12, v16) -- equivalent call inferred; original call site unknown
			local v18 = frameBasis(v9, v17) -- equivalent call inferred; original call site unknown
			local v19 = fitDistance(v8, v9, v18, 38, v10)
			local v20 = freeDistance(v9, -v18.LookVector, v19 + 2, filterDescendantsInstances)

			if v19 + 0.75 <= v20 then
				v14 = v20
				v13 = v17
				break
			elseif v14 < v20 then
				v13 = v17
				v14 = v20
			end
		end

		while total < 80 do
			local v16 = frameBasis(v9, v13) -- equivalent call inferred; original call site unknown

			if fitDistance(v8, v9, v16, total, v10) + 0.75 <= v14 then
				break
			else
				total += 4
			end
		end

		local v16 = math.max(52, total)
		local lastTime = os.clock()

		while os.clock() - lastTime < 2.6 do
			local v17 = 1 - (1 - (os.clock() - lastTime) / 2.6) ^ 3
			v9 = v9:Lerp(subjectCorners(v6, v8), 0.25)
			local fieldOfView2 = v16 + (total - v16) * v17
			local v19 = 0.2792526803190927 * (0.5 - v17)
			local v20 = frameBasis(v9, CFrame.fromAxisAngle(createVector(0, 1, 0), v19):VectorToWorldSpace(v13)) -- equivalent call inferred; original call site unknown
			local v21 = -v20.LookVector
			local v22 = fitDistance(v8, v9, v20, fieldOfView2, v10)
			local v23 = math.max(math.min(v22, freeDistance(v9, v21, v22 + 1, filterDescendantsInstances) - 0.75), 1)
			local v24 = math.tan(math.rad(fieldOfView2) / 2)
			local v25 = v9 + v21 * v23
			local v26 = v9 - v20.UpVector * (v24 * 0.3 * v23)
			currentCamera.CFrame = CFrame.lookAt(v25, v26) * CFrame.Angles(0, 0, (math.rad(-4 - v17 * 5)))
			currentCamera.FieldOfView = fieldOfView2
			RunService.RenderStepped:Wait()
		end

		v5()
		colorCorrectionEffect.Saturation = 0.2
		colorCorrectionEffect.Contrast = 0.1
		object2:FlashScreen(Color3.new(1, 1, 1), 0.25, 0.6)
		Kit.Shake(10, 18, 1.4)
		Vfx.Burst("Slam", CFrame.new(Vfx.Ground(at, instance:GetAttribute("FloorY"))), 0.6)
		Vfx.Burst("SpiderSlashes", Vfx.Frame("SpiderSlashes", at, unit), 0.8, 0.4)
		attachTrail(scrambleHuman, maid)
		object2:Say("BYE BYE SCRAMBLE!", nil, 2.5)
		local lastTime2 = os.clock()
		local cFrame = currentCamera.CFrame

		while os.clock() - lastTime2 < 1.6 do
			local v17 = (os.clock() - lastTime2) / 1.6
			local position

			if scrambleHuman and scrambleHuman.PrimaryPart then
				position = scrambleHuman.PrimaryPart.Position
			else
				position = at
			end

			local v18 = position - unit * (40 + v17 * 30) + Vector3.new(0, 12 + v17 * 16, 0) + cross * 16
			cFrame = cFrame:Lerp(CFrame.lookAt(v18, position), 0.18)
			currentCamera.CFrame = cFrame
			currentCamera.FieldOfView = math.min(currentCamera.FieldOfView + 1.2, 62)
			RunService.RenderStepped:Wait()
		end

		TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
			Saturation = 0,
			Contrast = 0
		}):Play()
		maid:Destroy()
	end
}