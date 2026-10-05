local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local Effect = require(game.ReplicatedStorage.Effect)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local localPlayer = Players.LocalPlayer
local frozen = table.freeze({
	"ColosseumBonusMoments.BF_Colosseum_Target_Shatter_01",
	"ColosseumBonusMoments.BF_Colosseum_Target_Shatter_02",
	"ColosseumBonusMoments.BF_Colosseum_Target_Shatter_03",
	"ColosseumBonusMoments.BF_Colosseum_Target_Shatter_04",
	"ColosseumBonusMoments.BF_Colosseum_Target_Shatter_05"
})
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 205, 60)
local color2 = Color3.fromRGB(220, 90, 70)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = {}
local positions = {}
local v6 = {}
local v7 = {}
local renderSteppedConnection = nil
local v8 = false
local v9 = nil
local v10 = nil
local v11 = nil
local v12 = nil

local function playCrowdSound(soundId: string)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = 0.5
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	task.delay(6, function()
		if sound.Parent ~= nil then
			sound:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startTicking()
	if v9 ~= nil then
		return
	end

	local v13 = Sound:Play("ColosseumBonusMoments.BF_TargetChallenge_ClockTicking_01")
	v13.Looped = true
	v9 = v13
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopTicking()
	if v9 ~= nil then
		Sound:Kill(v9)
		v9 = nil
	end
end

local function addTargetBillboard(basePart)
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "BillboardGui"
	billboardGui.Active = true
	billboardGui.ClipsDescendants = true
	billboardGui.LightInfluence = 1
	billboardGui.MaxDistance = 800
	billboardGui.Size = UDim2.fromScale(12, 12)
	billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "ImageLabel"
	imageLabel.AutomaticSize = Enum.AutomaticSize.Y
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://79077297788441"
	imageLabel.ScaleType = Enum.ScaleType.Crop
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
	imageLabel.Parent = billboardGui
	billboardGui.Parent = basePart
	local size = billboardGui.Size
	local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local tweenInfo3 = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	billboardGui.Size = UDim2.fromScale(size.X.Scale * 1.7, size.Y.Scale * 1.7)
	imageLabel.ImageTransparency = 1
	TweenService:Create(billboardGui, tweenInfo2, {
		Size = size
	}):Play()
	TweenService:Create(imageLabel, tweenInfo3, {
		ImageTransparency = 0
	}):Play()
	local frame = Instance.new("Frame")
	frame.Name = "Flash"
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 0.15
	frame.BorderSizePixel = 0
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = 10
	frame.Parent = billboardGui
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(1, 0)
	uICorner.Parent = frame
	TweenService:Create(frame, tweenInfo3, {
		BackgroundTransparency = 1
	}):Play()
	task.delay(0.35, function()
		frame:Destroy()
	end)
end

local function revealTarget(basePart)
	local function reveal(instance)
		if instance:IsA("BasePart") then
			local ownerTransparency = instance:GetAttribute("OwnerTransparency")

			if typeof(ownerTransparency) == "number" then
				instance.Transparency = ownerTransparency
			end
		elseif instance:IsA("Decal") then
			local ownerTransparency = instance:GetAttribute("OwnerTransparency")

			if typeof(ownerTransparency) == "number" then
				instance.Transparency = ownerTransparency
			end
		end
	end

	reveal(basePart)

	for _, descendant in basePart:GetDescendants() do
		reveal(descendant)
	end

	if basePart:GetAttribute("NeedsBillboard") == true then
		if not basePart:IsA("BasePart") then
			basePart = basePart:FindFirstChildWhichIsA("BasePart", true)
		end

		if basePart ~= nil then
			addTargetBillboard(basePart)
		end
	end
end

local function setFill(value: number, color3: Color3)
	if v2 == nil then
		return
	end

	v2.BackgroundColor3 = color3
	TweenService:Create(v2, tweenInfo, {
		Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setTimer(p: number)
	if v3 == nil then
		return
	end

	v3.Text = `{p}s`
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setDecals(instance, flag: boolean)
	local decal1 = instance:FindFirstChild("Decal1")
	local decal2 = instance:FindFirstChild("Decal2")

	if decal1 ~= nil and decal1:IsA("Decal") then
		decal1.Transparency = flag and 1 or 0
	end

	if decal2 ~= nil and decal2:IsA("Decal") then
		decal2.Transparency = flag and 0 or 1
	end
end

local function updateSpectators()
	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	local position = currentCamera.CFrame.Position

	for _, v13 in v5 do
		local v14 = positions[v13]

		if v14 == nil then
			continue
		end

		local v15 = v14 + Vector3.new(0, v6[v13] or 0, 0)
		local vector2 = Vector3.new(position.X - v15.X, 0, position.Z - v15.Z)

		if not (vector2.Magnitude < 0.01) then
			v13.CFrame = CFrame.lookAt(v15, v15 + vector2)
		end
	end
end

local function jumpSpectator(instance)
	if v7[instance] then
		return
	end

	v7[instance] = true
	setDecals(instance, true) -- equivalent call inferred; original call site unknown
	local v13 = math.random(2, 3)
	local v14 = 1.5 * (0.7 + math.random() * 0.40000000000000013)
	local v15 = 0.28 * v13
	local lastTime = os.clock()

	while true do
		local v16 = os.clock() - lastTime

		if v15 <= v16 then
			break
		end

		local v17 = v16 % 0.28 / 0.28
		v6[instance] = math.sin(v17 * 3.141592653589793) * v14
		task.wait()
	end

	v6[instance] = 0
	setDecals(instance, false) -- equivalent call inferred; original call site unknown
	v7[instance] = nil
end

local function jumpAllSpectators()
	for _, v13 in v5 do
		task.delay(math.random() * 0.35, jumpSpectator, v13)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerSpectator(instance)
	instance.Anchored = true
	table.insert(v5, instance)
	positions[instance] = instance.Position
	setDecals(instance, false) -- equivalent call inferred; original call site unknown
end

local function showSpectators()
	if not v8 or v4 ~= nil then
		return
	end

	local spectators = script:FindFirstChild("Spectators")
	local spectatorSpawns = script:FindFirstChild("SpectatorSpawns")

	if spectators == nil or spectatorSpawns == nil then
		return
	end

	local children = {}

	for _, child in spectators:GetChildren() do
		if child:IsA("Model") or child:IsA("BasePart") then
			table.insert(children, child)
		end
	end

	local v13 = {}

	for _, part in spectatorSpawns:GetChildren() do
		if part:IsA("BasePart") then
			table.insert(v13, part)
		end
	end

	if #children == 0 or #v13 == 0 then
		return
	end

	for i = #v13, 2, -1 do
		local v14 = math.random(1, i)
		local v15 = v13[v14]
		local v16 = v13[i]
		v13[i] = v15
		v13[v14] = v16
	end

	local v14 = math.clamp(math.floor(#v13 * 0.8 + 0.5), 0, #v13)
	local model = Instance.new("Model")
	model.Name = "CrowdSpectators"
	model.Parent = workspace
	v4 = model
	v5 = {}
	positions = {}
	v6 = {}
	v7 = {}

	for i = 1, v14 do
		local clone = children[math.random(1, #children)]:Clone()

		if clone:IsA("Model") or clone:IsA("BasePart") then
			clone:PivotTo(v13[i].CFrame)
		end

		clone.Parent = model

		if clone:IsA("BasePart") and clone:FindFirstChild("Decal1") ~= nil and clone:FindFirstChild("Decal2") ~= nil then
			registerSpectator(clone) -- equivalent call inferred; original call site unknown
		end

		for _, part in clone:GetDescendants() do
			if not (part:IsA("BasePart") and part:FindFirstChild("Decal1") ~= nil and part:FindFirstChild("Decal2") ~= nil) then
				continue
			end

			registerSpectator(part) -- equivalent call inferred; original call site unknown
		end
	end

	if renderSteppedConnection == nil then
		renderSteppedConnection = RunService.RenderStepped:Connect(updateSpectators)
	end
end

local function hideSpectators()
	if renderSteppedConnection ~= nil then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	v5 = {}
	positions = {}
	v6 = {}
	v7 = {}

	if v4 ~= nil then
		v4:Destroy()
		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyGauge()
	if v ~= nil then
		v:Destroy()
		v = nil
		v2 = nil
		v3 = nil
	end
end

local function makeGauge()
	if v ~= nil then
		return
	end

	local part = Instance.new("Part")
	part.Name = "Part"
	part.Anchored = true
	part.AudioCanCollide = false
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = CFrame.new(-1928.82, 34.9161, -3012.72, 0.743146, 0, -0.66913, 0, 1, 0, 0.66913, 0, 0.743146)
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.EnableFluidForces = false
	part.Size = createVector(1, 1, 1)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.Transparency = 1
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "BillboardGui"
	billboardGui.Active = true
	billboardGui.AlwaysOnTop = true
	billboardGui.ClipsDescendants = true
	billboardGui.LightInfluence = 1
	billboardGui.MaxDistance = 750
	billboardGui.Size = UDim2.fromScale(75, 15)
	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(84, 72, 57)
	frame.BorderColor3 = Color3.new()
	frame.BorderSizePixel = 0
	frame.Position = UDim2.fromScale(0.5, 0.5)
	frame.Size = UDim2.fromScale(0.9, 0.9)
	local frame2 = Instance.new("Frame")
	frame2.Name = "stroke"
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.BackgroundColor3 = Color3.fromRGB(177, 151, 99)
	frame2.BorderColor3 = Color3.new()
	frame2.BorderSizePixel = 0
	frame2.Position = UDim2.fromScale(0.5, 0.5)
	frame2.Size = UDim2.fromScale(1.02, 1.1)
	frame2.ZIndex = -1
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "bar"
	frame3.AnchorPoint = Vector2.new(0, 0.5)
	frame3.BackgroundColor3 = Color3.fromRGB(211, 190, 150)
	frame3.BorderColor3 = Color3.new()
	frame3.BorderSizePixel = 0
	frame3.Position = UDim2.fromScale(0, 0.5)
	frame3.Size = UDim2.fromScale(0.5, 1)
	frame3.Parent = frame
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "timer"
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new(
		"rbxasset://fonts/families/SourceSansPro.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.Size = UDim2.fromScale(0.5, 0.8)
	textLabel.Text = "30s"
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = frame
	frame.Parent = billboardGui
	billboardGui.Parent = part
	part.Parent = workspace
	v = part
	v2 = frame3
	v3 = textLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function emit(emitter)
	local emitCount = emitter:GetAttribute("EmitCount")
	emitter:Emit(typeof(emitCount) ~= "number" and 15 or emitCount)
end

local function emitAll(emitter)
	if emitter:IsA("ParticleEmitter") then
		emit(emitter) -- equivalent call inferred; original call site unknown
	end

	for _, emitter2 in emitter:GetDescendants() do
		if not emitter2:IsA("ParticleEmitter") then
			continue
		end

		emit(emitter2) -- equivalent call inferred; original call site unknown
	end
end

local function playBreak(cFrame: CFrame)
	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local v13 = ((humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart")) and createVector(0, 1, 0) or (cFrame.Position - humanoidRootPart.Position).Unit) * 60
	local effects = workspace:FindFirstChild("Effects") or workspace
	local targetFragments = script:FindFirstChild("TargetFragments")

	if targetFragments ~= nil and targetFragments:IsA("Model") then
		local clone = targetFragments:Clone()
		clone:PivotTo(cFrame)

		for _, part in clone:GetChildren() do
			if not part:IsA("BasePart") then
				continue
			end

			local v14 = 0.5 + math.random() * 0.5
			part.AssemblyLinearVelocity = 0.6 * v13 * v14
			part.AssemblyAngularVelocity = 0.2 * v13 * v14
		end

		clone.Parent = effects
		task.delay(3, function()
			clone:Destroy()
		end)
	end

	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.CFrame = cFrame
	part.Parent = effects
	local targetBreak = script:FindFirstChild("TargetBreak")

	if targetBreak ~= nil then
		local clone = targetBreak:Clone()
		clone.Parent = part
		emitAll(clone)
	end

	Sound:Play(frozen[math.random(1, #frozen)])
	task.delay(3, function()
		part:Destroy()
	end)
end

local function linearMove(object, cframe: CFrame, cframe2: CFrame, p: number)
	local total = 0

	while total < p do
		object:SetCFrame(cframe:Lerp(cframe2, total / p))
		total += RunService.RenderStepped:Wait()
	end

	object:SetCFrame(cframe2)
end

local function playIntro(cframe: CFrame, cframe2: CFrame, cframe3: CFrame, cframe4: CFrame)
	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	local v13 = CameraController.new(currentCamera, 1, 0.4)
	v13:SetCFrame(cframe)
	playCrowdSound("rbxassetid://126615573673174")
	jumpAllSpectators()
	task.delay(1, jumpAllSpectators)
	linearMove(v13, cframe, cframe2, 2)
	linearMove(v13, cframe3, cframe4, 2)
	v13:FadeOut(0.6)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playFlee(cframe: CFrame)
	Effect.new("Jitte.SmokeTeleport"):play({
		NewPos = cframe,
		PrevPos = cframe + createVector(0, 3, 0)
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideRoses()
	if v10 ~= nil then
		v10:Destroy()
		v10 = nil
	end
end

local function throwRoses()
	local rose = script:FindFirstChild("Rose")

	if rose == nil or not rose:IsA("BasePart") or #v5 == 0 then
		return
	end

	local character = localPlayer.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil or not humanoidRootPart:IsA("BasePart") then
		return
	end

	local position = humanoidRootPart.Position
	local model = Instance.new("Model")
	model.Name = "CrowdRoses"
	model.Parent = workspace
	v10 = model
	local vector2 = Vector3.new(0, -workspace.Gravity, 0)

	for i = 1, 30 do
		task.delay(i / 30 * 3, function()
			if v10 ~= model then
				return
			end

			local currentCamera = workspace.CurrentCamera

			if currentCamera == nil then
				return
			end

			local position2 = currentCamera.CFrame.Position
			local v13 = {}

			for _, v14 in v5 do
				if (v14.Position - position2).Magnitude <= 75 then
					table.insert(v13, v14)
				end
			end

			if #v13 == 0 then
				return
			end

			local v14 = v13[math.random(1, #v13)].Position + createVector(0, 2, 0)
			local v15 = position + Vector3.new((math.random() * 2 - 1) * 40, 0, (math.random() * 2 - 1) * 40)
			local v16 = 2 * (0.85 + math.random() * 0.3)
			local assemblyLinearVelocity = (v15 - v14 - vector2 * 0.5 * v16 * v16) / v16
			local clone = rose:Clone()
			clone.CFrame = CFrame.new(v14) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
			clone.Anchored = false
			clone.CanCollide = false
			clone.AssemblyLinearVelocity = assemblyLinearVelocity
			clone.AssemblyAngularVelocity = Vector3.new(
				math.random() * 8 - 4,
				math.random() * 8 - 4,
				math.random() * 8 - 4
			)
			clone.Parent = model
			task.delay(5, function()
				clone:Destroy()
			end)
		end)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reset()
	v8 = false
	stopTicking() -- equivalent call inferred; original call site unknown
	destroyGauge() -- equivalent call inferred; original call site unknown
	hideSpectators()
	hideRoses() -- equivalent call inferred; original call site unknown
end

local function playFinale()
	throwRoses()
	playCrowdSound("rbxassetid://126615573673174")
	jumpAllSpectators()
	task.delay(1.5, jumpAllSpectators)
	local currentCamera = workspace.CurrentCamera

	if currentCamera == nil or v11 == nil or v12 == nil then
		task.wait(3)
		task.delay(1, reset)
	else
		local v13 = CameraController.new(currentCamera, 1, 0.4)
		v13:SetCFrame(v11)
		linearMove(v13, v11, v12, 3)
		v13:FadeOut(0.6)
		task.delay(1.6, reset)
	end
end

return {
	OnLoad = function(p)
		p.Trove:Add(reset)
	end,
	RemoteEvents = {
		ShowTarget = function(_, instance)
			if typeof(instance) == "Instance" then
				revealTarget(instance)
			end
		end,
		Intro = function(_, p, p2, p3, p4)
			if typeof(p) ~= "CFrame" or typeof(p2) ~= "CFrame" or typeof(p3) ~= "CFrame" or typeof(p4) ~= "CFrame" then
				return
			end

			v11 = p
			v12 = p2
			v8 = true
			showSpectators()
			task.spawn(playIntro, p, p2, p3, p4)
		end,
		Started = function(_)
			v8 = true
			makeGauge()
			setFill(0, color)
			setTimer(0) -- equivalent call inferred; original call site unknown
			showSpectators()
			startTicking() -- equivalent call inferred; original call site unknown
		end,
		Hit = function(_, p)
			setFill(p, color)
			playCrowdSound("rbxassetid://126615573673174")
			jumpAllSpectators()
		end,
		Miss = function(_, p)
			setFill(p, color2)
			playCrowdSound("rbxassetid://140141868547789")
		end,
		Flee = function(_, newPos)
			if typeof(newPos) == "CFrame" then
				playFlee(newPos) -- equivalent call inferred; original call site unknown
			end
		end,
		Time = function(_, p)
			if v3 == nil then
				return
			end

			v3.Text = `{p}s`
		end,
		Succeeded = function(_)
			v8 = false
			stopTicking() -- equivalent call inferred; original call site unknown
			setFill(1, color)
			setTimer(0) -- equivalent call inferred; original call site unknown
			Sound:Play("ColosseumBonusMoments.BF_Target_Challenge_Success_Crowd_01")
			task.spawn(playFinale)
		end,
		Failed = function(_)
			Sound:Play("ColosseumBonusMoments.BF_Target_Challenge_Failure_Crowd_01")
			reset() -- equivalent call inferred; original call site unknown
		end,
		Break = function(_, cFrame)
			playBreak(cFrame)
		end
	}
}