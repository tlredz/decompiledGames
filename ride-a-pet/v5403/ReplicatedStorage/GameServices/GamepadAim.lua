local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local GamepadAim = {}
local buttonR2 = Enum.KeyCode.ButtonR2
local v = {}
local v2 = {}
local v3 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function LastInputIsGamepad()
	return string.sub(UserInputService:GetLastInputType().Name, 1, 7) == "Gamepad"
end

local function IsShowing(parent)
	while parent do
		if parent:IsA("GuiObject") and not parent.Visible then
			return false
		end

		if parent:IsA("LayerCollector") then
			return parent.Enabled
		else
			parent = parent.Parent
		end
	end

	return false
end

local function LayerOf(p)
	local parent = p.Parent

	while parent do
		if parent:IsA("LayerCollector") then
			return parent
		else
			parent = parent.Parent
		end
	end

	return nil
end

local function RectContains(p, point: Vector2)
	local absolutePosition = p.AbsolutePosition
	local absoluteSize = p.AbsoluteSize
	return point.X >= absolutePosition.X and point.X <= absolutePosition.X + absoluteSize.X and point.Y >= absolutePosition.Y and point.Y <= absolutePosition.Y + absoluteSize.Y
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AimPoint()
	local mouseLocation = UserInputService:GetMouseLocation()
	local guiInset = GuiService:GetGuiInset()
	return Vector2.new(mouseLocation.X - guiInset.X, mouseLocation.Y - guiInset.Y)
end

local v4 = {}

local function SurfaceAimPoint(instance)
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return nil
	end

	local adornee = instance.Adornee

	if not adornee and instance.Parent and instance.Parent:IsA("BasePart") then
		adornee = instance.Parent
	end

	if not (adornee and adornee:IsA("BasePart")) then
		return nil
	end

	local mouseLocation = UserInputService:GetMouseLocation()
	local screenPointToRay = currentCamera:ScreenPointToRay(mouseLocation.X, mouseLocation.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local character = Players.LocalPlayer and Players.LocalPlayer.Character
	raycastParams.FilterDescendantsInstances = character and { character } or {}
	local raycastResult = workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * 300, raycastParams)

	if not raycastResult or raycastResult.Instance ~= adornee then
		return nil
	end

	local pointToObjectSpace = adornee.CFrame:PointToObjectSpace(raycastResult.Position)
	local size = adornee.Size
	local face = instance.Face
	local v5, v6

	if face == Enum.NormalId.Front then
		if pointToObjectSpace.Z > -size.Z / 2 + 0.05 then
			return nil
		end

		v5 = 0.5 - pointToObjectSpace.X / size.X
		v6 = 0.5 - pointToObjectSpace.Y / size.Y
	elseif face == Enum.NormalId.Back then
		if pointToObjectSpace.Z < size.Z / 2 - 0.05 then
			return nil
		end

		v5 = 0.5 + pointToObjectSpace.X / size.X
		v6 = 0.5 - pointToObjectSpace.Y / size.Y
	elseif face == Enum.NormalId.Right then
		if pointToObjectSpace.X < size.X / 2 - 0.05 then
			return nil
		end

		v5 = 0.5 - pointToObjectSpace.Z / size.Z
		v6 = 0.5 - pointToObjectSpace.Y / size.Y
	elseif face == Enum.NormalId.Left then
		if pointToObjectSpace.X > -size.X / 2 + 0.05 then
			return nil
		end

		v5 = 0.5 + pointToObjectSpace.Z / size.Z
		v6 = 0.5 - pointToObjectSpace.Y / size.Y
	else
		if face == Enum.NormalId.Top then
			if pointToObjectSpace.Y < size.Y / 2 - 0.05 then
				return nil
			end

			v5 = 0.5 + pointToObjectSpace.X / size.X
		else
			if pointToObjectSpace.Y > -size.Y / 2 + 0.05 then
				return nil
			end

			v5 = 0.5 - pointToObjectSpace.X / size.X
		end

		v6 = 0.5 + pointToObjectSpace.Z / size.Z
	end

	if v5 < 0 or v5 > 1 or v6 < 0 or v6 > 1 then
		return nil
	end

	local absoluteSize = instance.AbsoluteSize
	return Vector2.new(v5 * absoluteSize.X, v6 * absoluteSize.Y)
end

local function CachedSurfaceAimPoint(p)
	local frame = time()
	local v6 = v4[p]

	if v6 and v6.Frame == frame then
		return v6.Point
	end

	local point = SurfaceAimPoint(p)
	v4[p] = {
		Frame = frame,
		Point = point
	}
	return point
end

local function IsAimed(data)
	if not IsShowing(data) then
		return false
	end

	local parent = data.Parent

	while true do
		if not parent then
			parent = nil
			break
		end

		if parent:IsA("LayerCollector") then
			break
		else
			parent = parent.Parent
		end
	end

	if not parent then
		return false
	end

	if parent:IsA("SurfaceGui") then
		local frame = time()
		local v6 = v4[parent]
		local point

		if v6 and v6.Frame == frame then
			point = v6.Point
		else
			point = SurfaceAimPoint(parent)
			v4[parent] = {
				Frame = frame,
				Point = point
			}
		end

		if point == nil then
			return false
		else
			local absolutePosition = data.AbsolutePosition
			local absoluteSize = data.AbsoluteSize

			if point.X >= absolutePosition.X and point.X <= absolutePosition.X + absoluteSize.X and point.Y >= absolutePosition.Y then
				return point.Y <= absolutePosition.Y + absoluteSize.Y
			else
				return false
			end
		end
	elseif parent:IsA("BillboardGui") then
		local currentCamera = workspace.CurrentCamera
		local adornee = parent.Adornee or parent.Parent
		local position = nil

		if adornee and adornee:IsA("BasePart") then
			position = adornee.Position
		elseif adornee and adornee:IsA("Model") then
			position = adornee:GetPivot().Position
		elseif adornee and adornee:IsA("Attachment") then
			position = adornee.WorldPosition
		end

		if currentCamera and position then
			local _, v5 = currentCamera:WorldToViewportPoint(position)

			if not v5 then
				return false
			end
		end

		local aimPoint = AimPoint() -- equivalent call inferred; original call site unknown
		local absolutePosition = data.AbsolutePosition
		local absoluteSize = data.AbsoluteSize
		return aimPoint.X >= absolutePosition.X and aimPoint.X <= absolutePosition.X + absoluteSize.X and aimPoint.Y >= absolutePosition.Y and aimPoint.Y <= absolutePosition.Y + absoluteSize.Y
	else
		local aimPoint = AimPoint() -- equivalent call inferred; original call site unknown
		local absolutePosition = data.AbsolutePosition
		local absoluteSize = data.AbsoluteSize
		return aimPoint.X >= absolutePosition.X and aimPoint.X <= absolutePosition.X + absoluteSize.X and aimPoint.Y >= absolutePosition.Y and aimPoint.Y <= absolutePosition.Y + absoluteSize.Y
	end
end

function GamepadAim.Register(instance, callback)
	if v[instance] then
		v[instance] = callback
		return
	end

	v[instance] = callback
	v2[instance] = { instance.Destroying:Connect(function()
			GamepadAim.Unregister(instance)
		end) }
end

function GamepadAim.Unregister(instance)
	v[instance] = nil
	local v5 = v2[instance]

	if v5 then
		for _, connection in v5 do
			connection:Disconnect()
		end

		v2[instance] = nil
	end

	local gamepadAimStroke = instance:FindFirstChild("GamepadAimStroke")

	if gamepadAimStroke then
		gamepadAimStroke:Destroy()
	end
end

function GamepadAim.RegisterWorld(callback)
	table.insert(v3, callback)
end

function GamepadAim.AimedButton()
	if GamepadUI.GameplayBlocked() then
		return nil
	end

	for k in v do
		if k.Parent and IsAimed(k) then
			return k
		end
	end

	return nil
end

function GamepadAim.FireKey()
	return buttonR2
end

if not RunService:IsClient() then
	return GamepadAim
end

ContextActionService:BindAction("GamepadAimFire", function(_, p)
	if GamepadUI.GameplayBlocked() or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	local aimedButton = GamepadAim.AimedButton()

	if aimedButton then
		local v5 = v[aimedButton]

		if v5 then
			task.spawn(v5)
		end

		return Enum.ContextActionResult.Sink
	else
		for _, callback in v3 do
			local success, result = pcall(callback)

			if success and result then
				return Enum.ContextActionResult.Sink
			end
		end

		return Enum.ContextActionResult.Pass
	end
end, false, buttonR2)
local v5 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function SetOutline(parent)
	if v5 == parent then
		return
	end

	local gamepadAimStroke = v5 and v5:FindFirstChild("GamepadAimStroke")

	if gamepadAimStroke then
		gamepadAimStroke:Destroy()
	end

	v5 = parent

	if parent then
		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "GamepadAimStroke"
		uIStroke.Color = Color3.fromRGB(255, 255, 255)
		uIStroke.Thickness = 4
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Parent = parent
	end
end

local total = 0
RunService.RenderStepped:Connect(function(dt)
	total += dt

	if total < 0.05 then
		return
	end

	total = 0

	if LastInputIsGamepad() then
		SetOutline(GamepadAim.AimedButton())
		return
	end

	SetOutline(nil) -- equivalent call inferred; original call site unknown
end)
return GamepadAim