local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local v = {}
local FakeAdminMessageUtil = {}

function FakeAdminMessageUtil.preload(items)
	for _, item in items do
		if v[item] then
			continue
		end

		local v2 = item
		task.spawn(function()
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(v2, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)

			if success and result then
				v[v2] = result
			end
		end)
	end
end

function FakeAdminMessageUtil.show(data)
	local playerGui = Players.LocalPlayer.PlayerGui
	local duration = data.duration or 10
	local fadeIn = data.fadeIn or 0.4
	local fadeOut = data.fadeOut or 0.5
	local displayOrder = data.displayOrder or 999999999999999
	local nameColor = data.nameColor or "rgb(85,170,255)"
	local tintColor = data.tintColor or Color3.new(0, 0, 0)
	local notificationFrame = ReplicatedStorage:FindFirstChild("NotificationFrame")

	if not notificationFrame then
		warn("[FakeAdminMessageUtil] NotificationFrame template missing in ReplicatedStorage")
		return
	end

	local clone = notificationFrame:Clone()
	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		if data.preloadedThumb then
			avatar.Image = data.preloadedThumb
		elseif v[data.senderUserId] then
			avatar.Image = v[data.senderUserId]
		else
			local senderUserId = data.senderUserId
			task.spawn(function()
				local success, result = pcall(function()
					return Players:GetUserThumbnailAsync(
						senderUserId,
						Enum.ThumbnailType.HeadShot,
						Enum.ThumbnailSize.Size100x100
					)
				end)

				if success and result then
					v[senderUserId] = result

					if avatar.Parent then
						avatar.Image = result
					end
				end
			end)
		end

		if data.tintAvatar then
			avatar.ImageColor3 = tintColor
		end
	end

	local text = clone:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.RichText = true
		text.Text = "<font color=\"" .. nameColor .. "\"><b>" .. data.senderName .. "</b></font> : " .. data.message
	end

	local v2 = {}
	local v3 = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("UIStroke") then
			table.insert(v2, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(v2, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v2, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(v2, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(v2, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(v2, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end

		if descendant:IsA("UIGradient") then
			table.insert(v3, {
				obj = descendant,
				original = descendant.Transparency
			})
		end
	end

	if clone:IsA("Frame") and clone.BackgroundTransparency < 1 then
		table.insert(v2, {
			obj = clone,
			prop = "BackgroundTransparency"
		})
	end

	local v4 = {}

	for i, v5 in ipairs(v2) do
		v4[i] = v5.obj[v5.prop]
		v5.obj[v5.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, v5 in ipairs(v3) do
		v5.obj.Transparency = numberSequence
	end

	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")
	local screenGui = nil

	if mainFrame then
		clone.Parent = mainFrame
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "SecondAnnounce"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = displayOrder
		screenGui.Parent = playerGui
		clone.Parent = screenGui
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = playerGui
	sound:Play()
	local Debris = game:GetService("Debris")
	Debris:AddItem(sound, 5)
	local tweenInfo = TweenInfo.new(fadeIn, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, v5 in ipairs(v2) do
		TweenService:Create(v5.obj, tweenInfo, {
			[v5.prop] = v4[i]
		}):Play()
	end

	for _, v5 in ipairs(v3) do
		v5.obj.Transparency = v5.original
	end

	task.delay(duration, function()
		local tweenInfo2 = TweenInfo.new(fadeOut, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v5 in ipairs(v2) do
			TweenService:Create(v5.obj, tweenInfo2, {
				[v5.prop] = 1
			}):Play()
		end

		for _, v5 in ipairs(v3) do
			v5.obj.Transparency = numberSequence
		end

		task.delay(fadeOut, function()
			if clone and clone.Parent then
				clone:Destroy()
			end

			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end)
end

return FakeAdminMessageUtil