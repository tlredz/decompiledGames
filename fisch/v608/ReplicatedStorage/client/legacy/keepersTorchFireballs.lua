local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local fireball = ReplicatedStorage.client.modules.Fireball.Fireball
local SebasUtil = require(ReplicatedStorage.client.modules.SebasUtil)
local v = {
	red = Color3.fromRGB(255, 0, 0),
	orange = Color3.fromRGB(255, 124, 58),
	yellow = Color3.fromRGB(255, 179, 0),
	green = Color3.fromRGB(13, 255, 0),
	blue = Color3.fromRGB(33, 103, 255),
	purple = Color3.fromRGB(139, 44, 255)
}
ReplicatedStorage.events.shootKeepersTorch.OnClientEvent:Connect(function(position, p, p2, p3)
	local clone = fireball.Fireball:Clone()
	clone.CFrame = CFrame.new(position)
	clone.Parent = workspace.VFXDebris
	clone.cast:Play()
	local v2 = time()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { workspace.VFXDebris, workspace.zones }

	for _, v3 in game.Players:GetPlayers() do
		if v3.Character then
			raycastParams:AddToFilter(v3.Character)
		end
	end

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			descendant.Color = ColorSequence.new(v[p2] or Color3.fromRGB(255, 178, 69))
		elseif descendant:IsA("PointLight") then
			descendant.Color = v[p2] or Color3.fromRGB(255, 178, 69)
		end
	end

	local steppedConnection = nil
	steppedConnection = RunService.Stepped:Connect(function(_)
		local v3 = position + p * (time() - v2) * 120
		local v4 = time() - v2 > 5
		local raycastResult = workspace:Raycast(position, v3 - position, raycastParams)
		clone.CFrame = CFrame.new(v3)

		if raycastResult then
			local clone2 = fireball.Hit:Clone()
			clone2.CFrame = CFrame.new(raycastResult.Position)
			clone2.Parent = workspace
			clone2.hit:Play()
			v4 = true

			for _, descendant in ipairs(clone2:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					descendant.Color = ColorSequence.new(v[p2] or Color3.fromRGB(255, 178, 69))
				elseif descendant:IsA("PointLight") then
					descendant.Color = v[p2] or Color3.fromRGB(255, 178, 69)
				end
			end

			SebasUtil:EmitAll(clone2)
			SebasUtil:DisableAllParticles(clone)
			task.delay(4, function()
				clone2:Destroy()
			end)

			if p3 == localPlayer and raycastResult.Instance:IsDescendantOf(workspace.active.bosses.cthulu.CathuluChainBreakIK) then
				ReplicatedStorage.events.keepersTorchHit:FireServer(p2 == workspace.active.bosses.cthulu.CathuluChainBreakIK:GetAttribute("currentFlame"))
			end
		end

		if v4 then
			clone:Destroy()
			steppedConnection:Disconnect()
		end
	end)
end)