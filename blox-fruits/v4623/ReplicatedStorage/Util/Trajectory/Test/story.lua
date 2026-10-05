local createVector = vector.create
local RunService = game:GetService("RunService")
local ConversionUtil = require(game.ReplicatedStorage.Packages.ConversionUtil)
local parentModule = require(script.Parent)
local roblox = ConversionUtil.Velocity.MilesPerHour.toRoblox(90)
return function()
	local v = {}
	local connections = {}
	local thread = task.spawn(function()
		local part = Instance.new("Part")
		part.Name = "Origin"
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.Material = Enum.Material.Neon
		part.Shape = Enum.PartType.Ball
		part.Position = workspace:GetAttribute("Throw_AimCF") or createVector(0, 15, 0)
		part.Color = Color3.fromRGB(0, 0, 255)
		part.Transparency = 0
		part.Parent = workspace
		table.insert(v, part)
		local clone = part:Clone()
		clone.Name = "Target"
		clone.Color = Color3.fromRGB(255, 0, 0)
		clone.Size = createVector(5, 5, 5)
		clone.Position = workspace:GetAttribute("Throw_TargetCF") or (part.CFrame * CFrame.new(0, -5, -30)).Position
		clone.Parent = workspace
		table.insert(v, clone)
		local clone2 = part:Clone()
		clone2.Name = "Projectile"
		clone2.Color = Color3.fromRGB(0, 255, 0)
		clone2.Size *= 3
		clone2.Parent = workspace
		table.insert(v, clone2)
		local beam = Instance.new("Beam")
		table.insert(v, beam)
		local attachment = Instance.new("Attachment")
		table.insert(v, attachment)
		attachment.Name = "Attachment0"
		attachment.Parent = workspace.Terrain
		beam.Attachment0 = attachment
		local attachment2 = Instance.new("Attachment")
		table.insert(v, attachment2)
		attachment2.Name = "Attachment1"
		attachment2.Parent = workspace.Terrain
		beam.Attachment1 = attachment2
		beam.Segments = 30
		beam.Transparency = NumberSequence.new(0)
		beam.FaceCamera = false
		beam.Width0 = clone2.Size.X
		beam.Width1 = clone2.Size.X
		beam.Parent = part
		part.Archivable = false
		clone2.Archivable = false
		clone.Archivable = false
		local v2 = 0
		local position = clone2.Position
		local v3 = createVector(0, 0, 0)
		table.insert(connections, RunService.RenderStepped:Connect(function(dt)
			local v4 = dt * 1
			local now = tick()
			local position2 = part.Position
			local position3 = clone.Position
			workspace:SetAttribute("Throw_AimCF", position2)
			workspace:SetAttribute("Throw_TargetCF", position3)
			local now2 = tick()
			local arcAim, v5 = parentModule.getArcAim(position2, position3)
			local v6 = arcAim.InitialVelocity.Unit * math.min(arcAim.InitialVelocity.Magnitude, roblox)
			local v7 = not (v5.Iterations >= parentModule.MAX_ITERATIONS or math.abs(v6.Magnitude - roblox) < 0.1)

			if v2 + 3 < now or v7 and (clone.Position - clone2.Position).Magnitude < clone.Size.Magnitude / 2 then
				v2 = now
				position = part.Position
				v3 = v6
			end

			v3 -= Vector3.new(0, workspace.Gravity, 0) * v4
			position += v3 * v4
			clone2.Position = position
			local now3 = tick()
			local now4 = tick()
			parentModule.alignBeam(beam, arcAim)
			local now5 = tick()
			print(string.format((`\ntrajectory flow\n - iterations: {v5.Iterations + 1}\n - solve: {math.round((now3 - now2) * 1000000) / 1000}ms, \n - draw: {math.round((now5 - now4) * 1000000) / 1000}ms,\n - initial speed: {math.round(10 * ConversionUtil.Velocity.Roblox.toMilesPerHour(v6.Magnitude)) / 10} mph`)))
		end))
	end)
	return function()
		task.cancel(thread)

		for _, v2 in v do
			local v3 = v2
			pcall(function()
				v3:Destroy()
			end)
		end

		for _, connection in connections do
			connection:Disconnect()
		end
	end
end