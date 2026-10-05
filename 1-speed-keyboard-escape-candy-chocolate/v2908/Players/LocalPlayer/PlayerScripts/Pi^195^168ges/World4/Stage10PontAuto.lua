local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local _ = {
	FADEOUT_DURATION = 0.5,
	INVISIBLE_TIME = 1
}
local v = {}

local function registerTimer(label)
	if not label:IsA("TextLabel") then
		return
	end

	local parent = label.Parent

	while parent do
		if parent:IsA("Model") and CollectionService:HasTag(parent, "W4Stage10BridgeModel") then
			v[label] = parent
			break
		else
			parent = parent.Parent
		end
	end
end

local function unregisterTimer(p)
	v[p] = nil
end

local v2 = {}

for _, v3 in ipairs(CollectionService:GetTagged("Timer")) do
	registerTimer(v3)
end

CollectionService:GetInstanceAddedSignal("Timer"):Connect(registerTimer)
CollectionService:GetInstanceRemovedSignal("Timer"):Connect(unregisterTimer)

local function isInsideKeyboard(instance, p)
	local parent = instance.Parent

	while parent and parent ~= p do
		if CollectionService:HasTag(parent, "Keyboard") then
			return true
		else
			parent = parent.Parent
		end
	end

	return false
end

local function addVisualToCache(folder, p, descendant)
	if CollectionService:HasTag(descendant, "Timer") then
		return
	end

	if descendant:IsA("BasePart") then
		for _, part in p.Parts do
			if part.Instance == descendant then
				return
			end
		end

		table.insert(p.Parts, {
			Instance = descendant,
			Orig = descendant.Transparency,
			OrigCanCollide = descendant.CanCollide,
			ProtectCollision = isInsideKeyboard(descendant, folder)
		})
	elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
		for _, text in p.Texts do
			if text.Instance == descendant then
				return
			end
		end

		table.insert(p.Texts, {
			Instance = descendant,
			Orig = descendant.TextTransparency
		})
	end
end

local function getVisualCache(folder)
	local v3 = {
		Parts = {},
		Texts = {},
		CurrentAlpha = 0,
		CurrentCollision = nil,
		DescendantConnection = nil
	}

	for _, descendant in folder:GetDescendants() do
		addVisualToCache(folder, v3, descendant)
	end

	v3.DescendantConnection = folder.DescendantAdded:Connect(function(descendant)
		addVisualToCache(folder, v3, descendant)
		task.defer(function()
			if folder.Parent then
				for _, part in v3.Parts do
					if part.Instance ~= descendant then
						continue
					end

					part.Instance.Transparency = part.Orig + v3.CurrentAlpha * (1 - part.Orig)

					if v3.CurrentCollision == nil or part.ProtectCollision then
						continue
					end

					local instance = part.Instance
					local canCollide

					if v3.CurrentCollision then
						canCollide = part.OrigCanCollide
					else
						canCollide = false
					end

					instance.CanCollide = canCollide
				end

				for _, text in v3.Texts do
					if text.Instance == descendant then
						text.Instance.TextTransparency = text.Orig + v3.CurrentAlpha * (1 - text.Orig)
					end
				end
			end
		end)
	end)
	return v3
end

local function applyState(visualCache, currentAlpha: number, currentCollision: boolean?)
	visualCache.CurrentAlpha = currentAlpha
	visualCache.CurrentCollision = currentCollision

	for _, part in visualCache.Parts do
		if not part.Instance.Parent then
			continue
		end

		part.Instance.Transparency = part.Orig + currentAlpha * (1 - part.Orig)

		if currentCollision == nil or part.ProtectCollision then
			continue
		end

		local instance = part.Instance
		local canCollide

		if currentCollision then
			canCollide = part.OrigCanCollide
		else
			canCollide = false
		end

		instance.CanCollide = canCollide
	end

	for _, text in visualCache.Texts do
		if text.Instance.Parent then
			text.Instance.TextTransparency = text.Orig + currentAlpha * (1 - text.Orig)
		end
	end
end

local function startBridgeLoop(instance)
	if v2[instance] then
		return
	end

	local bridgeDie = instance:GetAttribute("BridgeDie")

	if typeof(bridgeDie) ~= "number" or bridgeDie <= 0 then
		warn("[Stage10PontAuto] Attribut BridgeDie invalide sur", instance:GetFullName())
		return
	end

	v2[instance] = true
	local visualCache = getVisualCache(instance)
	task.spawn(function()
		while instance.Parent and CollectionService:HasTag(instance, "W4Stage10BridgeModel") do
			instance:SetAttribute("ServerStartTime", workspace:GetServerTimeNow())
			task.wait(bridgeDie)

			for i = 1, 20 do
				applyState(visualCache, i / 20, nil)
				task.wait(0.025)
			end

			applyState(visualCache, 1, false)
			task.wait(1)
			applyState(visualCache, 0, true)
		end

		if visualCache.DescendantConnection then
			visualCache.DescendantConnection:Disconnect()
		end

		v2[instance] = nil
	end)
end

for _, model in CollectionService:GetTagged("W4Stage10BridgeModel") do
	if model:IsA("Model") then
		task.spawn(startBridgeLoop, model)
	end
end

CollectionService:GetInstanceAddedSignal("W4Stage10BridgeModel"):Connect(function(model)
	if model:IsA("Model") then
		task.spawn(startBridgeLoop, model)
	end
end)
CollectionService:GetInstanceRemovedSignal("W4Stage10BridgeModel"):Connect(function(model)
	if model:IsA("Model") then
		v2[model] = nil
	end
end)
RunService.RenderStepped:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	for k, v3 in v do
		local bridgeDie = v3:GetAttribute("BridgeDie")
		local serverStartTime = v3:GetAttribute("ServerStartTime")

		if not (bridgeDie and serverStartTime) then
			continue
		end

		local v4 = math.max(0, bridgeDie - (serverTimeNow - serverStartTime))

		if v4 > 0 then
			k.Text = string.format("%.2f", v4)
			k.TextColor3 = v4 < 1 and Color3.new(1, 0, 0) or Color3.new(1, 1, 1)
		else
			k.Text = "Wait..."
			k.TextColor3 = Color3.new(1, 0, 0)
		end
	end
end)