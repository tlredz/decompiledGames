local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local MultiJumpController = require(ReplicatedStorage.Controllers.MultiJumpController)
local Observers = require(ReplicatedStorage.Packages.Observers)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local v = {
	"EggrotCloud",
	"EggrotCloud_Candy",
	"EggrotCloud_Lava",
	"EggrotCloud_Galaxy",
	"EggrotCloud_Divine",
	"EggrotCloud_Sand",
	"EggrotCloud_Rock"
}

local function updateCloudBounds(p)
	local bottomY = 1e999
	local topY = -1e999

	for _, collidablePart in p.CollidableParts do
		local v4 = collidablePart.Size.Y / 2
		local v5 = collidablePart.Position.Y - v4
		local v6 = collidablePart.Position.Y + v4

		if v5 < bottomY then
			bottomY = v5
		end

		if topY < v6 then
			topY = v6
		end
	end

	p.BottomY = bottomY
	p.TopY = topY
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setCloudCollide(state, flag: boolean)
	if state.Colliding == flag then
		return
	end

	state.Colliding = flag

	for _, collidablePart in state.CollidableParts do
		collidablePart.CanCollide = flag
		collidablePart.CanTouch = flag or state.Sand
	end
end

return table.freeze({
	Start = function(_)
		local maid = Trove.new()
		local v2 = {}
		local v3 = {}
		local parts = {}
		local v4 = false
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local overlapParams = OverlapParams.new()
		overlapParams.FilterType = Enum.RaycastFilterType.Include
		overlapParams.MaxParts = 4

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rebuildFilter()
			raycastParams.FilterDescendantsInstances = parts
			overlapParams.FilterDescendantsInstances = parts
		end

		maid:Add(Observers.observeTag(`EggrotGalaxyForce_{localPlayer.UserId}`, function(p)
			local parent = p.Parent

			-- equivalent calls inferred from this helper; original call sites unknown
			local function update()
				p.Force = Vector3.new(
					0,
					parent.AssemblyMass * workspace.Gravity * FFlags:GetInstant("EggrotCloud/GalaxyGravityFactor", 0.65),
					0
				)
			end

			update() -- equivalent call inferred; original call site unknown
			local gravityChangedConnection = workspace:GetPropertyChangedSignal("Gravity"):Connect(update)
			local assemblyMassChangedConnection = parent:GetPropertyChangedSignal("AssemblyMass"):Connect(update)
			return function()
				gravityChangedConnection:Disconnect()
				assemblyMassChangedConnection:Disconnect()
			end
		end, { workspace }))
		maid:Add(RunService.PostSimulation:Connect(function(dt: number)
			local character = localPlayer.Character

			if not character then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local humanoid = character:FindFirstChildOfClass("Humanoid")

			if not (humanoidRootPart and humanoid) then
				return
			end

			local Y = humanoidRootPart.Position.Y
			local v5 = humanoidRootPart.Size.Y / 2
			local v6 = Y + v5
			local v7 = Y - v5 - humanoid.HipHeight
			local v8 = math.max(-humanoidRootPart.AssemblyLinearVelocity.Y, 0)
			local v9 = math.max(math.min(FFlags:GetInstant("EggrotCloud/OneWayRayLength", 150), v8), 15)
			local v10 = workspace:Blockcast(
				CFrame.new(humanoidRootPart.Position.X, v6, humanoidRootPart.Position.Z) * humanoidRootPart.CFrame.Rotation,
				humanoidRootPart.Size,
				Vector3.new(0, -v9, 0),
				raycastParams
			) or workspace:Raycast(
				Vector3.new(humanoidRootPart.Position.X, v6, humanoidRootPart.Position.Z),
				Vector3.new(0, -v9, 0),
				raycastParams
			)
			local v11

			if v10 then
				v11 = v3[v10.Instance]
			end

			local partsInPart = workspace:GetPartsInPart(humanoidRootPart, overlapParams)
			local v12 = {}

			for _, v13 in partsInPart do
				local v14 = v3[v13]

				if v14 then
					v12[v14] = true
				end
			end

			local instant = FFlags:GetInstant("EggrotCloud/SurfaceTolerance", 1)
			local flag = false

			for k, v13 in v2 do
				if v13.Hidden then
					setCloudCollide(v13, false) -- equivalent call inferred; original call site unknown
				elseif v13.Rock and v13.RockFaded then
					setCloudCollide(v13, false) -- equivalent call inferred; original call site unknown
				elseif v13.Sand then
					if not flag then
						for _, collidablePart in v13.CollidableParts do
							local pointToObjectSpace = collidablePart.CFrame:PointToObjectSpace(humanoidRootPart.Position)
							local halfSize = collidablePart.Size / 2

							if not (math.abs(pointToObjectSpace.X) <= halfSize.X and math.abs(pointToObjectSpace.Y) <= halfSize.Y) then
								continue
							end

							if not (math.abs(pointToObjectSpace.Z) <= halfSize.Z) then
								continue
							end

							flag = true
							break
						end
					end
				elseif v7 < v13.BottomY then
					setCloudCollide(v13, false) -- equivalent call inferred; original call site unknown
				elseif v11 == k and not v12[k] and v13.TopY - instant <= v7 then
					setCloudCollide(v13, true) -- equivalent call inferred; original call site unknown
				end
			end

			local instant2 = FFlags:GetInstant("EggrotCloud/RockFadeDuration", 2.5)

			for k, v13 in v2 do
				if not v13.Rock or v13.Hidden then
					continue
				end

				local v14 = instant2 * v13.VanishMultiplier
				local colliding = v13.Colliding

				if colliding then
					if v11 == k and v13.TopY - instant <= v7 then
						colliding = math.abs(humanoidRootPart.AssemblyLinearVelocity.Y) < 3
					else
						colliding = false
					end
				end

				local rockStandTime = v13.RockStandTime
				local rockStandTime2

				if colliding then
					rockStandTime2 = math.min(rockStandTime + dt, v14)
				else
					rockStandTime2 = math.max(
						rockStandTime - dt * FFlags:GetInstant("EggrotCloud/RockRecoverRate", 1),
						0
					)
				end

				if rockStandTime2 ~= v13.RockStandTime then
					v13.RockStandTime = rockStandTime2
					local v16 = rockStandTime2 / v14

					for _, part in v13.Parts do
						local v17 = v13.OriginalTransparencies[part] or 0
						part.Transparency = v17 + (1 - v17) * v16
					end
				end

				if v14 <= rockStandTime2 then
					v13.RockFaded = true
				elseif v13.RockFaded and rockStandTime2 <= v14 * 0.4 then
					v13.RockFaded = false
				end
			end

			if flag then
				local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
				local instant3 = FFlags:GetInstant("EggrotCloud/SandSinkSpeed", 4)

				if assemblyLinearVelocity.Y < -instant3 then
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
						assemblyLinearVelocity.X,
						-instant3,
						assemblyLinearVelocity.Z
					)
				end

				if not v4 then
					MultiJumpController:RefillJumps()
				end
			end

			v4 = flag
		end))

		for _, v5 in v do
			local v6 = v5
			maid:Add(Observers.observeTag(v5, function(part)
				local maid2 = Trove.new()
				local tweens = {}
				local eggrotCloudVanishMultiplier = part:GetAttribute("EggrotCloudVanishMultiplier")
				local v7 = {
					Parts = {},
					CollidableParts = {},
					BottomY = 1e999,
					TopY = -1e999,
					OriginalTransparencies = {},
					Colliding = false,
					Hidden = part:GetAttribute("EggrotCloudHidden") == true,
					Sand = v6 == "EggrotCloud_Sand",
					Rock = v6 == "EggrotCloud_Rock",
					RockStandTime = 0,
					RockFaded = false,
					VanishMultiplier = (type(eggrotCloudVanishMultiplier) ~= "number" or not (eggrotCloudVanishMultiplier > 0)) and 1 or eggrotCloudVanishMultiplier
				}
				v2[part] = v7
				table.insert(parts, part)
				rebuildFilter() -- equivalent call inferred; original call site unknown

				local function addPart(part2)
					table.insert(v7.Parts, part2)
					v7.OriginalTransparencies[part2] = part2.Transparency
					v3[part2] = part

					if part2.CanCollide and not part2:HasTag("EggrotCloudIgnoreCollision") then
						table.insert(v7.CollidableParts, part2)
						part2.CanCollide = false
						part2.CanTouch = v7.Sand
						part2.CanQuery = not v7.Hidden
						local v8 = part2.Size.Y / 2
						local bottomY = part2.Position.Y - v8
						local topY = part2.Position.Y + v8

						if bottomY < v7.BottomY then
							v7.BottomY = bottomY
						end

						if v7.TopY < topY then
							v7.TopY = topY
						end
					end

					if v7.Hidden then
						part2.Transparency = 1
					end
				end

				local function removePart(part2)
					local index = table.find(v7.Parts, part2)

					if index then
						table.remove(v7.Parts, index)
					end

					local index2 = table.find(v7.CollidableParts, part2)

					if index2 then
						table.remove(v7.CollidableParts, index2)
					end

					local originalTransparency = v7.OriginalTransparencies[part2]

					if originalTransparency then
						part2.Transparency = originalTransparency
					end

					if index2 then
						part2.CanCollide = true
						part2.CanTouch = true
						part2.CanQuery = true
					end

					v7.OriginalTransparencies[part2] = nil
					v3[part2] = nil
					updateCloudBounds(v7)
				end

				if part:IsA("BasePart") then
					task.spawn(addPart, part)
				end

				maid2:Add(Observers.observeDescendants(part, function(part2)
					if not part2:IsA("BasePart") then
						return nil
					end

					addPart(part2)
					return function()
						removePart(part2)
					end
				end))
				maid2:Add(part:GetAttributeChangedSignal("EggrotCloudFadeTime"):Connect(function()
					local eggrotCloudFadeTime = part:GetAttribute("EggrotCloudFadeTime")

					if not eggrotCloudFadeTime or eggrotCloudFadeTime <= 0 then
						return
					end

					for k, v8 in tweens do
						v8:Cancel()
					end

					table.clear(tweens)
					local tweenInfo = TweenInfo.new(eggrotCloudFadeTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

					for k, part2 in v7.Parts do
						local tween = TweenService:Create(part2, tweenInfo, {
							Transparency = 1
						})
						table.insert(tweens, tween)
						tween:Play()
					end
				end))
				maid2:Add(part:GetAttributeChangedSignal("EggrotCloudHidden"):Connect(function()
					for k, v8 in tweens do
						v8:Cancel()
					end

					table.clear(tweens)
					local eggrotCloudHidden = part:GetAttribute("EggrotCloudHidden") == true
					v7.Hidden = eggrotCloudHidden

					if eggrotCloudHidden then
						setCloudCollide(v7, false) -- equivalent call inferred; original call site unknown
					end

					for k, collidablePart in v7.CollidableParts do
						collidablePart.CanQuery = not eggrotCloudHidden
					end

					if eggrotCloudHidden then
						for k, part2 in v7.Parts do
							part2.Transparency = 1
						end
					else
						local tweenInfo = TweenInfo.new(
							FFlags:GetInstant("EggrotCloud/ReappearDuration", 0.5),
							Enum.EasingStyle.Quad,
							Enum.EasingDirection.Out
						)

						for k, part2 in v7.Parts do
							local tween = TweenService:Create(part2, tweenInfo, {
								Transparency = v7.OriginalTransparencies[part2]
							})
							table.insert(tweens, tween)
							tween:Play()
						end
					end
				end))
				return function()
					v2[part] = nil
					local index = table.find(parts, part)

					if index then
						table.remove(parts, index)
						rebuildFilter() -- equivalent call inferred; original call site unknown
					end

					maid2:Destroy()

					for k, v8 in tweens do
						v8:Cancel()
					end

					for k, collidablePart in v7.CollidableParts do
						collidablePart.CanCollide = true
						collidablePart.CanTouch = true
						collidablePart.CanQuery = true
					end

					for k, part2 in v7.Parts do
						local originalTransparency = v7.OriginalTransparencies[part2]

						if originalTransparency then
							part2.Transparency = originalTransparency
						end

						v3[part2] = nil
					end
				end
			end, { workspace }))
		end

		return function()
			maid:Destroy()
			table.clear(v2)
			table.clear(v3)
			table.clear(parts)
		end
	end
})