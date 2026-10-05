local ObsidironClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
local random = Random.new()
local v = {
	Encased = "Raw",
	Raw = "Scalding Obsidiron Ingot",
	["Scalding Obsidiron Ingot"] = "Obsidiron Ingot",
	["Obsidiron Ingot"] = "Charged Obsidiron"
}
local v2 = {
	Encased = "ObsidianRockCrack",
	Raw = "ObsidironSmelt",
	Scalding_Obsidiron_Ingot = "ObsidironSizzle"
}
local v3 = {
	Encased = function(p)
		task.spawn(function()
			local stone = p.Ore.Stone

			for _ = 1, 6 do
				local clone = stone:Clone()
				task.spawn(function()
					task.wait(2 + random:NextNumber() * 0.5)
					clone:Destroy()
				end)
				clone.WeldConstraint:Destroy()
				clone.Size *= 0.3 + random:NextNumber() * 0.3
				clone.CFrame = stone.CFrame + Vector3.new(
					random:NextNumber() - 0.5,
					random:NextNumber() - 0.5,
					random:NextNumber() - 0.5
				)
				clone.CanCollide = true
				clone.Parent = workspace.Particles
			end
		end)
	end
}

function AnimateStateChange(instance, value)
	local v4 = string.gsub(value, " ", "_")

	if instance:GetAttribute("Animated_" .. v4) then
		return
	end

	instance:SetAttribute("Animated_" .. v4, true)

	if v3[v4] then
		v3[v4](instance)
	end

	if v2[v4] then
		Client.Sound.Play(v2[v4], {
			Volume = 0.6,
			Instance = instance.PrimaryPart
		})
	end

	if instance:FindFirstChild("Transformation") then
		for _, emitter in pairs(instance.Transformation:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 2)
			end
		end
	end
end

function ProgressOre(instance, p, p2)
	if instance:GetAttribute("LocalOreState") then
		return
	end

	local oreState = instance:GetAttribute("OreState")
	local v4 = v[oreState]

	if p ~= oreState then
		return
	end

	instance:SetAttribute("LocalOreState", v4)
	AnimateStateChange(instance, p)
	task.spawn(function()
		for _ = 0, 2, 0.1 do
			task.wait(0.1)
		end

		instance:SetAttribute("LocalOreState", nil)
	end)
	Client.Events.RequestProgressObsidiron:InvokeServer(instance, p, p2)
end

function UpdateModel(folder)
	local localOreState = folder:GetAttribute("LocalOreState") or folder:GetAttribute("OreState")

	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1

			if descendant.Material == Enum.Material.Glass then
				descendant.Material = Enum.Material.SmoothPlastic
			end
		elseif descendant:IsA("PointLight") then
			descendant.Enabled = false
		elseif descendant:IsA("ParticleEmitter") then
			descendant.Enabled = false
		end
	end

	if localOreState == "Encased" then
		for _, part in pairs(folder.Ore:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 0
			end
		end
	elseif localOreState == "Raw" then
		for _, descendant in pairs(folder.Ore:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Transparency = descendant.Name == "Stone" and 1 or 0
			elseif descendant:IsA("ParticleEmitter") then
				descendant.Enabled = true
			end
		end
	elseif localOreState == "Charged Obsidiron" then
		for _, descendant in pairs(folder.Ore:GetDescendants()) do
			if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
				descendant.Transparency = 0
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("PointLight") then
				descendant.Enabled = true
			end
		end
	else
		local folder2 = folder:FindFirstChild(localOreState)

		if folder2 then
			for _, descendant in pairs(folder2:GetDescendants()) do
				if descendant:IsA("BasePart") and descendant.Name ~= "Main" then
					descendant.Transparency = 0
				elseif descendant:IsA("PointLight") then
					descendant.Enabled = true
				end
			end
		end
	end
end

function ObsidironAdded(instance)
	local steppedConnection = nil
	local v4 = nil

	local function updateState()
		UpdateModel(instance)
		local oreState = instance:GetAttribute("OreState")

		if v4 == oreState then
			return
		end

		if v4 then
			AnimateStateChange(instance, v4)
		end

		v4 = oreState

		if steppedConnection then
			steppedConnection:Disconnect()
		end

		if oreState == "Encased" then
			local v5 = nil
			steppedConnection = RunService.Stepped:Connect(function()
				local assemblyLinearVelocity = instance.PrimaryPart.AssemblyLinearVelocity

				if v5 then
					local magnitude = assemblyLinearVelocity.Magnitude
					local magnitude2 = v5.Magnitude
					local magnitude3 = (v5 - assemblyLinearVelocity).Magnitude
					instance.PrimaryPart:GetTouchingParts()

					if magnitude < 30 and magnitude2 > 50 and magnitude3 > 70 then
						ProgressOre(instance, "Encased")
					end
				end

				v5 = assemblyLinearVelocity
			end)
		end
	end

	instance:GetAttributeChangedSignal("LocalOreState"):Connect(function()
		updateState()
	end)
	instance:GetAttributeChangedSignal("OreState"):Connect(function()
		updateState()
	end)
	updateState()
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if instance:GetAttribute("LocalOreState") then
			return
		end

		if otherPart:GetAttribute("IsLava") and instance:GetAttribute("OreState") == "Raw" then
			ProgressOre(instance, "Raw", otherPart)
		elseif otherPart:HasTag("Water") and not otherPart:GetAttribute("IsLava") and instance:GetAttribute("OreState") == "Scalding Obsidiron Ingot" then
			ProgressOre(instance, "Scalding Obsidiron Ingot", otherPart)
		end
	end)
end

function ObsidironClient.Init()
	Client.Utility.ForAllTagged("Obsidiron", ObsidironAdded)
end

return ObsidironClient