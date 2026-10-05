if not game.Lighting:WaitForChild("Atmosphere", 2) then
	return
end

local PropertyMap = require(script.PropertyMap)
local lightingLayers = game.Lighting.LightingLayers

for _, child in pairs(game.Lighting:GetChildren()) do
	if not PropertyMap[child.ClassName] then
		continue
	end

	local clone = child:Clone()
	clone.Parent = lightingLayers
	clone:SetAttribute("Intensity", 1)
	clone:SetAttribute("ZIndex", -999999)
	local v = child
	local success, _ = pcall(function()
		v.Enabled = false
	end)

	if not success then
		child.Name = "Base" .. child.ClassName
	end
end

for className, v in pairs(PropertyMap) do
	local terrain

	if className == "Clouds" then
		terrain = workspace.Terrain
	else
		terrain = game.Lighting
	end

	local v2 = terrain:FindFirstChild("Base" .. className) or Instance.new(className, terrain)
	v2.Name = "Base" .. className
	local v3 = v
	local attributes = v2
	v2.Changed:Connect(function(p)
		if v3[p] then
			attributes[p] = attributes:GetAttribute("True" .. p)
		end
	end)
end

function UpdateClass(p)
	local v = game.Lighting:FindFirstChild("Base" .. p) or workspace.Terrain:FindFirstChild("Base" .. p)

	if v == nil then
		return
	end

	local v2 = {}

	for _, descendant in pairs(lightingLayers:GetDescendants()) do
		if descendant.ClassName ~= p then
			continue
		end

		if descendant:GetAttribute("Enabled") == nil then
			local v3 = descendant
			local success, result = pcall(function()
				return v3.Enabled
			end)

			if success and not result then
				continue
			end
		elseif descendant:GetAttribute("Enabled") == false then
			continue
		end

		local v3 = not descendant:GetAttribute("Ignore") and {} or descendant:GetAttribute("Ignore"):split(",")
		local v4 = {}

		for k in pairs(PropertyMap[p]) do
			if not table.find(v3, k) then
				v4[k] = descendant[k]
			end
		end

		v4.ZIndex = descendant:GetAttribute("ZIndex") or 1
		local intensity

		if descendant:FindFirstChild("Intensity") then
			intensity = descendant.Intensity.Value
		else
			intensity = descendant:GetAttribute("Intensity") or 1
		end

		v4.Intensity = intensity
		v4.Intensity = math.clamp(v4.Intensity, 0, 1)
		table.insert(v2, v4)
	end

	table.sort(v2, function(a, b)
		return a.ZIndex < b.ZIndex
	end)
	local v3 = {}

	for k, v4 in pairs(PropertyMap[p]) do
		v3[k] = v4
	end

	for _, v4 in pairs(v2) do
		for k, v5 in pairs(v4) do
			if not (k ~= "ZIndex" and k ~= "Intensity") then
				continue
			end

			if typeof(v5) == "number" then
				v3[k] += (v5 - v3[k]) * v4.Intensity
			else
				v3[k] = v3[k]:lerp(v5, v4.Intensity)
			end
		end
	end

	for k, v4 in pairs(v3) do
		v:SetAttribute("True" .. k, v4)
		v[k] = v4
	end
end

function DoUpdate()
	for k in pairs(PropertyMap) do
		UpdateClass(k)
	end
end

game.Lighting.LightingLayers.DescendantAdded:Connect(function(descendant)
	if PropertyMap[descendant.ClassName] then
		if descendant:FindFirstChild("Intensity") then
			local intensity = descendant:FindFirstChild("Intensity")
			intensity.Changed:Connect(function()
				UpdateClass(intensity.Parent.ClassName)
			end)
		else
			descendant.ChildAdded:Connect(function(child)
				if child.Name == "Intensity" then
					local changedConnection = nil
					changedConnection = child.Changed:Connect(function()
						if not child.Parent then
							changedConnection:Disconnect()
						end

						UpdateClass(descendant.ClassName)
					end)
					UpdateClass(child.Parent.ClassName)
				end
			end)
			descendant.ChildRemoved:Connect(function(child)
				if child.Name == "Intensity" then
					UpdateClass(descendant.ClassName)
				end
			end)
		end

		descendant.Changed:Connect(function()
			UpdateClass(descendant.ClassName)
		end)
		descendant:GetAttributeChangedSignal("Enabled"):Connect(function()
			UpdateClass(descendant.ClassName)
		end)
		descendant:GetAttributeChangedSignal("Intensity"):Connect(function()
			UpdateClass(descendant.ClassName)
		end)
		UpdateClass(descendant.ClassName)
	end
end)

for _, descendant in pairs(game.Lighting.LightingLayers:GetDescendants()) do
	if not PropertyMap[descendant.ClassName] then
		continue
	end

	if descendant:FindFirstChild("Intensity") then
		local intensity = descendant:FindFirstChild("Intensity")
		local changedConnection = nil
		local parent = intensity.Parent
		changedConnection = intensity.Changed:Connect(function()
			if not intensity.Parent then
				changedConnection:Disconnect()
			end

			UpdateClass(parent.ClassName)
		end)
	else
		local v = descendant
		descendant.ChildAdded:Connect(function(child)
			if child.Name == "Intensity" then
				local changedConnection = nil
				changedConnection = child.Changed:Connect(function()
					if not child.Parent then
						changedConnection:Disconnect()
					end

					UpdateClass(v.ClassName)
				end)
				UpdateClass(child.Parent.ClassName)
			end
		end)
		local v2 = descendant
		descendant.ChildRemoved:Connect(function(child)
			if child.Name == "Intensity" then
				UpdateClass(v2.ClassName)
			end
		end)
	end

	local v = descendant
	descendant.Changed:Connect(function()
		UpdateClass(v.ClassName)
	end)
	local v2 = descendant
	descendant:GetAttributeChangedSignal("Enabled"):Connect(function()
		UpdateClass(v2.ClassName)
	end)
	local v3 = descendant
	descendant:GetAttributeChangedSignal("Intensity"):Connect(function()
		UpdateClass(v3.ClassName)
	end)
end

DoUpdate()