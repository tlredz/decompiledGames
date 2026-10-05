local createVector = vector.create
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Effect = require(game.ReplicatedStorage.Effect)
local Util = require(game.ReplicatedStorage.Util)
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = Players.LocalPlayer
local v = {
	"PirateVillageSFX.PirateVillBonus_Rope_Cut_01",
	"PirateVillageSFX.PirateVillBonus_Rope_Cut_02",
	"PirateVillageSFX.PirateVillBonus_Rope_Cut_03"
}
local v2 = {
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Small_01",
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Small_02",
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Small_03"
}
local v3 = {
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Medium_01",
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Medium_02",
	"PirateVillageSFX.PirateVillBonus_Windmill_Creak_Medium_03"
}
local color = Color3.new(1, 0.96, 0.88)
local v4 = {}
local parts = {}
local transparenciesByPart = {}
local parts2 = {}
local cFramesByPart = {}
local jointInstances = {}
local cFrame = nil
local v5 = nil
local v6 = 0
local total = 0
local v7 = 0
local flag = false
local flag2 = false
local v8 = 0
local v9 = nil
local renderSteppedConnection = nil
local destroyingConnection = nil
local thread = nil
local v10 = nil
local v11 = nil
local count = 0
local v12 = nil
local heartbeatConnection = nil
local total2 = 0
local v13 = 0
local v14 = false
local v15 = false
local v16 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function ropeGroupKey(name: string)
	local v17 = name:gsub("%.%d+$", "")
	return v17:match("^(.+%d)[AB]$") or v17
end

local function findRig()
	local map = workspace:FindFirstChild("Map")
	local pirate

	if map then
		pirate = map:FindFirstChild("Pirate")
	end

	if not pirate then
		return nil
	end

	local windmillRig = pirate:FindFirstChild("WindmillRig", true)

	if windmillRig then
		return windmillRig:FindFirstChild("Windmill_rig", true) or windmillRig
	end

	return nil
end

local function applyBladeTransform()
	local cframe = cFrame

	if not cframe then
		return
	end

	local v17 = cframe * CFrame.Angles(0, 0, v6) * cframe:Inverse()

	for _, v18 in parts2 do
		local v19 = cFramesByPart[v18]

		if v19 and v18.Parent then
			v18.CFrame = v17 * v19
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRandom(list, p)
	if p == nil then
		return
	end

	pcall(function()
		Sound:Play(list[math.random(#list)], p)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopFreeSpinSound()
	local v17 = v9
	v9 = nil

	if v17 == nil then
		return
	end

	pcall(function()
		Sound:FadeOut(v17, 1)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startFreeSpinSound()
	local v17 = v5

	if v9 ~= nil or v17 == nil then
		return
	end

	pcall(function()
		local v18 = Sound:Play("PirateVillageSFX.PirateVillBonus_Windmill_Freely_Rotating_01", v17, {
			fadeIn = 1
		})
		v18.Looped = true
		v9 = v18
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scheduleBudge()
	v8 = os.clock() + 3 + math.random() * 3.5
end

local function stepBlades(p: number)
	local v17 = p > 0.03333333333333333 and 0.03333333333333333 or p

	if flag then
		total += (1.6 - total) * math.min(v17 * 1, 1)
		v6 = (v6 + total * v17) % 6.283185307179586
		applyBladeTransform()
	else
		if v8 > 0 then
			local now = os.clock()

			if v8 <= now then
				scheduleBudge() -- equivalent call inferred; original call site unknown
				total += 0.3 + math.random() * 0.3
				playRandom(v2, v5) -- equivalent call inferred; original call site unknown
			end
		end

		local v18 = v6 - v7

		if math.abs(v18) < 0.0001 and math.abs(total) < 0.0001 then
			if v18 ~= 0 or total ~= 0 then
				v6 = v7
				total = 0
				applyBladeTransform()
			end
		else
			local v19 = v18 * -28 - total * 4.5
			total += v19 * v17
			v6 += total * v17
			applyBladeTransform()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopLoop()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLoop()
	if not renderSteppedConnection then
		renderSteppedConnection = RunService.RenderStepped:Connect(stepBlades)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideParts(items)
	for _, item in items do
		if item.Parent then
			item.Transparency = 1
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideGroup(p: string)
	local v17 = v4[p]

	if v17 then
		hideParts(v17) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideAllRigging()
	for k in v4 do
		hideGroup(k) -- equivalent call inferred; original call site unknown
	end

	hideParts(parts) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function revealAllRigging()
	for k, transparency in transparenciesByPart do
		if k.Parent then
			k.Transparency = transparency
		end
	end
end

local function groupMidpoint(items)
	local v17 = createVector(0, 0, 0)
	local count2 = 0

	for _, item in items do
		if not item.Parent then
			continue
		end

		v17 += item.Position
		count2 += 1
	end

	if count2 > 0 then
		return v17 / count2
	end

	return nil
end

local function sliceFlash(vector2: Vector3, p: number)
	local currentCamera = workspace.CurrentCamera
	local position

	if currentCamera then
		position = currentCamera.CFrame.Position
	else
		position = vector2 + createVector(0, 0, 1)
	end

	if (position - vector2).Magnitude < 0.001 then
		position = vector2 + createVector(0, 0, 1)
	end

	local v17 = CFrame.lookAt(vector2, position) * CFrame.Angles(-1.5707963267948966, 0, 0)
	pcall(function()
		Effect.new("SpriteSlice"):play({
			CFrame = v17 * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0),
			VertexColor = createVector(2.2, 2.09, 1.8700001),
			Scale = createVector(1, 1, 1) * p,
			GrowScale = 0.5,
			Step = 1,
			Start = 1,
			RotSpeed = 1.5707963267948966,
			Transparency = { 0.1, 0.35 }
		})
	end)
end

local function sliceBurst(vector2: Vector3, p: number, p2: number)
	for i = 1, p do
		local v17 = p2 * (0.75 + math.random() * 0.5)

		if i == 1 then
			sliceFlash(vector2, v17)
		else
			local v18 = Vector3.new(
				(math.random() - 0.5) * 3.5,
				(math.random() - 0.5) * 3.5,
				(math.random() - 0.5) * 3.5
			)
			local v19 = v17
			task.delay((i - 1) * 0.045, function()
				sliceFlash(vector2 + v18, v19)
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shakeCamera(vector2: Vector3, p: number, p2: number)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local magnitude = (currentCamera.CFrame.Position - vector2).Magnitude

	if magnitude > 140 then
		return
	end

	local v17 = 1 - magnitude / 140
	pcall(function()
		Util.CameraShaker:ShakeOnce(p * v17, 8, 0, p2)
	end)
end

local function slashFlash(position: Vector3, p: number)
	local cFrame2 = CFrame.new(position) * CFrame.Angles(0, math.random() * 3.141592653589793 * 2, 0)
	pcall(function()
		Effect.new("SwordSlash"):play({
			CFrame = cFrame2,
			EndCFrame = cFrame2 * CFrame.Angles(0, 1.8849555921538759, 0),
			Size = createVector(1, 1, 1) * p,
			Color = color,
			Transparency = 0.35,
			Duration = 0.18
		})
	end)
end

local function severRope(items, vector2: Vector3)
	local folder = Instance.new("Folder")
	folder.Name = "WindmillRopeSever"
	folder.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local flag3 = false

	for _, item in items do
		if not item.Parent then
			continue
		end

		local clone = item:Clone()

		for _, descendant in clone:GetDescendants() do
			if descendant:IsA("JointInstance") or descendant:IsA("Constraint") then
				descendant:Destroy()
			end
		end

		clone.Transparency = transparenciesByPart[item] or 0
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanQuery = false
		clone.CanTouch = false
		clone.Parent = folder
		flag3 = true
		local vector3 = clone.Position - vector2

		if vector3.Magnitude <= 0.1 then
			vector3 = Vector3.new(math.random() - 0.5, -0.5, math.random() - 0.5)
		end

		local v17 = vector3.Unit * 5 - createVector(0, 3, 0)
		local cframe = CFrame.Angles(
			(math.random() - 0.5) * 1.0995574287564276,
			(math.random() - 0.5) * 1.0995574287564276,
			(math.random() - 0.5) * 1.0995574287564276
		)
		TweenService:Create(clone, tweenInfo, {
			CFrame = (clone.CFrame + v17) * cframe,
			Size = clone.Size * 0.45,
			Transparency = 1
		}):Play()
	end

	if flag3 then
		Debris:AddItem(folder, 0.55)
	else
		folder:Destroy()
	end
end

local function playCutEffect(items, vector2: Vector3?, flag3: boolean)
	if not vector2 then
		local v17 = createVector(0, 0, 0)
		local count2 = 0

		for _, item in items do
			if not item.Parent then
				continue
			end

			v17 += item.Position
			count2 += 1
		end

		if count2 > 0 then
			vector2 = v17 / count2
		else
			vector2 = nil
		end
	end

	if not vector2 then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera and (currentCamera.CFrame.Position - vector2).Magnitude > 400 then
		return
	end

	playRandom(v, vector2) -- equivalent call inferred; original call site unknown
	sliceBurst(vector2, flag3 and 5 or 2, 0.8)
	local v18 = (flag3 and 1.35 or 1) * 45
	slashFlash(vector2, v18)

	if flag3 then
		task.delay(0.09, function()
			slashFlash(vector2, v18)
		end)
		task.delay(0.18, function()
			slashFlash(vector2, v18)
		end)
	end

	shakeCamera(vector2, flag3 and 5 or 1.4, flag3 and 1.1 or 0.5) -- equivalent call inferred; original call site unknown
	severRope(items, vector2)

	if flag3 and #parts > 0 then
		severRope(parts, vector2)
	end
end

local function enterFreeSpin()
	flag = true
	v8 = 0
	hideAllRigging() -- equivalent call inferred; original call site unknown
	startLoop() -- equivalent call inferred; original call site unknown
	local v17 = v5

	if v9 == nil then
		if v17 == nil then
			return
		else
			pcall(function()
				local v18 = Sound:Play("PirateVillageSFX.PirateVillBonus_Windmill_Freely_Rotating_01", v17, {
					fadeIn = 1
				})
				v18.Looped = true
				v9 = v18
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function enterTangle()
	stopFreeSpinSound() -- equivalent call inferred; original call site unknown
	flag = false
	v7 = v6
	scheduleBudge() -- equivalent call inferred; original call site unknown
	revealAllRigging() -- equivalent call inferred; original call site unknown
	startLoop() -- equivalent call inferred; original call site unknown
end

local function collectRig()
	local rig = findRig()

	if not rig then
		return nil
	end

	table.clear(v4)
	table.clear(parts)
	table.clear(transparenciesByPart)
	table.clear(parts2)
	table.clear(cFramesByPart)
	table.clear(jointInstances)
	cFrame = nil
	v5 = nil
	local v17 = nil

	for _, part in rig:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		if part.Name == "Ropes" then
			table.insert(parts, part)
			transparenciesByPart[part] = part.Transparency
		elseif part.Name:find("Rope") then
			local v18 = ropeGroupKey(part.Name) -- equivalent call inferred; original call site unknown
			local parts3 = v4[v18]

			if not parts3 then
				parts3 = {}
				v4[v18] = parts3
			end

			table.insert(parts3, part)
			transparenciesByPart[part] = part.Transparency
		elseif part.Name:find("Windmill Blades") then
			table.insert(parts2, part)
			cFramesByPart[part] = part.CFrame

			if part.Name == "Windmill Blades" then
				v17 = part
			end

			for _, jointInstance in part:GetChildren() do
				if not jointInstance:IsA("JointInstance") then
					continue
				end

				jointInstance.Enabled = false
				table.insert(jointInstances, jointInstance)
			end
		end
	end

	if not v17 then
		return nil
	end

	cFrame = v17.CFrame
	v5 = v17
	return rig
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseCamera()
	local v17 = v10

	if not v17 then
		return
	end

	v10 = nil
	pcall(function()
		v17:FadeOut(0.8)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bladeFacing()
	local v17 = v5

	if not (v17 and v17.Parent) then
		return nil
	end

	local lookVector = v17.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude < 0.001 then
		return nil
	end

	return vector2.Unit
end

-- equivalent calls inferred from this helper; original call sites unknown
local function windmillRevealCFrame()
	local v17 = v5
	local v18 = bladeFacing() -- equivalent call inferred; original call site unknown

	if v17 and v18 then
		local position = v17.CFrame.Position
		local v19 = position + v18 * (math.max(v17.Size.X, v17.Size.Y) * 1.45) + createVector(0, 6, 0)
		return CFrame.lookAt(v19, position - createVector(0, 18, 0))
	else
		return nil
	end
end

local function playCompletionCutscene()
	if v10 then
		return
	end

	local v17 = v5
	local v18 = windmillRevealCFrame() -- equivalent call inferred; original call site unknown

	if not (v17 and v18) then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (humanoidRootPart.Position - v17.Position).Magnitude > 400 then
		return
	end

	local success, result = pcall(function()
		local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
		return CameraController.new()
	end)

	if not (success and result) then
		return
	end

	v10 = result
	result:TeleportTo(v18)
	pcall(function()
		result.Animations:PivotAroundY(v17.Position, 12, 1.4, 0.2)
	end)
	task.delay(4.25, function()
		if v10 == result then
			releaseCamera() -- equivalent call inferred; original call site unknown
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function introShotCFrame(vector2: Vector3, p: number, p2: number)
	local v17 = bladeFacing() -- equivalent call inferred; original call site unknown

	if v17 then
		return CFrame.lookAt(vector2 + v17 * p + Vector3.new(0, p2, 0), vector2)
	end

	return nil
end

local function lowestRopeFocusPoint()
	local v17 = 1e999
	local v18 = nil

	for k, v19 in v4 do
		for _, v20 in v19 do
			if not v20.Parent then
				continue
			end

			local v21 = v20.Position.Y - v20.Size.Y / 2

			if not (v21 < v17) then
				continue
			end

			v18 = k
			v17 = v21
		end
	end

	if not v18 then
		return nil
	end

	local v19 = createVector(0, 0, 0)
	local count2 = 0

	for _, v20 in v4[v18] do
		if not v20.Parent then
			continue
		end

		v19 += v20.Position
		count2 += 1
	end

	if count2 > 0 then
		return v19 / count2
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseIntroCamera()
	local v17 = v12

	if not v17 then
		return
	end

	v12 = nil
	v17.cancelled = true
	local controller = v17.controller

	if not controller then
		return
	end

	if v10 == controller then
		v10 = nil
	end

	pcall(function()
		controller:FadeOut(0.6)
	end)
end

local function moveIntroCamera(vector2: Vector3?, p: number, p2: number)
	local v17 = v12

	if not vector2 or not v17 or v17.cancelled or not v17.controller then
		return
	end

	local v18 = introShotCFrame(vector2, p, p2) -- equivalent call inferred; original call site unknown

	if not v18 then
		return
	end

	pcall(function()
		v17.controller.Animations:AnimateTo(v18, 1, 0.9)
		v17.controller.Animations:PivotAroundY(vector2, 9, 1, 0.3)
	end)
end

local function distanceToRigging()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) then
		return nil
	end

	local position = humanoidRootPart.Position
	local v17 = 1e999

	local function measure(instance)
		if not instance.Parent then
			return
		end

		local pointToObjectSpace = instance.CFrame:PointToObjectSpace(position)
		local halfSize = instance.Size / 2
		local magnitude = (pointToObjectSpace - Vector3.new(
			math.clamp(pointToObjectSpace.X, -halfSize.X, halfSize.X),
			math.clamp(pointToObjectSpace.Y, -halfSize.Y, halfSize.Y),
			(math.clamp(pointToObjectSpace.Z, -halfSize.Z, halfSize.Z))
		)).Magnitude

		if magnitude < v17 then
			v17 = magnitude
		end
	end

	for _, v18 in v4 do
		for _, v19 in v18 do
			measure(v19)
		end
	end

	for _, v18 in parts do
		measure(v18)
	end

	local v18

	if v17 < 1e999 then
		return v17
	end

	return v18
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disarmIntro()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	total2 = 0
end

local function cancelIntro()
	disarmIntro() -- equivalent call inferred; original call site unknown
	releaseIntroCamera() -- equivalent call inferred; original call site unknown

	if not v15 then
		return
	end

	v15 = false
	v16 = true
	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	pcall(function()
		DialogueController.close()
	end)
end

local function playIntroCutscene()
	local v17 = windmillRevealCFrame() -- equivalent call inferred; original call site unknown

	if v17 then
		local DialogueController = require(game.ReplicatedStorage.DialogueController)
		local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
		local v18 = {
			controller = nil,
			cancelled = false
		}
		v12 = v18
		v16 = false
		local v19 = DialogueController.new()
		v19:setTitle("")
		v19:addPage(function(object)
			if not (v18.controller or v18.cancelled) then
				local success, result = pcall(function()
					return CameraController.new()
				end)

				if success and result then
					v18.controller = result
					v10 = result
					v19:getMaid():GiveTask(function()
						if v12 == v18 then
							releaseIntroCamera() -- equivalent call inferred; original call site unknown
						end
					end)
					result.Animations:AnimateTo(v17, 1, 1.2)
					task.delay(1.5, function()
						moveIntroCamera(lowestRopeFocusPoint(), 42, 4)
					end)
				end
			end

			object:setTitle("")
			object:noCancel()
			object:addText("Hm.. I could probably cut these ropes!")
			object:advanceAfterDelay(3.6)
		end)
		v19:build()
		local v20 = DialogueController.start(v19)
		v15 = false

		if v20 == nil or v16 then
			local v21 = v12 == v18 and v12

			if v21 then
				v12 = nil
				v21.cancelled = true
				local controller = v21.controller

				if controller then
					if v10 == controller then
						v10 = nil
					end

					pcall(function()
						controller:FadeOut(0.6)
					end)
				end
			end

			v13 = os.clock() + 5
		else
			v14 = true
			disarmIntro() -- equivalent call inferred; original call site unknown
		end
	else
		v15 = false
		v13 = os.clock() + 5
	end
end

local function armIntro()
	if v14 or heartbeatConnection or flag or not v11 or v11.Completed then
		return
	end

	local DialogueController = require(game.ReplicatedStorage.DialogueController)
	total2 = 0
	heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
		total2 += dt

		if total2 < 0.2 then
			return
		end

		total2 = 0

		if v14 or flag or not v11 or v11.Completed then
			disarmIntro() -- equivalent call inferred; original call site unknown
		else
			if v15 or not flag2 or os.clock() < v13 or DialogueController.Active then
				return
			end

			local v19 = distanceToRigging()

			if v19 and v19 <= 35 then
				v15 = true
				task.spawn(playIntroCutscene)
			end
		end
	end)
end

local function restoreAll()
	cancelIntro()
	stopLoop() -- equivalent call inferred; original call site unknown
	stopFreeSpinSound() -- equivalent call inferred; original call site unknown
	releaseCamera() -- equivalent call inferred; original call site unknown

	if destroyingConnection then
		destroyingConnection:Disconnect()
		destroyingConnection = nil
	end

	for _, v17 in jointInstances do
		v17.Enabled = true
	end

	for _, v17 in parts2 do
		local cFrame2 = cFramesByPart[v17]

		if cFrame2 and v17.Parent then
			v17.CFrame = cFrame2
		end
	end

	revealAllRigging() -- equivalent call inferred; original call site unknown
	table.clear(v4)
	table.clear(parts)
	table.clear(transparenciesByPart)
	table.clear(parts2)
	table.clear(cFramesByPart)
	table.clear(jointInstances)
	cFrame = nil
	v5 = nil
	v6 = 0
	total = 0
	v7 = 0
	flag = false
	flag2 = false
	v8 = 0
	count = 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchRig(instance)
	if destroyingConnection then
		destroyingConnection:Disconnect()
	end

	destroyingConnection = instance.Destroying:Connect(restoreAll)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyState(p)
	if p.Completed then
		flag = true
		v8 = 0
		hideAllRigging() -- equivalent call inferred; original call site unknown
		startLoop() -- equivalent call inferred; original call site unknown
		local v17 = v5

		if v9 == nil then
			if v17 == nil then
				return
			end

			pcall(function()
				local v18 = Sound:Play("PirateVillageSFX.PirateVillBonus_Windmill_Freely_Rotating_01", v17, {
					fadeIn = 1
				})
				v18.Looped = true
				v9 = v18
			end)
		end
	else
		enterTangle() -- equivalent call inferred; original call site unknown
		armIntro()
	end
end

local function startWindmill(p)
	if flag2 then
		return
	end

	local v17 = collectRig()

	if not v17 then
		count += 1
		return
	end

	count = 0
	flag2 = true
	watchRig(v17)
	applyState(p) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startLocationWatch()
	if thread then
		return
	end

	thread = task.spawn(function()
		while true do
			local v17 = v11
			local v18 = localPlayer:GetAttribute("CurrentLocation") == "Pirate Village"

			if flag2 then
				if not v18 then
					restoreAll()
				end
			elseif v17 and v18 and count < 120 and not flag2 then
				local v19 = collectRig()

				if v19 then
					count = 0
					flag2 = true
					watchRig(v19) -- equivalent call inferred; original call site unknown

					if v17.Completed then
						flag = true
						v8 = 0
						hideAllRigging() -- equivalent call inferred; original call site unknown
						startLoop() -- equivalent call inferred; original call site unknown
						startFreeSpinSound() -- equivalent call inferred; original call site unknown
					else
						enterTangle() -- equivalent call inferred; original call site unknown
						armIntro()
					end
				else
					count += 1
				end
			end

			task.wait(1)
		end
	end)
end

local WindmillMaintenance = {}
WindmillMaintenance.DataName = script.Name
WindmillMaintenance.LoadWhenCompleted = true

function WindmillMaintenance.OnLoad(p)
	restoreAll()
	v11 = p

	if not flag2 then
		local v17 = collectRig()

		if v17 then
			count = 0
			flag2 = true
			watchRig(v17) -- equivalent call inferred; original call site unknown

			if p.Completed then
				flag = true
				v8 = 0
				hideAllRigging() -- equivalent call inferred; original call site unknown
				startLoop() -- equivalent call inferred; original call site unknown
				startFreeSpinSound() -- equivalent call inferred; original call site unknown
			else
				enterTangle() -- equivalent call inferred; original call site unknown
				armIntro()
			end
		else
			count += 1
		end
	end

	startLocationWatch() -- equivalent call inferred; original call site unknown
end

WindmillMaintenance.RemoteEvents = {
	Tangled = function(_)
		if flag2 then
			enterTangle() -- equivalent call inferred; original call site unknown
			armIntro()
		end
	end,
	RopeCut = function(_, value: string, value2: number, value3: number, p)
		local v17

		if typeof(value2) == "number" and typeof(value3) == "number" then
			v17 = value3 > 0
		else
			v17 = false
		end

		local v18 = not v17 and 0 or math.clamp(value2 / value3, 0, 1)
		local v19 = v17 and value3 <= value2

		if typeof(value) == "string" then
			local v20 = v4[value]

			if v20 then
				if typeof(p) ~= "Vector3" then
					p = nil
				end

				playCutEffect(v20, p, v19)
			end

			hideGroup(value) -- equivalent call inferred; original call site unknown
		end

		total += (v18 * 2.5 + 1) * 0.9
		playRandom(v3, v5) -- equivalent call inferred; original call site unknown

		if v19 then
			total += 3
		end
	end
}

function WindmillMaintenance.OnComplete(_, p, p2)
	if p2 then
		v11 = nil
		restoreAll()
	else
		v14 = true
		cancelIntro()

		if p then
			flag = true
			v8 = 0
			hideAllRigging() -- equivalent call inferred; original call site unknown
			startLoop() -- equivalent call inferred; original call site unknown
			startFreeSpinSound() -- equivalent call inferred; original call site unknown
			playCompletionCutscene()
		end
	end
end

return WindmillMaintenance