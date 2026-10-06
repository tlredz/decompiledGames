local HighlightModule = {}
local characterWorkshop = workspace:FindFirstChild("CharacterWorkshop") or workspace.Effects
local currentCamera = workspace.CurrentCamera
local v = {}
local v2 = {}
local v3 = {
	RightLowerArm = true,
	RightHand = true,
	LeftLowerArm = true,
	LeftHand = true
}

function HighlightModule.Get(_, p)
	return v[p]
end

function HighlightModule.AddArc(_, p)
	v2[p] = true
end

function HighlightModule.GetArcColor(_)
	local v4 = tick() / 10 % 1
	return Color3.fromHSV(v4, 1, 1)
end

function HighlightModule.Add(_, instance, p, p2)
	if not v[instance] then
		v[instance] = {}
		local v4 = p or v3
		local model = Instance.new("Model")
		model.Name = instance.Name .. "'s Outline"
		model:SetAttribute("NoAutoDelete", true)
		model.Parent = characterWorkshop or workspace
		local color = Color3.fromRGB(255, 0, 0)

		if p2.ColorName.Value ~= "Arc" then
			color = _G.ArmamentColorUpdateClient(p2.Color.Value)
		end

		for _, part in pairs(instance:GetChildren()) do
			if not (part:IsA("BasePart") and v4[part.Name]) then
				continue
			end

			local clone = part:Clone()
			clone:ClearAllChildren()
			clone.Name = part.Name .. "Outline"
			clone.Size = part.Size * 1.175
			clone.Color = color
			clone.Material = Enum.Material.Neon
			clone.Massless = true
			clone.Anchored = true
			clone.CanCollide = false

			if clone:IsA("MeshPart") then
				clone.TextureID = ""
			end

			clone:SetAttribute("ColorName", p2.ColorName.Value)
			clone.Parent = model
			table.insert(v[instance], clone)
		end
	end
end

function HighlightModule:Remove(p)
	if v[p] then
		local child = characterWorkshop:FindFirstChild(p.Name .. "'s Outline")

		if child then
			child:Destroy()
		end

		v[p] = nil
	end
end

function HighlightModule.Reset(_)
	for k, _ in pairs(v) do
		local child = characterWorkshop:FindFirstChild(k.Name .. "'s Outline")

		if child then
			child:Destroy()
		end
	end

	v = {}
end

function HighlightModule.Update(_)
	debug.profilebegin("Render Outline")
	local count = 0
	local v4 = {}
	local v5 = {}

	for k, v6 in pairs(v) do
		if k.Parent then
			for _, v7 in pairs(v6) do
				local part = k:FindFirstChild(v7.Name:gsub("Outline", ""))

				if not (part and part.Parent and part:IsA("BasePart")) then
					continue
				end

				local v8 = part.Position - currentCamera.CFrame.Position
				local unit = v8.Unit
				local v9 = 1 - math.clamp((10 - v8.Magnitude) / 10, 0, 1)
				v7.Size = part.Size * 1.175
				v7.Transparency = part.Transparency < 1 and 0 or 1
				count += 1
				v4[count] = part.CFrame + unit * v9
				v5[count] = v7

				if v7:GetAttribute("ColorName") ~= "Arc" then
					continue
				end

				local v10 = tick() / 10 % 1
				v7.Color = Color3.fromHSV(v10, 1, 1)
				local child = characterWorkshop:FindFirstChild(k.Name .. "Real Sword")

				if child and child:FindFirstChild("HighlightArmament") then
					child.HighlightArmament.OutlineColor = Color3.fromHSV(v10, 1, 1)
				end
			end
		else
			HighlightModule:Remove(k)
		end
	end

	workspace:BulkMoveTo(v5, v4, Enum.BulkMoveMode.FireCFrameChanged)

	for k, _ in pairs(v2) do
		if k.Parent then
			local v6 = tick() / 10 % 1
			k.Color = Color3.fromHSV(v6, 1, 1)
		else
			v2[k] = nil
		end
	end

	debug.profileend()
end

return HighlightModule