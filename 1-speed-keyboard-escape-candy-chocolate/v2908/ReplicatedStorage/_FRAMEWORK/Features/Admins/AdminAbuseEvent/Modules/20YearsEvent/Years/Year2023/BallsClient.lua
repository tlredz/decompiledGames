local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local BallMotion = require(script.Parent.BallMotion)
local Config = require(script.Parent.Config)
require(script.Parent.Types)
require(script.Parent.Parent.Parent.Types)

local function findBallTemplate(p)
	local yearAssets = p.yearAssets
	local _2023

	if yearAssets then
		_2023 = yearAssets:FindFirstChild("2023")
	end

	local part

	if _2023 then
		part = _2023:FindFirstChild(Config.ballAssetName)
	end

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

local function createDefaultBall()
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = createVector(1, 1, 1) * Config.ballDiameterStuds
	part.Material = Enum.Material.Neon
	part.Color = Config.ballColor
	local v = Config.ballDiameterStuds * 0.5
	local attachment = Instance.new("Attachment")
	attachment.Position = createVector(0, 1, 0) * v
	attachment.Parent = part
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = createVector(-0, -1, -0) * v
	attachment2.Parent = part
	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment
	trail.Attachment1 = attachment2
	trail.Color = ColorSequence.new(Config.ballColor)
	trail.Transparency = NumberSequence.new(0, 1)
	trail.Lifetime = Config.trailLifetimeSeconds
	trail.LightEmission = 1
	trail.Parent = part
	return part
end

local function createBallPart(instance)
	local clone

	if instance then
		clone = instance:Clone()
	else
		clone = createDefaultBall()
	end

	clone.Anchored = true
	clone.CanCollide = false
	clone.CanQuery = false
	clone.CanTouch = false
	clone.CastShadow = false
	return clone
end

local function getTargetPosition(p: number?)
	local playerByUserId

	if p then
		playerByUserId = Players:GetPlayerByUserId(p)
	end

	local character

	if playerByUserId then
		character = playerByUserId.Character
	end

	if character then
		return character:GetPivot().Position
	end

	return nil
end

local function stepBall(state, p: number)
	state.age += p
	local position = state.part.Position
	local positionAt = BallMotion.positionAt
	local flight = state.flight
	local age = state.age
	local targetUserId = state.targetUserId
	local playerByUserId

	if targetUserId then
		playerByUserId = Players:GetPlayerByUserId(targetUserId)
	end

	local character

	if playerByUserId then
		character = playerByUserId.Character
	end

	local v

	if character then
		v = character:GetPivot().Position
	end

	local v2 = positionAt(flight, age, v)
	local part = state.part
	local cFrame

	if (v2 - position).Magnitude > 0.001 then
		cFrame = CFrame.lookAt(v2, v2 + (v2 - position))
	else
		cFrame = CFrame.new(v2)
	end

	part.CFrame = cFrame
end

return {
	start = function(p, p2)
		local yearAssets = p.yearAssets
		local _2023

		if yearAssets then
			_2023 = yearAssets:FindFirstChild("2023")
		end

		local part

		if _2023 then
			part = _2023:FindFirstChild(Config.ballAssetName)
		else
			part = nil
		end

		if not (part and part:IsA("BasePart")) then
			part = nil
		end

		local v = {}
		local folder = Instance.new("Folder")
		folder.Name = Config.ballsFolderName
		folder.Parent = Workspace

		-- equivalent calls inferred from this helper; original call sites unknown
		local function removeBall(k: number)
			local v2 = v[k]

			if v2 then
				v2.part:Destroy()
				v[k] = nil
			end
		end

		local ballLaunchedConnection = p2.ballLaunched:connect(function(data)
			local v2 = part
			local clone

			if v2 then
				clone = v2:Clone()
			else
				clone = createDefaultBall()
			end

			clone.Anchored = true
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.CastShadow = false
			clone.CFrame = CFrame.new(data.flight.origin)
			local v3 = {
				part = clone,
				targetUserId = data.targetUserId,
				flight = data.flight,
				age = 0
			}
			stepBall(v3, math.max(0, Workspace:GetServerTimeNow() - data.serverTime))
			v3.part.Parent = folder
			v[data.id] = v3
		end)
		local ballEndedConnection = p2.ballEnded:connect(removeBall)
		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
			for k, v2 in v do
				if v2.age >= v2.flight.duration then
					removeBall(k) -- equivalent call inferred; original call site unknown
				else
					stepBall(v2, dt)
				end
			end
		end)
		return function()
			ballLaunchedConnection()
			ballEndedConnection()
			renderSteppedConnection:Disconnect()
			table.clear(v)
			folder:Destroy()
		end
	end
}