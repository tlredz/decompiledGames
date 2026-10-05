local RunService = game:GetService("RunService")
local cframe = CFrame.new(-0.013702, -0.183366, 0.006739, 0, 0, -1, 0, 1, 0, 1, 0, 0)
return function(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or player.Root

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 900 then
		return
	end

	local v = os.clock() + (player.Duration or 5)
	local gorillaKingBanana = character:GetAttribute("GorillaKingBanana")

	if typeof(gorillaKingBanana) == "number" and os.clock() < gorillaKingBanana then
		character:SetAttribute("GorillaKingBanana", v)
		return
	end

	character:SetAttribute("GorillaKingBanana", v)
	local gorillaBanana = script:FindFirstChild("GorillaBanana")

	if gorillaBanana then
		local rightHand = character:FindFirstChild("RightHand")

		if rightHand and rightHand:IsA("BasePart") then
			local clone = gorillaBanana:Clone()
			local handle = clone:FindFirstChild("Handle")

			if handle and handle:IsA("BasePart") then
				local parts = {}

				for _, part in ipairs(clone:GetDescendants()) do
					if not part:IsA("BasePart") then
						continue
					end

					part.Anchored = false
					part.CanCollide = false
					part.CanQuery = false
					part.CanTouch = false
					part.Massless = true
					table.insert(parts, part)
				end

				clone:PivotTo(rightHand.CFrame * cframe)
				clone.Parent = character
				local motor6D = Instance.new("Motor6D")
				motor6D.Name = "Handle"
				motor6D.Part0 = rightHand
				motor6D.Part1 = handle
				motor6D.C0 = cframe
				motor6D.Parent = rightHand
				task.spawn(function()
					while character.Parent do
						local gorillaKingBanana2 = character:GetAttribute("GorillaKingBanana")

						if typeof(gorillaKingBanana2) ~= "number" or gorillaKingBanana2 <= os.clock() then
							break
						end

						RunService.Heartbeat:Wait()
					end

					local lastTime = os.clock()

					while os.clock() - lastTime < 0.35 and character.Parent do
						local v2 = (os.clock() - lastTime) / 0.35

						for _, v3 in ipairs(parts) do
							v3.Transparency = math.max(v3.Transparency, v2)
						end

						RunService.Heartbeat:Wait()
					end

					if motor6D.Parent then
						motor6D:Destroy()
					end

					if clone.Parent then
						clone:Destroy()
					end

					if character.Parent then
						character:SetAttribute("GorillaKingBanana", nil)
					end
				end)
			else
				warn("GorillaKing.Banana: GorillaBanana has no Handle part")
				clone:Destroy()
				character:SetAttribute("GorillaKingBanana", nil)
			end
		else
			warn((`GorillaKing.Banana: no RightHand on {character.Name}`))
			character:SetAttribute("GorillaKingBanana", nil)
		end
	else
		warn("GorillaKing.Banana: GorillaBanana is missing from the effect module")
		character:SetAttribute("GorillaKingBanana", nil)
	end
end