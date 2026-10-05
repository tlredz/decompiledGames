local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Remotes
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(game.ReplicatedStorage.Modules.CameraShaker)
require(replicatedStorage.Modules.Icon)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "DebugController"
})
local v4 = localPlayer
local v5 = {
	Respawn2 = true,
	Destroy = true,
	OP = false,
	FF = true,
	TI = false,
	Item = true,
	Dummy1 = false,
	Dummy2 = false,
	Dummy3 = false,
	Dummy4 = false,
	Dummy5 = false,
	Dummy6 = false,
	Dummy7 = false,
	Dummy8 = false,
	Dummy9 = false,
	Gravity = 196.2,
	WalkSpeed = 16,
	JumpPower = 40,
	ServerName = "",
	ServerIcon = 0,
	Fidelity = 2,
	Tick = 20,
	Damage = 1,
	Knockback = 1,
	Lock = false,
	Voice = false,
	RC = false,
	CC1 = false,
	CC2 = false,
	CC3 = false,
	GlobalName = false,
	MaxDmg = 0,
	VK = false,
	VKB = false,
	KF = false
}
local v6 = {
	Flight = false,
	Build = false,
	PSPerms = false,
	CD = true,
	Ult = false,
	Stun = false,
	Respawn = true,
	DeathKick = true,
	Skill = true,
	SkillM1 = true,
	SkillUlt = true,
	Parkour = true,
	Burst = true,
	ApplyNew = false,
	Workshop = false
}
local v7 = {
	Kick = true,
	Ban = true,
	Heal = true,
	ResetCD = true,
	Kill = true,
	Bring = true,
	Go = true,
	Respawn3 = true
}
local v8 = {
	Flight = function()
		local character = v4.Character

		if not character then
			return
		end

		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			return humanoidRootPart:FindFirstChild("FlightForce") ~= nil
		end
	end,
	Build = function()
		return v4:FindFirstChild("BuildTag") ~= nil
	end,
	PSPerms = function()
		return v4:GetAttribute("PS_Perms")
	end,
	CD = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("CD")
		end
	end,
	Ult = function()
		local character = v4.Character

		if character then
			return character:GetAttribute("UltDrain")
		end
	end,
	Stun = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return character.Info:GetAttribute("NoStun")
		end
	end,
	Respawn = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("NoRes")
		end
	end,
	DeathKick = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return character.Info:GetAttribute("DeathKick")
		end
	end,
	Skill = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("Skill")
		end
	end,
	SkillM1 = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("M1")
		end
	end,
	SkillUlt = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("Ult")
		end
	end,
	Parkour = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("Parkour")
		end
	end,
	Burst = function()
		local character = v4.Character

		if character and character:FindFirstChild("Info") then
			return not character.Info:GetAttribute("Burst")
		end
	end,
	Workshop = function()
		return v4:GetAttribute("Workshop") == true
	end
}

local function updateBool(frame, p)
	if p == true then
		frame.Toggle.BackgroundColor3 = Color3.fromRGB(85, 255, 0)
		frame.Toggle.Side.BackgroundColor3 = Color3.fromRGB(169, 255, 189)
		frame.Toggle.Side.Position = UDim2.new(0, 0, 0, 0)
	else
		frame.Toggle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
		frame.Toggle.Side.BackgroundColor3 = Color3.fromRGB(85, 0, 0)
		frame.Toggle.Side.Position = UDim2.new(0.5, 0, 0, 0)
	end
end

function controller.KnitStart(_)
	local menus = localPlayer.PlayerGui:WaitForChild("Menus")
	local private = menus.Group.Private
	private:SetAttribute("Loaded", true)
	localPlayer:WaitForChild("leaderstats")

	local function updateDebugPlayer()
		if v4 == "All" then
			private.Items.Players.Players.ApplyNew.Visible = true

			for _, frame in private.Items.Players.Players:GetDescendants() do
				if not (frame:IsA("Frame") and v6[frame.Name] ~= nil and frame:FindFirstChild("Toggle")) then
					continue
				end

				updateBool(frame, v6[frame.Name])
			end
		else
			private.Items.Players.Players.ApplyNew.Visible = false

			for _, frame in private.Items.Players.Players:GetDescendants() do
				if not (frame:IsA("Frame") and v8[frame.Name] ~= nil and frame:FindFirstChild("Toggle")) then
					continue
				end

				updateBool(frame, v8[frame.Name]())
			end
		end
	end

	for _, button in private.Categories:GetChildren() do
		if not button:IsA("TextButton") then
			continue
		end

		local v9 = button
		button.MouseButton1Down:Connect(function()
			for i, button2 in private.Categories:GetChildren() do
				if button2:IsA("TextButton") then
					button2.Select.Visible = button2 == v9
				end
			end

			v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if v9.Name == "Players" then
				updateDebugPlayer()
			end

			for i, child in private.Items:GetChildren() do
				child.Visible = child.Name == v9.Name
			end
		end)
	end

	local clone = menus.Preset.Player:Clone()
	clone.Name = "All"
	clone.Display.Text = "All"
	clone.Main.Text = "All Players"
	clone.Parent = private.Items.Players.List
	clone.Select.MouseButton1Down:Connect(function()
		v4 = "All"
		updateDebugPlayer()
		v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

		for _, frame in private.Items.Players.List:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame == clone then
				frame.BackgroundTransparency = 0.5
			else
				frame.BackgroundTransparency = 1
			end
		end
	end)

	local function createGiftPlayer(data)
		local clone2 = menus.Preset.Player:Clone()
		clone2.Name = data.Name
		clone2.Display.Text = data.DisplayName or data.Name
		clone2.Main.Text = "(@" .. data.Name .. ")"

		if data == v4 then
			clone2.BackgroundTransparency = 0.5
		end

		clone2.Parent = private.Items.Players.List
		clone2.Select.MouseButton1Down:Connect(function()
			v4 = data
			updateDebugPlayer()
			v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			for _, frame in private.Items.Players.List:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				if frame == clone2 then
					frame.BackgroundTransparency = 0.5
				else
					frame.BackgroundTransparency = 1
				end
			end
		end)
		data.CharacterAdded:Connect(function()
			if data ~= v4 then
				return
			end

			task.defer(function()
				updateDebugPlayer()
			end)
		end)
		pcall(function()
			local userIdFromNameAsync = game.Players:GetUserIdFromNameAsync(data.Name)
			local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
				userIdFromNameAsync,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size48x48
			)
			clone2.Icon.Image = userThumbnailAsync
		end)
	end

	v.Debug:Connect(function(p, text)
		if p and text ~= nil then
			if p == "Banned" then
				for _, frame in private.Items.Moderation.Banned:GetChildren() do
					if frame:IsA("Frame") then
						frame:Destroy()
					end
				end

				for k, v9 in text do
					local clone2 = menus.Preset.UnbanPlayer:Clone()
					clone2.Display.Text = v9.DisplayName or v9.Name
					clone2.Main.Text = "(@" .. v9.Name .. ")"
					clone2.Parent = private.Items.Moderation.Banned
					local v10 = k
					clone2.Button.MouseButton1Down:Connect(function()
						v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
						v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
						v.Unban:Fire(v10)
					end)
					local v11 = k
					task.spawn(function()
						local userThumbnailAsync = game.Players:GetUserThumbnailAsync(
							v11,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size48x48
						)
						clone2.Icon.Image = userThumbnailAsync
					end)
				end
			else
				for _, frame in private.Items:GetDescendants() do
					if not (frame:IsA("Frame") and frame.Name == p) then
						continue
					end

					if not (frame.Parent == private.Items.Server or frame.Parent == private.Items.Moderation or frame.Parent == private.Items.Players.Players) then
						continue
					end

					if frame:FindFirstChild("Toggle") then
						updateBool(frame, text)
					elseif frame:FindFirstChild("TextBox") then
						frame.TextBox.Text = text
					end
				end
			end
		end
	end)
	v.Update:Connect(function(items)
		if items then
			for k, item in items do
				if v6[k] ~= nil then
					v6[k] = item
				end
			end
		end

		updateDebugPlayer()
	end)

	for _, child in game.Players:GetChildren() do
		task.spawn(createGiftPlayer, child)
	end

	game.Players.PlayerAdded:Connect(createGiftPlayer)
	game.Players.PlayerRemoving:Connect(function(player)
		if v4 == player then
			v4 = localPlayer
		end

		updateDebugPlayer()

		for _, frame in private.Items.Players.List:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame.Name == v4.Name then
				frame.BackgroundTransparency = 0.5
			elseif frame.Name == player.Name then
				frame:Destroy()
			else
				frame.BackgroundTransparency = 1
			end
		end
	end)

	for _, frame in private.Items:GetDescendants() do
		if not (frame:IsA("Frame") and (frame.Parent == private.Items.Server or frame.Parent == private.Items.Moderation or frame.Parent == private.Items.Players.Players)) then
			continue
		end

		local name = frame.Name

		if v5[name] == nil then
			if v6[name] == nil then
				if v7[name] ~= nil then
					local name2 = name
					frame.Button.MouseButton1Down:Connect(function()
						v.Debug:Fire(name2, v4)
						v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					end)
				end
			else
				local name2 = name
				frame.Toggle.Side.MouseButton1Down:Connect(function()
					v.Debug:Fire(name2, v4)
					v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
				end)
			end
		elseif frame:FindFirstChild("Toggle") then
			updateBool(frame, v5[name])
			local name2 = name
			frame.Toggle.Side.MouseButton1Down:Connect(function()
				v.Debug:Fire(name2)
				v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
				v3:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
			end)
		elseif frame:FindFirstChild("Button") then
			local name2 = name
			frame.Button.MouseButton1Down:Connect(function()
				v.Debug:Fire(name2)
				v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			end)
		elseif frame:FindFirstChild("TextBox") then
			local name2 = name
			local v10 = frame
			frame.TextBox.FocusLost:Connect(function()
				v.Debug:Fire(name2, v10.TextBox.Text)
				v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			end)
		end
	end

	local request = game.ReplicatedStorage.Remotes.Request
	request.OnClientEvent:Connect(function(p, p2)
		local bindableFunction = Instance.new("BindableFunction", script)

		function bindableFunction.OnInvoke(p3)
			v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)

			if p3 == "Allow" then
				request:FireServer(p)
			end
		end

		Debris:AddItem(bindableFunction, 2)
		local StarterGui = game:GetService("StarterGui")
		StarterGui:SetCore("SendNotification", {
			Title = "Build Mode Request",
			Text = p.Name .. p2,
			Button1 = "Allow",
			Button2 = "Deny",
			Callback = bindableFunction,
			Duration = 2
		})
	end)
	localPlayer.PlayerGui.ChildRemoved:Connect(function(child)
		if child.Name ~= "BuildTools" then
			return
		end

		for _, descendant in workspace.Logic:GetDescendants() do
			if descendant:IsA("BillboardGui") then
				descendant.Enabled = false
			elseif descendant:IsA("SelectionBox") then
				descendant.Visible = false
			elseif descendant:IsA("Beam") then
				descendant:Destroy()
			end
		end
	end)
	private:GetPropertyChangedSignal("Visible"):Connect(function()
		v.Update:Fire()
	end)
	private.Items.Presets:GetPropertyChangedSignal("Visible"):Connect(function()
		v3:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
		private.Visible = false

		for _, button in private.Categories:GetChildren() do
			if button:IsA("TextButton") then
				button.Select.Visible = button.Name == "Server"
			end
		end

		for _, child in private.Items:GetChildren() do
			child.Visible = child.Name == "Server"
		end

		_G.WorkshopIcon:select()
	end)
	replicatedStorage.Keybind.Creator["Reset Cooldowns"].Pressed:Connect(function()
		v.Debug:Fire("ResetCD", localPlayer)
	end)
	replicatedStorage.Keybind.Creator["Toggle Flight"].Pressed:Connect(function()
		v.Debug:Fire("Flight", localPlayer)
	end)
	replicatedStorage.Keybind.Creator["Toggle Build Menu"].Pressed:Connect(function()
		v.Debug:Fire("Build", localPlayer)
	end)

	if workspace.Map.Destructible:FindFirstChild("Model") and workspace.Map.Destructible.Model:FindFirstChild("StationControl") then
		workspace.Map.Destructible.Model.StationControl.Handle.Train.OnClientEvent:Connect(function()
			local train = workspace.Effects:WaitForChild("Train", 1)
			task.spawn(function()
				repeat
					task.wait(0.05)
					local magnitude = (workspace.CurrentCamera.CFrame.Position - train.Position).Magnitude

					if not (magnitude > 500) then
						local position = workspace.CurrentCamera.CFrame.Position

						if not workspace:Raycast(position, train.Position - position, _G.MapParams) then
							if magnitude < 150 then
								CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
							elseif magnitude < 300 then
								CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
							elseif magnitude > 300 then
								CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
							end
						end
					end
				until not train.Parent
			end)
		end)
	end
end

function controller.KnitInit(_)
	v = Knit.GetService("DebugService")
	v2 = Knit.GetService("BuildService")
	v3 = Knit.GetController("FXController")
end

return controller