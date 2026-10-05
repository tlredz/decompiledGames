local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Net)
local v4 = require3(ReplicatedStorage2.Shared.HourlyWheelData)
require3(script.Parent.Parent)
local v5 = nil
local v6 = nil
local v7 = nil
local count = 0
local numberValue = Instance.new("NumberValue")
local Spinner = {}

local function getPlayerOPReward(localPlayer)
	local v8 = nil

	for k, guaranteedReward in v4.GuaranteedRewards do
		if v4.GuaranteedRewards[k + 1] and v2.RewardInfo.playerOwnsItem(localPlayer, guaranteedReward.Reward) then
			v8 = guaranteedReward
		else
			v8 = guaranteedReward
			break
		end
	end

	if v8 and v8.Replacement then
		local v10 = v.Client:WaitReplion("Data")

		if not v10 or v8.ShouldUseReplacement(v10) then
			return v8.Replacement
		end
	end

	return v8
end

function GetAngle(p: number, p2: number)
	return p + p2 * 360
end

function CalculateRolls(p: number)
	return p * 360
end

function WrapNumber(p: number, p2: number)
	local v8 = p % p2

	if v8 == 0 then
		return p2
	end

	return v8
end

function CycleSpin(state, data, p: string)
	if state.IsSpinning then
		return
	end

	local v8 = state.FiveSpinEnabled and 0.3 or 2
	state.IsSpinning = true
	numberValue.Value = 0
	state.Container[p].Rotation = 0
	local tween = TweenService:Create(
		state.Container[p],
		TweenInfo.new(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Rotation = GetAngle(data.Angle, 5)
		}
	)
	local tween2 = TweenService:Create(
		numberValue,
		TweenInfo.new(v8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0),
		{
			Value = 80
		}
	)

	if p ~= "Outer" then
		script.Advance:Play()
	end

	tween:Play()
	tween2:Play()
	tween.Completed:Connect(function()
		script[`{p}Reward`]:Play()
		local parent = state.Container[p][data.Index]

		local function DestroyAfterTween(instance, p2)
			local tween3 = TweenService:Create(
				instance,
				TweenInfo.new(0.7, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0),
				p2
			)
			tween3:Play()
			tween3.Completed:Connect(function()
				task.wait(0.1)

				if instance:IsDescendantOf(state.Container) then
					instance:Destroy()
				end
			end)
		end

		if data.Advance and p ~= "Inner" then
			local clone = parent.Icon.Title:Clone()
			clone.Parent = parent.Icon
			DestroyAfterTween(clone, {
				Size = clone.Size + UDim2.fromScale(2, 2),
				TextTransparency = 1
			})
			DestroyAfterTween(clone.UIStroke, {
				Transparency = 1
			})
		elseif data.Advance and p == "Inner" then
			local clone = state.Container.OP:Clone()
			clone.Parent = state.Container
			local lastTime = tick()
			local v10 = 0.8

			while tick() - lastTime < v10 do
				local number = Random.new():NextNumber(-4, 4)
				local number2 = Random.new():NextNumber(-4, 4)
				clone.Position = UDim2.new(0.5, number, 0.5, number2)
				task.wait()
			end

			clone.Position = UDim2.new(0.5, 0, 0.5, 0)
			DestroyAfterTween(clone, {
				Size = clone.Size + UDim2.fromScale(1, 1)
			})
			DestroyAfterTween(clone.CircleImg, {
				ImageTransparency = 1
			})
			DestroyAfterTween(clone.GrandPrize.Glow, {
				ImageTransparency = 1
			})
			DestroyAfterTween(clone.GrandPrize.Icon, {
				ImageTransparency = 1
			})
		else
			local clone = parent.Icon:Clone()
			clone.Parent = parent
			DestroyAfterTween(clone, {
				Size = clone.Size + UDim2.fromScale(2, 2),
				ImageTransparency = 1
			})
		end

		v6:FireServer()
		state.IsSpinning = false
	end)
end

function Spinner:HookSpinner(p)
	local value = numberValue.Value
	numberValue.Changed:Connect(function()
		if numberValue.Value == 0 or not p.IsSpinning then
			return
		end

		local v8 = WrapNumber(math.ceil(numberValue.Value), CalculateRolls(5))

		if v8 == value then
			return
		end

		local clone = script.Tick:Clone()
		clone.Parent = p.Container
		clone:Play()
		task.delay(clone.TimeLength + 0.1, function()
			clone:Destroy()
		end)
		value = v8
	end)
end

function FillRewards(p, childName)
	local function update()
		local playerOPReward = getPlayerOPReward(Players.LocalPlayer)
		local oP = p.Container:FindFirstChild("OP")
		oP.GrandPrize.Icon.Image = playerOPReward.Reward.Icon or ""
		local clone = v4[childName]

		if childName == "Inner" then
			clone = table.clone(clone)

			for _, v9 in clone do
				if not v9.Advance then
					continue
				end

				local v10 = v9.Probability - playerOPReward.Chance
				v9.Probability -= v10
				local clone2 = table.clone(clone.Item1)
				clone2.Probability += v10
				clone.Item1 = clone2
				break
			end
		end

		for childName2, v8 in clone do
			local child = p.Container:FindFirstChild(childName):FindFirstChild(childName2)

			if not child then
				continue
			end

			local probability = v8.Probability

			if v8.Advance then
				local findFirstChild = p.Container:FindFirstChild(childName)
				findFirstChild.Advance.Odds.Text = `{math.round(probability * 100) / 100}%`
			else
				child.Odds.Text = `{math.round(probability * 100) / 100}%`
			end
		end
	end

	v7:OnChange("ReceivedHourlyWheelCoralGreatsword", update)
	update()

	if childName == "Inner" then
		for _, guaranteedReward in v4.GuaranteedRewards do
			local itemOwnershipState = v2.RewardInfo.getItemOwnershipState(Players.LocalPlayer, guaranteedReward.Reward)

			if itemOwnershipState then
				itemOwnershipState:Connect(update)
			end
		end
	end

	for childName2, v8 in v4[childName] do
		local child = p.Container:FindFirstChild(childName):FindFirstChild(childName2)

		if not child then
			continue
		end

		if v8.Advance and v8.IconId or v8.Reward.Icon then
			child.Icon.Image = v8.Advance and v8.IconId or v8.Reward.Icon
		else
			warn(`[{childName2}] Missing an icon, data:`, v8, child)
		end

		local v9 = v8
		local v10 = child

		local function updateOdd()
			local probability = v9.Probability

			if v9.Advance then
				local findFirstChild = p.Container:FindFirstChild(childName)
				findFirstChild.Advance.Odds.Text = `{math.round(probability * 100) / 100}%`
			else
				v10.Odds.Text = `{math.round(probability * 100) / 100}%`
			end
		end

		updateOdd()

		if v8.Advance then
			local clone_2 = script.Title:Clone()
			clone_2.Parent = child.Icon
		end

		if v8.AbilityTrial then
			local value = v8.AbilityTrial.Reward.Value
			local v12 = child
			local v13 = v8

			local function updateVisual()
				if v7:Find("Abilities.Unlocked", value) and not v7:Get({ "Trials", "Abilities", value }) then
					v12.Icon.Image = v13.Reward.Icon or ""
					v12.Expiration.Visible = false
				else
					v12.Expiration.Visible = true

					if v13.AbilityTrial.ExpireTime and not (os.time() < v13.AbilityTrial.ExpireTime) then
						v12.Expiration.Time.Visible = false
						return
					end

					v12.Icon.Image = v13.AbilityTrial.Reward.Icon or "rbxassetid://6034407076"
					v12.Expiration.Time.Visible = true
					local duration = v13.AbilityTrial.Reward.Duration
					v12.Expiration.Time.Text = v2.ValueConvertor:FormatTime(duration):gsub(" 00s", "")
				end
			end

			updateVisual()
			v7:OnChange({ "Trials", "Abilities", value }, update)
			v7:OnChange("Abilities.Unlocked", update)
		else
			child.Expiration.Time.Visible = false
		end
	end
end

function Spinner:Hook(p)
	v7 = v.Client:WaitReplion("Data")
	v5 = v3:RemoteEvent("HourlyWheel/ProcessRoll")
	v6 = v3:RemoteEvent("HourlyWheel/ClaimReward")
	v5.OnClientEvent:Connect(function(value, p2: string)
		if typeof(value) == "boolean" then
			script.FinalReward:Play()
		elseif typeof(value) == "string" then
			if p.FiveSpinEnabled then
				local v8 = v7:Get((`{v4.ReplionPath}.Amount`))

				if count < 5 and v8 > 0 then
					count += 1
					v5:FireServer()
				else
					count = 0
					p.FiveSpinEnabled = false
				end
			end
		else
			CycleSpin(p, value, p2)
		end
	end)
	FillRewards(p, "Outer")
	FillRewards(p, "Middle")
	FillRewards(p, "Inner")
	Spinner:HookSpinner(p)
end

function Spinner.Init(_, container)
	local v8 = {
		Container = container,
		IsSpinning = false,
		FiveSpinEnabled = false
	}
	Spinner:Hook(v8)
	return v8
end

return Spinner