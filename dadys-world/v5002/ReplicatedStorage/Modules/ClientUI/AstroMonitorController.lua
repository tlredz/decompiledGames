local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local GameContext = require(ReplicatedStorage.Modules.Core.GameContext)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local heartbeatConnection = nil
local v = {}

local function cleanup()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	for _, v2 in pairs(v) do
		if v2 and v2.Parent then
			v2:Destroy()
		end
	end

	v = {}
end

return {
	setup = function()
		cleanup()
		local character = GameContext.Character

		if not (character and character.Parent) then
			return
		end

		local config = character:FindFirstChild("Config")
		local moduleName = config and config:FindFirstChild("ModuleName")

		if not moduleName or moduleName.Value == "" or not TowerLUT:HasPassive(character, "Astro") then
			return
		end

		print("Astro Passive: Starting client-side stamina monitoring")
		local astro = ReplicatedStorage.TowerData:FindFirstChild("Astro")

		if not astro then
			warn("Astro Passive: Astro module not found")
			return
		end

		local heartIcon = astro:FindFirstChild("HeartIcon")

		if not heartIcon then
			warn("Astro Passive: HeartIcon template not found")
			return
		end

		local v2 = 0
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			local now = tick()

			if now - v2 < 0.5 then
				return
			end

			v2 = now

			for k, v3 in pairs(v) do
				if not (v3 and v3.Parent and v3.Parent.Parent) then
					v[k] = nil
				end
			end

			local inGamePlayers = Workspace:FindFirstChild("InGamePlayers")

			if not inGamePlayers then
				return
			end

			for _, model in pairs(inGamePlayers:GetChildren()) do
				if not (model ~= character and model:IsA("Model")) then
					continue
				end

				local v3 = model
				local success, result = pcall(function()
					local humanoid = v3:FindFirstChild("Humanoid")
					local humanoidRootPart = v3:FindFirstChild("HumanoidRootPart")
					local stats = v3:FindFirstChild("Stats")

					if humanoid and humanoidRootPart and stats and humanoid.Health > 0 then
						local currentStamina = stats:FindFirstChild("CurrentStamina")
						local stamina = stats:FindFirstChild("Stamina")

						if currentStamina and stamina and stamina.Value > 0 then
							local v4 = math.clamp(currentStamina.Value / stamina.Value, 0, 1)
							local v5 = tostring(v3)

							if v4 <= 0.5 then
								if not (v[v5] and v[v5].Parent) then
									local clone = heartIcon:Clone()
									clone.Enabled = true
									clone.AlwaysOnTop = true
									clone.Parent = humanoidRootPart
									local frame = clone:FindFirstChild("Frame")
									local heart1 = frame and frame:FindFirstChild("Heart1")

									if heart1 then
										heart1.Visible = true
										heart1.ImageTransparency = 0.3
									end

									v[v5] = clone
								end

								if character.PrimaryPart then
									local v6 = math.clamp(
										(character.PrimaryPart.Position - humanoidRootPart.Position).Magnitude / 10,
										2,
										15
									)
									v[v5].Size = UDim2.new(v6, 0, v6, 0)
								end
							elseif v[v5] then
								v[v5]:Destroy()
								v[v5] = nil
							end
						end
					end
				end)

				if not success then
					warn("Astro Passive: Error monitoring toon:", result)
				end
			end
		end)
	end
}