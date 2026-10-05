local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local editData = ReplicatedStorage:FindFirstChild("editData")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local TowerLUT = require(ReplicatedStorage.SharedUtils.TowerLUT)
local LooeyAbility = {
	setupCharacter = function(instance, p)
		local humanoid = instance:WaitForChild("Humanoid")
		instance:WaitForChild("Stats")
		local config = instance:WaitForChild("Config")
		local maxHealth = humanoid.MaxHealth
		local health = humanoid.Health
		local v = {
			Head = instance:FindFirstChild("Head")
		}
		local sizes = {}
		local speedStat = 0
		local v3 = 1
		local v4 = false

		for k, part in pairs(v) do
			if part and part:IsA("BasePart") then
				sizes[k] = part.Size
			else
				warn("[Scaling] Missing or invalid part:", k)
			end
		end

		local scale = instance:GetScale()

		-- equivalent calls inferred from this helper; original call sites unknown
		local function rigScaleRatio()
			return instance:GetScale() / scale
		end

		local v5 = nil
		local healthSpeedMultiplier = 1

		local function updateSpeed()
			speedStat = math.clamp(math.floor(maxHealth - humanoid.Health), 0, 5)
			local v7 = speedStat * 0.2 + 1
			local v8 = not TowerLUT:HasPassive(instance, "Looey") and 1 or v7

			if v5 then
				StatModifierManager.RemoveSpeedModifiers(instance, v5)
			end

			if v8 > 1 then
				v5 = StatModifierManager.ApplySpeedModifiers(instance, v8, "LooeyHeartOfHelium", {
					category = "ability"
				})
			else
				v5 = nil
			end

			healthSpeedMultiplier = v8
		end

		local function applyScale(part, size, duration)
			if part and size then
				TweenService:Create(part, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = size
				}):Play()
			end
		end

		local function updateModelSize(p2)
			if p2 < 0 then
				if instance:FindFirstChild("Audio") and instance.Audio:FindFirstChild("Pop") and instance.Audio.Pop:FindFirstChild("Value") then
					instance.Audio.Pop.Value:Play()
				end

				if instance:FindFirstChild("RootPart") and instance.RootPart:FindFirstChild("Attachment") and instance.RootPart.Attachment:FindFirstChild("ParticleEmitter") then
					instance.RootPart.Attachment.ParticleEmitter:Emit(5)
				end
			end

			local v7 = math.clamp(1 * (1 - (maxHealth - health) / maxHealth * 0.3), 0.6, 1)
			local v8 = rigScaleRatio() -- equivalent call inferred; original call site unknown
			local hat = instance:FindFirstChild("Hat")

			if hat then
				hat.Size = (health == 1 and createVector(2.379, 1, 2.379) or health == 2 and createVector(
					2.379,
					1.1,
					2.379
				) or hat:GetAttribute("OriginalSize") or createVector(2.379, 1.204, 2.379)) * v8
			end

			if v7 ~= v3 then
				for k, part in pairs(v) do
					if part and part:IsA("BasePart") and sizes[k] then
						applyScale(part, sizes[k] * v8 * v7, 0.2)
					end
				end

				v3 = v7
			end
		end

		humanoid.HealthChanged:Connect(function(p2)
			local v7 = p2 - health
			health = p2

			if v7 < 0 then
				v4 = true
				updateSpeed()
				updateModelSize(v7)
				task.wait(0.1)
				v4 = false
				local success, result = pcall(function()
					if editData then
						editData:Invoke(p, function(p3)
							if p3 then
								local v8 = false

								for _, v10 in pairs(p3.Data.Mastery) do
									if v10.Name ~= config.ModuleName.Value then
										continue
									end

									v8 = v10
									break
								end

								if v8 then
									for _, v10 in pairs(v8.RequirementList) do
										if v10.Name == "PassiveAbilityActivate" then
											v10.Current = math.min(v10.Current + 1, v10.Amount)
										end
									end
								end
							end
						end)
					else
						warn("[Mastery] 'editData' RemoteFunction not found in ReplicatedStorage.")
					end
				end)

				if not success then
					warn("[Mastery] Error updating data:", result)
				end
			elseif v7 > 0 then
				if instance:FindFirstChild("Audio") and instance.Audio:FindFirstChild("Grow") and instance.Audio.Grow:FindFirstChild("Value") then
					instance.Audio.Grow.Value:Play()
				end

				v4 = true
				updateSpeed()
				updateModelSize(v7)
				task.wait(0.1)
				v4 = false
			end
		end)

		for _, v7 in ipairs({ "MaskToon", "MaskPassive", "MaskStatsOnly" }) do
			instance:GetAttributeChangedSignal(v7):Connect(updateSpeed)
		end

		return {
			currentHealth = health,
			maxHealth = maxHealth,
			speedStat = speedStat,
			healthSpeedMultiplier = healthSpeedMultiplier
		}
	end,
	OnDamaged = function(instance, state, _)
		state.currentHealth = instance:WaitForChild("Humanoid").Health
		state.speedStat = math.clamp(math.floor(state.maxHealth - state.currentHealth), 0, 5)
		return state
	end
}

function LooeyAbility.Init(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	local result = {
		currentHealth = humanoid.Health,
		maxHealth = humanoid.MaxHealth,
		speedStat = 0,
		healthSpeedMultiplier = 1
	}

	if not instance or instance:WaitForChild("Config").ModuleName.Value ~= "Looey" then
		return result
	end

	local v = LooeyAbility.setupCharacter(instance, playerFromCharacter)

	if v then
		for k, v2 in pairs(v) do
			result[k] = v2
		end
	end

	return result
end

return LooeyAbility