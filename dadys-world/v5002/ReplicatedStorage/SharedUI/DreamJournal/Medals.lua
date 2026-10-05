local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
local Achievements = require(ReplicatedStorage.SharedData.Achievements)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
return function(object)
	local page = object:FindPage("Medals")
	local margin = page and page:FindFirstChild("Margin")
	object.styleController:Apply(margin.Details.ProgressFrame, "Shared.Journal.progressFrame")

	if not margin then
		warn("COULD NOT FIND MARGGIN IN MEDAL PAGE")
		return
	end

	local scrollingFrame = margin:FindFirstChild("ScrollingFrame")
	local medalTemplate = scrollingFrame and scrollingFrame:FindFirstChild("MedalTemplate")

	if not medalTemplate then
		warn("COULD NOT FIND MEDAL TEMPLATE")
		return
	end

	medalTemplate.Parent = nil
	local details = margin:WaitForChild("Details")
	local noOp = margin:WaitForChild("NoOp")
	object.styleController:Apply(details, "Shared.Journal.medalDetails")
	local scrollingFrame2 = page.Margin:WaitForChild("ScrollingFrame")
	local thumb = page.Margin:WaitForChild("Scrolling"):WaitForChild("Thumb")
	local uIDragDetector = thumb.UIDragDetector
	local v = 1 - thumb.Size.Y.Scale
	scrollingFrame2.Changed:Connect(function()
		thumb.Position = UDim2.new(
			thumb.Position.X.Scale,
			0,
			scrollingFrame2.CanvasPosition.Y / (scrollingFrame2.AbsoluteCanvasSize.Y - scrollingFrame2.AbsoluteWindowSize.Y) * v,
			0
		)
	end)
	uIDragDetector.DragContinue:Connect(function()
		local v2 = thumb.Position.Y.Scale / v
		local v3 = scrollingFrame2.AbsoluteCanvasSize.Y - scrollingFrame2.AbsoluteWindowSize.Y
		scrollingFrame2.CanvasPosition = Vector2.new(0, v3 * v2)
	end)
	uIDragDetector.DragStart:Connect(function()
		object.tweens.playTween(thumb.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
			Scale = 1.15
		})
	end)
	uIDragDetector.DragEnd:Connect(function()
		object.tweens.playTween(thumb.UIScale, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
			Scale = 1
		})
	end)

	local function createGrid(object2)
		local instances = {}

		local function updateRedeemableCount(instance)
			local index = table.find(instances, instance)

			if instance:GetAttribute("CanRedeem") == true and instance:GetAttribute("Redeemed") == false then
				if not index then
					table.insert(instances, instance)
				end
			elseif index then
				table.remove(instances, index)
			end

			object:SetRedeemableCount(#instances)
		end

		local clones = {}

		for k, v2 in pairs(Achievements.All.Standard) do
			if v2.Hidden then
				continue
			end

			if v2.Category == "Holiday" and (not HolidayEventConfig.ENABLED or v2.Holiday ~= HolidayEventConfig.ContentFlag) and (MyDataController:getDataFromPath((string.format(
				"DreamJournal.Achievements.%s.Progress",
				k
			))) or 0) < v2.Requirement then
				continue
			end

			local clone = medalTemplate:Clone()
			clones[k] = clone
			object.styleController:Apply(clone, "Shared.Journal.medals")
			local imageLabel = clone.ImageLabel
			local imageLabel_2 = imageLabel:WaitForChild("ImageLabel")
			imageLabel_2.Image = v2.Icon
			local imageShadow = imageLabel:WaitForChild("ImageShadow")
			imageShadow.Image = v2.Icon
			local progressShadow = imageLabel:WaitForChild("ProgressShadow")
			progressShadow.Image = v2.Icon
			local progressHint = imageLabel:WaitForChild("ProgressHint")
			progressHint.Image = v2.Icon
			local displayName = clone:WaitForChild("DisplayName")
			displayName.Text = v2.Name
			clone.ImageButton.ImageTransparency = 0.95
			local v3 = k
			object:BindButton(clone.ImageButton, function()
				page:SetAttribute("PreviewID", v3)

				for k2, v4 in pairs(clones) do
					v4:SetAttribute("Selected", k2 == v3)
				end
			end)
			clone:SetAttribute("NumericIndex", v2.NumericIndex)
			clone.LayoutOrder = v2.NumericIndex + 100 or 100
			clone:SetAttribute("AchievementID", k)
			local v4 = string.format("DreamJournal.Achievements.%s.Progress", k)
			local v5 = string.format("DreamJournal.Achievements.%s.Redeemed", k)
			local v7 = v2

			local function update_progress()
				local v9 = MyDataController:getDataFromPath(v4) or 0
				local requirement = v7.Requirement or 0
				local v10 = math.clamp((requirement > 0 and v9 / requirement or 0) * 100, 0, 100)
				local v11 = v10 // 1 == 99 and 99 or v10
				clone:SetAttribute(
					"Progress",
					v7.DisplayType == Achievements.Enums.DISPLAYTYPES.CHECKBOX and v11 < 100 and 0 or v11
				)
			end

			local v9 = clone
			local v11 = v2
			clone:GetAttributeChangedSignal("Progress"):Connect(function()
				local progress = v9:GetAttribute("Progress") or 0
				local progress_2 = v9:WaitForChild("Progress")
				progress_2.Size = UDim2.fromScale(1, progress / 100)
				v9:SetAttribute("CanRedeem", progress == 100)
				imageLabel.ProgressShadow.ImageColor3 = progress > 0 and Color3.fromRGB(106, 106, 106) or Color3.fromRGB(
					43,
					43,
					43
				)
				local uIGradient = imageLabel.ProgressShadow:WaitForChild("UIGradient")
				uIGradient.Offset = Vector2.new(0, 1 - progress / 100)
				imageLabel.ProgressHint.UIGradient.Offset = Vector2.new(0, 1 - progress / 100)
				imageLabel.ImageLabel.UIGradient.Offset = Vector2.new(0, 1 - progress / 100)
				imageLabel.ImageShadow.UIGradient.Offset = Vector2.new(0, 1 - progress / 100)
				v9.LayoutOrder = progress == 100 and v11.NumericIndex or v9.LayoutOrder
				updateRedeemableCount(v9)
			end)
			-- equivalent calls inferred from this helper; original call sites unknown
			local v13 = clone

			local function update_redeemed()
				v13:SetAttribute("Redeemed", MyDataController:getDataFromPath(v5) ~= nil)
				updateRedeemableCount(v13)
			end

			local update_progress2 = update_progress
			object2:ListenToChange(v4, function(p)
				update_progress2()
			end)
			update_progress()
			local v14 = v5
			local v15 = clone
			object2:ListenToChange(v5, function(p)
				update_redeemed() -- equivalent call inferred; original call site unknown
			end)
			clone:SetAttribute("Redeemed", MyDataController:getDataFromPath(v5) ~= nil)
			updateRedeemableCount(clone)
			local v16 = clone

			local function updateOrder(clone2)
				local achievementID = clone2:GetAttribute("AchievementID")
				local v17 = Achievements.All.Standard[achievementID]
				local numericIndex = v17.NumericIndex + 100 or 100
				clone2.LayoutOrder = numericIndex

				if (clone2:GetAttribute("Progress") or 0) == 100 then
					numericIndex = v17.NumericIndex or numericIndex
				end

				local data = MyDataController:getDataFromPath((string.format(
					"DreamJournal.Achievements.%s.Pinned",
					achievementID
				)))
				local v19 = data ~= nil

				if v19 then
					numericIndex = -tonumber(data)
				end

				v16:SetAttribute("Pinned", v19)

				if page:GetAttribute("PreviewID") == achievementID then
					page:SetAttribute("Pinned", v19)
				end

				clone2.LayoutOrder = numericIndex
			end

			updateOrder(clone)
			local updateOrder2 = updateOrder
			local v17 = clone
			object2:ListenToChange(string.format("DreamJournal.Achievements.%s.Pinned", k), function(p)
				updateOrder2(v17)
			end)
			clone.Parent = scrollingFrame
		end
	end

	local connection = nil

	local function updatePreviewWindow(object2)
		local previewID = page:GetAttribute("PreviewID")
		local v2 = previewID and Achievements.All.Standard[previewID]

		if v2 then
			noOp.Visible = false

			if connection then
				connection:Disconnect()
			end

			local v3 = string.format("DreamJournal.Achievements.%s.Progress", previewID)

			local function update()
				local v4 = MyDataController:getDataFromPath(v3) or 0
				local requirement = v2.Requirement or 0
				local v5 = math.clamp((not (requirement > 0) and 0 or v4 / requirement or 0) * 100, 0, 100)
				local v6 = v5 // 1 == 99 and 99 or v5
				local v7 = v2.DisplayType == Achievements.Enums.DISPLAYTYPES.CHECKBOX and v6 < 100 and 0 or v6
				details.ProgressFrame:SetAttribute("Progress", v7)
				local text = v2.TextFormat and v2.TextFormat(v4 // 1) or tonumber(v4) and string.format(
					"%d",
					(tonumber(v4))
				) or ""

				if v2.DisplayType == Achievements.Enums.DISPLAYTYPES.CHECKBOX then
					text = v7 >= 100 and "Completed" or "Not Completed"
				end

				local textLabel = details.ProgressFrame.TextLabel

				if text == "" or not text then
					text = math.ceil(v7) .. "%"
				end

				textLabel.Text = text
				local imageLabel = details.ImageLabel
				local imageLabel_2 = imageLabel:WaitForChild("ImageLabel")
				imageLabel_2.Image = v2.Icon
				local imageShadow = imageLabel:WaitForChild("ImageShadow")
				imageShadow.Image = v2.Icon
				local progressShadow = imageLabel:WaitForChild("ProgressShadow")
				progressShadow.Image = v2.Icon
				local progressHint = imageLabel:WaitForChild("ProgressHint")
				progressHint.Image = v2.Icon
				local uIGradient = imageLabel.ProgressShadow:WaitForChild("UIGradient")
				uIGradient.Offset = Vector2.new(0, 1 - v7 / 100)
				imageLabel.ProgressShadow.ImageColor3 = v7 > 0 and Color3.fromRGB(106, 106, 106) or Color3.fromRGB(
					43,
					43,
					43
				)
				details.Description.Text = v2.Description
				details.Difficulty.Text = v2.Difficulty
				details.DisplayName.Text = v2.Name
				details.KeyIndex.Text = string.format("Medal No.%d", v2.MedalNumber or v2.NumericIndex)
				details.Type.Text = v2.CategoryDisplayName or "N/A"
				page:SetAttribute(
					"Redeemed",
					MyDataController:getDataFromPath((string.format("DreamJournal.Achievements.%s.Redeemed", previewID))) ~= nil
				)
				page:SetAttribute("CanRedeem", v7 == 100)
				page:SetAttribute(
					"Pinned",
					MyDataController:getDataFromPath((string.format("DreamJournal.Achievements.%s.Pinned", previewID))) ~= nil
				)
			end

			connection = object2:ListenToChange(v3, update)
			update()
			details.Visible = true
		else
			details.Visible = false
			noOp.Visible = true
		end
	end

	MyDataController:onReplicaReady(function(p)
		createGrid(p)
		page:GetAttributeChangedSignal("PreviewID"):Connect(function()
			updatePreviewWindow(p)
		end)
		updatePreviewWindow(p)
		local previewID = nil
		page:GetPropertyChangedSignal("Visible"):Connect(function()
			if page.Visible then
				page:SetAttribute("PreviewID", previewID)
				return
			end

			previewID = page:GetAttribute("PreviewID")
			page:SetAttribute("PreviewID", nil)
		end)
		object:BindButton(details:WaitForChild("TextButton"), function()
			local previewID2 = page:GetAttribute("PreviewID")

			if not (previewID2 and Achievements.All.Standard[previewID2]) then
				return
			end

			if MyDataController:getDataFromPath((string.format("DreamJournal.Achievements.%s.Redeemed", previewID2))) ~= nil then
				print("You have already redeemed this medal!")
				page:SetAttribute("Redeemed", true)
			else
				local attemptRedeemAchievement, v3 = Network:Get("AttemptRedeemAchievement", previewID2)

				if attemptRedeemAchievement then
					print("Success!")
					page:SetAttribute("Redeemed", true)
				else
					print("Failed! " .. tostring(v3))
					page:SetAttribute("Redeemed", false)
				end
			end
		end)
		object:BindButton(details:WaitForChild("Pinned"), function()
			Network:Post("TogglePinTitle", page:GetAttribute("PreviewID"))
		end)
	end)
end