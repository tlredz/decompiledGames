local function Hide(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 1
			descendant.CanCollide = false
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end
end

local function Unhide(folder)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Transparency = 0
			descendant.CanCollide = true
			descendant.CanTouch = false
			descendant.CanQuery = false
		elseif descendant:IsA("Texture") then
			descendant.Transparency = 1
		end
	end
end

local model = nil

local function Pillars(p)
	local WAIT_INTERVAL = 0.016666666666666666
	task.wait(1)
	local pillars = p.Pillars
	local enemies = p.Enemies

	if model then
		model:Destroy()
		model = nil
	end

	if enemies then
		model = Instance.new("Model", workspace)
		local model2 = Instance.new("Model", model)
		local highlight = Instance.new("Highlight", model2)
		highlight.FillColor = Color3.fromRGB(115, 0, 255)
		highlight.FillTransparency = 1
		highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
		highlight.OutlineTransparency = 1
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		local descendants = {}
		local descendants2 = {}
		local clones = {}

		for _, pillar in pairs(pillars) do
			local clone = pillar:Clone()
			clone.Parent = model2
			clone:SetAttribute("OriginalPivot", clone:GetPivot())
			Unhide(clone)
			Hide(pillar)

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant.Name == "Rune" then
					table.insert(descendants2, descendant)
				elseif descendant.Name == "Texture" then
					table.insert(descendants, descendant)
				end
			end

			for _, child in pairs(clone:GetChildren()) do
				local part2 = nil

				for _, part in pairs(child:GetChildren()) do
					if not part:IsA("BasePart") then
						continue
					end

					if part2 then
						local weld = Instance.new("Weld", part2)
						weld.C0 = part2.CFrame:ToObjectSpace(part.CFrame)
						weld.Part0 = part2
						weld.Part1 = part
						part.Anchored = false
					else
						child.PrimaryPart = part
						part2 = part
					end
				end
			end

			table.insert(clones, clone)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getNudge(p2)
			return (math.random() - 0.5) * 2 * (1 - p2 ^ 2)
		end

		local v = 0

		while v < 2 do
			local v2 = v + task.wait(WAIT_INTERVAL)
			local v3 = v2 / 2
			local cframes = {}

			for k, v4 in pairs(clones) do
				cframes[k] = CFrame.new(getNudge(v3), getNudge(v3) / 8, getNudge(v3))
				v4:PivotTo(v4:GetAttribute("OriginalPivot") * cframes[k] * CFrame.new(0, v3 * 11.8, 0))
			end

			v = v2 + task.wait(WAIT_INTERVAL)
			local v4 = v / 2

			for k, v5 in pairs(clones) do
				v5:PivotTo(v5:GetAttribute("OriginalPivot") * cframes[k] * CFrame.new(0, v4 * 11.8, 0))
			end
		end

		task.wait(1)
		local total = 0

		while total < 0.5 do
			total += task.wait(WAIT_INTERVAL)
			local v2 = math.clamp((total / 0.5) ^ 2, 0, 1)
			highlight.FillTransparency = 1 - v2 * 0.2
			highlight.OutlineTransparency = 1 - v2
			local lerped = Color3.fromRGB(81, 73, 84):Lerp(Color3.fromRGB(168, 144, 240), v2)

			for _, v3 in pairs(descendants2) do
				v3.Color = lerped
			end

			for _, v3 in pairs(descendants) do
				v3.OffsetStudsU = v2 * 6000 / 2
				v3.StudsPerTileU = v2 * 6000
			end
		end

		for k, enemy in pairs(enemies) do
			local humanoid = enemy:FindFirstChild("Humanoid")

			if not humanoid then
				continue
			end

			local healthChangedConnection = nil
			local v2 = humanoid
			local v3 = k

			local function Died()
				if v2.Health > 0 then
					return
				end

				healthChangedConnection:Disconnect()
				local folder = clones[v3]
				folder.Parent = model

				for i, child in pairs(folder:GetChildren()) do
					if child.Name == "section1" then
						continue
					end

					child.PrimaryPart.Anchored = false
					child.PrimaryPart.Velocity = Vector3.new(
						(math.random() - 0.5) * 2,
						math.random() + 0.5,
						(math.random() - 0.5) * 2
					).Unit * 50
				end

				for i, descendant in pairs(folder:GetDescendants()) do
					if descendant.Name == "Texture" then
						descendant.OffsetStudsU = 0
						descendant.Transparency = 0.03
					elseif descendant.Name == "Rune" then
						descendant.Color = Color3.fromRGB(81, 73, 84)
					end
				end
			end

			healthChangedConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(Died)
			Died()
		end
	else
		for _, pillar in pairs(pillars) do
			Unhide(pillar)
		end
	end
end

return Pillars