local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local Trove = require(ReplicatedStorage.Packages.Trove)
local Spring = require(ReplicatedStorage.Packages.Spring)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local Animals = require(ReplicatedStorage.Shared.Animals)
local BrainrotAssets = require(ReplicatedStorage.Shared.BrainrotAssets)
local BrainrotCard = require(ReplicatedStorage.Shared.BrainrotCard)
local VFX = require(ReplicatedStorage.Shared.VFX)
local Animals2 = require(ReplicatedStorage.Datas.Animals)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
require(ReplicatedStorage.Shared.EquipBrainrots)
local EquipBrainrotsFlags = require(ReplicatedStorage.Shared.Flags.EquipBrainrotsFlags)
local FastOverheadController = require(ReplicatedStorage.Controllers.FastOverheadController)
local isTradePlaza = ServerData.IsTradePlaza()
local v = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local v2 = v and 0.03333333333333333 or 0
local v3 = v and 0.16666666666666666 or 0.06666666666666667
local renderedMovingAnimals = workspace:WaitForChild("RenderedMovingAnimals")
local animals = ReplicatedStorage:WaitForChild("Animations").Animals
local equipBrainrots = ReplicatorClient.get("EquipBrainrots")
local v4 = {}
local v5 = {}
local v6 = 0
local count = 0
local v7 = {}
local v8 = {}
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = true

-- equivalent calls inferred from this helper; original call sites unknown
local function signatureOf(data)
	return (`{data.Index}|{data.Mutation or ""}|{table.concat(data.Traits or {}, ",")}`)
end

local function lerpAngle(p: number, p2: number, p3: number)
	return p + ((p2 - p + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playPoof(vector2: Vector3)
	local copy = VFX.copy(VFX.Library.Misc.Smoke, CFrame.new(vector2))
	VFX.emit(copy)
	Debris:AddItem(copy, 3)
end

local function attachOneOfOneFrame(maid, clone, primaryPart, data)
	if not FastOverheadController.GuiTemplates.AnimalOverhead:FindFirstChild("1OF1Banner") then
		return
	end

	local v9 = nil
	local OVERHEAD_ATTACHMENT = clone:FindFirstChild("OVERHEAD_ATTACHMENT", true)

	if not (OVERHEAD_ATTACHMENT and OVERHEAD_ATTACHMENT:IsA("Attachment")) then
		OVERHEAD_ATTACHMENT = nil
	end

	local function clearOneOfOneFrame()
		if v9 then
			v9()
			v9 = nil
		end
	end

	maid:Add(clearOneOfOneFrame)
	maid:Add(BrainrotCard.ObserveOneOfOne({
		Index = data.Index,
		Mutation = data.Mutation
	}, function(flag: boolean)
		if flag then
			if v9 then
				return
			end

			if not OVERHEAD_ATTACHMENT then
				local animal = Animals2[data.Index]
				local v10 = maid:Add(Instance.new("Attachment"))
				v10.Name = "1OF1Attachment"
				v10.CFrame = CFrame.new(
					0,
					clone:GetExtentsSize().Y * 0.75 * (animal and animal.OverheadYOffsetModifier or 1),
					0
				)
				v10.Parent = primaryPart
				OVERHEAD_ATTACHMENT = v10
			end

			local adornee = OVERHEAD_ATTACHMENT

			if not adornee then
				return
			end

			local fastOverhead, v11 = FastOverheadController.createFastOverhead({
				adornee = adornee,
				guiTemplate = FastOverheadController.GuiTemplates.AnimalOverhead,
				relativeToAdornee = true,
				studsOffsetY = 0.875
			})
			v9 = v11
			local _1OF1Banner = fastOverhead:FindFirstChild("1OF1Banner")

			for _, guiObject in ipairs(fastOverhead:GetChildren()) do
				if guiObject ~= _1OF1Banner and guiObject:IsA("GuiObject") then
					guiObject.Visible = false
				end
			end

			if _1OF1Banner and _1OF1Banner:IsA("GuiObject") then
				_1OF1Banner.AnchorPoint = Vector2.new(0.5, 0.5)
				_1OF1Banner.Position = UDim2.fromScale(0.5, 0.5)
				_1OF1Banner.Visible = true
			end
		elseif v9 then
			v9()
			v9 = nil
		end
	end))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyPet(k: string)
	local v9 = v4[k]

	if not v9 then
		return
	end

	v4[k] = nil
	v9.Trove:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyAll()
	for k in v4 do
		destroyPet(k) -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawnPet(formatted: string, userKey: string, data)
	v5[formatted] = true
	task.spawn(function()
		local signature = signatureOf(data) -- equivalent call inferred; original call site unknown
		local model = BrainrotAssets.getModel(data.Index)

		if not model then
			v5[formatted] = nil
			return
		end

		local clone = model:Clone()
		local primaryPart = clone.PrimaryPart

		if primaryPart then
			local maid = Trove.new()
			maid:Add(clone)
			clone:SetAttribute("_noTrails", true)

			if data.Mutation then
				maid:Add(Animals:ApplyMutation(clone, data.Index, data.Mutation))
			end

			if data.Traits then
				maid:Add(Animals:ApplyTraits(clone, data.Index, data.Traits))
			end

			clone:ScaleTo(clone:GetScale() * 0.35)

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = false
					descendant.CanQuery = false
					descendant.CanTouch = false
					descendant.Massless = true
					descendant.Anchored = false
				elseif descendant:IsA("Trail") then
					descendant:Destroy()
				end
			end

			local motor6D = Instance.new("Motor6D")
			motor6D.Name = "__equip_transform"
			motor6D.Part0 = workspace.Terrain
			motor6D.Part1 = primaryPart
			motor6D.Parent = primaryPart
			maid:Add(motor6D)
			local playerByUserId = Players:GetPlayerByUserId(tonumber(userKey) or 0)
			local character = playerByUserId and playerByUserId.Character
			local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				motor6D.Transform = humanoidRootPart.CFrame * primaryPart.PivotOffset:Inverse()
			end

			clone.Parent = renderedMovingAnimals
			attachOneOfOneFrame(maid, clone, primaryPart, data)
			local animationController = clone:FindFirstChildWhichIsA("AnimationController") or clone:FindFirstChildWhichIsA("Humanoid")
			local v11 = animationController and animationController:FindFirstChildWhichIsA("Animator")

			if not v11 then
				local animationController2 = Instance.new("AnimationController")
				v11 = Instance.new("Animator")
				v11.Parent = animationController2
				animationController2.Parent = clone
			end

			local child = animals:FindFirstChild(data.Index)
			local track = nil
			local walk = child and child:FindFirstChild("Walk")
			local speed, track2

			if walk then
				speed = walk:GetAttribute("Speed") or 1
				track2 = v11:LoadAnimation(walk)
				track2.Looped = true
				track2:AdjustSpeed(speed)
			else
				speed = 1
			end

			local roadBrainrotIdle = child and (child:FindFirstChild("RoadBrainrotIdle") or child:FindFirstChild("Idle"))

			if roadBrainrotIdle then
				track = v11:LoadAnimation(roadBrainrotIdle)
				track.Looped = true
				track:AdjustSpeed(roadBrainrotIdle:GetAttribute("Speed") or 1)
			end

			if track then
				track:Play()
				track:AdjustWeight(1)
			end

			if track2 then
				track2:Play()
				track2:AdjustWeight(0.001)
			end

			v5[formatted] = nil

			if not EquipBrainrotsFlags.Enabled:Get() then
				maid:Destroy()
				return
			end

			local v12 = v4
			local v14 = {
				Trove = maid,
				Model = clone,
				Motor = motor6D,
				PivotOffsetInverse = primaryPart.PivotOffset:Inverse(),
				WalkTrack = track2,
				WalkBaseSpeed = speed,
				IdleTrack = track,
				PositionSpring = 0,
				HopSpring = 0,
				Yaw = 0,
				GroundY = 0,
				TargetGroundY = 0,
				GroundHit = false,
				LastCastXZ = 0,
				FarSince = 0,
				Initialized = false,
				NextUpdate = 0,
				LastUpdate = 0,
				UserKey = 0,
				Signature = 0
			}
			local positionSpring = Spring.new(Vector2.zero)
			positionSpring.Speed = 9
			positionSpring.Damper = 1
			v14.PositionSpring = positionSpring
			local hopSpring = Spring.new(0)
			hopSpring.Speed = 11
			hopSpring.Damper = 1
			v14.HopSpring = hopSpring
			v14.LastCastXZ = Vector2.zero
			v14.UserKey = userKey
			v14.Signature = signature
			v12[formatted] = v14
		else
			clone:Destroy()
			v5[formatted] = nil
		end
	end)
end

local function reconcile()
	local players = equipBrainrots.Data and equipBrainrots.Data.players or {}

	for k, v9 in v4 do
		local v10, v11 = string.match(k, "^(.-):(.+)$")
		local v12 = v10 and v11 and players[v10] and players[v10][v11]

		if not (not v12 or `{v12.Index}|{v12.Mutation or ""}|{table.concat(v12.Traits or {}, ",")}` ~= v9.Signature) then
			continue
		end

		destroyPet(k) -- equivalent call inferred; original call site unknown
	end

	for k, player in players do
		if typeof(player) ~= "table" then
			continue
		end

		for k2, v9 in player do
			local formatted = `{k}:{k2}`

			if v4[formatted] or v5[formatted] then
				continue
			end

			spawnPet(formatted, k, v9) -- equivalent call inferred; original call site unknown
		end
	end
end

local function updatePets()
	local v9 = {}

	for k, v10 in v4 do
		local v11 = v9[v10.UserKey]

		if not v11 then
			v11 = {}
			v9[v10.UserKey] = v11
		end

		table.insert(v11, k)
	end

	for _, list in v9 do
		table.sort(list)
	end

	local characters = { renderedMovingAnimals }

	for _, v10 in Players:GetPlayers() do
		if v10.Character then
			table.insert(characters, v10.Character)
		end
	end

	raycastParams.FilterDescendantsInstances = characters
	local currentCamera = workspace.CurrentCamera
	local now = os.clock()

	if now - v6 >= 1 then
		v6 = now
		count = 0
	end

	for k, v10 in v9 do
		local playerByUserId = Players:GetPlayerByUserId(tonumber(k) or 0)
		local character = playerByUserId and playerByUserId.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local v11

		if humanoid == nil then
			v11 = false
		else
			v11 = humanoid:GetState() == Enum.HumanoidStateType.Jumping
		end

		if v11 and not v7[k] then
			for _, v12 in v10 do
				local v13 = v4[v12]

				if v13 then
					v13.HopSpring:Impulse(45)
				end
			end
		end

		v7[k] = v11
		local v12 = 0

		if humanoidRootPart and humanoid then
			local v13 = humanoidRootPart.Position.Y - 2.5

			if humanoid.FloorMaterial == Enum.Material.Air then
				v12 = math.max(0, v13 - (v8[k] or v13))
			else
				v8[k] = v13
			end
		end

		for k2, v13 in v10 do
			local v14 = v4[v13]

			if not v14 then
				continue
			end

			if v14.NextUpdate <= now then
				local v15 = now - v14.LastUpdate
				v14.LastUpdate = now
				local v16 = 1 - math.exp(-9 * v15)
				local v17 = 1 - math.exp(-20 * v15)

				if humanoidRootPart then
					if math.isfinite(humanoidRootPart.Position.X) and math.isfinite(humanoidRootPart.Position.Y) and math.isfinite(humanoidRootPart.Position.Z) then
						local cFrame = humanoidRootPart.CFrame
						local v18 = k2 - 1 - (#v10 - 1) * 0.5
						local v19 = (#v10 - 1) * 0.5
						local v20 = (not (v19 > 0) and 1 or 1 - math.abs(v18) / v19) * 2 + 6
						local v21 = cFrame.Position + cFrame.LookVector * -v20 + cFrame.RightVector * (v18 * 4)
						local vector2 = Vector2.new(v21.X, v21.Z)
						local v22 = not v14.Initialized
						local position

						if v22 then
							position = vector2
						else
							position = v14.PositionSpring.Position
						end

						local groundY = cFrame.Position.Y - 2.5
						local magnitude = (position - v14.LastCastXZ).Magnitude

						if (v22 or magnitude > 2) and count < 30 then
							count += 1
							local vector3 = Vector3.new(position.X, cFrame.Position.Y + 4, position.Y)
							local raycastResult = workspace:Raycast(vector3, createVector(0, -13, 0), raycastParams)
							v14.GroundHit = raycastResult ~= nil

							if raycastResult then
								v14.TargetGroundY = raycastResult.Position.Y
							end

							v14.LastCastXZ = position
						end

						if v14.GroundHit then
							groundY = v14.TargetGroundY + v12
						end

						local v24 = false

						if v22 then
							v14.Initialized = true
							v14.PositionSpring:SetTarget(vector2, true)
							v14.GroundY = groundY
						else
							local position2 = v14.PositionSpring.Position

							if (vector2 - position2).Magnitude > 60 then
								if v14.FarSince == 0 then
									v14.FarSince = now
								end

								if now - v14.FarSince >= 1 then
									playPoof(Vector3.new(position2.X, v14.GroundY, position2.Y)) -- equivalent call inferred; original call site unknown
									v14.PositionSpring:SetTarget(vector2, true)
									v14.GroundY = groundY
									playPoof(Vector3.new(vector2.X, groundY, vector2.Y)) -- equivalent call inferred; original call site unknown
									v14.FarSince = 0
								else
									v14.PositionSpring.Target = position2
									v24 = true
								end
							else
								v14.FarSince = 0
								v14.PositionSpring.Target = vector2
							end
						end

						if not v24 then
							v14.GroundY += (groundY - v14.GroundY) * v17
						end

						local position2 = v14.PositionSpring.Position
						local velocity = v14.PositionSpring.Velocity
						local magnitude2 = velocity.Magnitude
						local yaw2

						if magnitude2 > 2 then
							yaw2 = math.atan2(-velocity.X, -velocity.Y)
						else
							local lookVector = cFrame.LookVector
							yaw2 = math.atan2(-lookVector.X, -lookVector.Z)
						end

						if not v22 then
							local yaw = v14.Yaw
							yaw2 = yaw + ((yaw2 - yaw + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * v16
						end

						v14.Yaw = yaw2
						local v26 = math.clamp(magnitude2 / 10, 0, 1)

						if v14.WalkTrack then
							v14.WalkTrack:AdjustWeight((math.max(v26, 0.001)))
							local v27 = math.clamp(magnitude2 / 16, 0.25, 3)
							v14.WalkTrack:AdjustSpeed(v14.WalkBaseSpeed * v27)
						end

						if v14.IdleTrack then
							v14.IdleTrack:AdjustWeight((math.max(1 - v26, 0.001)))
						end

						local v27

						if currentCamera then
							local v28
							v28, v27 = currentCamera:WorldToViewportPoint((Vector3.new(
								position2.X,
								v14.GroundY,
								position2.Y
							)))
						else
							v27 = false
						end

						local v28

						if v27 then
							v28 = v2
						else
							v28 = v3
						end

						v14.NextUpdate = now + v28
					else
						v14.NextUpdate = now + v3
					end
				else
					if v14.WalkTrack then
						v14.WalkTrack:AdjustWeight(0.001)
					end

					if v14.IdleTrack then
						v14.IdleTrack:AdjustWeight(1)
					end

					v14.NextUpdate = now + v3
				end
			end

			if not v14.Initialized then
				continue
			end

			local position = v14.PositionSpring.Position

			if math.isfinite(position.X) and math.isfinite(position.Y) and math.isfinite(v14.GroundY) and math.isfinite(v14.Yaw) then
				local v15 = math.max(v14.HopSpring.Position, 0)
				local v16 = CFrame.new(position.X, v14.GroundY + v15, position.Y) * CFrame.Angles(0, v14.Yaw, 0)
				v14.Motor.Transform = v16 * v14.PivotOffsetInverse
			else
				v14.Initialized = false
				v14.PositionSpring:SetTarget(Vector2.zero, true)
				v14.GroundY = 0
				v14.Yaw = 0
			end
		end
	end
end

return {
	Start = function(_)
		if not isTradePlaza then
			return
		end

		local v9 = EquipBrainrotsFlags.Enabled:Get()
		EquipBrainrotsFlags.Enabled.Changed:Connect(function(flag: boolean)
			v9 = flag

			if not v9 then
				destroyAll() -- equivalent call inferred; original call site unknown
			end
		end)
		RunService.Stepped:Connect(function(_, _: number)
			if not v9 then
				return
			end

			debug.profilebegin("EquipBrainrots::Render")
			reconcile()
			updatePets()
			debug.profileend()
		end)
	end
}