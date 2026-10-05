local createVector = vector.create
local RenderDistance = require(game.ReplicatedStorage:WaitForChild("Util"):WaitForChild("RenderDistance"))
local crescentSlash = game.ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("CrescentSlash")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function inQuint(p, p2, p3, p4)
	return p3 * math.pow(p / p4, 5) + p2
end

local function inCirc(p, p2, p3, p4)
	return -p3 * (math.sqrt(1 - math.pow(p / p4, 2)) - 1) + p2
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
RunService:BindToRenderStep("WindLayer", Enum.RenderPriority.Last.Value + 1007, function(p)
	for k, v2 in next, v, nil do
		if not v2.RenderDistance:WithinRange(p) then
			continue
		end

		local size = v2.Size
		local duration = v2.Duration
		local anchor = v2.Anchor
		local now = tick()

		for k2, slash in next, v2.Slashes, nil do
			if slash.Restart then
				slash.Restart = false
				slash.Start = now + slash.Start
			end

			local v3 = math.min(1, (now - slash.Start) / duration)

			if anchor:IsDescendantOf(workspace) then
				if v3 >= 1 then
					slash.Start = -(now - slash.Start - duration)
					slash.Restart = true
					slash.Rotation = math.random(360)
					slash.CFrame = anchor.CFrame
					anchor.CFrame = slash.CFrame
				elseif v3 > 0 then
					if not slash.CFrame then
						slash.CFrame = anchor.CFrame
					end

					slash.Rotation -= 18.84955592153876 * p
					slash.Part.Transparency = v3 * 0.3 + 0.7
					slash.Part.Size = size * createVector(1, 0.05, 1.125) * (v3 + 1)
					slash.Part.CFrame = slash.CFrame * CFrame.Angles(1.5707963267948966, slash.Rotation, 0) * CFrame.new(
						0,
						0,
						-size.x * v3 * 0.5
					)
				end
			else
				slash.Part:Destroy()
				table.remove(v2.Slashes, k2)
			end
		end

		if #v2.Slashes == 0 then
			table.remove(v, k)
		end
	end
end)

function Slash(color, p)
	local clone = crescentSlash:Clone()
	clone.Color = color
	clone.Size = createVector(1, 1, 1)
	clone.Parent = _WorldOrigin
	return {
		Part = clone,
		Rotation = math.random(360),
		Start = tick() + p
	}
end

return function(data)
	local anchor = data.Anchor
	local size = data.Size or anchor.Size
	local duration = data.Duration or 0.2
	local rate = data.Rate or 0.03333333333333333
	local color = data.Color or Color3.fromRGB(255, 255, 255)
	local v2 = duration / rate
	local v3 = {
		RenderDistance = RenderDistance.new(anchor, 700, 1200, 0.15),
		Anchor = anchor,
		Size = size,
		Duration = duration,
		Slashes = {}
	}

	for i = 0, v2 do
		local v4 = Slash(color, duration * (i / v2))
		table.insert(v3.Slashes, v4)
	end

	table.insert(v, v3)
end