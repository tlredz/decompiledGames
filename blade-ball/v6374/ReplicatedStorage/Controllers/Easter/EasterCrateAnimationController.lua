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
local random = Random.new()
local playerGui = Players.LocalPlayer.PlayerGui
local v = nil
local v2 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Signal)
local v3 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v4 = require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.Shared.Easter.EasterSwordCrate)
local v6 = require3(ReplicatedStorage2.Controllers.Easter.EasterPageController)
require3(ReplicatedStorage2.Shared.EasterGachaData)
local v7 = require3(ReplicatedStorage2.Shared.WeightRandom)
require3(ReplicatedStorage2.Common.RewardInfo)
local flag = false
local remoteEvent = v4:RemoteEvent("OpenEasterCrate")
local unboxGui = playerGui:WaitForChild("EasterCrate"):WaitForChild("UnboxGui")
local mover = unboxGui:WaitForChild("WeaponsClipping"):WaitForChild("Scroller"):WaitForChild("Mover")
local unlocked = unboxGui.Unlocked
local fade = unboxGui.Fade
local X = unboxGui.X
local templateBlue = mover:WaitForChild("TemplateBlue")
templateBlue.Parent = nil
local templateGold = mover:WaitForChild("TemplateGold")
templateGold.Parent = nil
local templatePink = mover:WaitForChild("TemplatePink")
templatePink.Parent = nil
local EasterCrateAnimationController = {
	Start = function(self)
		v = v2.Client:WaitReplion("Data")
		remoteEvent.OnClientEvent:Connect(function(...)
			self:Open(...)
		end)
	end,
	Open = function(self, p, _: boolean?)
		while flag do
			task.wait()
		end

		flag = true
		local number = random:NextNumber(-38.56, -38.74)
		fade.Visible = false
		unlocked.Text = ""
		X.Visible = false
		v3:Lock("EasterCrate", true)
		v3:Open("EasterCrate", true)
		unboxGui.Position = UDim2.fromScale(0.5, 1.5)
		TweenService:Create(unboxGui, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
		local chancesByReward = {}

		for _, v8 in v5 do
			chancesByReward[v8.Reward] = v8.Chance
		end

		local picker = v7.getPicker(chancesByReward)

		for i = 1, 200 do
			local v8

			if i == 197 then
				v8 = p
			else
				v8 = picker()
			end

			createTemplate(i, v8)
		end

		mover.Position = UDim2.new()
		local tween = TweenService:Create(mover, TweenInfo.new(6.2, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(number, 0)
		})
		ReplicatedStorage2.Misc.spinwheel.TimePosition = 2
		ReplicatedStorage2.Misc.spinwheel:Play()
		tween:Play()
		tween.Completed:Wait()
		tween:Destroy()
		ReplicatedStorage2.Misc.spinwheel:Stop()
		ReplicatedStorage2.Misc.reward:Play()
		fade.Visible = true
		unlocked.Text = string.format("Rolled: %s", p.DisplayName)
		task.wait(3)
		TweenService:Create(unboxGui, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = UDim2.fromScale(0.5, 1.5)
		}):Play()
		task.wait(0.65)
		flag = false
		v3:Unlock("EasterCrate", true)
		v3:Close("EasterCrate", true)

		for _, button in mover:GetChildren() do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		v6:Open()
	end
}

function createTemplate(layoutOrder: number, p)
	local clone = random:NextInteger(1, 2) == 1 and templateBlue:Clone() or templatePink:Clone()
	clone.LayoutOrder = layoutOrder
	clone.ImageLabel.Image = p.Icon or ""
	clone.NameOfWeapon.Text = p.DisplayName or ""
	clone.Parent = mover
	return clone
end

return EasterCrateAnimationController