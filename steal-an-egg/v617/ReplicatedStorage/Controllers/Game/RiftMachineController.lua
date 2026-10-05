local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local RiftEligibility = require(ReplicatedStorage.Shared.Util.RiftEligibility)
local RiftFlags = require(ReplicatedStorage.Shared.Flags.RiftFlags)
local ScrambleTradeInEligibility = require(ReplicatedStorage.Shared.Util.ScrambleTradeInEligibility)
local ScrambleTradeInFlags = require(ReplicatedStorage.Shared.Flags.ScrambleTradeInFlags)
local RiftMachineSchedule = require(ReplicatedStorage.Shared.Util.RiftMachineSchedule)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
return {
	Start = function()
		local riftTradeIn = ReplicatedStorage.Assets.VFX.RiftTradeIn
		local color = Color3.fromRGB(196, 152, 255)
		local localPlayer = Players.LocalPlayer
		local riftMachine = Workspace:WaitForChild("World"):WaitForChild("Machines"):WaitForChild(
			"RiftMachine",
			(math.max(10, RiftMachineSchedule.GetSwapAt() - Workspace:GetServerTimeNow() + 60))
		)

		if riftMachine == nil then
			return
		end

		local rift = riftMachine:WaitForChild("Rift")
		local proximityPrompt = riftMachine:WaitForChild("Machine"):WaitForChild("Attachment"):WaitForChild("ProximityPrompt")
		local objectText = proximityPrompt.ObjectText
		local billboardGui = riftMachine:WaitForChild("Overhead"):WaitForChild("BillboardGui")
		local timer = riftMachine:WaitForChild("Overhead"):WaitForChild("TimerGui"):WaitForChild("Timer")
		local shop = timer:WaitForChild("Shop")
		timer.Enabled = false
		local enabledsByDescendant = {}
		local v = {}

		for _, descendant in rift:GetDescendants() do
			if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") then
				enabledsByDescendant[descendant] = descendant.Enabled
			elseif descendant:IsA("BasePart") then
				v[descendant] = {
					CanCollide = descendant.CanCollide,
					CanQuery = descendant.CanQuery,
					CanTouch = descendant.CanTouch
				}
			end
		end

		local v2 = nil
		local v3 = nil
		local v4 = false
		local v5 = false
		local shop2 = billboardGui:FindFirstChild("Shop")

		local function lockedVisual()
			local v6 = ScrambleTradeInFlags.Enabled:Get()
			local v7 = v2

			if v7 ~= nil then
				if v5 == v6 then
					return v7
				else
					v7:Destroy()
				end
			end

			v5 = v6
			local v8

			if v6 then
				v8 = riftTradeIn.LockedLaboratory
			else
				v8 = riftTradeIn.LockedPortal
			end

			local clone = v8:Clone()
			local riftPivotOffset = clone:GetAttribute("RiftPivotOffset")
			assert(typeof(riftPivotOffset) == "CFrame", "LockedPortal needs a RiftPivotOffset CFrame attribute")
			clone.Name = "LockedPortal"
			clone:PivotTo(rift:GetPivot() * riftPivotOffset)
			v2 = clone
			return clone
		end

		local function laboratoryActive()
			return ScrambleTradeInFlags.Enabled:Get()
		end

		local function resolveState()
			if ScrambleTradeInFlags.Enabled:Get() then
				local v6 = Save.Await()

				if v6 == nil or ScrambleTradeInEligibility.RequiredSpeedPower() == nil then
					return "Hidden"
				end

				if ScrambleTradeInEligibility.IsEligible(v6.SpeedPower) then
					return "Open"
				end

				if RiftEligibility.IsEligible(v6.SpeedPower) or v6.LastLogout ~= 0 or RiftEligibility.HasSeenReveal(localPlayer) then
					return "Locked"
				end

				return "Hidden"
			else
				if not RiftEligibility.IsFeatureLive() then
					return "Hidden"
				end

				local v6 = Save.Await()

				if v6 ~= nil and RiftEligibility.IsEligible(v6.SpeedPower) then
					return "Open"
				end

				local v7 = v6 == nil and 0 or v6.SpeedPower
				local v8 = v6 == nil and 0 or v6.LastLogout

				if RiftEligibility.IsRevealed(localPlayer, v7, v8) then
					return "Locked"
				end

				return "Hidden"
			end
		end

		local function applyState(p: string)
			local requiredSpeedPower = ScrambleTradeInEligibility.RequiredSpeedPower()
			local v6

			if p == "Locked" then
				v6 = ScrambleTradeInFlags.Enabled:Get() and requiredSpeedPower ~= nil
			else
				v6 = false
			end

			proximityPrompt:SetAttribute("ObjectTextBelow", v6)
			local v7 = proximityPrompt
			local objectText2

			if v6 then
				objectText2 = `Unlocked at {TreadmillUtil.FormatSpeedPower(requiredSpeedPower)} speed`
			else
				objectText2 = objectText
			end

			v7.ObjectText = objectText2

			if v3 == p and v4 == ScrambleTradeInFlags.Enabled:Get() then
				return
			end

			v3 = p
			v4 = ScrambleTradeInFlags.Enabled:Get()
			local enabled = p == "Open"

			for k, v10 in v do
				k.LocalTransparencyModifier = enabled and 0 or 1
				local canCollide

				if enabled then
					canCollide = v10.CanCollide
				else
					canCollide = false
				end

				k.CanCollide = canCollide
				local canQuery

				if enabled then
					canQuery = v10.CanQuery
				else
					canQuery = false
				end

				k.CanQuery = canQuery
				local canTouch

				if enabled then
					canTouch = v10.CanTouch
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

			if shop2 then
				shop2.Text = v4 and "DR. SCRAMBLE'S LABORATORY" or "THE RIFT"
			end

			if p == "Locked" then
				local lockedVisual_2 = lockedVisual()
				lockedVisual_2.Parent = riftMachine
			elseif v2 ~= nil then
				v2.Parent = nil
			end

			proximityPrompt.ActionText = p == "Locked" and "Locked" or v4 and "Dr. Scramble's Laboratory" or "The Rift"
			proximityPrompt.Enabled = p ~= "Hidden"
		end

		local function refreshTimer()
			local v6 = 1790434800 - Workspace:GetServerTimeNow()
			local enabled

			if v3 == "Open" then
				enabled = not ScrambleTradeInFlags.Enabled:Get() and v6 > 0
			else
				enabled = false
			end

			timer.Enabled = enabled

			if not enabled then
				return v6
			end

			local v8 = math.ceil(v6)
			local v9 = math.floor(v8 / 86400)
			local v10 = math.floor(v8 % 86400 / 3600)
			local v11 = math.floor(v8 % 3600 / 60)
			local v12 = v8 % 60

			if v9 > 0 then
				shop.Text = string.format("%s%dd %dh", "Animals Leaving In: ", v9, v10)
				return v6
			end

			if v10 > 0 then
				shop.Text = string.format("%s%dh %dm", "Animals Leaving In: ", v10, v11)
				return v6
			else
				shop.Text = string.format("%s%dm %ds", "Animals Leaving In: ", v11, v12)
			end

			return v6
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refresh()
			applyState(resolveState())
			refreshTimer()
		end

		proximityPrompt.ActionText = "The Rift"
		proximityPrompt.Triggered:Connect(function()
			if v3 ~= "Locked" then
				Tabs.Activate(ScrambleTradeInFlags.Enabled:Get() and "DrScrambleTradeIn" or "RiftTradeIn")
				return
			end

			local v6

			if ScrambleTradeInFlags.Enabled:Get() then
				v6 = ScrambleTradeInEligibility.RequiredSpeedPower()
			else
				v6 = RiftFlags.SpeedPowerRequirement:Get()
			end

			if v6 == nil then
				refresh() -- equivalent call inferred; original call site unknown
			else
				local show = Toast.Show
				local v7 = {
					Text = `You need {TreadmillUtil.FormatSpeedPower(v6)} Speed to use this!`,
					Seconds = 3,
					Color = 0
				}
				local color2

				if ScrambleTradeInFlags.Enabled:Get() then
					color2 = Color3.fromRGB(81, 226, 36)
				else
					color2 = color
				end

				v7.Color = color2
				show(v7)
			end
		end)
		applyState("Hidden")
		Save.Await()
		refresh() -- equivalent call inferred; original call site unknown
		local v6 = Save.WatchFields("SpeedPower", refresh)
		RiftFlags.SpeedPowerRequirement.Changed:Connect(refresh)
		RiftFlags.Retired.Changed:Connect(refresh)
		ScrambleTradeInEligibility.Changed:Connect(refresh)
		ScrambleTradeInFlags.Enabled.Changed:Connect(refresh)
		ScrambleTradeInFlags.SpeedPowerRequirement.Changed:Connect(refresh)
		Workspace:GetAttributeChangedSignal(RiftEligibility.OpenAttribute):Connect(refresh)
		localPlayer:GetAttributeChangedSignal(RiftEligibility.CutsceneSeenAttribute):Connect(refresh)
		task.spawn(function()
			while riftMachine.Parent ~= nil do
				local v7 = refreshTimer()

				if v7 <= 0 then
					break
				else
					task.wait((math.min(1, v7)))
				end
			end
		end)
		return v6
	end
}