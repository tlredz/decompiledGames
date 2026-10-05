local PopUpUI = {}
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local checkTable = require(ReplicatedStorage.Modules.UtilityAlec.checkTable)
local removeTable = require(ReplicatedStorage.Modules.UtilityAlec.removeTable)
localPlayer:GetMouse()
local background = nil
task.spawn(function()
	background = playerGui.NotificationsMenu.NotificationsMenu.NotificationsMenu.Background
end)
local layoutOrder = 100000
local texts = {}
local v2 = nil
local v3 = {
	warning = true,
	purple = true,
	blue = true,
	hungrydeer = true,
	easterwarning = true
}

function BlessingFaceAnimation(instance)
	local face = instance:WaitForChild("Face")
	local count = 0

	while instance and instance.Parent do
		count += 1
		face.Image = count % 2 == 1 and "rbxassetid://121013915628594" or "rbxassetid://137350829690183"
		task.wait(0.4)
	end
end

function TabletGrindingAnimation(parent)
	local tablet = parent:WaitForChild("Tablet")
	local bench = parent:WaitForChild("Bench")
	local position = tablet.Position
	local size = tablet.Size
	local size2 = bench.Size

	local function createParticle(position2: UDim2)
		local frame = Instance.new("Frame")
		frame.Name = "Particle"
		frame.Size = UDim2.fromOffset(10, 10)
		frame.Position = position2
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.BackgroundColor3 = Color3.fromRGB(255, 223, 100)
		frame.BorderSizePixel = 0
		frame.ZIndex = bench.ZIndex + 1
		frame.Parent = parent
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(1, 0)
		uICorner.Parent = frame
		return frame
	end

	local function burstParticles(position2: UDim2)
		for i = 1, 14 do
			local particle = createParticle(position2)
			local v4 = i / 14 * 3.141592653589793 * 2 + math.random() * 0.3
			local v5 = math.random(60, 120)
			local v6 = math.cos(v4) * v5
			local v7 = math.sin(v4) * v5 * 0.6
			local uDim = UDim2.new(
				position2.X.Scale,
				position2.X.Offset + v6,
				position2.Y.Scale,
				position2.Y.Offset + v7
			)
			local tween = TweenService:Create(
				particle,
				TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Position = uDim,
					Size = UDim2.fromOffset(4, 4),
					BackgroundTransparency = 1
				}
			)
			tween:Play()
			tween.Completed:Connect(function()
				particle:Destroy()
			end)
		end
	end

	local function playAnimation()
		tablet.Position = position
		tablet.Size = size
		tablet.ImageTransparency = 0
		tablet.Visible = true
		bench.Size = size2
		bench.ImageColor3 = Color3.new(1, 1, 1)

		for i = 1, 8 do
			tablet.Image = i % 2 == 1 and "rbxassetid://83069514677223" or "rbxassetid://78455981502332"
			local v4 = math.sin(i * 3.141592653589793) * 0.1 + 1
			TweenService:Create(
				tablet,
				TweenInfo.new(0.32000000000000006, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Size = UDim2.new(size.X.Scale * v4, 0, size.Y.Scale * v4, 0)
				}
			):Play()
			task.wait(0.4)
		end

		local tween = TweenService:Create(tablet, TweenInfo.new(0.1), {
			Size = size
		})
		tween:Play()
		tween.Completed:Wait()
		task.wait(0.3)
		local tween2 = TweenService:Create(tablet, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = bench.Position,
			Size = UDim2.new(size.X.Scale * 0.2, 0, size.Y.Scale * 0.2, 0)
		})
		tween2:Play()
		tween2.Completed:Wait()
		tablet.Visible = false
		burstParticles(bench.Position)
		local uDim = UDim2.new(size2.X.Scale * 1.3, 0, size2.Y.Scale * 1.3, 0)
		local tween3 = TweenService:Create(
			bench,
			TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Size = uDim
			}
		)
		tween3:Play()
		tween3.Completed:Wait()
		local tween4 = TweenService:Create(
			bench,
			TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				ImageColor3 = Color3.fromRGB(255, 215, 50)
			}
		)
		tween4:Play()
		tween4.Completed:Wait()
		task.wait(0.2)
		local uDim2 = UDim2.new(size2.X.Scale * 1.1, 0, size2.Y.Scale * 1.1, 0)
		TweenService:Create(bench, TweenInfo.new(0.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = uDim2
		}):Play()
		TweenService:Create(bench, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			ImageColor3 = Color3.new(1, 1, 1)
		}):Play()
		task.wait(0.6)
		TweenService:Create(bench, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = size2
		}):Play()
	end

	playAnimation()
end

function PopUpUI.AddPopUp(text, textColor, value, options)
	task.spawn(function()
		options = options or {}

		if textColor == "note" then
			if checkTable(texts, text) then
				return
			end

			table.insert(texts, text)
			task.spawn(function()
				wait(20)
				removeTable(texts, text)
			end)
			local clone = background.NoteTemplate:Clone()
			v2 = nil
			layoutOrder += 1
			clone.Name = "MessageToDestroy"
			clone.LayoutOrder = layoutOrder
			clone.TextLabel.Text = text
			clone.TextLabel.MaxVisibleGraphemes = 0
			clone.ImageLabel.ImageTransparency = 1
			clone.ImageLabel.MouseButton1Down:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
			clone.Visible = true
			clone.Parent = background
			TweenService:Create(
				clone.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 0.3
				}
			):Play()
			task.spawn(function()
				wait(0.3)

				if clone then
					local v4 = #clone.TextLabel.Text
					local clone2 = ReplicatedStorage.Core.Sounds.Typewriter:Clone()
					clone2.Parent = ReplicatedStorage.Core.Sounds

					for i = 1, v4 do
						if not (clone and clone.Parent) then
							continue
						end

						clone.TextLabel.MaxVisibleGraphemes = i
						clone2:Resume()
						local v5 = string.sub(clone.TextLabel.Text, i, i)

						if v5 == "." then
							clone2:Pause()
							task.wait(1)
						elseif v5 == "," then
							clone2:Pause()
							task.wait(0.5)
						else
							task.wait(0.03)
						end
					end

					clone2:Pause()
					wait(value or 8.5)

					if clone and clone.Parent then
						clone:Destroy()
					end

					if clone2 then
						clone2:Destroy()
					end
				end
			end)
		elseif textColor == "blessing" then
			local clone = background.BlessingAddedTemplate:Clone()
			v2 = nil
			layoutOrder += 1
			clone.Name = "MessageToDestroy"
			clone.LayoutOrder = layoutOrder
			clone.TextLabel.Text = text
			clone.TextLabel.MaxVisibleGraphemes = 0
			clone.ImageLabel.ImageTransparency = 1
			clone.ImageLabel.MouseButton1Down:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
			clone.Visible = true
			clone.Parent = background
			TweenService:Create(clone.Face, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(
				clone.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 0.3
				}
			):Play()
			task.spawn(function()
				BlessingFaceAnimation(clone)
			end)
			task.spawn(function()
				wait(0.3)

				if clone then
					local v4 = #clone.TextLabel.Text
					local clone2 = ReplicatedStorage.Core.Sounds.Typewriter:Clone()
					clone2.Parent = ReplicatedStorage.Core.Sounds

					for i = 1, v4 do
						if not (clone and clone.Parent) then
							continue
						end

						clone.TextLabel.MaxVisibleGraphemes = i
						clone2:Resume()
						local v5 = string.sub(clone.TextLabel.Text, i, i)

						if v5 == "." then
							clone2:Pause()
							task.wait(1)
						elseif v5 == "," then
							clone2:Pause()
							task.wait(0.5)
						else
							task.wait(0.03)
						end
					end

					clone2:Pause()
					wait(value or 8.5)

					if clone and clone.Parent then
						clone:Destroy()
					end

					if clone2 then
						clone2:Destroy()
					end
				end
			end)
		elseif textColor == "craftingbenchupgrade" then
			local clone = background.CraftingBenchUpgradeTemplate:Clone()
			v2 = nil
			layoutOrder += 1
			clone.Name = "MessageToDestroy"
			clone.LayoutOrder = layoutOrder
			clone.TextLabel.Text = text
			clone.TextLabel.MaxVisibleGraphemes = 0
			clone.ImageLabel.ImageTransparency = 1
			clone.ImageLabel.MouseButton1Down:Connect(function()
				if clone then
					clone:Destroy()
				end
			end)
			clone.Visible = true
			clone.Parent = background
			TweenService:Create(clone.Tablet, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(clone.Bench, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(
				clone.ImageLabel,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 0.3
				}
			):Play()
			task.spawn(function()
				TabletGrindingAnimation(clone)
			end)
			task.spawn(function()
				wait(0.3)

				if clone then
					local v4 = #clone.TextLabel.Text
					local clone2 = ReplicatedStorage.Core.Sounds.Typewriter:Clone()
					clone2.Parent = ReplicatedStorage.Core.Sounds

					for i = 1, v4 do
						if not (clone and clone.Parent) then
							continue
						end

						clone.TextLabel.MaxVisibleGraphemes = i
						clone2:Resume()
						local v5 = string.sub(clone.TextLabel.Text, i, i)

						if v5 == "." then
							clone2:Pause()
							task.wait(1)
						elseif v5 == "," then
							clone2:Pause()
							task.wait(0.5)
						else
							task.wait(0.03)
						end
					end

					clone2:Pause()
					wait(value or 8.5)

					if clone and clone.Parent then
						clone:Destroy()
					end

					if clone2 then
						clone2:Destroy()
					end
				end
			end)
		elseif v2 and v2.Parent and v2:GetAttribute("PopUpMessage") == text and v2:GetAttribute("PopUpType") == (textColor or "") then
			local v4 = (v2:GetAttribute("PopUpCount") or 1) + 1
			v2:SetAttribute("PopUpCount", v4)
			v2.TextLabel.Text = (v2:GetAttribute("PopUpRendered") or text) .. " (x" .. v4 .. ")"
			v2:SetAttribute("PopUpExpireAt", os.clock() + (value or 6.5))

			if v3[textColor] then
				Client.Sound.Play("Error")
			end
		else
			local clone = background.Template:Clone()
			clone.Name = "MessageToDestroy"
			clone.TextLabel.Text = text

			if textColor and textColor == "warning" then
				Client.Sound.Play("Error")
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 12, 0)
			elseif textColor and textColor == "night" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(72, 48, 120)
			elseif textColor and textColor == "yellow" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 217, 0)
			elseif textColor and textColor == "purple" then
				Client.Sound.Play("Error")
				clone.TextLabel.TextColor3 = Color3.fromRGB(102, 0, 255)
			elseif textColor and textColor == "green" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(0, 217, 0)
			elseif textColor and textColor == "diamond" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(0, 199, 217)
			elseif textColor and textColor == "alien" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(37, 134, 22)
			elseif textColor and textColor == "blue" then
				Client.Sound.Play("Error")
				clone.TextLabel.TextColor3 = Color3.fromRGB(47, 160, 212)
			elseif textColor and textColor == "orange" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 115, 0)
			elseif textColor and textColor == "fairybiome" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(26, 255, 160)
			elseif textColor and textColor == "hungrydeer" then
				Client.Sound.Play("Error")
				clone.TextLabel.TextColor3 = Color3.fromRGB(170, 85, 255)
			elseif textColor and textColor == "valentines" then
				clone.TextLabel.TextColor3 = Color3.fromRGB(255, 85, 255)
			elseif textColor and (textColor == "elf" or textColor == "halloween") then
				local text2 = clone.TextLabel.Text
				local text3 = ""
				local v5, v6

				if textColor == "halloween" then
					v5 = "rgb(235, 110, 0)"
					v6 = "rgb(255, 160, 40)"
				else
					v5 = "rgb(51, 170, 33)"
					v6 = "rgb(255,69,72)"
				end

				local count = 0

				for i = 1, #text2 do
					local v7 = text2:sub(i, i)

					if v7 == " " then
						text3 ..= " "
					else
						text3 ..= "<font color=\"" .. (count % 2 == 0 and v6 or v5) .. "\">" .. v7 .. "</font>"
						count += 1
					end
				end

				clone.TextLabel.RichText = true
				clone.TextLabel.Text = text3
			elseif textColor and (textColor == "easter" or textColor == "easterwarning" or textColor == "easterbunny") then
				local text2 = clone.TextLabel.Text
				local text3 = ""

				if textColor == "easterwarning" then
					Client.Sound.Play("Error")
				end

				local count = 0

				for i = 1, #text2 do
					local v5 = text2:sub(i, i)

					if v5 == " " then
						text3 ..= " "
					else
						text3 ..= "<font color=\"" .. (count % 2 == 0 and "rgb(251, 125, 255)" or "rgb(252, 156, 255)") .. "\">" .. v5 .. "</font>"
						count += 1
					end
				end

				clone.TextLabel.RichText = true
				clone.TextLabel.Text = text3
			elseif typeof(textColor) == "Color3" then
				clone.TextLabel.TextColor3 = textColor
			end

			clone.Visible = true
			clone.Parent = background
			v2 = clone
			clone:SetAttribute("PopUpMessage", text)
			clone:SetAttribute("PopUpType", textColor or "")
			clone:SetAttribute("PopUpRendered", clone.TextLabel.Text)
			clone:SetAttribute("PopUpCount", 1)
			clone:SetAttribute("PopUpExpireAt", os.clock() + (value or 6.5))

			while clone and clone.Parent do
				local v4 = (clone:GetAttribute("PopUpExpireAt") or 0) - os.clock()

				if v4 <= 0 then
					break
				else
					task.wait(v4)
				end
			end

			if v2 == clone then
				v2 = nil
			end

			if clone then
				clone:Destroy()
			end
		end
	end)
end

function PopUpUI.AddSmallPopUp(text, p, value)
	task.spawn(function()
		local background2 = playerGui.NotificationsMenu.SmallNotifs.SmallNotifs.Background
		local clone = background2.Template:Clone()
		clone.Name = "MessageToDestroy"
		clone.TextLabel.Text = text
		clone.TextLabel.TextColor3 = p or Color3.fromRGB(255, 255, 255)
		clone.Visible = true
		clone.Parent = background2
		wait(value or 4.85)

		if clone then
			clone:Destroy()
		end
	end)
end

Client.Events.PromptReviveFriend:Connect(function(p)
	PopUpUI.BottomRightNotification({
		Title = "REVIVE " .. p.DisplayName .. "?",
		Text = "80 Robux",
		Duration = 10,
		Button1 = "BUY",
		Callback = function()
			print("ATTEMPT REVIVE " .. p.DisplayName)
		end
	})
end)

function PopUpUI.BottomRightNotification(p)
	local success, result = pcall(function()
		StarterGui:SetCore("SendNotification", p)
	end)

	if not success then
		warn("Failed to create notification:", result)
		wait(1)
		StarterGui:SetCore("SendNotification", p)
	end
end

Client.Events.SetPopUpMessage:Connect(function(...)
	PopUpUI.AddPopUp(...)
end)
Client.Events.SetSmallPopUpMessage:Connect(function(...)
	PopUpUI.AddSmallPopUp(...)
end)

function FormatHighlightedText(value, value2, data)
	if not value2 then
		return value
	end

	local v4 = string.lower(value)
	local v5 = string.lower(value2)
	local v6, v7 = string.find(v4, v5, 1, true)

	if not v6 then
		return value
	end

	print("FOUND START POS")
	local v8 = string.sub(value, v6, v7)
	local v9 = string.sub(value, 1, v6 - 1)
	local v10 = string.sub(value, v7 + 1)
	local v11 = math.floor(data.R * 255)
	local v12 = math.floor(data.G * 255)
	local v13 = math.floor(data.B * 255)
	return v9 .. "<font color=\"" .. string.format("#%02X%02X%02X", v11, v12, v13) .. "\">[" .. v8 .. "]</font>" .. v10
end

function PopUpUI.AddAdminAbuseMessage(p, p2, p3, value, value2)
	local text = FormatHighlightedText(p, p2, p3)
	local template = Client.Interface.AdminMessages.Template

	if not template then
		return
	end

	for _ = 1, value2 or 1 do
		task.spawn(function()
			local clone = template:Clone()
			clone.Name = "Msg"
			clone.TextLabel.Text = text
			clone.BackgroundTransparency = 1
			clone.Visible = true
			clone.Parent = template.Parent
			TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
				BackgroundTransparency = 0.25
			}):Play()
			Client.Sound.Play("AdminReward", {
				Duplicate = true
			})
			Client.Sound.Play("AdminRewardSmall", {
				Duplicate = true
			})
			task.spawn(function()
				wait(0.65)

				if clone then
					TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
						BackgroundTransparency = 1
					}):Play()
				end

				wait(value or 9)

				if clone then
					clone:Destroy()
				end
			end)
		end)
		wait(0.1)
	end
end

Client.Events.AdminAbuseMessage:Connect(function(...)
	PopUpUI.AddAdminAbuseMessage(...)
end)

function PopUpUI.Init()
	task.spawn(function() end)
end

return PopUpUI