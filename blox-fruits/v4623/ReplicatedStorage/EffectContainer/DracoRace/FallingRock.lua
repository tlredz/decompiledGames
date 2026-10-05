local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fallingRock = FX:WaitForChild("DracoRace").FallingRock
local debris = Util.Debris
return function(data)
	local position = data.Position

	if position then
		if (workspace.CurrentCamera.CFrame.Position - position).Magnitude > 2000 then
			return
		end

		local _ = data.Lifetime or 10
		local _ = data.Speed or 3
		local random = Random.new()
		local clone = fallingRock.RockMaterial:Clone()
		debris:AddItem(clone, 11)
		clone.Size += Vector3.new(math.random(1, 3), math.random(1, 3), math.random(1, 3))
		local clone2 = fallingRock.Container.Burning:Clone()
		debris:AddItem(clone2, 11)
		clone2.Parent = clone
		local clone3 = fallingRock.Container.Break:Clone()
		debris:AddItem(clone3, 11)
		clone3.Parent = clone
		local children = clone3:GetChildren()
		local lastTime = os.clock()
		local children2 = clone2:GetChildren()
		clone.CFrame = CFrame.new(position)
		clone.Parent = _WorldOrigin
		local integer = random:NextInteger(1, 4)
		Util.Sound:Play("BF_Trial_Rock_Falling_Loop_01", clone, nil, 1 + math.random(-10, 10) / 100, 0.5)
		Util.Sound:Play(
			"BF_Trial_Rock_Spawn_0" .. tostring(integer),
			clone.Position,
			nil,
			1 + math.random(-10, 10) / 100,
			1
		)
		local v = {}
		local v2 = nil
		local position2 = nil

		for _, v4 in ipairs(children2) do
			v[v4] = { os.clock(), 0.15, v4:GetAttribute("EmitCount") or 1 }
		end

		local v4 = { math.random(-6, 6), math.random(-6, 6), math.random(-6, 6) }
		local v5 = 0.016666666666666666

		while not (os.clock() - lastTime >= 10) do
			local v6
			v2, position2, v6 = Util.Ray(
				clone.Position,
				CFrame.new(clone.Position).upVector.Unit * -clone.ExtentsSize.Magnitude,
				{ clone, workspace.Characters, workspace.Enemies },
				false
			)

			if v2 and clone3 and clone then
				local terrain = workspace:FindFirstChild("Terrain")

				if not terrain then
					break
				end

				clone3.Parent = terrain
				clone2.Parent = terrain
				clone3.Position = position2

				for _, v7 in ipairs(children) do
					v7:Emit(v7:GetAttribute("EmitCount"))
				end

				break
			else
				for _, v7 in ipairs(children2) do
					if not (os.clock() - v[v7][1] > v[v7][2]) then
						continue
					end

					v7:Emit(v[v7][3])
					v[v7][1] = os.clock()
				end

				clone.CFrame = CFrame.new(clone.Position - Vector3.new(0, v5 * 3 * 60, 0)) * (clone.CFrame - clone.CFrame.Position) * CFrame.Angles(
					math.rad(v4[1]),
					math.rad(v4[2]),
					(math.rad(v4[3]))
				)
				v5 = RunService.Heartbeat:Wait()
			end
		end

		if v2 ~= nil then
			Util.Sound:Play(
				"BF_Trial_Rock_Fall_Impact_0" .. tostring(integer),
				position2,
				nil,
				1 + math.random(-15, 15) / 100,
				1
			)
		end

		if clone then
			clone:Destroy()
		end
	end
end