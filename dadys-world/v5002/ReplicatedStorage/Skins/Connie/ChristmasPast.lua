local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "Christmas Past",
	TowerName = "Connie",
	Description = "No description yet",
	Mastery = false,
	Cost = 600,
	Unlocks = require(ReplicatedStorage.SharedData.ReleaseTimes).Christmas2025_W4,
	Christmas = true,
	HolidaySkin = true,
	ApplySkin = function(folder)
		local function handleNameTag(instance)
			local head = instance:FindFirstChild("Head")

			if not head then
				return
			end

			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local nameTag = humanoidRootPart:WaitForChild("NameTag", 5)

			if not nameTag then
				return
			end

			if not head:FindFirstChild("BubbleChat") then
				nameTag.Adornee = head
				return
			end

			local nameTagOverride = head.BubbleChat:FindFirstChild("NameTagOverride")

			if not nameTagOverride then
				nameTag.Adornee = head.BubbleChat
				return
			end

			if nameTagOverride.Value == nil then
			end

			nameTag.Adornee = head.BubbleChat
		end

		for _, descendant in pairs(folder:GetDescendants()) do
			if descendant:HasTag("SkinPart") then
				descendant:RemoveTag("SkinPart")
			end
		end

		local config = folder:WaitForChild("Config")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		local hurtTexture = config:WaitForChild("HurtTexture")
		local normalTexture = config:WaitForChild("NormalTexture")
		blinkTexture.Texture = "rbxassetid://86773043621424"
		hurtTexture.Texture = "rbxassetid://108260989278774"
		normalTexture.Texture = "rbxassetid://116207182734348"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		folder.RootPart.root:Destroy()
		clone.RootPart.root.Parent = folder.RootPart
		local animations = folder:WaitForChild("Animations")

		for _, animation in pairs(clone:WaitForChild("Animations"):GetChildren()) do
			local animation2 = animations:FindFirstChild(animation.Name)

			if animation2 and animation2:IsA("Animation") and animation:IsA("Animation") then
				animation2.AnimationId = animation.AnimationId
			end
		end

		local v = {
			RightUpperArm = "RightUpperrArm",
			Torso = "UpperTorso"
		}

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local weld = Instance.new("Weld")
			local child = folder:WaitForChild(v[part.Name] or part.Name)
			part.Parent = child
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = child
			part.Anchored = false
			child.Transparency = 1
		end

		task.spawn(handleNameTag, folder)
		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}