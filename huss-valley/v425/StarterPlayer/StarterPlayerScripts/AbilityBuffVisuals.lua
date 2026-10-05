local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v = {}

local function restore(p)
	for k, v2 in p.hidden do
		if not k.Parent then
			continue
		end

		for k2, v3 in v2 do
			k[k2] = v3
		end
	end

	table.clear(p.hidden)
end

local function hide(p, folder, p2)
	for _, descendant in folder:GetDescendants() do
		local v2 = p.hidden[descendant]

		if not v2 then
			if descendant:IsA("BasePart") then
				v2 = {
					LocalTransparencyModifier = descendant.LocalTransparencyModifier
				}
			elseif descendant:IsA("Decal") then
				v2 = {
					Transparency = descendant.Transparency
				}
			elseif descendant:IsA("Humanoid") then
				v2 = {
					DisplayDistanceType = descendant.DisplayDistanceType
				}
			else
				v2 = (descendant:IsA("BillboardGui") or descendant:IsA("Highlight") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Light")) and {
					Enabled = descendant.Enabled
				} or v2
			end

			p.hidden[descendant] = v2
		end

		if not v2 then
			continue
		end

		for k, v3 in v2 do
			if k == "Enabled" then
				descendant.Enabled = false
			elseif k == "DisplayDistanceType" then
				descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			else
				descendant[k] = v3 + (1 - v3) * p2
			end
		end
	end
end

local function resetBlade(state)
	if state.blade and state.blade.Parent then
		state.blade.Size = state.size
	end

	if state.weld and state.weld.Parent then
		local weld = state.weld
		local weld2 = state.weld
		local c0 = state.c0
		local c1 = state.c1
		weld.C0 = c0
		weld2.C1 = c1
	end

	if state.glow then
		state.glow:Destroy()
	end

	if state.light then
		state.light:Destroy()
	end

	state.blade = nil
	state.weld = nil
	state.glow = nil
	state.light = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watch(character)
	v[character] = {
		hidden = {}
	}
end

local function playerAdded(player)
	player.CharacterAdded:Connect(watch)

	if player.Character then
		watch(player.Character) -- equivalent call inferred; original call site unknown
	end
end

Players.PlayerAdded:Connect(playerAdded)

for _, v2 in Players:GetPlayers() do
	v2.CharacterAdded:Connect(watch)

	if not v2.Character then
		continue
	end

	watch(v2.Character) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaled(p, p2)
	return CFrame.new(p.Position * p2) * p.Rotation
end

RunService:BindToRenderStep("AbilityBuffVisuals", Enum.RenderPriority.Last.Value, function()
	for k, v2 in v do
		if k.Parent then
			if k:GetAttribute("Ghosted") == true then
				hide(v2, k, 0.8)
			elseif k:GetAttribute("Cloaked") == true then
				hide(v2, k, k == Players.LocalPlayer.Character and 0.8 or 1)
			elseif next(v2.hidden) then
				restore(v2)
			end

			local bigDaggerActive = k:GetAttribute("BigDaggerActive") == true
			local equippedDagger = k:FindFirstChild("EquippedDagger")
			local blade = equippedDagger and equippedDagger:FindFirstChild("Blade")

			if v2.blade and v2.blade ~= blade then
				resetBlade(v2)
			end

			if bigDaggerActive and blade and not v2.blade then
				local handle = equippedDagger:FindFirstChild("Handle")
				local bladeWeld = handle and handle:FindFirstChild("BladeWeld")

				if bladeWeld then
					local size = blade.Size
					local C0 = bladeWeld.C0
					local C1 = bladeWeld.C1
					v2.blade = blade
					v2.size = size
					v2.weld = bladeWeld
					v2.c0 = C0
					v2.c1 = C1
					local highlight = Instance.new("Highlight")
					highlight.Name = "BigDaggerGlow"
					highlight.Adornee = blade
					highlight.DepthMode = Enum.HighlightDepthMode.Occluded
					highlight.FillColor = Color3.fromRGB(255, 207, 64)
					highlight.OutlineColor = Color3.fromRGB(255, 235, 120)
					highlight.FillTransparency = 0.55
					highlight.OutlineTransparency = 0.08
					highlight.Parent = blade
					v2.glow = highlight
					local pointLight = Instance.new("PointLight")
					pointLight.Name = "BigDaggerLight"
					pointLight.Color = Color3.fromRGB(255, 216, 86)
					pointLight.Brightness = 1.1
					pointLight.Range = 7
					pointLight.Shadows = false
					pointLight.Parent = blade
					v2.light = pointLight
				end
			end

			if v2.blade then
				if bigDaggerActive then
					v2.blade.Size = v2.size * 2
					local weld = v2.weld
					local weld2 = v2.weld
					local C0 = scaled(v2.c0, 2) -- equivalent call inferred; original call site unknown
					local C1 = scaled(v2.c1, 2) -- equivalent call inferred; original call site unknown
					weld.C0 = C0
					weld2.C1 = C1
				else
					resetBlade(v2)
				end
			end
		else
			restore(v2)
			resetBlade(v2)
			v[k] = nil
		end
	end
end)
script.Destroying:Connect(function()
	RunService:UnbindFromRenderStep("AbilityBuffVisuals")

	for _, v2 in v do
		restore(v2)
		resetBlade(v2)
	end
end)