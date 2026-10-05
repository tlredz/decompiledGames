local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
require(ReplicatedStorage.SharedData.Achievements)
local Titles = require(ReplicatedStorage.SharedData.Titles)
local Network = require(ReplicatedStorage.SharedUtils.Network)
local DisplayMessage = require(ReplicatedStorage.Modules.DisplayMessage)
return function(object)
	local page = object:FindPage("Titles")
	local margin = page and page:FindFirstChild("Margin")

	if not margin then
		warn("COULD NOT FIND MARGGIN IN TITLE PAGE")
		return
	end

	local scrollingFrame = margin:FindFirstChild("ScrollingFrame")
	local titleTemplate = scrollingFrame and scrollingFrame:FindFirstChild("TitleTemplate")

	if not titleTemplate then
		warn("COULD NOT FIND MEDAL TEMPLATE")
		return
	end

	titleTemplate.Parent = nil
	local noOp = margin:WaitForChild("NoOp")
	noOp.Visible = true

	local function refreshEmptyState()
		for _, frame in ipairs(scrollingFrame:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			noOp.Visible = false
			return
		end

		noOp.Visible = true
	end

	local function createList(object2)
		local function addTitle(name, _)
			local title = Titles[name]

			if not title then
				print("NO DATA FOUND FOR TITLE ID: " .. tostring(name))
				return
			end

			local clone = titleTemplate:Clone()
			object:BindButton(clone:WaitForChild("TextButton"), function()
				if object.styleController:GetState(clone) == "equipped" then
					local v, v2, v3 = Network:Get("AttemptEquipTitle", "None")

					if v then
						object.styleController:SetState(clone, "unEquipped")
					elseif v2 == "TitleLocked" then
						DisplayMessage(
							string.format("You must earn 1000 ichor to change titles! %d/1000", v3),
							nil,
							nil,
							true
						)
					elseif v2 == "MustGraduate" then
						DisplayMessage("You must speak to Dandy first!", nil, nil, true)
					else
						print("Failed! " .. tostring(v2))
					end
				else
					local attemptEquipTitle, v, v2 = Network:Get("AttemptEquipTitle", name)

					if attemptEquipTitle then
						object.styleController:SetState(clone, "equipped")
					elseif v == "TitleLocked" then
						DisplayMessage(
							string.format("You must earn 1000 ichor to change titles! %d/1000", v2),
							nil,
							nil,
							true
						)
					elseif v == "MustGraduate" then
						DisplayMessage("You must speak to Dandy first!", nil, nil, true)
					else
						print("Failed! " .. tostring(v))
					end
				end
			end)
			clone.ImageLabel.Image = title.Icon or title.Image or ""
			clone.ImageShadow.Image = title.Icon or title.Image or ""
			clone.DisplayName.Text = "[" .. title.DisplayName .. "]"
			clone.Description.Text = title.Description or "N/A"
			clone.Name = name
			clone.Parent = scrollingFrame
			clone:SetAttribute("Difficulty", title.UIGradient)
			object.styleController:Apply(clone, "Shared.Journal.title")
			clone:GetAttributeChangedSignal("Hidden"):Connect(function()
				if clone:GetAttribute("Hidden") then
				end
			end)
			local v = title.LinkedAchievementID and string.match(title.LinkedAchievementID, "%d+")
			local v2 = v == nil and 0 or v
			local layoutOrder

			if string.find(string.lower(title.UIGradient), "bronze") then
				layoutOrder = v2 + 500
			elseif string.find(string.lower(title.UIGradient), "silver") then
				layoutOrder = v2 + 400
			elseif string.find(string.lower(title.UIGradient), "gold") then
				layoutOrder = v2 + 300
			elseif string.find(string.lower(title.UIGradient), "iridescent") then
				layoutOrder = v2 + 200
			else
				layoutOrder = v2 + 1000
			end

			clone.LayoutOrder = layoutOrder
			local child = clone.DisplayName:FindFirstChild(title.UIGradient)

			if child then
				child.Enabled = true
			end

			if object2.Data.EquippedTitle == name then
				object.styleController:SetState(clone, "equipped")
			end

			local connection = nil
			connection = object2:ListenToChange("Titles." .. name, function(p)
				if p == nil then
					if clone.Parent then
						clone:Destroy()
					end

					if connection then
						connection:Disconnect()
						connection = nil
					end

					refreshEmptyState()
				end
			end)
			refreshEmptyState()
		end

		for k, title in pairs(object2.Data.Titles) do
			addTitle(k, title)
		end

		refreshEmptyState()
		object2:ListenToNewKey("Titles", function(p, name)
			addTitle(name, p)
		end)
		object2:ListenToChange("EquippedTitle", function(p)
			for _, frame in ipairs(scrollingFrame:GetChildren()) do
				if not frame:IsA("Frame") then
					continue
				end

				local v = frame.Name == p and "equipped" or "unEquipped"

				if object.styleController:GetState(frame) ~= v then
					object.styleController:SetState(frame, v)
				end
			end
		end)
	end

	MyDataController:onReplicaReady(function(p)
		createList(p)
	end)
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

		for _, frame in pairs(scrollingFrame2:GetChildren()) do
			if not frame:IsA("Frame") then
				continue
			end

			local positionInParent = object.tweens.getPositionInParent(frame, scrollingFrame2)
			frame.Debug.Text = tostring(positionInParent)

			if positionInParent.Y.Scale >= 0.9 then
				frame:SetAttribute("Hidden", true)
			elseif positionInParent.Y.Scale <= -0.15 then
				frame:SetAttribute("Hidden", true)
			else
				frame:SetAttribute("Hidden", false)
			end
		end
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
end