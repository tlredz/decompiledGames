local createVector = vector.create
local RenderDistance = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("RenderDistance"))
local shockwaveLayer = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("ShockwaveLayer")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function inQuint(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 5) + p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function inCirc(p, p2, p3, duration)
	return -p3 * (math.sqrt(1 - math.pow(p / duration, 2)) - 1) + p2
end

local function inSine(p, p2, p3, p4)
	return -p3 * math.cos(p / p4 * 1.5707963267948966) + p3 + p2
end

local function inExpo(p, p2, p3, p4)
	if p == 0 then
		return p2
	end

	return p3 * math.pow(2, 10 * (p / p4 - 1)) + p2 - p3 * 0.001
end

function CalculateRadius(p, p2)
	return p * 1.35 * math.pow(math.sin(3.141592653589793 * p2), 0.3 * (p2 > 0.4 and 2 or 1))
end

function CalculateLength(p, p2, p3)
	return p * 1.4 ^ (p3 * (p2 / 2))
end

function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v = {}
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("BlastLayer", Enum.RenderPriority.Last.Value + 1000, function(p)
	for k, v2 in pairs(v) do
		if v2.RenderDistance:WithinRange(p) then
			local size = v2.Size
			local duration = v2.Duration
			local anchor = v2.Anchor
			local transparency = v2.Transparency
			local now = tick()

			for k2, shockwave in next, v2.Shockwaves, nil do
				if shockwave.Restart then
					shockwave.Restart = false
					shockwave.Start = now + shockwave.Start
				end

				local v3 = math.min(1, (now - shockwave.Start) / duration)

				if anchor:IsDescendantOf(workspace) then
					if v3 >= 1 then
						shockwave.Start = -(now - shockwave.Start - duration)
						shockwave.Restart = true
						shockwave.Rotation = 0
					else
						local Z = size.Z
						local X = size.X
						local Y = size.Y
						local v4 = math.max(CalculateRadius(X, v3), X / 6.6)
						local v5 = math.max(CalculateRadius(Y, v3), X / 6.6)
						local v8 = inCirc(math.min(1, now - shockwave.Start), Z / 4, Z / 0.4, duration) -- equivalent call inferred; original call site unknown
						local v9 = math.min(1, now - shockwave.Start)
						local v10 = math.min(
							v9 == 0 and 0.5 or 0.8 * math.pow(2, 10 * (v9 / duration - 1)) + 0.5 - 0.0008,
							0.8
						)
						shockwave.Rotation = 0

						if not v2.NoFade then
							shockwave.Part.Transparency = transparency + v10 * (1 - transparency)
						end

						shockwave.Part.Size = Vector3.new(v4, v8, v5)
						shockwave.Part.CFrame = anchor.CFrame * CFrame.new(0, 0, -Z / 2 + Z * v3 + v8 / 2 * v3) * CFrame.Angles(
							1.5707963267948966,
							shockwave.Rotation,
							0
						)
					end
				else
					shockwave.Part:Destroy()
					v2.Shockwaves[k2] = nil
				end
			end
		end

		if #v2.Shockwaves == 0 then
			v[k] = nil
		end
	end
end)

function Shockwave(color, p, transparency)
	local clone = shockwaveLayer:Clone()
	clone.Transparency = transparency
	clone.Color = color
	clone.Size = createVector(1, 1, 1)
	clone.Parent = _WorldOrigin
	return {
		Part = clone,
		Rotation = 0,
		Start = tick() - p
	}
end

return function(data)
	local anchor = data.Anchor

	if not anchor then
		return
	end

	local size = data.Size or anchor.Size
	local duration = data.Duration or 0.6
	local rate = data.Rate or 0.1
	local color = data.Color or Color3.fromRGB(33, 84, 185)
	local transparency = data.Transparency or 0
	local noFade = data.NoFade
	local v2 = duration / rate
	local v3 = {
		RenderDistance = RenderDistance.new(anchor, 600, 1200, 0.25),
		Anchor = anchor,
		NoFade = noFade,
		Size = size,
		Duration = duration,
		Transparency = transparency,
		Shockwaves = {}
	}

	for i = 0, v2 do
		table.insert(v3.Shockwaves, Shockwave(color, duration * (i / v2), transparency))
	end

	table.insert(v, v3)
end