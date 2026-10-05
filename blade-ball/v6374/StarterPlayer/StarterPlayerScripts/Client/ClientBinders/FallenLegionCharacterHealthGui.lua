local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Utils = require(ReplicatedStorage.Common.Utils)
return {
	Binder = function(instance)
		local showForClient = instance:GetAttribute("ShowForClient")

		if showForClient then
			local parent = instance.Parent

			if not parent then
				return
			end

			local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

			if not (playerFromCharacter and playerFromCharacter == Players.LocalPlayer) then
				return
			end
		end

		local maid = Utils.Maid.new()
		local v = Utils.Streamer:Sync(instance, "Frame", "BossHealth")
		maid:GiveTask(v)
		maid:GiveTask(v.Loaded:Connect(function(instance2)
			local function updateHealth()
				local health = instance.Parent:GetAttribute("Health") or 0
				local maxHealth = instance.Parent:GetAttribute("MaxHealth") or 0

				if showForClient then
					instance.Enabled = health < maxHealth
				end

				for i = 1, maxHealth do
					local child = instance2:FindFirstChild(i)

					if not child then
						continue
					end

					if health <= 1 and health >= 0 and maxHealth == 1 then
						local v2 = math.clamp(health / 1, 0, 1)
						TweenService:Create(child.Holder.Bar, TweenInfo.new(1, Enum.EasingStyle.Quint), {
							Size = UDim2.fromScale(v2, 1)
						}):Play()
					elseif health < i then
						local v2 = 1 - math.max(health - i, 0)
						TweenService:Create(child.Holder, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
							Position = UDim2.fromScale(-v2, 0)
						}):Play()
						TweenService:Create(child.Holder.Bar, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
							Position = UDim2.fromScale(v2, 0)
						}):Play()
					else
						child.Holder.Position = UDim2.fromScale(0, 0)
						child.Holder.Bar.Position = UDim2.fromScale(0, 0)
					end
				end
			end

			local parent = instance.Parent

			if parent then
				if showForClient then
					local v2 = 1
					maid.DamageReceived = instance.Parent:GetAttributeChangedSignal("Health"):Connect(function()
						parent = instance.Parent
						local health

						if parent then
							health = parent:GetAttribute("Health")
						end

						if health and health < v2 then
							ReplicatedStorage.Misc.BattleRoyaleSFX.DamageReceived:Play()
						end
					end)

					function maid.CleanupDamageReceived()
						parent = nil
						v2 = nil
					end
				end

				maid.HealthUpdated = parent:GetAttributeChangedSignal("Health"):Connect(updateHealth)
				maid.MaxHealthUpdated = parent:GetAttributeChangedSignal("MaxHealth"):Connect(updateHealth)
				task.spawn(updateHealth)
			end
		end))
		return maid
	end
}