local createVector = vector.create
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local toolsExtras = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Debounce = require(packages.Debounce)
local parent = script.Parent
local parent2 = parent.Parent.Parent
local now = 0
local folder = nil
local v = false
local heartbeatConnection = nil
local v2 = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function initializeAimArch()
	if folder then
		folder:Destroy()
	end

	folder = Instance.new("Folder")
	folder.Name = "SlingshotAimArch"
	folder.Parent = workspace
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearAimArch()
	if folder then
		folder:ClearAllChildren()
	end
end

local function calculateTrajectoryWithCollision(p, total, p2, p3)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { parent2.Character, folder }
	local total2 = 0
	local result = {}

	while total2 <= p3 do
		table.insert(result, p)
		local v3 = p + total * p2
		total += createVector(0, -196.2, 0) * p2
		local raycastResult = workspace:Raycast(p, v3 - p, raycastParams)

		if raycastResult then
			table.insert(result, raycastResult.Position)
			return result
		end

		total2 += p2

		if v3.Y <= -100 then
			break
		else
			p = v3
		end
	end

	return result
end

local function createAimArch(position, value)
	clearAimArch() -- equivalent call inferred; original call site unknown
	local character = parent2.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local v3 = math.clamp(math.max(0, os.clock() - now), 0.4, 1)
	local v6 = calculateTrajectoryWithCollision(
		humanoidRootPart.Position + createVector(0, 2, 0),
		(position - humanoidRootPart.Position).Unit * 200 * v3,
		0.05,
		8
	)
	local v7 = value or "dots"

	if v7 == "dots" then
		for i, position2 in ipairs(v6) do
			if i % 2 ~= 0 then
				continue
			end

			local part = Instance.new("Part")
			part.Name = "AimDot"
			part.Shape = Enum.PartType.Ball
			part.Material = Enum.Material.Neon
			local v9 = i / #v6
			local color = Color3.new(v9, 1 - v9, 0)
			part.Color = color
			part.Size = createVector(0.3, 0.3, 0.3)
			part.Position = position2
			part.CanCollide = false
			part.Anchored = true
			part.Transparency = 0.2
			part.Parent = folder
			local pointLight = Instance.new("PointLight")
			pointLight.Color = color
			pointLight.Brightness = 0.5
			pointLight.Range = 2
			pointLight.Parent = part
		end
	elseif v7 == "line" then
		for i = 1, #v6 - 1 do
			local v8 = v6[i]
			local v9 = v6[i + 1]
			local magnitude = (v9 - v8).Magnitude
			local midpoint = (v8 + v9) / 2
			local part = Instance.new("Part")
			part.Name = "AimLine"
			part.Shape = Enum.PartType.Block
			part.Material = Enum.Material.Neon
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Size = Vector3.new(0.1, 0.1, magnitude)
			part.CFrame = CFrame.lookAt(midpoint, v9)
			part.CanCollide = false
			part.Anchored = true
			part.Transparency = 0.6
			part.Parent = folder
		end
	end

	if #v6 > 0 then
		local v8 = v6[#v6]
		local clone = toolsExtras.Ring.Union:Clone()
		clone.Name = "LandingIndicator"
		clone.Size = createVector(12, 0.25, 12)
		clone.Position = v8 + createVector(0, 0.1, 0)
		clone.Parent = folder
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Transparency = 0.8
		}):Play()
	end
end

local function updateAimArch()
	if not v then
		return
	end

	local now2 = tick()

	if now2 - v2 < 0.05 then
		return
	end

	v2 = now2
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	createAimArch(PlayerMouse.Hit.Position, "line")
end

parent.Equipped:Connect(function()
	initializeAimArch() -- equivalent call inferred; original call site unknown
end)
parent.Activated:Connect(function()
	if Debounce("ItemUse/Slingshot/", 10) then
		return
	end

	now = os.clock()
	v = true
	heartbeatConnection = RunService.Heartbeat:Connect(updateAimArch)
end)
parent.Deactivated:Connect(function()
	local _ = game.Players.LocalPlayer
	local PlayerMouse = require(ReplicatedStorage.Packages.PlayerMouse)
	local v3 = os.clock() - now
	v = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	clearAimArch() -- equivalent call inferred; original call site unknown
	Net:RemoteEvent("UseItem"):FireServer(v3, PlayerMouse.Hit.Position, PlayerMouse.Target)
end)
parent.Unequipped:Connect(function()
	v = false

	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	if folder then
		folder:Destroy()
		folder = nil
	end
end)