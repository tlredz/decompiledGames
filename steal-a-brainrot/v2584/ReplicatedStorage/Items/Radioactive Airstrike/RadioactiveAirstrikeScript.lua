local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local parent = script.Parent
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
local v = nil
local thread = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function StopPulse()
	if thread then
		if coroutine.status(thread) ~= "suspended" then
			task.cancel(thread)
		end

		thread = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StarPulse()
	if thread then
		return
	end

	thread = task.spawn(function()
		while v do
			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			local tween = TweenService:Create(v, tweenInfo, {
				Transparency = 0.3
			})
			tween:Play()
			tween.Completed:Wait()

			if not (v and v.Parent) then
				return
			end

			local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local tween2 = TweenService:Create(v, tweenInfo2, {
				Transparency = 0.7
			})
			tween2:Play()
			tween2.Completed:Wait()
		end

		thread = nil
	end)
end

local function CreateCircle()
	if v and v.Parent then
		return v
	end

	local part = Instance.new("Part")
	part.Size = createVector(36, 0.1, 36)
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Material = Enum.Material.Neon
	part.Transparency = 0.3
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Anchored = true
	local cylinderMesh = Instance.new("CylinderMesh")
	cylinderMesh.Parent = part
	part.Orientation = createVector(0, 0, 0)
	part.Parent = workspace
	v = part
	StarPulse() -- equivalent call inferred; original call site unknown
	return v
end

parent.Activated:Connect(function()
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	Net:RemoteEvent("UseItem"):FireServer(v2 and v2 or PlayerMouse.Hit.Position)
end)
parent.Equipped:Connect(function()
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local character = localPlayer.Character

	if not character then
		return
	end

	RunService:UnbindFromRenderStep("ShowCircle")
	RunService:BindToRenderStep("ShowCircle", Enum.RenderPriority.Character.Value + 1, function()
		if parent:GetAttribute("CooldownTime") then
			v2 = nil
			return
		end

		local circle = CreateCircle()
		local hit = PlayerMouse.Hit

		if not hit then
			v2 = nil
			return
		end

		local v4 = hit.Position + createVector(0, 5, 0)
		local characters = {}

		for _, v5 in Players:GetPlayers() do
			if v5 == localPlayer then
				continue
			end

			local character2 = v5.Character

			if character2 then
				table.insert(characters, character2)
			end
		end

		raycastParams.FilterDescendantsInstances = { character, table.unpack(characters) }
		local raycastResult = workspace:Raycast(v4, createVector(0, -50, 0), raycastParams)

		if raycastResult then
			circle.Position = raycastResult.Position + createVector(0, 0.02, 0)
			v2 = raycastResult.Position + createVector(0, 0.02, 0)
		end
	end)
end)
parent.Unequipped:Connect(function()
	RunService:UnbindFromRenderStep("ShowCircle")
	StopPulse() -- equivalent call inferred; original call site unknown

	if v then
		v:Destroy()
		v = nil
	end
end)
parent:GetAttributeChangedSignal("CooldownTime"):Connect(function()
	if parent:GetAttribute("CooldownTime") then
		StopPulse() -- equivalent call inferred; original call site unknown
		v2 = nil

		if v then
			v:Destroy()
			v = nil
		end
	end
end)