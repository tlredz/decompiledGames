local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local BetterDebris = require(ReplicatedStorage.Modules.BetterDebris)
local Utility = require(ReplicatedStorage.Modules.Utility)
local CameraController = require(Players.LocalPlayer.PlayerScripts.Controllers.CameraController)
local mushroomCloud = Players.LocalPlayer.PlayerScripts.Assets:WaitForChild("Misc"):WaitForChild("MushroomCloud")

local function get_rotation(position)
	local unit = (position - workspace.CurrentCamera.CFrame.Position).Unit
	local v = position - unit
	local v2 = position + unit * 8
	local raycastResult = Utility:Raycast(v, v2, (v - v2).Magnitude)

	if raycastResult.Normal then
		return CFrame.new(createVector(0, 0, 0), raycastResult.Normal) * CFrame.Angles(-1.5707963267948966, 0, 0)
	end

	return CFrame.identity
end

return function(position, p, value, p2, value2, p3, p4)
	local v = 5 * (value or 1)
	local v2 = value2 or 64
	local magnitude = (workspace.CurrentCamera.CFrame.Position - position).Magnitude

	if CONSTANTS.RENDER_DISTANCE < magnitude then
		return
	end

	Utility:CreateSound("rbxassetid://13455969017", 0.5, 0.9 + 0.2 * math.random(), position, true, 10, p3, p4)
	Utility:CreateSound("rbxassetid://17641561917", 1.5, 0.9 + 0.2 * math.random(), position, true, 10, p3, p4)

	if magnitude <= v2 then
		local v3 = math.max(0, 1 - magnitude / v2)
		CameraController:ShakeOnce(
			v3 * 50,
			v3 * 10 / v,
			0.1 / v,
			0.4 / v,
			createVector(0.25, 0.25, 0),
			createVector(0, 0, 0)
		)
	end

	local v3 = p / 40
	local cframe = CFrame.new(position)
	local v4

	if p2 then
		v4 = get_rotation(position)
	else
		v4 = CFrame.identity
	end

	local v5 = cframe * v4
	local v6 = -5 * v3
	local clone = mushroomCloud:Clone()
	clone.Parent = workspace
	clone:SetPrimaryPartCFrame(v5)
	BetterDebris:AddItem(clone, 25 / v)
	clone.Fire.PointLight.Range = p * 3
	Utility:PlayParticles(clone.Fire)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function shake(value3)
		return Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.25 * (value3 or 1)
	end

	local v7 = (math.random(1, 2) - 1.5) * 2

	local function spin()
		return CFrame.Angles(0, tick() * 0.25 * v7 % 6.283185307179586, 0)
	end

	Utility:RenderstepForLoop(0, 100, 0.5 * v, function(p5)
		local v8 = 1 - (1 - p5 / 100) ^ 5
		local v9 = p5 / 100
		local v10 = v8 * 3
		local v11 = v9 * 3
		local v12 = 1 + (1 - v8)
		clone.Cloud.Size = createVector(14.711, 14.091, 13.818) * v10 * v3
		clone.Fire.Size = createVector(14.007, 14.026, 13.543) * v10 * v3
		clone.Ring.Size = createVector(14.9445, 2.697, 14.778) * v11 * v3
		clone.Cloud.CFrame = v5 * CFrame.new(0, clone.Cloud.Size.Y / 2 + v6, 0) * CFrame.Angles(
			0,
			tick() * 0.25 * v7 % 6.283185307179586,
			0
		) + shake(v12)
		clone.Fire.CFrame = clone.Cloud.CFrame + shake(v12)
		clone.Ring.CFrame = clone.Cloud.CFrame * CFrame.new(0, -1.815, 0) + shake(v12)
	end)
	Utility:RenderstepForLoop(0, 100, 0.5 * v, function(p5)
		local transparency = p5 / 100
		local v9 = (1 + transparency / 2) * 3
		clone.Fire.Transparency = transparency
		clone.Ring.Transparency = transparency / 2
		clone.Ring.Size = createVector(14.9445, 2.697, 14.778) * v9 * v3
		clone.Cloud.CFrame = v5 * CFrame.new(0, clone.Cloud.Size.Y / 2 + v6, 0) * CFrame.Angles(
			0,
			tick() * 0.25 * v7 % 6.283185307179586,
			0
		) + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.25 * 1
		clone.Fire.CFrame = clone.Cloud.CFrame + Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 0.25 * 1
		clone.Ring.CFrame = clone.Cloud.CFrame * CFrame.new(0, -1.815, 0) + Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 0.25 * 1
	end)
	Utility:RenderstepForLoop(0, 100, 1 * v, function(p5)
		local transparency = p5 / 100
		local v9 = (1.5 + transparency / 2) * 3
		clone.Cloud.Transparency = transparency
		clone.Ring.Transparency = 0.5 + transparency / 2
		clone.Ring.Size = createVector(14.9445, 2.697, 14.778) * v9 * v3
		clone.Cloud.CFrame = v5 * CFrame.new(0, clone.Cloud.Size.Y / 2 + v6, 0) * CFrame.Angles(
			0,
			tick() * 0.25 * v7 % 6.283185307179586,
			0
		) + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5) * 0.25 * 1
		clone.Ring.CFrame = clone.Cloud.CFrame * CFrame.new(0, -1.815, 0) + Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 0.25 * 1
	end)
	clone:Destroy()
end