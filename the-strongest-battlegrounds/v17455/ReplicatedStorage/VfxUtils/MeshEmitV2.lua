local TweenService = game:GetService("TweenService")

local function getTweenData(parent, duration: number, p: string, p2)
	local attribute = parent:GetAttribute(p .. "_TweenParams")
	local v = {
		{ "TweenStyle", p2 },
		{ "TweenDirection", Enum.EasingDirection.Out }
	}
	local v2 = {}

	if typeof(attribute) == "string" then
		local v3 = { attribute:match("(%a+),(%a+)") }

		for i = 1, 2 do
			local v4 = v3[i]
			local v5 = v[i]
			local v6 = v5[1]
			local v7 = v5[2]

			if v4 then
				local v8 = v6
				local v9 = v4

				if not pcall(function()
					v2[v8] = Enum[v8][v9]
				end) then
					v2[v6] = v7
				end
			else
				v2[v6] = v7
			end
		end
	else
		for _, v3 in v do
			v2[v3[1]] = v3[2]
		end
	end

	return TweenInfo.new(duration, v2.TweenStyle, v2.TweenDirection)
end

local function emitMeshOnce(instance)
	if not (instance and instance.Parent) then
		return
	end

	local firstChild = instance.Parent:FindFirstChild("End")

	if not firstChild then
		warn("Goal is not defined.")
		return
	end

	local rotationX = instance.Parent:GetAttribute("RotationX") or NumberRange.new(0, 0)
	local rotationY = instance.Parent:GetAttribute("RotationY") or NumberRange.new(0, 0)
	local rotationZ = instance.Parent:GetAttribute("RotationZ") or NumberRange.new(0, 0)
	local startTransparency = tonumber(instance.Parent:GetAttribute("StartTransparency")) or 0
	local duration = tonumber(instance.Parent:GetAttribute("Duration")) or 0.1
	local random = Random.new(math.random(1, 2000000))
	local cframe = CFrame.Angles(
		math.rad((random:NextNumber(rotationX.Min, rotationX.Max))),
		math.rad((random:NextNumber(rotationY.Min, rotationY.Max))),
		(math.rad((random:NextNumber(rotationZ.Min, rotationZ.Max))))
	)
	local clone = instance:Clone()
	clone.CFrame *= cframe

	if clone:IsA("MeshPart") then
		clone.Transparency = startTransparency
	elseif clone:IsA("BasePart") and clone:FindFirstChildOfClass("Decal") then
		clone.Transparency = 1
	end

	clone.Parent = workspace.CurrentCamera

	if clone:FindFirstChildOfClass("Decal") then
		TweenService:Create(clone, getTweenData(instance.Parent, duration, "Part", Enum.EasingStyle.Cubic), {
			Size = firstChild.Size,
			CFrame = firstChild.CFrame * cframe
		}):Play()
	else
		TweenService:Create(clone, getTweenData(instance.Parent, duration, "Part", Enum.EasingStyle.Cubic), {
			Size = firstChild.Size,
			CFrame = firstChild.CFrame * cframe,
			Transparency = 1
		}):Play()
	end

	local specialMesh = clone:FindFirstChildOfClass("SpecialMesh")
	local specialMesh2 = firstChild:FindFirstChildOfClass("SpecialMesh")

	if specialMesh and specialMesh2 then
		TweenService:Create(specialMesh, getTweenData(instance.Parent, duration, "Mesh", Enum.EasingStyle.Sine), {
			Scale = specialMesh2.Scale
		}):Play()
	end

	local decal = clone:FindFirstChildOfClass("Decal")
	local decal2 = firstChild:FindFirstChildOfClass("Decal")

	if decal and decal2 then
		decal.Transparency = startTransparency
		TweenService:Create(decal, getTweenData(instance.Parent, duration, "Decal", Enum.EasingStyle.Cubic), {
			Transparency = decal2.Transparency,
			Color3 = decal2.Color3
		}):Play()
	end

	task.delay(duration, clone.Destroy, clone)
end

return function(p)
	local enabledDuration = p.Parent:GetAttribute("EnabledDuration") or 0
	local meshRate = p.Parent:GetAttribute("MeshRate") or 0

	if enabledDuration > 0 and meshRate > 0 then
		local lastTime = tick()
		task.spawn(function()
			while tick() - lastTime <= enabledDuration do
				emitMeshOnce(p)
				task.wait(1 / meshRate)
			end
		end)
	else
		emitMeshOnce(p)
	end
end