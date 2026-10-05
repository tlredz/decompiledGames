local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
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

local function hideInterface()
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

	for _, v3 in v do
		local v4 = v3
		local success, result = pcall(function()
			return StarterGui:GetCoreGuiEnabled(v4)
		end)

		if not (success and result) then
			continue
		end

		v2[v3] = true
		local v5 = v3
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v5, false)
		end)
	end
end

local function showInterface()
	for _, v3 in screenGuis do
		if v3.Parent then
			v3.Enabled = true
		end
	end

	table.clear(screenGuis)

	for k in v2 do
		local v3 = k
		pcall(function()
			StarterGui:SetCoreGuiEnabled(v3, true)
		end)
	end

	table.clear(v2)
end

local function basis(p)
	local v3 = p.CFrame.LookVector * createVector(1, 0, 1)
	local selected = not (v3.Magnitude > 0.001) and createVector(0, 0, 1) or v3.Unit
	return selected, (Vector3.new(-selected.Z, 0, selected.X))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toWorld(instance, vector2: Vector3)
	local v3 = instance.CFrame.LookVector * createVector(1, 0, 1)
	local v4 = not (v3.Magnitude > 0.001) and createVector(0, 0, 1) or v3.Unit
	local vector3 = Vector3.new(-v4.Z, 0, v4.X)
	return instance.Position + vector3 * vector2.X + createVector(0, 1, 0) * vector2.Y + v4 * vector2.Z
end

local v3 = {
	inout = function(p: number)
		return p * p * (3 - p * 2)
	end,
	accelerate = function(p: number)
		return p * p
	end,
	decelerate = function(p: number)
		return 1 - (1 - p) * (1 - p)
	end,
	linear = function(p: number)
		return p
	end
}

local function lookAtStable(lerped: Vector3, lerped2: Vector3, root)
	local v4 = root.CFrame.LookVector * createVector(1, 0, 1)
	local v5 = not (v4.Magnitude > 0.001) and createVector(0, 0, 1) or v4.Unit
	Vector3.new(-v5.Z, 0, v5.X)
	local v6 = lerped2 - lerped

	if v6.Magnitude < 0.001 then
		v6 = v5
	end

	local unit = v6.Unit
	local v7 = not (math.abs(unit.Y) > 0.985) and createVector(0, 1, 0) or v5
	return CFrame.lookAt(lerped, lerped + unit, v7)
end

return function(data)
	local root = data.Root
	local shots = data.Shots

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") or (typeof(shots) ~= "table" or #shots < 2) then
		return
	end

	local localPlayer = Players.LocalPlayer
	local character = localPlayer and localPlayer.Character
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (humanoidRootPart.Position - root.Position).Magnitude > (data.Range or 400) then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watching()
		if localPlayer.Character == character and character.Parent then
			return humanoid == nil or humanoid.Health > 0
		end

		return false
	end

	local duration = data.Duration or 6
	local marker = data.Marker

	local function surgePoint()
		if typeof(marker) == "Instance" and marker:IsA("Attachment") and marker.Parent then
			return marker.WorldPosition
		end

		return root.Position
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function lookOf(p, _: number)
		if p.LookSurge then
			if typeof(marker) == "Instance" and marker:IsA("Attachment") and marker.Parent then
				return marker.WorldPosition
			end

			return root.Position
		else
			local look = p.Look or createVector(0, 0, 0)
			return toWorld(root, look)
		end
	end

	local function frameOf(shot, _: number)
		local world = toWorld(root, shot.Pos) -- equivalent call inferred; original call site unknown
		local v7 = lookOf(shot) -- equivalent call inferred; original call site unknown
		return lookAtStable(world, v7, root)
	end

	local function sample(total: number)
		local shot = shots[1]

		for i, shot2 in ipairs(shots) do
			if i == 1 then
				continue
			end

			if total <= shot2.At then
				if shot2.Snap or shot2.At <= shot.At then
					return frameOf(shot, total)
				end

				local v4 = (v3[shot2.Ease or "inout"] or v3.inout)((math.clamp(
					(total - shot.At) / (shot2.At - shot.At),
					0,
					1
				)))
				local world = toWorld(root, shot.Pos) -- equivalent call inferred; original call site unknown
				local lerped = world:Lerp(toWorld(root, shot2.Pos), v4)
				local v8 = lookOf(shot) -- equivalent call inferred; original call site unknown
				local v9 = lookOf(shot2) -- equivalent call inferred; original call site unknown
				return lookAtStable(lerped, v8:Lerp(v9, v4), root)
			else
				shot = shot2
			end
		end

		return frameOf(shot, total)
	end

	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "ThunderGodAwakenTint"
	colorCorrectionEffect.Brightness = 0
	colorCorrectionEffect.Contrast = 0
	colorCorrectionEffect.Saturation = 0
	colorCorrectionEffect.Parent = Lighting
	TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.4), {
		Brightness = data.Brightness or -0.02,
		Contrast = data.Contrast or 0.08,
		Saturation = data.Saturation or -0.1
	}):Play()
	local v4 = CameraController.new(workspace.CurrentCamera, 1, 0.35)
	hideInterface()
	local total = 0
	local success, result = pcall(function()
		while total < duration and root.Parent do
			-- equivalent call inferred; original call site unknown
			if not watching() then
				break
			end

			v4:SetCFrame(sample(total))
			total += RunService.RenderStepped:Wait()
		end
	end)
	showInterface()

	if not success then
		warn((`BossAwaken.Cam: {result}`))
	end

	v4:FadeOut(0.7)
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