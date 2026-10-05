local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local FX = require(game.ReplicatedStorage.FX)
local X = FX:WaitForChild("DogHouse").X
local v = {
	DogHouse = script:WaitForChild("DogHouse"),
	Slayer = script:WaitForChild("Slayer")
}
local Util = require(game.ReplicatedStorage.Util)
local v2 = {}

local function getParts(part)
	local parts = {}

	if part:IsA("BasePart") then
		table.insert(parts, part)
	end

	for _, part2 in ipairs(part:GetDescendants()) do
		if part2:IsA("BasePart") then
			table.insert(parts, part2)
		end
	end

	return parts
end

local function getBottomCenterOffset(clone)
	local pivot = clone:GetPivot()
	clone:PivotTo(CFrame.new(pivot.Position))
	local v3 = 1e999
	local v4 = -1e999
	local v5 = 1e999
	local v6 = 1e999
	local v7 = -1e999

	for _, v8 in ipairs((getParts(clone))) do
		local cFrame = v8.CFrame
		local size = v8.Size

		for i = -1, 1, 2 do
			for i2 = -1, 1, 2 do
				for i3 = -1, 1, 2 do
					local position = (cFrame * CFrame.new(i * size.X / 2, i2 * size.Y / 2, i3 * size.Z / 2)).Position
					v3 = math.min(v3, position.X)
					v4 = math.max(v4, position.X)
					v5 = math.min(v5, position.Y)
					v6 = math.min(v6, position.Z)
					v7 = math.max(v7, position.Z)
				end
			end
		end
	end

	clone:PivotTo(pivot)
	return Vector3.new((v3 + v4) / 2, v5, (v6 + v7) / 2) - pivot.Position
end

local function hideCharacter(character, p)
	local backpacks = { character }
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:FindFirstChild("Backpack") then
		table.insert(backpacks, playerFromCharacter.Backpack)
	end

	for _, folder in ipairs(backpacks) do
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant == p then
				continue
			end

			if descendant:IsA("BasePart") then
				if descendant.Transparency < 1 then
					descendant:SetAttribute("DogHouseInvisible", descendant.Transparency)
					descendant.Transparency = 1
				end
			elseif descendant:IsA("Decal") and descendant.Name == "face" and descendant.Transparency < 1 then
				descendant:SetAttribute("DogHouseInvisible", descendant.Transparency)
				descendant.Transparency = 1
			end
		end
	end
end

local function restoreChar(character)
	local backpacks = { character }
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:FindFirstChild("Backpack") then
		table.insert(backpacks, playerFromCharacter.Backpack)
	end

	for _, folder in ipairs(backpacks) do
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				local dogHouseInvisible = descendant:GetAttribute("DogHouseInvisible")

				if dogHouseInvisible ~= nil then
					descendant.Transparency = dogHouseInvisible
					descendant:SetAttribute("DogHouseInvisible", nil)
				end
			elseif descendant:IsA("Decal") and descendant.Name == "face" then
				local dogHouseInvisible = descendant:GetAttribute("DogHouseInvisible")

				if dogHouseInvisible ~= nil then
					descendant.Transparency = dogHouseInvisible
					descendant:SetAttribute("DogHouseInvisible", nil)
				end
			end
		end
	end
end

local function revealChar(character)
	local backpacks = { character }
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:FindFirstChild("Backpack") then
		table.insert(backpacks, playerFromCharacter.Backpack)
	end

	for _, folder in ipairs(backpacks) do
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("BasePart") then
				local dogHouseInvisible = descendant:GetAttribute("DogHouseInvisible")

				if dogHouseInvisible ~= nil then
					descendant.Transparency = dogHouseInvisible
				end
			elseif descendant:IsA("Decal") and descendant.Name == "face" then
				local dogHouseInvisible = descendant:GetAttribute("DogHouseInvisible")

				if dogHouseInvisible ~= nil then
					descendant.Transparency = dogHouseInvisible
				end
			end
		end
	end
end

local function cleanupChar(character, flag: boolean?)
	local v3 = v2[character]

	if not v3 then
		return
	end

	if v3.Connection and v3.Connection.Connected then
		v3.Connection:Disconnect()
	end

	if v3.DiedConnection and v3.DiedConnection.Connected then
		v3.DiedConnection:Disconnect()
	end

	if v3.BackpackConnection and v3.BackpackConnection.Connected then
		v3.BackpackConnection:Disconnect()
	end

	if v3.ToolConnection and v3.ToolConnection.Connected then
		v3.ToolConnection:Disconnect()
	end

	if flag and v3.Model and v3.Model.Parent then
		v3.Model:Destroy()
	end

	v2[character] = nil
end

local function RedExplosion(root)
	local redExplosion = X:FindFirstChild("RedExplosion")

	if not redExplosion then
		return
	end

	local clone = redExplosion:Clone()
	clone.Name = "DogHouseRedExplosion"

	if clone:IsA("BasePart") then
		clone.Anchored = true
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.CFrame = root.CFrame
		clone.Parent = _WorldOrigin
	elseif clone:IsA("Attachment") then
		clone.Parent = root
	elseif clone:IsA("Model") then
		clone:PivotTo(root.CFrame)
		clone.Parent = _WorldOrigin
	else
		local attachment = Instance.new("Attachment")
		attachment.Name = "DogHouseRedExplosionAttachment"
		attachment.Parent = root

		for _, child in ipairs(clone:GetChildren()) do
			child.Parent = attachment
		end

		clone:Destroy()
		clone = attachment
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
			descendant:Emit(descendant:GetAttribute("EmitCount") or 35)
		elseif descendant:IsA("Sound") then
			descendant:Play()
		elseif descendant:IsA("Beam") or descendant:IsA("Trail") then
			descendant.Enabled = true
			local v3 = descendant
			task.delay(0.35, function()
				if v3 and v3.Parent then
					v3.Enabled = false
				end
			end)
		end
	end

	Debris:AddItem(clone, 3)
end

local function explodeDogHouse(model, position: Vector3)
	local parts = getParts(model)
	Util.Sound:Play("TigerFt_FSkill_Explode_03", position)

	for _, part in ipairs(parts) do
		if not (part and part.Parent) then
			continue
		end

		local clone = part:Clone()

		for _, descendant in ipairs(clone:GetDescendants()) do
			if not (descendant:IsA("Weld") or descendant:IsA("Motor6D") or descendant:IsA("WeldConstraint") or descendant:IsA("BallSocketConstraint") or descendant:IsA("HingeConstraint")) then
				continue
			end

			descendant:Destroy()
		end

		clone.Anchored = false
		clone.CanCollide = false
		clone.CanTouch = false
		clone.CanQuery = false
		clone.Massless = true
		clone.CFrame = part.CFrame
		clone.Parent = _WorldOrigin
		part.LocalTransparencyModifier = 1
		local vector2 = clone.Position - position

		if vector2.Magnitude < 2 then
			vector2 = Vector3.new(math.random() - 0.5, math.random() * 0.8 + 0.4, math.random() - 0.5)
		end

		local unit = (vector2.Unit + Vector3.new(
			(math.random() - 0.5) * 0.8,
			math.random() * 0.65,
			(math.random() - 0.5) * 0.8
		)).Unit
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(1000000000, 1000000000, 1000000000)
		bodyVelocity.Velocity = unit * math.random(35, 95) + Vector3.new(0, math.random(35, 85), 0)
		bodyVelocity.Parent = clone
		Debris:AddItem(bodyVelocity, 0.18)
		local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
		bodyAngularVelocity.MaxTorque = createVector(1000000000, 1000000000, 1000000000)
		bodyAngularVelocity.AngularVelocity = Vector3.new(
			math.random(-12, 12),
			math.random(-12, 12),
			math.random(-12, 12)
		)
		bodyAngularVelocity.Parent = clone
		Debris:AddItem(bodyAngularVelocity, 0.35)
		task.delay(0.45 + math.random() * 0.25, function()
			if clone and clone.Parent then
				TweenService:Create(clone, TweenInfo.new(0.45), {
					Size = createVector(0.05, 0.05, 0.05),
					Transparency = 1
				}):Play()
			end
		end)
		Debris:AddItem(clone, 1.35)
	end
end

local function dogyhouse(character, root, humanoid, duration: number?, modelName: string?, flag: boolean?)
	cleanupChar(character, true)
	hideCharacter(character, root)
	local clone = (v[modelName or "DogHouse"] or v.DogHouse):Clone()
	clone.Name = (modelName or "DogHouse") .. "XLocal"
	clone.Parent = _WorldOrigin

	for _, v3 in ipairs((getParts(clone))) do
		v3.Anchored = true
		v3.CanCollide = false
		v3.CanTouch = false
		v3.CanQuery = false
		v3.Massless = true
	end

	local hrpSizeScale = root:GetAttribute("HrpSizeScale")
	local v3 = (math.max(
		root.Size.Magnitude / (createVector(2, 2, 1)).Magnitude * (hrpSizeScale and hrpSizeScale.Y or 1),
		1
	) - 1) * 0.55 + 1

	if v3 ~= 1 then
		clone:ScaleTo(clone:GetScale() * v3)
	end

	local identity = CFrame.identity

	if modelName == "Slayer" then
		identity = CFrame.Angles(0, 3.141592653589793, 0)
	end

	local bottomCenterOffset = getBottomCenterOffset(clone)

	local function getGroundedCF()
		local lookVector = root.CFrame.LookVector
		local vector2 = Vector3.new(lookVector.X, 0, lookVector.Z)
		local v4 = vector2.Magnitude < 0.01 and createVector(0, 0, -1) or vector2.Unit
		local cframe = CFrame.lookAt(createVector(0, 0, 0), v4) * identity
		local v5 = root.Position.Y - root.Size.Y / 2 - humanoid.HipHeight
		local vector3 = Vector3.new(root.Position.X, v5, root.Position.Z)
		return CFrame.new(vector3 - cframe:VectorToWorldSpace(bottomCenterOffset)) * cframe
	end

	local groundedCF = getGroundedCF()
	local clone2 = X.Cube:Clone()
	clone2.Parent = _WorldOrigin
	local random = Random.new()

	if clone2:IsA("BasePart") then
		clone2.CFrame = root.CFrame
	end

	clone2.Smoke:Emit(25)
	Util.Sound:Play("ChestPoof1", clone2.Position, nil, 1 + random:NextNumber(-1, 1) / 3, 0.25)
	local Debris2 = game:GetService("Debris")
	Debris2:AddItem(clone2, 4)
	clone:PivotTo(groundedCF)

	local function update(p)
		if character.Parent and root.Parent and clone.Parent then
			local groundedCF2 = getGroundedCF()
			local v4 = 1 - math.exp(-167 * p)
			groundedCF = groundedCF:Lerp(groundedCF2, v4)
			clone:PivotTo(groundedCF)
		else
			cleanupChar(character, true)
			restoreChar(character)
		end
	end

	local v4 = {
		Model = clone,
		Connection = RunService.Heartbeat:Connect(update),
		Hidden = true,
		Persistent = flag == true
	}
	v2[character] = v4
	v4.DiedConnection = humanoid.Died:Connect(function()
		if v2[character] == v4 then
			cleanupChar(character, true)
			restoreChar(character)
		end
	end)
	v4.ToolConnection = character.ChildAdded:Connect(function(tool)
		if not tool:IsA("Tool") then
			return
		end

		task.defer(function()
			if not (v2[character] == v4 and v4.Hidden and tool.Parent == character) then
				return
			end

			hideCharacter(character, root)
		end)
	end)
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(character)

	if playerFromCharacter and playerFromCharacter:FindFirstChild("Backpack") then
		v4.BackpackConnection = playerFromCharacter.Backpack.ChildAdded:Connect(function(tool)
			if not tool:IsA("Tool") then
				return
			end

			task.delay(0.1, function()
				if not (v2[character] == v4 and v4.Hidden) then
					return
				end

				hideCharacter(character, root)
			end)
		end)
	end

	if not flag then
		task.delay((duration or 5) + 2, function()
			if v2[character] and v2[character].Model == clone then
				cleanupChar(character, true)
				restoreChar(character)
			end
		end)
	end
end

return function(player)
	local character = player.Character
	local root = player.Root
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if not (character and root and humanoid) then
		return
	end

	local phase = player.Phase or 1

	if phase == 1 then
		dogyhouse(
			character,
			root,
			humanoid,
			player.Duration or 5,
			player.ModelName or "DogHouse",
			player.Persistent == true
		)
	elseif phase == 2 then
		local v3 = v2[character]

		if v3 then
			if v3.Connection and v3.Connection.Connected then
				v3.Connection:Disconnect()
			end

			if v3.Model and v3.Model.Parent then
				explodeDogHouse(v3.Model, root.Position)
				v3.Model:Destroy()
			end

			v2[character] = nil
		end

		RedExplosion(root)
		restoreChar(character)
	elseif phase == 3 then
		local v3 = v2[character]

		if v3 then
			v3.Hidden = false
			revealChar(character)
		end
	elseif phase == 4 then
		local v3 = v2[character]

		if v3 and character:GetAttribute("DogHouseFormM1") then
			v3.Hidden = true
			hideCharacter(character, root)
		end
	elseif phase == 5 then
		cleanupChar(character, true)
		restoreChar(character)
	end
end