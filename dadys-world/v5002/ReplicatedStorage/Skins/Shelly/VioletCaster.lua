local VioletCaster = {}
VioletCaster.Name = "Violet Caster"
VioletCaster.TowerName = "Shelly"
VioletCaster.Description = "No description yet"
VioletCaster.Mastery = false
VioletCaster.Cost = 600
VioletCaster.Halloween = true
VioletCaster.HolidaySkin = true

function VioletCaster.ApplySkin(instance)
	local clone = game.ServerStorage.SkinModelStorage[instance.Config.ModuleName.Value][script.Name][script.Name]:Clone()
	local config = instance:WaitForChild("Config")
	local blinkTexture = config:WaitForChild("BlinkTexture")
	local hurtTexture = config:WaitForChild("HurtTexture")
	local normalTexture = config:WaitForChild("NormalTexture")
	blinkTexture.Texture = "rbxassetid://122275771077633"
	hurtTexture.Texture = "rbxassetid://139286824938198"
	normalTexture.Texture = "rbxassetid://104349109931004"
	local v = {
		Hat = "Head"
	}

	for _, part in pairs(clone:GetChildren()) do
		if not part:IsA("MeshPart") then
			continue
		end

		local weld = Instance.new("Weld")
		local child = instance:WaitForChild(v[part.Name] or part.Name)
		part.Parent = child
		weld.Parent = part
		weld.Part0 = part
		weld.Part1 = child
		part.Anchored = false
		child.Transparency = 1
	end

	local Debris = game:GetService("Debris")
	Debris:AddItem(clone, 10)
end

function VioletCaster.UseAbility(instance)
	instance:WaitForChild("Head"):WaitForChild("Attachment"):WaitForChild("ParticleEmitter"):Emit(2)
end

return VioletCaster