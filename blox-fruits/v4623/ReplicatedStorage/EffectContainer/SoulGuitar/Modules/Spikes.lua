local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local soulGuitarXFlipbook = FX:WaitForChild("SoulGuitarEffects").SoulGuitarXFlipbook

local function NoiseBetween(p: number, p2: number, p3: number, p4: number, p5: number)
	return p4 + (p5 - p4) * (math.noise(p, p2, p3) + 0.5)
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function Spikes(p, duration, _)
	local v = math.max(0, duration - 0.5)
	local parent = _WorldOrigin
	local v3 = p + createVector(0, -2, 0)
	local clones = {}

	for i = 1, #soulGuitarXFlipbook:GetChildren() do
		local clone = soulGuitarXFlipbook[tostring(i)]:Clone()
		clone.CastShadow = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Anchored = true
		clone.Locked = true
		clone.Transparency = 1
		clone.Size *= createVector(1, 0.5, 1)
		clone.Parent = parent
		clone.CFrame = CFrame.new(v3) + clone.Size.Y * 0.5 * createVector(0, 1, 0)
		clone.Color = Color3.fromRGB(117, 255, 133)
		table.insert(clones, clone)
	end

	local lines = script.Lines
	local part = Instance.new("Part")
	part.Anchored = true
	part.CastShadow = false
	part.Locked = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Transparency = 1
	part.Size = createVector(200, 200, 200)
	part.CFrame = CFrame.new(v3) - createVector(0, 100, 0)
	part.Name = "GuitarXLines"
	local clone = lines:Clone()
	clone.Enabled = true
	clone.Parent = part
	part.Parent = parent
	local clone2 = script.Part.GroundAttach:Clone()
	clone2.Parent = part
	task.delay(duration, function()
		if part ~= nil and part.Parent ~= nil then
			part:Destroy()
		end
	end)
	local currentCamera = workspace.CurrentCamera
	local count = #clones
	local v4 = 1
	local v5 = clones[1]
	local transparency = 0
	v5.Transparency = transparency
	heartbeatLoopFor2(duration, function(p2)
		local v7 = math.floor(4 * p2 % 1 * count) + 1

		if v7 ~= v4 then
			v5.Transparency = 1
			v5 = clones[v7]
			v5.Transparency = transparency
			v4 = v7
		end

		v5.CFrame = CFrame.lookAt(
			v3,
			v3 * createVector(0, 1, 0) + currentCamera.CFrame.Position * createVector(1, 0, 1)
		) * CFrame.Angles(0, 1.5707963267948966, 0) + v5.Size.Y * 0.5 * createVector(0, 1, 0)
	end, function()
		for _, v7 in ipairs(clones) do
			v7:Destroy()
		end
	end)
	task.delay(v, function()
		clone.Enabled = false

		for _, child in ipairs(clone2:GetChildren()) do
			child.Enabled = false
		end

		heartbeatLoopFor2(0.5, function(_, _, p2)
			transparency = 0 + 1 * p2 ^ 0.5
			v5.Transparency = transparency
		end, function()
			v5.Transparency = 1
		end)
	end)
end

return Spikes