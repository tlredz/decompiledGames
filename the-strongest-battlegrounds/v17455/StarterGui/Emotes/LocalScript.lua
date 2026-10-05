repeat
	task.wait()
until game.IsLoaded

local localPlayer = game.Players.LocalPlayer
local imageLabel = script.Parent.ImageLabel
require(game.ReplicatedStorage.Emotes)
local Emotes = require(game.ReplicatedStorage.Emotes)
local table2 = Emotes:GetTable()
local Emotes2 = require(game.ReplicatedStorage.Emotes)
local table3 = Emotes2:GetTable(true)
local UserInputService = game:GetService("UserInputService")
local gamepadEnabled = UserInputService.GamepadEnabled
local touchEnabled = UserInputService.TouchEnabled
local ActionCheck = require(game.ReplicatedStorage.ActionCheck)
local Info = require(game.ReplicatedStorage.Info)
local RunService = game:GetService("RunService")
local isStudio = RunService:IsStudio()
local TweenService = game:GetService("TweenService")
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(171, 66, 66)
local color3 = Color3.fromRGB(255, 194, 38)
local scrollingFrame = script.ScrollingFrame
local owned = scrollingFrame.Owned
local v = {}
local table4 = {}
local table5 = {}
local table6 = {
	"Boundless Rage",
	"Final Stand",
	"Divine Form",
	"Inner Rage",
	"Shadow Eruption",
	"True Aura"
}
local previews = {}
local v5 = {}
local flag = false
local clonesByName = {}

for _, child in pairs(imageLabel:GetChildren()) do
	table.insert(v, child.Name)
end

if touchEnabled then
	imageLabel.Position = UDim2.new(0.5, 0, 0.45, 0)
end

local v6 = {
	KillEmote = {
		Text = "Kill Emote",
		AttributeName = "KillEmote",
		Table = table4,
		ImageColor3 = color2
	},
	MeleeEffects = {
		Text = "Melee Effect",
		AttributeName = "MeleeEffect",
		Table = table5,
		ImageColor3 = color
	},
	AuraEffect = {
		Text = "Aura Effect",
		AttributeName = "AuraEffect",
		Table = table6,
		ImageColor3 = color3
	}
}
local colorFrame = script.ColorFrame
local extraScrollingFrame = script.extraScrollingFrame
local connections = {}
local switch = script.Parent.ImageLabel:WaitForChild("Switch", 1)
scrollingFrame:GetPropertyChangedSignal("Parent"):Connect(function()
	local visible = scrollingFrame.Parent == script
	imageLabel.Spin.Visible = visible
	imageLabel.Bulk.Visible = visible
	imageLabel.Limited.Visible = visible

	if visible then
		switch.Visible = true
		colorFrame.Parent = script
		extraScrollingFrame.Parent = script
		loadoutupd()
	else
		local emote = scrollingFrame.Parent:GetAttribute("Emote")
		local v8 = table3[emote]

		if v8 then
			if v8.CanColor then
				colorFrame.Parent = scrollingFrame.Parent
			end

			if v8.extraoptions then
				switch.Visible = false

				local function fn(instance, _)
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(instance.EmoteGlow, TweenInfo.new(0.15), {
						ImageColor3 = instance:GetAttribute("enabled") and Color3.fromRGB(93, 171, 112) or Color3.fromRGB(
							171,
							69,
							71
						)
					}):Play()
				end

				for _, uIListLayout in pairs(extraScrollingFrame:GetChildren()) do
					if not uIListLayout:IsA("UIListLayout") then
						uIListLayout:Destroy()
					end
				end

				for _, connection in pairs(connections) do
					connection:Disconnect()
				end

				table.clear(connections)
				local HttpService = game:GetService("HttpService")
				local jSONDecode = HttpService:JSONDecode(localPlayer:GetAttribute("EmoteExtraOptions") or "[]")

				for k, extraoption in pairs(v8.extraoptions) do
					local clone = script.itemtemplate:Clone()
					local defaultenabled = extraoption.defaultenabled ~= false
					clone.Parent = extraScrollingFrame
					clone.Text = k

					if jSONDecode[emote] and jSONDecode[emote][k] ~= nil then
						defaultenabled = jSONDecode[emote][k]
					end

					clone:SetAttribute("enabled", defaultenabled)
					fn(clone)
					local option = k
					table.insert(connections, clone.MouseButton1Down:Connect(function()
						local enabled = not clone:GetAttribute("enabled")
						clone:SetAttribute("enabled", enabled)
						fn(clone)

						if localPlayer.Character then
							localPlayer.Character.Communicate:FireServer({
								Goal = "EmoteExtraOption",
								Emote = emote,
								Option = option,
								Enabled = enabled
							})
						end
					end))
				end

				extraScrollingFrame.Parent = scrollingFrame.Parent
			end
		end
	end
end)
local text2 = string.format(
	"<font size=\"30\">CLAIM NEW EMOTE</font>\n<font size=\"18\">%s ME!</font>",
	touchEnabled and "PRESS" or "CLICK"
)
local tracksByPreview = {}
local clonesByName2 = {}

local function fn()
	local children = {}

	for _, child in pairs(workspace.Live:GetChildren()) do
		if not (tostring(child) ~= tostring(localPlayer) and child:FindFirstChild("Humanoid") and child:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local humanoid = child:FindFirstChild("Humanoid")
		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		if not (humanoid.Health <= 0) or not ((humanoidRootPart.Position - localPlayer.Character.PrimaryPart.Position).Magnitude <= 10) or child:FindFirstChild("KillEmoteFinished") or not child:FindFirstChild("Torso") then
			continue
		end

		if child:FindFirstChild("Torso").Transparency == 1 or (child:GetAttribute("KillEmoteBegan") or child:GetAttribute("supplexed") or child:GetAttribute("BreakJointed")) then
			continue
		end

		local playerFromCharacter = game.Players:GetPlayerFromCharacter(child)

		if not (playerFromCharacter and (playerFromCharacter:GetAttribute("DiedTime") or 0) >= 2) then
			table.insert(children, child)
		end
	end

	local v8 = 20
	local v9 = nil

	for _, v10 in pairs(children) do
		local magnitude = (v10:FindFirstChild("HumanoidRootPart").Position - localPlayer.Character.PrimaryPart.Position).Magnitude

		if not (magnitude < v8) then
			continue
		end

		v9 = v10
		v8 = magnitude
	end

	if workspace:GetAttribute("RoyaleCustom") then
		return nil
	end

	if v9 then
		return v9
	end
end

local function fn2(p, value, p2)
	local radial = p.Radial
	local v8 = (value or 16) / 160
	radial.Visible = true
	local v9 = {
		"rbxassetid://95007903269647",
		"rbxassetid://71926048514582",
		"rbxassetid://111515469080408",
		"rbxassetid://99378878471592",
		"rbxassetid://124125109911613",
		"rbxassetid://112905073377905",
		"rbxassetid://94584979745998",
		"rbxassetid://123498196278321",
		"rbxassetid://98495583544127",
		"rbxassetid://108071026812990"
	}
	local v10 = {}

	for k, image in pairs(v9) do
		if not (k > 2) then
			continue
		end

		local imageLabel2 = Instance.new("ImageLabel")
		imageLabel2.Size = UDim2.new(0.001, 0, 0.001, 0)
		imageLabel2.ImageTransparency = 0.99
		imageLabel2.Image = image
		imageLabel2.BackgroundTransparency = 1
		imageLabel2.Parent = radial
		table.insert(v10, imageLabel2)
	end

	for _, image in pairs(v9) do
		radial.Image = image

		for i = 3, 0, -1 do
			for i2 = 3, 0, -1 do
				radial.ImageRectOffset = Vector2.new(i2 * 225, i * 225)
				task.wait(v8)
			end
		end
	end

	v5[p2] = nil
	radial.Visible = false

	for _, v11 in pairs(v10) do
		v11:Destroy()
	end
end

local flag2 = false

local function fn3(position, name)
	local clone = script.Frame:Clone()
	local button = clone.Button
	local worldModel = clone.ViewportFrame.WorldModel
	clone.Parent = imageLabel
	clone.Name = name
	clone.Position = position
	clonesByName2[name] = clone
	local preview = worldModel.Preview
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://13716964686"
	animation.Parent = preview
	local camera = Instance.new("Camera")
	camera.CFrame = preview.PrimaryPart.CFrame * CFrame.new(0, 1, -5) * CFrame.Angles(
		0.3490658503988659,
		3.141592653589793,
		0
	)
	camera.Parent = clone
	clone.ViewportFrame.CurrentCamera = camera
	local track = preview.Humanoid.Animator:LoadAnimation(animation)
	track.Looped = true

	if imageLabel.Visible then
		track:Play()
	end

	tracksByPreview[preview] = track
	table.insert(previews, preview)

	local function fn4()
		local v8 = string.byte((string.sub(clone.EmoteName.Text, 1, 1)))
		local layoutOrder = tonumber((string.sub(clone.EmoteName.Text, 1, 1))) and 150 or v8
		local emote = clone:GetAttribute("Emote") or "Crush"

		for _, label in pairs(clone:GetChildren()) do
			if label:IsA("TextLabel") and tostring(label) == "Clone" then
				label:Destroy()
			end
		end

		clone.EmoteName.Visible = true
		clone.EmoteName.Text = emote
		clone.EmoteProperty.Text = "2 Player"
		clone.EmoteProperty.Visible = clone:GetAttribute("Dual")
		clone.EmoteProperty.ZIndex = 3
		clone.LayoutOrder = layoutOrder
		local fade = clone.Fade
		local v10 = table3[tostring(emote)]
		local flag3 = false

		for _, v12 in pairs(table6) do
			if tostring(clone:GetAttribute("Emote")) == v12 then
				flag3 = true
			end
		end

		if v10 and (v10.KillEmote or v10.MeleeEffects) or flag3 then
			for _, v12 in pairs({ "KillEmote", "MeleeEffect", "AuraEffect" }) do
				clone:SetAttribute(v12, false)
			end

			local auraEffect = v6

			if flag3 then
				auraEffect = v6.AuraEffect
			elseif v10.KillEmote then
				auraEffect = v6.KillEmote
			elseif v6.MeleeEffects then
				auraEffect = v6.MeleeEffects
			end

			local emoteProperty = clone.EmoteProperty
			emoteProperty.Text = auraEffect.Text
			emoteProperty.Visible = true
			emoteProperty.ZIndex = 30
			fade.ImageColor3 = auraEffect.ImageColor3
			clone:SetAttribute(auraEffect.AttributeName, true)

			for _, list in pairs({ table4, table5 }) do
				if table.find(list, clone) then
					table.remove(list, table.find(list, clone))
				end
			end

			if auraEffect.Table and not table.find(auraEffect.Table, clone) then
				table.insert(auraEffect.Table, clone)
			end
		else
			fade.ImageColor3 = Color3.fromRGB(0, 0, 0)

			if table.find(table4, clone) then
				table.remove(table4, table.find(table4, clone))
				clone:SetAttribute("KillEmote", false)
			end
		end
	end

	clone:GetAttributeChangedSignal("Emote"):Connect(fn4)
	fn4()
	clone:GetAttributeChangedSignal("Animation"):Connect(function()
		track:Stop()
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = clone:GetAttribute("Animation")
		animation2.Parent = preview
		track = preview.Humanoid.Animator:LoadAnimation(animation2)
		track.Looped = true

		if imageLabel.Visible then
			track:Play()
		end

		tracksByPreview[preview] = track
	end)
	local fn5 = nil
	button.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not imageLabel.Visible then
				return
			end

			fn5 = function()
				fn5 = nil
			end

			if flag2 then
				return
			end

			flag2 = true
			task.delay(0.25, function()
				flag2 = false
			end)
			local lastTime = tick()

			while true do
				if fn5 then
					task.wait()
				end

				if not (not fn5 or tick() - lastTime > 0.5) then
					continue
				end

				if tick() - lastTime > 0.5 and fn5 then
					local v8 = scrollingFrame.Parent == clone
					scrollingFrame:SetAttribute("Number", name)
					scrollingFrame.Parent = v8 and script or clone
					shared.sfx({
						SoundId = "rbxassetid://5797580410",
						Parent = workspace,
						Volume = 0.75
					}):Play()

					for _, v9 in pairs(clonesByName2) do
						if v9 ~= clone then
							v9.Visible = v8 and true or false
						end
					end

					return
				else
					scrollingFrame.Parent = script

					for _, v8 in pairs(clonesByName2) do
						v8.Visible = true
					end

					imageLabel.Visible = false
					local character = localPlayer.Character

					if not character then
						break
					end

					if character:FindFirstChild("NoRotate") or not (character:FindFirstChild("DoingEmote") or ActionCheck:Check(
						character,
						{ "Emote" }
					)) then
						return
					end

					if tick() - (character:GetAttribute("_JustDashed") or 0) < 0.4 then
						return
					end

					if clone:GetAttribute("KillEmote") then
						local v8 = fn()
						local v9, message

						if v8 and v8:FindFirstChild("KillEmoteFinished") then
							v9 = false
							message = "THIS PLAYER HAS ALREADY BEEN EMOTED ON!"
						else
							v9 = v8 and true or false
							message = "YOU MUST BE NEXT TO A DEAD PLAYER TO USE THIS EMOTE!"
						end

						if not v9 then
							shared.repfire({
								Effect = "Notification",
								Message = message
							})
							return
						end
					end

					local emote = clone:GetAttribute("Emote") or "Crush"
					local cooldown = table3[emote].Cooldown

					if cooldown and isStudio then
						cooldown = nil

						if not _G.gerg then
							_G.gerg = true
							warn("NO EMOTE CD < STUDIO")
						end
					end

					if cooldown then
						if v5[emote] or clone.Radial.Visible then
							return
						end

						clone.Radial.Visible = true
						clone.Radial.Image = "rbxassetid://95007903269647"
						clone.Radial.ImageRectOffset = Vector2.new(675, 675)
						v5[emote] = 1e999
						local character2 = character
						local v9 = emote
						task.spawn(function()
							local v10 = nil
							local lastTime2 = tick()
							local childAddedConnection = nil
							childAddedConnection = character2.ChildAdded:Connect(function(child)
								if child.Name ~= "DoingEmote" or child:GetAttribute("Name") ~= v9 then
									return
								end

								v10 = child
								return childAddedConnection:Disconnect()
							end)

							repeat
								task.wait()
							until v10 or tick() - lastTime2 > 1

							childAddedConnection:Disconnect()

							if tick() - lastTime2 > 1 then
								clone.Radial.Visible = false
								v5[v9] = nil
							elseif v10 and v10:GetAttribute("Name") == v9 then
								local lastTime3 = tick()

								repeat
									task.wait()
								until not v10 or not v10.Parent or tick() - lastTime3 > 13 or not character2.Parent

								if tick() - lastTime3 > 13 then
									clone.Radial.Visible = false
									v5[v9] = nil
								else
									v5[v9] = tick() + cooldown
									task.spawn(fn2, clone, cooldown, v9)
								end
							else
								v5[v9] = nil
							end
						end)
					end

					character:SetAttribute("EmoteStarted", tick())
					character:SetAttribute("SideDashDisable", tick())
					character.Communicate:FireServer({
						Goal = "Emote",
						Emote = emote
					})
					break
				end
			end
		end
	end)
	button.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and fn5 then
			fn5()
		end
	end)
	return clone
end

tick()
local layoutOrder2 = -100
local v9 = {}

local function fn4()
	local emotes = localPlayer:GetAttribute("Emotes") or "[]"
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(emotes)

	for i = 1, math.floor(#jSONDecode / 2) do
		local v10 = #jSONDecode - i + 1
		local v11 = jSONDecode[v10]
		local v12 = jSONDecode[i]
		jSONDecode[i] = v11
		jSONDecode[v10] = v12
	end

	for _, text in pairs(jSONDecode) do
		if scrollingFrame.ScrollingFrame:FindFirstChild(text .. "em") or not table3[text] then
			continue
		end

		local clone = script.TextButton:Clone()
		clone.Text = text
		clone.Name = text .. "em"
		local v11 = table3[tostring(text)]
		local v12 = {}
		local imageColor = nil

		for k, v14 in pairs(v6) do
			table.insert(v12, { k, v14.ImageColor3 })
		end

		for _, v14 in pairs(v12) do
			if not (v11 and v11[v14[1]]) then
				continue
			end

			imageColor = v14[2]
			clone:SetAttribute("Type", (tostring(v14[1])))
		end

		if imageColor then
			local clone2 = script.EmoteGlow:Clone()
			clone2.ImageColor3 = imageColor
			clone2.Parent = clone
		end

		tonumber((string.sub(clone.Name:lower(), 1, 1)))
		clone.Parent = scrollingFrame.ScrollingFrame
		local clone2

		if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("NewEmotes") then
			clone2 = script.Glow:Clone()
			clone2.Parent = clone
			clone.LayoutOrder = layoutOrder2
			layoutOrder2 -= 1
			scrollingFrame.ScrollingFrame.CanvasPosition = Vector2.new(0, 0, 0, 0)
		else
			clone2 = nil
		end

		v9[clone] = clone2 or true
		local text3 = text
		clone.MouseEnter:Connect(function()
			(function(p)
				local parent = scrollingFrame.Parent

				if p then
					loadoutupd()
				else
					parent.EmoteName.Text = text3
					parent:SetAttribute("Animation", "rbxassetid://" .. table3[text3].Animation)
				end

				local glow = parent.Glow
				local number = Random.new():NextNumber(2.5, 3)
				glow.ImageTransparency = 0.25
				glow.Size = UDim2.new(number, 0, number, 0)
				TweenService:Create(glow, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = 1
				}):Play()
			end)()
		end)

		if not gamepadEnabled then
			continue
		end

		local emote = text
		clone.MouseButton1Click:Connect(function()
			scrollingFrame.Parent = script

			for k, v16 in pairs(clonesByName2) do
				v16.Visible = true
			end

			if clone2 then
				clone2:Destroy()
			end

			local character = localPlayer.Character

			if character then
				shared.sfx({
					SoundId = "rbxassetid://6493287948",
					Parent = workspace,
					Volume = 0.65
				}):Play()
				character.Communicate:FireServer({
					Goal = "EmoteLoadout",
					Emote = emote,
					Loadout = tonumber(scrollingFrame:GetAttribute("Number") or 1)
				})
			end
		end)
	end
end

local UserInputService2 = game:GetService("UserInputService")
UserInputService2.InputEnded:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position
		local guiObjectsAtPosition = localPlayer.PlayerGui:GetGuiObjectsAtPosition(position.X, position.Y)

		for _, v10 in pairs(guiObjectsAtPosition) do
			if not (string.sub(v10.Name, #v10.Name - 1, #v10.Name) == "em" and v9[v10]) then
				continue
			end

			local v11 = v9[v10]
			scrollingFrame.Parent = script

			for _, v12 in pairs(clonesByName2) do
				v12.Visible = true
			end

			if v11 and typeof(v11) == "Instance" then
				v11:Destroy()
			end

			local character = localPlayer.Character

			if not character then
				break
			end

			shared.sfx({
				SoundId = "rbxassetid://6493287948",
				Parent = workspace,
				Volume = 0.65
			}):Play()
			character.Communicate:FireServer({
				Goal = "EmoteLoadout",
				Emote = string.sub(v10.Name, 0, #v10.Name - 2),
				Loadout = tonumber(scrollingFrame:GetAttribute("Number") or 1)
			})
			return
		end
	end
end)
localPlayer:GetAttributeChangedSignal("Emotes"):Connect(function()
	fn4(true)
end)
fn4()
local now = 0
scrollingFrame.Framechh.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
	now = tick()
	task.delay(0.3, function()
		if tick() - now > 0.3 then
			local text = scrollingFrame.Framechh.TextBox.Text

			for _, button in pairs(scrollingFrame.ScrollingFrame:GetChildren()) do
				if not button:IsA("TextButton") then
					continue
				end

				local flag3 = false
				local name = button.Name

				if string.sub(string.lower(name), 1, (string.len(text))) == string.lower(text) then
					flag3 = true
				else
					local parts = button.Name:split(" ")

					if #parts > 1 then
						for _, part in pairs(parts) do
							if string.sub(string.lower(part), 1, (string.len(text))) ~= string.lower(text) then
								continue
							end

							flag3 = true
							break
						end
					end
				end

				if flag3 then
					button.Visible = true
				else
					button.Visible = false
				end
			end
		end
	end)
end)
local scrollingFrame2 = scrollingFrame.ScrollingFrame
scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame2.UIListLayout.AbsoluteContentSize.Y)
scrollingFrame2.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame2.CanvasSize = UDim2.new(0, 0, 0, scrollingFrame2.UIListLayout.AbsoluteContentSize.Y)
end)

local function fn5()
	local emoteLoadout = localPlayer:GetAttribute("EmoteLoadout") or "[]"
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(emoteLoadout)

	for k, text in pairs(jSONDecode) do
		local v11 = rawget(clonesByName2, (tonumber(k)))

		if not v11 then
			continue
		end

		v11:SetAttribute("Dual", table3[text] and table3[text].Dual and true or false)
		v11:SetAttribute("Emote", text)
		v11.EmoteName.Text = text
		local animation = table3[text] and table3[text].Animation or table3.Crush.Animation
		local v12

		if typeof(animation) == "Instance" then
			local RunService2 = game:GetService("RunService")

			if RunService2:IsStudio() then
				local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
				v12 = KeyframeSequenceProvider:RegisterKeyframeSequence(animation)
			else
				v12 = "rbxassetid://0"
			end
		else
			v12 = "rbxassetid://" .. animation
		end

		v11:SetAttribute("Animation", v12)
	end
end

loadoutupd = fn5
local v10 = {
	UDim2.new(0.5, 0, 0.115, 0),
	UDim2.new(0.095, 0, 0.5, 0),
	UDim2.new(0.5, 0, 0.9, 0),
	UDim2.new(0.903, 0, 0.498, 0)
}
local gamepadEnabled2 = UserInputService.GamepadEnabled
local v11 = {}
local v12 = false
local v13 = false

local function fn6(p)
	local gamepass = script.Parent.ImageLabel.Gamepass
	gamepass.Visible = not localPlayer:GetAttribute("ExtraSlots")

	if gamepadEnabled2 then
		gamepass.Visible = false
	elseif not gamepass.Visible then
		local gamepassTwo = script.Parent.ImageLabel.GamepassTwo
		gamepassTwo.Visible = not localPlayer:GetAttribute("EmoteSearchBar")

		if not gamepassTwo:GetAttribute("coddn") then
			gamepassTwo:SetAttribute("coddn", true)

			local function onMouseButton1Click()
				local MarketplaceService = game:GetService("MarketplaceService")
				MarketplaceService:PromptGamePassPurchase(localPlayer, 793925178)
			end

			gamepassTwo.Spin.MouseButton1Click:Connect(onMouseButton1Click)
			gamepassTwo.MouseButton1Click:Connect(onMouseButton1Click)
		end
	end

	local function onMouseButton1Click()
		localPlayer.Character.Communicate:FireServer({
			Goal = "Prompt Emote Purchase"
		})
	end

	if not gamepass:GetAttribute("con") then
		gamepass:SetAttribute("con", true)
		gamepass.Spin.MouseButton1Click:Connect(onMouseButton1Click)
		gamepass.MouseButton1Click:Connect(onMouseButton1Click)
		task.spawn(function()
			local MarketplaceService = game:GetService("MarketplaceService")
			local productInfo = MarketplaceService:GetProductInfo(229966673, Enum.InfoType.GamePass)
			gamepass.Spin.Text = string.gsub(gamepass.Spin.Text, "99 ROBUX", productInfo.PriceInRobux .. " ROBUX")
		end)
	end

	scrollingFrame.Gamepass.Visible = false
	localPlayer:GetAttribute("EmoteSearchBar")
	scrollingFrame.Framechh.Visible = true

	if localPlayer:GetAttribute("EmoteSearchBar") then
		imageLabel.Switch.Visible = true

		if localPlayer:GetAttribute("ExtraSlots") then
			imageLabel.Switch.Position = UDim2.new(0.5, 0, 0.5, 0)
		end
	end

	if localPlayer:GetAttribute("ExtraSlots") and not v12 then
		v12 = true

		if p then
			scrollingFrame.Parent = script
			v13 = false

			for _, v14 in pairs(clonesByName2) do
				v14:Destroy()
			end

			table.clear(previews)
			table.clear(clonesByName2)
		end

		script.Frame.Size = UDim2.new(0.285, 0, 0.285, 0)

		for _, v14 in pairs({
			UDim2.new(0.215, 0, 0.24, 0),
			UDim2.new(0.785, 0, 0.24, 0),
			UDim2.new(0.215, 0, 0.76, 0),
			UDim2.new(0.785, 0, 0.76, 0)
		}) do
			table.insert(v10, v14)
		end

		if p then
			for k, v14 in pairs(v10) do
				fn3(v14, k)
			end
		end
	end

	if not v13 then
		v13 = true

		for k, v14 in pairs(v10) do
			local v15 = fn3(v14, #v10 + k)
			v15.Button.Visible = false
			v15.UIAspectRatioConstraint.AspectRatio = 0.0001
			v15.Active = false
			v11[v15] = true
		end
	end
end

fn6()

for k, v14 in pairs(v10) do
	fn3(v14, k)
end

local v14 = false
imageLabel.Switch.MouseButton1Click:Connect(function()
	shared.sfx({
		SoundId = "rbxassetid://5797580410",
		Parent = workspace,
		Volume = 0.75
	}):Play()

	for _, v15 in pairs(clonesByName2) do
		if (v11[v15] and true or false) == not v14 then
			v15.Button.Visible = true
			v15.UIAspectRatioConstraint.AspectRatio = 1
			v15.Active = true
		else
			v15.UIAspectRatioConstraint.AspectRatio = 0.0001
			v15.Button.Visible = false
			v15.Active = false
		end
	end

	v14 = not v14
end)
imageLabel:GetPropertyChangedSignal("Visible"):Connect(function()
	if imageLabel.Visible then
		for _, v15 in pairs(previews) do
			if tracksByPreview[v15] then
				tracksByPreview[v15]:Play(0)
			end
		end
	else
		for _, v15 in pairs(previews) do
			for _, v16 in pairs(v15.Humanoid.Animator:GetPlayingAnimationTracks()) do
				v16:Stop()
			end
		end
	end
end)
local CollectionService = game:GetService("CollectionService")
imageLabel.Visible = false

local function fn7(text)
	for _, v15 in pairs(table4) do
		if v15 and v15:FindFirstChild("EmoteProperty") then
			v15.EmoteProperty.Text = text
		end
	end
end

local startOfYear = nil
local currentWeek = nil
local secondsInWeek = nil

local function timeUntilNextWeek()
	if not secondsInWeek then
		return "???"
	end

	local v15 = startOfYear + currentWeek * secondsInWeek
	local v16 = os.difftime(v15, os.time())
	local v17 = math.floor(v16 / 86400)
	local v18 = v16 % 86400
	local v19 = math.floor(v18 / 3600)
	local v20 = v18 % 3600
	local v21 = math.floor(v20 / 60)
	local v22 = v20 % 60
	local v23 = {}

	if v17 > 0 then
		table.insert(v23, v17 .. "d")
	end

	if v19 > 0 then
		table.insert(v23, v19 .. "h")
	end

	if v21 > 0 then
		table.insert(v23, v21 .. "m")
	end

	table.insert(v23, math.clamp(v22, 1, 60) .. "s")
	return table.concat(v23, " ")
end

function shared.emotegui(visible, p)
	if localPlayer:GetAttribute("MoveEditorEnabled") then
		imageLabel.Visible = false
		return
	end

	if p then
		return imageLabel.Visible
	end

	if not imageLabel.Visible then
		Info.hideGUI(script.Parent)
	end

	if visible == nil then
		imageLabel.Visible = not imageLabel.Visible
	else
		imageLabel.Visible = visible
		shared.virtualcursor(script.Parent)
	end

	if imageLabel.Visible then
		if flag then
			return
		end

		flag = true
		task.spawn(function()
			while imageLabel.Visible do
				imageLabel.Limited.Timer.Timer.Text = "Leaving in " .. timeUntilNextWeek()
				local v15 = fn()

				if v15 and not v15:FindFirstChild("KillEmoteFinished") then
					fn7("USE!")
				else
					fn7("Kill Emote")
				end

				task.wait(0.1)
			end

			flag = false
		end)
	else
		scrollingFrame.Parent = script

		for _, v15 in pairs(clonesByName2) do
			v15.Visible = true
		end

		for _ = 1, 10 do
			local preview = imageLabel:FindFirstChild("Preview")

			if not preview then
				break
			end

			preview:Destroy()
		end
	end

	for _, v15 in pairs(CollectionService:GetTagged("gamewins")) do
		v15.Visible = not imageLabel.Visible
	end
end

pcall(fn5)
localPlayer:GetAttributeChangedSignal("EmoteLoadout"):Connect(fn5)
localPlayer:GetAttributeChangedSignal("ExtraSlots"):Connect(function()
	fn6(true)
	fn5()
end)
localPlayer:GetAttributeChangedSignal("EmoteSearchBar"):Connect(function()
	fn6(true)
end)
local emoteProducts = Info.EmoteProducts

local function chec(_)
	local texts = {}

	if not (scrollingFrame2 and scrollingFrame2.Parent) then
		return
	end

	local count = 0

	for _, button in pairs(scrollingFrame2:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		count += 1
		table.insert(texts, button.Text)
	end

	local count2 = 0
	local count3 = 0

	for k, v15 in pairs(table3) do
		count2 += 1

		if v15.Limited and table.find(texts, k) then
			count3 += 1
		end
	end

	owned.Text = ("%s / %s"):format(count, count2)
end

local function fn8()
	local lastEmoteSpin = localPlayer:GetAttribute("LastEmoteSpin") or -100
	local v15 = (localPlayer:GetAttribute("TotalKillsFrb") or 0) - lastEmoteSpin
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer:GetAttribute("Emotes") or "[]")
	local count = 0
	local flag3 = true

	for k, _ in pairs(table2) do
		if table.find(jSONDecode, k) then
			continue
		end

		count += 1
		flag3 = false
	end

	local count2 = 0
	local count3 = 0

	for k, _ in pairs(table3) do
		count2 += 1

		if table.find(jSONDecode, k) then
			count3 += 1
		end
	end

	owned.Text = ("%s / %s"):format(count3, count2)

	for k, v16 in pairs(clonesByName) do
		if not table.find(jSONDecode, k) then
			continue
		end

		v16.Spin.Text = ([[
<font size="45">%s</font>
<font color="rgb(158, 255, 174)" transparency="1"><stroke transparency="1" color="#00A2FF" thickness="0">188 ROBUX</stroke></font>]]):format(k)
		v16.Spin.Check.Visible = true
	end

	for _, emoteProduct in pairs(emoteProducts) do
		if not emoteProduct.button then
			continue
		end

		if flag3 or count < emoteProduct.count then
			emoteProduct.button.Visible = false
		else
			emoteProduct.button.Visible = true
		end
	end

	if workspace:FindFirstChild("Duel Choice") or workspace:GetAttribute("RankedOnes") then
		imageLabel.Spin.Text = ""
		imageLabel.Spin.Position = UDim2.new(5, 0, 5, 0)
	elseif flag3 then
		imageLabel.Spin.Text = ""
	elseif v15 < 50 then
		local v16 = 50 - v15
		imageLabel.Spin.Text = string.format([[
NEW EMOTE: <font color="rgb(255, 85, 85)">%s KILLS</font>
<font size="16">HOLD EMOTE DOWN TO CHANGE</font>]], v16)
	else
		if imageLabel.Spin.Text ~= text2 and localPlayer:GetAttribute("HandlerLoaded") then
			if shared.notifyemote then
				shared.notifyemote()
			else
				local lastTime = tick()
				task.spawn(function()
					repeat
						task.wait()
					until tick() - lastTime > 5 or shared.notifyemote

					if shared.notifyemote then
						shared.notifyemote()
					end
				end)
			end
		end

		imageLabel.Spin.Text = text2
	end
end

imageLabel.Spin.MouseButton1Click:Connect(function()
	local character = localPlayer.Character

	if character then
		if imageLabel.Spin.Text == "" then
			return
		end

		if workspace:GetAttribute("RankedOnes") then
			imageLabel.Spin.Visible = false
			imageLabel.Spin.Position = UDim2.new(3, 0, 3, 0)
		elseif imageLabel.Spin.Text:find("CLAIM NEW EMOTE") then
			shared.sfx({
				SoundId = "rbxassetid://4612384643",
				Parent = workspace,
				Volume = 0.6
			}):Play()
			character.Communicate:FireServer({
				Goal = "Emote Spin"
			})
		end
	end
end)

for _, v15 in pairs({
	"TotalKillsFrb",
	"LastEmoteSpin",
	"Emotes",
	"HandlerLoaded",
	"CanBuyRandom"
}) do
	localPlayer:GetAttributeChangedSignal(v15):Connect(fn8)
end

fn8()
local bulk = imageLabel.Bulk
local imageButton = bulk.ImageButton
imageButton.Name = "GP"
imageButton.Parent = script

for _, emoteProduct in pairs(emoteProducts) do
	local id = emoteProduct.id
	local MarketplaceService = game:GetService("MarketplaceService")
	local productInfo = MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
	local clone = imageButton:Clone()
	clone.Visible = false
	clone.Parent = bulk
	clone.Spin.Text = string.format([[
<font size="45">%s</font>
<font size="35" color="rgb(158, 255, 174)">%s ROBUX</font>]], emoteProduct.count .. " " .. (emoteProduct.count > 1 and "EMOTES" or "EMOTE"), productInfo.PriceInRobux)
	clone.Image = "rbxassetid://" .. 15079675105
	local v15 = emoteProduct
	clone.MouseButton1Click:Connect(function()
		if not localPlayer:GetAttribute("CanBuyRandom") then
			shared.repfire({
				Effect = "Notification",
				Text = "YOUR COUNTRY PREVENTS THIS PURCHASE",
				Title = "EMOTES"
			})
			return
		end

		local MarketplaceService2 = game:GetService("MarketplaceService")
		MarketplaceService2:PromptProductPurchase(localPlayer, v15.id)
	end)
	emoteProduct.button = clone
end

fn8()

function getRarityColor(value)
	local v15 = math.clamp(value, 100, 799)
	local v16 = {
		{
			threshold = 250,
			color = Color3.fromRGB(255, 255, 255)
		},
		{
			threshold = 400,
			color = Color3.fromRGB(130, 255, 128)
		},
		{
			threshold = 550,
			color = Color3.fromRGB(92, 135, 255)
		},
		{
			threshold = 700,
			color = Color3.fromRGB(255, 165, 0)
		},
		{
			threshold = 799,
			color = Color3.fromRGB(255, 79, 79)
		}
	}

	for _, v17 in ipairs(v16) do
		if v15 <= v17.threshold then
			return v17.color
		end
	end

	return v16[#v16].color
end

local limited = imageLabel.Limited
local imageButton2 = limited.List.ImageButton
imageButton2.Parent = script

local function fn9()
	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(localPlayer:GetAttribute("LimitedPreview") or "[]")

	for _, button in pairs(limited.List:GetChildren()) do
		local ID = button:GetAttribute("ID")

		if not (button:IsA("ImageButton") and ID) then
			continue
		end

		local v15 = tostring(ID)
		local new = button:FindFirstChild("New")

		if new then
			new.Visible = not jSONDecode[v15]
		end
	end
end

local function fn10()
	local limited2 = workspace:GetAttribute("Limited")

	if not limited2 then
		return
	end

	local HttpService = game:GetService("HttpService")
	local jSONDecode = HttpService:JSONDecode(limited2)

	for _, button in pairs(limited.List:GetChildren()) do
		if button:IsA("ImageButton") then
			button:Destroy()
		end
	end

	table.clear(clonesByName)
	local HttpService2 = game:GetService("HttpService")
	local jSONDecode2 = HttpService2:JSONDecode(localPlayer:GetAttribute("Emotes") or "[]")
	local count = 0

	for _, item in pairs(jSONDecode.items) do
		count += 1
		local v15 = table.find(jSONDecode2, item.Name) ~= nil
		local clone = imageButton2:Clone()
		clone:SetAttribute("ID", item.ID)
		clone.Spin.Text = ("<font size=\"45\">%s</font>\n<font color=\"rgb(158, 255, 174)\">%s ROBUX</font>"):format(
			item.Name,
			item.Price
		)

		if v15 then
			clone.Spin.Text = ("<font size=\"40\">%s</font>\n<font color=\"rgb(120, 255, 150)\">OWNED</font>"):format(item.Name)
			local check = clone.Spin:FindFirstChild("Check")

			if check then
				check.Visible = true
			end
		end

		clone.Image = "rbxassetid://" .. item.Image
		local v16 = table3[tostring(item.Name)]
		local v17 = {}
		local imageColor = nil

		for k, v19 in pairs(v6) do
			table.insert(v17, { k, v19.ImageColor3 })
		end

		for _, v19 in pairs(v17) do
			if v16 and v16[v19[1]] then
				imageColor = v19[2]
			end
		end

		if imageColor then
			clone.Glow.ImageColor3 = imageColor
		end

		clone.Parent = limited.List
		clone.Visible = true

		if v16 and v16.Preview then
			clone.Preview.Visible = true
			local v19 = clone
			local v20 = v16
			local v21 = item
			clone.Preview.MouseButton1Click:Connect(function()
				if imageLabel:FindFirstChild("Preview") then
					return
				end

				shared.sfx({
					SoundId = "rbxassetid://10066921516",
					Parent = workspace,
					Volume = 0.25
				}):Play()
				local clone2 = script.Preview:Clone()
				clone2.Loading.LocalScript.Enabled = true
				clone2.Origin.Value = v19.Preview
				clone2:SetAttribute("ID", v20.Preview)
				clone2.Parent = imageLabel

				if v20.Preview == 132667596929569 or v20.Preview == 80527003220550 or v20.Preview == 97332443582360 or v20.Preview == 72385565295818 or v20.Preview == 97599293604082 or v20.Preview == 82535683894728 or v20.Preview == 76084431152851 or v20.Preview == 126033249793452 then
					clone2.VideoFrame.Volume = 100
				end

				localPlayer.Character.Communicate:FireServer({
					Goal = "Limited Preview",
					Limited = v21.ID
				})
			end)
		else
			clone.Preview.Visible = false
		end

		local v20 = item
		clone.MouseButton1Click:Connect(function()
			if v15 then
				return
			end

			localPlayer.Character.Communicate:FireServer({
				Goal = "Prompt Limited Purchase",
				Limited = v20.Number
			})
		end)
		clonesByName[item.Name] = clone
	end

	local v15 = ({ 0.317, 0.151, -0.01 })[count] or -0.01
	local timer = imageLabel.Limited.Timer
	timer.Position = UDim2.new(timer.Position.X.Scale, timer.Position.X.Offset, v15, timer.Position.Y.Offset)
	startOfYear = jSONDecode.info.startOfYear
	currentWeek = jSONDecode.info.currentWeek
	secondsInWeek = jSONDecode.info.secondsInWeek
	fn9()
	fn8()
end

workspace:GetAttributeChangedSignal("Limited"):Connect(fn10)
pcall(fn10)
localPlayer:GetAttributeChangedSignal("LimitedPreview"):Connect(fn9)