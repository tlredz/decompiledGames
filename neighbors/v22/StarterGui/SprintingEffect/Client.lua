local parent = script.Parent
local template = parent:WaitForChild("Template")
parent.Template.Image = "rbxassetid://6924361000"
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local _ = workspace.CurrentCamera
character:WaitForChild("HumanoidRootPart")
character:WaitForChild("Humanoid")
local sine = Enum.EasingStyle.Sine
local v = Enum.EasingDirection.In
local v2 = {}
v2[1], v2[2], v2[3], v2[4] = false, false, false, false

local function GetX(p)
	local X = parent.AbsoluteSize.X

	if p == 1 or p == 2 then
		return (math.random(X / 2, X))
	end

	return (math.random(1, X / 2))
end

local function GetY(p)
	local Y = parent.AbsoluteSize.Y

	if p == 1 or p == 4 then
		return (math.random(1, Y / 2))
	end

	return (math.random(Y / 2, Y))
end

local function GetRandomPos()
	local X = parent.AbsoluteSize.X
	local Y = parent.AbsoluteSize.Y
	local X2 = parent.AbsoluteSize.X
	local v3 = math.random(1, X2 / 2)
	local Y2 = parent.AbsoluteSize.Y
	local v4 = math.random(Y2 / 2, Y2)
	local v5 = math.random(1, 4)

	if v2[v5] == false then
		v2[v5] = true
		local X3 = parent.AbsoluteSize.X

		if v5 == 1 or v5 == 2 then
			v3 = math.random(X3 / 2, X3)
		else
			v3 = math.random(1, X3 / 2)
		end

		local Y3 = parent.AbsoluteSize.Y

		if v5 == 1 or v5 == 4 then
			v4 = math.random(1, Y3 / 2)
		else
			v4 = math.random(Y3 / 2, Y3)
		end
	else
		local v6 = false

		for i = 1, 4 do
			if v2[i] ~= false then
				continue
			end

			v2[i] = true
			v6 = true
			local X3 = parent.AbsoluteSize.X

			if i == 1 or i == 2 then
				v3 = math.random(X3 / 2, X3)
			else
				v3 = math.random(1, X3 / 2)
			end

			local Y3 = parent.AbsoluteSize.Y

			if i == 1 or i == 4 then
				v4 = math.random(1, Y3 / 2)
			else
				v4 = math.random(Y3 / 2, Y3)
			end

			break
		end

		if not v6 then
			v2 = {
				false,
				false,
				false,
				false
			}
			local v7 = math.random(1, 4)
			v2[v7] = true
			local X3 = parent.AbsoluteSize.X

			if v7 == 1 or v7 == 2 then
				v3 = math.random(X3 / 2, X3)
			else
				v3 = math.random(1, X3 / 2)
			end

			local Y3 = parent.AbsoluteSize.Y

			if v7 == 1 or v7 == 4 then
				v4 = math.random(1, Y3 / 2)
			else
				v4 = math.random(Y3 / 2, Y3)
			end
		end
	end

	local v6 = v3 - 0.001
	local v7 = v4 - 0.001

	if (math.random(1, 2) == 1 and "X" or "Y") == "X" then
		local v8 = math.random(0, 1)
		local v9

		if v8 == 0 then
			v9 = v8 - 0.07
		else
			v9 = v8 + 0.07
		end

		return (UDim2.fromScale(v6 / X, v9))
	else
		local v8 = math.random(0, 1)
		local v9

		if v8 == 0 then
			v9 = v8 - 0.07
		else
			v9 = v8 + 0.07
		end

		return (UDim2.fromScale(v9, v7 / Y))
	end
end

local function GetRotation(p)
	local v3 = p.X.Scale - 0.5
	local v4 = 0.5 - p.Y.Scale
	local v5 = math.sqrt(math.abs(v3) ^ 2 + math.abs(v4) ^ 2)
	local v6

	if p.X.Scale > 0.5 and p.Y.Scale < 0.5 then
		v6 = 1
	elseif p.X.Scale < 0.5 and p.Y.Scale < 0.5 then
		v6 = 4
	elseif p.X.Scale < 0.5 and p.Y.Scale > 0.5 then
		v6 = 3
	elseif p.X.Scale > 0.5 and p.Y.Scale > 0.5 then
		v6 = 2
	else
		v6 = nil
	end

	if v6 == 1 or v6 == 3 then
		v4 = v3
	end

	if v6 == 1 or v6 == 4 then
		return math.deg((math.asin(v4 / v5))) + (v6 - 1) * 90
	end

	return math.deg(-math.asin(v4 / v5)) + (v6 - 1) * 90
end

local function CreateTriangle(position, rotation, duration)
	local clone = template:Clone()
	clone.Visible = true
	clone.Parent = parent
	clone.Position = position
	clone.Rotation = rotation
	clone.ImageTransparency = 1
	clone:SetAttribute("OriginalPosX", clone.Position.X.Scale)
	clone:SetAttribute("OriginalPosY", clone.Position.Y.Scale)
	local v3 = tonumber("0.0" .. tostring(math.random(3, 5)))
	local v4 = tonumber("0." .. tostring(math.random(4, 7)))
	clone.Size = UDim2.fromScale(v3, v4)
	TweenService:Create(clone, TweenInfo.new(0.4), {
		ImageTransparency = 0
	}):Play()
	task.delay(0.2, function()
		local tween = TweenService:Create(clone, TweenInfo.new(duration, sine, v), {
			ImageTransparency = 1
		})
		tween:Play()
		tween.Completed:Wait()
		clone:Destroy()
	end)
end

local function AdjustOffset(p)
	for _, image in pairs(parent:GetChildren()) do
		if not (image:IsA("ImageLabel") and image:GetAttribute("OriginalPosX")) then
			continue
		end

		local v3 = (image:GetAttribute("OriginalPosX") - 0.5) * p
		local v4 = (0.5 - image:GetAttribute("OriginalPosY")) * p
		image.Position = UDim2.fromScale(0.5 + v3, 0.5 + v4)
	end
end

local thread = coroutine.create(function()
	while task.wait() do
		if not character:GetAttribute("Sprinting") then
			coroutine.yield()
		end

		local position = GetRandomPos()
		CreateTriangle(position, GetRotation(position), 0.2)
	end
end)
character:GetAttributeChangedSignal("Sprinting"):Connect(function()
	if not character:GetAttribute("Sprinting") then
		TweenService:Create(workspace.Camera, TweenInfo.new(0.3), {
			FieldOfView = 70
		}):Play()
		return
	end

	coroutine.resume(thread)
	TweenService:Create(workspace.Camera, TweenInfo.new(0.3), {
		FieldOfView = 90
	}):Play()
end)