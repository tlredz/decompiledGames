local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local mouse = localPlayer:GetMouse()
mouse.TargetFilter = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function mobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local cframe = CFrame.Angles(0, 3.141592653589793, 0)

local function WrapMouse(p)
	local viewportSize = currentCamera.ViewportSize
	local v = {
		X = viewportSize.X / 2,
		Y = viewportSize.Y / 2,
		Hit = CFrame.new(),
		Target = nil,
		TargetFilter = { localPlayer.Character, workspace._WorldOrigin }
	}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function GetRayFromMousePoint(p2, X, Y)
		local viewportPointToRay = currentCamera:ViewportPointToRay(X, Y, p2)
		local v2 = viewportPointToRay.Origin + viewportPointToRay.Direction
		return Ray.new(currentCamera.CoordinateFrame.p, v2 - currentCamera.CoordinateFrame.p)
	end

	local function onChange(data)
		local Global = require(game.ReplicatedStorage.Global)

		if Global.Shiftlock then
			v.X = currentCamera.ViewportSize.X / 2
			v.Y = currentCamera.ViewportSize.Y / 2 - 36
		elseif typeof(data) == "Vector2" then
			v.X = data.X
			v.Y = data.Y
		else
			v.X = data.Position.X
			v.Y = data.Position.Y
		end

		local rayFromMousePoint = GetRayFromMousePoint(999, v.X, v.Y) -- equivalent call inferred; original call site unknown
		local part, v3, _ = game.Workspace:FindPartOnRayWithIgnoreList(rayFromMousePoint, v.TargetFilter)
		v.Hit = CFrame.new(v3, currentCamera.CoordinateFrame.p) * cframe
		v.Target = part
	end

	local changedConnection = nil

	if mobile() then
		changedConnection = p.Changed:Connect(function(p2)
			if p.UserInputState == Enum.UserInputState.End or p.UserInputState == Enum.UserInputState.Cancel then
				changedConnection:Disconnect()
				changedConnection = nil
			elseif p2 == "Position" then
				onChange(p)
			end
		end)
		onChange(p)
	else
		changedConnection = UserInputService.InputChanged:Connect(function(input)
			if p.UserInputState == Enum.UserInputState.End then
				changedConnection:Disconnect()
				changedConnection = nil
			elseif input.Position then
				onChange(UserInputService:GetMouseLocation())
			end
		end)
		onChange(UserInputService:GetMouseLocation())
	end

	return v, function()
		if not changedConnection then
			return
		end

		changedConnection:Disconnect()
		changedConnection = nil
	end, function()
		onChange(UserInputService:GetMouseLocation())
	end
end

return WrapMouse