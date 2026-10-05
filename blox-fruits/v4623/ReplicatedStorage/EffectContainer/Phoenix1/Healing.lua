local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
require(game.ReplicatedStorage.Util.ScaleParticle)
local RunService = game:GetService("RunService")
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local healing = FX:WaitForChild("Phoenix1").Healing

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = { TweenInfo.new(0.25, Enum.EasingStyle.Sine) }

local function createEffect(cFrame, model, p, p2)
	local clone = model:Clone()
	clone.Parent = p2 or _WorldOrigin
	clone.Name = p or clone.Name

	if model:IsA("Model") then
		clone:SetPrimaryPartCFrame(cFrame)
		return clone
	end

	clone.CFrame = cFrame
	return clone
end

Util.ResizeModel(healing.Bubble, 0.5)
return function(player)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	local holding = player.Holding
	local humanoid = character.Humanoid

	if player.Adding then
		if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).magnitude > 500 then
			return
		end

		local clone = healing.Bubble:Clone()
		clone.Name = "PhoenixHealing" .. character.Name
		clone.Parent = _WorldOrigin
		Util.Sound:Play("PhoEnergyChargeLoop", clone.circle)

		while clone ~= nil and clone.Parent ~= nil and character:IsDescendantOf(workspace) and humanoid.Health > 0 and holding and holding.Value and holding:IsDescendantOf(workspace) and not clone:FindFirstChild("StopFollowing") do
			for _, child in pairs(clone:GetChildren()) do
				child.Position = humanoidRootPart.Position + Vector3.new(0, child:GetAttribute("Y") or 0, 0)

				if child.Name == "spinny" then
					child.Orientation += Vector3.new(
						child:GetAttribute("AngleX") or 0,
						child:GetAttribute("AngleY") or 0,
						child:GetAttribute("AngleZ") or 0
					)
				end
			end

			RunService.Heartbeat:Wait()
		end

		if clone.Name == "DESTROYING" then
			return
		end

		clone.Name = "DESTROYING"
		Debris:AddItem(clone, 1.25)
		local boolValue = Instance.new("BoolValue", clone)
		boolValue.Name = "StopFollowing"

		if clone then
			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					descendant.Enabled = false
				elseif descendant:IsA("Mesh") or descendant:IsA("Decal") or descendant:IsA("MeshPart") or descendant:IsA("Part") then
					TweenService:Create(descendant, v[1], {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("Sound") then
					Util.Sound:FadeOut(descendant, 0.5)
				end
			end
		end
	else
		local folder = _WorldOrigin:FindFirstChild("PhoenixHealing" .. character.Name)

		if not folder then
			return
		end

		folder.Name = "DESTROYING"
		Debris:AddItem(folder, 1.25)
		local boolValue_2 = Instance.new("BoolValue", folder)
		boolValue_2.Name = "StopFollowing"

		if folder then
			for _, descendant in pairs(folder:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") or descendant:IsA("Beam") or descendant:IsA("Trail") then
					descendant.Enabled = false
				elseif descendant:IsA("Mesh") or descendant:IsA("Decal") or descendant:IsA("MeshPart") or descendant:IsA("Part") then
					TweenService:Create(descendant, v[1], {
						Transparency = 1
					}):Play()
				elseif descendant:IsA("Sound") then
					Util.Sound:FadeOut(descendant, 0.5)
				end
			end
		end
	end
end