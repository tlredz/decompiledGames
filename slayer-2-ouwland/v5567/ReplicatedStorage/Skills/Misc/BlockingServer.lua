local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DebrisModule = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("DebrisModule"))
local _ = math.clamp
local clock = os.clock
local Utility = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Utility"))
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local PlayerStatResolver = require(ReplicatedStorage.CAM.Global.PlayerStatResolver)
local manage_cd = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.manage_cd)
local ServerStorage = game:GetService("ServerStorage")
local Checklists = require(ServerStorage.SAM.Services.Checklists)
local v = {
	Stun = true,
	Strict_Stun = true,
	CombatStun = true
}

local function idleUntilStunned(child, duration: number)
	local thread = coroutine.running()
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function wake()
		if flag then
			return
		end

		flag = true
		task.spawn(thread)
	end

	local childAddedConnection = child.ChildAdded:Connect(function(child2)
		if v[child2.Name] then
			wake() -- equivalent call inferred; original call site unknown
		end
	end)
	task.delay(duration, wake)
	coroutine.yield()
	childAddedConnection:Disconnect()
end

local function refreshBlockStats(instance, instance2)
	local v2 = PlayerStatResolver.GetStat(instance, "Block Points") or 0
	local maxValue = math.max(math.round(gameSettings.BaseStats.BlockPoints + v2), 1)

	if maxValue ~= instance2.MaxValue then
		local v4 = instance2.Value / math.max(instance2.MaxValue, 1)
		instance2.MaxValue = maxValue
		instance2.Value = maxValue * v4
	end

	instance2:SetAttribute("AddedBlockPoints", v2)
	instance2:SetAttribute("BlockRegen", PlayerStatResolver.GetStat(instance, "Block Regen") or 0)
end

local BlockingServer = {}
BlockingServer.Id = {}

function BlockingServer.Hold(instance)
	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(instance.Name)

	if child ~= nil then
		local v2 = instance:FindFirstChild("Blocking")

		if v2 == nil then
			v2 = Instance.new("IntConstrainedValue")
			v2.Name = "Blocking"
			refreshBlockStats(instance, v2)
			v2.Value = v2.MaxValue
			v2.Parent = child

			local function onStatChange()
				refreshBlockStats(instance, v2)
			end

			local v3 = PlayerStatResolver.Attach(instance, "Block Points", onStatChange)
			local v4 = PlayerStatResolver.Attach(instance, "Block Regen", onStatChange)
			local now = clock()
			local v5 = v2.Value / v2.MaxValue
			local changedConnection = v2.Changed:Connect(function()
				if v2 then
					local v6 = v2.Value / v2.MaxValue

					if v6 < v5 then
						now = clock()
					end

					v5 = v6
				end
			end)

			local function postBreakRegenReady()
				local breakAt = v2:GetAttribute("BreakAt")

				if breakAt == nil then
					return false
				end

				local v6 = breakAt + gameSettings.BlockBreakRegenDelay

				if Utility.Tick() < v6 then
					return false
				end

				local DMG = child:FindFirstChild("DMG")
				local lastAttacked

				if DMG ~= nil then
					lastAttacked = DMG:GetAttribute("LastAttacked") or nil
				end

				if lastAttacked == nil or not (v6 < lastAttacked) then
					return true
				end

				v2:SetAttribute("BreakAt", nil)
				return false
			end

			task.spawn(function()
				while instance ~= nil and child ~= nil and instance.Parent == game.Players and v2 ~= nil and (v2.Parent == instance or v2.Parent == child) do
					local v6

					if gameSettings.BlockRegenWhileStunned == true then
						v6 = child:FindFirstChild("Stun") ~= nil or child:FindFirstChild("Strict_Stun") ~= nil or child:FindFirstChild("CombatStun") ~= nil
					else
						v6 = false
					end

					local temporaryBoost = Utility.TemporaryBoostOf(child, gameSettings.StunChainBoost.Stat)
					local v7

					if temporaryBoost > 1 then
						v7 = gameSettings.StunChainBoost.SkipsRegenCooldown == true
					else
						v7 = false
					end

					if v6 or v7 or clock() - now > gameSettings.BlockRegenerateCoolDown or postBreakRegenReady() then
						if (v2:GetAttribute("D") or 0) > 0 then
							v2:SetAttribute("D", 0)
						else
							v2.Value += 1
						end

						if v2.Value >= v2.MaxValue then
							v2:SetAttribute("BreakAt", nil)
						end

						task.wait(gameSettings.BlockRegenInterval / ((1 + (v2:GetAttribute("BlockRegen") or 0)) * temporaryBoost))
					elseif gameSettings.BlockRegenWhileStunned == true then
						idleUntilStunned(child, 1)
					else
						task.wait(1)
					end
				end

				if changedConnection ~= nil then
					changedConnection:Disconnect()
				end

				if v3 ~= nil then
					v3()
				end

				if v4 ~= nil then
					v4()
				end
			end)
		end

		local now = os.clock()
		local v3 = now - (v2:GetAttribute("PressedAt") or -1e999) >= manage_cd.fetch(instance, "Blocking") - 0.3
		v2:SetAttribute("PressedAt", now)

		if v3 then
			local stringValue = Instance.new("StringValue")
			stringValue.Name = "escapeiframe"
			stringValue.Parent = child
			DebrisModule:AddItem(stringValue, 0.025)
		end

		refreshBlockStats(instance, v2)
		v2.Name = "Blocking"
		v2.Parent = child
		v2:AddTag("Blocking")
		local v4 = child:FindFirstChild("Stun") ~= nil or child:FindFirstChild("CombatStun") ~= nil

		if v3 and v4 and child:FindFirstChild("Strict_Stun") == nil then
			task.spawn(Checklists.Bump, instance, "Block")
		end

		if v3 and child:FindFirstChild("Stun") == nil and child:FindFirstChild("CombatStun") == nil and (child:FindFirstChild("DMG") and Utility.Tick() - child.DMG:GetAttribute("LastAttacked") or 2) >= 1 then
			local stringValue = Instance.new("StringValue", v2)
			stringValue.Name = "Perfect"
			DebrisModule:AddItem(stringValue, 0.1)
			local stringValue2 = Instance.new("StringValue", v2)
			stringValue2.Name = "PerfectNpc"
			DebrisModule:AddItem(stringValue2, 0.25)
		end
	end
end

function BlockingServer.UnHold(parent)
	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(parent.Name)

	if child ~= nil then
		local blocking = child:FindFirstChild("Blocking")
		task.wait()

		if blocking ~= nil then
			blocking:RemoveTag("Blocking")
			blocking.Parent = parent
		end
	end
end

function BlockingServer.Cancel(parent)
	local child = game.ReplicatedStorage.Player_Service.Values:FindFirstChild(parent.Name)

	if child ~= nil then
		local blocking = child:FindFirstChild("Blocking")
		task.wait()

		if blocking ~= nil then
			blocking:RemoveTag("Blocking")
			blocking.Parent = parent
		end
	end
end

return BlockingServer