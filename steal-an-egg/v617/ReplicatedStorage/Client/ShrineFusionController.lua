local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local shrineFusion = Remotes.ShrineFusion
local ShrineFusionSequence = require(ReplicatedStorage.Client.ShrineFusionSequence)
local ShrinePadZone = require(ReplicatedStorage.Shared.Util.ShrinePadZone)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = {
	Light = Color3.fromRGB(255, 209, 74),
	Dark = Color3.fromRGB(198, 42, 32)
}
local _ = {
	DiscDiameter = 15.6,
	DiscLift = 0.07,
	OrbCount = 3,
	OrbRadius = 7.2,
	OrbSize = 0.7,
	OrbSpeed = 1.3,
	OrbBob = 0.5,
	OrbHeight = 1.3,
	AnimDistance = 180,
	Approach = 6,
	Breathe = 1.7,
	FieldSize = 46,
	ArcCurve = 9,
	ArcWidth = 0.9
}
local v2 = {}
local v3 = {
	Ready = false
}
local flag = false
local v4 = 0
local v5 = nil
local v6 = nil
local v7 = nil
local fusionShrineBillboard = ReplicatedStorage.Assets.Billboards:WaitForChild("FusionShrineBillboard")
assert(
	fusionShrineBillboard:IsA("BillboardGui"),
	"ReplicatedStorage.Assets.Billboards.FusionShrineBillboard must be a BillboardGui"
)

-- equivalent calls inferred from this helper; original call sites unknown
local function child(instance, childName: string)
	local child2 = instance:FindFirstChild(childName)
	assert(child2, instance:GetFullName() .. "." .. childName .. " is missing")
	return child2
end

local function statusOf(instance, childName: string)
	local child2 = child(instance, childName) -- equivalent call inferred; original call site unknown
	local status = child2:FindFirstChild("Status")
	assert(status, child2:GetFullName() .. ".Status is missing")
	assert(status:IsA("TextLabel"), status:GetFullName() .. " must be a TextLabel")
	return status
end

local function contentOf(instance)
	local card = instance:FindFirstChild("Card")
	assert(card, instance:GetFullName() .. ".Card is missing")
	local inner = card:FindFirstChild("Inner")
	assert(inner, card:GetFullName() .. ".Inner is missing")
	local content = inner:FindFirstChild("Content")
	assert(content, inner:GetFullName() .. ".Content is missing")
	return content
end

local function styleOf(instance)
	local uIGradient = instance:FindFirstChildOfClass("UIGradient")
	local v8 = {
		Text = instance.Text,
		Color = 0
	}
	local color

	if uIGradient then
		color = uIGradient.Color
	end

	v8.Color = color
	return v8
end

local v8 = {
	COMPLETED = 0,
	AVAILABLE = 0
}
local card = fusionShrineBillboard:FindFirstChild("Card")
assert(card, fusionShrineBillboard:GetFullName() .. ".Card is missing")
local inner = card:FindFirstChild("Inner")
assert(inner, card:GetFullName() .. ".Inner is missing")
local content = inner:FindFirstChild("Content")
assert(content, inner:GetFullName() .. ".Content is missing")
local divineColumn = content:FindFirstChild("DivineColumn")
assert(divineColumn, content:GetFullName() .. ".DivineColumn is missing")
local status = divineColumn:FindFirstChild("Status")
assert(status, divineColumn:GetFullName() .. ".Status is missing")
assert(status:IsA("TextLabel"), status:GetFullName() .. " must be a TextLabel")
local uIGradient = status:FindFirstChildOfClass("UIGradient")
local COMPLETED = {
	Text = status.Text,
	Color = 0
}
local color3

if uIGradient then
	color3 = uIGradient.Color
end

COMPLETED.Color = color3
v8.COMPLETED = COMPLETED
local card2 = fusionShrineBillboard:FindFirstChild("Card")
assert(card2, fusionShrineBillboard:GetFullName() .. ".Card is missing")
local inner2 = card2:FindFirstChild("Inner")
assert(inner2, card2:GetFullName() .. ".Inner is missing")
local content2 = inner2:FindFirstChild("Content")
assert(content2, inner2:GetFullName() .. ".Content is missing")
local eternalColumn = content2:FindFirstChild("EternalColumn")
assert(eternalColumn, content2:GetFullName() .. ".EternalColumn is missing")
local status2 = eternalColumn:FindFirstChild("Status")
assert(status2, eternalColumn:GetFullName() .. ".Status is missing")
assert(status2:IsA("TextLabel"), status2:GetFullName() .. " must be a TextLabel")
local uIGradient2 = status2:FindFirstChildOfClass("UIGradient")
local AVAILABLE = {
	Text = status2.Text,
	Color = 0
}
local color4

if uIGradient2 then
	color4 = uIGradient2.Color
end

AVAILABLE.Color = color4
v8.AVAILABLE = AVAILABLE

-- equivalent calls inferred from this helper; original call sites unknown
local function applyStatus(instance, value)
	local v13

	if type(value) == "string" then
		v13 = v8[value]
	end

	instance.Text = not v13 and "LOADING" or v13.Text
	local uIGradient3 = instance:FindFirstChildOfClass("UIGradient")
	local color

	if v13 then
		color = v13.Color
	else
		color = v8.AVAILABLE.Color
	end

	if uIGradient3 and color then
		uIGradient3.Color = color
	end
end

local function mix(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value: number)
	local v13 = math.clamp(value, 0, 1)
	return v13 * v13 * (3 - v13 * 2)
end

local function localRoot()
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		return humanoidRootPart.Position
	end

	return nil
end

local function shotRig(p)
	local position = p.Light.Position
	local position2 = p.Dark.Position
	local v13 = position - position2
	local axis = not (v13.Magnitude > 0.01) and createVector(1, 0, 0) or v13.Unit
	local unit = (createVector(0, 1, 0)):Cross(axis)
	local focus = (position + position2) / 2 + createVector(0, 5.5, 0)
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local position3

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		position3 = humanoidRootPart.Position
	end

	local v16 = not position3 and createVector(0, 0, 0) or (focus - position3) * createVector(1, 0, 1)
	local v17 = {
		Focus = focus,
		Axis = axis,
		Front = unit,
		Light = position,
		Dark = position2,
		Span = math.max(18, v13.Magnitude * 1.25),
		Root = position3,
		Approach = 0
	}

	if v16.Magnitude > 0.01 then
		unit = v16.Unit
	end

	v17.Approach = unit
	return v17
end

local function camFrame(state, data, serverTimeNow: number, dt: number)
	local cam = state.Cam

	if not cam then
		cam = {
			Dist = 1.26,
			Height = 9.4,
			FOV = 56,
			Angle = 0.34,
			Drift = 1,
			Shot = 1
		}
		state.Cam = cam
	end

	local flightFocus = ShrineFusionSequence.FlightFocus()
	local v13 = 1 - math.exp(-dt * 2.8)
	local v14 = 1 - math.exp(-dt * 5.2)
	local v15 = math.max(state.EndsAt - state.StartedAt, 1)
	local v16 = math.clamp(v15 * 0.24, 0.5, 1.3)
	local v17 = state.EndsAt - v16
	local v18 = math.clamp((serverTimeNow - state.StartedAt) / v15, 0, 1)
	local dist2, height2, FOV2, angle2, drift2

	if state.PayoffAt then
		local v24 = smooth((serverTimeNow - state.PayoffAt - 1.1) / 3.4) -- equivalent call inferred; original call site unknown
		dist2 = v24 * 0.24 + 0.6
		height2 = v24 * 1.1999999999999993 + 4.4
		FOV2 = v24 * 3 + 46
		angle2 = 0
		drift2 = 0
	elseif v17 <= serverTimeNow then
		local v24 = smooth((serverTimeNow - v17) / v16) -- equivalent call inferred; original call site unknown
		dist2 = v24 * -0.06000000000000005 + 0.56
		height2 = v24 * -0.3999999999999999 + 3.6
		FOV2 = v24 * -2.5 + 46
		angle2 = 0
		drift2 = 0
	elseif v18 < 0.38 then
		local v24 = smooth(v18 / 0.38) -- equivalent call inferred; original call site unknown
		dist2 = v24 * -0.24 + 1.26
		height2 = v24 * -2.2 + 9.4
		FOV2 = v24 * -3 + 56
		angle2 = 0.34
		drift2 = 1
	else
		local v24 = math.max((v17 - state.StartedAt) / v15, 0.43)
		local v25 = smooth((v18 - 0.38) / (v24 - 0.38)) -- equivalent call inferred; original call site unknown
		angle2 = v25 * 0.55 + -0.55
		dist2 = v25 * -0.32999999999999996 + 0.95
		height2 = v25 * -0.6000000000000005 + 4.4
		FOV2 = v25 * -4 + 50
		drift2 = 0.5

		if cam.Shot == 1 then
			cam.Shot = 2
			cam.Angle = angle2
			cam.Dist = dist2
			cam.Height = height2
			cam.FOV = FOV2
			cam.Drift = drift2
		end
	end

	local dist = cam.Dist
	cam.Dist = dist + (dist2 - dist) * v13
	local height = cam.Height
	cam.Height = height + (height2 - height) * v13
	local FOV = cam.FOV
	cam.FOV = FOV + ((flightFocus and 51 or FOV2) - FOV) * v13
	local angle = cam.Angle
	cam.Angle = angle + (angle2 - angle) * v14
	local drift = cam.Drift
	cam.Drift = drift + (drift2 - drift) * v14
	local v24 = cam.Angle + math.sin((serverTimeNow - state.StartedAt) * 0.33) * 0.05 * cam.Drift
	local unit = (data.Front * math.cos(v24) + data.Axis * math.sin(v24)).Unit
	local v25 = data.Focus + unit * data.Span * cam.Dist + Vector3.new(0, cam.Height, 0)

	if flightFocus and not cam.Anchor then
		cam.Anchor = v25
		cam.AnchorFrom = v25
		cam.AnchorTo = data.Focus + unit * data.Span * 0.78 + createVector(0, 5.6, 0)
		cam.AnchorAt = serverTimeNow
		cam.AimPoint = data.Focus
		cam.AimGoal = data.Focus
		cam.AimVelocity = createVector(0, 0, 0)
	end

	if not cam.Anchor then
		return CFrame.lookAt(v25, data.Focus), cam.FOV
	end

	cam.Anchor = cam.AnchorFrom:Lerp(cam.AnchorTo, smooth((serverTimeNow - cam.AnchorAt) / 0.55))
	local aimGoal

	if flightFocus then
		aimGoal = data.Focus:Lerp(flightFocus, 0.42)
	else
		aimGoal = data.Focus
	end

	cam.AimGoal = aimGoal
	local v27 = math.min(dt, 0.03333333333333333)
	cam.AimVelocity += ((cam.AimGoal - cam.AimPoint) * 30.25 - cam.AimVelocity * 6.6) * v27
	cam.AimPoint += cam.AimVelocity * v27
	return CFrame.lookAt(cam.Anchor, cam.AimPoint), cam.FOV
end

local function letterbox(screenGui)
	local v13 = {}

	for k, name in { "TopBar", "BottomBar" } do
		local frame = Instance.new("Frame")
		frame.Name = name
		frame.BackgroundColor3 = Color3.new()
		frame.BorderSizePixel = 0
		frame.ZIndex = 5
		local anchorPoint

		if k == 1 then
			anchorPoint = Vector2.new(0, 0)
		else
			anchorPoint = Vector2.new(0, 1)
		end

		frame.AnchorPoint = anchorPoint
		local position

		if k == 1 then
			position = UDim2.fromScale(0, 0)
		else
			position = UDim2.fromScale(0, 1)
		end

		frame.Position = position
		frame.Size = UDim2.fromScale(1, 0)
		frame.Parent = screenGui
		v13[k] = frame
		TweenService:Create(frame, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(1, 0.115)
		}):Play()
	end

	return v13[1], v13[2]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setBillboards(state, flag2: boolean)
	if state.BillboardsOn == flag2 then
		return
	end

	state.BillboardsOn = flag2

	for _, billboard in state.Billboards do
		if billboard.Parent then
			billboard.Enabled = flag2
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refresh()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		local success, result, v13 = pcall(function()
			return shrineFusion.AskState:InvokeServer()
		end)

		if success and result and type(v13) == "table" then
			v3 = v13
		end

		flag = false
	end)
end

local function label(parent, name: string, text: string, position: UDim2, size: UDim2, textColor: Color3)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name
	textLabel.BackgroundTransparency = 1
	textLabel.Position = position
	textLabel.Size = size
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Text = text
	textLabel.TextColor3 = textColor
	textLabel.TextScaled = true
	textLabel.TextWrapped = true
	textLabel.Parent = parent
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 25
	uITextSizeConstraint.MinTextSize = 10
	uITextSizeConstraint.Parent = textLabel
	return textLabel
end

local function billboard(parent, name: string, adornee, point: Vector2, studsOffsetWorldSpace: Vector3)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = name
	billboardGui.Adornee = adornee
	billboardGui.Size = UDim2.fromOffset(point.X, point.Y)
	billboardGui.StudsOffsetWorldSpace = studsOffsetWorldSpace
	billboardGui.MaxDistance = 85
	billboardGui.AlwaysOnTop = false
	billboardGui.ResetOnSpawn = false
	billboardGui.Parent = parent
	return billboardGui
end

local function characterOf(value)
	local playerByUserId

	if type(value) == "number" then
		playerByUserId = Players:GetPlayerByUserId(value)
	end

	if playerByUserId then
		return playerByUserId.Character
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function recipeOf(tier)
	if v3.Ready and type(v3.Recipes) == "table" then
		return v3.Recipes[tier]
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseCamera(data, cFrame: CFrame?)
	local currentCamera = workspace.CurrentCamera

	if currentCamera == data.Camera and currentCamera.CameraType == Enum.CameraType.Scriptable then
		currentCamera.CameraType = data.Type
		currentCamera.FieldOfView = data.FOV

		if cFrame then
			currentCamera.CFrame = cFrame
		end

		currentCamera.CameraSubject = data.Subject
	end
end

local function dropBars(data)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

	for _, v13 in { data.Top, data.Bottom } do
		TweenService:Create(v13, tweenInfo, {
			Size = UDim2.fromScale(1, 0)
		}):Play()
	end

	task.delay(0.5, function()
		data.Gui:Destroy()
	end)
end

local function stopCutscene(flag2: boolean?)
	local v13 = v5
	v5 = nil

	if v13 then
		v13.Help.Visible = false
		local currentCamera = workspace.CurrentCamera
		local character = localPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		local v14

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			v14 = humanoidRootPart.Position
		end

		if flag2 ~= true and currentCamera == v13.Camera and currentCamera.CameraType == Enum.CameraType.Scriptable and v14 then
			v6 = {
				Camera = v13.Camera,
				Type = v13.Type,
				FOV = v13.FOV,
				Subject = v13.Subject,
				Gui = v13.Gui,
				Top = v13.Top,
				Bottom = v13.Bottom,
				From = currentCamera.CFrame,
				FromFOV = currentCamera.FieldOfView,
				Offset = v13.CamOffset,
				T = 0
			}
			return
		end

		releaseCamera(v13, v13.CFrame) -- equivalent call inferred; original call site unknown

		if flag2 == true then
			v13.Gui:Destroy()
		else
			dropBars(v13)
		end
	elseif flag2 == true and v6 then
		local v14 = v6
		v6 = nil
		releaseCamera(v14) -- equivalent call inferred; original call site unknown
		v14.Gui:Destroy()
	end
end

local function startCutscene(data)
	local v13 = v5
	v5 = nil

	if v13 then
		v13.Help.Visible = false
		local _ = workspace.CurrentCamera
		local character = localPlayer.Character
		local humanoidRootPart

		if character then
			humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		end

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local _ = humanoidRootPart.Position
		end

		releaseCamera(v13, v13.CFrame) -- equivalent call inferred; original call site unknown
		v13.Gui:Destroy()
	elseif v6 then
		local v14 = v6
		v6 = nil
		releaseCamera(v14) -- equivalent call inferred; original call site unknown
		v14.Gui:Destroy()
	end

	local shrine = data.Shrine
	local currentCamera = workspace.CurrentCamera

	if typeof(shrine) ~= "Instance" or not (shrine:IsDescendantOf(workspace) and currentCamera) then
		return
	end

	local lightPad = shrine:FindFirstChild("LightPad")
	local darkPad = shrine:FindFirstChild("DarkPad")

	if not (lightPad and darkPad and lightPad:IsA("BasePart") and darkPad:IsA("BasePart")) then
		return
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ShrineFusionRitual"
	screenGui.DisplayOrder = 60
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	local top, bottom = letterbox(screenGui)
	local help = label(
		screenGui,
		"Help",
		"Stay on your pad and keep holding your animal. Moving away cancels fusion.",
		UDim2.fromScale(0.15, 0.795),
		UDim2.fromScale(0.7, 0.055),
		Color3.new(1, 1, 1)
	)
	help.TextStrokeTransparency = 0.3
	help.ZIndex = 6
	local character = localPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local position

	if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
		position = humanoidRootPart.Position
	end

	local v17 = {
		Id = data.SessionId,
		Tier = data.Tier,
		Model = shrine,
		Light = lightPad,
		Dark = darkPad,
		EndsAt = data.EndsAt,
		StartedAt = workspace:GetServerTimeNow(),
		Camera = currentCamera,
		Type = currentCamera.CameraType,
		FOV = currentCamera.FieldOfView,
		CFrame = currentCamera.CFrame,
		Subject = currentCamera.CameraSubject,
		CamOffset = 0,
		Gui = 0,
		Help = 0,
		Top = 0,
		Bottom = 0
	}
	local camOffset

	if position then
		camOffset = currentCamera.CFrame.Position - position
	else
		camOffset = currentCamera.CFrame.LookVector * -12 + createVector(0, 4, 0)
	end

	v17.CamOffset = camOffset
	v17.Gui = screenGui
	v17.Help = help
	v17.Top = top
	v17.Bottom = bottom
	v5 = v17
	currentCamera.CameraType = Enum.CameraType.Scriptable
	currentCamera.FieldOfView = 56
	local v19 = v2[shrine]

	if v19 and v19.BillboardsOn ~= false then
		v19.BillboardsOn = false

		for _, billboard2 in v19.Billboards do
			if billboard2.Parent then
				billboard2.Enabled = false
			end
		end
	end

	local v20 = recipeOf(data.Tier) -- equivalent call inferred; original call site unknown
	local begin = ShrineFusionSequence.Begin
	local lightUserId = data.LightUserId
	local playerByUserId

	if type(lightUserId) == "number" then
		playerByUserId = Players:GetPlayerByUserId(lightUserId)
	end

	local lightCharacter

	if playerByUserId then
		lightCharacter = playerByUserId.Character
	end

	local darkUserId = data.DarkUserId
	local playerByUserId2

	if type(darkUserId) == "number" then
		playerByUserId2 = Players:GetPlayerByUserId(darkUserId)
	end

	local darkCharacter

	if playerByUserId2 then
		darkCharacter = playerByUserId2.Character
	end

	local v21 = {
		Shrine = shrine,
		LightCharacter = lightCharacter,
		DarkCharacter = darkCharacter,
		EndsAt = data.EndsAt,
		Tier = data.Tier,
		FusedCategory = 0,
		Participant = true
	}
	local fusedCategory

	if v20 then
		fusedCategory = v20.Fused
	end

	v21.FusedCategory = fusedCategory
	begin(v21)
end

local function cleanup(p)
	local v13 = v2[p]

	if not v13 then
		return
	end

	v2[p] = nil

	for _, connection in v13.Connections do
		connection:Disconnect()
	end

	for _, v14 in v13.Owned do
		v14:Destroy()
	end

	if v5 and v5.Model == p then
		stopCutscene()
	end
end

local function register(model)
	if v2[model] or not (model:IsA("Model") and model:IsDescendantOf(workspace)) then
		return
	end

	local lightPad = model:FindFirstChild("LightPad")
	local darkPad = model:FindFirstChild("DarkPad")

	if not (lightPad and darkPad and lightPad:IsA("BasePart") and darkPad:IsA("BasePart")) then
		return
	end

	local v13 = {
		Model = model,
		Light = lightPad,
		Dark = darkPad,
		Owned = {},
		Connections = {},
		Pads = {},
		Billboards = {},
		BillboardsOn = true
	}
	v2[model] = v13
	local attachment = Instance.new("Attachment")
	attachment.Name = "FusionStatusAnchor"
	attachment.Position = lightPad.CFrame:PointToObjectSpace((lightPad.Position + darkPad.Position) / 2)
	attachment.Parent = lightPad
	table.insert(v13.Owned, attachment)
	local clone = fusionShrineBillboard:Clone()
	clone.Name = "PersonalFusionStatus"
	clone.Adornee = attachment
	clone.ResetOnSpawn = false
	clone.Enabled = true
	clone.Parent = playerGui
	table.insert(v13.Owned, clone)
	table.insert(v13.Billboards, clone)
	local card3 = clone:FindFirstChild("Card")
	assert(card3, clone:GetFullName() .. ".Card is missing")
	local inner3 = card3:FindFirstChild("Inner")
	assert(inner3, card3:GetFullName() .. ".Inner is missing")
	local content3 = inner3:FindFirstChild("Content")
	assert(content3, inner3:GetFullName() .. ".Content is missing")
	local divineColumn2 = content3:FindFirstChild("DivineColumn")
	assert(divineColumn2, content3:GetFullName() .. ".DivineColumn is missing")
	local status3 = divineColumn2:FindFirstChild("Status")
	assert(status3, divineColumn2:GetFullName() .. ".Status is missing")
	assert(status3:IsA("TextLabel"), status3:GetFullName() .. " must be a TextLabel")
	v13.Divine = status3
	local eternalColumn2 = content3:FindFirstChild("EternalColumn")
	assert(eternalColumn2, content3:GetFullName() .. ".EternalColumn is missing")
	local status4 = eternalColumn2:FindFirstChild("Status")
	assert(status4, eternalColumn2:GetFullName() .. ".Status is missing")
	assert(status4:IsA("TextLabel"), status4:GetFullName() .. " must be a TextLabel")
	v13.Eternal = status4
	local divine = v13.Divine
	divine.Text = "LOADING"
	local uIGradient3 = divine:FindFirstChildOfClass("UIGradient")
	local color = v8.AVAILABLE.Color

	if uIGradient3 and color then
		uIGradient3.Color = color
	end

	local eternal = v13.Eternal
	eternal.Text = "LOADING"
	local uIGradient4 = eternal:FindFirstChildOfClass("UIGradient")
	local color2 = v8.AVAILABLE.Color

	if uIGradient4 and color2 then
		uIGradient4.Color = color2
	end

	local vector2 = Vector2.new(520, 62)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "PersonalFusionHint"
	billboardGui.Adornee = attachment
	billboardGui.Size = UDim2.fromOffset(vector2.X, vector2.Y)
	billboardGui.StudsOffsetWorldSpace = createVector(0, 11.8, 0)
	billboardGui.MaxDistance = 85
	billboardGui.AlwaysOnTop = false
	billboardGui.ResetOnSpawn = false
	billboardGui.Parent = playerGui
	billboardGui.Enabled = false
	table.insert(v13.Owned, billboardGui)
	v13.Hint = billboardGui
	v13.Message = label(billboardGui, "Guidance", "", UDim2.new(), UDim2.fromScale(1, 1), Color3.fromRGB(226, 224, 236))
	v13.Message.TextStrokeTransparency = 0.25
	v13.Anim = {
		Center = (lightPad.Position + darkPad.Position) / 2
	}

	for k, v15 in { "Light", "Dark" } do
		local pad = v13[v15]
		local top = pad.Position.Y + pad.Size.Y / 2
		local part = Instance.new("Part")
		part.Name = "FusionGlowDisc" .. v15
		part.Shape = Enum.PartType.Cylinder
		part.Size = createVector(0.18, 15.6, 15.6)
		part.CFrame = CFrame.new(pad.Position.X, top + 0.07, pad.Position.Z) * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = v[v15]
		part.Transparency = 1
		part.Parent = model
		table.insert(v13.Owned, part)
		local pointLight = Instance.new("PointLight")
		pointLight.Color = v[v15]
		pointLight.Range = 16
		pointLight.Brightness = 0
		pointLight.Enabled = false
		pointLight.Parent = part
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Color = ColorSequence.new(v[v15])
		particleEmitter.LightEmission = 1
		particleEmitter.LightInfluence = 0
		particleEmitter.Lifetime = NumberRange.new(1.1, 2.2)
		particleEmitter.Speed = NumberRange.new(2, 4.5)
		particleEmitter.SpreadAngle = Vector2.new(24, 24)
		particleEmitter.Acceleration = createVector(0, 1.5, 0)
		particleEmitter.EmissionDirection = Enum.NormalId.Right
		particleEmitter.Rate = 0
		particleEmitter.Enabled = false
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(1, 0)
		})
		particleEmitter.Parent = part
		local orbs = {}

		for _ = 1, 3 do
			local part2 = Instance.new("Part")
			part2.Name = "FusionGlowOrb" .. v15
			part2.Shape = Enum.PartType.Ball
			part2.Size = createVector(0.7, 0.7, 0.7)
			part2.CFrame = CFrame.new(pad.Position.X, top + 1.3, pad.Position.Z)
			part2.Anchored = true
			part2.CanCollide = false
			part2.CanTouch = false
			part2.CanQuery = false
			part2.CastShadow = false
			part2.Material = Enum.Material.Neon
			part2.Color = v[v15]
			part2.Transparency = 1
			part2.Parent = model
			table.insert(v13.Owned, part2)
			table.insert(orbs, part2)
		end

		v13.Pads[v15] = {
			Pad = pad,
			Disc = part,
			Glow = pointLight,
			Embers = particleEmitter,
			Orbs = orbs,
			Top = top,
			Offset = (k - 1) * 2.1,
			DiscT = 1,
			LightT = 0,
			OrbA = 0,
			Goal = {
				Disc = 0.62,
				Breathe = 0.16,
				Light = 0.7,
				Orb = 0
			}
		}
	end

	local attachment2 = Instance.new("Attachment")
	attachment2.Parent = v13.Pads.Light.Disc
	local attachment3 = Instance.new("Attachment")
	attachment3.Parent = v13.Pads.Dark.Disc
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment2
	beam.Attachment1 = attachment3
	beam.CurveSize0 = 9
	beam.CurveSize1 = 9
	beam.Width0 = 0.9
	beam.Width1 = 0.9
	beam.Segments = 24
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Color = ColorSequence.new(v.Light, v.Dark)
	beam.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(0.5, 0.45),
		NumberSequenceKeypoint.new(1, 0.75)
	})
	beam.Parent = v13.Pads.Light.Disc
	v13.Arc = beam
	local part = Instance.new("Part")
	part.Name = "FusionGlowField"
	part.Size = createVector(46, 0.2, 46)
	part.CFrame = CFrame.new(v13.Anim.Center.X, v13.Pads.Light.Top - 0.4, v13.Anim.Center.Z)
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Transparency = 1
	part.Parent = model
	table.insert(v13.Owned, part)

	for _, v15 in { "Light", "Dark" } do
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particleEmitter.Color = ColorSequence.new(v[v15])
		particleEmitter.LightEmission = 1
		particleEmitter.LightInfluence = 0
		particleEmitter.Lifetime = NumberRange.new(4, 7)
		particleEmitter.Speed = NumberRange.new(0.6, 1.8)
		particleEmitter.Rate = 3.5
		particleEmitter.EmissionDirection = Enum.NormalId.Top
		particleEmitter.Size = NumberSequence.new(0.22)
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.15, 0.3),
			NumberSequenceKeypoint.new(0.8, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Parent = part
	end

	table.insert(v13.Connections, model.AncestryChanged:Connect(function()
		if not model:IsDescendantOf(workspace) then
			cleanup(model)
		end
	end))
	refresh() -- equivalent call inferred; original call site unknown
end

shrineFusion.Feedback.OnClientEvent:Connect(function(p)
	if type(p) == "table" and type(p.Message) == "string" then
		v7 = {
			Message = p.Message,
			Until = os.clock() + 4
		}
	end
end)
shrineFusion.Ritual.OnClientEvent:Connect(function(p)
	if type(p) ~= "table" then
		return
	end

	if p.Phase == "Started" then
		startCutscene(p)
	elseif not v5 or v5.Id == p.SessionId then
		if p.Phase == "Completed" then
			refresh() -- equivalent call inferred; original call site unknown

			if v5 then
				v5.PayoffAt = workspace:GetServerTimeNow()
				v5.Help.Visible = false
			end

			if not ShrineFusionSequence.Payoff(stopCutscene) then
				stopCutscene()
			end
		else
			ShrineFusionSequence.Cancel()
			stopCutscene()
		end
	end
end)
shrineFusion.StateChanged.OnClientEvent:Connect(function(instance, data)
	if type(data) ~= "table" or typeof(instance) ~= "Instance" then
		return
	end

	if data.Phase == "Ritual" then
		task.defer(function()
			if v5 or ShrineFusionSequence.IsPlaying() or not instance:IsDescendantOf(workspace) then
				return
			end

			local lightPad = instance:FindFirstChild("LightPad")
			local darkPad = instance:FindFirstChild("DarkPad")

			if not (lightPad and darkPad and lightPad:IsA("BasePart") and darkPad:IsA("BasePart")) then
				return
			end

			local v13 = recipeOf(data.Tier) -- equivalent call inferred; original call site unknown
			local begin = ShrineFusionSequence.Begin
			local v14 = {
				Shrine = instance,
				LightCharacter = 0,
				DarkCharacter = 0,
				EndsAt = 0,
				Tier = 0,
				FusedCategory = 0,
				Participant = false
			}
			local fusionUserId = lightPad:GetAttribute("FusionUserId")
			local playerByUserId

			if type(fusionUserId) == "number" then
				playerByUserId = Players:GetPlayerByUserId(fusionUserId)
			end

			local lightCharacter

			if playerByUserId then
				lightCharacter = playerByUserId.Character
			end

			v14.LightCharacter = lightCharacter
			local fusionUserId2 = darkPad:GetAttribute("FusionUserId")
			local playerByUserId2

			if type(fusionUserId2) == "number" then
				playerByUserId2 = Players:GetPlayerByUserId(fusionUserId2)
			end

			local darkCharacter

			if playerByUserId2 then
				darkCharacter = playerByUserId2.Character
			end

			v14.DarkCharacter = darkCharacter
			v14.EndsAt = data.EndsAt
			v14.Tier = data.Tier
			local fusedCategory

			if v13 then
				fusedCategory = v13.Fused
			end

			v14.FusedCategory = fusedCategory
			begin(v14)
		end)
	elseif data.Phase == "Committing" then
		if not v5 and ShrineFusionSequence.IsPlaying() then
			ShrineFusionSequence.Payoff()
		end
	elseif data.Phase == "Idle" and not v5 and ShrineFusionSequence.IsPlaying() and not ShrineFusionSequence.IsResolving() then
		ShrineFusionSequence.Cancel()
	end
end)
localPlayer.CharacterAdded:Connect(function()
	ShrineFusionSequence.Cancel()
	stopCutscene()
end)
local total = 0
RunService.RenderStepped:Connect(function(dt)
	if v5 then
		local currentCamera = workspace.CurrentCamera
		local serverTimeNow = workspace:GetServerTimeNow()

		if currentCamera == v5.Camera and v5.Model:IsDescendantOf(workspace) and (not (v5.EndsAt + 5 < serverTimeNow) or ShrineFusionSequence.IsResolving()) then
			local v13 = shotRig(v5)
			local cFrame, fieldOfView = camFrame(v5, v13, serverTimeNow, dt)
			currentCamera.CFrame = cFrame
			currentCamera.FieldOfView = fieldOfView
		else
			stopCutscene()
		end
	end

	if v6 then
		local v13 = v6
		local currentCamera = workspace.CurrentCamera

		if currentCamera == v13.Camera and currentCamera.CameraType == Enum.CameraType.Scriptable then
			v13.T += dt
			local v14 = smooth(math.clamp(v13.T / 0.9, 0, 1)) -- equivalent call inferred; original call site unknown
			local character = localPlayer.Character
			local humanoidRootPart

			if character then
				humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			end

			local v15

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
				v15 = humanoidRootPart.Position
			end

			local v16 = v15 or v13.From.Position - v13.Offset
			local cframe = CFrame.lookAt(v16 + v13.Offset, v16 + createVector(0, 2.2, 0))
			currentCamera.CFrame = v13.From:Lerp(cframe, v14)
			local fromFOV = v13.FromFOV
			currentCamera.FieldOfView = fromFOV + (v13.FOV - fromFOV) * v14

			if v14 >= 1 then
				v6 = nil
				releaseCamera(v13) -- equivalent call inferred; original call site unknown
				dropBars(v13)
			end
		else
			v6 = nil
			dropBars(v13)
		end
	end

	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local now = os.clock()
		local position = currentCamera.CFrame.Position

		for _, v13 in v2 do
			local anim = v13.Anim

			if not anim or (position - anim.Center).Magnitude > 180 then
				continue
			end

			local v14 = 1 - math.exp(-dt * 6)

			for _, v15 in { "Light", "Dark" } do
				local pad = v13.Pads[v15]
				local goal = pad.Goal
				local v16 = (math.sin(now * 1.7 + pad.Offset) + 1) * 0.5
				local discT = pad.DiscT
				pad.DiscT = discT + (goal.Disc + goal.Breathe * v16 - discT) * v14
				pad.Disc.Transparency = pad.DiscT
				local lightT = pad.LightT
				pad.LightT = lightT + (goal.Light - lightT) * v14
				pad.Glow.Brightness = pad.LightT
				pad.Glow.Enabled = pad.LightT > 0.05
				local orbA = pad.OrbA
				pad.OrbA = orbA + (goal.Orb - orbA) * v14
				local v17 = pad.OrbA > 0.02

				for k, orb in pad.Orbs do
					if v17 then
						local v18 = now * 1.3 + pad.Offset + k * (6.283185307179586 / #pad.Orbs)
						local v19 = 7.2 * (0.55 + 0.45 * pad.OrbA)
						orb.CFrame = CFrame.new(
							pad.Pad.Position.X + math.cos(v18) * v19,
							pad.Top + 1.3 + math.sin(now * 2.3 + k * 1.7) * 0.5,
							pad.Pad.Position.Z + math.sin(v18) * v19
						)
					end

					orb.Transparency = 1 - pad.OrbA * 0.85
				end
			end
		end
	end

	total += dt

	if total < 0.2 then
		return
	end

	total = 0
	local humanoidRootPart

	if localPlayer.Character then
		humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
	end

	local flag2 = false

	for k, v13 in v2 do
		if k:IsDescendantOf(workspace) and v13.Light:IsDescendantOf(k) and v13.Dark:IsDescendantOf(k) then
			local v14 = ShrineFusionSequence.ActiveShrine() == k
			setBillboards(v13, not v14) -- equivalent call inferred; original call site unknown
			local fusionPhase = k:GetAttribute("FusionPhase")
			local v16 = fusionPhase ~= "Disabled"
			v13.Arc.Enabled = not v14 and v16

			for _, v17 in { "Light", "Dark" } do
				local v18 = v13[v17]
				local pad = v13.Pads[v17]
				local fusionActive = v18:GetAttribute("FusionActive") == true
				local v19 = fusionActive and (fusionPhase == "Ritual" or fusionPhase == "Committing")
				local goal = pad.Goal

				if v14 then
					goal.Disc = 0.75
					goal.Breathe = 0.08
					goal.Light = 0.5
					goal.Orb = 0
					pad.Embers.Rate = 0
				elseif v16 then
					if v19 then
						goal.Disc = 0.12
						goal.Breathe = 0.05
						goal.Light = 3
						goal.Orb = 1
						pad.Embers.Rate = 26
					elseif fusionActive then
						goal.Disc = 0.3
						goal.Breathe = 0.08
						goal.Light = 1.8
						goal.Orb = 1
						pad.Embers.Rate = 15
					else
						goal.Disc = 0.62
						goal.Breathe = 0.16
						goal.Light = 0.7
						goal.Orb = 0
						pad.Embers.Rate = 4
					end
				else
					goal.Disc = 0.93
					goal.Breathe = 0.03
					goal.Light = 0
					goal.Orb = 0
					pad.Embers.Rate = 0
				end

				pad.Embers.Enabled = pad.Embers.Rate > 0
			end

			local divine = v13.Divine
			local v17

			if v3.Ready then
				v17 = v3.Divine
			end

			applyStatus(divine, v17) -- equivalent call inferred; original call site unknown
			local eternal = v13.Eternal
			local v18

			if v3.Ready then
				v18 = v3.Eternal
			end

			applyStatus(eternal, v18) -- equivalent call inferred; original call site unknown
			local message = nil
			local v19 = humanoidRootPart and humanoidRootPart:IsA("BasePart") and ShrinePadZone.ContainsPoint(
				v13.Light,
				humanoidRootPart.Position
			) and "Light" or humanoidRootPart and humanoidRootPart:IsA("BasePart") and ShrinePadZone.ContainsPoint(
				v13.Dark,
				humanoidRootPart.Position
			) and "Dark" or nil

			if v3.Ready and not v3.Enabled then
				message = "Shrine unavailable. Try again later."
			elseif v3.Ready and next(v3.Recipes or {}) == nil then
				message = "Shrine not ready. Try again later."
			elseif fusionPhase == "Mismatch" then
				message = "Both pets must be Divine, or both Eternal."
			elseif v19 and v7 and v7.Until > os.clock() then
				message = v7.Message
			elseif v19 then
				message = "Hold a " .. v19 .. " Divine or Eternal pet."
			end

			v13.Message.Text = message or ""
			v13.Hint.Enabled = v13.BillboardsOn and message ~= nil

			if humanoidRootPart and humanoidRootPart:IsA("BasePart") and (humanoidRootPart.Position - v13.Light.Position).Magnitude < 100 then
				flag2 = true
			end
		else
			cleanup(k)
		end
	end

	if flag2 then
		local now = os.clock()

		if v4 <= now then
			v4 = os.clock() + 5
			refresh() -- equivalent call inferred; original call site unknown
		end
	end
end)
CollectionService:GetInstanceAddedSignal("ShrineFusion"):Connect(register)
CollectionService:GetInstanceRemovedSignal("ShrineFusion"):Connect(cleanup)
workspace.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "LightPad" or descendant.Name == "DarkPad" then
		local parent = descendant.Parent

		if parent and CollectionService:HasTag(parent, "ShrineFusion") then
			task.defer(register, parent)
		end
	end
end)

for _, v13 in CollectionService:GetTagged("ShrineFusion") do
	register(v13)
end

return table.freeze({})