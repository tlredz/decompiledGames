local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local identity = CFrame.identity

local function resolveRoot(character)
	if typeof(character) ~= "Instance" then
		return nil
	end

	if character:IsA("BasePart") then
		return character
	end

	if character:IsA("Model") then
		return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRoarAssets()
	local dino = FX:WaitForChild("Dino")
	local transformed = dino and dino:FindFirstChild("Transformed")
	return transformed and transformed:FindFirstChild("TAP")
end

local function emitBurst(folder)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")
		local emitCount = emitter:GetAttribute("EmitCount") or 15
		local v2 = emitter
		task.spawn(function()
			if emitDelay and emitDelay ~= 0 then
				task.wait(emitDelay)
			end

			v2:Emit(emitCount)
		end)
	end
end

local function setEnabled(folder, enabled: boolean)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end

local colorSequence = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150))

local function recolor(folder, colorSequence2)
	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Color = colorSequence2
		end
	end
end

return function(player)
	if not player then
		return
	end

	local root = player.Root or resolveRoot(player.Character)

	if not (root and root:IsA("BasePart")) then
		return
	end

	local roarAssets = getRoarAssets() -- equivalent call inferred; original call site unknown

	if not roarAssets then
		return
	end

	local duration = player.Duration or 1.6
	local cFrame = root.CFrame * identity
	local v2 = Util.Sound:Play("Dinosaur Roar", root, nil, 0.8, 1)

	if v2 then
		task.delay(duration, function()
			Util.Sound:FadeOut(v2, 0.4)
		end)
	end

	local roarStartImpact = roarAssets:FindFirstChild("RoarStartImpact")

	if roarStartImpact then
		local clone = roarStartImpact:Clone()
		clone.CFrame = cFrame
		local main = clone:FindFirstChild("Main")

		if main then
			main.Part0 = root
			main.C0 = identity
		end

		clone.Parent = _WorldOrigin
		emitBurst(clone)
		Util.Debris:AddItem(clone, 3)
	end

	task.wait(0.15)
	local roarStart = roarAssets:FindFirstChild("RoarStart")

	if roarStart then
		local clone = roarStart:Clone()
		clone.CFrame = cFrame
		local main = clone:FindFirstChild("Main")

		if main then
			main.Part0 = root
			main.C0 = identity
		end

		clone.Parent = _WorldOrigin
		recolor(clone, colorSequence)
		setEnabled(clone, true)
		task.delay(duration, function()
			setEnabled(clone, false)
			Util.Debris:AddItem(clone, 2)
		end)
	end

	local roarGround = roarAssets:FindFirstChild("RoarGround")

	if roarGround then
		local clone = roarGround:Clone()
		local ray = Util.Ray
		local position = cFrame.Position
		local v3 = { workspace.Characters, workspace.Enemies }
		local _, v4, v5 = ray(position, createVector(-0, -20, -0), v3)

		if v4 then
			clone.CFrame = CFrame.new(v4, v4 + (v5 or createVector(0, 1, 0))) * CFrame.Angles(-1.5707963267948966, 0, 0)
		else
			clone.CFrame = CFrame.new(cFrame.Position)
		end

		clone.Parent = _WorldOrigin
		recolor(clone, colorSequence)
		setEnabled(clone, true)
		task.delay(duration, function()
			setEnabled(clone, false)
			Util.Debris:AddItem(clone, 2)
		end)
	end
end