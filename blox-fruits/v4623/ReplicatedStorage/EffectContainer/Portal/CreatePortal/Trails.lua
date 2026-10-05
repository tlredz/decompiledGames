local createVector = vector.create

local function SwirlSpline(vector2: Vector3, p: number)
	local v = p * 11
	local v2 = -(createVector(0, 1, 0)):Cross(vector2)
	local v3 = math.exp(v * -0.19)
	return (Vector3.new(
		v3 * (vector2.X * math.cos(v * 0.8) + (v2.X - vector2.X * -0.19) / 0.8 * math.sin(v * 0.8)),
		((1 - v3) ^ 3 * 2 - (1 - v3) ^ 2 * 3 + 1) * vector2.Y + ((1 - v3) ^ 3 - (1 - v3) ^ 2 * 2 + (1 - v3)) * v2.Y,
		v3 * (vector2.Z * math.cos(v * 0.8) + (v2.Z - vector2.Z * -0.19) / 0.8 * math.sin(v * 0.8))
	))
end

local random = Random.new()
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("PortalEffects").Portal
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local attachmentPair = Util.AttachmentPair
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):Inverse()

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function createSwirlTrails(p: number, vector2: Vector3, vector3: Vector3)
	if (Workspace.CurrentCamera.CFrame.Position - vector3).Magnitude > 2500 then
		return
	end

	local v = time()
	heartbeatLoopFor2(p, function()
		if time() - v > 0.02 then
			v = time()
			local v2 = attachmentPair.new(
				CFrame.new(0, -random:NextNumber(1, 5.8), 0),
				CFrame.new(0, random:NextNumber(1, 5.8), 0)
			)
			local clone = FX:WaitForChild("PortalEffects").VTrail:Clone()
			clone.Color = ColorSequence.new(Color3.fromHSV(0.6225, random:NextNumber(0.54, 0.94), 1))
			clone.Brightness = random:NextNumber(-2, 5)
			clone.LightEmission = random:NextNumber(-1, 1)
			v2:hookUp(clone)
			local v3 = CFrame.lookAt(createVector(0, 0, 0), vector2) * inverse + vector3
			local v4 = RandomVectorOffsetBetween(createVector(0, 1, 0), 0.8726646259971648, 1.5707963267948966) * random:NextNumber(
				60,
				80
			)
			heartbeatLoopFor2(0.75, function(_, _, p2: number)
				local swirlSpline = SwirlSpline(v4, p2 * 0.99)
				local swirlSpline2 = SwirlSpline(v4, p2)
				v2:setRelativeCFrame(v3 * CFrame.lookAt(swirlSpline, swirlSpline2))
			end, function()
				local swirlSpline = SwirlSpline(v4, 0.99)
				local swirlSpline2 = SwirlSpline(v4, 1)
				v2:setRelativeCFrame(v3 * CFrame.lookAt(swirlSpline, swirlSpline2))
				task.delay(0.5, function()
					v2:destroy()
				end)
			end)
		end
	end)
end

return createSwirlTrails