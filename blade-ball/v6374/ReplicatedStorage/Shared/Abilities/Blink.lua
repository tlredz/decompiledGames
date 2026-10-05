local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local v = require3(ReplicatedStorage2.Shared.PlaceGhost)
local Blink = {}
Blink.cooldown = 5.5
Blink.uses = 3
Blink.iconId = "rbxassetid://15059338710"

function Blink.canBeUsed(p)
	return p.moveDirection.Magnitude > 0
end

function Blink.validateArguments(p)
	assert(p, "Bad arguments")
	assert(typeof(p.originalRootCFrame) == "CFrame", "Bad originalRootCFrame")
	assert(typeof(p.originalPositions) == "table", "Bad originalPositions")
	local count = 0

	for _ in p.originalPositions do
		count += 1
	end

	assert(count == #p.originalPositions, "Bad array")

	for i = count, 1, -1 do
		local originalPosition = p.originalPositions[i]
		assert(typeof(originalPosition) == "table", "Bad originalPosition")

		if originalPosition.part == nil then
			table.remove(p.originalPositions, i)
		else
			local v2

			if typeof(originalPosition.part) == "Instance" then
				v2 = originalPosition.part:IsA("BasePart")
			else
				v2 = false
			end

			assert(v2, "Bad originalPosition.part")
		end

		assert(typeof(originalPosition.cframe) == "CFrame", "Bad originalPosition.cframe")
	end
end

function Blink.localOwnerActivation(data)
	local v2 = {
		originalRootCFrame = data.rootPart.CFrame,
		originalPositions = {}
	}

	for _, part in data.character:GetDescendants() do
		if part:IsA("BasePart") then
			table.insert(v2.originalPositions, {
				part = part,
				cframe = part.CFrame
			})
		end
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Runtime,
		workspace.Alive,
		workspace.Dead,
		workspace.Balls
	}
	local v3 = data.moveDirection.Unit * (16 + data.upgradeLevel * 5)
	local spherecast = workspace:Spherecast(data.rootPart.Position - v3.Unit * 1, 1, v3 + v3.Unit * 1, raycastParams)

	if spherecast then
		data.character:TranslateBy(data.moveDirection.Unit * spherecast.Distance)
		return v2
	end

	data.character:TranslateBy(v3)
	return v2
end

function Blink.anyClientActivationAsync(p, _, p2)
	local _ = p.upgradeLevel >= 2
	local clone

	if p.upgradeLevel >= 2 then
		clone = script.MaxBlink:Clone()
	else
		clone = script.Blink:Clone()
	end

	clone.CFrame = p2.originalRootCFrame
	clone.Parent = workspace.Runtime
	clone.sound1:Play()
	clone.sound2:Play()
	clone.Attachment.Specs2:Emit(10)
	clone.Attachment.ball:Emit(1)
	Debris:AddItem(clone, 4)
	local cframesByPart = {}

	for _, originalPosition in p2.originalPositions do
		cframesByPart[originalPosition.part] = originalPosition.cframe
	end

	local character = p.character
	local color

	if p.upgradeLevel >= 2 then
		color = Color3.fromRGB(255, 255, 142)
	else
		color = Color3.fromRGB(82, 122, 255)
	end

	v(character, {
		color = color,
		cframeMap = cframesByPart,
		riseSpeed = 5,
		lifetime = 1.5,
		animationDelay = 0.5
	})
end

return Blink