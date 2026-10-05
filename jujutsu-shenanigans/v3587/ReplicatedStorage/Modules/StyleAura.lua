local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local preload = ReplicatedStorage.Utils.Preload
local assets = script.Assets
local localMusic = script.LocalMusic
local styleAura = assets.StyleAura
local stance = assets.Stance
local smoke = assets.Smoke
local color = Color3.fromRGB(74, 116, 255)
local clone_2 = stance:Clone()
clone_2.Parent = preload
return function(p, parent, object, clones, instance, color2: Color3?)
	local v = color2 or color
	local humanoidRootPart = parent:FindFirstChild("HumanoidRootPart")
	local styleAura2 = parent:FindFirstChild("StyleAura")
	local torso = parent:FindFirstChild("Torso")

	if styleAura2 then
		local v2 = styleAura2:GetAttribute("Color") == v
		styleAura2:Destroy()

		if v2 then
			object:Stop()
			return false
		end
	end

	task.delay(0.35, function()
		if not (object.IsPlaying and (humanoidRootPart and humanoidRootPart.Parent)) then
			return
		end

		local clone = instance:Clone()
		clone.Name = "StyleMusic"
		clone.SoundGroup = SoundService.Music
		clone.Parent = humanoidRootPart

		if p and p.Parent then
			local clone2 = localMusic:Clone()
			clone2.Parent = parent
			clone2.Enabled = true
		end

		clone:Play()
		table.insert(clones, clone)
	end)
	local clone = stance:Clone()
	clone.SoundGroup = SoundService.Effect
	clone.Parent = humanoidRootPart
	clone:Play()
	table.insert(clones, clone)
	local clone2 = styleAura:Clone()
	clone2.Parent = parent
	clone2:SetAttribute("Color", v)
	local weld = Instance.new("Weld")
	weld.Part0 = clone2.PrimaryPart
	weld.Part1 = torso
	weld.Parent = clone2.PrimaryPart
	local color3 = Color3.new(v.R * 0.19999999999999996, v.G * 0.19999999999999996, v.B * 0.19999999999999996)
	local colorSequence = ColorSequence.new(v, color3)

	for _, emitter in clone2:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = colorSequence
		emitter.Enabled = true
	end

	for _, part in parent:GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local clone3 = smoke:Clone()
		clone3.Color = colorSequence
		clone3.Parent = part
		clone3:Emit(30)
		table.insert(clones, clone3)
	end

	return true
end