local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
Random.new()
local playerGui = Players.LocalPlayer.PlayerGui
local v = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v3 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Common.Utils)
local v6 = require3(ReplicatedStorage2.Shared.GenericCrateData)
local v7 = require3(ReplicatedStorage2.Shared.TitleData)
local v8 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local uDim = UDim2.fromScale(0.055, 0.085)
local chancesByReward = {}
local v9 = nil
local flag = false

for _, reward in v6.Rewards do
	chancesByReward[reward] = reward.Chance
end

local picker = v8.getPicker(chancesByReward)
local genericCrate = playerGui:WaitForChild("GenericCrate")
local unboxGui = genericCrate:WaitForChild("UnboxGui")
local scroller = unboxGui:WaitForChild("WeaponsClipping"):WaitForChild("Scroller")
local mover = scroller:WaitForChild("Mover")
local unlocked = unboxGui.Unlocked
local fade = unboxGui.Fade
local X = unboxGui.X

-- equivalent calls inferred from this helper; original call sites unknown
local function getTitleData(value: string)
	for _, v10 in v7 do
		if v10.Name == value then
			return v10
		end
	end

	return nil
end

local function createTemplate(layoutOrder: number, data)
	local clone = mover.UIListLayout.Template:Clone()
	clone.LayoutOrder = layoutOrder
	local v10 = #clone:GetChildren()
	local v11 = clone[tostring((layoutOrder - 1) % v10 + 1)]
	v11.Visible = true

	if data.Type == "Title" then
		local titleData = getTitleData(data.Value) -- equivalent call inferred; original call site unknown
		assert(titleData, (`failed to find title data for {data.Value}`))
		v11.Title.Label.Text = `"{titleData.Tag.Text}"`
		v11.Title.Label.TextColor3 = titleData.Tag.Color
		v11.Title.Visible = true
		v11.Vector.Visible = false
	else
		v11.Vector.Image = data.Icon or ""
		v11.Vector.Visible = true
		v11.Title.Visible = false
	end

	clone.Visible = true
	clone.Parent = mover
	return clone
end

local GenericCrateAnimationController = {}

function GenericCrateAnimationController.Start(_)
	v9 = v.Client:WaitReplion("Data")
end

function GenericCrateAnimationController:Open()
	while flag do
		task.wait()
	end

	flag = true
	local replion = v.Client:GetReplion("Data")

	if not replion then
		flag = false
		return
	end

	local expect = replion:GetExpect(v6.Currency)
	local price = v6.Price

	if expect < price then
		local v10 = price - expect
		local v11 = v5.ValueConvertor:AddCommas(v10)
		local v12

		if v10 == 1 then
			v12 = string.lower(v6.CurrencyDisplayName)
		else
			v12 = string.lower(v6.CurrencyDisplayNamePlural)
		end

		v3:SendNotification(`You need {v11} more {v12} to open this crate!`, 3)
		ReplicatedStorage2.Misc.error:Play()
		flag = false
	else
		local v10, v11 = v4:Invoke("OpenGenericCrate", 1)

		if v10 and typeof(v11) == "buffer" then
			local v12 = buffer.readu8(v11, 1)
			local reward = v6.Rewards[v12].Reward
			fade.Visible = false
			unlocked.Text = ""
			X.Visible = false
			v2:Lock(genericCrate.Name, true)
			v2:Open(genericCrate.Name, true)
			unboxGui.Position = UDim2.fromScale(0.5, 1.5)
			TweenService:Create(unboxGui, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
				Position = UDim2.fromScale(0.5, 0.5)
			}):Play()
			local v13 = nil

			for i = 1, 60 do
				local v14 = i == 57
				local v15

				if v14 then
					v15 = reward
				else
					v15 = picker().Reward
				end

				local template = createTemplate(i, v15)

				if v14 then
					v13 = template
				end
			end

			mover.Position = uDim
			task.wait(0.5)
			local v14 = mover.AbsoluteSize.X / 2 - (v13.AbsolutePosition.X + v13.AbsoluteSize.X / 2 - scroller.AbsolutePosition.X)
			local tween = TweenService:Create(mover, TweenInfo.new(6.2, Enum.EasingStyle.Sine), {
				Position = uDim + UDim2.fromOffset(v14, 0)
			})
			ReplicatedStorage2.Misc.spinwheel.TimePosition = 2
			ReplicatedStorage2.Misc.spinwheel:Play()
			tween:Play()
			tween.Completed:Wait()
			tween:Destroy()
			ReplicatedStorage2.Misc.spinwheel:Stop()
			ReplicatedStorage2.Misc.reward:Play()
			fade.Visible = true
			unlocked.Text = string.format("Rolled: %s", reward.DisplayName)
			task.wait(3)
			TweenService:Create(unboxGui, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, 1.5)
			}):Play()
			task.wait(0.65)
			flag = false
			v2:Unlock(genericCrate.Name, true)
			v2:Close(genericCrate.Name, true)

			for _, guiObject in mover:GetChildren() do
				if guiObject:IsA("GuiObject") then
					guiObject:Destroy()
				end
			end
		else
			v3:SendNotification(typeof(v11) ~= "string" and "Internal Server Error! [1]" or v11, 3)
			ReplicatedStorage2.Misc.error:Play()
			flag = false
		end
	end
end

return GenericCrateAnimationController