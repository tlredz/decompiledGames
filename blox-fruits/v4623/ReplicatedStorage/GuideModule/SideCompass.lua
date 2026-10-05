local createVector = vector.create
local GuideData = require(script.Parent.GuideData)
local v = true
local v2 = true
local v3 = false
local v4 = false
local v5 = false
local v6 = {}

local function createSideCompass()
	local frame = Instance.new("Frame")
	frame.Name = "Compass"
	frame.AnchorPoint = Vector2.new(0, 0.5)
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.new(0, 10, 0.5, -20)
	frame.Size = UDim2.fromScale(0.352, 0.16)
	frame.SizeConstraint = Enum.SizeConstraint.RelativeYY
	frame.ZIndex = -13
	local frame2 = Instance.new("Frame")
	frame2.Name = "Frame"
	frame2.BackgroundTransparency = 1
	frame2.Position = UDim2.fromOffset(1, 1)
	frame2.Size = UDim2.new(1, -2, 1, -2)
	frame2.ZIndex = -17
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Background"
	imageLabel.Active = true
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "http://www.roblox.com/asset/?id=8934095607"
	imageLabel.LayoutOrder = 3
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Size = UDim2.fromScale(1, 1)
	imageLabel.Visible = false
	imageLabel.ZIndex = -17
	local imageLabel2 = Instance.new("ImageLabel")
	imageLabel2.Name = "Arrow"
	imageLabel2.Active = true
	imageLabel2.AnchorPoint = Vector2.new(0.5, 0)
	imageLabel2.BackgroundTransparency = 1
	imageLabel2.Image = "http://www.roblox.com/asset/?id=8934096993"
	imageLabel2.LayoutOrder = 1
	imageLabel2.Position = UDim2.fromScale(0.5, 0.025)
	imageLabel2.Size = UDim2.fromScale(0.3, 0.35)
	imageLabel2.ZIndex = -16
	imageLabel2.Parent = imageLabel
	imageLabel.Parent = frame2
	local imageLabel3 = Instance.new("ImageLabel")
	imageLabel3.Name = "GuideIcon"
	imageLabel3.Active = true
	imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel3.BackgroundTransparency = 1
	imageLabel3.Image = "rbxassetid://8934096355"
	imageLabel3.LayoutOrder = 3
	imageLabel3.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel3.Size = UDim2.fromScale(0.2, 0.8)
	imageLabel3.Visible = false
	imageLabel3.ZIndex = -16
	imageLabel3.Parent = frame2
	local clone = script.Parent:WaitForChild("Compass"):Clone()
	clone.Name = "Button"
	clone.Parent = frame2
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint.Parent = frame2
	local imageLabel4 = Instance.new("ImageLabel")
	imageLabel4.Name = "Alert"
	imageLabel4.Active = true
	imageLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel4.BackgroundTransparency = 1
	imageLabel4.Image = "http://www.roblox.com/asset/?id=9945465628"
	imageLabel4.ImageTransparency = 0.4
	imageLabel4.Interactable = false
	imageLabel4.LayoutOrder = 3
	imageLabel4.Position = UDim2.fromScale(0.5, 0.5)
	imageLabel4.Size = UDim2.fromScale(1.1, 1.1)
	imageLabel4.ZIndex = -14
	imageLabel4.Parent = frame2
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "DistanceText"
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
	textLabel.Position = UDim2.fromScale(0.5, 1)
	textLabel.Size = UDim2.fromScale(0.95, 0.35)
	textLabel.Text = "None"
	textLabel.TextColor3 = Color3.new()
	textLabel.TextScaled = true
	textLabel.TextStrokeTransparency = 0.7
	textLabel.TextTransparency = 0.4
	textLabel.Visible = false
	textLabel.ZIndex = -13
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Shadow"
	textLabel2.BackgroundTransparency = 1
	textLabel2.FontFace = Font.new(
		"rbxasset://fonts/families/FredokaOne.json",
		Enum.FontWeight.Bold,
		Enum.FontStyle.Normal
	)
	textLabel2.Position = UDim2.fromOffset(-2, -2)
	textLabel2.Size = UDim2.fromScale(1, 1)
	textLabel2.Text = "None"
	textLabel2.TextColor3 = Color3.fromRGB(255, 179, 0)
	textLabel2.TextScaled = true
	textLabel2.TextStrokeTransparency = 0.8
	textLabel2.ZIndex = -13
	textLabel2.Parent = textLabel
	textLabel.Parent = frame2
	frame2.Parent = frame
	local uIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint2.Name = "UIAspectRatioConstraint"
	uIAspectRatioConstraint2.AspectRatio = 2.2
	uIAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
	uIAspectRatioConstraint2.Parent = frame
	local uISizeConstraint = Instance.new("UISizeConstraint")
	uISizeConstraint.Name = "UISizeConstraint"
	uISizeConstraint.MaxSize = Vector2.new(250, 250)
	uISizeConstraint.Parent = frame
	local uIPadding = Instance.new("UIPadding")
	uIPadding.Name = "UIPadding"
	uIPadding.PaddingBottom = UDim.new(0, 2)
	uIPadding.PaddingLeft = UDim.new(0, 2)
	uIPadding.PaddingRight = UDim.new(0, 2)
	uIPadding.PaddingTop = UDim.new(0, 2)
	uIPadding.Parent = frame
	local textLabel3 = Instance.new("TextLabel")
	textLabel3.Name = "Notify"
	textLabel3.BackgroundTransparency = 1
	textLabel3.FontFace = Font.new("rbxasset://fonts/families/Bangers.json")
	textLabel3.Position = UDim2.fromScale(0.3, -0.05)
	textLabel3.Size = UDim2.fromScale(0.35, 0.35)
	textLabel3.Text = "!!!"
	textLabel3.TextColor3 = Color3.fromRGB(255, 0, 0)
	textLabel3.TextScaled = true
	textLabel3.TextStrokeTransparency = 0
	textLabel3.Visible = false
	textLabel3.ZIndex = -14
	textLabel3.Parent = frame
	return frame
end

local SideCompass = {
	COMPASS_BILLBOARD_SHOW_ISLAND_WHEN_TRACKING = false,
	_instance = createSideCompass()
}

-- equivalent calls inferred from this helper; original call sites unknown
local function updateInstanceVisibility()
	SideCompass._instance.Visible = v2 and v3 and not (v4 or v5)
end

local function computeSurfaceCFrame(absolutePosition: Vector2, absoluteSize: Vector2)
	local currentCamera = workspace.CurrentCamera
	local lookVector = currentCamera.CFrame.LookVector

	local function screenToWorld(p: number, p2: number)
		local screenPointToRay = currentCamera:ScreenPointToRay(p, p2)
		local v7 = 2 / screenPointToRay.Direction:Dot(lookVector)
		return screenPointToRay.Origin + screenPointToRay.Direction * v7
	end

	local screenPointToRay = currentCamera:ScreenPointToRay(absolutePosition.X, absolutePosition.Y)
	local v7 = 2 / screenPointToRay.Direction:Dot(lookVector)
	local v8 = screenPointToRay.Origin + screenPointToRay.Direction * v7
	local screenPointToRay2 = currentCamera:ScreenPointToRay(absolutePosition.X + absoluteSize.X, absolutePosition.Y)
	local v9 = 2 / screenPointToRay2.Direction:Dot(lookVector)
	local v10 = screenPointToRay2.Origin + screenPointToRay2.Direction * v9
	local screenPointToRay3 = currentCamera:ScreenPointToRay(absolutePosition.X, absolutePosition.Y + absoluteSize.Y)
	local v11 = 2 / screenPointToRay3.Direction:Dot(lookVector)
	local v12 = screenPointToRay3.Origin + screenPointToRay3.Direction * v11
	local v13 = v10 - v8
	local v14 = v12 - v8
	local v15 = v8 + v13 * 0.5 + v14 * 0.5
	local unit = v13.Unit
	local v16 = -v14.Unit
	local unit2 = unit:Cross(v16).Unit
	return CFrame.fromMatrix(v15, unit, v16, unit2), v13.Magnitude, v14.Magnitude
end

function SideCompass.moveToSurfaceGui()
	local frame = SideCompass._instance.Frame
	local absolutePosition = frame.AbsolutePosition
	local absoluteSize = frame.AbsoluteSize

	while absoluteSize.X == 0 or absoluteSize.Y == 0 or absolutePosition.X == 0 or absolutePosition.Y == 0 do
		task.wait()
		absoluteSize = frame.AbsoluteSize
		absolutePosition = frame.AbsolutePosition
	end

	local cFrame, v8, v9 = computeSurfaceCFrame(absolutePosition, absoluteSize)
	local part = Instance.new("Part")
	part.Name = "SideCompassSurface"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = Vector3.new(v8, v9, 0.1)
	part.CFrame = cFrame
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.LightInfluence = 0
	surfaceGui.ZOffset = 1
	surfaceGui.Name = "SideCompassSurfaceGui"
	surfaceGui.Face = Enum.NormalId.Back
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 60
	surfaceGui.AlwaysOnTop = false
	surfaceGui.Parent = part
	surfaceGui.Adornee = part
	local clone = frame:Clone()
	clone.Button.ImageColor3 = Color3.new(1, 1, 1)
	clone.Button.Visible = true
	clone.Visible = true
	clone.AnchorPoint = Vector2.new(0, 0)
	clone.Position = UDim2.fromScale(0, 0)
	clone.Size = UDim2.fromScale(1, 1)
	clone.Parent = surfaceGui
	part.Parent = workspace
	part.AncestryChanged:Once(function()
		task.wait(1)
		surfaceGui.Parent = nil
	end)
	return part, clone
end

function SideCompass.spawnAtCFrameAndTweenToScreen(cframe: CFrame)
	local frame = SideCompass._instance.Frame
	local parent = frame.Parent
	local anchorPoint = frame.AnchorPoint
	local position = frame.Position
	local size = frame.Size

	while frame.AbsoluteSize.X == 0 or frame.AbsoluteSize.Y == 0 or frame.AbsolutePosition.X == 0 or frame.AbsolutePosition.Y == 0 do
		task.wait()
	end

	local v7, v8 = SideCompass.moveToSurfaceGui()
	local cframe2 = CFrame.Angles(0, 1.5707963267948966, 0)
	v7.Shape = Enum.PartType.Cylinder
	v7.Size = createVector(0.05, 0.75, 0.75)
	v7.Color = Color3.fromRGB(182, 255, 182)
	v7.Transparency = 0
	local parent2 = v8.Parent
	parent2.Face = Enum.NormalId.Left
	local clone = parent2:Clone()
	clone.Name = "SideCompassSurfaceGuiBack"
	clone.Face = Enum.NormalId.Right
	clone.Adornee = v7
	clone.Parent = v7
	v7.CFrame = cframe * cframe2
	frame.Visible = false
	local v9 = {}
	local clone2 = nil
	local renderSteppedConnection = nil
	local v10 = 1
	local renderSteppedConnection2 = nil

	v9[1] = function()
		local DarkScreen = require(script.DarkScreen)
		clone2 = DarkScreen:Clone()
		local frame2 = clone2.Frame.Frame
		frame2.AnchorPoint = Vector2.new(0.5, 0.5)
		local currentCamera = workspace.CurrentCamera
		local RunService = game:GetService("RunService")
		renderSteppedConnection = RunService.RenderStepped:Connect(function()
			if v7.Parent then
				local worldToViewportPoint = currentCamera:WorldToViewportPoint(v7.Position)
				local v11 = math.max(v7.Size.Y, v7.Size.Z) * 0.5
				local worldToViewportPoint2 = currentCamera:WorldToViewportPoint(v7.Position + currentCamera.CFrame.UpVector * v11)
				local v12 = (Vector2.new(worldToViewportPoint2.X, worldToViewportPoint2.Y) - Vector2.new(
					worldToViewportPoint.X,
					worldToViewportPoint.Y
				)).Magnitude * 2 * 1.5 * v10
				frame2.Position = UDim2.fromOffset(worldToViewportPoint.X, worldToViewportPoint.Y)
				frame2.Size = UDim2.fromOffset(v12, v12)
			else
				local GuiService = game:GetService("GuiService")
				local guiInset = GuiService:GetGuiInset()
				local v11 = frame.AbsolutePosition + frame.AbsoluteSize * 0.5 + guiInset
				local v12 = math.max(frame.AbsoluteSize.X, frame.AbsoluteSize.Y) * 1.5 * v10
				frame2.Position = UDim2.fromOffset(v11.X, v11.Y)
				frame2.Size = UDim2.fromOffset(v12, v12)
			end
		end)
		clone2.Parent = game.Players.LocalPlayer.PlayerGui
	end

	v9[2] = function()
		local position2 = v7.CFrame.Position
		local size2 = v7.Size
		local RunService = game:GetService("RunService")
		local total = 0
		local steppedConnection = nil
		steppedConnection = RunService.Stepped:Connect(function(_, dt)
			total += dt
			local v11 = math.clamp(total / 2, 0, 1)
			local v12 = v11 <= 0 and 0 or 2 ^ ((v11 - 1) * 2)
			local v13, v14, v15 = computeSurfaceCFrame(frame.AbsolutePosition, frame.AbsoluteSize)
			local lerped = position2:Lerp(v13.Position, v12)
			local lerped2 = cframe.Rotation:Lerp(v13.Rotation, v12)
			local v16 = 31.41592653589793 * (1 - v11) ^ 2
			v7.Size = size2:Lerp(Vector3.new(size2.X, v15, v14), v12)
			v7.CFrame = (lerped2 + lerped) * CFrame.Angles(0, v16, 0) * cframe2

			if v11 >= 1 then
				steppedConnection:Disconnect()
				frame.AnchorPoint = anchorPoint
				frame.Position = position
				frame.Size = size
				frame.Parent = parent
				frame.Visible = true
				v7:Destroy()
			end
		end)
	end

	v9[3] = function()
		local total = 0
		local RunService = game:GetService("RunService")
		renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
			total += dt
			v10 = math.sin(total * 3.141592653589793 * 2.5) * 0.12 + 1
		end)
	end

	v9[4] = function()
		if renderSteppedConnection then
			renderSteppedConnection:Disconnect()
			renderSteppedConnection = nil
		end

		if renderSteppedConnection2 then
			renderSteppedConnection2:Disconnect()
			renderSteppedConnection2 = nil
		end

		if not clone2 then
			return
		end

		local TweenService = game:GetService("TweenService")
		local frame2 = clone2.Frame
		local frame3 = frame2.Frame
		local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local uDim = UDim2.fromOffset(frame3.AbsoluteSize.X * 3, frame3.AbsoluteSize.Y * 3)
		TweenService:Create(frame2, tweenInfo, {
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(frame3.UIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
		local tween = TweenService:Create(frame3, tweenInfo, {
			Size = uDim
		})
		tween.Completed:Once(function()
			if clone2 then
				clone2:Destroy()
				clone2 = nil
			end
		end)
		tween:Play()
	end

	return v7, function()
		return assert(table.remove(v9, 1))()
	end
end

function SideCompass.hide()
	v2 = false
	updateInstanceVisibility() -- equivalent call inferred; original call site unknown
end

function SideCompass.show()
	v2 = true
	updateInstanceVisibility() -- equivalent call inferred; original call site unknown
end

function SideCompass.setTrackedQuestVisible(flag: boolean)
	v4 = flag
	updateInstanceVisibility() -- equivalent call inferred; original call site unknown
end

function SideCompass.setMenuHidden(flag: boolean)
	v5 = flag
	updateInstanceVisibility() -- equivalent call inferred; original call site unknown
	SideCompass.setButtonVisible(v)
end

function SideCompass.setTrackerDocked(p, flag: boolean)
	v6[p] = flag and true or nil
	SideCompass._instance.Frame.Button.ImageLabel.Visible = next(v6) == nil
end

function SideCompass.setRotation(rotation: number)
	SideCompass._instance.Frame.GuideIcon.Rotation = rotation
end

function SideCompass.setImageColor(imageColor: Color3)
	local _ = SideCompass.COMPASS_BILLBOARD_SHOW_ISLAND_WHEN_TRACKING
	SideCompass._instance.Frame.GuideIcon.ImageColor3 = imageColor
end

function SideCompass.setButtonVisible(flag: boolean)
	v = flag

	if SideCompass.COMPASS_BILLBOARD_SHOW_ISLAND_WHEN_TRACKING and not v3 then
		flag = false
	end

	local visible = flag and not v5
	SideCompass._instance.Frame.Button.Visible = visible
end

GuideData.HandleUpdate("CompassUnlocked", function(flag: boolean)
	v3 = flag
	SideCompass.setButtonVisible(v)
	updateInstanceVisibility() -- equivalent call inferred; original call site unknown
end)

function SideCompass.setButtonImageColor(imageColor: Color3)
	SideCompass._instance.Frame.Button.ImageColor3 = imageColor
end

return SideCompass