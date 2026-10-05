local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local v = {}
local v2 = {}

local function waitForDescendant(model, childName: string)
	local child = model:FindFirstChild(childName, true)

	while not child and model.Parent do
		task.wait(0.1)
		child = model:FindFirstChild(childName, true)
	end

	return child
end

local function buildPartCache(state)
	local result = {}

	for _, part in state.keycaps:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(result, {
				part = part,
				transparency = part.Transparency,
				canCollide = part.CanCollide
			})
		end
	end

	table.insert(result, {
		part = state.trigger,
		transparency = state.trigger.Transparency,
		canCollide = state.trigger.CanCollide
	})
	return result
end

local function isLocalCharacterPart(instance)
	local character = localPlayer.Character
	return character ~= nil and instance:IsDescendantOf(character)
end

local function characterStillTouchingBridge(state)
	local character = localPlayer.Character

	if not (character and state.trigger.Parent) then
		return false
	end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { character }
	return #workspace:GetPartsInPart(state.trigger, overlapParams) > 0
end

local function restoreBridge(p)
	for _, currentPart in p.currentParts do
		if not currentPart.part.Parent then
			continue
		end

		currentPart.part.Transparency = currentPart.transparency
		currentPart.part.CanCollide = currentPart.canCollide
	end
end

local function runCycle(state)
	if state.cycleRunning or state.waitingForExit then
		return
	end

	state.cycleRunning = true
	state.currentParts = buildPartCache(state)
	local tweens = {}

	for _, currentPart in state.currentParts do
		if not currentPart.part.Parent then
			continue
		end

		local tween = TweenService:Create(currentPart.part, TweenInfo.new(5, Enum.EasingStyle.Linear), {
			Transparency = 1
		})
		table.insert(tweens, tween)
		tween:Play()
	end

	if tweens[1] then
		tweens[1].Completed:Wait()
	else
		task.wait(5)
	end

	for _, currentPart in state.currentParts do
		if currentPart.part.Parent then
			currentPart.part.CanCollide = false
		end
	end

	task.wait(2)
	restoreBridge(state)
	state.cycleRunning = false
	state.waitingForExit = true

	while state.model.Parent and characterStillTouchingBridge(state) do
		task.wait(0.1)
	end

	state.waitingForExit = false
end

local function setupBridge(model)
	if not model:IsA("Model") or v[model] or v2[model] then
		return
	end

	v2[model] = true
	local model2 = waitForDescendant(model, "Keycaps")
	local part = waitForDescendant(model, "DollarBridge")

	if model2 and model2:IsA("Model") then
		if part and part:IsA("BasePart") then
			local v3 = {
				model = model,
				keycaps = model2,
				currentParts = {},
				trigger = part,
				cycleRunning = false,
				waitingForExit = false,
				touchConnection = nil
			}
			v3.touchConnection = part.Touched:Connect(function(otherPart)
				local character = localPlayer.Character
				local v4

				if character == nil then
					v4 = false
				else
					v4 = otherPart:IsDescendantOf(character)
				end

				if v4 then
					task.spawn(runCycle, v3)
				end
			end)
			v[model] = v3
			v2[model] = nil
		else
			v2[model] = nil
			warn("[Stage4Bridge] BasePart 'DollarBridge' introuvable dans", model:GetFullName())
		end
	else
		v2[model] = nil
		warn("[Stage4Bridge] Model 'Keycaps' introuvable dans", model:GetFullName())
	end
end

local function removeBridge(model)
	if not model:IsA("Model") then
		return
	end

	local v3 = v[model]

	if not v3 then
		return
	end

	if v3.touchConnection then
		v3.touchConnection:Disconnect()
	end

	v[model] = nil
	v2[model] = nil
end

local tagged = CollectionService:GetTagged("World4Stage4Bridge")

for _, v3 in tagged do
	task.spawn(setupBridge, v3)
end

CollectionService:GetInstanceAddedSignal("World4Stage4Bridge"):Connect(function(p)
	task.spawn(setupBridge, p)
end)
CollectionService:GetInstanceRemovedSignal("World4Stage4Bridge"):Connect(removeBridge)
localPlayer.CharacterAdded:Connect(function()
	for _, v3 in v do
		if v3.cycleRunning then
			continue
		end

		v3.waitingForExit = false
		restoreBridge(v3)
	end
end)