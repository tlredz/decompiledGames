local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
require3(ReplicatedStorage2.Shared.ThreadSafeTargetingHelper)
require3(ReplicatedStorage2.Misc.LightningBolt)
require3(ReplicatedStorage2.Misc.LightningBolt.LightningSparks)
require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v = require3(ReplicatedStorage2.Shared.SpeedModifiers)
local v2 = require3(ReplicatedStorage2.Packages.Observers)

local function doCast(data)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace.Alive }
	return workspace:Raycast(data.rootPart.Position, createVector(-0, -100, -0), raycastParams)
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Runtime }
local raycastParams2 = RaycastParams.new()
raycastParams2.FilterType = Enum.RaycastFilterType.Include
raycastParams2.FilterDescendantsInstances = { workspace.Runtime }

if RunService:IsClient() then
	local localPlayer = Players.LocalPlayer
	v2.observeTag("PlatformObject", function(instance)
		if instance:GetAttribute("Owner") == localPlayer.UserId then
			instance.CanCollide = true
			return nil
		end

		instance.CanCollide = false
		return v2.observeDescendants(instance, function(part)
			if part:IsA("BasePart") then
				part.CanCollide = false
			end

			return nil
		end)
	end, { workspace.Runtime })
end

local filterDescendantsInstances = {}

local function updateOwnedPlatforms()
	if RunService:IsClient() then
		local filterDescendantsInstances2 = {}

		for _, v5 in filterDescendantsInstances do
			if v5:GetAttribute("Owner") == Players.LocalPlayer.UserId then
				table.insert(filterDescendantsInstances2, v5)
			end
		end

		raycastParams2.FilterDescendantsInstances = filterDescendantsInstances2
	end
end

v2.observeTag("PlatformObject", function(p)
	table.insert(filterDescendantsInstances, p)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	updateOwnedPlatforms()
	return function()
		local index = table.find(filterDescendantsInstances, p)

		if index then
			table.remove(filterDescendantsInstances, index)
			raycastParams.FilterDescendantsInstances = filterDescendantsInstances
			updateOwnedPlatforms()
		end
	end
end, { workspace.Runtime })
local Platform = {}
Platform.cooldown = 30
Platform.cooldownReductionPerUpgrade = 3.75
Platform.iconId = "rbxassetid://14377836406"

function Platform.canBeUsed(data)
	if RunService:IsClient() and data.humanoid.FloorMaterial == Enum.Material.Air or doCast(data) == nil then
		return false
	end

	local v4 = 75 * (1 + 0.5 * data.upgradeLevel)
	local raycastParams3 = RaycastParams.new()
	raycastParams3.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams3.FilterDescendantsInstances = { workspace.Alive }

	if workspace:Raycast(data.rootPart.Position, createVector(0, 1, 0) * (v4 + 4.5), raycastParams3) then
		return false
	end

	return true
end

function Platform.localOwnerActivation(p, p2)
	local v4 = v:SetModifierFor(p.character, "Platform", v.Utils.MinDebuff(p.character, 0), v.Priority.DEBUFF)
	task.delay(0.3, v4)
	local animator = p.character:FindFirstChildWhichIsA("Animator", true)

	if animator then
		animator:LoadAnimation(script.PlatformAnimation):Play(0.05, 1, 0.75)
	end

	local postSimulationConnection = nil
	local cFrame = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function startPlatformUpdate()
		if postSimulationConnection then
			postSimulationConnection:Disconnect()
		end

		cFrame = nil
		local rootPart = p.rootPart
		postSimulationConnection = RunService.PostSimulation:Connect(function()
			if rootPart.Parent then
				local cFrame2 = rootPart.CFrame
				local raycastResult = workspace:Raycast(
					cFrame2.Position + createVector(0, 15, 0),
					createVector(-0, -35, -0),
					raycastParams2
				)

				if not (raycastResult and raycastResult.Instance) then
					cFrame = nil
					return
				end

				if not cFrame then
					cFrame = raycastResult.Instance.CFrame
				end

				local cFrame3 = raycastResult.Instance.CFrame
				local v5 = cFrame3 * cFrame:Inverse()
				cFrame = cFrame3
				rootPart.CFrame = v5 * cFrame2
			elseif postSimulationConnection then
				postSimulationConnection:Disconnect()
				postSimulationConnection = nil
			end
		end)
	end

	startPlatformUpdate() -- equivalent call inferred; original call site unknown
	p2.addCleaner(function()
		if postSimulationConnection then
			postSimulationConnection:Disconnect()
			postSimulationConnection = nil
		end
	end)
	return nil
end

function Platform.serverActivationAsync(data, _)
	local raycastResult = doCast(data)

	if not raycastResult then
		return
	end

	local clone = ReplicatedStorage2.Misc.Platform:Clone()

	if data.upgradeLevel >= 2 then
		clone.Size = createVector(15, 0.1, 15)
	else
		clone.Size = createVector(10, 0.1, 10)
	end

	clone.Name = "Vanity"
	clone.Sound:Play()
	clone.Rocks:Play()
	clone.CFrame = CFrame.new((Vector3.new(data.rootPart.Position.X, raycastResult.Position.Y, data.rootPart.Position.Z))) * data.rootPart.CFrame.Rotation
	clone.Color = raycastResult.Instance.Color
	clone.Material = raycastResult.Material
	clone.CollisionGroup = "LockedParts"
	clone.Outlinez:PivotTo(clone:GetPivot())
	clone.dos:PivotTo(clone:GetPivot())
	clone.diggle:PivotTo(clone:GetPivot())
	clone:SetAttribute("Owner", data.player.UserId)
	local pathfindingModifier = Instance.new("PathfindingModifier")
	pathfindingModifier.Label = "MapBoundaries"
	pathfindingModifier.PassThrough = false
	pathfindingModifier.Parent = clone
	clone.Parent = workspace.Runtime
	clone:AddTag("PlatformObject")
	local v4 = 75 * (1 + 0.5 * data.upgradeLevel)
	TweenService:Create(clone, TweenInfo.new(2), {
		Size = clone.Size + Vector3.new(0, v4, 0),
		CFrame = clone.CFrame + Vector3.new(0, v4 / 2, 0)
	}):Play()
	data.rootPart.CFrame += createVector(0, 2, 0)
	Debris:AddItem(clone, 25)
	local diggle = clone.diggle
	diggle.Parent = workspace
	Debris:AddItem(diggle, 3)
	TweenService:Create(diggle, TweenInfo.new(2), {
		Position = clone.Position + Vector3.new(0, v4 + 3, 0)
	}):Play()
	local outlinez = clone.Outlinez

	if data.upgradeLevel >= 2 then
		outlinez = clone.dos
	end

	for _, descendant in outlinez:GetDescendants() do
		if descendant.Name ~= "dust" then
			continue
		end

		descendant.Color = ColorSequence.new(clone.Color)
		descendant.Enabled = true
		local v5 = descendant
		task.delay(2.25, function()
			v5.Enabled = false
		end)
	end

	task.spawn(function()
		local total = 3.1

		if data.upgradeLevel >= 1 then
			total += 1
		end

		if data.upgradeLevel >= 2 then
			total += 2
		end

		for _ = 0, total do
			task.wait(1.5 / total)
			local clone2 = ReplicatedStorage2.Misc.Wave:Clone()
			clone2.Parent = workspace.Runtime
			Debris:AddItem(clone2, 1.5)
			clone2.Transparency = 0
			clone2.Size = createVector(0.01, 0.5, 0.01)
			clone2.Color = raycastResult.Instance.Color
			clone2.CFrame = clone.CFrame
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = data.upgradeLevel >= 2 and createVector(50, 0.5, 50) or createVector(30, 0.5, 30),
				Transparency = 1
			}):Play()
		end
	end)
	local v5 = 12 - 1.5 * data.upgradeLevel
	task.delay(v5, function()
		clone.Sound:Play()
		task.delay(2, function()
			clone:Destroy()
		end)
	end)
end

return Platform