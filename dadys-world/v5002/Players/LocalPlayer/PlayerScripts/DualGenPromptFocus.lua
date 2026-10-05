local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GeneratorUIController = require(ReplicatedStorage.Modules.ClientUI.GeneratorUIController)
local localPlayer = Players.LocalPlayer
local object = setmetatable({}, {
	__mode = "k"
})
local v = table.create(8)

local function buildSlotCache(model)
	local result = {}

	for i = 1, 8 do
		local child = model:FindFirstChild(i == 1 and "Prompt" or "Prompt" .. i)

		if not child then
			break
		end

		local attachment = child:FindFirstChild("Attachment")
		local proximityPrompt = attachment and attachment:FindFirstChildOfClass("ProximityPrompt")

		if proximityPrompt then
			result[#result + 1] = {
				promptPart = child,
				prompt = proximityPrompt,
				origDist = proximityPrompt.MaxActivationDistance
			}
		end
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerGen(model)
	if model:IsA("Model") then
		object[model] = buildSlotCache(model)
	end
end

local function unregisterGen(p)
	local v2 = object[p]

	if v2 then
		for _, v3 in ipairs(v2) do
			if v3.prompt.Parent and v3.prompt.MaxActivationDistance ~= v3.origDist then
				v3.prompt.MaxActivationDistance = v3.origDist
			end
		end

		object[p] = nil
	end
end

for _, v2 in ipairs(CollectionService:GetTagged("GenFXManaged")) do
	registerGen(v2) -- equivalent call inferred; original call site unknown
end

CollectionService:GetInstanceAddedSignal("GenFXManaged"):Connect(registerGen)
CollectionService:GetInstanceRemovedSignal("GenFXManaged"):Connect(unregisterGen)

local function applyFocus(list, position, p)
	if #list < 2 then
		return
	end

	if p then
		for _, v2 in ipairs(list) do
			if v2.prompt.MaxActivationDistance ~= 0 then
				v2.prompt.MaxActivationDistance = 0
			end
		end
	else
		table.clear(v)

		for _, v2 in ipairs(list) do
			if not v2.prompt.Enabled then
				continue
			end

			local position2 = v2.promptPart.Position
			local v3 = position2.X - position.X
			local v4 = position2.Y - position.Y
			local v5 = position2.Z - position.Z
			v2.dist = math.sqrt(v3 * v3 + v4 * v4 + v5 * v5)
			v[#v + 1] = v2
		end

		local count = #v

		if count < 2 then
			if count == 1 then
				local v2 = v[1]

				if v2.prompt.MaxActivationDistance ~= v2.origDist then
					v2.prompt.MaxActivationDistance = v2.origDist
				end
			end
		else
			local dist = v[1].dist

			for i = 2, count do
				local dist2 = v[i].dist

				if dist2 < dist then
					dist = dist2
				end
			end

			for i = 1, count do
				local v2 = v[i]
				local maxActivationDistance = v2.dist - dist > 1.5 and 0 or v2.origDist

				if v2.prompt.MaxActivationDistance ~= maxActivationDistance then
					v2.prompt.MaxActivationDistance = maxActivationDistance
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(function()
	if GeneratorUIController.ArePromptsMuted() then
		return
	end

	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return
	end

	local position = humanoidRootPart.Position
	local decoding = character:FindFirstChild("Decoding")
	local value = decoding and decoding.Value

	for k, v2 in pairs(object) do
		if k.Parent then
			applyFocus(v2, position, k == value)
		else
			object[k] = nil
		end
	end
end)