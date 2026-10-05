local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local FX = require(game.ReplicatedStorage.FX)
local leechVFX = FX:WaitForChild("RaceAwakenings").Ghoul.LeechVFX

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

function cubicBezier(p: number, vector: Vector3, vector2: Vector3, vector3: Vector3, vector4: Vector3)
	return vector * (1 - p) ^ 3 + vector2 * 3 * p * (1 - p) ^ 2 + vector3 * 3 * (1 - p) * p ^ 2 + vector4 * p ^ 3
end

local v = false
local v2 = {}
local LeechVFX = {}

local function despawn(k: number, instance, parent)
	if parent ~= nil then
		instance.Trail.Enabled = false
		local absorb = instance.Absorb
		absorb.Parent = parent
		Util.Debris:AddItem(absorb, 2)

		for _, child in pairs(absorb:GetChildren()) do
			child:Emit(child:GetAttribute("EmitCount"))
		end

		Util.Sound:Play("SoulAbsorb__9624925392", parent.Position, nil, math.random(25, 30) / 10, 0.25)
	end

	if instance then
		instance:Destroy()
		table.remove(v2, k)
	end
end

function refreshBucket()
	local _, result = pcall(function()
		if #v2 > 0 then
			v = true

			while #v2 > 0 do
				local now = tick()

				for k, v3 in pairs(v2) do
					local v4 = now - v3[1]
					local v5 = nil

					if v3[3][4] == nil then
						despawn(k, v3[4], v3[3][4])
					else
						local cubicBezier3 = cubicBezier
						local v6 = math.max(0.001, v4) / v3[2]
						local v7 = v3[3][1]
						local v8 = v3[3][1]
						local v9 = v8 + (v3[3][4].Position - v8) * 0.33 + v3[3][2]
						local v10 = v3[3][1]
						v5 = cubicBezier3(
							v6,
							v7,
							v9,
							v10 + (v3[3][4].Position - v10) * 0.66 + v3[3][3],
							v3[3][4].Position
						)
					end

					local position = v3[4].Position
					v3[4].CFrame = CFrame.new(v5, position) * CFrame.Angles(0, 3.141592653589793, 0)

					if v3[2] <= v4 then
						despawn(k, v3[4], v3[3][4])
					end
				end

				RunService.RenderStepped:Wait()
			end

			v = false
		end
	end)

	if result then
		warn("[Ghoul - Lifesteal VFX] Something went wrong in the main loop: \n")

		if #v2 > 0 then
			for _, v3 in pairs(v2) do
				if v3[4] then
					v3[4]:Destroy()
				end
			end

			v2 = {}
			v = false
		end
	end
end

function LeechVFX.new(p: number, list, p2)
	local clone = leechVFX.LifestealTrail:Clone()
	debris:AddItem(clone, p + 3)
	clone.CFrame = CFrame.new(list[1], list[4].Position)
	clone.Parent = _WorldOrigin
	table.insert(v2, {
		tick(),
		p,
		list,
		clone,
		p2 or nil
	})

	if not v then
		refreshBucket()
	end

	return clone
end

return LeechVFX