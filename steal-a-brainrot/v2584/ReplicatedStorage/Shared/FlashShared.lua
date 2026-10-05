local createVector = vector.create
game:GetService("CollectionService")
game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local Observers = require(ReplicatedStorage.Packages.Observers)
Asserts.Table({ Asserts.Finite, Asserts.Finite, Asserts.Finite })
local replicated = FastFlags.Replicated("Flash.Enabled", Asserts.Boolean, true)
local replicated2 = FastFlags.Replicated("Flash.Cooldown", Asserts.NonNegative, 20)
local replicated3 = FastFlags.Replicated("Flash.Distance", Asserts.NonNegative, 40)
local replicated4 = FastFlags.Replicated("Flash.MaxRootDistance", Asserts.NonNegative, 10)
local replicated5 = FastFlags.Replicated("Flash.ResultTolerance", Asserts.NonNegative, 0.5)
local replicated6 = FastFlags.Replicated("Flash.MinTravel", Asserts.NonNegative, 2)
local raycastParams = RaycastParams.new()
raycastParams.IgnoreWater = true
raycastParams.BruteForceAllSlow = false
raycastParams.RespectCanCollide = true
raycastParams.CollisionGroup = "Player"
local excludeInstances = {}
Observers.observeTag("FlashTeleportIgnore", function(p)
	table.insert(excludeInstances, p)
	raycastParams.ExcludeInstances = excludeInstances
	return function()
		local index = table.find(excludeInstances, p)

		if index then
			table.remove(excludeInstances, index)
		end
	end
end)
Observers.observeCharacters(function(_, p)
	table.insert(excludeInstances, p)
	raycastParams.ExcludeInstances = excludeInstances
	return function()
		local index = table.find(excludeInstances, p)

		if index then
			table.remove(excludeInstances, index)
		end
	end
end)

local function BlockcastWithRaycast(cframe: CFrame, vector2: Vector3, vector3: Vector3, raycastParams2)
	local v2 = nil

	local function submit(raycastResult: RaycastResult?)
		if not raycastResult then
			return
		end

		if not v2 or raycastResult.Distance < v2.Distance then
			v2 = raycastResult
		end
	end

	local blockcast = workspace:Blockcast(cframe, vector2, vector3, raycastParams2)

	if blockcast and (not v2 or blockcast.Distance < v2.Distance) then
		v2 = blockcast
	end

	local raycastResult = workspace:Raycast(cframe.Position, vector3, raycastParams2)

	if raycastResult and (not v2 or raycastResult.Distance < v2.Distance) then
		v2 = raycastResult
	end

	if not ((vector3 * createVector(1, 0, 1)).Magnitude > 0.001) then
		return v2
	end

	local v3 = math.max(vector2.X, vector2.Y, vector2.Z)
	local v4 = vector3.Unit * v3
	local v5 = cframe - v4
	local v6 = vector3 + v4
	local blockcast2 = workspace:Blockcast(v5, vector2, v6, raycastParams2)
	local v7 = blockcast2 and {
		Instance = blockcast2.Instance,
		Position = blockcast2.Position,
		Normal = blockcast2.Normal,
		Material = blockcast2.Material,
		Distance = math.max(0, blockcast2.Distance - v3)
	}

	if v7 and (not v2 or v7.Distance < v2.Distance) then
		v2 = v7
	end

	return v2
end

local table2 = Asserts.Table({
	RootCFrame = Asserts.CFrameFinite,
	RootSize = Asserts.Vector3Positive,
	HipHeight = Asserts.FiniteNonNegative,
	CameraCFrame = Asserts.CFrameFinite,
	Distance = Asserts.FiniteNonNegative
})
local table3 = Asserts.Table({
	CFrame = Asserts.CFrameFinite,
	Valid = Asserts.Boolean
})
return table.freeze({
	ToVector3 = function(list)
		return (Vector3.new(list[1], list[2], list[3]))
	end,
	Enabled = replicated,
	Cooldown = replicated2,
	Distance = replicated3,
	MaxRootDistance = replicated4,
	ResultTolerance = replicated5,
	Compute = function(data)
		table2(data)
		local distance = data.Distance
		local rootSize = data.RootSize
		local hipHeight = data.HipHeight
		local v2 = hipHeight + rootSize.Y * 0.5
		local v3 = data.RootCFrame * CFrame.new(0, -v2, 0)
		local v4 = data.CameraCFrame * CFrame.fromOrientation(0.2617993877991494, 0, 0)
		local cframe = CFrame.lookAlong(v3.Position, v4.LookVector)
		local cframe2 = cframe * CFrame.new(0, 0, -distance)
		local v5 = -1e999
		local v6 = math.sqrt(rootSize.X ^ 2 + rootSize.Z ^ 2)
		local vector2 = Vector3.new(v6, hipHeight + rootSize.Y, v6)
		local cframe3 = CFrame.new(0, vector2.Y * 0.5, 0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function submit(cframe4: CFrame)
			local magnitude = ((cframe.Position - cframe4.Position) * createVector(1, 0, 1)).Magnitude

			if v5 < magnitude then
				v5 = magnitude
				cframe2 = cframe4
			end
		end

		local flag = false
		local v7 = cframe * CFrame.new(0, 0, -distance)
		local v8 = v7.Position - cframe.Position
		local blockcastWithRaycast = BlockcastWithRaycast(cframe * cframe3, vector2, v8, raycastParams)

		if blockcastWithRaycast then
			flag = true
			submit(CFrame.new(cframe.Position + v8.Unit * blockcastWithRaycast.Distance) * v7.Rotation) -- equivalent call inferred; original call site unknown
		else
			submit(v7) -- equivalent call inferred; original call site unknown
		end

		if flag then
			local Y = vector2.Y
			local v10 = {
				Y * 0.25,
				Y * 0.5,
				Y * 1,
				Y * 1.25,
				Y * 1.5,
				Y * 2,
				0.5,
				1,
				2.5,
				5
			}

			for _, v11 in ipairs(v10) do
				local v12 = { CFrame.new(0, v11, 0), CFrame.new(0, 0, -distance), CFrame.new(0, -v11, 0) }
				local v13 = cframe

				for _, v14 in ipairs(v12) do
					local v15 = v13 * v14
					local v16 = v15.Position - v13.Position
					local blockcastWithRaycast2 = BlockcastWithRaycast(v13 * cframe3, vector2, v16, raycastParams)

					if blockcastWithRaycast2 then
						v13 = CFrame.new(v13.Position + v16.Unit * blockcastWithRaycast2.Distance) * v15.Rotation
					else
						v13 = v15
					end
				end

				submit(v13) -- equivalent call inferred; original call site unknown
			end
		end

		local v10 = math.max(replicated6:Get(), v6)
		local _, v11, _ = cframe2:ToOrientation()
		return {
			CFrame = CFrame.new(cframe2.Position) * CFrame.fromOrientation(0, v11, 0),
			Valid = v10 <= v5
		}
	end,
	BuildComputeParams = function(player, cframe: CFrame)
		local v2

		if typeof(player) == "Instance" then
			v2 = player:IsA("Player")
		else
			v2 = false
		end

		assert(v2)
		Asserts.CFrameFinite(cframe)
		local distance = replicated3:Get()
		local character = player.Character

		if not character then
			return nil
		end

		local primaryPart = character.PrimaryPart

		if not primaryPart then
			return nil
		end

		local humanoid = character:FindFirstChildWhichIsA("Humanoid")

		if humanoid then
			return {
				RootCFrame = primaryPart.CFrame,
				RootSize = primaryPart.Size,
				HipHeight = humanoid.HipHeight,
				CameraCFrame = cframe,
				Distance = distance
			}
		end

		return nil
	end,
	AssertComputeParams = table2,
	AssertComputeResult = table3
})