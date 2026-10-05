local createVector = vector.create
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local v = {
	Enum.CoreGuiType.Backpack,
	Enum.CoreGuiType.Chat,
	Enum.CoreGuiType.Health,
	Enum.CoreGuiType.PlayerList,
	Enum.CoreGuiType.EmotesMenu
}
local screenGuis = {}
local v2 = {}
local v3 = 0

local function hideInterface()
	v3 += 1

	if v3 > 1 then
		return
	end

	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	if playerGui then
		for _, screenGui in playerGui:GetDescendants() do
			if not (screenGui:IsA("ScreenGui") and screenGui.Enabled) then
				continue
			end

			screenGui.Enabled = false
			table.insert(screenGuis, screenGui)
		end
	end

	for _, v4 in v do
		local v5 = v4
		local success, result = pcall(function()
			return StarterGui:GetCoreGuiEnabled(v5)
		end)

		if not (success and result) then
			continue
		end

		v2[v4] = true
		local v6 = v4
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v6, false)
		end)
	end
end

local function showInterface()
	v3 = math.max(v3 - 1, 0)

	if v3 > 0 then
		return
	end

	for _, v4 in screenGuis do
		if v4.Parent then
			v4.Enabled = true
		end
	end

	table.clear(screenGuis)

	for k in v2 do
		local v4 = k
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v4, true)
		end)
	end

	table.clear(v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flatFacing(p)
	local v4 = p.CFrame.LookVector * createVector(1, 0, 1)

	if v4.Magnitude > 0.001 then
		return v4.Unit
	end

	return createVector(0, 0, 1)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function baseFrame(p)
	return CFrame.lookAt(p.Position, p.Position + flatFacing(p))
end

local function legacyFrame(root, p: number, p2: number)
	local v4 = root.Position + createVector(0, 4, 0)
	local v5 = v4 + root.CFrame.LookVector * p + Vector3.new(0, p2, 0)
	return CFrame.lookAt(v5, v4)
end

local function frame(root, pull: number, height: number, yaw: number, focus: number)
	local v4 = root.Position + Vector3.new(0, focus, 0)
	local v5 = v4 + CFrame.Angles(0, math.rad(yaw), 0) * flatFacing(root) * pull + Vector3.new(0, height, 0)
	return CFrame.lookAt(v5, v4)
end

return function(player)
	local root = player.Root
	local duration = player.Duration or 2

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") then
		return
	end

	local pullStart = player.PullStart or 26
	local pullEnd = player.PullEnd or 62
	local heightStart = player.HeightStart or 8
	local heightEnd = player.HeightEnd or 26
	local range = player.Range or 260
	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or range < (humanoidRootPart.Position - root.Position).Magnitude then
		return
	end

	local v4 = "BossAwakenShake" .. tostring(os.clock())
	local now = 0
	local v5 = 0
	local v6 = 0
	local v7 = 0

	-- equivalent calls inferred from this helper; original call sites unknown
	local function punch(magnitude: number, roughness: number, fadeOut: number)
		now = os.clock()
		v5 = now + fadeOut
		v6 = magnitude
		v7 = roughness
	end

	local function shakeOffset()
		local now2 = os.clock()

		if v5 <= now2 then
			return CFrame.identity
		end

		local v8 = 1 - (now2 - now) / (v5 - now)
		local v9 = v6 * v8 * v8
		local v10 = now2 * v7
		local v11 = math.noise(v10, 0, 0) * v9
		local v12 = math.noise(0, v10, 0) * v9
		local v13 = math.noise(0, 0, v10) * v9
		return CFrame.new(v11 * 0.02, v12 * 0.02, 0) * CFrame.Angles(
			math.rad(v11 * 0.12),
			math.rad(v12 * 0.12),
			(math.rad(v13 * 0.2))
		)
	end

	RunService:BindToRenderStep(v4, Enum.RenderPriority.Camera.Value + 5, function()
		local v8 = shakeOffset()

		if v8 ~= CFrame.identity then
			workspace.CurrentCamera.CFrame *= v8
		end
	end)

	if player.Shake ~= false then
		punch(9, 6, 1.4) -- equivalent call inferred; original call site unknown
	end

	local shakes

	if typeof(player.Shakes) == "table" then
		shakes = player.Shakes
	else
		shakes = nil
	end

	local v8 = 1

	local function runShakes(total: number)
		while shakes and v8 <= #shakes do
			local shake = shakes[v8]

			if total < shake.At then
				break
			end

			v8 += 1
			local magnitude = shake.Magnitude or 12
			local roughness = shake.Roughness or 10
			local fadeOut = shake.FadeOut or 0.7
			punch(magnitude, roughness, fadeOut) -- equivalent call inferred; original call site unknown
		end
	end

	local bossPrimedIsland = Lighting:FindFirstChild("BossPrimedIsland")

	if bossPrimedIsland then
		local v9 = os.clock() + duration + 0.7 + 1
		bossPrimedIsland:SetAttribute("Handoff", v9)
		bossPrimedIsland:SetAttribute("Until", v9 + 1)
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "BossAwakenTint"
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.35), {
		Brightness = -0.2,
		Contrast = 0.2,
		Saturation = player.Saturation or -0.25
	}):Play()
	local shots

	if typeof(player.Shots) == "table" and #player.Shots >= 2 then
		shots = player.Shots
	else
		shots = nil
	end

	local frequency = player.Frequency or shots and 7 or 2.4
	local character2

	if typeof(player.Character) == "Instance" then
		character2 = player.Character
	else
		character2 = root.Parent
	end

	local v9 = nil
	local v10 = nil

	local function trackPoint(track: string)
		if v10 ~= track or not (v9 and v9.Parent) then
			v10 = track
			v9 = nil

			if character2 then
				for _, part in character2:GetDescendants() do
					if not (part:IsA("BasePart") and part.Name == track) then
						continue
					end

					v9 = part
					break
				end
			end
		end

		if v9 then
			return v9.Position
		end

		return nil
	end

	local function shotCFrame(shot)
		local v11

		if typeof(shot.CF) == "CFrame" then
			v11 = baseFrame(root) * shot.CF
		else
			v11 = frame(root, shot.Pull or pullStart, shot.Height or heightStart, shot.Yaw or 0, shot.Focus or 4)
		end

		local v12 = shot.Track and trackPoint(shot.Track)

		if not v12 then
			return v11
		end

		local position = v11.Position

		if shot.TrackAnchor and typeof(shot.CF) == "CFrame" then
			position = v12 + (baseFrame(root)):VectorToWorldSpace(shot.CF.Position)
		elseif shot.TrackLocal and v9 and typeof(shot.CF) == "CFrame" then
			local position2 = shot.CF.Position
			local cFrame = v9.CFrame
			position = cFrame:PointToWorldSpace(position2)
			local pointToWorldSpace = cFrame:PointToWorldSpace((Vector3.new(position2.X, -position2.Y, position2.Z)))

			if (pointToWorldSpace - root.Position).Magnitude > (position - root.Position).Magnitude then
				position = pointToWorldSpace
			end
		end

		local v13 = v12 + (shot.TrackOffset or createVector(0, 0, 0))

		if (v13 - position).Magnitude > 0.001 then
			return CFrame.lookAt(position, v13)
		end

		return v11
	end

	local function sample(total: number)
		if shots then
			local shot = shots[1]

			for _, shot2 in ipairs(shots) do
				if total <= shot2.At then
					local v11 = shot2.At - shot.At

					if v11 <= 0 then
						return shotCFrame(shot2)
					end

					if shot2.Snap then
						return shotCFrame(shot)
					end

					local v12 = math.clamp((total - shot.At) / v11, 0, 1)
					local v13 = 1 - (1 - v12) * (1 - v12)
					local v14 = shotCFrame(shot)
					local v15 = shotCFrame(shot2)

					if typeof(shot.CF) == "CFrame" or typeof(shot2.CF) == "CFrame" then
						return v14:Lerp(v15, v13)
					end

					local focus = shot.Focus or 4
					local v16 = focus + ((shot2.Focus or 4) - focus) * v13
					return CFrame.lookAt(v14.Position:Lerp(v15.Position, v13), root.Position + Vector3.new(0, v16, 0))
				else
					shot = shot2
				end
			end

			return shotCFrame(shot)
		else
			local v11 = math.clamp(total / duration, 0, 1)
			local v12 = 1 - (1 - v11) * (1 - v11)
			return legacyFrame(
				root,
				pullStart + (pullEnd - pullStart) * v12,
				heightStart + (heightEnd - heightStart) * v12
			)
		end
	end

	local v11 = CameraController.new(workspace.CurrentCamera, 1, 0.45)
	local total = 0
	local v12 = 0
	hideInterface()
	local success, result = pcall(function()
		while total < duration and root.Parent do
			local v13 = false

			if shots then
				local v14 = 0

				for i, shot in ipairs(shots) do
					if total >= shot.At then
						v14 = i
					end
				end

				if v14 ~= v12 then
					v12 = v14

					if v14 > 0 then
						v13 = shots[v14].Snap == true
					else
						v13 = false
					end
				end
			end

			runShakes(total)

			if v13 then
				v11:SetAreAnimationsInstant(true)
			end

			v11.Animations:AnimateTo(sample(total), 1, frequency)

			if v13 then
				v11:SetAreAnimationsInstant(false)
			end

			total += task.wait()
		end
	end)
	showInterface()
	pcall(RunService.UnbindFromRenderStep, RunService, v4)

	if not success then
		warn((`BossAwaken.Cinematic: {result}`))
	end

	v11:FadeOut(0.7)
	local tween = TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.7), {
		Brightness = 0,
		Contrast = 0,
		Saturation = 0
	})
	tween.Completed:Connect(function()
		colorCorrectionEffect:Destroy()
	end)
	tween:Play()
end