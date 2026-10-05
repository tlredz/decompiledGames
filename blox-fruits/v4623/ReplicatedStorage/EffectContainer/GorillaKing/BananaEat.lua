local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local berryVisualData = ReplicatedStorage:WaitForChild("EffectContainer"):WaitForChild("Berries"):WaitForChild("Collect"):WaitForChild("BerryVisualData")
local module = require(berryVisualData)
return function(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	local head = character:FindFirstChild("Head")

	if not (head and head:IsA("BasePart")) or (workspace.CurrentCamera.CFrame.Position - head.Position).Magnitude > 900 or character:GetAttribute("GorillaKingBananaEat") then
		return
	end

	local variant = module.Variants[module.indexFromName("Yellow Star")]

	if not variant then
		warn("GorillaKing.BananaEat: no Yellow Star variant")
		return
	end

	character:SetAttribute("GorillaKingBananaEat", true)
	local v = { variant.Colors.Primary, variant.Colors.Secondary, variant.Colors.Tertiary }
	local cframe = CFrame.new(0, -head.Size.Y * 0.28, 0)
	local part = Instance.new("Part")
	part.Name = "GorillaKingBananaEat"
	part.Size = createVector(0.2, 0.2, 0.2)
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.CFrame = head.CFrame * cframe
	part.Parent = workspace:FindFirstChild("_WorldOrigin") or workspace
	local v2 = 0

	for _, v3 in ipairs({ variant.Pick, variant.Touch }) do
		for _, emitter in ipairs(v3:GetChildren()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local clone = emitter:Clone()
			local _Recolorable = clone:GetAttribute("_Recolorable")

			if typeof(_Recolorable) == "number" and v[_Recolorable] then
				clone.Color = ColorSequence.new(v[_Recolorable])
			end

			clone.Parent = part
			v2 = math.max(v2, clone.Lifetime.Max)
			clone:Emit(clone:GetAttribute("EmitCount") or 1)
		end
	end

	local heartbeatConnection = RunService.Heartbeat:Connect(function()
		if head.Parent then
			part.CFrame = head.CFrame * cframe
		end
	end)
	task.delay(v2 + 1.5, function()
		heartbeatConnection:Disconnect()
		part:Destroy()

		if character.Parent then
			character:SetAttribute("GorillaKingBananaEat", nil)
		end
	end)
end