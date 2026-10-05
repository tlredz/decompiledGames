local TweenService = game:GetService("TweenService")

local function getTweenData(clone, attributeName)
	if typeof(attributeName) ~= "string" then
		return
	end

	local duration = clone:GetAttribute("Duration")

	if typeof(duration) ~= "number" then
		return
	end

	local attribute = clone:GetAttribute(attributeName)

	if typeof(attribute) ~= "string" then
		return
	end

	local v = string.split(attribute, ",")

	if typeof(v[1]) == "string" and typeof(v[2]) == "string" then
		return TweenInfo.new(duration, Enum.EasingStyle[v[1]], Enum.EasingDirection[v[2]])
	end

	if typeof(v[1]) == "string" and typeof(v[2]) ~= "string" then
		return TweenInfo.new(duration, Enum.EasingStyle[v[1]], Enum.EasingDirection.In)
	end

	if typeof(v[1]) ~= "string" and typeof(v[2]) == "string" then
		return TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection[v[2]])
	end

	if typeof(v[1]) == "string" or typeof(v[2]) == "string" then
		return
	else
		return TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	end
end

local tweenInfo = TweenInfo.new(0)
return function(instance)
	if not instance:FindFirstChild("End") then
		warn("Goal is not defined.")
		return
	end

	local clone = instance:Clone()
	game.Debris:AddItem(clone, 10)
	local startTransparency = tonumber(clone:GetAttribute("StartTransparency")) or 0

	if typeof(startTransparency) == "number" then
		if clone.Start:IsA("MeshPart") then
			TweenService:Create(clone.Start, tweenInfo, {
				Transparency = startTransparency
			}):Play()
			clone.Start.Transparency = startTransparency
		elseif clone.Start:IsA("BasePart") and clone.Start:FindFirstChild("Decal") then
			TweenService:Create(clone.Start.Decal, tweenInfo, {
				Transparency = startTransparency
			}):Play()
			clone.Start.Decal.Transparency = startTransparency
		end
	end

	clone.Parent = workspace.CurrentCamera
	local duration = tonumber(clone:GetAttribute("Duration")) or 0.1
	local v = {}
	local tweenData = getTweenData(clone, "Part_TweenParams")

	if typeof(tweenData) == "TweenInfo" then
		table.insert(v, (TweenService:Create(clone.Start, tweenData, {
			CFrame = clone.End.CFrame,
			Transparency = 1,
			Size = clone.End.Size
		})))
	end

	if typeof((getTweenData(clone, "Mesh_TweenParams"))) == "TweenInfo" and clone.Start:FindFirstChild("Mesh") and clone.End:FindFirstChild("Mesh") then
		table.insert(v, (TweenService:Create(clone.Start.Mesh, tweenData, {
			Scale = clone.End.Mesh.Scale
		})))
	end

	if typeof((getTweenData(clone, "Decal_TweenParams"))) == "TweenInfo" and clone.Start:FindFirstChild("Decal") then
		table.insert(v, (TweenService:Create(clone.Start.Decal, tweenData, {
			Transparency = 1
		})))
	end

	for _, v2 in pairs(v) do
		v2:Play()
	end

	task.delay(duration, function()
		clone:Destroy()
	end)
end