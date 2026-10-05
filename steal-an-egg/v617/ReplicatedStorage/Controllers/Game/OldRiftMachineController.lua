local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RiftMachineSchedule = require(ReplicatedStorage.Shared.Util.RiftMachineSchedule)
return {
	Start = function()
		if RiftMachineSchedule.IsLaboratoryTime() then
			return
		end

		local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
		local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
		local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
		local Save = require(ReplicatedStorage.Shared.Save)
		local Tabs = require(ReplicatedStorage.Client.Tabs)
		local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
		local localPlayer = Players.LocalPlayer
		local oldRiftMachine = Workspace:WaitForChild("World"):WaitForChild("Machines"):WaitForChild(
			"OldRiftMachine",
			5
		)

		if oldRiftMachine == nil then
			return
		end

		local rift = oldRiftMachine:WaitForChild("Rift")
		local proximityPrompt = oldRiftMachine:WaitForChild("Machine"):WaitForChild("Attachment"):WaitForChild("ProximityPrompt")
		local billboardGui = oldRiftMachine:WaitForChild("Overhead"):WaitForChild("BillboardGui")
		local timer = oldRiftMachine.Overhead:WaitForChild("TimerGui"):WaitForChild("Timer")
		local shop = timer:WaitForChild("Shop")
		timer.Enabled = false
		local v = {}
		local enabledsByDescendant = {}

		for _, descendant in rift:GetDescendants() do
			if descendant:IsA("BasePart") then
				v[descendant] = {
					Collide = descendant.CanCollide,
					Query = descendant.CanQuery,
					Touch = descendant.CanTouch
				}
			elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") then
				enabledsByDescendant[descendant] = descendant.Enabled
			end
		end

		local v2 = nil
		local v3 = nil
		local connections = {}
		local v4 = true

		local function resolveState()
			if not RiftEligibility.IsFeatureLive() then
				return "Hidden"
			end

			local v5 = Save.Await()

			if v5 ~= nil and RiftEligibility.IsEligible(v5.SpeedPower) then
				return "Open"
			end

			local v6 = v5 == nil and 0 or v5.SpeedPower
			local v7 = v5 == nil and 0 or v5.LastLogout

			if RiftEligibility.IsRevealed(localPlayer, v6, v7) then
				return "Locked"
			end

			return "Hidden"
		end

		local function applyState(p: string)
			if v3 == p then
				return
			end

			v3 = p
			local enabled = p == "Open"

			for k, v6 in v do
				k.LocalTransparencyModifier = enabled and 0 or 1
				local canCollide

				if enabled then
					canCollide = v6.Collide
				else
					canCollide = false
				end

				k.CanCollide = canCollide
				local canQuery

				if enabled then
					canQuery = v6.Query
				else
					canQuery = false
				end

				k.CanQuery = canQuery
				local canTouch

				if enabled then
					canTouch = v6.Touch
				else
					canTouch = false
				end

				k.CanTouch = canTouch
			end

			for k, enabled2 in enabledsByDescendant do
				if not enabled then
					enabled2 = false
				end

				k.Enabled = enabled2
			end

			billboardGui.Enabled = enabled
			local shop2 = billboardGui:FindFirstChild("Shop")

			if shop2 and shop2:IsA("TextLabel") then
				shop2.Text = "THE RIFT"
			end

			if p == "Locked" then
				if v2 == nil then
					local clone = ReplicatedStorage.Assets.VFX.RiftTradeIn.LockedPortal:Clone()
					local riftPivotOffset = clone:GetAttribute("RiftPivotOffset")
					assert(typeof(riftPivotOffset) == "CFrame", "LockedPortal needs RiftPivotOffset")
					clone.Name = "LockedPortal"
					clone:PivotTo(rift:GetPivot() * riftPivotOffset)
					v2 = clone
				end

				v2.Parent = oldRiftMachine
			elseif v2 ~= nil then
				v2.Parent = nil
			end

			proximityPrompt.ActionText = p == "Locked" and "Locked" or "The Rift"
			proximityPrompt.Enabled = p ~= "Hidden"
		end

		local function refreshTimer()
			local v5 = RiftMachineSchedule.GetSwapAt() - Workspace:GetServerTimeNow()
			local enabled

			if v3 == "Open" then
				enabled = RiftEligibility.IsFeatureLive() and v5 > 0
			else
				enabled = false
			end

			timer.Enabled = enabled

			if not enabled then
				return v5
			end

			local v7 = math.ceil(v5)
			local v8 = math.floor(v7 / 86400)
			local v9 = math.floor(v7 % 86400 / 3600)
			local v10 = math.floor(v7 % 3600 / 60)
			local v11 = v7 % 60

			if v8 > 0 then
				shop.Text = string.format("Animals Leaving In: %dd %dh", v8, v9)
				return v5
			end

			if v9 > 0 then
				shop.Text = string.format("Animals Leaving In: %dh %dm", v9, v10)
				return v5
			else
				shop.Text = string.format("Animals Leaving In: %dm %ds", v10, v11)
			end

			return v5
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			if not v4 or oldRiftMachine.Parent == nil then
				return
			end

			applyState(resolveState())
			refreshTimer()
		end

		table.insert(connections, proximityPrompt.Triggered:Connect(function()
			if not v4 or oldRiftMachine.Parent == nil then
				return
			end

			if v3 == "Locked" then
				Toast.Show({
					Text = "You need " .. TreadmillUtil.FormatSpeedPower(RiftFlags.SpeedPowerRequirement:Get()) .. " Speed to use this!",
					Seconds = 3,
					Color = Color3.fromRGB(196, 152, 255)
				})
			elseif v3 == "Open" and RiftEligibility.IsFeatureLive() then
				Tabs.Activate("RiftTradeIn")
			end
		end))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function watch(object)
			table.insert(connections, object:Connect(refresh))
		end

		local v5 = Save.WatchFields("SpeedPower", refresh)
		watch(RiftFlags.SpeedPowerRequirement.Changed) -- equivalent call inferred; original call site unknown
		watch(RiftFlags.Retired.Changed) -- equivalent call inferred; original call site unknown
		watch(Workspace:GetAttributeChangedSignal(RiftEligibility.OpenAttribute)) -- equivalent call inferred; original call site unknown
		watch(localPlayer:GetAttributeChangedSignal(RiftEligibility.CutsceneSeenAttribute)) -- equivalent call inferred; original call site unknown
		table.insert(connections, oldRiftMachine.AncestryChanged:Connect(function()
			if oldRiftMachine.Parent ~= nil then
				return
			end

			v4 = false
			timer.Enabled = false
			v5:Clean()

			for _, connection in connections do
				connection:Disconnect()
			end
		end))
		refresh() -- equivalent call inferred; original call site unknown
		task.spawn(function()
			while v4 and oldRiftMachine.Parent ~= nil do
				local v6 = refreshTimer()

				if v6 <= 0 then
					break
				else
					task.wait((math.min(1, v6)))
				end
			end
		end)
	end
}