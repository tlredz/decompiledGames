local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local mouse

if localPlayer then
	mouse = localPlayer:GetMouse() or nil
else
	mouse = nil
end

if mouse then
	mouse.TargetFilter = workspace._WorldOrigin
end

local UserInputService = game:GetService("UserInputService")

-- equivalent calls inferred from this helper; original call sites unknown
local function mobile()
	return UserInputService.TouchEnabled and not UserInputService.MouseEnabled
end

local cframe = CFrame.Angles(0, 3.141592653589793, 0)
local isMobile

if localPlayer then
	isMobile = mobile()
else
	isMobile = false
end

if not localPlayer then
	return mouse
end

local viewportSize = currentCamera.ViewportSize
mouse = {
	X = viewportSize.X / 2,
	Y = viewportSize.Y / 2 - 75,
	Hit = CFrame.new(),
	Target = nil,
	TargetFilter = { localPlayer.Character, workspace._WorldOrigin },
	isMobile = isMobile,
	IsUsingGamepad = false
}
local gamepad1 = Enum.UserInputType.Gamepad1
local gamepad2 = Enum.UserInputType.Gamepad2
local gamepad3 = Enum.UserInputType.Gamepad3
UserInputService.InputBegan:Connect(function(input)
	local userInputType = input.UserInputType

	if userInputType == gamepad1 or userInputType == gamepad2 or userInputType == gamepad3 then
		mouse.IsUsingGamepad = userInputType
	else
		mouse.IsUsingGamepad = false
	end
end)
localPlayer.CharacterAdded:Connect(function(character)
	mouse.TargetFilter = { character, workspace._WorldOrigin }
end)

local function onChange(data)
	if isMobile then
		local Global = require(game.ReplicatedStorage.Global)

		if Global.Shiftlock then
			mouse.X = currentCamera.ViewportSize.X / 2
			mouse.Y = currentCamera.ViewportSize.Y / 2 - 75
		elseif data then
			if typeof(data) == "Vector2" then
				mouse.X = data.X
				mouse.Y = data.Y
			else
				mouse.X = data.Position.X
				mouse.Y = data.Position.Y
			end
		end
	end
end

setmetatable(mouse, {
	__index = function(_, p)
		if p == "X" then
			local Global = require(game.ReplicatedStorage.Global)

			if Global.CurrentTouchObjectForMouse then
				local Global2 = require(game.ReplicatedStorage.Global)
				onChange(Global2.CurrentTouchObjectForMouse)
			end

			return (rawget(mouse, "X"))
		else
			local v2 = mouse[p]

			if typeof(v2) == "function" then
				return function(_, ...)
					return v2(mouse, ...)
				end
			end

			return v2
		end
	end
})
local GetRayFromMousePoint

if isMobile then
	GetRayFromMousePoint = function(p)
		local screenPointToRay = currentCamera:ScreenPointToRay(mouse.X, mouse.Y, p)
		local v2 = screenPointToRay.Origin + screenPointToRay.Direction
		return Ray.new(currentCamera.CoordinateFrame.p, v2 - currentCamera.CoordinateFrame.p)
	end
else
	GetRayFromMousePoint = function(p)
		local screenPointToRay = currentCamera:ScreenPointToRay(mouse.X, mouse.Y, p)
		local v2 = screenPointToRay.Origin + screenPointToRay.Direction
		return Ray.new(currentCamera.CoordinateFrame.p, v2 - currentCamera.CoordinateFrame.p)
	end
end

local changedConnection = nil
local v2 = nil
local UserInputService2 = game:GetService("UserInputService")
UserInputService2.InputBegan:connect(function(data, p)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.CurrentTouchObjectForMouse or p then
		return
	end

	if changedConnection and (v2.UserInputState == Enum.UserInputState.End or v2.UserInputState == Enum.UserInputState.Cancel) then
		changedConnection:Disconnect()
		changedConnection = nil
	end

	if p or changedConnection then
		return
	end

	if data.UserInputType == Enum.UserInputType.Touch then
		v2 = data
		changedConnection = data.Changed:Connect(function(p2)
			local Global2 = require(game.ReplicatedStorage.Global)

			if Global2.CurrentTouchObjectForMouse then
				return
			end

			if data.UserInputState == Enum.UserInputState.End or data.UserInputState == Enum.UserInputState.Cancel then
				changedConnection:Disconnect()
				changedConnection = nil
			elseif p2 == "Position" then
				onChange(data)
			end
		end)
		onChange(data)
	end
end)

local function fn()
	local localPlayer2 = localPlayer
	local position = localPlayer2.Character:GetPivot().Position
	local v4 = 1e999
	local v5 = nil
	local humanoidRootPart = nil

	for _, v6 in pairs(game.Players:GetPlayers()) do
		if v6 == localPlayer2 then
			continue
		end

		local position2 = v6.Character:GetPivot().Position
		local magnitude = (position2 - position).Magnitude

		if not (v6.Character and magnitude < v4) then
			continue
		end

		humanoidRootPart = v6.Character.HumanoidRootPart
		v5 = position2
	end

	return v5, humanoidRootPart
end

local function updateMouse()
	if localPlayer:GetAttribute("AAIM") then
		local _ = localPlayer.Character:GetPivot().Position
		local v3, target = fn()
		mouse.Hit = CFrame.new(v3, currentCamera.CoordinateFrame.p) * cframe
		mouse.Target = target
	else
		local rayFromMousePoint = GetRayFromMousePoint(9999)
		local humanoidRootPart, v4, _ = workspace:FindPartOnRayWithIgnoreList(rayFromMousePoint, mouse.TargetFilter)
		mouse.Hit = CFrame.new(v4, currentCamera.CoordinateFrame.p) * cframe

		if humanoidRootPart then
			local parent = humanoidRootPart.Parent

			if parent.Parent.Name == "DragonHitboxesClient" then
				local value = parent.Object.Value

				if value and value.Character then
					humanoidRootPart = value.Character:FindFirstChild("HumanoidRootPart")
				end
			end
		end

		mouse.Target = humanoidRootPart
	end
end

if not isMobile then
	mouse.Move:Connect(function()
		updateMouse()
	end)
end

local Global = require(game.ReplicatedStorage.Global)

function Global.updateMouseWrapper()
	if isMobile then
		local Global2 = require(game.ReplicatedStorage.Global)
		local currentTouchObjectForMouse = Global2.CurrentTouchObjectForMouse

		if currentTouchObjectForMouse then
			onChange(currentTouchObjectForMouse)
		else
			onChange(UserInputService.MouseEnabled and Vector2.new(mouse.X, mouse.Y))
		end
	end

	updateMouse()
end

task.spawn(function()
	while true do
		local success, result = pcall(function()
			while task.wait() do
				if isMobile then
					local Global2 = require(game.ReplicatedStorage.Global)
					local currentTouchObjectForMouse = Global2.CurrentTouchObjectForMouse

					if currentTouchObjectForMouse then
						onChange(currentTouchObjectForMouse)
					else
						onChange(UserInputService.MouseEnabled and Vector2.new(mouse.X, mouse.Y))
					end
				end

				updateMouse()
			end
		end)

		if not success then
			print(result)
		end

		task.wait()
	end
end)
return mouse