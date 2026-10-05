local UserInputService = game:GetService("UserInputService")
local AnalyticsUtil = require(game.ReplicatedStorage.Util.AnalyticsUtil)
local GuideModule = require(game.ReplicatedStorage.GuideModule)
local Global = require(game.ReplicatedStorage.Global)
local Map = require(game.ReplicatedStorage.Controllers.UI.Map)
local SideCompass = require(game.ReplicatedStorage.GuideModule.SideCompass)
local Map2 = require(game.ReplicatedStorage.Definitions.Map)
local Trove = require(game.ReplicatedStorage.Modules.Util.Trove)
local flag = false
local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
local _ = game.Players.LocalPlayer
local parent = script.Parent.Parent

local function setIfChanged(p, p2, p3)
	if p[p2] ~= p3 then
		p[p2] = p3
	end
end

return function(p, data)
	while not Map.IsInitialized do
		task.wait()
	end

	assert(Map.IsInitialized, "bad Map")
	local toggleTracking
	local quest = parent:WaitForChild("Quest")
	local UI = GuideModule.UI
	local leftFrame = UI:WaitForChild("LeftFrame")
	local iconFrame = leftFrame:WaitForChild("IconFrame")
	local v = false
	local sideCompass = GuideModule.SideCompass
	local button = GuideModule.SideCompass:WaitForChild("Frame"):WaitForChild("Button")
	GuideModule:ParentUI(parent)
	local updateEventTrackers = nil

	local function toggleQuest(flag2: boolean)
		local abandon = leftFrame:WaitForChild("Abandon")

		if flag2 == true then
			abandon.Visible = true
			GuideModule:ToggleCompassShown(false)
			GuideModule:ResetCompass()

			if not v then
				quest.Visible = true
				SideCompass.hide()
			end

			flag = true
			UI.TopFrame.Header.Text = "Mission"
			UI.BottomFrame.Header.Text = "Reward:"
			local track = parent:WaitForChild("Guide"):WaitForChild("LeftFrame"):WaitForChild("Track")
			track.Visible = false
		else
			GuideModule:ChangeDisplayedNPC(nil)
			GuideModule:ToggleCompassShown(not parent.Parent:FindFirstChild("DungeonInterface"))
			abandon.Visible = false

			if not v then
				if parent.Parent:FindFirstChild("DungeonInterface") then
					SideCompass.hide()
				else
					SideCompass.show()
				end
			end

			quest.Visible = false
			flag = false
			UI.TopFrame.Header.Text = "Recommended Quest"
			UI.BottomFrame.Header.Text = ""
			UI.BottomFrame.Description.Text = ""
			local track_2 = parent:WaitForChild("Guide"):WaitForChild("LeftFrame"):WaitForChild("Track")
			track_2.Visible = true
		end
	end

	local function toggleGuide(visible: boolean)
		if SideCompass.COMPASS_BILLBOARD_SHOW_ISLAND_WHEN_TRACKING and toggleTracking then
			if visible then
				if GuideModule.Data.Tracking == true then
					task.defer(toggleTracking, false)
				else
					task.defer(toggleTracking, true)
				end
			else
				task.defer(toggleTracking, false)
			end

			visible = false
		end

		Global.TestGamePrint("toggleGuide", visible)
		local notify = sideCompass:WaitForChild("Notify")
		notify.Visible = false

		if visible == true then
			UI.Visible = true
			SideCompass.hide()
			quest.Visible = false
			v = true
			data.getCurrentDamageCounter():SetPosition(UDim2.new(0.02, 10, 0.455, -8))
		else
			UI.Visible = visible

			if flag then
				quest.Visible = true
			elseif parent.Parent:FindFirstChild("DungeonInterface") then
				SideCompass.hide()
			else
				SideCompass.show()
			end

			data.getCurrentDamageCounter():SetPosition(UDim2.new(0.2, 10, 0.6, 0))
			v = false
		end

		if updateEventTrackers then
			task.spawn(updateEventTrackers)
		end
	end

	local flag2 = false
	local _ = p.Value

	local function tryFreshieGuideToggle()
		if flag2 then
		end
	end

	p.Changed:Connect(tryFreshieGuideToggle)

	local function onCompassClick()
		Global.TestGamePrint("compassButton.Activated")
		AnalyticsUtil.reportActivity("HUD/Button/Compass")
		toggleGuide(not v)
		toggleTracking(not GuideModule.Data.Tracking)
	end

	button.TextButton.MouseButton1Click:Connect(onCompassClick)
	button.Activated:Connect(onCompassClick)
	UI:WaitForChild("Close").Activated:Connect(function()
		Global.TestGamePrint("questExpansionWindow:WaitForChild(\"Close\").Activated")
		toggleGuide(false)
	end)
	quest:WaitForChild("Expand").Activated:Connect(function()
		Global.TestGamePrint("questWindow:WaitForChild(\"Expand\").Activated")
		toggleGuide(true)
	end)
	local v2 = nil

	toggleTracking = function(tracking: boolean)
		if GuideModule.Data.Tracking == tracking and Map:GetNavigationTarget() ~= nil == tracking then
			return
		end

		if v2 then
			v2:Destroy()
			v2 = nil
		end

		GuideModule.Data.Tracking = tracking

		if not tracking then
			Map:SetNavigationTarget(nil)
		end

		local track = parent:WaitForChild("Guide"):WaitForChild("LeftFrame"):WaitForChild("Track")
		GuideModule:ResetCompass()

		if GuideModule.Data.Tracking == true then
			v2 = Trove.new()
			assert(v2):Add(function()
				v2 = nil
				Global.GuideCallbacks.SpecialLocation = nil
			end)
			track.TextLabel.Text = "Untrack"
		else
			track.TextLabel.Text = "Track"
		end

		SideCompass.setButtonVisible(true)

		if v ~= false then
			toggleGuide(false)
		end

		if GuideModule.Data.Tracking then
			SideCompass.setButtonImageColor(Color3.new(1, 0, 0))
		else
			SideCompass.setButtonImageColor(Color3.new(1, 1, 1))
		end

		if not tracking then
			Global.TrackingLightningEvent = false
			Global.TrackingCorruptedEvent = false
		end

		return v2
	end

	parent.Parent.ChildAdded:Connect(function(child)
		task.defer(function()
			if child.Name == "DungeonInterface" then
				task.defer(function()
					toggleQuest(false)
				end)
			end
		end)
	end)
	parent:WaitForChild("Guide"):WaitForChild("Close").Activated:Connect(function()
		toggleGuide(false)
	end)
	parent:WaitForChild("Guide"):WaitForChild("LeftFrame"):WaitForChild("Abandon").Activated:Connect(function()
		toggleQuest(false)
		remotes.CommF_:InvokeServer("AbandonQuest")
	end)
	parent:WaitForChild("Guide"):WaitForChild("LeftFrame"):WaitForChild("Track").Activated:Connect(function()
		toggleTracking(not GuideModule.Data.Tracking)
	end)
	local Events = require(script.Events)
	updateEventTrackers = Events(toggleTracking, function()
		return v
	end, function()
		return flag
	end).updateEventTrackers
	UI.Visible = false

	if parent.Parent:FindFirstChild("DungeonInterface") then
		SideCompass.hide()
	else
		SideCompass.show()
	end

	task.defer(function()
		while not Map.IsInitialized do
			task.wait()
		end

		assert(Map.IsInitialized, "bad map controller")
		task.wait(3)

		while true do
			local humanoid = data.getHumanoid()
			local character = data.getCharacter()
			local humanoidRootPart = GuideModule.Data.Ready and humanoid and humanoid.Health > 0 and character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart then
				-- equivalent calls inferred from this helper; original call sites unknown
				local v3 = humanoidRootPart

				local function updateMeters(vector: Vector3)
					local lastMeters = math.floor((vector - v3.Position).Magnitude / 10)
					GuideModule.Data.LastMeters = lastMeters
					local subtitle2 = UI.TopFrame.Subtitle2
					local text = lastMeters > 9999 and "Over 9999m away.." or lastMeters <= 9999 and lastMeters > 8 and lastMeters .. "m away" or "Nearby!"

					if subtitle2.Text ~= text then
						subtitle2.Text = text
					end
				end

				local nearestNPC = GuideModule:GetNearestNPC(humanoidRootPart.Position, p.Value)
				local v4 = nearestNPC[1]
				local v5 = nearestNPC[2]
				local text2 = nearestNPC[3]
				local v7 = nearestNPC[5]
				local navigationTarget = Map:GetNavigationTarget()

				if flag or navigationTarget then
					if navigationTarget then
						updateMeters(navigationTarget.World.Position) -- equivalent call inferred; original call site unknown

						if toggleTracking then
							toggleTracking(true)
						end

						GuideModule:PointCompass(navigationTarget.World.Position)
					else
						GuideModule:PointCompass(v4, v5)
					end
				elseif v4 then
					updateMeters(GuideModule:GetDistance(v4)) -- equivalent call inferred; original call site unknown
					GuideModule:PointCompass(v4, v5)
					local currentMap = Map2.findCurrentMap()

					if currentMap then
						local closestIsland = Map2.findClosestIsland(currentMap, v4)

						if closestIsland then
							Map:SetRecommendation(closestIsland)
						else
							Map:SetRecommendation(nil)
						end
					else
						Map:SetRecommendation(nil)
					end

					if v7 then
						if v7 == 1 then
							local subtitle1 = UI.TopFrame.Subtitle1

							if subtitle1.Text ~= "Capture the <Frozen Heart> using a harpoon!" then
								subtitle1.Text = "Capture the <Frozen Heart> using a harpoon!"
							end
						elseif v7 == 2 then
							local subtitle1 = UI.TopFrame.Subtitle1

							if subtitle1.Text ~= "Deliver the <Frozen Heart> to Tiki Outpost." then
								subtitle1.Text = "Deliver the <Frozen Heart> to Tiki Outpost."
							end
						end

						local uIGradient = iconFrame.UIStroke.UIGradient
						local colorSequence = ColorSequence.new(Color3.fromRGB(255, 197, 20))

						if uIGradient.Color ~= colorSequence then
							uIGradient.Color = colorSequence
						end
					elseif text2 then
						if typeof(text2) == "string" then
							local subtitle1 = UI.TopFrame.Subtitle1

							if subtitle1.Text ~= text2 then
								subtitle1.Text = text2
							end
						else
							local subtitle1 = UI.TopFrame.Subtitle1
							local text = "Find the NPC at " .. text2.Name .. "."

							if subtitle1.Text ~= text then
								subtitle1.Text = text
							end
						end
					else
						local subtitle1 = UI.TopFrame.Subtitle1
						local text = "Find the " .. v5 .. "."

						if subtitle1.Text ~= text then
							subtitle1.Text = text
						end

						local uIGradient = iconFrame.UIStroke.UIGradient
						local colorSequence = ColorSequence.new(Color3.fromRGB(255, 197, 20))

						if uIGradient.Color ~= colorSequence then
							uIGradient.Color = colorSequence
						end
					end
				else
					GuideModule:PointCompass()
					local subtitle1 = UI.TopFrame.Subtitle1

					if subtitle1.Text ~= "(None)" then
						subtitle1.Text = "(None)"
					end

					local subtitle2 = UI.TopFrame.Subtitle2

					if subtitle2.Text ~= "-" then
						subtitle2.Text = "-"
					end

					local uIGradient = iconFrame.UIStroke.UIGradient
					local colorSequence = ColorSequence.new(Color3.fromRGB(255, 197, 20))

					if uIGradient.Color ~= colorSequence then
						uIGradient.Color = colorSequence
					end
				end
			end

			if UserInputService.GamepadEnabled or not UserInputService.MouseEnabled then
				pcall(function()
					parent.Parent.Smokescreen:Destroy()
					remotes.CommF_:InvokeServer("NoSmoke2")
				end)
			end

			parent.BottomHUDList:FindFirstChild("FreshieNotify")
			data.getHumanoid()
			data.getCharacter()
			task.wait(0.2)
		end
	end)
end