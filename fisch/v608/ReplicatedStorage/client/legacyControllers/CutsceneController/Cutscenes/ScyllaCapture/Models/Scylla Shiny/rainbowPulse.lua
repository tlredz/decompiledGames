local RunService = game:GetService("RunService")
local parent = script.Parent
local parts = {}

local function collectGlowParts()
	for _, part in ipairs(parent:GetDescendants()) do
		if not (part:IsA("MeshPart") and part.Name:lower():sub(1, 5) == "glow_") then
			continue
		end

		part.Material = Enum.Material.Neon
		table.insert(parts, part)
		local ancestryChangedConnection = nil
		local v = part
		ancestryChangedConnection = part.AncestryChanged:Connect(function()
			if not v:IsDescendantOf(workspace) then
				ancestryChangedConnection:Disconnect()
				local index = table.find(parts, v)

				if index then
					table.remove(parts, index)
				end
			end
		end)
	end
end

local function updateGlowParts()
	if #parts == 0 then
		return
	end

	local v = os.clock() * 0.1 % 1
	local color = Color3.fromHSV(v, 1, 1)

	for i = #parts, 1, -1 do
		local v2 = parts[i]

		if v2 and v2.Parent then
			v2.Color = color
		else
			table.remove(parts, i)
		end
	end
end

collectGlowParts()
local total = 0
RunService.PostSimulation:Connect(function(dt)
	total += dt

	if total >= 0.06060606060606061 then
		total = 0
		updateGlowParts()
	end
end)