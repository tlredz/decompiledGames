local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local SoulvesterGuardCinematic = require(script.Parent.SoulvesterGuardCinematic)
local StareFit = require(ReplicatedStorage.Modules.StareFit)
local success, result = pcall(function()
	return require(ReplicatedStorage.SharedUtils.HapticEffectsController)
end)
local v = success and result or nil
local success2, result2 = pcall(function()
	return require(ReplicatedStorage.SharedUtils.Audio)
end)
local v2 = success2 and result2 or nil
local v3 = {
	"jaw",
	"mouth",
	"teeth",
	"tooth",
	"tongue",
	"antenna"
}
local v4 = {
	dread = {
		duration = 4.2,
		fadeIn = 0.08,
		fadeOut = 0.6,
		scale = 1.45,
		opacity = 0.95,
		fovPunch = 14,
		shake = 0.8,
		hapticIn = "ImpactPunch",
		anim = "Idle",
		vignette = Color3.fromRGB(5, 2, 8),
		vignetteAlpha = 0.7,
		slideIn = 0.35,
		leanFar = 2.6,
		leanNear = 1.1,
		swayHz = 1.4,
		rollAmp = 0.06,
		drift = { 0, 0 }
	},
	dream = {
		duration = 5.6,
		fadeIn = 1.1,
		fadeOut = 1.2,
		scale = 1.45,
		opacity = 0.95,
		anim = "Idle",
		fovPunch = 0,
		shake = 0,
		hapticIn = "Swell",
		hapticMid = "Heartbeat",
		vignette = Color3.fromRGB(10, 8, 28),
		vignetteAlpha = 0.65,
		slideIn = 1.1,
		leanFar = 2.6,
		leanNear = 1.1,
		swayHz = 0.8,
		rollAmp = 0.1,
		drift = { 0, 0 }
	}
}
local color = Color3.fromRGB(105, 105, 112)
local color2 = Color3.fromRGB(235, 235, 240)

local function findStareHead(clone)
	local headPart = clone:FindFirstChild("HeadPart")

	if headPart and headPart:IsA("ObjectValue") and headPart.Value and headPart.Value:IsA("BasePart") then
		return headPart.Value
	end

	local head = clone:FindFirstChild("Head", true)

	if head and head:IsA("BasePart") then
		return head
	end

	return clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)
end

local function findStareHand(folder)
	local rightHand = folder:FindFirstChild("RightHand", true)

	if rightHand and rightHand:IsA("BasePart") then
		return rightHand
	end

	local v5 = 0
	local v6 = nil

	for _, part in ipairs(folder:GetDescendants()) do
		local name = part.Name:lower()

		if not part:IsA("BasePart") or not name:find("hand") or name:find("handle") then
			continue
		end

		local v7 = part.Size.X * part.Size.Y * part.Size.Z

		if not (v5 < v7) then
			continue
		end

		v6 = part
		v5 = v7
	end

	return v6
end

local function nameIsKept(instance)
	local name = instance.Name:lower()

	for _, v5 in ipairs(v3) do
		if name:find(v5, 1, true) then
			return true
		end
	end

	return false
end

local function isKept(part, stareHead, p, p2)
	if part == stareHead or part:IsDescendantOf(stareHead) or p and nameIsKept(part) then
		return true
	end

	if p2 <= 0 then
		return false
	end

	local pointToObjectSpace = stareHead.CFrame:PointToObjectSpace(part.Position)
	local halfSize = stareHead.Size / 2
	return math.abs(pointToObjectSpace.X) <= halfSize.X + p2 and math.abs(pointToObjectSpace.Y) <= halfSize.Y + p2 and math.abs(pointToObjectSpace.Z) <= halfSize.Z + p2
end

local function poseStareRig(folder, anim)
	local animations = folder:FindFirstChild("Animations")
	local animation = animations and animations:FindFirstChild(anim or "Idle")

	if not (animation and animation:IsA("Animation")) then
		return false
	end

	for _, part in ipairs(folder:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = part.Name == "HumanoidRootPart" or part.Name == "RootPart"
		end
	end

	local v5 = folder:FindFirstChildWhichIsA("Animator", true)

	if not v5 then
		local parent = folder:FindFirstChildOfClass("Humanoid")

		if not parent then
			parent = Instance.new("AnimationController")
			parent.Parent = folder
		end

		v5 = Instance.new("Animator")
		v5.Parent = parent
	end

	local success3, result3 = pcall(function()
		return v5:LoadAnimation(animation)
	end)

	if success3 and result3 then
		result3.Looped = true
		result3:Play(0)
		return true
	else
		return false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playHaptic(p)
	if v and p then
		pcall(function()
			v:Play(p)
		end)
	end
end

local fieldOfView = nil
local tweens = {}
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelPunchTweens()
	for _, v5 in ipairs(tweens) do
		v5:Cancel()
	end

	table.clear(tweens)
end

local function hitCamera(fovPunch, shake)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera or SoulvesterGuardCinematic.isActive() or fovPunch <= 0 and shake <= 0 then
		return
	end

	if fovPunch > 0 then
		if fieldOfView == nil then
			fieldOfView = currentCamera.FieldOfView
		end

		count += 1
		local v5 = count
		cancelPunchTweens() -- equivalent call inferred; original call site unknown
		local tween = TweenService:Create(
			currentCamera,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				FieldOfView = fieldOfView + fovPunch
			}
		)
		table.insert(tweens, tween)
		tween:Play()
		task.delay(0.1, function()
			if v5 ~= count or not currentCamera.Parent then
				return
			end

			local tween2 = TweenService:Create(
				currentCamera,
				TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					FieldOfView = fieldOfView
				}
			)
			table.insert(tweens, tween2)
			tween2.Completed:Once(function(p)
				if v5 == count and p == Enum.PlaybackState.Completed then
					fieldOfView = nil
					table.clear(tweens)
				end
			end)
			tween2:Play()
		end)
	end

	if shake <= 0 then
		return
	end

	local v5 = os.clock() + 0.3
	pcall(function()
		RunService:UnbindFromRenderStep("TwistedStareShake")
	end)
	RunService:BindToRenderStep("TwistedStareShake", Enum.RenderPriority.Camera.Value + 1, function()
		local v6 = v5 - os.clock()

		if v6 <= 0 or not currentCamera.Parent then
			pcall(function()
				RunService:UnbindFromRenderStep("TwistedStareShake")
			end)
			return
		end

		local v7 = (v6 / 0.3) ^ 2 * shake
		currentCamera.CFrame *= CFrame.new((math.random() - 0.5) * v7, (math.random() - 0.5) * v7, 0)
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playArrive()
	if v2 then
		task.spawn(pcall, v2.PlayOne, v2, "Sounds.UI.Alerts.Spotted")
	end
end

return {
	RenderObject = function(data)
		local rig = data and data.rig

		if not (rig and rig:IsA("Model")) then
			return
		end

		local v5 = v4[data.style] or v4.dream
		local v6 = {}

		for k, v7 in pairs(v5) do
			v6[k] = v7
		end

		if type(data.tune) == "table" then
			for k, v7 in pairs(data.tune) do
				if v6[k] ~= nil then
					v6[k] = v7
				end
			end
		end

		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

		if not playerGui then
			return
		end

		local twistedStareGui = playerGui:FindFirstChild("TwistedStareGui")

		if twistedStareGui then
			twistedStareGui:Destroy()
		end

		local success3, result3 = pcall(function()
			local clone = rig:Clone()
			local resolved = StareFit.resolve(rig.Name)
			local stareHead = findStareHead(clone)
			local v7 = true

			if resolved.hand > 0 and math.random() < resolved.hand then
				local stareHand = findStareHand(clone)

				if stareHand then
					stareHead = stareHand
					v7 = false
				else
					warn("[TwistedStare]", rig.Name, "rolled a hand shot but the rig has no hand part")
				end
			end

			if not stareHead then
				clone:Destroy()
				return
			end

			local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart") or clone.PrimaryPart
			local v8 = math.max(stareHead.Size.X, stareHead.Size.Y, stareHead.Size.Z)
			local v9 = v8 * resolved.reach
			local count2 = 0

			for _, part in ipairs(clone:GetDescendants()) do
				if not part:IsA("BasePart") then
					continue
				end

				if isKept(part, stareHead, v7, v9) then
					count2 += 1
				else
					part.Transparency = 1
				end
			end

			print(string.format(
				"[TwistedStare] %s: %s shot, %d part(s) kept (reach %.1f, yaw %d, edge %+.1f)",
				rig.Name,
				v7 and "head" or "hand",
				count2,
				resolved.reach,
				math.round(resolved.yaw),
				resolved.edge
			))
			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "TwistedStareGui"
			screenGui.ResetOnSpawn = false
			screenGui.IgnoreGuiInset = true
			screenGui.DisplayOrder = 40
			local frame = Instance.new("Frame")
			frame.BackgroundColor3 = v6.vignette
			frame.BackgroundTransparency = 1
			frame.BorderSizePixel = 0
			frame.Size = UDim2.fromScale(1, 1)
			frame.Parent = screenGui
			local v10 = math.clamp(v6.scale, 0.2, 3)
			local v11 = (1 - v10) / 2 + resolved.edge * 0.5
			local v12 = (1 - v10) / 2
			local v13 = not (math.abs(resolved.edge) > 0.01) and 0 or math.sign(resolved.edge)
			local viewportFrame = Instance.new("ViewportFrame")
			viewportFrame.Size = UDim2.fromScale(v10, v10)
			viewportFrame.Position = UDim2.fromScale(v11 + v13 * 0.5, v12)
			viewportFrame.BackgroundColor3 = Color3.new(0, 0, 0)
			viewportFrame.BackgroundTransparency = 1
			viewportFrame.ImageTransparency = 1
			viewportFrame.ImageColor3 = Color3.new(1, 1, 1)
			viewportFrame.Ambient = color
			viewportFrame.LightColor = color2
			viewportFrame.LightDirection = createVector(-0.3, -0.6, -1)
			viewportFrame.Parent = screenGui
			local imageTransparency = 1 - math.clamp(tonumber(v6.opacity) or 0.95, 0.05, 1)
			local worldModel = Instance.new("WorldModel")
			worldModel.Parent = viewportFrame
			clone.Parent = worldModel
			local camera = Instance.new("Camera")
			camera.Parent = viewportFrame
			viewportFrame.CurrentCamera = camera
			screenGui.Parent = playerGui
			playArrive() -- equivalent call inferred; original call site unknown
			playHaptic(v6.hapticIn) -- equivalent call inferred; original call site unknown
			hitCamera(v6.fovPunch or 0, v6.shake or 0)
			TweenService:Create(
				viewportFrame,
				TweenInfo.new(v6.fadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					ImageTransparency = imageTransparency
				}
			):Play()
			TweenService:Create(frame, TweenInfo.new(v6.fadeIn), {
				BackgroundTransparency = v6.vignetteAlpha
			}):Play()
			poseStareRig(clone, v6.anim)
			local cframe = CFrame.fromAxisAngle(createVector(0, 1, 0), (math.rad(resolved.yaw)))
			local v15 = not v7 and 0 or resolved.lift

			if v7 or not humanoidRootPart then
				humanoidRootPart = stareHead
			end

			local v16 = v6.duration - v6.fadeOut
			local v17 = math.max(tonumber(v6.slideIn) or 0.35, 0.01)

			if v6.hapticMid then
				task.delay(v16 * 0.5, function()
					if screenGui.Parent then
						playHaptic(v6.hapticMid) -- equivalent call inferred; original call site unknown
					end
				end)
			end

			local total = 0
			local renderSteppedConnection = nil
			renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
				total += dt

				if total >= v6.duration or not screenGui.Parent then
					renderSteppedConnection:Disconnect()
					return
				end

				local position = stareHead.Position
				local vector2 = cframe:VectorToWorldSpace(humanoidRootPart.CFrame.LookVector)
				local v18 = math.clamp((total - v6.fadeIn) / math.max(v16 - v6.fadeIn, 0.01), 0, 1)
				local v19 = v18 * v18 * (3 - v18 * 2)
				local v20 = v8 * (v6.leanFar - (v6.leanFar - v6.leanNear) * v19) * resolved.zoom
				local cross = vector2:Cross(createVector(0, 1, 0))
				local v21 = cross * v8 * resolved.shift
				local v22 = math.sin(total * v6.swayHz) * v8 * 0.12
				local v23 = math.sin(total * v6.swayHz * 1.5) * v8 * 0.06
				local v24 = position + vector2 * v20 + createVector(0, 1, 0) * v23 + cross * v22 + v21
				local v25 = position - createVector(0, 1, 0) * v8 * v15 + v21
				camera.CFrame = CFrame.lookAt(v24, v25) * CFrame.Angles(0, 0, math.sin(total * 0.9) * v6.rollAmp)
				local v26 = math.clamp((total - v6.fadeIn) / 0.8, 0, 1)
				local v27 = math.clamp((v16 - total) / 0.8, 0, 1)
				local v28 = v26 * v26 * (3 - v26 * 2) * (v27 * v27 * (3 - v27 * 2))
				local v29

				if v13 == 0 then
					v29 = 0
				else
					local v30 = 1 - math.clamp(total / v17, 0, 1)
					local v31 = math.clamp((total - v16) / math.max(v6.fadeOut, 0.01), 0, 1)
					v29 = v13 * 0.5 * (v30 ^ 3 + v31 * v31)
				end

				viewportFrame.Position = UDim2.fromScale(
					v11 + v29 + v28 * v6.drift[1] * math.sin(total * 0.73),
					v12 + v28 * v6.drift[2] * math.sin(total * 0.52 + 1.3)
				)
			end)
			task.delay(v16, function()
				if screenGui.Parent then
					TweenService:Create(
						viewportFrame,
						TweenInfo.new(v6.fadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							ImageTransparency = 1
						}
					):Play()
					TweenService:Create(frame, TweenInfo.new(v6.fadeOut), {
						BackgroundTransparency = 1
					}):Play()
				end
			end)
			Debris:AddItem(screenGui, v6.duration + 0.3)
		end)

		if not success3 then
			warn("[TwistedStare]", result3)
		end
	end
}