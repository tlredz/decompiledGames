local TweenService = game:GetService("TweenService")

local function getTweenData(instance, attributeName)
	if typeof(attributeName) ~= "string" then
		return
	end

	local duration = instance:GetAttribute("Duration")

	if typeof(duration) ~= "number" then
		return
	end

	local attribute = instance:GetAttribute(attributeName)

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

	local startTransparency = tonumber(instance:GetAttribute("StartTransparency")) or 0

	if typeof(startTransparency) == "number" then
		if instance.Start:IsA("MeshPart") then
			TweenService:Create(instance.Start, tweenInfo, {
				Transparency = startTransparency
			}):Play()
			instance.Start.Transparency = startTransparency
		elseif instance.Start:IsA("BasePart") and instance.Start:FindFirstChild("Decal") then
			TweenService:Create(instance.Start.Decal, tweenInfo, {
				Transparency = startTransparency
			}):Play()
			instance.Start.Decal.Transparency = startTransparency
		end
	end

	instance.Parent = workspace.CurrentCamera
	local duration = tonumber(instance:GetAttribute("Duration")) or 0.1
	local v = {}
	local tweenData = getTweenData(instance, "Part_TweenParams")

	if typeof(tweenData) == "TweenInfo" then
		table.insert(v, (TweenService:Create(instance.Start, tweenData, {
			CFrame = instance.End.CFrame,
			Transparency = 1,
			Size = instance.End.Size
		})))
	end

	if typeof((getTweenData(instance, "Mesh_TweenParams"))) == "TweenInfo" and instance.Start:FindFirstChild("Mesh") and instance.End:FindFirstChild("Mesh") then
		table.insert(v, (TweenService:Create(instance.Start.Mesh, tweenData, {
			Scale = instance.End.Mesh.Scale
		})))
	end

	if typeof((getTweenData(instance, "Decal_TweenParams"))) == "TweenInfo" and instance.Start:FindFirstChild("Decal") then
		table.insert(v, (TweenService:Create(instance.Start.Decal, tweenData, {
			Transparency = 1
		})))
	end

	for _, v2 in pairs(v) do
		v2:Play()
	end

	task.delay(duration, function()
		instance:Destroy()
	end)
end