local createVector = vector.create
local RunService = game:GetService("RunService")
game:GetService("Debris")
local v = {
	Speed = 60,
	Drag = 4,
	Spread = 15,
	LifeTime = 4,
	FadeTrail = true,
	StopThreshold = 0.5,
	TurbulenceStrength = 8,
	TurbulenceSpeed = 3,
	LinkTurbulenceToSpeed = true,
	SpinSpeed = 0,
	Gravity = createVector(0, -8, 0)
}

local function ApplySpread(unit: Vector3, spread: number)
	if spread == 0 then
		return unit
	end

	local cframe = CFrame.lookAt(createVector(0, 0, 0), unit)
	local v2 = math.rad((math.random() - 0.5) * spread)
	local v3 = math.rad((math.random() - 0.5) * spread)
	return (cframe * CFrame.Angles(v2, v3, 0)).LookVector
end

return {
	Create = function(position: Vector3, vector2: Vector3?, instance, items)
		local clone = table.clone(v)

		if items then
			for k, item in pairs(items) do
				clone[k] = item
			end
		end

		local unit = vector2 and vector2.Unit or createVector(0, 1, 0)
		local applySpread = ApplySpread(unit, clone.Spread)
		local v3 = {}
		local parent

		if instance then
			parent = instance:Clone()

			for _, trail in pairs(parent:GetDescendants()) do
				if trail:IsA("Trail") then
					table.insert(v3, trail)
				end
			end
		else
			parent = Instance.new("Part")
			parent.Size = createVector(0.2, 0.2, 0.2)
			parent.Color = Color3.fromRGB(255, 150, 50)
			parent.Material = Enum.Material.Neon
			parent.Shape = Enum.PartType.Ball
			game.Debris:AddItem(parent, clone.LifeTime + 0.1)
			local attachment = Instance.new("Attachment", parent)
			attachment.Position = Vector3.new(0, parent.Size.Y / 2, 0)
			local attachment2 = Instance.new("Attachment", parent)
			attachment2.Position = Vector3.new(0, -parent.Size.Y / 2, 0)
			local trail = Instance.new("Trail")
			trail.Attachment0 = attachment
			trail.Attachment1 = attachment2
			trail.Lifetime = 0.4
			trail.LightEmission = 1
			trail.Color = ColorSequence.new(parent.Color)
			trail.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			})
			trail.Parent = parent
			table.insert(v3, trail)
		end

		parent.Anchored = true
		parent.CanCollide = false
		parent.CastShadow = false
		parent.CFrame = CFrame.new(position)
		parent.Parent = workspace.Thrown
		local v5 = position
		local v6 = applySpread * clone.Speed
		local speed = clone.Speed
		local v7 = math.random() * 10000
		local v8 = math.random() * 10000
		local v9 = math.random() * 10000
		local v10 = math.random() * 10000
		task.spawn(function()
			local lastTime = os.clock()
			local v11 = 0
			local heartbeatConnection = nil
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				v11 = os.clock() - lastTime

				if v11 >= clone.LifeTime then
					heartbeatConnection:Disconnect()
					parent:Destroy()
				else
					v6 += clone.Gravity * dt
					local v12 = math.clamp(1 - clone.Drag * dt, 0, 1)
					v6 *= v12

					if v6.Magnitude < clone.StopThreshold then
						v6 = createVector(0, 0, 0)
					end

					local v13 = math.clamp(v6.Magnitude / speed, 0, 1)
					local turbulenceStrength = clone.TurbulenceStrength

					if clone.LinkTurbulenceToSpeed then
						turbulenceStrength *= v13
					end

					local v14 = v11 * clone.TurbulenceSpeed
					local v15 = Vector3.new(math.noise(v14, v7), math.noise(v14, v8), math.noise(v14, v9)) * turbulenceStrength * dt
					v5 = v5 + v6 * dt + v15
					local spinSpeed = clone.SpinSpeed

					if clone.LinkTurbulenceToSpeed then
						spinSpeed *= v13
					end

					if spinSpeed > 0.01 then
						local cframe = CFrame.Angles(
							math.rad(math.noise(v11, v10) * spinSpeed * 10),
							math.rad(math.noise(v11, v10 + 10) * spinSpeed * 10),
							(math.rad(math.noise(v11, v10 + 20) * spinSpeed * 10))
						)
						parent.CFrame = CFrame.new(v5) * (parent.CFrame.Rotation * cframe)
					else
						parent.CFrame = CFrame.new(v5) * parent.CFrame.Rotation
					end

					local v16 = clone.LifeTime * 0.75

					if v16 < v11 then
						local v17 = clone.LifeTime - v16
						local v18 = math.clamp((v11 - v16) / v17, 0, 1)

						if clone.FadeTrail then
							local numberSequence = NumberSequence.new({
								NumberSequenceKeypoint.new(0, v18),
								NumberSequenceKeypoint.new(1, 1)
							})

							for _, v19 in ipairs(v3) do
								v19.Transparency = numberSequence
							end
						end
					end
				end
			end)
		end)
	end
}