local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DamageIndicator = {}
local v = {}
local Streaming = require(ReplicatedStorage.Chest.Assets.Modules.Streaming)
local currentCamera = workspace.CurrentCamera

function GetCharacterVisualData(p)
	local v2 = v[p]

	if not v2 then
		v2 = {}
		v[p] = v2
	end

	return v2
end

function ClearVisualCaches(items)
	for _, item in pairs(items) do
		if type(item) == "table" then
			ClearVisualCaches(item)
		elseif typeof(item) == "Instance" then
			local v2 = item
			pcall(function()
				v2:Destroy()
			end)
		end
	end
end

local v2 = {
	Ronin = function(parent, flag: boolean)
		local v3 = GetCharacterVisualData(parent)

		if flag then
			local humanoidRootPart = parent.HumanoidRootPart
			v3.RoninFX = v3.RoninFX or {}
			local v5 = { createVector(2.62, 6.256, 0), createVector(-2.62, 6.256, 0) }

			for _, v6 in pairs(v3.RoninFX) do
				v6:Destroy()
			end

			v3.RoninFX = {}

			for childName, _ in pairs({
				RightHand = true,
				RightLowerArm = true,
				RightUpperArm = true,
				LeftHand = true,
				LeftLowerArm = true,
				LeftUpperArm = true
			}) do
				local child = parent:FindFirstChild(childName)

				if not child then
					continue
				end

				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.Smoke:Clone()
				clone.Parent = child
				clone.Enabled = true
				table.insert(v3.RoninFX, clone)
			end

			for _, position in pairs(v5) do
				local attachment = Instance.new("Attachment")
				attachment.Position = createVector(0, -3.311, 0)
				local attachment2 = Instance.new("Attachment")
				attachment2.Position = position
				attachment2.Parent = attachment
				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.RedWind:Clone()
				clone.Attachment0 = attachment
				clone.Attachment1 = attachment2
				clone.Parent = attachment
				local clone2 = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.DarkWind:Clone()
				clone2.Attachment0 = attachment
				clone2.Attachment1 = attachment2
				clone2.Parent = attachment
				attachment.Parent = humanoidRootPart
				table.insert(v3.RoninFX, attachment)
			end

			local humanoidRootPart2 = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart2 then
				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Ronin.GlowPart:Clone()
				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart2
				weld.Part1 = clone
				weld.Parent = clone
				clone.Parent = parent
				table.insert(v3.RoninFX, clone)
			end
		else
			if not v3.RoninFX then
				return
			end

			for _, emitter in pairs(v3.RoninFX) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				else
					for _, emitter2 in pairs(emitter:GetDescendants()) do
						if emitter2:IsA("ParticleEmitter") then
							emitter2.Enabled = false
						end
					end
				end

				local v4 = emitter
				task.spawn(function()
					wait(1)
					v4:Destroy()
				end)
			end

			v3.RoninFX = {}
		end
	end,
	Brawler = function(parent, flag: boolean)
		local v3 = GetCharacterVisualData(parent)

		if flag then
			v3.BrawlerFX = v3.BrawlerFX or {}

			for _, v4 in pairs(v3.BrawlerFX) do
				v4:Destroy()
			end

			v3.BrawlerFX = {}

			for childName, _ in pairs({
				RightHand = true,
				LeftHand = true
			}) do
				local child = parent:FindFirstChild(childName)

				if not child then
					continue
				end

				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.Lightning1:Clone()
				clone.Parent = child
				clone.Enabled = true
				local clone2 = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.main:Clone()
				clone2.Parent = child
				clone2.Enabled = true
				table.insert(v3.BrawlerFX, clone)
				table.insert(v3.BrawlerFX, clone2)
			end

			for childName, _ in pairs({
				RightLowerArm = true,
				LeftLowerArm = true
			}) do
				local child = parent:FindFirstChild(childName)

				if not child then
					continue
				end

				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.Swirl:Clone()
				clone.Parent = child
				clone.Enabled = true
				table.insert(v3.BrawlerFX, clone)
			end

			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Brawler.GlowPart:Clone()
				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart
				weld.Part1 = clone
				weld.Parent = clone
				clone.Parent = parent
				table.insert(v3.BrawlerFX, clone)
			end
		else
			if not v3.BrawlerFX then
				return
			end

			for _, emitter in pairs(v3.BrawlerFX) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				else
					for _, emitter2 in pairs(emitter:GetDescendants()) do
						if emitter2:IsA("ParticleEmitter") then
							emitter2.Enabled = false
						end
					end
				end

				local v4 = emitter
				task.spawn(function()
					wait(1)
					v4:Destroy()
				end)
			end

			v3.BrawlerFX = {}
		end
	end,
	Eternal = function(parent, flag: boolean)
		local v3 = GetCharacterVisualData(parent)

		if flag then
			v3.EternalFX = v3.EternalFX or {}

			for childName, _ in pairs({
				RightHand = true,
				RightLowerArm = true,
				RightUpperArm = true,
				RightFoot = true,
				RightLowerLeg = true,
				RightUpperLth = true,
				LeftHand = true,
				LeftLowerArm = true,
				LeftUpperArm = true,
				LeftFoot = true,
				LeftLowerLeg = true,
				LeftUpperLth = true,
				Head = true
			}) do
				local child = parent:FindFirstChild(childName)

				if not child then
					continue
				end

				for _, child2 in pairs(ReplicatedStorage.Chest.Etc.PassiveVFX.Eternal.Aura:GetChildren()) do
					local clone = child2:Clone()
					clone.Parent = child
					clone.Enabled = true
					table.insert(v3.EternalFX, clone)
				end
			end

			local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				local clone = ReplicatedStorage.Chest.Etc.PassiveVFX.Eternal.GlowPart:Clone()
				local weld = Instance.new("Weld")
				weld.Part0 = humanoidRootPart
				weld.Part1 = clone
				weld.Parent = clone
				clone.Parent = parent
				table.insert(v3.EternalFX, clone)
			end
		else
			if not v3.EternalFX then
				return
			end

			for _, emitter in pairs(v3.EternalFX) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				else
					for _, emitter2 in pairs(emitter:GetDescendants()) do
						if emitter2:IsA("ParticleEmitter") then
							emitter2.Enabled = false
						end
					end
				end

				local v4 = emitter
				task.spawn(function()
					wait(1)
					v4:Destroy()
				end)
			end

			v3.EternalFX = {}
		end
	end
}

function DamageIndicator.new(instance)
	local humanoid = instance.Humanoid
	local primaryPart = instance.PrimaryPart
	local health = humanoid.Health
	local v3 = {}
	local characterPassives = instance:FindFirstChild("CharacterPassives")
	return humanoid.HealthChanged:Connect(function()
		local health2 = humanoid.Health

		if characterPassives then
			if humanoid.Health <= humanoid.MaxHealth * 0.15 then
				if characterPassives:FindFirstChild("Ronin") and not v3.Ronin then
					v3.Ronin = true
					v2.Ronin(instance, true)
				end

				if characterPassives:FindFirstChild("Brawler") and not v3.Brawler then
					v3.Brawler = true
					v2.Brawler(instance, true)
				end

				if characterPassives:FindFirstChild("Eternal") and not v3.Eternal then
					v3.Eternal = true
					v2.Eternal(instance, true)
				end
			else
				if v3.Ronin then
					v3.Ronin = nil
					v2.Ronin(instance, false)
				end

				if v3.Brawler then
					v3.Brawler = nil
					v2.Brawler(instance, false)
				end

				if v3.Eternal then
					v3.Eternal = nil
					v2.Eternal(instance, false)
				end
			end
		end

		if (primaryPart.Position - currentCamera.CFrame.Position).Magnitude > Streaming:GetRenderDistance() then
			return
		end

		local v4 = math.abs(health - health2)
		local v5 = health2 < health and "Damage" or "Heal"
		local v6 = v4 <= 0 and "Damage" or v5

		if v4 > 0 then
			if v6 == "Damage" then
				ReplicatedStorage.Chest.Remotes.Bindables.TextDamage:Fire(instance, math.floor(v4), {
					Mode = "Damage"
				})
			elseif v6 == "Heal" then
				local healStack = instance:GetAttribute("HealStack")

				if healStack and healStack > 0 then
					ReplicatedStorage.Chest.Remotes.Bindables.TextDamage:Fire(instance, math.floor(v4), {
						Mode = "Heal"
					})
				end
			end
		end

		health = humanoid.Health
	end)
end

function DamageIndicator.ClearCache(p)
	local v3 = GetCharacterVisualData(p)
	ClearVisualCaches(v3)
	v[p] = nil
end

return DamageIndicator