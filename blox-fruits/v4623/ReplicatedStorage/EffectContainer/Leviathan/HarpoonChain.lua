local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local FX = require(game.ReplicatedStorage.FX)
local harpoonChain = FX:WaitForChild("Leviathan").HarpoonChain

local function constrainAngle(p, _, _, _)
	return p
end

local v = {
	{},
	{}
}
local flag = false
local now = 0

local function GetChainFromCache()
	if not flag then
		flag = true
		task.delay(0.1, function()
			while flag do
				if #v[2] == 0 and os.clock() - now > 120 then
					v[1][1]:Destroy()
					table.remove(v[1], 1)

					if #v[1] == 0 then
						flag = false
						break
					end
				end

				task.wait(0.1)
			end
		end)
	end

	local selected = v[1][1] or harpoonChain.Chain1:Clone()

	if v[1][1] then
		table.remove(v[1], 1)
	end

	table.insert(v[2], selected)
	now = os.clock()
	return selected
end

local function ReturnChainToCache(p)
	p.CFrame = CFrame.new(0, -50, 0)
	local index = table.find(v[2], p)

	if index then
		table.remove(v[2], index)
	end

	table.insert(v[1], p)
	now = os.clock()
end

return function(data)
	local cannonBall = data.CannonBall
	local cannon = data.Cannon
	local _ = data.Cutscene or true

	if (cannon.Seat.Position - workspace.CurrentCamera.CFrame.Position).Magnitude > 2000 then
		return
	end

	local maid = Util.Maid.new()
	local part1 = cannon.Seat.TubeWeld.Part1
	local v2 = { cannonBall.Harpoon.Position + cannonBall.Harpoon.CFrame.RightVector * 8, cannon.BoatHinge.Position }
	local v3 = nil
	local v4 = {}
	local v5 = 0
	local v6 = 0
	local clones = {}

	while cannonBall.Parent do
		if cannonBall:GetAttribute("Welded") then
			cannonBall.Weld.C0 = CFrame.Angles(0, -1.5707963267948966, 0)
		else
			cannonBall.Weld.C0 = cannonBall.CFrame:ToObjectSpace(CFrame.new(
				cannonBall.Position,
				cannonBall.Position + cannonBall.Velocity
			) * CFrame.Angles(0, -1.5707963267948966, 0))
		end

		local X = Vector3.new(cannonBall.Weld.C0:ToEulerAnglesXYZ()).X

		if v3 and #v4 > 4 then
			local lookVector = v3.LookVector
			local _ = cannon.Seat.CannonWeld.Part0
			local _ = cannon.Seat.BoatWeld.Part0
			local cframe = CFrame.new(
				v3["HorizontalPivot.Position"],
				(Vector3.new(lookVector.X, v3["HorizontalPivot.Position"].Y, lookVector.Z))
			)
			local v7 = -math.deg(Vector3.new(v3["BoatWeld.Part0.CFrame"]:ToObjectSpace(cframe):ToEulerAnglesXYZ()).Y)
			local Y = math.deg(Vector3.new(cannon.Seat.BoatWeld.C0:ToEulerAnglesXYZ()).Y)
			local v8 = math.abs(v7 - Y)

			if not (v7 < -65 or v7 > 65) or Y ~= 65 and Y ~= -65 then
				local v9 = 50 / (math.exp((v8 - 50) * -0.05) + 1) + -0.5
				local v10 = math.clamp(math.sign(v7 - Y) * v9 * v6 * v8 + Y, -65, 65)
				cannon.Seat.BoatWeld.C0 = CFrame.Angles(0, math.rad(v10), 0)
				cannon.Seat.BoatWeld.C1 = CFrame.Angles(0, math.rad(v10) * 2, 0)
			end

			local cframe2 = v3["BoatWeld.Part0.CFrame"] * cannon.Seat.BoatWeld.C0 * cannon.Seat.BoatWeld.C1:Inverse() * cannon.Seat.BoatWeld.Part0.CFrame:ToObjectSpace(cannon.Seat.CannonWeld.Part0.CFrame)
			local v9 = math.clamp(
				math.deg(Vector3.new(cframe2:ToObjectSpace((CFrame.new(cframe2.Position, lookVector))):ToEulerAnglesXYZ()).X),
				-10,
				45
			)
			local v10 = math.max(v9 - 25, 0) / 35 * 2.5
			cannon.Seat.CannonWeld.C0 = CFrame.new(0, v10, 0) * CFrame.Angles(math.rad(v9), 0, 0) * CFrame.new(
				0,
				0,
				-v10 / 1.4142135623730951
			)
		end

		local v7 = {
			cannonBall.Harpoon.Position + cannonBall.Harpoon.CFrame.RightVector * 8,
			cannon.BoatHinge.Position
		}
		local v8 = v5 + ({ (v7[1] - v2[1]).Magnitude, (v7[2] - v7[1]).Magnitude - (v2[2] - v2[1]).Magnitude })[2]
		local magnitude = (part1.Position + part1.CFrame.LookVector * 4 - v7[1]).Magnitude
		v5 = math.clamp(v8, magnitude, math.min(70, magnitude * 0.1) + magnitude)
		local v10 = math.floor((v5 - #v4 * 8.6) / 8.6)
		local v11 = v5 > 550 and 0 or v10
		local v12 = v11 > 300 and 0 or v11
		local v13 = {}

		if v12 > 0 then
			v2 = v7

			for _ = 1, v12 do
				local chainFromCache = GetChainFromCache()
				chainFromCache.Velocity = createVector(0, 0, 0)
				chainFromCache.CFrame = part1.CFrame
				pcall(function()
					chainFromCache.Parent = workspace._WorldOrigin
				end)
				table.insert(v4, chainFromCache)
			end
		else
			v2 = v7

			for _ = 1, -v12 do
				v13[v4[1]] = true
				ReturnChainToCache(v4[1])
				table.remove(v4, 1)
			end
		end

		local function Backward(p)
			local lookVector = part1.CFrame.LookVector
			local v15 = part1.Position + part1.CFrame.LookVector * 5

			for i = #v4, 1, -1 do
				local v16 = v4[i]
				local v17 = v16.Position + v16.CFrame.RightVector * 8.6 / 2

				if (v16.Position - v16.CFrame.RightVector * 8.6 / 2 - v15).Magnitude < 0.3 then
					break
				end

				local cframe = CFrame.new(v15, v17)
				v16.CFrame = cframe * CFrame.new(0, 0, -4.3) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
					X,
					0,
					0
				)
				v15 = cframe.Position + cframe.LookVector * 8.6
				local rightVector = v16.CFrame.RightVector
			end
		end

		local v15 = X

		local function Forward(p)
			local v16 = cannonBall.Harpoon.Position + cannonBall.Harpoon.CFrame.RightVector * 8

			for i = 1, #v4 do
				local v17 = v4[i]
				local lookVector = part1.CFrame.LookVector
				local v18 = v17.Position - v17.CFrame.RightVector * 8.6 / 2

				if (v17.Position + v17.CFrame.RightVector * 8.6 / 2 - v16).Magnitude < 0.3 then
					break
				end

				local cframe = CFrame.new(v16, v18)
				v17.CFrame = cframe * CFrame.new(0, 0, -4.3) * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
					v15,
					0,
					0
				)
				v16 = cframe.Position + cframe.LookVector * 8.6
				local rightVector = v17.CFrame.RightVector
			end
		end

		if cannonBall:GetAttribute("Welded") then
			for _, v16 in pairs(v4) do
				v16.CFrame -= Vector3.new(0, workspace.Gravity * v6 / 2, 0)
			end
		end

		Forward()
		Backward()
		Forward()

		if #v4 > 0 then
			local v16 = part1.Position + part1.CFrame.LookVector * 5
			local v17 = v4[#v4].Position - v4[#v4].CFrame.RightVector * 4.3
			local v18 = math.floor(((v16 - v17).Magnitude - 2) / 8.6)

			if v18 < 500 and v18 > 0 then
				for _ = 1, v18 do
					local chainFromCache = GetChainFromCache()
					v13[chainFromCache] = nil
					local cframe = CFrame.new(v17, v16)
					chainFromCache.Velocity = createVector(0, 0, 0)
					chainFromCache.CFrame = cframe * CFrame.new(0, 0, -4.3) * CFrame.Angles(0, -1.5707963267948966, 0)
					pcall(function()
						chainFromCache.Parent = workspace._WorldOrigin
					end)
					table.insert(v4, chainFromCache)
					v17 = cframe.Position + cframe.LookVector * 8.6
				end
			end

			for k, _ in pairs(v13) do
				local v19 = k
				pcall(function()
					v19.Parent = nil
				end)
			end

			local v19 = part1.Position + part1.CFrame.LookVector * 5
			local v20 = v4[#v4].Position - v4[#v4].CFrame.RightVector * 4.3
			local v21 = math.floor((v19 - v20).Magnitude / 1.6)
			local v22 = v21 > 500 and 0 or v21

			if #clones < v22 then
				for _ = 1, v22 - #clones do
					local clone = harpoonChain.Link1:Clone()
					clone.Parent = workspace._WorldOrigin
					maid:GiveTask(function()
						game.Debris:AddItem(clone, 0.016666666666666666)
					end)
					table.insert(clones, clone)
				end
			end

			for i = 1, #clones do
				local v23 = clones[i]

				if v22 < i then
					v23.Transparency = 1
				else
					v23.Transparency = 0
					local cframe = CFrame.new(v20, v19)
					v23.CFrame = cframe * CFrame.new(0, 0, -0.8) * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
						math.rad(i * 45) + X,
						0,
						0
					)
					v20 = cframe.Position + cframe.LookVector * 1.6
				end
			end

			local v23 = part1.Position - part1.CFrame.LookVector
			local v24 = math.floor((v23 - v20).Magnitude / 1.6)
			local v25 = v24 > 500 and 0 or v24

			if v25 + v22 > #clones then
				for _ = 1, v25 + v22 - #clones do
					local clone = harpoonChain.Link1:Clone()
					clone.Parent = workspace._WorldOrigin
					maid:GiveTask(clone)
					table.insert(clones, clone)
				end
			end

			for i = v22 + 1, #clones do
				local v26 = clones[i]

				if v25 + v22 < i then
					v26.Transparency = 1
				else
					v26.Transparency = 0
					local cframe = CFrame.new(v20, v23)
					v26.CFrame = cframe * CFrame.new(0, 0, -0.8) * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.Angles(
						math.rad(i * 45) + X,
						0,
						0
					)
					v20 = cframe.Position + cframe.LookVector * 1.6
				end
			end

			if clones[1] then
				v3 = {
					["BoatWeld.Part0.CFrame"] = cannon.Seat.BoatWeld.Part0.CFrame,
					["HorizontalPivot.Position"] = cannon.Seat.BoatWeld.Part0.Position,
					LookVector = v4[#v4].Position + v4[#v4].CFrame.LookVector,
					LastVelocity = cannonBall.Velocity
				}
			end
		end

		v6 = task.wait()
	end

	maid:DoCleaning()

	for _, v7 in pairs(v4) do
		local v8 = v7
		pcall(function()
			v8.Parent = nil
		end)
		ReturnChainToCache(v7)
	end
end