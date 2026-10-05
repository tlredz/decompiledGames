local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
require(ReplicatedStorage.Shared.Globals.Constants)
local GUI = require(ReplicatedStorage.Client.GUI)
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local Log = require(ReplicatedStorage.Packages.Log)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(255, 64, 64)
local color2 = Color3.fromRGB(48, 255, 105)
local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.62, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
local v = Log.new()
return {
	Start = function()
		local moreSpeedOnHit = GUI.GetMoreSpeedOnHit()
		local frame = moreSpeedOnHit.Frame
		assert(frame:IsA("Frame"), "PlayerGui.GetMoreSpeedOnHit.Frame must be a Frame")
		local button = frame.Button
		assert(button:IsA("GuiButton"), "PlayerGui.GetMoreSpeedOnHit.Frame.Button must be a GuiButton")
		local frame2 = button.Frame
		assert(frame2:IsA("Frame"), "PlayerGui.GetMoreSpeedOnHit.Frame.Button.Frame must be a Frame")
		local title = frame2.Title
		assert(title:IsA("TextLabel"), "PlayerGui.GetMoreSpeedOnHit.Frame.Button.Frame.Title must be a TextLabel")
		local uIScale = EnsureUIScale(frame2)
		local position = frame.Position
		local uDim = UDim2.new(position.X.Scale, position.X.Offset, -0.4, position.Y.Offset)
		local textColor3 = title.TextColor3
		local scale = uIScale.Scale
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local count = 0

		local function playPositionTween(udim: UDim2, p)
			if v3 ~= nil then
				v3:Cancel()
			end

			local tween = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, p), {
				Position = udim
			})
			v3 = tween
			tween:Play()
			return tween
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopTitlePulse()
			local v6 = v4

			if v6 == nil then
				return
			end

			v4 = nil
			v6:Destroy()
		end

		local function startTitlePulse()
			stopTitlePulse() -- equivalent call inferred; original call site unknown
			title.TextColor3 = textColor3
			uIScale.Scale = scale
			local maid = Trove.new()
			v4 = maid
			maid:Add(function()
				title.TextColor3 = textColor3
				uIScale.Scale = scale
			end)
			maid:Add(task.spawn(function()
				while v4 == maid do
					title.TextColor3 = textColor3
					uIScale.Scale = scale
					local tween = TweenService:Create(title, tweenInfo, {
						TextColor3 = color2
					})
					local tween2 = TweenService:Create(uIScale, tweenInfo, {
						Scale = scale * 1.3
					})
					maid:Add(tween)
					maid:Add(tween2)
					tween:Play()
					tween2:Play()
					tween2.Completed:Wait()

					if v4 ~= maid then
						break
					end

					local tween3 = TweenService:Create(title, tweenInfo2, {
						TextColor3 = textColor3
					})
					local tween4 = TweenService:Create(uIScale, tweenInfo2, {
						Scale = scale
					})
					maid:Add(tween3)
					maid:Add(tween4)
					tween3:Play()
					tween4:Play()
					tween4.Completed:Wait()
					title.TextColor3 = textColor3
					uIScale.Scale = scale
				end
			end))
		end

		local function showOffer(p: number, p2: number)
			count += 1
			local v6 = count
			v5 = p
			title.Text = `+{Simple.FormatCompact(p2, ".#")}`
			frame.Position = uDim
			startTitlePulse()
			moreSpeedOnHit.Enabled = true
			playPositionTween(position, Enum.EasingDirection.Out)
			task.delay(6, function()
				if v6 ~= count then
					return
				end

				playPositionTween(uDim, Enum.EasingDirection.In).Completed:Once(function()
					if v6 ~= count then
						return
					end

					stopTitlePulse() -- equivalent call inferred; original call site unknown
					v5 = nil
					moreSpeedOnHit.Enabled = false
				end)
			end)
		end

		moreSpeedOnHit.Enabled = false
		title.TextColor3 = textColor3
		uIScale.Scale = scale
		ButtonFX(button, nil, function()
			local v6 = v5

			if v6 == nil then
				v:AtWarning():Log("GetMoreSpeedOnHit button activated without an active product")
			else
				Storefront.Prompt(v6, true)
			end
		end)
		Remotes.GuardPatrol.SpeedTollWarning.OnClientEvent:Connect(function()
			Toast.Show({
				Text = "You don't have enough speed!",
				Seconds = 2,
				Color = color
			})
		end)
		Remotes.GuardPatrol.SpeedTollOffer.OnClientEvent:Connect(showOffer)
	end
}