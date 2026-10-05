game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local _ = FX:WaitForChild("SoulGuitarEffects").Wind
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
Random.new()

local function GroundCrack(list, cFrame: CFrame, size: Vector3, p: number, color: Color3, p2: number, value: number, p3)
	local v = value or 0
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = size
	part.CFrame = cFrame
	part.Name = "GroundCrackPart"
	local decal = Instance.new("Decal")
	decal.Face = Enum.NormalId.Top
	decal.Texture = list[1]
	decal.Color3 = color
	Util.SetParentOverrideWithColor(decal, part, p3, "LeopardFruitVFXColor")
	Util.SetParentOverrideWithColor(part, _WorldOrigin, p3, "LeopardFruitVFXColor")
	local count = #list
	heartbeatLoopFor2(p, function(_, _, p4)
		local v2 = math.floor(p4 * (count - 1)) + 1

		if v2 ~= 1 then
			decal.Texture = list[v2]
		end
	end, function()
		decal.Texture = list[#list]
		task.wait(v)
		heartbeatLoopFor2(p2, function(_, _, transparency)
			decal.Transparency = transparency
		end, function()
			decal.Transparency = 1
		end)
	end)
	task.delay(p + p2 + 2, function()
		part:Destroy()
	end)
	return part, decal
end

return GroundCrack