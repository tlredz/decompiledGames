local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
character:WaitForChild("Humanoid")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

-- equivalent calls inferred from this helper; original call sites unknown
local function enableHumanoidRootPartCollisions()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		humanoidRootPart.CanCollide = true
	end
end

local function update()
	local massless = character:GetAttribute("PropMorphed") and true or false

	for _, v2 in CollectionService:GetTagged("PhysicsDoor") do
		local base = v2:FindFirstChild("Base")

		if not base then
			continue
		end

		base.Massless = massless
		local doorframe = v2:FindFirstChild("Doorframe")

		if not doorframe then
			continue
		end

		for _, child in doorframe:GetChildren() do
			if child.Name == "Part" then
				child.CanCollide = not massless
			end
		end
	end

	for _, v2 in CollectionService:GetTagged("Ceiling") do
		v2.CanCollide = not massless
	end

	if massless then
		local steppedConnection = nil
		steppedConnection = RunService.Stepped:Connect(function()
			if character.Parent and character:GetAttribute("PropMorphed") then
				enableHumanoidRootPartCollisions() -- equivalent call inferred; original call site unknown
			else
				steppedConnection:Disconnect()
				steppedConnection = nil
			end
		end)
	end
end

update()
character:GetAttributeChangedSignal("PropMorphed"):connect(update)
localPlayer.CharacterAdded:connect(function(object)
	object:GetAttributeChangedSignal("PropMorphed"):connect(update)
end)