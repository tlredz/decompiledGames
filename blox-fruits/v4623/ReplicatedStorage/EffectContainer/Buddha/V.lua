local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
Vector3.new()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local LightAbsorption2 = require(script.Parent.Modules.LightAbsorption2)
local Beam = require(script.Parent.Modules.Beam)
local Explosion = require(script.Parent.Modules.Explosion)

local function coolSine(p)
	return 0.5 + (math.sin(3.141592653589793 * (p - 0.25)) * 6 + math.sin(9.42477796076938 * (p - 0.25)) * 2) / 11.309733552923255
end

return function(data)
	local charging = data.charging
	local size = data.size
	local at = data.at
	local targetArray = data.targetArray
	local speed = data.speed
	local chargeFor = data.chargeFor

	if (at.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1800 then
		return
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin

	if charging == true then
		local v = Util.Sound:Play("LightExplosion2", at)
		promise.try(function()
			LightAbsorption2(at, 5 * size, 0.75 * (chargeFor + 1 - 0.6))
		end)
		promise.delay(0.3):await()

		if not data.NoShake then
			Util.CameraShaker:ShakeOnce(15, 25, 0.1, 2 * chargeFor)
		end

		local count = #targetArray
		local count2 = 0
		awaitHeartbeatLoopFor(chargeFor, function(p)
			if count2 * chargeFor / count < p and count2 < count then
				count2 += 1
				Util.Sound:Play("Buddha2Explosion", targetArray[count2])
				promise.try(function()
					Beam(at.Position, targetArray[count2], size, speed, false)
				end)
			end
		end, function()
			Util.Sound:FadeOut(v, 0.3)
		end)
	else
		promise.try(function()
			Explosion(targetArray[1], size * 2.5, true)
		end)
		Util.Sound:Play("Buddha2VExplosion", targetArray[1])
		local clone = FX:WaitForChild("BuddhaEffects").Ring:Clone()
		clone.CanTouch = false
		clone.Size = Vector3.new(size * 15, size * 15, size)
		clone.CFrame = CFrame.new(targetArray[1] + Vector3.new(0, size * 3, 0)) * CFrame.Angles(
			1.5707963267948966,
			0,
			0
		)
		clone.Parent = model
		local part = Instance.new("Part")
		Util.Debris:AddItem(part, 10)
		part.CanTouch = false
		part.Anchored = true
		part.CanCollide = false
		part.CastShadow = false
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(1000, size * 10, size * 10)
		part.Color = Color3.fromHSV(0, 0, 1)
		part.CFrame = CFrame.new(targetArray[1]) * CFrame.Angles(0, 0, 1.5707963267948966)
		part.Material = Enum.Material.Neon
		part.Parent = model
		awaitHeartbeatLoopFor(1, function(p)
			local v = p / 1

			if v < 0.5 then
				part.Size = Vector3.new(1000, size * (10 - 20 * v), size * (10 - 20 * v))
			else
				part.Transparency = 1
			end

			clone.Size = Vector3.new(size * (15 + 20 * v), size * (15 + 20 * v), size)
			clone.Transparency = v ^ 4
		end, function()
			clone.Transparency = 1
		end)
	end

	model:Destroy()
end