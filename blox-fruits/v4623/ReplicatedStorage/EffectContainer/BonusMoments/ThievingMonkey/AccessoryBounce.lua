local RunService = game:GetService("RunService")

local function findVisualRoot(part)
	if part:IsA("BasePart") and part:GetAttribute("ThievingMonkeyAccessoryRoot") == true then
		return part
	end

	for _, part2 in part:GetDescendants() do
		if part2:IsA("BasePart") and part2:GetAttribute("ThievingMonkeyAccessoryRoot") == true then
			return part2
		end
	end

	return nil
end

local function configureVisualInstance(instance)
	if instance:IsA("BasePart") then
		local thievingMonkeyVisualTransparency = instance:GetAttribute("ThievingMonkeyVisualTransparency")

		if typeof(thievingMonkeyVisualTransparency) == "number" then
			instance.Transparency = thievingMonkeyVisualTransparency
		end

		instance.LocalTransparencyModifier = 0
		instance.Anchored = true
		instance.CanCollide = false
		instance.CanQuery = false
		instance.CanTouch = false
		instance.Massless = true
	elseif instance:IsA("Decal") then
		local thievingMonkeyVisualTransparency = instance:GetAttribute("ThievingMonkeyVisualTransparency")

		if typeof(thievingMonkeyVisualTransparency) == "number" then
			instance.Transparency = thievingMonkeyVisualTransparency
		end
	elseif instance:IsA("Texture") then
		local thievingMonkeyVisualTransparency = instance:GetAttribute("ThievingMonkeyVisualTransparency")

		if typeof(thievingMonkeyVisualTransparency) == "number" then
			instance.Transparency = thievingMonkeyVisualTransparency
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getLocalTransparency(instance)
	if instance:IsA("BasePart") or instance:IsA("Texture") or instance:IsA("Decal") then
		return instance.LocalTransparencyModifier
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setLocalTransparency(instance, localTransparencyModifier: number)
	if instance:IsA("BasePart") then
		instance.LocalTransparencyModifier = localTransparencyModifier
	elseif instance:IsA("Texture") then
		instance.LocalTransparencyModifier = localTransparencyModifier
	elseif instance:IsA("Decal") then
		instance.LocalTransparencyModifier = localTransparencyModifier
	end
end

return function(p)
	local source = p.Source
	local collider = p.Collider

	if not source or not collider or not collider:IsA("BasePart") or not source:IsDescendantOf(workspace) or not collider:IsDescendantOf(workspace) or collider:GetAttribute("ThievingMonkeyAccessoryAttached") == true then
		return
	end

	local clone = source:Clone()
	configureVisualInstance(clone)

	for _, descendant in clone:GetDescendants() do
		configureVisualInstance(descendant)
	end

	local visualRoot = findVisualRoot(clone)

	if not visualRoot then
		clone:Destroy()
		return
	end

	local cFrame = visualRoot.CFrame
	local v = {}

	if clone:IsA("BasePart") then
		v[clone] = cFrame:ToObjectSpace(clone.CFrame)
	end

	for _, part in clone:GetDescendants() do
		if part:IsA("BasePart") then
			v[part] = cFrame:ToObjectSpace(part.CFrame)
		end
	end

	local localTransparencies = {}
	local localTransparency = getLocalTransparency(source) -- equivalent call inferred; original call site unknown

	if localTransparency ~= nil then
		localTransparencies[source] = localTransparency

		if source:IsA("BasePart") then
			source.LocalTransparencyModifier = 1
		elseif source:IsA("Texture") then
			source.LocalTransparencyModifier = 1
		elseif source:IsA("Decal") then
			source.LocalTransparencyModifier = 1
		end
	end

	for _, descendant in source:GetDescendants() do
		local localTransparency2 = getLocalTransparency(descendant) -- equivalent call inferred; original call site unknown

		if localTransparency2 == nil then
			continue
		end

		localTransparencies[descendant] = localTransparency2

		if descendant:IsA("BasePart") then
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("Texture") then
			descendant.LocalTransparencyModifier = 1
		elseif descendant:IsA("Decal") then
			descendant.LocalTransparencyModifier = 1
		end
	end

	local cFrame2 = collider.CFrame

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pivotVisual(cframe: CFrame)
		for k, v2 in v do
			k.CFrame = cframe * v2
		end
	end

	pivotVisual(cFrame2) -- equivalent call inferred; original call site unknown
	clone.Name = "MonkeyAccessoryVisual"
	clone.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	local flag = false
	local preRenderConnection = nil
	local destroyingConnection = nil
	local destroyingConnection2 = nil
	local thievingMonkeyAccessoryAttachedChangedConnection = nil

	local function cleanup()
		if flag then
			return
		end

		flag = true

		if preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end

		if destroyingConnection then
			destroyingConnection:Disconnect()
			destroyingConnection = nil
		end

		if destroyingConnection2 then
			destroyingConnection2:Disconnect()
			destroyingConnection2 = nil
		end

		if thievingMonkeyAccessoryAttachedChangedConnection then
			thievingMonkeyAccessoryAttachedChangedConnection:Disconnect()
			thievingMonkeyAccessoryAttachedChangedConnection = nil
		end

		for k, v3 in localTransparencies do
			local v4 = k
			local localTransparencyModifier = v3
			pcall(function()
				setLocalTransparency(v4, localTransparencyModifier) -- equivalent call inferred; original call site unknown
			end)
		end

		clone:Destroy()
	end

	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		if not (source:IsDescendantOf(workspace) and collider:IsDescendantOf(workspace)) then
			cleanup()
			return
		end

		local v3 = 1 - math.exp(dt * -20)
		cFrame2 = cFrame2:Lerp(collider.CFrame, v3)
		pivotVisual(cFrame2) -- equivalent call inferred; original call site unknown
	end)
	destroyingConnection = source.Destroying:Connect(cleanup)
	destroyingConnection2 = collider.Destroying:Connect(cleanup)
	thievingMonkeyAccessoryAttachedChangedConnection = collider:GetAttributeChangedSignal("ThievingMonkeyAccessoryAttached"):Connect(function()
		if collider:GetAttribute("ThievingMonkeyAccessoryAttached") == true then
			cleanup()
		end
	end)

	if collider:GetAttribute("ThievingMonkeyAccessoryAttached") == true then
		cleanup()
	end
end