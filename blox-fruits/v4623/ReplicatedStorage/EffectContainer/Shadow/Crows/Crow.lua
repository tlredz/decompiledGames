local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

function cflerp(object, p, p2)
	return object:lerp(p, p2)
end

function cubicBezier(p, p2, p3, p4, p5)
	return p2 * (1 - p) ^ 3 + p3 * 3 * p * (1 - p) ^ 2 + p4 * 3 * (1 - p) * p ^ 2 + p5 * p ^ 3
end

local v = false
local v2 = {}
local Crow = {}

function refreshBucket()
	local function despawn(k, instance, callback)
		if callback then
			task.spawn(function()
				callback(instance)
				table.remove(v2, k)
			end)
			return
		end

		instance:Destroy()
		table.remove(v2, k)
	end

	local _, result = pcall(function()
		if #v2 > 0 then
			v = true

			while #v2 > 0 do
				local now = tick()

				for k, v3 in pairs(v2) do
					local v4 = now - v3[1]
					local v5 = nil

					if typeof(v3[4][4]) == "Instance" then
						if v3[4][4] == nil then
							despawn(k, v3[5], v3[6] or nil)
						else
							local cubicBezier3 = cubicBezier
							local v6 = math.max(0.001, v4) / v3[2]
							local v7 = v3[4][1]
							local v8 = v3[4][1]
							local v9 = v8 + (v3[4][4].Position - v8) * 0.33 + v3[4][2]
							local v10 = v3[4][1]
							v5 = cubicBezier3(
								v6,
								v7,
								v9,
								v10 + (v3[4][4].Position - v10) * 0.66 + v3[4][3],
								v3[4][4].Position
							)
						end
					else
						v5 = cubicBezier(math.max(0.001, v4) / v3[2], unpack(v3[4]))
					end

					local position = v3[5].Position
					v3[5].LeftWing.Orientation = Vector3.new(0, 0, math.sin(v4 * v3[3]) * -8 * 10)
					v3[5].RightWing.Orientation = Vector3.new(0, 0, math.sin(v4 * v3[3]) * 8 * 10)
					v3[5].CFrame = CFrame.new(v5, position) * CFrame.Angles(0.5235987755982988, 3.141592653589793, 0)

					if v3[2] <= v4 then
						despawn(k, v3[5], v3[6] or nil)
					end
				end

				RunService.RenderStepped:Wait()
			end

			v = false
		end
	end)

	if result then
		warn("[Crows] Something went wrong in the main loop: \n")

		if #v2 > 0 then
			for _, v3 in pairs(v2) do
				if v3[5] then
					v3[5]:Destroy()
				end
			end

			v2 = {}
			v = false
		end
	end
end

function Crow.new(p, list, p2)
	local clone = script.MiniCrow:Clone()
	debris:AddItem(clone, p + 5)

	if typeof(list[4]) == "Instance" then
		clone.CFrame = CFrame.new(list[1], list[4].Position) * CFrame.Angles(0.5235987755982988, 0, 0)
	else
		clone.CFrame = CFrame.new(list[1], list[4]) * CFrame.Angles(0.5235987755982988, 0, 0)
	end

	clone.Parent = _WorldOrigin
	table.insert(v2, {
		tick(),
		p,
		math.random(8, 12) / (p / 2),
		list,
		clone,
		p2 or nil
	})

	if not v then
		task.spawn(function()
			refreshBucket()
		end)
	end

	return clone
end

return Crow