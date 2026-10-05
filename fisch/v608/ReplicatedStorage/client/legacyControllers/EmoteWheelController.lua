local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local GamepadService = game:GetService("GamepadService")
local GuiService = game:GetService("GuiService")
local events = ReplicatedStorage.events
local resources = ReplicatedStorage.resources
local emotes = resources.animations.emotes
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v = Lighting:FindFirstChild("emotewheelblur")

if not v then
	v = Instance.new("BlurEffect")
	v.Name = "emotewheelblur"
	v.Size = 0
	v.Parent = Lighting
end

local main = playerGui:WaitForChild("EmoteWheel", 1800):WaitForChild("Main")
local wheel = main:WaitForChild("Wheel")
local segments = wheel:WaitForChild("Segments")
local info = wheel:WaitForChild("Info")
local emoteTemplate = wheel:WaitForChild("EmoteTemplate")
local openEmoteWheel = ReplicatedStorage.client.inputs.GlobalInterface.OpenEmoteWheel
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local library = require(ReplicatedStorage.shared.modules.library)
local paidemotes = library.paidemotes
local marketplace = require(ReplicatedStorage.shared.utils.marketplace)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
local tweenInfo4 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo5 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo7 = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
local tweenInfo8 = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
local color = Color3.fromRGB(116, 199, 255)
local color2 = Color3.new(0, 0, 0)
local color3 = Color3.fromRGB(124, 124, 124)
local color4 = Color3.new(1, 1, 1)
local cframe = CFrame.new(0, -1.5, 6)
local _ = Enum.KeyCode.B

local function fn()
	return Enum.ContextActionResult.Sink
end

local v2 = {
	Free = Color3.new(1, 1, 1),
	Supporter = Color3.fromRGB(255, 201, 65),
	["Emote Pack"] = Color3.fromRGB(244, 125, 255),
	Unobtainable = Color3.fromRGB(119, 85, 255),
	Shop = Color3.fromRGB(169, 232, 255)
}
local v3 = {
	sit = false,
	showcase = false,
	sit1 = "sit01",
	sit2 = "sit02",
	sit3 = "sit03",
	sit4 = "sit04",
	sit5 = "sit05",
	sit6 = "sit06",
	sit7 = "sit07",
	sit8 = "sit08",
	sit9 = "sit09"
}
local v4 = 1
local v5 = 1
local v6 = nil
local v7 = nil
local flag = false
local v8 = nil
local gamepassEmotes = nil
local v9 = nil
local flag2 = false
local v10 = {}
local v11 = {}
local tracksByName = {}
local count = 0
local fetched = legacyLocalPlayerData.fetch()
local emotes2 = fetched:WaitForChild("Cache"):WaitForChild("Emotes")
local EmoteWheelController = {
	GetRarityColor = function(childName: string)
		if v8 and table.find(v8, childName) then
			return v2.Free
		end

		local paidemote = paidemotes[childName]

		if paidemote and paidemote.passId then
			if paidemote.passId == 847012516 then
				return v2["Emote Pack"]
			end

			if paidemote.passId == 837478377 then
				return v2.Supporter
			end
		end

		if emotes:FindFirstChild(childName):GetAttribute("AdminEmote") then
			return v2.Unobtainable
		end

		return v2.Shop
	end,
	LoadEmoteRig = function()
		if v9 then
			return v9
		end

		local clone = ReplicatedStorage.resources.ui.emotewheel.EmoteRig:Clone()

		if localPlayer.UserId > 0 then
			clone.Parent = workspace
			local success, result = pcall(function()
				return Players:GetHumanoidDescriptionFromUserIdAsync(localPlayer.UserId)
			end)

			if success and result then
				clone:WaitForChild("Humanoid"):ApplyDescriptionAsync(result)
			end
		end

		clone.Parent = script
		v9 = clone
		return clone
	end
}

function EmoteWheelController.PlayEmote(p: string?)
	EmoteWheelController.CloseWheel()
	ReplicatedStorage.events.UseEmoteWheel:FireServer(p)
	resources.sounds.sfx.ui.click1:Play()
end

function EmoteWheelController.StopOpenCloseTweens()
	for _, v12 in v11 do
		v12:Cancel()
	end

	table.clear(v11)
	v11 = {}
end

function EmoteWheelController.PlayOpenCloseTweens(flag3: boolean)
	local v12

	if flag3 then
		v12 = tweenInfo
	else
		v12 = tweenInfo3
	end

	local v13

	if flag3 then
		v13 = tweenInfo2
	else
		v13 = tweenInfo4
	end

	v.Size = flag3 and 0 or v.Size
	local tween = TweenService:Create(v, v13, {
		Size = flag3 and 14 or 0
	})
	table.insert(v11, tween)
	tween:Play()
	local v14 = wheel
	local position

	if flag3 then
		position = UDim2.fromScale(0.5, 1.75)
	else
		position = wheel.Position
	end

	v14.Position = position
	wheel.UIScale.Scale = flag3 and 0.25 or wheel.UIScale.Scale
	wheel.GlowImageThing.ImageTransparency = flag3 and 1 or wheel.GlowImageThing.ImageTransparency
	local position2

	if flag3 then
		position2 = UDim2.fromScale(0.5, 0.5)
	else
		position2 = UDim2.fromScale(0.5, 1.75)
	end

	local v20 = TweenService:Create(wheel, v13, {
		Position = position2
	})
	table.insert(v11, v20)
	v20:Play()
	local tween2 = TweenService:Create(wheel.UIScale, v13, {
		Scale = flag3 and 1 or 0.25
	})
	table.insert(v11, tween2)
	tween2:Play()
	local tween3 = TweenService:Create(wheel.GlowImageThing, v13, {
		ImageTransparency = flag3 and 0.775 or 1
	})
	table.insert(v11, tween3)
	tween3:Play()
	segments.Rotation = flag3 and 360 or segments.Rotation
	local tween4 = TweenService:Create(segments, v12, {
		Rotation = flag3 and 0 or -360
	})
	table.insert(v11, tween4)
	tween4:Play()

	for _, child in segments:GetChildren() do
		child.Holder.Rotation = flag3 and -360 or child.Holder.Rotation
		local tween5 = TweenService:Create(child.Holder, v12, {
			Rotation = flag3 and 0 or 360
		})
		table.insert(v11, tween5)
		tween5:Play()
	end
end

function EmoteWheelController.CloseWheel()
	local v12 = count
	flag2 = false
	EmoteWheelController.StopOpenCloseTweens()
	EmoteWheelController.PlayOpenCloseTweens(false)
	task.delay(tweenInfo4.Time, function()
		if not flag2 and count == v12 then
			main.Visible = false
		end
	end)
	task.spawn(function()
		ContextActionService:UnbindAction("EmoteWheelNoScroll")
	end)
	task.defer(function()
		GamepadService:DisableGamepadCursor()
		GuiService.SelectedObject = nil
	end)
	resources.sounds.sfx.ui.popup2:Play()
end

function EmoteWheelController.OpenWheel()
	count += 1
	flag2 = true
	EmoteWheelController.StopOpenCloseTweens()
	main.Visible = true
	EmoteWheelController.PlayOpenCloseTweens(true)
	task.spawn(function()
		ContextActionService:BindAction(
			"EmoteWheelNoScroll",
			fn,
			false,
			Enum.UserInputType.MouseWheel,
			Enum.KeyCode.ButtonL1,
			Enum.KeyCode.ButtonR1,
			Enum.KeyCode.ButtonA,
			Enum.KeyCode.Thumbstick2
		)
	end)
	GamepadService:DisableGamepadCursor()
	task.delay(0.25, function()
		if flag2 then
			GuiService.SelectedObject = segments:FindFirstChild((`Segment{v6 or 1}`)).Holder.Click
		end
	end)
	resources.sounds.sfx.ui.popup:Play()
end

function EmoteWheelController.GetSegmentFrameFromNumber(p: number)
	return segments:FindFirstChild((`Segment{p}`))
end

function EmoteWheelController.UpdateInfo()
	local v12

	if v5 == 1 then
		v12 = color3
	else
		v12 = color4
	end

	info.Arrows.Right.ImageColor3 = v12
	info.Arrows.Right.UIStroke.Color = v12
	info.Arrows.Left.ImageColor3 = v12
	info.Arrows.Left.UIStroke.Color = v12
	info.PageNumber.Text = `Page {v4}/{v5}`
end

function EmoteWheelController.ForceSelectPage(p: number)
	local v12 = v10[p]

	if not v12 then
		return
	end

	v4 = p
	v7 = EmoteWheelController.GetEmoteFromSegment(v6)

	for k, v13 in v12 do
		local segmentFrame = EmoteWheelController.GetSegmentFrameFromNumber(k)
		local emoteMain = segmentFrame.Holder.Main:WaitForChild("EmoteMain")
		EmoteWheelController.DeloadPossibleRig(k)
		local rig = EmoteWheelController.GetRig(k, v13)
		rig.Name = v13
		rig:PivotTo(cframe)
		rig.Parent = emoteMain.Viewport.WorldModel
		local emoteOnRig = EmoteWheelController.LoadEmoteOnRig(rig)
		emoteOnRig:Play()
		emoteOnRig:AdjustSpeed(v6 == k and 1 or 0)
		emoteMain.Title.Text = v13
		emoteMain.Title.TextColor3 = EmoteWheelController.GetRarityColor(v13)
		segmentFrame.Holder.Main.Visible = true
	end

	if 6 - #v12 > 0 and #v12 + 1 <= 6 then
		for i = #v12 + 1, 6 do
			local getSegmentFrameFromNumber = EmoteWheelController.GetSegmentFrameFromNumber(i)
			getSegmentFrameFromNumber.Holder.Main.Visible = false
			EmoteWheelController.DeloadPossibleRig(i)
		end
	end

	EmoteWheelController.UpdateInfo()
end

function EmoteWheelController.SwitchPage(p: number)
	if v5 == 1 then
		return
	end

	local v12 = v4 + p
	local v13

	if v12 < 1 then
		v13 = v5
	else
		v13 = v5 < v12 and 1 or v12
	end

	TweenService:Create(main, tweenInfo7, {
		Position = UDim2.fromScale(0.5, 0.48)
	}):Play()
	task.delay(tweenInfo7.Time, function()
		TweenService:Create(main, tweenInfo8, {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
	end)
	resources.sounds.sfx.ui.emotepage:Play()
	EmoteWheelController.ForceSelectPage(v13)
end

function EmoteWheelController.UpdatePages(list)
	for _, v12 in v8 do
		if v3[v12] ~= false then
			table.insert(list, v12)
		end
	end

	for _, v12 in gamepassEmotes do
		if marketplace.userHasGamepassAsync(localPlayer, paidemotes[v12].passId) then
			table.insert(list, v12)
		end
	end

	table.sort(list, function(a, b)
		return string.lower(v3[a] or a) < string.lower(v3[b] or b)
	end)
	table.clear(v10)
	v10 = {}
	v5 = math.ceil(#list / 6)

	for k, v12 in list do
		local v13 = math.ceil(k / 6)
		local v14 = k % 6 == 0 and 6 or k % 6
		local v15 = v10[v13]

		if not v15 then
			v10[v13] = {}
			v15 = v10[v13]
		end

		v15[v14] = v12
	end

	EmoteWheelController.ForceSelectPage(1)
end

function EmoteWheelController.GetEmoteFromSegment(p: number?)
	if not p then
		return nil
	end

	local v12 = v10[v4]

	if v12 then
		return v12[p] or nil
	end

	return nil
end

function EmoteWheelController.OwnedEmotesUpdated(items)
	local names = {}

	for _, item in items do
		table.insert(names, item.Name)
	end

	EmoteWheelController.UpdatePages(names)
end

function EmoteWheelController.GetFreeEmotes()
	local names = {}

	for _, animation in emotes:GetChildren() do
		if not animation:IsA("Animation") or (animation:GetAttribute("Obtainable") or animation:GetAttribute("AdminEmote") or paidemotes[animation.Name]) then
			continue
		end

		table.insert(names, animation.Name)
	end

	return names
end

function EmoteWheelController.GetGamepassEmotes()
	local names = {}

	for _, animation in emotes:GetChildren() do
		if animation:IsA("Animation") and paidemotes[animation.Name] then
			table.insert(names, animation.Name)
		end
	end

	return names
end

function EmoteWheelController.LoadEmoteOnRig(parent)
	local name = parent.Name
	local v12 = tracksByName[name]

	if v12 then
		return v12
	end

	local child = emotes:FindFirstChild(name)

	if not parent:GetAttribute("AnimationObjectsLoaded") then
		if child:FindFirstChild("EmoteModel") then
			local clone = child:FindFirstChild("EmoteModel"):Clone()
			clone.Parent = parent

			for _, part in clone:GetChildren() do
				if part:FindFirstChildWhichIsA("Motor6D") then
					if part.Name == "fan" then
						local motor6D = part:FindFirstChildWhichIsA("Motor6D")
						motor6D.Part0 = parent:FindFirstChild("Left Arm")
					else
						local motor6D_2 = part:FindFirstChildWhichIsA("Motor6D")
						motor6D_2.Part0 = parent[part:FindFirstChildWhichIsA("Motor6D"):GetAttribute("WeldTo")]
					end

					local motor6D_3 = part:FindFirstChildWhichIsA("Motor6D")
					motor6D_3.Part1 = part
				end

				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Anchored = false
				part.Massless = true
			end
		end

		parent:SetAttribute("AnimationObjectsLoaded", true)
	end

	local track = parent:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(child)
	tracksByName[name] = track
	return track
end

function EmoteWheelController.DeloadPossibleRig(p: number)
	local model = EmoteWheelController.GetSegmentFrameFromNumber(p):WaitForChild("Holder"):WaitForChild("Main"):WaitForChild("EmoteMain"):WaitForChild("Viewport"):WaitForChild("WorldModel"):FindFirstChildOfClass("Model")

	if model then
		model.Parent = script.DeloadedRigs
	end
end

function EmoteWheelController.GetRig(p: number, childName: string, flag3: boolean?)
	local child = script.DeloadedRigs:FindFirstChild(childName)

	if child then
		return child
	end

	local child2 = EmoteWheelController.GetSegmentFrameFromNumber(p):WaitForChild("Holder"):WaitForChild("Main"):WaitForChild("EmoteMain"):WaitForChild("Viewport"):WaitForChild("WorldModel"):FindFirstChild(childName)

	if child2 then
		return child2
	end

	if flag3 then
		return
	else
		return (v9:Clone())
	end
end

function EmoteWheelController.PauseAnimation(p: number)
	local emote = EmoteWheelController.GetEmoteFromSegment(p)

	if not emote then
		return
	end

	local rig = EmoteWheelController.GetRig(p, emote, true)

	if not rig then
		return
	end

	local emoteOnRig = EmoteWheelController.LoadEmoteOnRig(rig)

	if not emoteOnRig.IsPlaying then
		emoteOnRig:Play()
	end

	emoteOnRig:AdjustSpeed(0)
end

function EmoteWheelController.ResumeAnimation(p: number)
	local emote = EmoteWheelController.GetEmoteFromSegment(p)

	if not emote then
		return
	end

	local rig = EmoteWheelController.GetRig(p, emote, true)

	if not rig then
		return
	end

	local emoteOnRig = EmoteWheelController.LoadEmoteOnRig(rig)

	if not emoteOnRig.IsPlaying then
		emoteOnRig:Play()
	end

	emoteOnRig:AdjustSpeed(1)
end

function EmoteWheelController.Start(_)
	v8 = EmoteWheelController.GetFreeEmotes()
	gamepassEmotes = EmoteWheelController:GetGamepassEmotes()
	EmoteWheelController.LoadEmoteRig()

	for _, child in segments:GetChildren() do
		local v12 = tonumber((string.gsub(child.Name, "Segment", "")))
		local background = child:WaitForChild("Background")
		local holder = child:WaitForChild("Holder")
		local click = holder:WaitForChild("Click")
		click.SelectionImageObject = script.dummySIO
		local clone = emoteTemplate:Clone()
		clone.Name = "EmoteMain"
		clone.Visible = true
		clone.Parent = holder:WaitForChild("Main")
		local v14 = child

		local function onHover()
			if not flag2 then
				return
			end

			v6 = v12
			v7 = EmoteWheelController.GetEmoteFromSegment(v6)

			for i, child2 in segments:GetChildren() do
				if child2 ~= v14 then
					child2:SetAttribute("IsHovered", false)
				end
			end

			TweenService:Create(background, tweenInfo5, {
				ImageColor3 = color
			}):Play()
			TweenService:Create(v14.UIScale, tweenInfo5, {
				Scale = 1.05
			}):Play()
			resources.sounds.sfx.ui.emotehover:Play()
			EmoteWheelController.ResumeAnimation(v6)
		end

		local v16 = v12
		local v17 = background
		local v18 = child

		local function onLeave()
			if not flag2 then
				return
			end

			if v6 == v16 then
				v6 = nil
			end

			TweenService:Create(v17, tweenInfo6, {
				ImageColor3 = color2
			}):Play()
			TweenService:Create(v18.UIScale, tweenInfo6, {
				Scale = 1
			}):Play()
			EmoteWheelController.PauseAnimation(v16)
		end

		local v19 = child
		local onHover2 = onHover
		local onLeave2 = onLeave
		child:GetAttributeChangedSignal("IsHovered"):Connect(function()
			if v19:GetAttribute("IsHovered") then
				onHover2()
			else
				onLeave2()
			end
		end)
		local v20 = child
		click.MouseEnter:Connect(function()
			v20:SetAttribute("IsHovered", true)
		end)
		local v21 = child
		click.MouseLeave:Connect(function()
			v21:SetAttribute("IsHovered", false)
		end)
		local v22 = child
		click.SelectionGained:Connect(function()
			v22:SetAttribute("IsHovered", true)
		end)
		click.Activated:Connect(function()
			if v6 and v7 and flag2 then
				EmoteWheelController.PlayEmote(v7)
			end
		end)
	end

	EmoteWheelController.OwnedEmotesUpdated(emotes2:GetChildren())
	emotes2.ChildAdded:Connect(function(numberValue)
		if numberValue:IsA("NumberValue") then
			EmoteWheelController.OwnedEmotesUpdated(emotes2:GetChildren())
		else
			warn((`[{script.Name}]: Invalid emote added to data: {numberValue.Name} (Expected NumberValue, got {numberValue.ClassName})`))
		end
	end)
	emotes2.ChildRemoved:Connect(function(_)
		EmoteWheelController.OwnedEmotesUpdated(emotes2:GetChildren())
	end)
	fetched:WaitForChild("Gamepasses").ChildAdded:Connect(function()
		EmoteWheelController.OwnedEmotesUpdated(emotes2:GetChildren())
	end)
	fetched:WaitForChild("Gamepasses").ChildRemoved:Connect(function()
		EmoteWheelController.OwnedEmotesUpdated(emotes2:GetChildren())
	end)
	UserInputService.InputBegan:Connect(function(input, _: boolean)
		if flag2 then
			if input.KeyCode == Enum.KeyCode.ButtonR1 then
				EmoteWheelController.SwitchPage(1)
			elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
				EmoteWheelController.SwitchPage(-1)
			elseif input.KeyCode == Enum.KeyCode.ButtonA then
				if v6 and v7 and flag2 then
					EmoteWheelController.PlayEmote(v7)
				else
					task.wait()
					EmoteWheelController.CloseWheel()
				end
			end
		end
	end)
	openEmoteWheel.Pressed:Connect(function()
		if flag2 then
			EmoteWheelController.CloseWheel()
		else
			EmoteWheelController.OpenWheel()
		end
	end)
	openEmoteWheel.Released:Connect(function()
		if v6 and v7 and flag2 and UserInputService.PreferredInput == Enum.PreferredInput.KeyboardAndMouse then
			EmoteWheelController.PlayEmote(v7)
		else
			EmoteWheelController.CloseWheel()
		end
	end)
	UserInputService.InputChanged:Connect(function(input, _: boolean)
		if not flag2 then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			EmoteWheelController.SwitchPage(input.Position.Z > 0 and -1 or 1)
		elseif input.KeyCode == Enum.KeyCode.Thumbstick2 then
			local unit = input.Position.Unit
			local v12 = unit.Y > 0.5 and 1 or unit.Y < -0.5 and 3 or 2

			if unit.X < 0 then
				v12 = 7 - v12
			end

			local v13 = (v12 + 1) % 6
			local v14 = v13 == 0 and 6 or v13

			for _, child in segments:GetChildren() do
				child:SetAttribute("IsHovered", child.Name == `Segment{v14}`)
			end

			GuiService.SelectedObject = segments:FindFirstChild((`Segment{v14}`)) and segments:FindFirstChild((`Segment{v14}`)).Holder.Click
		end
	end)
	info.Arrows.Left.Activated:Connect(function()
		EmoteWheelController.SwitchPage(-1)
	end)
	info.Arrows.Right.Activated:Connect(function()
		EmoteWheelController.SwitchPage(1)
	end)
	events.toggleemotewheel.Event:Connect(function()
		if flag then
			return
		end

		flag = true
		task.delay(0.05, function()
			flag = false
		end)

		if flag2 then
			EmoteWheelController.CloseWheel()
		else
			EmoteWheelController.OpenWheel()
		end
	end)
end

return EmoteWheelController