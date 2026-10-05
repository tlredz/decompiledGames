local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SlapSimulation = require(ReplicatedStorage.Shared.ServerAuthority.SlapSimulation)
local swingAttribute = SlapSimulation.SwingAttribute
local toolAttribute = SlapSimulation.ToolAttribute
local cooldownAttribute = SlapSimulation.CooldownAttribute
local slash = ReplicatedStorage.Sounds.Sfx.Slash
local v = {}
local v2 = {}

local function playSwing(instance)
	local tool = instance:FindFirstChildWhichIsA("Tool")

	if not tool then
		return
	end

	local slash2 = tool:FindFirstChild("Slash")

	if slash2 and slash2:IsA("Sound") then
		slash2:Play()
		return
	end

	local clone = slash:Clone()
	clone.Parent = tool:FindFirstChild("Handle") or instance:FindFirstChild("HumanoidRootPart")

	if not clone.Parent then
		clone:Destroy()
		return
	end

	clone:Play()
	clone.Ended:Once(function()
		clone:Destroy()
	end)
	task.delay(5, function()
		clone:Destroy()
	end)
end

local function watchLocalTool(tool)
	if tool:IsA("Tool") and not v[tool] then
		v[tool] = tool.Activated:Connect(function()
			local character = Players.LocalPlayer.Character

			if not character or tool.Parent ~= character or not tool:GetAttribute(toolAttribute) then
				return
			end

			local attribute = tool:GetAttribute(cooldownAttribute) or 0
			local now = os.clock()

			if now - (v2[tool] or -1e999) < attribute then
				return
			end

			v2[tool] = now
			playSwing(character)
		end)
		tool.Destroying:Once(function()
			local connection = v[tool]

			if connection then
				connection:Disconnect()
				v[tool] = nil
				v2[tool] = nil
			end
		end)
	end
end

local function watchCharacter(player, instance)
	if player == Players.LocalPlayer then
		for _, child in ipairs(instance:GetChildren()) do
			watchLocalTool(child)
		end

		instance.ChildAdded:Connect(watchLocalTool)
	else
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart", 10)

		if humanoidRootPart and humanoidRootPart:IsA("BasePart") then
			local attribute = humanoidRootPart:GetAttribute(swingAttribute) or 0
			humanoidRootPart:GetAttributeChangedSignal(swingAttribute):Connect(function()
				local attribute2 = humanoidRootPart:GetAttribute(swingAttribute) or 0

				if attribute2 <= attribute then
					attribute = attribute2
					return
				end

				attribute = attribute2
				playSwing(instance)
			end)
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function watchPlayer(player)
	local function onCharacterAdded(p)
		watchCharacter(player, p)
	end

	if player.Character then
		task.spawn(onCharacterAdded, player.Character)
	end

	player.CharacterAdded:Connect(onCharacterAdded)
end

return {
	Start = function(_)
		for _, v3 in Players:GetPlayers() do
			watchPlayer(v3) -- equivalent call inferred; original call site unknown
		end

		Players.PlayerAdded:Connect(watchPlayer)
	end
}