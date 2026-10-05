local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
game:GetService("CollectionService")
game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local Icon = require(replicatedStorage.Modules.Icon)
local _ = replicatedStorage.Animations
local _ = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "EmoteController"
})
controller.EmoteCache = {}
controller.Page = 1

function controller.KnitStart(_)
	local emotes = localPlayer.PlayerGui:WaitForChild("Emotes")
	local emote = emotes.Emote
	local inventory = localPlayer.PlayerGui:WaitForChild("Menus").Group.Inventory
	local gamepasses = localPlayer:WaitForChild("Gamepasses")
	task.wait()
	local v3 = Icon.new()
	v3:setImage("rbxassetid://11713358131")
	v3:bindEvent("selected", function(_)
		emote.Visible = true
	end)
	v3:bindEvent("deselected", function(_)
		emote.Visible = false
	end)
	replicatedStorage.Keybind.Combat.Emote.Pressed:Connect(function()
		if localPlayer.Character and _G.UsingPiano == 2 or localPlayer:GetAttribute("Adjusting_Keybinds") then
			return
		end

		if emote.Visible == false then
			v3:select()
		elseif emote.Visible == true then
			v3:deselect()
		end
	end)
	emote:GetPropertyChangedSignal("Visible"):Connect(function()
		if emote.Visible == false then
			return
		end

		emote.Size = UDim2.new(0.1, 150, 0.1, 150)
		emote.TextBox.Text = ""
		TweenService:Create(emote, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = UDim2.new(0.2, 150, 0.2, 150)
		}):Play()

		for _, humanoid in emote:GetDescendants() do
			if not humanoid:IsA("Humanoid") then
				continue
			end

			for _, v4 in humanoid:GetPlayingAnimationTracks() do
				v4.TimePosition = 0
			end
		end
	end)
	local camera = Instance.new("Camera")
	camera.Parent = emote
	camera.CFrame = emotes.Preset.Rig.HumanoidRootPart.CFrame * CFrame.new(0, 0, -30) * CFrame.Angles(
		0,
		3.141592653589793,
		0
	)
	camera.FieldOfView = 17
	localPlayer:WaitForChild("leaderstats")
	UserInputService.JumpRequest:Connect(function(_, _)
		local character = localPlayer.Character

		if not character or character.Info:FindFirstChild("EmoteCanJump") then
			return
		end

		if character.Info:FindFirstChild("Emote") then
			v.EmoteEnd:Fire()
		end
	end)
	v.Equip:Connect(function(childName, value, animationId, text)
		local child = emote:FindFirstChild(childName, true)

		if child:FindFirstChild("Rig") then
			child.Rig:Destroy()
		end

		local text2 = value or "None"
		child.EmoteName.Text = text2
		child.EmoteName.Tip.Visible = text ~= nil

		if text then
			child.EmoteName.Tip.Text = text
		end

		controller.EmoteCache[childName] = text2

		if childName <= 8 and controller.Page == 1 then
			inventory.Items.Emotes.Equipped[tostring(childName)].Text = text2
		elseif childName > 8 and controller.Page == 2 then
			inventory.Items.Emotes.Equipped[tostring(childName - 8)].Text = text2
		end

		local clone = emotes.Preset.Rig:Clone()
		clone.Parent = child

		if animationId then
			local animation = Instance.new("Animation", clone)
			animation.AnimationId = animationId

			if animationId ~= "0" then
				local track = clone.Humanoid:LoadAnimation(animation)
				track.Looped = true
				track:Play()
				track:GetMarkerReachedSignal("Loop"):Connect(function(timePosition)
					track.TimePosition = timePosition
				end)
			end
		end
	end)
	emote.Switch.MouseButton1Down:Connect(function()
		emote.Page1.Visible = not emote.Page1.Visible
		emote.Page2.Visible = not emote.Page2.Visible
		v2:PlaySound(sounds.Misc.UI.Switch, workspace, game.SoundService.Effect)
	end)

	for _, viewportFrame in emote:GetDescendants() do
		if not viewportFrame:IsA("ViewportFrame") then
			continue
		end

		viewportFrame.CurrentCamera = camera
		local v4 = viewportFrame
		viewportFrame.MouseEnter:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
			TweenService:Create(v4, TweenInfo.new(0.25), {
				Size = UDim2.new(0.35, 10, 0.5, 10)
			}):Play()
		end)
		local v5 = viewportFrame
		viewportFrame.MouseLeave:Connect(function()
			TweenService:Create(v5, TweenInfo.new(0.25), {
				Size = UDim2.new(0.35, 0, 0.5, 0)
			}):Play()
		end)
		local v6 = viewportFrame
		viewportFrame.Clickable.MouseButton1Down:Connect(function()
			v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
			v3:deselect()
			v.Emote:Fire((tonumber(v6.Name)))
		end)
	end

	local function updateGamepass()
		if gamepasses:GetAttribute("742180133") then
			for i = 5, 8 do
				local findFirstChild = emote:FindFirstChild(i, true)
				findFirstChild.Visible = true
				local findFirstChild_2 = inventory.Items.Emotes.Equipped:FindFirstChild(i)
				findFirstChild_2.Visible = true
			end

			local findFirstChild_3 = emote:FindFirstChild(13, true)
			findFirstChild_3.Visible = true
			local findFirstChild_4 = emote:FindFirstChild(14, true)
			findFirstChild_4.Visible = true
			local findFirstChild_5 = emote:FindFirstChild(15, true)
			findFirstChild_5.Visible = true
			local findFirstChild_6 = emote:FindFirstChild(16, true)
			findFirstChild_6.Visible = true
		end

		if gamepasses:GetAttribute("1151174294") then
			emote.Switch.Visible = true
			inventory.Items.Emotes.Equipped.Switch.Visible = true
			emote.TextBox.Visible = true
		end
	end

	updateGamepass()
	gamepasses:GetAttributeChangedSignal("742180133"):Connect(updateGamepass)
	gamepasses:GetAttributeChangedSignal("1151174294"):Connect(updateGamepass)
	local Effects = require(script:WaitForChild("Effects"))
	v.Effects:Connect(function(p, ...)
		local v4 = { ... }
		xpcall(function()
			Effects[p](unpack(v4))
		end, function(p2)
			print(("err with EmoteController [%s]: %s"):format(p, p2))
		end)
	end)
	emote.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
		if emote.TextBox.Text == "" then
			if gamepasses:GetAttribute("1151174294") then
				emote.TextBox.Visible = true
				emote.Switch.Visible = true
			end

			emote.Page1.Visible = true
			emote.Page2.Visible = false
			emote.Search.Visible = false
		else
			emote.Page1.Visible = false
			emote.Page2.Visible = false
			emote.Switch.Visible = false
			emote.Search.Visible = true

			for _, frame in emote.Search:GetChildren() do
				if frame:IsA("Frame") then
					frame:Destroy()
				end
			end

			for _, frame in inventory.Items.Emotes.List:GetChildren() do
				if not (frame:IsA("Frame") and frame.Name:lower():find(emote.TextBox.Text:lower())) then
					continue
				end

				local clone = frame:Clone()
				clone.Parent = emote.Search
				clone.Visible = true
				clone.MouseEnter:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Hover, workspace, game.SoundService.Effect)
				end)
				clone.EmoteName.MouseButton1Down:Connect(function()
					v2:PlaySound(sounds.Misc.UI.Click, workspace, game.SoundService.Effect)
					v3:deselect()
					v.Emote:Fire(clone.Name)
				end)
			end
		end
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("EmoteService")
	v2 = Knit.GetController("FXController")
end

return controller