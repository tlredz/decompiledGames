local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConcertAnnouncementController = {}
ConcertAnnouncementController.__index = ConcertAnnouncementController
local v = {}

function ConcertAnnouncementController.new()
	local object = setmetatable({}, ConcertAnnouncementController)
	object._activeNotifications = {}
	task.spawn(function()
		object._notifTemplate = ReplicatedStorage:WaitForChild("NotificationFrame", 5)
	end)
	return object
end

function ConcertAnnouncementController:showText(p: string)
	self:_showAnnouncement("X3ll3n", p, "rgb(85,170,255)", nil, 32468810)
end

function ConcertAnnouncementController:showFlyText(p: string)
	self:_showAnnouncement("Fly", p, "rgb(85,170,255)", "rbxassetid://1566392131")
end

function ConcertAnnouncementController:showLuckyText(p: string)
	self:_showAnnouncement("LuckyMatg", p, "rgb(85,170,255)", nil, 175193570)
end

function ConcertAnnouncementController:showLokiText(p: string)
	self:_showAnnouncement("Secret_Lokii", p, "rgb(85,170,255)", nil, 3845375404)
end

function ConcertAnnouncementController:_showAnnouncement(p: string, p2: string, p3: string, image: string?, value: number?)
	if not p2 or p2 == "" then
		return
	end

	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui") or localPlayer:WaitForChild("PlayerGui", 2)

	if not playerGui then
		return
	end

	local _notifTemplate = self._notifTemplate

	if not _notifTemplate then
		_notifTemplate = ReplicatedStorage:FindFirstChild("NotificationFrame")

		if _notifTemplate then
			self._notifTemplate = _notifTemplate
		end
	end

	if not _notifTemplate then
		warn("[ConcertAnnouncementController] showFakeAnnouncement: NotificationFrame template missing")
		return
	end

	local clone = _notifTemplate:Clone()
	clone.ZIndex = 100
	local avatar = clone:FindFirstChild("Avatar")

	if avatar and avatar:IsA("ImageLabel") then
		avatar.ZIndex = 101

		if image then
			avatar.Image = image
		else
			local v2 = value or 32468810
			local image2 = v[v2]

			if image2 then
				avatar.Image = image2
			else
				task.spawn(function()
					local success, result = pcall(function()
						return Players:GetUserThumbnailAsync(
							v2,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size100x100
						)
					end)

					if success and result then
						v[v2] = result

						if avatar and avatar.Parent then
							avatar.Image = result
						end
					end
				end)
			end
		end

		avatar.ImageColor3 = Color3.new(1, 1, 1)
	end

	local text = clone:FindFirstChild("Text")

	if text and text:IsA("TextLabel") then
		text.ZIndex = 101
		text.RichText = true
		text.Text = "<font color=\"" .. p3 .. "\"><b>" .. p .. "</b></font> : " .. p2
	end

	local visuals = {}
	local gradients = {}

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("UIStroke") then
			table.insert(visuals, {
				obj = descendant,
				prop = "Transparency"
			})
		elseif descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
			table.insert(visuals, {
				obj = descendant,
				prop = "TextTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(visuals, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
			table.insert(visuals, {
				obj = descendant,
				prop = "ImageTransparency"
			})

			if descendant.BackgroundTransparency < 1 then
				table.insert(visuals, {
					obj = descendant,
					prop = "BackgroundTransparency"
				})
			end
		elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
			table.insert(visuals, {
				obj = descendant,
				prop = "BackgroundTransparency"
			})
		end

		if descendant:IsA("UIGradient") then
			table.insert(gradients, {
				obj = descendant,
				original = descendant.Transparency
			})
		end
	end

	if clone:IsA("Frame") and clone.BackgroundTransparency < 1 then
		table.insert(visuals, {
			obj = clone,
			prop = "BackgroundTransparency"
		})
	end

	local v4 = {}

	for i, v5 in ipairs(visuals) do
		v4[i] = v5.obj[v5.prop]
		v5.obj[v5.prop] = 1
	end

	local numberSequence = NumberSequence.new(1)

	for _, v5 in ipairs(gradients) do
		v5.obj.Transparency = numberSequence
	end

	local adminAnnounce = playerGui:FindFirstChild("AdminAnnounce")
	local mainFrame = adminAnnounce and adminAnnounce:FindFirstChild("MainFrame")
	local screenGui = nil

	if mainFrame then
		clone.Parent = mainFrame
	else
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "FakeAnnounceConcert"
		screenGui.IgnoreGuiInset = true
		screenGui.ResetOnSpawn = false
		screenGui.DisplayOrder = 110
		screenGui.Parent = playerGui
		clone.Parent = screenGui
	end

	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://98797174600699"
	sound.Volume = 0.4
	sound.Parent = localPlayer
	sound:Play()
	task.delay(5, function()
		if sound and sound.Parent then
			sound:Destroy()
		end
	end)
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	for i, v5 in ipairs(visuals) do
		TweenService:Create(v5.obj, tweenInfo, {
			[v5.prop] = v4[i]
		}):Play()
	end

	for _, v5 in ipairs(gradients) do
		v5.obj.Transparency = v5.original
	end

	table.insert(self._activeNotifications, {
		notif = clone,
		fallbackSg = screenGui,
		visuals = visuals,
		gradients = gradients,
		HIDDEN_SEQ = numberSequence,
		FADE_OUT_TIME = 0.5
	})
	task.delay(3.5, function()
		if not clone.Parent then
			return
		end

		local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

		for _, v6 in ipairs(visuals) do
			if v6.obj and v6.obj.Parent then
				TweenService:Create(v6.obj, tweenInfo2, {
					[v6.prop] = 1
				}):Play()
			end
		end

		for _, v6 in ipairs(gradients) do
			if v6.obj and v6.obj.Parent then
				v6.obj.Transparency = numberSequence
			end
		end

		task.delay(0.5, function()
			if clone and clone.Parent then
				clone:Destroy()
			end

			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end

			for i, _activeNotification in ipairs(self._activeNotifications) do
				if _activeNotification.notif ~= clone then
					continue
				end

				table.remove(self._activeNotifications, i)
				break
			end
		end)
	end)
end

function ConcertAnnouncementController:destroy()
	for _, _activeNotification in ipairs(self._activeNotifications) do
		if _activeNotification.notif and _activeNotification.notif.Parent then
			_activeNotification.notif:Destroy()
		end

		if _activeNotification.fallbackSg and _activeNotification.fallbackSg.Parent then
			_activeNotification.fallbackSg:Destroy()
		end
	end

	table.clear(self._activeNotifications)
end

return ConcertAnnouncementController