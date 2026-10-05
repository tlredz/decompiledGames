local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local parent = script.Parent
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local UseBall2 = require(ReplicatedStorage.Shared.UseBall2)
local counts = parent.Parent:FindFirstChild("counts")
RunService.PreRender:Connect(function()
	local flag = UseBall2()

	if flag then
		counts.Visible = false
	end

	if not flag then
		parent.Visible = false
		return
	end

	local flag2 = false
	local usesRemaining = 0
	local character = localPlayer.Character

	if character then
		local characterAbility = Abilities.getCharacterAbility(character)

		if characterAbility then
			local abilityInfoUnsafe = Abilities.getAbilityInfoUnsafe(characterAbility)
			flag2 = abilityInfoUnsafe.uses and abilityInfoUnsafe.uses > 1 and true or false
		end

		if flag2 then
			usesRemaining = Abilities.getCooldown(character).usesRemaining
		end
	end

	parent.Visible = flag2

	if flag2 then
		parent.Text = tostring(usesRemaining)
	end
end)