local Debris = game:GetService("Debris")
game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SoulSword = {
	Name = "Soul Sword",
	Icon = "rbxassetid://87951994035674",
	Rarity = "Common",
	Description = "When a Twisted damages the user, the Twisted receives a 15% speed debuff for 30 seconds. Does not stack. As Soulvester, gain an additional heart while this trinket is equipped.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	TrinketState = "Other",
	Cost = 0,
	Requirement1 = { "None", 0 },
	HasSpecialEvent = true,
	SpecialEvent = function(_, _: number, parent)
		if not parent then
			return
		end

		local speedDebuff = parent:FindFirstChild("SpeedDebuff")

		if speedDebuff then
			Debris:AddItem(speedDebuff, 30)
			local chaser = parent:FindFirstChild("Chaser") or parent:FindFirstChild("ChaserDyle")

			if chaser then
				chaser:SetAttribute("LastAttack", tick())
			end
		else
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "SpeedDebuff"
			stringValue.Value = "Speed"
			local numberValue = Instance.new("NumberValue", stringValue)
			numberValue.Name = "Multiplier"
			numberValue.Value = 0.85
			stringValue.Parent = parent

			if parent.PrimaryPart and not parent.PrimaryPart:FindFirstChild("DebuffWindow") then
				local clone = ServerStorage.GUI.DebuffWindow:Clone()
				clone.Parent = parent.PrimaryPart
				clone.Script.Enabled = true
			end

			task.delay(1, function()
				if not (parent and parent.Parent) then
					return
				end

				local slow = parent:FindFirstChild("Slow")

				if slow then
					slow:Destroy()
				end

				local stringValue2 = Instance.new("StringValue")
				stringValue2.Name = "Slow"
				stringValue2:SetAttribute("IndicatorOnly", true)
				local stringValue3 = Instance.new("StringValue", stringValue2)
				stringValue3.Name = "DebuffType"
				stringValue3.Value = "Slow"
				local numberValue2 = Instance.new("NumberValue", stringValue2)
				numberValue2.Name = "Duration"
				numberValue2.Value = 30
				local numberValue3 = Instance.new("NumberValue", stringValue2)
				numberValue3.Name = "DebuffStrength"
				numberValue3.Value = 1
				stringValue2.Parent = parent
				Debris:AddItem(stringValue2, 29)
			end)
			local chaser = parent:FindFirstChild("Chaser") or parent:FindFirstChild("ChaserDyle")
			local runSpeed = chaser and chaser:FindFirstChild("RunSpeed")
			local patrolSpeed = chaser and chaser:FindFirstChild("PatrolSpeed")
			local humanoid = parent:FindFirstChild("Humanoid")
			local chasing = chaser and chaser:FindFirstChild("Chasing")

			if runSpeed and patrolSpeed and humanoid and chasing and chaser.Name == "Chaser" then
				local now = tick()
				chaser:SetAttribute("LastAttack", now)

				if not chaser:GetAttribute("SoulSwordActive") then
					runSpeed.Value *= 0.85
					patrolSpeed.Value *= 0.85
					chaser:SetAttribute("SoulSwordActive", true)
					humanoid.WalkSpeed = chasing.Value and runSpeed.Value or patrolSpeed.Value
				end

				task.delay(30, function()
					if not (chaser and chaser.Parent) then
						return
					end

					if chaser:GetAttribute("LastAttack") == now and runSpeed and runSpeed.Parent then
						runSpeed.Value /= 0.85
						patrolSpeed.Value /= 0.85
						chaser:SetAttribute("SoulSwordActive", false)
						humanoid.WalkSpeed = chasing.Value and runSpeed.Value or patrolSpeed.Value
					end
				end)
			end

			Debris:AddItem(stringValue, 30)
		end
	end
}

local function revokeHeart(instance)
	if not instance:GetAttribute("SoulSwordHeartGranted") then
		return
	end

	instance:SetAttribute("SoulSwordHeartGranted", nil)
	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.MaxHealth = math.max(humanoid.MaxHealth - 1, 1)
		humanoid.Health = math.min(humanoid.Health, humanoid.MaxHealth)
	end
end

function SoulSword.ApplyTrinket(instance)
	local config = instance:FindFirstChild("Config")
	local moduleName = config and config:FindFirstChild("ModuleName")

	if not moduleName or not moduleName:IsA("StringValue") or moduleName.Value ~= "Soulvester" or instance:GetAttribute("SoulSwordHeartGranted") then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	instance:SetAttribute("SoulSwordHeartGranted", true)
	humanoid.MaxHealth += 1
	humanoid.Health += 1
end

function SoulSword.RemoveTrinket(instance)
	local trinkets = instance:FindFirstChild("Trinkets")
	local trinket1 = trinkets and trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets and trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		revokeHeart(instance)
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		revokeHeart(instance)
		return "Slot2"
	end
end

return SoulSword