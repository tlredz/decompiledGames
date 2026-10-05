local createVector = vector.create
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Player = require(ReplicatedStorage.Shared.Player)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Kit = require(script.Parent.Kit)
local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local color = Color3.fromRGB(225, 255, 225)
local color2 = Color3.new(0, 0, 0)
local localPlayer = Players.LocalPlayer
local random = Random.new()
local v = Trove.new()
local extended = v:Extend()
local v2 = nil
local parent = nil
local v4 = nil
local v5 = nil
local v6 = {}
local v7 = 0
local v8 = 0
local v9 = 1
local zero = Vector2.zero
local v10 = "clear"
local v11 = nil
local v12 = false
local flag = false
local fadeFrom = 0
local total = 0
local count = 0
local v14 = nil
local flag2 = false

local function viewport()
	local absoluteSize

	if v2 then
		absoluteSize = v2.AbsoluteSize
	else
		absoluteSize = Vector2.zero
	end

	if absoluteSize.X >= 1 and absoluteSize.Y >= 1 then
		return absoluteSize
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera then
		return currentCamera.ViewportSize
	end

	return (Vector2.new(1280, 720))
end

local function ensureGui()
	if v2 and v2.Parent then
		return true
	end

	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local UI = assets and assets:FindFirstChild("UI")
	local scrambleBoss = UI and UI:FindFirstChild("ScrambleBoss")
	local binaryTransition = scrambleBoss and scrambleBoss:FindFirstChild("BinaryTransition")

	if binaryTransition == nil or not binaryTransition:IsA("ScreenGui") then
		return false
	end

	v:Clean()
	extended = v:Extend()
	v12 = false
	v6 = {}
	zero = Vector2.zero
	v10 = "clear"
	v11 = nil
	flag = false
	local clone = v:Clone(binaryTransition)
	local grid = clone:WaitForChild("Grid")
	local cell = grid:WaitForChild("Cell")
	local fade = clone:WaitForChild("Fade")
	clone.Enabled = false
	cell.Visible = false
	fade.Visible = false
	clone.Parent = localPlayer:WaitForChild("PlayerGui")
	v2 = clone
	parent = grid
	v4 = cell
	v5 = fade
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function paint(state, glow: number)
	if state.Glow == glow then
		return
	end

	state.Glow = glow
	state.Digit.TextColor3 = state.Tone:Lerp(color, glow)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function apply(state, p: number)
	local v15 = math.max(p, 0)

	if state.Value == v15 then
		return
	end

	state.Value = v15
	state.Frame.Size = UDim2.fromScale(v7 * v15, v8 * v15)
end

local function rebuild()
	local absoluteSize

	if v2 then
		absoluteSize = v2.AbsoluteSize
	else
		absoluteSize = Vector2.zero
	end

	if not (absoluteSize.X >= 1 and absoluteSize.Y >= 1) then
		local currentCamera = Workspace.CurrentCamera

		if currentCamera then
			absoluteSize = currentCamera.ViewportSize
		else
			absoluteSize = Vector2.new(1280, 720)
		end
	end

	if absoluteSize == zero and #v6 > 0 then
		return
	end

	zero = absoluteSize

	for _, v15 in v6 do
		v15.Frame:Destroy()
	end

	table.clear(v6)
	local v15 = math.max(absoluteSize.X, absoluteSize.Y) / 22
	local v16 = math.ceil(absoluteSize.X / v15)
	local v17 = math.ceil(absoluteSize.Y / v15)
	v9 = v17
	local v18 = v15 / absoluteSize.X
	local v19 = v15 / absoluteSize.Y
	v7 = v18 * 1.04
	v8 = v19 * 1.04
	local textSize = math.max(math.floor(v15 * 0.72), 8)
	local v21 = v10 == "covered" and 1 or 0

	for i = 1, v16 do
		for i2 = 1, v17 do
			local clone = v4:Clone()
			clone.Name = `{i}_{i2}`
			clone.Position = UDim2.fromScale((i - 0.5) * v18, (i2 - 0.5) * v19)
			clone.Size = UDim2.fromScale(v7 * v21, v8 * v21)
			clone.Visible = true
			local digit = clone:WaitForChild("Digit")
			digit.TextSize = textSize
			digit.Text = random:NextNumber() < 0.5 and "0" or "1"
			local lerped = Kit.Green:Lerp(color2, 1 - random:NextNumber(0.3, 1))
			digit.TextColor3 = lerped
			clone.Parent = parent
			table.insert(v6, {
				Frame = clone,
				Digit = digit,
				Column = i,
				Row = i2,
				Value = v21,
				Glow = 0,
				Tone = lerped
			})
		end
	end
end

local function delays()
	local result = table.create(#v6, 0)
	local v15 = {}

	for k, v16 in v6 do
		if v15[v16.Column] == nil then
			v15[v16.Column] = random:NextNumber(0, 0.16)
		end

		local v17 = not (v9 > 1) and 0 or (v16.Row - 1) / (v9 - 1)
		result[k] = v15[v16.Column] + v17 * 0.26
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFade(value: number)
	fadeFrom = math.clamp(value, 0, 1)
	local v15 = v5
	v15.BackgroundTransparency = 1 - fadeFrom
	v15.Visible = fadeFrom > 0
end

local function flicker(p: number)
	total += p

	if total < 0.06 then
		return
	end

	total = 0

	for _, v15 in v6 do
		if v15.Value > 0 and random:NextNumber() < 0.14 then
			v15.Digit.Text = v15.Digit.Text == "0" and "1" or "0"
		end
	end
end

local fn

local function finish(p)
	v11 = nil

	if p.Target == 1 then
		v10 = "covered"

		if flag then
			flag = false
			fn(0)
		end
	else
		v10 = "clear"
		extended:Clean()
		v12 = false

		for _, v15 in v6 do
			apply(v15, 0) -- equivalent call inferred; original call site unknown
			paint(v15, 0) -- equivalent call inferred; original call site unknown
		end

		fadeFrom = 0
		local v15 = v5
		v15.BackgroundTransparency = 1 - fadeFrom
		v15.Visible = fadeFrom > 0

		if v2 then
			v2.Enabled = false
		end
	end
end

local function step(p: number)
	flicker(p)
	local v15 = v11

	if v15 == nil then
		return
	end

	local v16 = os.clock() - v15.Start

	if v15.Fade then
		local v17 = math.clamp(v16 / 0.15, 0, 1)
		setFade(v15.FadeFrom + (v15.Target - v15.FadeFrom) * v17) -- equivalent call inferred; original call site unknown

		if v17 >= 1 then
			finish(v15)
		end
	else
		local v17 = math.max(v15.Info.Time, 0.001)
		local flag3 = true

		for k, v18 in v6 do
			local v19 = v15.From[k] or 1 - v15.Target
			local v20 = (v16 - (v15.Delays[k] or 0)) / v17
			local target = v15.Target
			local v21 = 0

			if v19 ~= v15.Target and v20 < 1 then
				flag3 = false

				if v20 <= 0 then
					target = v19
				else
					local value = TweenService:GetValue(v20, v15.Info.EasingStyle, v15.Info.EasingDirection)
					target = v19 + (v15.Target - v19) * value
					v21 = 1 - v20
				end
			end

			apply(v18, target) -- equivalent call inferred; original call site unknown
			paint(v18, v21) -- equivalent call inferred; original call site unknown
		end

		if flag3 then
			finish(v15)
		end
	end
end

fn = function(target: number)
	local v15 = v2
	local reducedMotionEnabled = GuiService.ReducedMotionEnabled

	if reducedMotionEnabled then
		local v16 = fadeFrom

		for _, v17 in v6 do
			v16 = math.max(v16, v17.Value)
			apply(v17, 0) -- equivalent call inferred; original call site unknown
			paint(v17, 0) -- equivalent call inferred; original call site unknown
		end

		setFade(math.min(v16, 1)) -- equivalent call inferred; original call site unknown
	else
		rebuild()

		if fadeFrom > 0 then
			for _, v16 in v6 do
				apply(v16, fadeFrom) -- equivalent call inferred; original call site unknown
			end

			fadeFrom = 0
			local v16 = v5
			v16.BackgroundTransparency = 1 - fadeFrom
			v16.Visible = fadeFrom > 0
		end
	end

	local from = table.create(#v6, 0)

	for k, v17 in v6 do
		from[k] = v17.Value
	end

	local v17 = {
		Target = target,
		Start = os.clock(),
		Info = 0,
		From = 0,
		Delays = 0,
		Fade = 0,
		FadeFrom = 0
	}
	local info

	if target == 1 then
		info = tweenInfo
	else
		info = tweenInfo2
	end

	v17.Info = info
	v17.From = from
	v17.Delays = reducedMotionEnabled and {} or delays()
	v17.Fade = reducedMotionEnabled
	v17.FadeFrom = fadeFrom
	v11 = v17
	v10 = target == 1 and "covering" or "revealing"
	v15.Enabled = true

	if target == 1 then
		Kit.Sound("Swoosh", nil, 0.5, 1.35)
	else
		Kit.Sound("Zap", nil, 0.25, 1.6)
	end

	if not v12 then
		v12 = true
		extended:Connect(RunService.RenderStepped, step)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rootPosition()
	local rootPart = Player.FindRootPart(localPlayer)

	if rootPart then
		return rootPart.Position
	end

	return nil
end

local function cameraModule()
	local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
	local playerModule

	if playerScripts then
		playerModule = playerScripts:FindFirstChild("PlayerModule")
	end

	if playerModule == nil or not playerModule:IsA("ModuleScript") then
		return nil
	end

	local module = require(playerModule)
	return module:GetCameras()
end

local function faceCharacter()
	local currentCamera = Workspace.CurrentCamera
	local rootPart = Player.FindRootPart(localPlayer)

	if currentCamera == nil or rootPart == nil or currentCamera.CameraType ~= Enum.CameraType.Custom then
		return
	end

	local lookVector = rootPart.CFrame.LookVector
	local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)

	if vector2.Magnitude < 0.01 then
		return
	end

	local v15 = cameraModule()
	local v16

	if v15 then
		v16 = v15:GetCameraSubjectPosition()
	end

	local v17 = v16 or rootPart.Position + createVector(0, 1.5, 0)
	local v18

	if v15 then
		v18 = v15:GetCameraToSubjectDistance()
	end

	local v19 = math.max(v18 or (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude, 0.5)
	local v20 = math.clamp(
		math.asin((math.clamp(currentCamera.CFrame.LookVector.Y, -1, 1))),
		-0.6981317007977318,
		-0.13962634015954636
	)
	local v21 = vector2.Unit * math.cos(v20) + createVector(0, 1, 0) * math.sin(v20)
	local cframe = CFrame.lookAt(v17 - v21 * v19, v17)
	currentCamera.CFrame = cframe

	if v15 then
		v15:CommitCameraCFrame(cframe, Enum.CameraType.Custom)
	end
end

local Transition = {}

function Transition.Cover(flag3: boolean?, value: number?)
	if not ensureGui() then
		return
	end

	count += 1
	local v15 = count
	v14 = rootPosition() -- equivalent call inferred; original call site unknown
	flag = false
	task.delay(math.max(value or 0, 5), function()
		if count == v15 and v10 ~= "clear" and v10 ~= "revealing" then
			Transition.Reveal()
		end
	end)

	if v10 == "covered" or v10 == "covering" then
		return
	end

	fn(1)

	if flag3 and v11 then
		v11.Start -= 10
	end
end

function Transition.Reveal()
	if v2 == nil or v10 == "clear" or v10 == "revealing" then
		return
	end

	if v10 == "covering" then
		flag = true
	else
		fn(0)
	end
end

function Transition.RevealAfterMove()
	local v15 = count
	local v16 = v14
	local lastTime = os.clock()
	task.spawn(function()
		while os.clock() - lastTime < 0.75 do
			if count ~= v15 then
				return
			end

			local v17 = rootPosition() -- equivalent call inferred; original call site unknown

			if v16 == nil or v17 and (v17 - v16).Magnitude > 12 then
				break
			else
				task.wait()
			end
		end

		task.wait(0.08)

		if count == v15 then
			faceCharacter()
			Transition.Reveal()
		end
	end)
end

function Transition.Listen()
	if flag2 then
		return
	end

	flag2 = true
	Remotes.ScrambleBoss.Transition.OnClientEvent:Connect(function(p, p2, value)
		if p == "Cover" then
			local cover = Transition.Cover
			local v15 = p2 == true

			if type(value) ~= "number" then
				value = nil
			end

			cover(v15, value)
		elseif p == "Reveal" then
			Transition.RevealAfterMove()
		end
	end)
end

return Transition