local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function IsHoverable(data)
	return data.Active and data.Interactable and data.Visible
end

local function HookButton(button)
	button.MouseEnter:Connect(function()
		if IsHoverable(button) then
			v = button
		end
	end)
	button.MouseLeave:Connect(function()
		if v == button then
			v = nil
		end
	end)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and IsHoverable(button) then
			v = button
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and v == button then
			v = nil
		end
	end)
	button.Destroying:Connect(function()
		if v == button then
			v = nil
		end
	end)
end

local function WatchContainer(folder)
	for _, button in folder:GetDescendants() do
		if button:IsA("GuiButton") then
			HookButton(button)
		end
	end

	folder.DescendantAdded:Connect(function(button)
		if button:IsA("GuiButton") then
			HookButton(button)
		end
	end)
end

WatchContainer(playerGui)
WatchContainer(workspace)

local function SurfaceCanvasPoint(gui, part, p)
	local pointToObjectSpace = part.CFrame:PointToObjectSpace(p)
	local size = part.Size
	local face = gui.Face
	local v2, v3

	if face == Enum.NormalId.Front then
		v2 = (size.X / 2 - pointToObjectSpace.X) / size.X
		v3 = (size.Y / 2 - pointToObjectSpace.Y) / size.Y
	elseif face == Enum.NormalId.Back then
		v2 = (pointToObjectSpace.X + size.X / 2) / size.X
		v3 = (size.Y / 2 - pointToObjectSpace.Y) / size.Y
	elseif face == Enum.NormalId.Right then
		v2 = (size.Z / 2 - pointToObjectSpace.Z) / size.Z
		v3 = (size.Y / 2 - pointToObjectSpace.Y) / size.Y
	elseif face == Enum.NormalId.Left then
		v2 = (pointToObjectSpace.Z + size.Z / 2) / size.Z
		v3 = (size.Y / 2 - pointToObjectSpace.Y) / size.Y
	elseif face == Enum.NormalId.Top then
		v2 = (pointToObjectSpace.X + size.X / 2) / size.X
		v3 = (pointToObjectSpace.Z + size.Z / 2) / size.Z
	else
		v2 = (pointToObjectSpace.X + size.X / 2) / size.X
		v3 = (size.Z / 2 - pointToObjectSpace.Z) / size.Z
	end

	local absoluteSize = gui.AbsoluteSize
	return Vector2.new(v2 * absoluteSize.X, v3 * absoluteSize.Y)
end

local function ButtonAtCanvasPoint(folder, p)
	for _, button in folder:GetDescendants() do
		if not (button:IsA("GuiButton") and IsHoverable(button)) then
			continue
		end

		local absolutePosition = button.AbsolutePosition
		local absoluteSize = button.AbsoluteSize

		if p.X >= absolutePosition.X and p.X <= absolutePosition.X + absoluteSize.X and p.Y >= absolutePosition.Y and p.Y <= absolutePosition.Y + absoluteSize.Y then
			return button
		end
	end

	return nil
end

local function HalfDepth(part, face)
	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return part.Size.Z / 2
	end

	if face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return part.Size.X / 2
	end

	return part.Size.Y / 2
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function FindHoveredSurfaceButton()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointToRay = currentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local origin = viewportPointToRay.Origin
	local direction = viewportPointToRay.Direction
	local v2 = {}

	for _, surfaceGui in playerGui:GetChildren() do
		if not (surfaceGui:IsA("SurfaceGui") and surfaceGui.Enabled) then
			continue
		end

		local adornee = surfaceGui.Adornee

		if typeof(adornee) == "Instance" and adornee:IsA("BasePart") then
			table.insert(v2, {
				Gui = surfaceGui,
				Part = adornee
			})
		end
	end

	raycastParams.FilterDescendantsInstances = { localPlayer.Character }
	local raycastResult = workspace:Raycast(origin, direction * 500, raycastParams)

	if raycastResult then
		for _, surfaceGui in raycastResult.Instance:GetChildren() do
			if surfaceGui:IsA("SurfaceGui") and surfaceGui.Enabled then
				table.insert(v2, {
					Gui = surfaceGui,
					Part = raycastResult.Instance
				})
			end
		end
	end

	local v3 = 1e999
	local v4 = nil

	for _, v5 in v2 do
		local gui = v5.Gui
		local part = v5.Part
		local vectorToWorldSpace = part.CFrame:VectorToWorldSpace(Vector3.fromNormalId(gui.Face))
		local dot = direction:Dot(vectorToWorldSpace)

		if not (dot < 0) then
			continue
		end

		local v6 = (part.Position + vectorToWorldSpace * HalfDepth(part, gui.Face) - origin):Dot(vectorToWorldSpace) / dot

		if not (v6 > 0 and v6 <= 500 and v6 < v3) then
			continue
		end

		local surfaceCanvasPoint = SurfaceCanvasPoint(gui, part, origin + direction * v6)
		local absoluteSize = gui.AbsoluteSize

		if not (surfaceCanvasPoint.X >= 0 and surfaceCanvasPoint.X <= absoluteSize.X and surfaceCanvasPoint.Y >= 0 and surfaceCanvasPoint.Y <= absoluteSize.Y) then
			continue
		end

		local buttonAtCanvasPoint = ButtonAtCanvasPoint(gui, surfaceCanvasPoint)

		if not buttonAtCanvasPoint then
			continue
		end

		v4 = buttonAtCanvasPoint
		v3 = v6
	end

	return v4
end

local v2 = false
local mouseIcon = ""
local v3 = nil
local hover = script:WaitForChild("Hover")
RunService.RenderStepped:Connect(function()
	if v then
		if v:IsDescendantOf(game) then
			if not IsHoverable(v) then
				v = nil
			end
		else
			v = nil
		end
	end

	local v4 = v or FindHoveredSurfaceButton()

	if v4 ~= v3 then
		v3 = v4

		if v4 then
			hover:Play()
		end
	end

	local v5 = v4 ~= nil

	if v5 == v2 then
		return
	end

	v2 = v5

	if v5 then
		mouseIcon = UserInputService.MouseIcon
		UserInputService.MouseIcon = "rbxasset://SystemCursors/PointingHand"
	elseif UserInputService.MouseIcon == "rbxasset://SystemCursors/PointingHand" then
		UserInputService.MouseIcon = mouseIcon
	end
end)