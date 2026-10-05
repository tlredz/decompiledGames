local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local Data = require(ReplicatedStorage.Modules.Data)
local Network = require(ReplicatedStorage.Modules.Network)
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts")
local sounds = script.Sounds
local parent = script.Parent
local tabs = parent.Tabs
local _ = parent.Parent.Parent
require(ReplicatedStorage.Modules.PlayerStates)
local UI = require(ReplicatedStorage.Modules.UI)
local SideBarButtons = require(game.ReplicatedStorage.Assets.Data.UIData.SideBarButtons)
local backgroundColor3 = tabs.Tab.BackgroundColor3
local imageColor3 = tabs.Tab.Icon.ImageColor3
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad)

for k, sideBarButton in SideBarButtons do
	if not (sideBarButton.CreateCondition == nil or sideBarButton.CreateCondition) then
		continue
	end

	local color = sideBarButton.Color or backgroundColor3
	local clone = tabs.Tab:Clone()
	clone.Name = k
	clone.Icon.Image = sideBarButton.Icon
	clone.Icon.Size = UDim2.fromScale(
		clone.Icon.Size.X.Scale * (sideBarButton.IconScale or 1),
		clone.Icon.Size.Y.Scale * (sideBarButton.IconScale or 1)
	)
	clone.Visible = true
	clone.LayoutOrder = sideBarButton.Order
	clone.Parent = tabs

	if sideBarButton.ExtraImage then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = sideBarButton.ExtraImage
		imageLabel.BackgroundTransparency = 1
		imageLabel.Size = UDim2.new(1.25, 0, 1.25, 0)
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Parent = clone
		imageLabel.ZIndex = 2
		clone.ClipsDescendants = false
	end

	if sideBarButton.GamepassRequired then
		local v = sideBarButton

		local function HasGamepass()
			return Players.LocalPlayer:GetAttribute(v.GamepassRequired)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local parent2 = clone
		local v3 = sideBarButton

		local function UpdateVisibility()
			parent2.Locked.Visible = not Players.LocalPlayer:GetAttribute(v3.GamepassRequired)
		end

		Players.LocalPlayer:GetAttributeChangedSignal(sideBarButton.GamepassRequired):Connect(UpdateVisibility)
		UpdateVisibility() -- equivalent call inferred; original call site unknown
	end

	local function UpdateColor(flag: boolean)
		if flag then
			TweenService:Create(clone, tweenInfo, {
				BackgroundColor3 = imageColor3
			}):Play()
			TweenService:Create(clone.Icon, tweenInfo, {
				ImageColor3 = color
			}):Play()
		else
			TweenService:Create(clone, tweenInfo, {
				BackgroundColor3 = color
			}):Play()
			TweenService:Create(clone.Icon, tweenInfo, {
				ImageColor3 = imageColor3
			}):Play()
		end
	end

	TweenService:Create(clone, tweenInfo, {
		BackgroundColor3 = color
	}):Play()
	TweenService:Create(clone.Icon, tweenInfo, {
		ImageColor3 = imageColor3
	}):Play()

	if sideBarButton.MatchingFrame then
		local matchingFrame = sideBarButton.MatchingFrame
		matchingFrame.Visible = false
		local v4 = sideBarButton
		local UpdateColor2 = UpdateColor
		matchingFrame:GetPropertyChangedSignal("Visible"):Connect(function()
			if matchingFrame.Visible then
				for k2, sideBarButton2 in SideBarButtons do
					if sideBarButton2 == v4 or not sideBarButton2.MatchingFrame or v4.IgnoredFrames and table.find(
						v4.IgnoredFrames,
						k2
					) then
						continue
					end

					sideBarButton2.MatchingFrame.Visible = false
				end
			end

			local visible = matchingFrame.Visible
			UpdateColor2(visible)

			if matchingFrame.Name == "Shop" then
				if visible then
					sounds.ShopOpen:Play()
				else
					sounds.ShopClose:Play()
				end
			end
		end)

		for _, v5 in next, Data, nil do
			print(v5)
		end

		if k == "Shop" and localPlayer:GetAttribute("Shop") ~= true then
			clone.NotificationDot.Visible = true
		end

		local parent2 = clone
		localPlayer:GetAttributeChangedSignal("Shop"):Once(function()
			parent2.NotificationDot.Visible = false
		end)
		local parent3 = clone
		local v7 = sideBarButton
		local matchingFrame2 = matchingFrame
		clone.Button.MouseButton1Click:Connect(function()
			if parent3.Name == "Shop" and parent3.NotificationDot.Visible == true then
				parent3.NotificationDot.Visible = false
				Network:fire("NotificatedPressed", "Shop")
			end

			if parent3.Locked.Visible then
				if v7.GamepassRequired then
					GamepassUtil:DisplayGamepassInfo(v7.GamepassRequired)
				end
			elseif matchingFrame2.Name ~= "Profile" then
				matchingFrame2.Visible = not matchingFrame2.Visible
			elseif not matchingFrame2.Visible then
				Network:fire("GetProfile")
			elseif matchingFrame2.Name == "Profile" then
				_G.SetProfileVisible(false)
			else
				matchingFrame2.Visible = false
			end
		end)
	end

	if sideBarButton.Callback then
		task.spawn(sideBarButton.Callback, clone)
	end

	UI:Bind(clone.Button)
	UI:AddShadowOnHover(clone)
end