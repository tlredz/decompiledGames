local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local v = { "EquippedWeapon", "UnequippedWeapon" }
local v2 = {
	["Frying Pan"] = {
		Part0 = "RightHand",
		C0 = CFrame.new(0.0358, -0.3802, -0.9674)
	},
	steak = {
		Part0 = "RightHand",
		C0 = CFrame.new(0.336, -0.25, 0.0024)
	}
}
local color = Color3.fromRGB(255, 150, 45)
local color2 = Color3.fromRGB(126, 86, 54)

-- equivalent calls inferred from this helper; original call sites unknown
local function rigScale(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local bodyHeightScale = humanoid and humanoid:FindFirstChild("BodyHeightScale")
	local value = bodyHeightScale and bodyHeightScale.Value

	if typeof(value) == "number" and value > 0 then
		return value
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleProp(clone, p: number)
	if p == 1 then
		return
	end

	local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")

	if specialMesh then
		specialMesh.Scale *= p
	end

	clone.Size *= p
end

local function brown(clone, duration: number)
	local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")

	if not specialMesh then
		TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
			Color = color2
		}):Play()
		return
	end

	specialMesh.VertexColor = createVector(1, 1, 1)
	TweenService:Create(specialMesh, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		VertexColor = createVector(0.2, 0, 0)
	}):Play()
end

local function buildFlame(clone)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, clone.Size.Y * 0.5, 0)
	attachment.Parent = clone
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "CookFlame"
	particleEmitter.Color = ColorSequence.new(color, Color3.fromRGB(255, 226, 140))
	particleEmitter.LightEmission = 1
	particleEmitter.LightInfluence = 0
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(0.4, 0.9),
		NumberSequenceKeypoint.new(1, 0)
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.25, 0.45)
	particleEmitter.Rate = 34
	particleEmitter.Speed = NumberRange.new(2, 4)
	particleEmitter.SpreadAngle = Vector2.new(12, 12)
	particleEmitter.Acceleration = createVector(0, 8, 0)
	particleEmitter.Parent = attachment
	local particleEmitter2 = Instance.new("ParticleEmitter")
	particleEmitter2.Name = "CookSmoke"
	particleEmitter2.Color = ColorSequence.new(Color3.fromRGB(215, 215, 215))
	particleEmitter2.LightInfluence = 1
	particleEmitter2.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(1, 1.8)
	})
	particleEmitter2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.72),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter2.Lifetime = NumberRange.new(0.8, 1.3)
	particleEmitter2.Rate = 12
	particleEmitter2.Speed = NumberRange.new(1.5, 3)
	particleEmitter2.SpreadAngle = Vector2.new(20, 20)
	particleEmitter2.Acceleration = createVector(0, 5, 0)
	particleEmitter2.Parent = attachment
	local pointLight = Instance.new("PointLight")
	pointLight.Color = color
	pointLight.Brightness = 2.5
	pointLight.Range = 11
	pointLight.Parent = clone
	return { particleEmitter, particleEmitter2 }, pointLight
end

return function(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or player.Root

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 900 then
		return
	end

	local v3 = os.clock() + (player.Duration or 5)
	local chefCooking = character:GetAttribute("ChefCooking")

	if typeof(chefCooking) == "number" and os.clock() < chefCooking then
		character:SetAttribute("ChefCooking", v3)
		return
	end

	character:SetAttribute("ChefCooking", v3)
	local chefProps = script:FindFirstChild("ChefProps")

	if chefProps then
		local v4 = {}
		local clones = {}
		local v5 = {}
		local v6 = {}
		local v7 = {}
		local v8 = nil

		for _, childName in v do
			local folder = character:FindFirstChild(childName)

			if not folder then
				continue
			end

			for _, part in ipairs(folder:GetDescendants()) do
				if not (part:IsA("BasePart") and part.Transparency < 1) then
					continue
				end

				table.insert(v4, {
					part = part,
					transparency = part.Transparency
				})
				part.Transparency = 1
			end
		end

		local v9 = rigScale(character) -- equivalent call inferred; original call site unknown

		for _, part in ipairs(chefProps:GetChildren()) do
			local v10 = v2[part.Name]

			if not (part:IsA("BasePart") and v10) then
				continue
			end

			local part2 = character:FindFirstChild(v10.Part0)

			if not (part2 and part2:IsA("BasePart")) then
				continue
			end

			local clone = part:Clone()
			scaleProp(clone, v9) -- equivalent call inferred; original call site unknown
			clone.Anchored = false
			clone.CanCollide = false
			clone.CanQuery = false
			clone.CanTouch = false
			clone.Massless = true
			local C0 = v10.C0.Rotation + v10.C0.Position * v9
			clone.CFrame = part2.CFrame * C0
			clone.Parent = character
			local motor6D = Instance.new("Motor6D")
			motor6D.Name = part.Name
			motor6D.Part0 = part2
			motor6D.Part1 = clone
			motor6D.C0 = C0
			motor6D.Parent = part2
			table.insert(clones, clone)
			table.insert(v5, motor6D)

			if part.Name == "Frying Pan" then
				local flame, v12 = buildFlame(clone)
				v8 = clone

				for _, v13 in ipairs(flame) do
					table.insert(v6, v13)
				end

				table.insert(v7, v12)
			elseif part.Name == "steak" then
				local throwAt = player.ThrowAt
				brown(clone, (typeof(throwAt) ~= "number" or not (throwAt > 0)) and 4 or throwAt)
			end
		end

		if #clones == 0 then
			character:SetAttribute("ChefCooking", nil)
			return
		end

		local throwAt = player.ThrowAt

		if typeof(throwAt) == "number" and v8 then
			task.delay(throwAt, function()
				if not v8.Parent then
					return
				end

				for _, v10 in ipairs(v6) do
					v10.Enabled = false
				end

				for _, v10 in ipairs(v7) do
					v10.Enabled = false
				end

				TweenService:Create(v8, TweenInfo.new(0.3), {
					Transparency = 1
				}):Play()
			end)
		end

		task.spawn(function()
			while character.Parent do
				local chefCooking2 = character:GetAttribute("ChefCooking")

				if typeof(chefCooking2) ~= "number" or chefCooking2 <= os.clock() then
					break
				end

				RunService.Heartbeat:Wait()
			end

			for _, v10 in ipairs(v6) do
				v10.Enabled = false
			end

			for _, v10 in ipairs(v7) do
				v10.Enabled = false
			end

			local lastTime = os.clock()

			while os.clock() - lastTime < 0.35 and character.Parent do
				local v10 = (os.clock() - lastTime) / 0.35

				for _, v11 in ipairs(clones) do
					v11.Transparency = math.max(v11.Transparency, v10)
				end

				RunService.Heartbeat:Wait()
			end

			for _, v10 in ipairs(v4) do
				if v10.part.Parent then
					v10.part.Transparency = v10.transparency
				end
			end

			for _, v10 in ipairs(v5) do
				if v10.Parent then
					v10:Destroy()
				end
			end

			for _, v10 in ipairs(clones) do
				if v10.Parent then
					v10:Destroy()
				end
			end

			if character.Parent then
				character:SetAttribute("ChefCooking", nil)
			end
		end)
	else
		warn("Chef.Cooking: ChefProps is missing from the effect module")
		character:SetAttribute("ChefCooking", nil)
	end
end