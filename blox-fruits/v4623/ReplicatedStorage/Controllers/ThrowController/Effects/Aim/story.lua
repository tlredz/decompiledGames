local createVector = vector.create
local RunService = game:GetService("RunService")
local Trajectory = require(game.ReplicatedStorage.Util.Trajectory)
local parentModule = require(script.Parent)
require(script.Parent.Parent.Types)
return function()
	local v = {}
	local connections = {}
	local v2 = nil
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
		clone.Transparency = 1
		clone.Position = workspace:GetAttribute("Throw_TargetCF") or (part.CFrame * CFrame.new(0, -5, -30)).Position
		clone.Parent = workspace
		table.insert(v, clone)
		part.Archivable = false
		clone.Archivable = false
		local v3 = {
			EffectDuration = 30,
			EffectName = "Effect",
			HitRadius = 50,
			Influence = NumberSequence.new(1),
			InnerColor = Color3.fromRGB(255, 255, 255),
			ItemName = "TestItem",
			OuterColor = Color3.fromRGB(0, 0, 0)
		}
		table.insert(connections, RunService.RenderStepped:Connect(function(dt)
			dt *= 1
			local position = part.Position
			local position2 = clone.Position
			workspace:SetAttribute("Throw_AimCF", position)
			workspace:SetAttribute("Throw_TargetCF", position2)
			local arcAim, _ = Trajectory.getArcAim(position, position2)

			if v2 then
				v2:Update(arcAim)
			else
				v2 = parentModule.aim(v3, arcAim)
			end
		end))
	end)
	return function()
		task.cancel(thread)

		if v2 then
			v2:Destroy()
		end

		for _, connection in connections do
			connection:Disconnect()
		end

		for _, v3 in v do
			local v4 = v3
			pcall(function()
				v4:Destroy()
			end)
		end
	end
end