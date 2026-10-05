local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Shared.Policy)
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local v3 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.Shared.WelcomeBackData)
local v4 = require3(ReplicatedStorage2.Shared.WelcomeBackCrate)
local playerGui = Players.LocalPlayer.PlayerGui
local v5 = nil
local cost = v4.Cost
local remoteFunction = v:RemoteFunction("PurchaseReturnCrateKey")
local remoteFunction2 = v:RemoteFunction("OpenReturnCrate")
local remoteEvent = v:RemoteEvent("RolledReturnCrate")
local crate = playerGui:WaitForChild("NewWelcomeBack").Frame.Views.Crate
local template = crate.Items.Template
template.Parent = nil
local clones = {}
local Crate = {
	Start = function(_)
		v5 = v2.Client:WaitReplion("Data")
		local flag = false
		crate.Buy.MouseButton1Click:Connect(function()
			if flag then
				return
			end

			flag = true

			if (v5:Get("WelcomeBackEvent.ReturnCrateKeys") or 0) > 0 then
				remoteFunction2:InvokeServer()
			else
				remoteFunction:InvokeServer()
			end

			task.wait(0.1)
			flag = false
		end)
		remoteEvent.OnClientEvent:Connect(RollForItem)
		v5:OnChange("WelcomeBackEvent.ReturnCrateKeys", UpdateCurrency)
		UpdateCurrency(v5:Get("WelcomeBackEvent.ReturnCrateKeys"))

		for i = 1, 8 do
			local reward = v4.Rewards[i]
			local clone = template:Clone()
			clone.LayoutOrder = i
			clone.Percentage.Text = `{v3:AddCommas(reward.Chance)}%`
			clone.ItemName.Text = reward.Reward.DisplayName
			clone.Vector.Image = reward.Reward.Icon or ""
			clone.Parent = crate.Items
			clones[i] = clone
		end
	end
}

function RollForItem(p: number)
	local count = #v4.Rewards
	local v6 = count * 3 + p - 1
	local v7 = math.random(3, 4)
	local v8 = 1
	local v9 = {}

	for _ = 1, 4 do
		for i = 1, count do
			local v10 = 0.15 - v8 / v6 * 0.1

			if v6 < v8 + v7 then
				v10 *= math.sqrt(v8 + v7) / 2
			end

			if v6 < v8 then
				task.wait(v10 / 2)
				break
			end

			local v11 = clones[i]

			if v11 then
				local v12 = v9[i]

				if v12 then
					v12:Cancel()
				end

				v11.Selection.Visible = true
				v11.Selection.ImageTransparency = 0
				v9[i] = FastTween(v11.Selection, TweenInfo.new(v10 * 2), {
					ImageTransparency = 1
				})
			end

			FastAudio("rbxassetid://6895079853", SoundService, 1, 0.5)
			task.wait(v10)
			v8 += 1
		end
	end

	for i, v10 in ipairs(clones) do
		if i == p then
			local v11 = v9[i]

			if v11 then
				v11:Cancel()
			end

			v10.Selection.ImageTransparency = 1
			FastTween(v10.Selection, TweenInfo.new(0.3), {
				ImageTransparency = 0
			})
		else
			FastTween(v10, TweenInfo.new(0.3), {
				ImageTransparency = 0.8
			})
			FastTween(v10.Vector, TweenInfo.new(0.3), {
				ImageTransparency = 0.8
			})
		end
	end

	local parent = clones[p]

	if parent then
		local clone = parent.Vector:Clone()
		clone.ZIndex = -10
		clone.ImageTransparency = 0.1
		clone.Parent = parent
		FastTween(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quart), {
			Size = UDim2.fromScale(1.5, 1.5),
			ImageTransparency = 1
		}).Completed:Once(function()
			clone:Destroy()
		end)
	end

	table.clear(v9)
	task.wait(1)

	for i, v11 in ipairs(clones) do
		if i == p then
			FastTween(v11.Selection, TweenInfo.new(0.3), {
				ImageTransparency = 1
			})
		else
			FastTween(v11, TweenInfo.new(0.3), {
				ImageTransparency = 0
			})
			FastTween(v11.Vector, TweenInfo.new(0.3), {
				ImageTransparency = 0
			})
		end
	end
end

function FastTween(p, p2, p3)
	local tween = TweenService:Create(p, p2, p3)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

function FastAudio(soundId: string, parent, volume: number?, value: number?, value2: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Parent = parent
	sound.Volume = volume
	sound.PlaybackSpeed = value or 1
	sound.TimePosition = value2 or 0
	sound:Play()
	sound.Ended:Once(function()
		sound:Destroy()
	end)
	return sound
end

function UpdateCurrency(value: number?)
	local v6 = value or 0

	if v6 > 0 then
		crate.Buy.Cost.Text = `Spin - {v6}`
		crate.Buy.Vector.Visible = false
	else
		crate.Buy.Cost.Text = v3:AddCommas(cost)
		crate.Buy.Vector.Visible = true
	end
end

return Crate