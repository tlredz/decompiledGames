local createVector = vector.create
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
game:GetService("GuiService")
local Players = game:GetService("Players")
local LastInput = require(game.ReplicatedStorage.Modules.LastInput)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local PreviewModel = require(game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel)
local PREVIEW_MODEL_CONFIG = PreviewModel.PREVIEW_MODEL_CONFIG
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local SpinnerUtil = require(game.ReplicatedStorage.Controllers.UI.Spinner.SpinnerUtil)
local ModelPopup = {}
local instances = game.ReplicatedStorage.Controllers.UI.Spinner.Components.PreviewModel:FindFirstChild("Instances")
local localPlayer = Players.LocalPlayer
local v = false
local maid = nil
local main = nil
local backpack = nil

local function getTouchGUI()
	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")
	local v2 = nil

	if touchGui and touchGui:IsA("ScreenGui") then
		return touchGui
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleHUDVisibility(enabled)
	local v3 = main
	local v4 = backpack
	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")
	local v5 = nil

	if touchGui and touchGui:IsA("ScreenGui") then
		v5 = touchGui
	end

	for _, v6 in { v3, v4, v5 } do
		if v6 then
			v6.Enabled = enabled
		end
	end
end

function ModelPopup:IsOpen()
	return v
end

function ModelPopup.Open(_, p, p2: number)
	if ModelPopup:IsOpen() then
		return
	end

	v = true
	ModelPopup.ScreenGui.Enabled = true
	local v3 = main
	local v4 = backpack
	local touchGui = localPlayer.PlayerGui:FindFirstChild("TouchGui")

	if not (touchGui and touchGui:IsA("ScreenGui")) then
		touchGui = nil
	end

	for _, v5 in { v3, v4, touchGui } do
		if v5 then
			v5.Enabled = false
		end
	end

	if maid then
		maid:Destroy()
		maid = nil
	end

	maid = Trove.new()
	local v5 = p or script["Dummy Model"]
	local folder = maid:Add(v5:Clone())
	folder.Parent = workspace

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
		part.AssemblyAngularVelocity = createVector(0, 0, 0)
	end

	folder.PrimaryPart = folder:FindFirstChild("_PrimaryPart") or folder:FindFirstChildWhichIsA("BasePart", true)
	local displayName = folder:GetAttribute("DisplayName") or folder.Name
	local v6 = RarityUtil.DATA[p2]
	local flag = false

	local function fn()
		if flag then
			return
		end

		flag = true
		local uDim = UDim2.fromScale(0.4, 0.1)
		local parent = maid:Add(Instance.new("ImageLabel"))
		parent.Image = "rbxassetid://84814021550813"
		parent.BackgroundTransparency = 1
		parent.ImageColor3 = Color3.new(1, 1, 1)
		parent.ScaleType = Enum.ScaleType.Stretch
		parent.AnchorPoint = Vector2.new(0.5, 0)
		parent.Position = UDim2.fromScale(0.5, 0.01)
		parent.Size = UDim2.fromScale(uDim.X.Scale * 0.5, uDim.Y.Scale * 0.5)
		local textLabel = Instance.new("TextLabel")
		textLabel.Rotation = -2
		textLabel.Size = UDim2.fromScale(1, 0.9)
		textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		textLabel.Position = UDim2.fromScale(0.5, 0.5)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Highway
		textLabel.TextScaled = true
		textLabel.Text = displayName
		textLabel.TextColor3 = v6.Color
		local uIStroke = Instance.new("UIStroke")
		local ColorUtil = require(game.ReplicatedStorage.Modules.Util.ColorUtil)
		uIStroke.Color = ColorUtil.tuneBrightness(v6.Color, 0.5)
		uIStroke.Thickness = 1
		uIStroke.Transparency = 0
		uIStroke.LineJoinMode = Enum.LineJoinMode.Round
		uIStroke.Parent = textLabel
		textLabel.Parent = parent
		parent.Parent = ModelPopup.ScreenGui
		maid:Add(TweenService:Create(parent, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
			Size = uDim
		})):Play()
	end

	local v7 = nil
	local v8 = nil

	local function particleState(folder2, enabled: boolean?)
		local max = 0

		for _, emitter in folder2:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			if enabled == nil then
				emitter:Emit((emitter:GetAttribute("EmitCount")))
			else
				emitter.Enabled = enabled
			end

			if not (emitter.Lifetime.Max <= max) then
				max = emitter.Lifetime.Max
			end
		end

		return max
	end

	local v9 = folder:GetExtentsSize() * 0.5
	local v10 = 0
	local total = 0
	local currentCamera = workspace.CurrentCamera
	local v11 = 3.141592653589793 * PREVIEW_MODEL_CONFIG.SPINS + 0.25
	local v12 = {
		Common = "Blox_Fruit_Click_01",
		Uncommon = "Blox_Fruit_Click_02",
		Rare = "Blox_Fruit_Click_03",
		Legendary = "Blox_Fruit_Click_04",
		Mythical = "Blox_Fruit_Click_Mythical_01"
	}
	local v13 = {
		Instance = nil,
		Alpha = 0,
		Elapsed = 0
	}
	local v14 = {
		TargetRotX = 0,
		TargetRotY = 0,
		CurrentRotX = 0,
		CurrentRotY = 0,
		Mouse = localPlayer:GetMouse()
	}
	local value = 0

	local function update(p3)
		debug.profilebegin("Spinner/PreviewModel")
		local absolutePosition = ModelPopup.DummyTile.AbsolutePosition
		local absoluteSize = ModelPopup.DummyTile.AbsoluteSize
		local v15 = absolutePosition.X + absoluteSize.X / 2
		local v16 = absolutePosition.Y + absoluteSize.Y / 2
		local v17 = math.max(1, currentCamera.ViewportSize.X)
		local v18 = math.max(1, currentCamera.ViewportSize.Y)
		local screenPointToRay = currentCamera:ScreenPointToRay(v15, v16)
		local fieldOfView = math.rad(currentCamera.FieldOfView)
		local v19 = math.atan(math.tan(fieldOfView / 2) * (v17 / v18)) * 2
		local v20 = absoluteSize.X / v17
		local v21 = absoluteSize.Y / v18
		local v22 = v19 * v20
		local v23 = fieldOfView * v21
		local v24 = v9.X / math.tan(v22 / 2)
		local v25 = v9.Y / math.tan(v23 / 2)
		local v26 = v9.Z * 1.5
		local v27 = math.min(v24, v25)
		local v28 = math.max(v24, v25, v26)

		if v27 >= 1e999 or v28 > 1e999 then
			v27 = 0
			v28 = 5
		end

		local v29 = math.clamp(v27, v27, v28)
		local v30 = screenPointToRay.Origin + screenPointToRay.Direction * v29
		local unit = (currentCamera.CFrame.Position - v30).Unit
		local v31 = math.atan2(unit.X, unit.Z)
		local v32 = math.clamp(math.asin(unit.Y), -PREVIEW_MODEL_CONFIG.MAX_PITCH, PREVIEW_MODEL_CONFIG.MAX_PITCH)
		local vector2 = Vector3.new(math.sin(v31) * math.cos(v32), math.sin(v32), math.cos(v31) * math.cos(v32))
		local cframe = CFrame.new(v30, v30 + vector2)

		if not (value < 1) then
			local X = v14.Mouse.X
			local Y = v14.Mouse.Y
			local v33 = (X - v15) / (absoluteSize.X / 2)
			local v34 = (Y - v16) / (absoluteSize.Y / 2)
			v14.targetRotY = math.clamp(
				v33 * PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE,
				-PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE,
				PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE
			)
			v14.targetRotX = math.clamp(
				-v34 * PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE,
				-PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE,
				PREVIEW_MODEL_CONFIG.MOUSE_MAX_ANGLE
			)
			v14.CurrentRotX += (v14.targetRotX - v14.CurrentRotX) * math.clamp(
				PREVIEW_MODEL_CONFIG.MOUSE_SMOOTHING * p3,
				0,
				1
			)
			v14.CurrentRotY += (v14.targetRotY - v14.CurrentRotY) * math.clamp(
				PREVIEW_MODEL_CONFIG.MOUSE_SMOOTHING * p3,
				0,
				1
			)
		end

		local v33 = cframe * CFrame.Angles(v14.CurrentRotX, v14.CurrentRotY + v10, 0)

		if v33 ~= v33 then
			return
		end

		folder:PivotTo(v33)

		if value < 1 then
			local v34 = total / PREVIEW_MODEL_CONFIG.TWEEN_TIME
			value = TweenService:GetValue(math.clamp(v34, 0, 1), Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			v10 = math.lerp(0, v11, 1 - value)

			if v13.Instance == nil then
				v13.Instance = maid:Add(Instance.new("Highlight"))
				local assert_2 = assert(v13.Instance)
				assert_2.FillColor = Color3.fromRGB()
				v13.Instance.OutlineTransparency = 1
				v13.Instance.FillTransparency = 0
				v13.Instance.Parent = folder
			end

			assert(v13.Instance)

			if value >= 0.9 then
				local alpha = TweenService:GetValue(
					math.clamp(v13.Elapsed / 0.5, 0, 1),
					Enum.EasingStyle.Exponential,
					Enum.EasingDirection.Out
				)
				v13.Elapsed += p3
				v13.Alpha = alpha
				v13.Instance.FillTransparency = v13.Alpha
			end
		end

		local cFrame = CFrame.new(v30, currentCamera.CFrame.Position) * CFrame.new(0, 0, -v9.Z + 1)
		local cframe2 = CFrame.new(v30, currentCamera.CFrame.Position)

		if total >= 0.01 then
			if v8 == nil then
				local trianglePart = instances:FindFirstChild("TrianglePart")
				v8 = maid:Add(trianglePart:Clone())

				for _, emitter in assert((assert(v8):FindFirstChild("Triangles"))):GetChildren() do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					emitter.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, v6.Color),
						ColorSequenceKeypoint.new(1, v6.Color)
					})
					emitter:Emit(1)
				end

				v8.CFrame = cFrame
				v8.Triangles.Position = createVector(0, 0, 2)
				v8.Parent = workspace
			end

			if v7 == nil then
				local part = instances:FindFirstChild(v6.Name)

				if assert(part and part:IsA("BasePart"), (`can't find part for rarity: {v6.Name}`)) then
					v7 = maid:Add(part:Clone())
				end

				v7.Attachment.Position = createVector(0, 0, 3)
				local assert_3 = assert(v7)
				assert_3.CFrame = cframe2
				v7.Parent = workspace
			end

			if v8 then
				v8.CFrame = cFrame
			end

			if v7 then
				v7.CFrame = cframe2
			end

			if v13.Instance and v13.Instance.FillTransparency >= 0.9 and not flag then
				fn()
				SpinnerUtil.playSound(v12[v6.Name])

				if v7 then
					particleState(v7)
				end
			end
		end

		total += p3
		debug.profileend()
	end

	local renderSteppedConnection = RunService.RenderStepped:Connect(update)
	maid:Add(renderSteppedConnection)
	local v15 = nil
	local v16 = (LastInput:Get() == "Touch" and 1.25 or 1.5) * 0.9
	maid:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and v7 and not gameProcessed then
			if v15 or value < 1 then
				return
			end

			local v17 = maid:Add(SpinnerUtil.tweenPreview(
				ModelPopup.DummyTile,
				TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true),
				{
					Size = UDim2.fromScale(v16, v16)
				}
			))
			v15 = v17
			maid:Add(v17.Completed:Connect(function()
				v15 = nil
			end))
			v17:Play()
			SpinnerUtil.playSound(v12[v6.Name])
			particleState(v7)
		end
	end))
	return true
end

function ModelPopup:Close()
	if not ModelPopup:IsOpen() then
		return
	end

	ModelPopup.ScreenGui.Enabled = false

	if maid then
		maid:Destroy()
		maid = nil
	end

	toggleHUDVisibility(true) -- equivalent call inferred; original call site unknown
	v = false
end

function ModelPopup.OnStart(_)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Enabled = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	screenGui.DisplayOrder = 1
	screenGui.ResetOnSpawn = false
	screenGui.Parent = localPlayer.PlayerGui
	screenGui.Name = "ModelPopup"
	local dummyTileHolder = script.DummyTileHolder
	dummyTileHolder.Parent = screenGui
	ModelPopup.DummyTile = dummyTileHolder.DummyTile
	local closeButtonFrame = script.CloseButtonFrame
	closeButtonFrame.Parent = screenGui
	closeButtonFrame.CloseButton.Activated:Connect(function()
		ModelPopup:Close()
	end)
	ModelPopup.ScreenGui = screenGui
	task.defer(function()
		local Players2 = game:GetService("Players")
		main = Players2.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Main")
		local Players3 = game:GetService("Players")
		backpack = Players3.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Backpack")
	end)
end

return ModelPopup