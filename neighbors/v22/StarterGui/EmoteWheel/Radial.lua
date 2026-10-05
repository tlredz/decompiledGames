local Radial = {}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()
local Radial2 = require(script:WaitForChild("Radial"))
local UI = require(ReplicatedStorage.Modules.UI)
local Network = require(ReplicatedStorage.Modules.Network)
local Data = require(ReplicatedStorage.Modules.Data)
local PlayerModule = require(ReplicatedStorage.Modules.PlayerModule)
local Gamepad = require(ReplicatedStorage.Modules.Gamepad)
local Sound = require(ReplicatedStorage.Modules.Sound)
local Emotes = require(ReplicatedStorage.Assets.Data.Store.Emotes)
local emoteSounds = ReplicatedStorage.Assets.EmoteSounds
local remotes = ReplicatedStorage.Remotes
local wheel = script.Parent:WaitForChild("Wheel")
local now = 0
local G = Enum.KeyCode.G
local buttonL3 = Enum.KeyCode.ButtonL3
local v = {
	"Push Ups",
	"SpeedDance",
	"SitUps",
	"Worm"
}
Radial.HoverIndex = 1
Radial.CurrentRadial = nil
Radial.Enabled = false
Radial.Binding = false
Radial.DeadZoneOut = 1e999
Radial.DeadZoneIn = 0.2
Radial.ShowCustomEmotes = true
wheel.CustomEmoteToggle.Visible = true
local track = nil
local v2 = false
local v3 = false
local flag = false
local v4 = false

if game.Lighting:FindFirstChild("EmoteBlur") then
	game.Lighting.EmoteBlur:Destroy()
end

local blurEffect = Instance.new("BlurEffect", game.Lighting)
blurEffect.Name = "EmoteBlur"
blurEffect.Size = 0
blurEffect.Enabled = false
pcall(function()
	return game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
end)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSound(p: string)
	Sound:Sound(script.Sounds[p], script.Parent)
end

local function addHoverEffect(data)
	local textColor3 = data.TextColor3
	local color = Color3.new(textColor3.r * 0.8, textColor3.g * 0.8, textColor3.b * 0.8)
	data.MouseEnter:connect(function()
		TweenService:Create(data, TweenInfo.new(0.15), {
			TextColor3 = color
		}):Play()
	end)
	data.MouseLeave:connect(function()
		TweenService:Create(data, TweenInfo.new(0.15), {
			TextColor3 = textColor3
		}):Play()
	end)
end

local thread = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCurrentTrack()
	if thread then
		task.cancel(thread)
		thread = nil
	end

	if track then
		track:Stop(0.1)
		track = nil
	end

	if v3 or flag then
		remotes.DeleteProp:FireServer()
	end

	v3 = false
	flag = false
	v2 = false
	v4 = false
end

remotes.EmoteSync.OnClientEvent:Connect(function(emoteName: string?, p: number?)
	if emoteName and p then
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")

		if not humanoid then
			return
		end

		v3 = false
		flag = false
		stopCurrentTrack() -- equivalent call inferred; original call site unknown

		if script:FindFirstChild("Animation") then
			script.Animation:Destroy()
		end

		local animation = Instance.new("Animation")
		animation.Name = "Animation"
		animation:SetAttribute("EmoteName", emoteName)
		animation.AnimationId = "rbxassetid://" .. p
		animation.Parent = script
		local emote = Emotes[emoteName]
		v4 = emote ~= nil and emote.CanMove == true
		v2 = emote ~= nil and emote.Grounded == true
		local track2 = humanoid:LoadAnimation(animation)
		track2.Priority = Enum.AnimationPriority.Action
		local looped

		if emote == nil then
			looped = false
		else
			looped = emote.Looped == true
		end

		track2.Looped = looped
		track2:Play(0.1)
		track = track2
		flag = true
		track2.Stopped:Once(function()
			if track == track2 then
				stopCurrentTrack() -- equivalent call inferred; original call site unknown
			end
		end)
		humanoid.Jumping:Once(function()
			stopCurrentTrack() -- equivalent call inferred; original call site unknown
		end)
		track2:GetMarkerReachedSignal("PlaySound"):Connect(function()
			local child = emoteSounds:FindFirstChild(emoteName)
			local sound = child and child:FindFirstChildWhichIsA("Sound")

			if sound then
				sound:Play()
			end
		end)
	elseif flag then
		stopCurrentTrack() -- equivalent call inferred; original call site unknown
	end
end)

local function getCustomEquippedEmotes()
	local emotes = Radial:GetEmotes(true)
	local emotes2 = {}

	for _, emote in pairs(emotes) do
		if emote.Overwrite then
			table.insert(emotes2, emote)
		end
	end

	return emotes2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateShowCustomEmotesToggleText()
	wheel.CustomEmoteToggle.Text = Radial.ShowCustomEmotes and "Hide Custom" or "Show Custom"
end

-- equivalent calls inferred from this helper; original call sites unknown
local function handleShowCustomEmoteToggle()
	if #getCustomEquippedEmotes() == 0 then
		wheel.CustomEmoteToggle.Visible = false
		Radial.ShowCustomEmotes = true
	elseif not wheel.CustomEmoteToggle.Visible then
		wheel.CustomEmoteToggle.Visible = true
		updateShowCustomEmotesToggleText() -- equivalent call inferred; original call site unknown
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isEmoteBlacklisted(p: string)
	return table.find(v, p) and true or false
end

function Radial:GetEmotes(p)
	local character = localPlayer.Character

	if not (character and character:FindFirstChild("Humanoid")) then
		return {}
	end

	local appliedDescription = character.Humanoid:GetAppliedDescription()
	local emotes = appliedDescription:GetEmotes()
	local result = {}

	for _, v5 in appliedDescription:GetEquippedEmotes() do
		local emote = emotes[v5.Name]

		if emote then
			result[v5.Slot] = {
				Name = v5.Name,
				Order = v5.Slot,
				Id = emote[1],
				Type = "RobloxEmote"
			}
		end
	end

	if Radial.ShowCustomEmotes ~= true and not p then
		return result
	end

	for k, v5 in Data.Emotes.Items or {} do
		if not v5.Slot then
			continue
		end

		local overwrite = result[v5.Slot] and true or false
		local emote = Emotes[k]

		if emote then
			result[v5.Slot] = {
				Name = k,
				Display = emote.Display,
				Order = v5.Slot,
				Id = emote.AnimationId,
				AnimationStart = emote.AnimationStart or nil,
				AnimationLoop = emote.AnimationLoop or nil,
				HasProp = emote.HasProp,
				EmoteDelay = emote.EmoteDelay,
				PropName = emote.PropName,
				Grounded = emote.Grounded,
				Sync = emote.Sync,
				CanMove = emote.CanMove,
				Looped = emote.Looped,
				Overwrite = overwrite,
				Type = "Emote"
			}
		end
	end

	return result
end

function Radial:SetEnabled(enabled)
	if not enabled and self.Binding then
		return
	end

	if enabled then
		now = os.clock()
	end

	self.Enabled = enabled
end

function Radial:Rebuild()
	if self.CurrentRadial then
		self.HoverIndex = 1
		self.CurrentRadial:Destroy()
		self.CurrentRadial = nil
	end

	self.CurrentRadial = Radial2.new(8, 0.5, 3.9269908169872414)
	self.CurrentRadial.DeadZoneOut = self.DeadZoneOut
	self.CurrentRadial.DeadZoneIn = self.DeadZoneIn
	self.CurrentRadial.Frame.Parent = wheel
	local emotes = self:GetEmotes()

	for k, emote in emotes do
		local textLabel = Instance.new("TextLabel")
		textLabel.Text = emote.Display or emote.Name
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextScaled = true

		if emote.Overwrite then
			textLabel.Text = "(" .. textLabel.Text .. ")"
		end

		local uITextSizeConstraint = Instance.new("UITextSizeConstraint", textLabel)
		uITextSizeConstraint.MaxTextSize = 15
		uITextSizeConstraint.MinTextSize = 1
		textLabel.BackgroundTransparency = 1
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Parent = self.CurrentRadial:GetAttachment(k)

		if emote.Type ~= "RobloxEmote" then
			continue
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.BackgroundTransparency = 1
		imageLabel.Name = "Icon"
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageLabel.Image = string.format("rbxthumb://type=Asset&id=%d&w=420&h=420", emote.Id)
		imageLabel.Size = UDim2.new(0, 80, 0, 80)
		imageLabel.Parent = self.CurrentRadial:GetAttachment(k)
		textLabel.Visible = false
	end

	self.CurrentRadial:SetDialProps({
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ImageTransparency = 0.1
	})
	self.CurrentRadial.Hover:connect(function(p, hoverIndex)
		self.HoverIndex = hoverIndex

		if p then
			local radial = self.CurrentRadial:GetRadial(p)
			radial.ImageColor3 = Color3.new(0, 0, 0)

			if os.clock() - now > 0.05 and self.Enabled then
				playSound("Hover") -- equivalent call inferred; original call site unknown
			end
		end

		if hoverIndex then
			local radial_2 = self.CurrentRadial:GetRadial(hoverIndex)
			radial_2.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
	end)
	self.CurrentRadial.Clicked:connect(function(p)
		local WAIT_INTERVAL = 0.1

		if os.clock() - now < 0.05 or not self.Enabled then
			return
		end

		local emote = emotes[p]
		playSound("Click") -- equivalent call inferred; original call site unknown
		self:SetEnabled(false)
		local character = localPlayer.Character

		if not (character and character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart")) then
			task.wait(WAIT_INTERVAL)
			return self:SetEnabled(false)
		end

		local humanoid = character.Humanoid

		if self.Binding or self.Swimming then
			Network:fire("SetEmoteSlot", self.BindingElement, p)
			self:StopBinding()
		else
			if emote and not (humanoid:FindFirstChild("CarryWeld") or character:GetAttribute("BoogieDancing")) then
				stopCurrentTrack() -- equivalent call inferred; original call site unknown

				if script:FindFirstChild("Animation") then
					script.Animation:Destroy()
				end

				if character:GetAttribute("Carrying") and not localPlayer:GetAttribute("Godmode") and isEmoteBlacklisted(emote.Name) then
					task.wait(WAIT_INTERVAL)
					self:SetEnabled(false)
					return
				end

				if emote.Type == "RobloxEmote" then
					humanoid:PlayEmote(emote.Name)
				elseif emote.Type == "Emote" and humanoid.FloorMaterial ~= Enum.Material.Air then
					local animation = Instance.new("Animation")
					animation.Name = "Animation"
					animation:SetAttribute("EmoteName", emote.Name)
					animation.Parent = script

					if emote.AnimationStart then
						if emote.HasProp then
							humanoid:UnequipTools()

							if character:FindFirstChildWhichIsA("Tool") then
								animation:Destroy()
								return
							else
								Network:fire("PropEmote", emote.Name)
								v3 = true
							end
						end

						animation.AnimationId = `rbxassetid://{emote.AnimationStart}`
						local track2 = humanoid:LoadAnimation(animation)
						track2.Priority = Enum.AnimationPriority.Action
						track2.Looped = false
						track2:Play(0.1)
						track = track2
						thread = task.spawn(function()
							local v5 = os.clock() + 3

							while track2.Length == 0 and os.clock() < v5 do
								task.wait()
							end

							task.wait((math.max(track2.Length - 0.3, 0)))
							thread = nil

							if track ~= track2 then
								return
							end

							if animation then
								animation:Destroy()
							end

							local animation2 = Instance.new("Animation")
							animation2.Name = "Animation"
							animation2:SetAttribute("EmoteName", emote.Name)
							animation2.AnimationId = `rbxassetid://{emote.AnimationLoop}`
							animation2.Parent = script
							local track3 = humanoid:LoadAnimation(animation2)
							track3.Priority = Enum.AnimationPriority.Action
							track3.Looped = true
							track3:Play(0.1)
							track = track3
						end)
					elseif emote.HasProp then
						humanoid:UnequipTools()

						if character:FindFirstChildWhichIsA("Tool") then
							animation:Destroy()
							return
						end

						animation.AnimationId = "rbxassetid://" .. emote.Id
						Network:fire("PropEmote", emote.Name)
						local track2 = humanoid:LoadAnimation(animation)
						track2.Priority = Enum.AnimationPriority.Action

						if emote.Looped then
							track2.Looped = true
						else
							track2.Stopped:Once(function()
								if track == track2 then
									stopCurrentTrack() -- equivalent call inferred; original call site unknown
								end
							end)
						end

						track = track2
						task.delay(emote.EmoteDelay or 0, function()
							if track == track2 then
								track2:Play(0.1)
							end
						end)
						v3 = true
					elseif emote.Sync then
						animation:Destroy()

						if humanoid.Sit then
							return
						end

						flag = true
						Network:fire("EmoteSyncSetup", emote.Name)
					else
						animation.AnimationId = "rbxassetid://" .. emote.Id
						track = humanoid:LoadAnimation(animation)
						track.Priority = Enum.AnimationPriority.Action

						if emote.Looped then
							track.Looped = true
						end

						track:Play(0.1)
					end

					if not emote.Sync then
						humanoid.Jumping:Once(function()
							stopCurrentTrack() -- equivalent call inferred; original call site unknown
						end)
						humanoid.StateChanged:Once(function()
							stopCurrentTrack() -- equivalent call inferred; original call site unknown
						end)
					end

					v2 = emote.Grounded == true
					v4 = emote.CanMove == true
				end
			end

			task.wait(WAIT_INTERVAL)
			self:SetEnabled(false)
		end
	end)
	handleShowCustomEmoteToggle() -- equivalent call inferred; original call site unknown
end

function Radial:StartBinding(bindingElement)
	self.BindingElement = bindingElement
	self.Binding = true
	wheel.CustomEmoteToggle.Visible = false
	wheel.Unbind.Visible = true
	localPlayer.PlayerGui.Neighbors.Enabled = false
	self.CurrentRadial.DeadZoneOut = 1
	self.CurrentRadial.DeadZoneIn = 0.5
	self:SetEnabled(true)
end

function Radial:StopBinding()
	self.Binding = false
	self.BindingElement = nil
	localPlayer.PlayerGui.Neighbors.Enabled = true
	wheel.Unbind.Visible = false
	self.CurrentRadial.DeadZoneOut = self.DeadZoneOut
	self.CurrentRadial.DeadZoneIn = self.DeadZoneIn
	self:SetEnabled(false)
end

wheel:WaitForChild("Unbind").MouseButton1Down:connect(function()
	Network:fire("SetEmoteSlot", Radial.BindingElement, nil)
	Radial:StopBinding()
end)
UI:Bind(wheel.Unbind)
addHoverEffect(wheel.Unbind)
wheel:WaitForChild("CustomEmoteToggle").MouseButton1Down:connect(function()
	Radial.ShowCustomEmotes = not Radial.ShowCustomEmotes
	updateShowCustomEmotesToggleText() -- equivalent call inferred; original call site unknown
	Radial:Rebuild()
end)
UI:Bind(wheel.CustomEmoteToggle)
addHoverEffect(wheel.CustomEmoteToggle)
UserInputService.InputBegan:connect(function(p, p2)
	if p2 or p.KeyCode ~= G and p.KeyCode ~= buttonL3 and p.KeyCode ~= Enum.KeyCode.Period then
		return
	end

	local pV2Piano = localPlayer.PlayerGui:FindFirstChild("PV2Piano")

	if Radial.Enabled or not pV2Piano or pV2Piano:GetAttribute("Visible") ~= true then
		return Radial:SetEnabled(not Radial.Enabled)
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == buttonL3 then
		if Radial.CurrentRadial._LastHoverIndex then
			Radial.CurrentRadial._ClickedBind:Fire(Radial.CurrentRadial._LastHoverIndex)
		end

		Radial:SetEnabled(false)
	end
end)
blurEffect:GetPropertyChangedSignal("Enabled"):Connect(function()
	PlayerModule:SetCameraInputEnabled(not (blurEffect.Enabled and Gamepad.GamepadEnabled))
end)

local function handleNewCharacter(instance)
	local humanoid = instance:WaitForChild("Humanoid")
	track = nil
	v3 = false
	flag = false
	v2 = false
	v4 = false
	humanoid:GetPropertyChangedSignal("MoveDirection"):connect(function()
		if humanoid.MoveDirection.magnitude > 0.5 then
			Radial:SetEnabled(false)

			if not v4 then
				stopCurrentTrack() -- equivalent call inferred; original call site unknown
			end
		end
	end)
	instance:GetAttributeChangedSignal("Carried"):connect(function()
		if instance:GetAttribute("Carried") then
			Radial:SetEnabled(false)
			stopCurrentTrack() -- equivalent call inferred; original call site unknown
		end
	end)
	instance:GetAttributeChangedSignal("Carrying"):connect(function()
		if instance:GetAttribute("Carrying") then
			local emoteName = script:FindFirstChild("Animation") and script:FindFirstChild("Animation"):GetAttribute("EmoteName")

			if isEmoteBlacklisted(emoteName) then
				stopCurrentTrack() -- equivalent call inferred; original call site unknown
			end
		end
	end)
	instance:GetAttributeChangedSignal("IsPosessed"):Connect(function()
		stopCurrentTrack() -- equivalent call inferred; original call site unknown
	end)
	instance:GetAttributeChangedSignal("InActivity"):Connect(function()
		stopCurrentTrack() -- equivalent call inferred; original call site unknown
	end)
	instance.ChildAdded:Connect(function(tool)
		if v3 == true and tool:IsA("Tool") then
			stopCurrentTrack() -- equivalent call inferred; original call site unknown
		end
	end)
	humanoid.ChildAdded:connect(function(humanoidDescription)
		if humanoidDescription:IsA("HumanoidDescription") then
			task.wait(0.25)
			Radial:Rebuild()
		end
	end)
	humanoid.Seated:Connect(function()
		if flag then
			stopCurrentTrack() -- equivalent call inferred; original call site unknown
		end
	end)
end

Radial:Rebuild()
localPlayer.CharacterAdded:connect(function(p)
	return handleNewCharacter(p)
end)

if localPlayer.Character then
	task.spawn(handleNewCharacter, localPlayer.Character)
end

Data.Emotes:GetPropertyChangedSignal("Items"):connect(function()
	return Radial:Rebuild()
end)
wheel.Size = UDim2.new(0, 500, 0, 500)
blurEffect.Size = 20
local RunService = game:GetService("RunService")
RunService.Heartbeat:connect(function(_)
	blurEffect.Enabled = Radial.Enabled
	wheel.Visible = Radial.Enabled

	if not localPlayer.Character then
		return
	end

	local canCollide = not v2
	local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")

	if localPlayer.Character:GetAttribute("PropMorphed") then
		localPlayer.Character.UpperTorso.CanCollide = false
		localPlayer.Character.PrimaryPart.CanCollide = false
	else
		Radial.Swimming = humanoid and humanoid:GetState() == Enum.HumanoidStateType.Swimming
		Radial.Carrying = localPlayer.Character:GetAttribute("Carrying")

		if localPlayer.Character and localPlayer.Character.PrimaryPart and localPlayer.Character:FindFirstChild("UpperTorso") and localPlayer.Character:FindFirstChild("LowerTorso") and localPlayer.Character:GetAttribute("PropMorphed") ~= true then
			if localPlayer.Character:GetAttribute("Ragdoll") then
				localPlayer.Character.UpperTorso.CanCollide = true
				localPlayer.Character.LowerTorso.CanCollide = true
				localPlayer.Character.PrimaryPart.CanCollide = true
			else
				localPlayer.Character.UpperTorso.CanCollide = canCollide
				localPlayer.Character.LowerTorso.CanCollide = canCollide

				if workspace:GetAttribute("DisableEmoteNoClip") then
					if v2 then
						localPlayer.Character.PrimaryPart.CanCollide = true
					else
						localPlayer.Character.PrimaryPart.CanCollide = false
					end
				else
					localPlayer.Character.PrimaryPart.CanCollide = false
				end
			end
		end
	end
end)

local function handle_mouse_click(point: Vector2)
	local v5 = point + Vector2.new(0, GuiService:GetGuiInset().Y)
	local absoluteSize = script.Parent.AbsoluteSize
	local v6 = wheel.AbsoluteSize.X * 0.5
	local v7 = absoluteSize * 0.5

	if Radial.Enabled and Radial.Binding and v6 < (v5 - v7).magnitude then
		Radial:StopBinding()
	end
end

mouse.Button1Down:connect(function()
	return handle_mouse_click(Vector2.new(mouse.X, mouse.Y))
end)
wheel.InputBegan:connect(function(p)
	if p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch then
		return handle_mouse_click(Vector2.new(p.Position.X, p.Position.Y))
	end
end)

function _G.ShowEmotesMenu(p)
	Radial:SetEnabled(p)
end

function _G.IsEmotesVisible()
	return Radial.Enabled
end

return Radial