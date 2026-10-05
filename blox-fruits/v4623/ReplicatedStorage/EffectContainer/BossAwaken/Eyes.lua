local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local v = {
	{
		Marker = { "Eye1", "Eyes1" },
		Glow = "Glow1"
	},
	{
		Marker = { "Eye2", "Eyes2" },
		Glow = "Glow2"
	}
}

local function findMarker(folder, marker)
	for _, attachment in ipairs(folder:GetDescendants()) do
		if not attachment:IsA("Attachment") then
			continue
		end

		for _, v2 in ipairs(marker) do
			if attachment.Name == v2 then
				return attachment
			end
		end
	end

	return nil
end

return function(player)
	local character = player.Character

	if typeof(character) ~= "Instance" or not character:IsA("Model") then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or player.Root

	if not (humanoidRootPart and humanoidRootPart:IsA("BasePart")) or (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 900 then
		return
	end

	local v2 = os.clock() + (player.Duration or 4)
	local bossAwakenEyes = character:GetAttribute("BossAwakenEyes")

	if typeof(bossAwakenEyes) == "number" and os.clock() < bossAwakenEyes then
		character:SetAttribute("BossAwakenEyes", v2)
		return
	end

	character:SetAttribute("BossAwakenEyes", v2)
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local glowingEyes = assets and assets:FindFirstChild("GlowingEyes")

	if glowingEyes then
		local clones = {}
		local descendants = {}
		local descendants2 = {}

		for _, v3 in ipairs(v) do
			local marker = findMarker(character, v3.Marker)
			local child = glowingEyes:FindFirstChild(v3.Glow)
			local parent = marker and marker.Parent

			if not (marker and child and parent and parent:IsA("BasePart")) then
				continue
			end

			local v4 = typeof(player.Offset) ~= "number" and 0 or player.Offset
			local clone = child:Clone()
			clone.Parent = parent
			clone.CFrame = marker.CFrame * CFrame.new(0, 0, -v4)
			table.insert(clones, clone)

			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("ParticleEmitter") then
					if typeof(player.Color) == "Color3" then
						descendant.Color = ColorSequence.new(player.Color)
					end

					descendant.ZOffset = math.max(descendant.ZOffset, 2)
					descendant.Enabled = true
					table.insert(descendants, descendant)
				elseif descendant:IsA("PointLight") then
					local brightness = descendant.Brightness
					descendant.Brightness = 0
					TweenService:Create(descendant, TweenInfo.new(0.45), {
						Brightness = brightness
					}):Play()
					table.insert(descendants2, descendant)
				end
			end
		end

		if #clones ~= 0 then
			task.spawn(function()
				while character.Parent do
					local bossAwakenEyes2 = character:GetAttribute("BossAwakenEyes")

					if typeof(bossAwakenEyes2) ~= "number" or bossAwakenEyes2 <= os.clock() then
						break
					end

					RunService.Heartbeat:Wait()
				end

				for _, v3 in ipairs(descendants) do
					v3.Enabled = false
				end

				for _, v3 in ipairs(descendants2) do
					TweenService:Create(v3, TweenInfo.new(0.35), {
						Brightness = 0
					}):Play()
				end

				task.wait(0.35)

				for _, v3 in ipairs(clones) do
					if v3.Parent then
						v3:Destroy()
					end
				end

				if character.Parent then
					character:SetAttribute("BossAwakenEyes", nil)
				end
			end)
			return
		end

		warn((`BossAwaken.Eyes: no Eye1/Eye2 attachments on {character.Name}`))
		character:SetAttribute("BossAwakenEyes", nil)
	else
		warn("BossAwaken.Eyes: ReplicatedStorage.Assets.GlowingEyes is missing")
		character:SetAttribute("BossAwakenEyes", nil)
	end
end