local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local _ = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local function WrapMouse()
	local viewportSize = currentCamera.ViewportSize
	local v = {
		X = viewportSize.X / 2,
		Y = viewportSize.Y / 2,
		Hit = CFrame.new(),
		Target = nil,
		TargetFilter = { workspace.Map }
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetRayFromScreenPoint(p, X, Y)
		local viewportPointToRay = currentCamera:ViewportPointToRay(X, Y, p)
		local v2 = viewportPointToRay.Origin + viewportPointToRay.Direction
		return Ray.new(currentCamera.CFrame.Position, v2 - currentCamera.CFrame.Position)
	end

	local function computeXYFromState()
		local Global = require(game.ReplicatedStorage.Global)

		if Global.Shiftlock then
			v.X = currentCamera.ViewportSize.X / 2
			v.Y = currentCamera.ViewportSize.Y / 2 - 36
		elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and v._lastTouchPos then
			v.X = v._lastTouchPos.X
			v.Y = v._lastTouchPos.Y
		elseif UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			local viewportSize2 = currentCamera.ViewportSize
			v.X = viewportSize2.X * 0.5
			v.Y = viewportSize2.Y * 0.5
		else
			local mouseLocation = UserInputService:GetMouseLocation()
			v.X = mouseLocation.X
			v.Y = mouseLocation.Y
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateRay()
		computeXYFromState()
		local rayFromScreenPoint = GetRayFromScreenPoint(999, v.X, v.Y) -- equivalent call inferred; original call site unknown
		local part, v3 = workspace:FindPartOnRayWithWhitelist(rayFromScreenPoint, v.TargetFilter)
		v.Target = part
		v.Hit = CFrame.new(v3, currentCamera.CFrame.Position) * cframe
	end

	local connections = {}
	connections[#connections + 1] = UserInputService.TouchStarted:Connect(function(p)
		v._lastTouchPos = p.Position
		updateRay() -- equivalent call inferred; original call site unknown
	end)
	connections[#connections + 1] = UserInputService.TouchMoved:Connect(function(p)
		v._lastTouchPos = p.Position
		updateRay() -- equivalent call inferred; original call site unknown
	end)
	connections[#connections + 1] = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			updateRay() -- equivalent call inferred; original call site unknown
		end
	end)
	connections[#connections + 1] = RunService.RenderStepped:Connect(function()
		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			updateRay() -- equivalent call inferred; original call site unknown
		end
	end)
	updateRay() -- equivalent call inferred; original call site unknown

	local function Destroy()
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	return v, Destroy, updateRay
end

return WrapMouse