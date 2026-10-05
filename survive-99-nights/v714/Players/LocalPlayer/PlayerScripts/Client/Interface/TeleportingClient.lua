local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local v = {
	["Frog Cave"] = {
		Colour = Color3.fromRGB(9, 179, 0),
		Description = "Entering the Frog King's Cave",
		Image1 = "rbxassetid://131273714619407",
		Image2 = "rbxassetid://75903607813007"
	},
	Cave = {
		Colour = Color3.fromRGB(220, 220, 220),
		Description = "Entering the Cave",
		Image1 = "rbxassetid://100790176197432",
		Image2 = "rbxassetid://130430225528893"
	},
	["Alien Mothership"] = {
		Colour = Color3.fromRGB(16, 234, 0),
		Description = "Entering the Mothership",
		Image1 = "rbxassetid://131942608205583",
		Image2 = "rbxassetid://84956451910786"
	},
	["Halloween Maze"] = {
		Colour = Color3.fromRGB(222, 137, 0),
		Description = "Entering the Maze",
		Image1 = "rbxassetid://106955770654830",
		Image2 = "rbxassetid://99384603944396"
	},
	["Alien Command Ship"] = {
		Colour = Color3.fromRGB(50, 216, 0),
		Description = "Entering the Command Ship",
		Image1 = "rbxassetid://131942608205583",
		Image2 = "rbxassetid://84956451910786"
	},
	Forest = {
		Colour = Color3.fromRGB(61, 117, 45),
		Description = "Back to the Forest...",
		Image1 = "rbxassetid://94896428871747",
		Image2 = "rbxassetid://94903104147703"
	}
}

function AnimateTeleportScreen(data)
	if not data then
		return
	end

	local v2 = v[data.CoverType] or {
		Description = "",
		Image1 = "",
		Image2 = ""
	}
	local teleportingCave = localPlayer.PlayerGui:WaitForChild("TeleportingCave", 5)
	local flag = nil

	local function fadeOut()
		localPlayer:SetAttribute("PreloadLighting", nil)
		flag = false

		if teleportingCave then
			local tweenInfo = TweenInfo.new(0.5)
			TweenService:Create(teleportingCave.Frame, tweenInfo, {
				BackgroundTransparency = 1
			}):Play()
			TweenService:Create(teleportingCave.ImageLabel, tweenInfo, {
				ImageTransparency = 1
			}):Play()
			local tween = TweenService:Create(teleportingCave.TextLabel, tweenInfo, {
				TextTransparency = 1
			})
			tween:Play()
			tween.Completed:Wait()
			teleportingCave.Enabled = false
		end
	end

	if teleportingCave then
		task.spawn(function()
			local imageLabel = teleportingCave:WaitForChild("ImageLabel")
			teleportingCave.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			teleportingCave.TextLabel.Text = v2.Description or ""
			imageLabel.Image = v2.Image1 or ""
			imageLabel.ImageColor3 = v2.Colour or Color3.fromRGB(255, 255, 255)
			teleportingCave.Frame.BackgroundColor3 = data.FadeColour or Color3.fromRGB(0, 0, 0)
			teleportingCave.Frame.BackgroundTransparency = 1
			imageLabel.ImageTransparency = 1
			teleportingCave.TextLabel.TextTransparency = 1
			print("fading in text etc")
			local tweenInfo = TweenInfo.new(data.FadeDuration)

			if (data.FadeDelay or 0) > 0 then
				task.wait(data.FadeDelay)
			end

			if flag == false then
				return
			end

			teleportingCave.Enabled = true

			if data.PreloadLighting then
				localPlayer:SetAttribute("PreloadLighting", data.PreloadLighting)
				Client.Events.UpdateLighting:Fire()
			end

			TweenService:Create(teleportingCave.Frame, tweenInfo, {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(imageLabel, tweenInfo, {
				ImageTransparency = 0
			}):Play()
			TweenService:Create(teleportingCave.TextLabel, tweenInfo, {
				TextTransparency = 0.5
			}):Play()
			flag = true

			while flag do
				imageLabel.Image = v2.Image1
				task.wait(0.3)

				if not flag then
					break
				end

				imageLabel.Image = v2.Image2
				task.wait(0.3)
			end
		end)
	end

	return fadeOut
end

local TeleportingClient = {}
TeleportingClient.AnimateTeleportScreen = AnimateTeleportScreen

function TeleportingClient.Teleport(p, value, state)
	if localPlayer:GetAttribute("Teleporting") then
		return
	end

	localPlayer:SetAttribute("Teleporting", true)
	local v2 = value or 1
	print(state)

	if state and not (state.FadeDelay and state.FadeDuration) then
		local fadeDelay = state.FadeDelay or 0
		local fadeDuration = v2 - fadeDelay
		state.FadeDelay = fadeDelay
		state.FadeDuration = fadeDuration
	end

	task.spawn(function()
		local v3 = AnimateTeleportScreen(state)
		local v4 = workspace:GetServerTimeNow() + v2

		if Client.Events.RequestTeleport:InvokeServer(p, v4) then
			local total = 0

			while workspace:GetServerTimeNow() < v4 and total < 8 do
				total += task.wait()
			end

			task.wait(0.5)

			if v3 then
				v3()
			end

			localPlayer:SetAttribute("Teleporting", nil)
		else
			if v3 then
				v3()
			end

			localPlayer:SetAttribute("Teleporting", nil)
		end
	end)
end

function TeleportingClient.Init() end

return TeleportingClient