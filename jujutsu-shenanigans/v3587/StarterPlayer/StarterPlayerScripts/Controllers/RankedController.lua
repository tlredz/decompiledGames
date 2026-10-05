local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
require(replicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.MVP)
local CountryCodes = require(game.ReplicatedStorage.Modules.CountryCodes)
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local controller = Knit.CreateController({
	Name = "RankedController"
})

function getFlagEmoji(value)
	local v7 = {
		a = "🇦",
		b = "🇧",
		c = "🇨",
		d = "🇩",
		e = "🇪",
		f = "🇫",
		g = "🇬",
		h = "🇭",
		i = "🇮",
		j = "🇯",
		k = "🇰",
		l = "🇱",
		m = "🇲",
		n = "🇳",
		o = "🇴",
		p = "🇵",
		q = "🇶",
		r = "🇷",
		s = "🇸",
		t = "🇹",
		u = "🇺",
		v = "🇻",
		w = "🇼",
		x = "🇽",
		y = "🇾",
		z = "🇿"
	}
	local v8 = string.lower(value)
	local v9 = string.sub(v8, 1, 1)
	local v10 = string.sub(v8, 2, 2)
	return v7[v9] .. v7[v10]
end

function controller.KnitStart(_)
	local group = localPlayer.PlayerGui:WaitForChild("Menus").Group
	local ranked = group.Ranked
	ranked:SetAttribute("Loaded", true)
	task.spawn(function()
		repeat
			task.wait()
		until workspace:GetAttribute("Init") == true

		if workspace:GetAttribute("Match") ~= nil then
			v2:Start()
		elseif workspace:GetAttribute("Roulette") ~= nil then
			v3:Start()
		elseif workspace:GetAttribute("FinalShowdown") ~= nil then
			v4:Start()
		elseif workspace:GetAttribute("NightParade") ~= nil then
			v5:Start()
		end
	end)

	local function teleport()
		for _, guiObject in ranked:GetChildren() do
			if guiObject.Name == "Loading" then
				guiObject.Visible = true
			elseif guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		task.spawn(function()
			repeat
				ranked.Loading.Icon.Rotation += 1
				task.wait()
			until ranked.Loading.Visible == false
		end)
	end

	local v7 = false
	ranked.VC.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v7 = not v7

		if v7 then
			ranked.VC.Loading.Visible = true
			ranked.VC.Image = "rbxassetid://219092693"
		else
			ranked.VC.Loading.Visible = false
			ranked.VC.Image = "rbxassetid://219092690"
		end
	end)
	ranked.Modes.Ranked.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(1)
	end)
	ranked.Modes.Servers.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		ranked.Servers.Visible = true
		ranked.Return.Visible = true
		ranked.Load.Visible = true
		ranked.Create.Visible = true
		ranked.VC.Visible = false
	end)
	ranked.Return.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		ranked.Modes.Visible = true
		ranked.JoinFriend.Visible = true
		ranked.VC.Visible = false
	end)
	ranked.Create.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		ranked.Create2.Visible = true
		ranked.Return.Visible = true
	end)
	ranked.JoinFriend.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		ranked.Return.Visible = true
		ranked.Friends.Visible = true
		local friendsOnline = localPlayer:GetFriendsOnline(200)

		for _, frame in ranked.Friends:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		for _, v8 in friendsOnline do
			if not (v8.LocationType == 4 and v8.PlaceId == game.PlaceId) then
				continue
			end

			local clone = group.Parent.Preset.FriendServer:Clone()
			clone.Title.Text = v8.DisplayName
			clone.Count.Visible = false
			clone.Desc.Text = "@" .. v8.UserName
			local v9 = v8
			task.spawn(function()
				local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
					v9.VisitorId,
					Enum.ThumbnailType.HeadShot,
					Enum.ThumbnailSize.Size48x48
				)
				clone.FriendIcon.Image = userThumbnailAsync
			end)
			clone.Parent = ranked.Friends
			local v11 = v8
			clone.Button.MouseButton1Down:Connect(function()
				v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				teleport()
				v.Teleport:Fire(6, v11.VisitorId)
			end)
		end
	end)
	local v8 = 5
	ranked.Modes.Public.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(2)
	end)
	ranked.Modes.Roulette.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		for _, frame in ranked.GamemodeServers:GetChildren() do
			if frame:IsA("Frame") and frame.Name == "RouServer" then
				frame:Destroy()
			end
		end

		ranked.GamemodeServers.Visible = true
		ranked.Return.Visible = true
		v.Filter:Fire(2)
		v8 = 5
	end)
	ranked.Modes.Creator.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		for _, frame in ranked.GamemodeServers:GetChildren() do
			if frame:IsA("Frame") and frame.Name == "RouServer" then
				frame:Destroy()
			end
		end

		ranked.GamemodeServers.Visible = true
		ranked.Return.Visible = true
		ranked.VC.Visible = true
		v.Filter:Fire(3)
		v8 = 7
	end)
	ranked.Modes.NightParade.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		for _, frame in ranked.GamemodeServers:GetChildren() do
			if frame:IsA("Frame") and frame.Name == "RouServer" then
				frame:Destroy()
			end
		end

		ranked.GamemodeServers.Visible = true
		ranked.Return.Visible = true
		v.Filter:Fire(4)
		v8 = 8
	end)
	ranked.Modes.FinalShowdown.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		for _, frame in ranked.GamemodeServers:GetChildren() do
			if frame:IsA("Frame") and frame.Name == "RouServer" then
				frame:Destroy()
			end
		end

		ranked.GamemodeServers.Visible = true
		ranked.Return.Visible = true
		v.Filter:Fire(5)
		v8 = 9
	end)
	ranked.GamemodeServers.QuickJoin.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(v8, true, v7)
	end)
	ranked.GamemodeServers.QuickJoinGlobal.Button.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(v8, nil, v7)
	end)
	local textBox = ranked.Create2.TextBox
	textBox.FocusLost:Connect(function(p)
		if not p then
			return
		end

		local text = textBox.Text
		textBox.Text = "Filtering..."
		textBox.TextEditable = false
		v.Filter:Fire(text)
	end)
	ranked.Create2.Create.MouseButton1Down:Connect(function()
		if textBox.TextEditable == false then
			return
		end

		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(3, textBox.Text)
	end)
	local v9 = false
	local v10 = false
	ranked.Load.MouseButton1Down:Connect(function()
		if v9 == true then
			return
		end

		v9 = true
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		v.Filter:Fire(1, v10)

		for _, frame in ranked.Servers:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end

		ranked.Load.Loading.Visible = true

		repeat
			task.wait()
		until v9 == false

		ranked.Load.Loading.Visible = false
	end)
	ranked.Load.Sort.MouseButton1Down:Connect(function()
		v10 = not v10
		ranked.Load.Sort.Rotation = v10 and 180 or 0
	end)
	ranked.Create2.Rejoin.MouseButton1Down:Connect(function()
		v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		teleport()
		v.Teleport:Fire(4, localPlayer.UserId)
	end)
	v.Teleport:Connect(function()
		for _, guiObject in ranked:GetChildren() do
			if guiObject:IsA("GuiObject") then
				guiObject.Visible = false
			end
		end

		ranked.Modes.Visible = true
		ranked.JoinFriend.Visible = true
	end)
	local v11 = nil

	local function loadList(text)
		local text2 = string.lower(ranked.Create.Searchbox.Text)
		local v12 = nil
		local v13

		if string.sub(text2, 3, 3) == " " then
			v13 = string.upper((string.sub(text2, 1, 2)))
			text2 = string.sub(text2, 4)

			if CountryCodes.ContinentCode[v13] then
				v12 = CountryCodes.ContinentCode[v13]
				v13 = nil
			end
		end

		local now = tick()
		v11 = now

		for k, item in text do
			if v11 ~= now then
				break
			end

			local v14 = item.value[6] or 1
			local clone = group.Parent.Preset.PrivateServer:Clone()
			clone.Name = item.key
			clone.Desc.Text = getFlagEmoji(item.value[4]) .. " " .. item.value[1]
			clone.Title.Text = item.value[2]
			clone.Count.Text = v14 .. "/20"
			clone:SetAttribute("CC", item.value[4])
			clone.LayoutOrder = v10 == true and v14 or -v14
			clone.Button.Image = "rbxassetid://" .. (item.value[5] or 0)
			clone.Parent = ranked.Servers

			if v13 and item.value[4] ~= v13 or v12 and CountryCodes.CountryCodes[item.value[4]] ~= v12 or not string.match(
				string.lower(item.value[2]),
				text2
			) then
				clone.Visible = false
			else
				clone.Visible = true
			end

			local v15 = item
			clone.Button.MouseButton1Down:Connect(function()
				v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				teleport()
				v.Teleport:Fire(4, v15.key)
			end)

			if k % 15 == 0 then
				task.wait()
			end
		end
	end

	local function loadListGamemode(text, p)
		for _, frame in ranked.GamemodeServers:GetChildren() do
			if frame:IsA("Frame") and frame.Name ~= "QuickJoin" and frame.Name ~= "QuickJoinGlobal" then
				frame:Destroy()
			end
		end

		for k, item in text do
			local clone = group.Parent.Preset.RouServer:Clone()
			clone.Name = k
			clone.Count.Text = item
			clone.Title.Text = getFlagEmoji(k) .. " " .. k
			clone.Parent = ranked.GamemodeServers
			local v12 = k
			clone.Button.MouseButton1Down:Connect(function()
				v6:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				teleport()
				v.Teleport:Fire(p, v12, v7)
			end)
		end
	end

	ranked.Create.Searchbox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = string.lower(ranked.Create.Searchbox.Text)
		local v12 = nil
		local v13

		if string.sub(text, 3, 3) == " " then
			v13 = string.upper((string.sub(text, 1, 2)))
			text = string.sub(text, 4)

			if CountryCodes.ContinentCode[v13] then
				v12 = CountryCodes.ContinentCode[v13]
				v13 = nil
			end
		end

		for _, frame in ranked.Servers:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			local CC = frame:GetAttribute("CC")

			if v13 and CC ~= v13 or v12 and CountryCodes.CountryCodes[CC] ~= v12 or not string.match(
				string.lower(frame.Title.Text),
				text
			) then
				frame.Visible = false
			else
				frame.Visible = true
			end
		end
	end)
	ranked:GetPropertyChangedSignal("Visible"):Connect(function()
		if ranked.Visible == true then
			return
		end

		for _, frame in ranked.Servers:GetChildren() do
			if frame:IsA("Frame") then
				frame:Destroy()
			end
		end
	end)
	v.Filter:Connect(function(text, p)
		if typeof(text) == "string" then
			textBox.Text = text
			textBox.TextEditable = true
		else
			if p == "ROULETTE" then
				pcall(function()
					loadListGamemode(text, 5)
				end)
				return
			elseif p == "CREATOR" then
				pcall(function()
					loadListGamemode(text, 7)
				end)
				return
			elseif p == "NIGHT" then
				pcall(function()
					loadListGamemode(text, 8)
				end)
				return
			elseif p == "FINAL" then
				pcall(function()
					loadListGamemode(text, 9)
				end)
				return
			end

			local success, result = pcall(function()
				loadList(text)
			end)

			if not success then
				warn(result)
			end

			v9 = false
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("RankedService")
	v6 = Knit.GetController("FXController")
	v3 = Knit.GetController("RouletteController")
	v4 = Knit.GetController("FinalShowdownController")
	v5 = Knit.GetController("NightParadeController")
	v2 = Knit.GetController("DuelController")
end

return controller