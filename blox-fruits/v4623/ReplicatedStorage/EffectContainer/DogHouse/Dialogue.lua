local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VRichText = require(game.ReplicatedStorage.Util.VRichText)
local playerGui = game.Players.LocalPlayer.PlayerGui
local bossBar = playerGui.TransformationHUD.BossBar
local dogHouse = playerGui.DogHouse
local frame = dogHouse.Frame
local viewportFrame = frame.ViewportFrame
local title = frame.Title
local textFrame = frame.Dialogue.TextFrame
local v = {
	MainFrameAppear = UDim2.fromScale(0.265, 0.03),
	MainFrameClose = UDim2.fromScale(0.265, -1),
	BossHealthBarAppear = UDim2.fromScale(0.5, 0.06),
	BossHealthBarClose = UDim2.fromScale(0.5, -1)
}
local renderSteppedConnection = nil
local count = 0
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function playTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	return tween
end

local function clearViewport()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end

	for _, child in ipairs(viewportFrame:GetChildren()) do
		child:Destroy()
	end

	viewportFrame.CurrentCamera = nil
end

local v3 = {
	indrav2 = true
}

local function visibleHead(clone)
	local v4 = nil

	for _, childName in { "Head", "Head2" } do
		local part = clone:FindFirstChild(childName, true)

		if not (part and part:IsA("BasePart")) then
			continue
		end

		if part.Transparency < 0.9 then
			return part
		else
			v4 = v4 or part
		end
	end

	return v4
end

local function setupViewport(model, headshot: boolean?, headshotDistance: number?)
	clearViewport()
	local v4

	if typeof(model) == "string" then
		v4 = model
	end

	if typeof(model) == "string" then
		model = script:FindFirstChild(model)

		if not model then
			warn("[DogHouse.Dialogue] Missing viewport character model:", (tostring(model)))
			return
		end
	end

	if not (model and model:IsA("Model")) then
		return
	end

	local archivable = model.Archivable
	model.Archivable = true
	local clone = model:Clone()
	model.Archivable = archivable

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ModuleScript") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false

			if descendant.Transparency >= 0.9 then
				descendant.Transparency = 1
			end
		end
	end

	local worldModel = Instance.new("WorldModel")
	worldModel.Name = "WorldModel"
	worldModel.Parent = viewportFrame
	clone.Parent = worldModel
	local _, v5 = clone:GetBoundingBox()
	local v6 = math.max(v5.Y, 1)
	local v7 = math.max(v5.X, v5.Z, 1)
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart", true)
	local v8 = not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) and createVector(0, 0, -1) or humanoidRootPart.CFrame.LookVector
	local vector2 = Vector3.new(v8.X, 0, v8.Z)
	local v9 = vector2.Magnitude <= 0.01 and createVector(0, 0, -1) or vector2.Unit
	local vector3 = Vector3.new(0, v6 * 0.5, 0)
	clone:PivotTo(CFrame.lookAt(vector3, vector3 + v9))
	local camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local v10

	if headshot == true then
		v10 = true
	elseif v4 == nil then
		v10 = false
	else
		v10 = v3[v4] == true
	end

	local v11

	if v10 then
		v11 = visibleHead(clone)
	end

	if v11 then
		local v12 = math.max(v11.Size.X, v11.Size.Y, v11.Size.Z, 1)
		local v13 = v11.Position + Vector3.new(0, v11.Size.Y * 0.05, 0)
		camera.FieldOfView = 45
		camera.CFrame = CFrame.lookAt(v13 + v9 * v12 * (headshotDistance or 3.2), v13)
	else
		camera.FieldOfView = 50
		local v12 = math.max(v7 * 1.55, v6 * 0.35)
		local vector4 = Vector3.new(0, v6 * 0.58, 0)
		camera.CFrame = CFrame.lookAt(vector4 + v9 * v12 + Vector3.new(0, v6 * 0.03, 0), vector4)
	end

	if not model:IsDescendantOf(workspace) then
		return
	end

	local humanoidRootPart2 = model:FindFirstChild("HumanoidRootPart", true)
	local humanoidRootPart3 = clone:FindFirstChild("HumanoidRootPart", true)

	if not (humanoidRootPart2 and humanoidRootPart2:IsA("BasePart") and humanoidRootPart3 and humanoidRootPart3:IsA("BasePart")) then
		return
	end

	local descendants = model:GetDescendants()
	local descendants2 = clone:GetDescendants()
	local v12 = {}

	for i, part in ipairs(descendants) do
		local part2 = descendants2[i]

		if not (part:IsA("BasePart") and part2 and part2:IsA("BasePart") and part2.Name == part.Name) then
			continue
		end

		table.insert(v12, {
			source = part,
			clone = part2
		})
	end

	local cFrame = humanoidRootPart3.CFrame
	renderSteppedConnection = RunService.RenderStepped:Connect(function()
		if not (humanoidRootPart2.Parent and humanoidRootPart3.Parent) then
			return
		end

		local cFrame2 = humanoidRootPart2.CFrame

		for _, v13 in v12 do
			local source = v13.source
			local clone2 = v13.clone

			if source.Parent and clone2.Parent then
				clone2.CFrame = cFrame * cFrame2:ToObjectSpace(source.CFrame)
			end
		end
	end)
end

local function formatDialogueText(value: string?)
	local v4 = value or "ARGHHHHHHHHHHHHHH"

	if v4:find("<Color=", 1, true) or v4:find("<AnimateStyle", 1, true) then
		return v4
	end

	return "<Color=White><AnimateStyle=Wiggle><AnimateStyleTime=0.1><AnimateStyleAmplitude=1.8><AnimateStepFrequency=1><AnimateStepTime=0.065>" .. v4 .. "<Color=/>"
end

return function(player)
	count += 1
	local v4 = count

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	local duration = player.Duration or 2.4
	local title2 = player.Title or "DOGHOUSE"
	local text = player.Text or "ARGHHHHHHHHHHHHHH"

	if not (text:find("<Color=", 1, true) or text:find("<AnimateStyle", 1, true)) then
		text = "<Color=White><AnimateStyle=Wiggle><AnimateStyleTime=0.1><AnimateStyleAmplitude=1.8><AnimateStepFrequency=1><AnimateStepTime=0.065>" .. text .. "<Color=/>"
	end

	dogHouse.Enabled = true
	frame.Visible = true
	frame.Position = v.MainFrameClose
	title.Text = title2
	textFrame:ClearAllChildren()
	setupViewport(player.Character, player.Headshot, player.HeadshotDistance)
	v2 = playTween(bossBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = v.BossHealthBarClose
	})
	task.wait(0.12)

	if v4 ~= count then
		return
	end

	v2 = playTween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = v.MainFrameAppear
	})
	v2.Completed:Wait()

	if v4 ~= count then
		return
	end

	task.wait(0.05)

	if v4 ~= count then
		return
	end

	VRichText:New(textFrame, text, {
		Font = "SourceSansBold",
		TextScaled = true,
		TextScale = 0.23,
		TextColor3 = "White",
		TextStrokeColor3 = "Black",
		TextStrokeTransparency = 0,
		ContainerHorizontalAlignment = "Center",
		ContainerVerticalAlignment = "Center",
		TextYAlignment = "Center",
		AnimateStepGrouping = "Letter",
		AnimateStepFrequency = 1,
		AnimateStepTime = 0.005,
		AnimateStyle = "Wiggle",
		AnimateStyleTime = 0.12,
		AnimateStyleAmplitude = 1.8
	}, true):Animate(false)
	task.wait(duration)

	if v4 ~= count then
		return
	end

	v2 = playTween(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = v.MainFrameClose
	})
	v2.Completed:Wait()

	if v4 ~= count then
		return
	end

	textFrame:ClearAllChildren()
	clearViewport()
	dogHouse.Enabled = false
	v2 = playTween(bossBar, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = v.BossHealthBarAppear
	})
end