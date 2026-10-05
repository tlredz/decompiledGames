local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local CollectionService = game:GetService("CollectionService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local adminAnnounce = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("AdminAnnounce")
local notificationFrame = ReplicatedStorage:WaitForChild("NotificationFrame")
local v = {
	Creator = {
		Color = "#ff0000",
		Prefix = "[CREATOR]"
	},
	HeadManager = {
		Color = "#a855f7",
		Prefix = "[COO]"
	},
	Admin = {
		Color = "#1de5ff",
		Prefix = "[ADMIN]"
	},
	MarketingLead = {
		Color = "#ff8c00",
		Prefix = "[MARKETING LEAD]"
	},
	Scripter = {
		Color = "#3b82f6",
		Prefix = "[SCRIPTER]"
	},
	Builder = {
		Color = "#dd994b",
		Prefix = "[BUILDER]"
	},
	QAManager = {
		Color = "#ffa500",
		Prefix = "[QA MANAGER]"
	},
	AssistantBoard = {
		Color = "#ffffff",
		Prefix = "[ASSISTANT BOARD]"
	},
	Moderator = {
		Color = "#51b94d",
		Prefix = "[MODERATOR]"
	},
	JuniorModerator = {
		Color = "#51b94d",
		Prefix = "[MODERATOR]"
	},
	Youtuber = {
		Color = "#ff42aa",
		Prefix = "[CC]"
	}
}

local function getGradients(folder)
	local result = {}

	for _, uIGradient in ipairs(folder:GetDescendants()) do
		if uIGradient:IsA("UIGradient") then
			table.insert(result, {
				obj = uIGradient,
				original = uIGradient.Transparency
			})
		end
	end

	return result
end

local function getAllVisuals(folder)
	local result = {}

	for _, descendant in ipairs(folder:GetDescendants()) do
		if descendant:IsA("UIStroke") then
			table.insert(result, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(result, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(result, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(result, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(result, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(result, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end
	end

	if folder:IsA("Frame") and folder.BackgroundTransparency < 1 then
		table.insert(result, {
			obj = folder,
			prop = "BackgroundTransparency"
		})
	end

	return result
end

local function showAnnouncement(text, senderName, senderUserId, isOwner, adminRole, duration: number?, icon: string?)
	local adminAnnounce2 = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce2 and adminAnnounce2:FindFirstChild("MainFrame")

	if not mainFrame then
		warn("[AdminAnnounce] AdminAnnounce/MainFrame introuvable dans PlayerGui")
		return
	end

	local clone = notificationFrame:Clone()
	clone.ZIndex = 100
	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		avatar.ZIndex = 101

		if icon then
			avatar.Image = icon
		elseif senderUserId then
			local success, result = pcall(function()
				return Players:GetUserThumbnailAsync(
					senderUserId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size100x100
				)
			end)

			if success and result then
				avatar.Image = result
			end
		end
	end

	local text2 = clone:FindFirstChild("Text")

	if text2 then
		text2.ZIndex = 101
		text2.RichText = true
		local v2 = senderName or "Admin"

		if isOwner then
			v2 = v2 .. "" or v2
		end

		local v3 = adminRole and v[adminRole]

		if v3 then
			text2.Text = string.format(
				"<font color=\"%s\">%s</font> <font color=\"rgb(85,170,255)\"><b>%s</b></font> : %s",
				v3.Color,
				v3.Prefix,
				v2,
				text
			)
		else
			text2.Text = "<font color=\"rgb(85,170,255)\"><b>" .. v2 .. "</b></font> : " .. text
		end
	end

	local allVisuals = getAllVisuals(clone)
	local gradients = getGradients(clone)
	local v2 = {}

	for i, allVisual in ipairs(allVisuals) do
		v2[i] = allVisual.obj[allVisual.prop]
		allVisual.obj[allVisual.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = numberSequence
	end

	clone.Parent = mainFrame
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = playerGui
	sound:Play()
	Debris:AddItem(sound, 5)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, allVisual in ipairs(allVisuals) do
		TweenService:Create(allVisual.obj, tweenInfo, {
			[allVisual.prop] = v2[i]
		}):Play()
	end

	for _, gradient in ipairs(gradients) do
		gradient.obj.Transparency = gradient.original
	end

	task.delay(duration or 10, function()
		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, allVisual in ipairs(allVisuals) do
			TweenService:Create(allVisual.obj, tweenInfo2, {
				[allVisual.prop] = 1
			}):Play()
		end

		for _, gradient in ipairs(gradients) do
			gradient.obj.Transparency = numberSequence
		end

		task.delay(0.5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end)
	end)
end

adminAnnounce.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" or not data.text then
		return
	end

	showAnnouncement(
		data.text,
		data.senderName,
		data.senderUserId,
		data.isOwner,
		data.adminRole,
		data.Duration,
		data.icon
	)
end)
local bindableEvent = Instance.new("BindableEvent")
bindableEvent.Name = "AdminAnnounceBindable"
bindableEvent.Event:Connect(function(data)
	if type(data) ~= "table" or not data.text then
		return
	end

	showAnnouncement(
		data.text,
		data.senderName,
		data.senderUserId,
		data.isOwner,
		data.adminRole,
		data.Duration,
		data.icon
	)
end)
bindableEvent.Parent = script
CollectionService:AddTag(bindableEvent, "AdminAnnounceListener")