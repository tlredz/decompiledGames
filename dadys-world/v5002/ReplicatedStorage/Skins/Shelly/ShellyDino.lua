local ShellyDino = {}
ShellyDino.Name = "Dino Snore"
ShellyDino.Cost = 600
ShellyDino.DandyStore = true

function ShellyDino.ApplySkin(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if part:IsA("MeshPart") then
			part.TextureID = "rbxassetid://100694837221367"
		end
	end

	local config = folder:WaitForChild("Config")
	local hurtTexture = config:WaitForChild("HurtTexture")
	hurtTexture.Texture = "rbxassetid://129696024562724"
	local normalTexture = config:WaitForChild("NormalTexture")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	normalTexture.Texture = "rbxassetid://100694837221367"
	blinkTexture.Texture = "rbxassetid://111716001445477"
	local clone = game.ServerStorage.SkinModelStorage[folder.Config.ModuleName.Value][script.Name][script.Name]:Clone()

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		if part.Name == "Hat" then
			local weld = Instance.new("Weld")
			part.Parent = folder:WaitForChild("Head")
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = folder:WaitForChild("Head")
			part.Anchored = false
		else
			local weld = Instance.new("Weld")
			part.Parent = folder:WaitForChild(part.Name)
			weld.Parent = part
			weld.Part0 = part
			weld.Part1 = folder:WaitForChild(part.Name)
			part.Anchored = false
			local waitForChild = folder:WaitForChild(part.Name)
			waitForChild.Transparency = 1
		end
	end

	folder.RootPart.root:Destroy()
	clone.RootPart.root.Parent = folder.RootPart
	folder.Animate.Enabled = false
	folder.Animate.Enabled = true
	local children = clone.Animations:GetChildren()

	for _, v in pairs(children) do
		folder.Animations[tostring(v)].AnimationId = v.AnimationId
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function ShellyDino.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return ShellyDino