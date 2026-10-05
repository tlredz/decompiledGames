local createVector = vector.create
local Realm = require(game.ReplicatedStorage.Util.Realm)

if Realm.getCurrentRealmDifficultyAsync() < 3 then
	script:Destroy()
	wait()
else
	-- equivalent calls inferred from this helper; original call sites unknown
	local function round(p, p2)
		return math.floor(p / p2 + 0.5) * p2
	end

	local function getYXZAngles(data)
		local lookVector = data.lookVector
		local rightVector = data.rightVector
		local upVector = data.upVector
		return
			math.atan2(lookVector.x, lookVector.z) + 3.141592653589793,
			-math.atan2(-lookVector.y, (math.sqrt(lookVector.x ^ 2 + lookVector.z ^ 2))),
			(math.atan2(rightVector.y, upVector.y))
	end

	local clone = game.ReplicatedStorage.Assets.Models.HexBarrier:Clone()
	clone.Size = createVector(400, 400, 144)
	local v = {}
	local v2 = nil
	local flag = nil
	local position = nil
	local v3 = nil
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local v7 = nil

	for i = -1, 1 do
		v[i] = {}

		for i2 = -1, 1 do
			local part = Instance.new("Part")
			part.Size = createVector(500, 500, 2)
			part.Transparency = 1
			part.CanTouch = false
			part.Anchored = true
			v[i][i2] = part
		end
	end

	local function BarrierService()
		local count = 0
		local humanoidRootPart

		if game.Players.LocalPlayer.Character then
			humanoidRootPart = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		end

		local v8 = { 1e999 }

		for _, child in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
			if not child:GetAttribute("Barrier") or not child:FindFirstChild("Mesh") or child.Mesh.Scale.X < 200 then
				continue
			end

			count += 1

			if not humanoidRootPart then
				continue
			end

			local magnitude = (child.Position - humanoidRootPart.Position).Magnitude
			local v9 = child.Mesh.Scale.X / 2 - magnitude

			if v9 > 0 and v9 < v8[1] then
				v8 = { v9, child }
			end
		end

		if v8[2] then
			if v2 ~= v8[2] then
				position = v8[2].Position
				v3 = v8[2].Mesh.Scale.X / 2 + clone.Size.Z / 2
				v4 = 27.825899999999997 / v3 * 3.141592653589793
				v5 = 50.00006666666666 / v3 * 3.141592653589793
				local v9 = 3.141592653589793 * (v3 - clone.Size.Z / 2) * 2
				v6 = math.clamp(v9 / 32, math.min(v9 / 8, 400), 400)
				v7 = v6 / v9 * 3.141592653589793 * 2

				for _, v10 in pairs(v) do
					for _, v11 in pairs(v10) do
						v11.Size = Vector3.new(v6 + 30, v6 + 30, 6)
					end
				end

				v2 = v8[2]
				clone.Parent = workspace
			end

			local v9 = math.min(
				((position - humanoidRootPart.Position).Magnitude - v3 + clone.Size.Z / 2 + 300) / 250,
				1
			)
			local v10 = CFrame.lookAt(position, humanoidRootPart.Position, createVector(0, 1, 0)) - position
			local lookVector = v10.lookVector
			local rightVector = v10.rightVector
			local upVector = v10.upVector
			local v11 = math.atan2(lookVector.x, lookVector.z) + 3.141592653589793
			local v12 = -math.atan2(-lookVector.y, (math.sqrt(lookVector.x ^ 2 + lookVector.z ^ 2)))
			local v13 = math.atan2(rightVector.y, upVector.y)

			for k, v14 in pairs(v) do
				for k2, v15 in pairs(v14) do
					v15.Parent = workspace
					v15.CFrame = CFrame.fromEulerAngles(v12 + k * v7, v11 + k2 * v7, v13, Enum.RotationOrder.YXZ) * CFrame.new(
						0,
						0,
						-v3 + clone.Size.Z / 2 - 3
					) + position
				end
			end

			local v15 = round(v12, v5) -- equivalent call inferred; original call site unknown
			local v17 = round(v11, v4) -- equivalent call inferred; original call site unknown
			local cframe = (CFrame.fromEulerAngles(v15, v17, v13, Enum.RotationOrder.YXZ) + position) * CFrame.new(
				0,
				0,
				-v3
			)
			local v18 = CFrame.new(position, humanoidRootPart.Position) * CFrame.new(0, 0, -v3)
			local objectSpace = cframe:ToObjectSpace(v18)
			clone.CFrame = v18 - v18.Position + cframe.Position
			local _ = objectSpace.Position - cframe.Position
			clone.Texture.OffsetStudsU = 225 - objectSpace.Position.X
			clone.Texture.OffsetStudsV = 225 + objectSpace.Position.Y
			clone.Texture.StudsPerTileU = 450
			clone.Texture.StudsPerTileV = 450
			clone.Texture.Transparency = v9 ^ 5 * -2.5 + 1
		else
			clone.Parent = nil
			clone.Texture.Transparency = 1
			v2 = nil

			for _, v9 in pairs(v) do
				for _, v10 in pairs(v9) do
					v10.Parent = nil
				end
			end

			if count == 0 then
				local RunService = game:GetService("RunService")
				RunService:UnbindFromRenderStep("BarrierService")
				flag = false
			end
		end
	end

	local function Check2(instance)
		if not instance:GetAttribute("Barrier") then
			return false
		end

		if flag then
			return true
		end

		flag = true
		local RunService = game:GetService("RunService")
		RunService:BindToRenderStep("BarrierService", 1, BarrierService)
		return true
	end

	local function Check(child)
		local v8

		if child:GetAttribute("Barrier") then
			if not flag then
				flag = true
				local RunService = game:GetService("RunService")
				RunService:BindToRenderStep("BarrierService", 1, BarrierService)
			end

			v8 = true
		else
			v8 = false
		end

		if not v8 then
			local barrierChangedConnection = child:GetAttributeChangedSignal("Barrier"):Connect(function()
				if not child:GetAttribute("Barrier") or flag then
					return
				end

				flag = true
				local RunService = game:GetService("RunService")
				RunService:BindToRenderStep("BarrierService", 1, BarrierService)
			end)
			child:GetPropertyChangedSignal("Parent"):Once(function()
				barrierChangedConnection:Disconnect()
			end)
		end
	end

	workspace:WaitForChild("_WorldOrigin"):WaitForChild("Locations")

	for _, child in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
		Check(child)
	end

	workspace._WorldOrigin.Locations.ChildAdded:Connect(Check)
end