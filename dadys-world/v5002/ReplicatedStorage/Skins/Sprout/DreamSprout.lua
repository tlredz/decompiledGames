local DreamSprout = {
	Name = "Star Time Sprout",
	ApplySkin = function(folder)
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("MeshPart") and not part:HasTag("DontChangeTexture") then
				part.TextureID = "rbxassetid://116775966546494"
			elseif part:IsA("MeshPart") and part:HasTag("DontChangeTexture") then
				print("Skipping texture change for part with DontChangeTexture tag:", part.Name, part:GetFullName())
			end
		end

		local config = folder:WaitForChild("Config")
		local hurtTexture = config:WaitForChild("HurtTexture")
		hurtTexture.Texture = "rbxassetid://92472992132382"
		local normalTexture = config:WaitForChild("NormalTexture")
		local blinkTexture = config:WaitForChild("BlinkTexture")
		normalTexture.Texture = "rbxassetid://116775966546494"
		blinkTexture.Texture = "rbxassetid://76773609677199"
		local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()
		local v = {
			["Sprout_rig_v002:Head"] = "Sprout_rig_v002:Head_geo",
			["Sprout_rig_v002:Torso"] = "Sprout_rig_v002:Torso_geo",
			["Sprout_rig_v002:LeftArm"] = "Sprout_rig_v002:LeftArm",
			["Sprout_rig_v002:RightArm"] = "Sprout_rig_v002:RightArm",
			["Sprout_rig_v002:LeftLeg"] = "Sprout_rig_v002:LeftLeg",
			["Sprout_rig_v002:RightLeg"] = "Sprout_rig_v002:RightLeg",
			Head = "Sprout_rig_v002:Head_geo",
			Torso = "Sprout_rig_v002:Torso_geo",
			Torso_01 = "Sprout_rig_v002:Torso_geo",
			LeftArm = "Sprout_rig_v002:LeftArm",
			RightArm = "Sprout_rig_v002:RightArm",
			LeftLeg = "Sprout_rig_v002:LeftLeg",
			RightLeg = "Sprout_rig_v002:RightLeg",
			Cape = "Sprout_rig_v002:Torso_geo",
			Cape2 = "Sprout_rig_v002:Torso_geo",
			BackAccessory = "Sprout_rig_v002:Torso_geo",
			StarAccessory = "Sprout_rig_v002:Head_geo",
			Charm_Savory = "Sprout_rig_v002:Charm_Savory"
		}

		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("MeshPart") or part:HasTag("DontChangeTexture") then
				continue
			end

			if not (part.Name:find("Sprout_rig_v002:") or part.Name == "Head" or part.Name == "Torso" or part.Name:find("Arm") or part.Name:find("Leg")) then
				continue
			end

			part.Transparency = 1
		end

		for _, part in pairs(clone:GetChildren()) do
			if not part:IsA("MeshPart") then
				continue
			end

			local v2 = v[part.Name] or part.Name
			local child = folder:FindFirstChild(v2)

			if not child and part.Name:find("Sprout_rig_v002:") then
				child = folder:FindFirstChild("Sprout_rig_v002:" .. part.Name:gsub("Sprout_rig_v002:", ""))
			end

			local v3 = child or folder:FindFirstChild(v2, true)

			if v3 then
				if not v3:HasTag("DontChangeTexture") then
					local weld = Instance.new("Weld")
					part.Parent = v3
					weld.Parent = part
					weld.Part0 = part
					weld.Part1 = v3
					part.Anchored = false
				end
			else
				warn("Target part not found for: " .. part.Name .. ", skipping...")
			end
		end

		local animations = folder:FindFirstChild("Animations")

		if animations then
			if animations:FindFirstChild("Idle") and script:FindFirstChild("Idle") then
				animations.Idle.AnimationId = script.Idle.AnimationId
			end

			if animations:FindFirstChild("Walk") and script:FindFirstChild("Walk") then
				animations.Walk.AnimationId = script.Walk.AnimationId
			end

			if animations:FindFirstChild("Run") and script:FindFirstChild("Walk") then
				animations.Run.AnimationId = script.Walk.AnimationId
			end
		end

		local animate = folder:FindFirstChild("Animate")

		if animate then
			animate:IsA("LocalScript")
		end

		local animations2 = clone:FindFirstChild("Animations")

		if animations2 then
			local animations3 = folder:FindFirstChild("Animations")

			if animations3 then
				for _, animation in pairs(animations2:GetChildren()) do
					if not animation:IsA("Animation") then
						continue
					end

					local animation2 = animations3:FindFirstChild(animation.Name)

					if animation2 and animation2:IsA("Animation") then
						animation2.AnimationId = animation.AnimationId
					end
				end
			end
		end

		folder.RootPart:FindFirstChild("Sprout_rig_v002:root"):Destroy()
		local sprout_rig_v002root = clone.RootPart:FindFirstChild("Sprout_rig_v002:root")
		sprout_rig_v002root.Parent = folder.RootPart
		local animate2 = folder:FindFirstChild("Animate")

		if animate2 then
			animate2.Enabled = false
			task.wait(0.1)
			animate2.Enabled = true
		end

		local Debris = game:GetService("Debris")
		Debris:AddItem(clone, 10)
	end
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")

function DreamSprout.UseAbility(_, _, p, p2)
	local Movement = require(ReplicatedStorage.Parts.RenderModules.SproutCupcake.Movement)
	local clone = ReplicatedStorage.Parts.RenderModules.SproutCupcake.Cupcake:Clone()
	Debris:AddItem(clone, 2)
	clone.Parent = workspace
	clone.Position = p.Position

	if clone:IsA("BasePart") then
		clone.Color = Color3.fromRGB(102, 51, 153)
	end

	if clone:FindFirstChild("Trail") then
		clone.Trail.Enabled = true
		clone.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(51, 51, 153)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(153, 102, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 153, 255))
		})
	end

	if clone:FindFirstChild("SmokePart") then
		clone.SmokePart.Enabled = true
		clone.SmokePart.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(102, 102, 204)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(204, 204, 255))
		})
	end

	local _ = p2.Position

	local function chase()
		local position = clone.Position
		Movement.parabola(clone, position, p2, 20, 25, 0.5)
	end

	local position = clone.Position
	Movement.parabola(clone, position, p2, 20, 25, 0.5)

	if clone then
		clone.SmokePart.Enabled = false
		clone.Transparency = 1
		clone.HeartPart:Emit(10)

		if clone:FindFirstChild("Eat") then
			clone.Eat:Play()
		end
	end
end

return DreamSprout