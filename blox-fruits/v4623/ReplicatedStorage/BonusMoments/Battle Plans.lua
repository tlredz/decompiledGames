local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local DialogueController = require(game.ReplicatedStorage.DialogueController)
local Util = require(game.ReplicatedStorage.Util)
local color = Color3.fromHex("#FF4F4F")
local color2 = Color3.fromHex("#30C741")
local color3 = Color3.fromHex("#000000")
local flag = false

local function lerpV(vector2: Vector3, vector3: Vector3, p: number)
	return vector2 + (vector3 - vector2) * p
end

local function getControls()
	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if success then
		return result
	end

	return nil
end

local function makeFade()
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil, nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BattlePlansCinematic"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 60
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = Color3.new(0, 0, 0)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	return frame, screenGui
end

local function fade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		task.wait(duration)
		return
	end

	local tween = TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	})
	tween:Play()
	tween.Completed:Wait()
end

local function playFade(fade2, backgroundTransparency: number, duration: number)
	if not fade2 then
		return
	end

	TweenService:Create(fade2, TweenInfo.new(duration), {
		BackgroundTransparency = backgroundTransparency
	}):Play()
end

local function showBanner(text: string, color4: Color3, duration: number)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BattlePlansBanner"
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 61
	screenGui.Parent = playerGui
	local textLabel = Instance.new("TextLabel")
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Position = UDim2.fromScale(0.5, 0.42)
	textLabel.Size = UDim2.fromScale(0.8, 0.16)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Bold)
	textLabel.TextScaled = true
	textLabel.TextColor3 = color4
	textLabel.TextTransparency = 1
	textLabel.Text = text
	textLabel.Parent = screenGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2.5
	uIStroke.Color = color3
	uIStroke.Transparency = 1
	uIStroke.Parent = textLabel
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 52
	uITextSizeConstraint.Parent = textLabel
	TweenService:Create(textLabel, TweenInfo.new(0.4), {
		TextTransparency = 0
	}):Play()
	TweenService:Create(uIStroke, TweenInfo.new(0.4), {
		Transparency = 0
	}):Play()
	task.delay(duration, function()
		local tween = TweenService:Create(textLabel, TweenInfo.new(0.6), {
			TextTransparency = 1
		})
		local tween2 = TweenService:Create(uIStroke, TweenInfo.new(0.6), {
			Transparency = 1
		})
		tween:Play()
		tween2:Play()
		tween.Completed:Wait()
		screenGui:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function waitForDialogue()
	local total = 0

	while DialogueController.Active and total < 8 do
		total += task.wait()
	end
end

local v = {
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.EmotesMenu,
	Enum.CoreGuiType.Health
}
local screenGuis = {}
local coreGuiEnableds = {}

local function hideHud(p)
	local playerGui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, screenGui in playerGui:GetChildren() do
			if not (screenGui:IsA("ScreenGui") and screenGui.Enabled and screenGui ~= p) then
				continue
			end

			screenGui.Enabled = false
			table.insert(screenGuis, screenGui)
		end
	end

	for _, v2 in v do
		local v3 = v2
		pcall(function()
			coreGuiEnableds[v3] = StarterGui:GetCoreGuiEnabled(v3)
			StarterGui:SetCoreGuiEnabled(v3, false)
		end)
	end
end

local function restoreHud()
	for _, v2 in screenGuis do
		if v2.Parent then
			v2.Enabled = true
		end
	end

	table.clear(screenGuis)

	for k, v2 in coreGuiEnableds do
		local v3 = k
		local v4 = v2
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v3, v4)
		end)
	end

	table.clear(coreGuiEnableds)
end

local function runShots(list)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or #list == 0 then
		return
	end

	local success, result = pcall(function()
		local playerScripts = Players.LocalPlayer:WaitForChild("PlayerScripts", 5)
		local playerModule = playerScripts and playerScripts:WaitForChild("PlayerModule", 5)

		if not playerModule then
			return nil
		end

		local module = require(playerModule)
		return (module:GetControls())
	end)

	if not success then
		result = nil
	end

	if result then
		pcall(function()
			result:Disable()
		end)
	end

	local fade2, v2 = makeFade()
	fade(fade2, 0, 0.3)
	hideHud(v2)
	local cameraType = currentCamera.CameraType
	local fieldOfView = currentCamera.FieldOfView

	for k, v3 in list do
		local currentCamera2 = workspace.CurrentCamera

		if not currentCamera2 then
			break
		end

		currentCamera2.CameraType = Enum.CameraType.Scriptable
		currentCamera2.FieldOfView = v3.fov
		currentCamera2.CFrame = CFrame.lookAt(v3.camStart, v3.lookStart)

		if k == 1 then
			playFade(fade2, 1, 0.4)
		end

		local v4 = k == #list
		local lastTime = os.clock()
		local v5 = false

		while true do
			local v6 = os.clock() - lastTime
			local v7 = math.clamp(v6 / v3.duration, 0, 1)
			local currentCamera3 = workspace.CurrentCamera

			if not currentCamera3 then
				break
			end

			currentCamera3.CameraType = Enum.CameraType.Scriptable
			local camStart = v3.camStart
			local v8 = camStart + (v3.camEnd - camStart) * v7
			local lookStart = v3.lookStart
			currentCamera3.CFrame = CFrame.lookAt(v8, lookStart + (v3.lookEnd - lookStart) * v7)
			currentCamera3.FieldOfView = v3.fov

			if v4 and not v5 and v3.duration - 0.3 <= v6 then
				playFade(fade2, 0, 0.3)
				v5 = true
			end

			if v7 >= 1 then
				break
			else
				RunService.RenderStepped:Wait()
			end
		end
	end

	local currentCamera2 = workspace.CurrentCamera

	if currentCamera2 then
		currentCamera2.FieldOfView = fieldOfView

		if cameraType == Enum.CameraType.Scriptable then
			cameraType = Enum.CameraType.Custom
		end

		currentCamera2.CameraType = cameraType
	end

	if result then
		pcall(function()
			result:Enable()
		end)
	end

	restoreHud()
	fade(fade2, 1, 0.4)

	if v2 then
		v2:Destroy()
	end
end

local function basis(vector2: Vector3, vector3: Vector3)
	local v2 = (vector2 - vector3) * createVector(1, 0, 1)
	local vector4 = not (v2.Magnitude > 1) and createVector(0, 0, 1) or v2.Unit
	local cross = vector4:Cross(createVector(0, 1, 0))
	local v3 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	return createVector(0, 1, 0), vector4, v3
end

local function findIntroCannons()
	local positions = {}
	local position = nil

	for _, descendant in workspace:GetDescendants() do
		if descendant.Name ~= "BonusMoment_Locations" then
			continue
		end

		for _, model in descendant:GetChildren() do
			if not model:IsA("Model") then
				continue
			end

			if model.Name == "MarineBusterCannon_Npc" then
				position = model:GetPivot().Position
			elseif model.Name == "MarineBusterCannon" then
				table.insert(positions, model:GetPivot().Position)
			end
		end
	end

	return position, positions
end

local function playIntro(vector2: Vector3, vector3: Vector3, vector4: Vector3?)
	if flag then
		return
	end

	flag = true
	waitForDialogue() -- equivalent call inferred; original call site unknown
	local lookStart = vector4 or vector2
	local v3 = (lookStart - vector3) * createVector(1, 0, 1)
	local vector5 = not (v3.Magnitude > 1) and createVector(0, 0, 1) or v3.Unit
	local cross = vector5:Cross(createVector(0, 1, 0))
	local v4 = not (cross.Magnitude > 0.001) and createVector(1, 0, 0) or cross.Unit
	local v5 = createVector(0, 1, 0)
	local introCannons, v6 = findIntroCannons()
	local v7 = {}
	local v8 = lookStart - vector5 * 240 + v5 * 70
	table.insert(v7, {
		camStart = v8 - v4 * 120,
		camEnd = v8 + v4 * 120,
		lookStart = lookStart - v4 * 120,
		lookEnd = lookStart + v4 * 120,
		fov = 74,
		duration = 4
	})

	if introCannons then
		local camStart = introCannons - vector5 * 58 + v4 * 6 + v5 * 9
		table.insert(v7, {
			camStart = camStart,
			camEnd = camStart + v4 * 14,
			lookStart = lookStart,
			lookEnd = lookStart + v4 * 14,
			fov = 60,
			duration = 4
		})
	end

	local v9

	if #v6 > 0 then
		local v10 = createVector(0, 0, 0)

		for _, v11 in v6 do
			v10 += v11
		end

		v9 = v10 / #v6
	end

	local v10 = v9 or vector3
	local v11 = v10 + v5 * 30 - vector5 * 60
	table.insert(v7, {
		camStart = v11 - v4 * 55,
		camEnd = v11 + v4 * 55,
		lookStart = v10 - v4 * 55,
		lookEnd = v10 + v4 * 55,
		fov = 66,
		duration = 3.5
	})
	runShots(v7)
	flag = false
end

local v2 = { "Cylinder.001", "Cylinder.002" }
local Mouse = require(game.ReplicatedStorage:WaitForChild("Mouse"))
local v3 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function setAimFilter(p)
	if v3 == p then
		return
	end

	local targetFilter = Mouse.TargetFilter

	if typeof(targetFilter) == "table" then
		local index = v3 and table.find(targetFilter, v3)

		if index then
			table.remove(targetFilter, index)
		end

		if p then
			table.insert(targetFilter, p)
		end
	end

	v3 = p
end

local v4 = {}
local renderSteppedConnection = nil
local v5 = nil
local v6 = 0
local yaw = 0
local pitch = 0
local total = 0
local v7 = false

local function wrapAngle(p: number)
	return (p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
end

-- equivalent calls inferred from this helper; original call sites unknown
local function directionYaw(unit: Vector3)
	return (math.atan2(unit.X, unit.Z))
end

local function smoothDampAngle(yaw2: number, targetYaw: number, yawVel: number, p: number, p2: number, p3: number)
	local v8 = yaw2 + ((targetYaw - yaw2 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793)
	local v9 = math.max(0.0001, p)
	local v10 = 2 / v9
	local v11 = v10 * p3
	local v12 = 1 / (v11 + 1 + v11 * 0.48 * v11 + v11 * 0.235 * v11 * v11)
	local v13 = yaw2 - v8
	local v14 = p2 * v9
	local v15 = math.clamp(v13, -v14, v14)
	local v16 = (yawVel + v10 * v15) * p3
	local v17 = (yawVel - v10 * v16) * v12
	local v18 = yaw2 - v15 + (v15 + v16) * v12

	if v8 - yaw2 > 0 == (v8 < v18) then
		v17 = (v8 - v8) / p3
		v18 = v8
	end

	return v18, v17
end

-- equivalent calls inferred from this helper; original call sites unknown
local function captureBarrel(p, parent)
	p.Transform = CFrame.identity
	return parent.CFrame:Inverse() * p.WorldCFrame
end

local function measureRestPitch(cframe: CFrame, vector2: Vector3)
	local upVector = cframe.UpVector
	local v8 = -1e999

	for _, v9 in { cframe.LookVector, cframe.UpVector, cframe.RightVector } do
		for _, v10 in { 1, -1 } do
			local v11 = v9 * v10
			local v12 = v11.X * vector2.X + v11.Z * vector2.Z + v11.Y * 0.5

			if not (v8 < v12) then
				continue
			end

			upVector = v11
			v8 = v12
		end
	end

	return math.atan2(upVector.Y, (math.max(Vector3.new(upVector.X, 0, upVector.Z).Magnitude, 0.0001))), upVector
end

-- equivalent calls inferred from this helper; original call sites unknown
local function localSeat()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		return humanoid.SeatPart
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shakeShell(p)
	local v8 = localSeat() -- equivalent call inferred; original call site unknown

	if v8 ~= p.seat then
		return
	end

	Util.CameraShaker:ShakeOnce(1.6, 9, 0, 0.3)
end

local function startVolleyRecoil(state)
	local v8 = {}

	if state.barrelL and state.restLocalL then
		table.insert(v8, "L")
	end

	if state.barrelR and state.restLocalR then
		table.insert(v8, "R")
	end

	if #v8 == 0 then
		return
	end

	task.spawn(function()
		for i = 1, 6 do
			if v4[state.model] ~= state then
				break
			end

			if v8[(i - 1) % #v8 + 1] == "L" then
				state.recoilL = 2.5
			else
				state.recoilR = 2.5
			end

			shakeShell(state) -- equivalent call inferred; original call site unknown

			if i < 6 then
				task.wait(0.15)
			end
		end
	end)
end

local function collectBusters()
	v4 = {}

	for _, descendant in workspace:GetDescendants() do
		if descendant.Name ~= "BonusMoment_Locations" then
			continue
		end

		for _, model in descendant:GetChildren() do
			if not (model:IsA("Model") and (model.Name == "MarineBusterCannon" or model.Name == "MarineBusterCannon_Npc")) then
				continue
			end

			local seat = model:FindFirstChild("Seat")

			if not (seat and seat:IsA("BasePart")) then
				continue
			end

			local pivot = model:GetPivot()
			local lookVector = seat.CFrame.LookVector
			local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
			local restForward = not (vector2.Magnitude > 0.001) and createVector(0, 0, 1) or vector2.Unit
			local controller = model:FindFirstChild("Controller", true)
			local barrelL = controller and controller:FindFirstChild("Barrel.L")
			local barrelR = controller and controller:FindFirstChild("Barrel.R")

			if not (barrelL and barrelL:IsA("Bone")) then
				barrelL = nil
			end

			if not (barrelR and barrelR:IsA("Bone")) then
				barrelR = nil
			end

			local parent

			if controller and controller.Parent and controller.Parent:IsA("BasePart") then
				parent = controller.Parent
			end

			if not parent then
				parent = model:FindFirstChild("RootPart")

				if not (parent and parent:IsA("BasePart")) then
					parent = model.PrimaryPart
				end
			end

			local restLocalR = nil
			local restLocalL

			if barrelL and parent then
				restLocalL = captureBarrel(barrelL, parent)
			end

			if barrelR and parent then
				restLocalR = captureBarrel(barrelR, parent)
			end

			local v11 = restLocalL or restLocalR
			local v12 = not (v11 and parent) and 0 or measureRestPitch(parent.CFrame * v11, restForward)
			local muzzles = {}

			if parent then
				local cFrame = parent.CFrame
				local v14 = {}

				for _, childName in v2 do
					local part = model:FindFirstChild(childName)

					if not (part and part:IsA("BasePart")) then
						continue
					end

					local v15 = part.Size.Z / 2
					table.insert(v14, part.CFrame:PointToWorldSpace((Vector3.new(0, 0, v15))))
					table.insert(v14, part.CFrame:PointToWorldSpace((Vector3.new(0, 0, -v15))))
				end

				local restForward2 = restForward
				local muzzles2 = muzzles

				local function addMuzzle(bone, cframe: CFrame?)
					if not (bone and cframe) then
						return
					end

					local cframe2 = cFrame * cframe
					local v19, v20 = measureRestPitch(cframe2, restForward2)
					local v21 = 0

					for k, v22 in v14 do
						v21 = math.max(v21, (v22 - cframe2.Position):Dot(v20))
					end

					local v22 = v21 <= 0 and 20 or v21
					table.insert(muzzles2, {
						bone = bone,
						offset = cframe2:VectorToObjectSpace(v20) * v22
					})
				end

				addMuzzle(barrelL, restLocalL)
				addMuzzle(barrelR, restLocalR)
			end

			local v14 = {
				model = model,
				seat = seat,
				restCF = pivot,
				center = pivot.Position,
				restForward = restForward,
				yaw = 0,
				targetYaw = 0,
				yawVel = 0,
				lastRelay = 0,
				pitch = v12,
				targetPitch = v12,
				restPitch = v12,
				rootPart = parent,
				barrelL = barrelL,
				barrelR = barrelR,
				restLocalL = restLocalL,
				restLocalR = restLocalR,
				muzzles = muzzles,
				recoilL = 0,
				recoilR = 0,
				cooldownConn = nil
			}
			v14.cooldownConn = model.ChildAdded:Connect(function(child)
				if child.Name == "Cooldown" then
					startVolleyRecoil(v14)
				end
			end)
			v4[model] = v14
		end
	end
end

local function getAimRemote()
	if v5 then
		return v5
	end

	local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
	local marineBusterAim = remotes and remotes:FindFirstChild("MarineBusterAim")

	if marineBusterAim and marineBusterAim:IsA("UnreliableRemoteEvent") then
		v5 = marineBusterAim
	end

	return v5
end

local function applyYaw(data)
	local v8 = CFrame.new(data.center) * CFrame.Angles(0, data.yaw, 0) * CFrame.new(-data.center)
	data.model:PivotTo(v8 * data.restCF)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ballisticPitch(position: Vector3, vector2: Vector3)
	local v8 = math.max(Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z).Magnitude, 8) / 180
	return (math.atan2((vector2.Y - (position.Y + 2.25) + 0.5 * workspace.Gravity * v8 * v8) / v8, 180))
end

local function clampTarget(vector2: Vector3, vector3: Vector3, unit: Vector3)
	local vector4 = Vector3.new(vector3.X - vector2.X, 0, vector3.Z - vector2.Z)
	local magnitude = vector4.Magnitude

	if magnitude > 0.01 then
		unit = vector4.Unit
	end

	local v8 = math.clamp(vector3.Y - vector2.Y, -300, 60)
	return vector2 + unit * math.clamp(magnitude, 8, 700) + Vector3.new(0, v8, 0)
end

local result = {}

local function ensureArcs(p: number)
	local terrain = workspace.Terrain

	for i = #result + 1, p do
		local attachment = Instance.new("Attachment")
		attachment.Name = "BusterArc0_" .. i
		attachment.Parent = terrain
		local attachment2 = Instance.new("Attachment")
		attachment2.Name = "BusterArc1_" .. i
		attachment2.Parent = terrain
		local beam = Instance.new("Beam")
		beam.Name = "BusterArc" .. i
		beam.Attachment0 = attachment
		beam.Attachment1 = attachment2
		beam.Color = ColorSequence.new(color)
		beam.FaceCamera = true
		beam.LightEmission = 1
		beam.LightInfluence = 0
		beam.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.6),
			NumberSequenceKeypoint.new(1, 0.15)
		})
		beam.Width0 = 0.4
		beam.Width1 = 1.4
		beam.Segments = 40
		beam.Enabled = false
		beam.Parent = terrain
		table.insert(result, {
			beam = beam,
			a0 = attachment,
			a1 = attachment2
		})
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideArcs()
	for _, v8 in result do
		v8.beam.Enabled = false
	end
end

local function destroyArcs()
	for _, v8 in result do
		v8.beam:Destroy()
		v8.a0:Destroy()
		v8.a1:Destroy()
	end

	table.clear(result)
end

local function drawArc(data, worldPosition: Vector3, vector2: Vector3, unit: Vector3)
	local gravity = workspace.Gravity
	local vector3 = Vector3.new(vector2.X - worldPosition.X, 0, vector2.Z - worldPosition.Z)

	if vector3.Magnitude > 0.01 then
		unit = vector3.Unit
	end

	local v8 = math.max(vector3.Magnitude, 8) / 180
	local v9 = math.min((vector2.Y - worldPosition.Y + 0.5 * gravity * v8 * v8) / v8, 386.01124569172055)
	local v10 = math.min(v8, 4)
	local v11 = unit * 180 + Vector3.new(0, v9, 0)
	local v12 = v11 - Vector3.new(0, gravity * v10, 0)
	local worldPosition2 = worldPosition + unit * (v10 * 180) + Vector3.new(0, v9 * v10 - 0.5 * gravity * v10 * v10, 0)
	data.a0.WorldPosition = worldPosition
	data.a0.WorldAxis = v11.Unit
	data.a1.WorldPosition = worldPosition2
	data.a1.WorldAxis = v12.Unit
	data.beam.CurveSize0 = v11.Magnitude * v10 / 3
	data.beam.CurveSize1 = v12.Magnitude * v10 / 3
	data.beam.Enabled = true
end

local function updateArcs(data, vector2: Vector3)
	local v8 = {}

	for _, muzzle in data.muzzles do
		table.insert(v8, muzzle.bone.TransformedWorldCFrame:PointToWorldSpace(muzzle.offset))
	end

	if #v8 == 0 then
		local gravity = workspace.Gravity
		local position = data.seat.Position
		local vector3 = Vector3.new(vector2.X - position.X, 0, vector2.Z - position.Z)
		local unit

		if vector3.Magnitude > 0.01 then
			unit = vector3.Unit
		else
			unit = data.restForward
		end

		local v9 = math.max(vector3.Magnitude, 8) / 180
		local v10 = math.min((vector2.Y - (position.Y + 2.25) + 0.5 * gravity * v9 * v9) / v9, 386.01124569172055)
		local v11 = unit * 180 + Vector3.new(0, v10, 0)
		table.insert(v8, position + createVector(0, 2.25, 0) + v11.Unit * 30)
	end

	for k, v9 in ensureArcs(#v8) do
		local worldPosition = v8[k]

		if worldPosition then
			drawArc(v9, worldPosition, vector2, data.restForward)
		else
			v9.beam.Enabled = false
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function pitchBone(p, cframe: CFrame, unit: Vector3, p2: number, vector2: Vector3)
	local cframe2 = CFrame.fromAxisAngle(unit, p2)
	local v8 = CFrame.new(cframe.Position + vector2) * cframe2 * (cframe - cframe.Position)
	p.Transform = cframe:Inverse() * v8
end

local function applyBarrels(data)
	local rootPart = data.rootPart

	if not (rootPart and (data.barrelL or data.barrelR)) then
		return
	end

	local lookVector = data.seat.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
	local unit

	if vector2.Magnitude > 0.001 then
		unit = vector2.Unit
	else
		unit = data.restForward
	end

	local cross = (createVector(0, 1, 0)):Cross(unit)

	if cross.Magnitude < 0.0001 then
		return
	end

	local unit2 = cross.Unit
	local v8 = data.restPitch - data.pitch
	local v9 = unit * math.cos(data.pitch) + createVector(0, 1, 0) * math.sin(data.pitch)
	local cFrame = rootPart.CFrame

	if data.barrelL and data.restLocalL then
		pitchBone(data.barrelL, cFrame * data.restLocalL, unit2, v8, v9 * -data.recoilL) -- equivalent call inferred; original call site unknown
	end

	if data.barrelR and data.restLocalR then
		pitchBone(data.barrelR, cFrame * data.restLocalR, unit2, v8, v9 * -data.recoilR) -- equivalent call inferred; original call site unknown
	end
end

local function swivelStep(dt: number)
	local v8 = localSeat() -- equivalent call inferred; original call site unknown
	local now = os.clock()
	local v9 = nil
	local flag2 = false

	for k, v10 in v4 do
		if not k:IsDescendantOf(workspace) then
			continue
		end

		local v11

		if v8 == nil then
			v11 = false
		else
			v11 = v8 == v10.seat
		end

		if v11 then
			flag2 = true
			local position = Mouse.Hit.Position
			local vector2 = Vector3.new(position.X - v10.center.X, 0, position.Z - v10.center.Z)

			if vector2.Magnitude >= 40 then
				local position2 = v10.seat.Position
				local restForward = v10.restForward
				local vector3 = Vector3.new(position.X - position2.X, 0, position.Z - position2.Z)
				local magnitude = vector3.Magnitude

				if magnitude > 0.01 then
					restForward = vector3.Unit
				end

				local v12 = math.clamp(position.Y - position2.Y, -300, 60)
				local v13 = position2 + restForward * math.clamp(magnitude, 8, 700) + Vector3.new(0, v12, 0)
				local v14 = directionYaw(vector2.Unit) -- equivalent call inferred; original call site unknown
				local restForward2 = v10.restForward
				v10.targetYaw = (v14 - math.atan2(restForward2.X, restForward2.Z) + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
				local position3 = v10.seat.Position
				v10.targetPitch = math.clamp(ballisticPitch(position3, v13), 0, 1.1344640137963142)
				updateArcs(v10, v13)
				v9 = k
			else
				v9 = k
				hideArcs() -- equivalent call inferred; original call site unknown
			end
		elseif now - v10.lastRelay > 0.5 then
			v10.targetYaw = 0
			v10.targetPitch = v10.restPitch
		else
			flag2 = true
		end

		local v12, yawVel = smoothDampAngle(v10.yaw, v10.targetYaw, v10.yawVel, 0.45, 1.5707963267948966, dt)
		v10.yawVel = yawVel

		if math.abs((v12 - v10.yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) > 0.00001 or math.abs(yawVel) > 0.0001 then
			v10.yaw = (v12 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793
			applyYaw(v10)
			flag2 = true
		end

		local v14 = v10.targetPitch - v10.pitch
		local v15 = dt * 3.839724354387525

		if v15 < v14 then
			v14 = v15
		elseif v14 < -v15 then
			v14 = -v15
		end

		if math.abs(v14) > 0.00001 then
			v10.pitch += v14
			flag2 = true
		end

		if v10.recoilL > 0 then
			v10.recoilL = math.max(0, v10.recoilL - dt * 9)
			flag2 = true
		end

		if v10.recoilR > 0 then
			v10.recoilR = math.max(0, v10.recoilR - dt * 9)
			flag2 = true
		end

		applyBarrels(v10)

		if not (v11 and now - v6 >= 0.06) then
			continue
		end

		if not (math.abs((v10.yaw - yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) >= 0.017453292519943295 or math.abs(v10.pitch - pitch) >= 0.017453292519943295 or now - v6 >= 0.35) then
			continue
		end

		if not v5 then
			local remotes = game.ReplicatedStorage:FindFirstChild("Remotes")
			local marineBusterAim = remotes and remotes:FindFirstChild("MarineBusterAim")

			if marineBusterAim and marineBusterAim:IsA("UnreliableRemoteEvent") then
				v5 = marineBusterAim
			end
		end

		local v16 = v5

		if not v16 then
			continue
		end

		v6 = now
		yaw = v10.yaw
		pitch = v10.pitch
		v16:FireServer(k, v10.yaw, v10.pitch)
	end

	setAimFilter(v9) -- equivalent call inferred; original call site unknown

	if not v9 then
		hideArcs() -- equivalent call inferred; original call site unknown
	end

	if flag2 then
		total = 0
	else
		total += dt
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopSwivel(flag2: boolean)
	if v3 ~= nil then
		local targetFilter = Mouse.TargetFilter
		local index = typeof(targetFilter) == "table" and v3 and table.find(targetFilter, v3)

		if index then
			table.remove(targetFilter, index)
		end

		v3 = nil
	end

	destroyArcs()

	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, v8 in v4 do
		if not v8.cooldownConn then
			continue
		end

		v8.cooldownConn:Disconnect()
		v8.cooldownConn = nil
	end

	if flag2 then
		for k, v8 in v4 do
			if not k:IsDescendantOf(workspace) then
				continue
			end

			local v9 = k
			local v10 = v8
			pcall(function()
				v9:PivotTo(v10.restCF)

				if v10.barrelL then
					v10.barrelL.Transform = CFrame.identity
				end

				if v10.barrelR then
					v10.barrelR.Transform = CFrame.identity
				end
			end)
		end
	end

	v4 = {}
	total = 0
end

local function startSwivel()
	if renderSteppedConnection then
		return
	end

	if not next(v4) then
		collectBusters()
	end

	if not next(v4) then
		return
	end

	total = 0
	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
		swivelStep(dt)

		if not v7 and total > 1.5 then
			-- equivalent call inferred; original call site unknown
			if not localSeat() then
				stopSwivel(false) -- equivalent call inferred; original call site unknown
			end
		end
	end)
end

local v8 = nil
local v9 = nil
local childAddedConnection = nil

local function loadTrack(animator, animationId: string)
	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local success, result2 = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if success then
		return result2
	end

	return nil
end

local function stopGunnerAnims()
	if childAddedConnection then
		childAddedConnection:Disconnect()
		childAddedConnection = nil
	end

	if v8 then
		v8:Stop(0.2)
		v8:Destroy()
		v8 = nil
	end

	if v9 then
		v9:Stop(0.1)
		v9:Destroy()
		v9 = nil
	end
end

local function startGunnerAnims(part)
	stopGunnerAnims()
	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://127082316056197"
	local success, result2 = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not success then
		result2 = nil
	end

	if result2 then
		result2.Priority = Enum.AnimationPriority.Action
		result2.Looped = true
		result2:Play(0.2)
		v8 = result2
	end

	local animation2 = Instance.new("Animation")
	animation2.AnimationId = "rbxassetid://86587466813590"
	local success2, result3 = pcall(function()
		return animator:LoadAnimation(animation2)
	end)

	if not success2 then
		result3 = nil
	end

	if result3 then
		result3.Priority = Enum.AnimationPriority.Action2
		result3.Looped = false
		v9 = result3
	end

	local parent = part.Parent

	if parent then
		childAddedConnection = parent.ChildAdded:Connect(function(child)
			if child.Name == "Cooldown" and v9 then
				v9:Play(0.05)
			end
		end)
	end
end

local function onLocalSeated(flag2: boolean, part)
	if not flag2 or typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part.Parent or part.Parent.Name ~= "MarineBusterCannon" then
		stopGunnerAnims()
		return
	end

	startSwivel()
	startGunnerAnims(part)
end

local function hookCharacter(instance)
	stopGunnerAnims()
	local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:WaitForChild("Humanoid", 10)

	if not (humanoid and humanoid:IsA("Humanoid")) then
		return
	end

	humanoid.Seated:Connect(onLocalSeated)

	if humanoid.SeatPart then
		onLocalSeated(true, humanoid.SeatPart)
	end
end

Players.LocalPlayer.CharacterAdded:Connect(hookCharacter)

if Players.LocalPlayer.Character then
	task.spawn(hookCharacter, Players.LocalPlayer.Character)
end

task.spawn(function()
	local remotes = game.ReplicatedStorage:WaitForChild("Remotes", 30)
	local marineBusterAim = remotes and remotes:WaitForChild("MarineBusterAim", 30)

	if marineBusterAim and marineBusterAim:IsA("UnreliableRemoteEvent") then
		v5 = marineBusterAim
		marineBusterAim.OnClientEvent:Connect(function(model, targetYaw, value)
			if typeof(targetYaw) ~= "number" or typeof(model) ~= "Instance" or not model:IsA("Model") then
				return
			end

			startSwivel()
			local v10 = v4[model]

			if not v10 then
				return
			end

			local v11 = localSeat() -- equivalent call inferred; original call site unknown

			if v11 and v11 == v10.seat then
				return
			end

			v10.targetYaw = targetYaw

			if typeof(value) == "number" then
				v10.targetPitch = math.clamp(value, 0, 1.1344640137963142)
			end

			v10.lastRelay = os.clock()
		end)
	end
end)
local v10 = nil
local object = setmetatable({}, {
	__mode = "k"
})

local function getWarnEffect()
	if v10 == nil then
		local success, result2 = pcall(function()
			local fishReplicated = game.ReplicatedStorage:WaitForChild("FishReplicated", 10)
			local fishingClient = fishReplicated and fishReplicated:WaitForChild("FishingClient", 10)
			local effect = fishingClient and fishingClient:WaitForChild("Effect", 10)

			if not effect then
				return false
			end

			local module = require(effect)
			return module
		end)
		v10 = success and result2 or false
	end

	return v10 or nil
end

local function warnAnchor(instance)
	local seat = instance:FindFirstChild("Seat")

	if seat and seat:IsA("BasePart") then
		return seat
	end

	return instance:FindFirstChildWhichIsA("BasePart", true)
end

local function warnCannon(model, duration: number)
	local v11 = os.clock() + duration

	if (object[model] or 0) > os.clock() then
		return
	end

	if v10 == nil then
		local success, result2 = pcall(function()
			local fishReplicated = game.ReplicatedStorage:WaitForChild("FishReplicated", 10)
			local fishingClient = fishReplicated and fishReplicated:WaitForChild("FishingClient", 10)
			local effect = fishingClient and fishingClient:WaitForChild("Effect", 10)

			if not effect then
				return false
			end

			local module = require(effect)
			return module
		end)
		v10 = success and result2 or false
	end

	local v12

	if v10 then
		v12 = v10
	end

	local seat

	if v12 then
		seat = model:FindFirstChild("Seat")

		if not (seat and seat:IsA("BasePart")) then
			seat = model:FindFirstChildWhichIsA("BasePart", true)
		end
	end

	if not (v12 and seat) then
		return
	end

	object[model] = v11
	local success, result2 = pcall(v12, {
		Mode = "Warn",
		Duration = duration,
		Head = seat
	})

	if not success or typeof(result2) ~= "Instance" or not result2:IsA("Attachment") then
		object[model] = nil
		return
	end

	local particleEmitter = result2:FindFirstChildWhichIsA("ParticleEmitter")

	if particleEmitter then
		particleEmitter.Enabled = false
	end

	local boundingBox, v13 = model:GetBoundingBox()
	result2.WorldPosition = Vector3.new(
		boundingBox.Position.X,
		boundingBox.Position.Y + v13.Y / 2 + 7,
		boundingBox.Position.Z
	)
	task.delay(duration, function()
		if object[model] == v11 then
			object[model] = nil
		end

		result2:Destroy()
	end)
end

task.spawn(function()
	local remotes = game.ReplicatedStorage:WaitForChild("Remotes", 30)
	local marineCannonWarn = remotes and remotes:WaitForChild("MarineCannonWarn", 30)

	if not (marineCannonWarn and marineCannonWarn:IsA("RemoteEvent")) then
		return
	end

	if v10 == nil then
		local success, result2 = pcall(function()
			local fishReplicated = game.ReplicatedStorage:WaitForChild("FishReplicated", 10)
			local fishingClient = fishReplicated and fishReplicated:WaitForChild("FishingClient", 10)
			local effect = fishingClient and fishingClient:WaitForChild("Effect", 10)

			if not effect then
				return false
			end

			local module = require(effect)
			return module
		end)
		v10 = success and result2 or false
	end

	marineCannonWarn.OnClientEvent:Connect(function(model, value)
		if typeof(model) ~= "Instance" or not (model:IsA("Model") and model:IsDescendantOf(workspace)) then
			return
		end

		if typeof(value) ~= "number" or value ~= value then
			return
		end

		warnCannon(model, math.clamp(value, 0.5, 8))
	end)
end)
return {
	DataName = script.Name,
	Repeatable = true,
	RemoteEvents = {
		Cinematic = function(_, p, p2, p3)
			if typeof(p) ~= "Vector3" or typeof(p2) ~= "Vector3" then
				return
			end

			if typeof(p3) ~= "Vector3" then
				p3 = nil
			end

			task.spawn(playIntro, p, p2, p3)
		end,
		RaidStart = function(_)
			v7 = true
			startSwivel()
		end,
		Failed = function(_)
			v7 = false
			stopSwivel(true)
			showBanner("THE FORTRESS HAS FALLEN", color, 3.5)
		end
	},
	OnComplete = function(_, p, _)
		v7 = false
		stopSwivel(true)

		if p then
			showBanner("THE FORTRESS STANDS", color2, 3)
		end
	end
}