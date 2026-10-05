local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local CmdrClient = replicatedStorage:WaitForChild("CmdrClient", 2) and require(replicatedStorage.CmdrClient)
local Icon = require(replicatedStorage.Modules.Icon)
pcall(function()
	local VoiceChatService = game:GetService("VoiceChatService")
	local isVoiceEnabledForUserIdAsync = VoiceChatService:IsVoiceEnabledForUserIdAsync(localPlayer.UserId)
	local IconController = require(replicatedStorage.Modules.Icon.IconController)
	IconController.voiceChatEnabled = isVoiceEnabledForUserIdAsync
end)
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "JoinController"
})
controller.lastRecvServer = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function readInt16(buf: buffer, offset: number)
	return buffer.readi16(buf, offset) / 1000
end

local function readi24(buf: buffer, offset: number)
	local v4 = buffer.readu16(buf, offset) * 256 + buffer.readu8(buf, offset + 2)

	if v4 >= 8388608 then
		return v4 - 16777216
	end

	return v4
end

local function writei24(buf: buffer, offset: number, total: number)
	if total < 0 then
		total += 16777216
	end

	buffer.writeu16(buf, offset, total / 256)
	buffer.writeu8(buf, offset + 2, total % 256)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function writeInt16(buf: buffer, offset: number, p: number)
	buffer.writei16(buf, offset, p * 1000)
end

local function readCFrame(buf: buffer)
	local v4 = buffer.readu16(buf, 0) * 256 + buffer.readu8(buf, 2)

	if v4 >= 8388608 then
		v4 -= 16777216
	end

	local v5 = v4 / 100
	local v6 = buffer.readu16(buf, 3) * 256 + buffer.readu8(buf, 5)

	if v6 >= 8388608 then
		v6 -= 16777216
	end

	local v7 = v6 / 100
	local v8 = buffer.readu16(buf, 6) * 256 + buffer.readu8(buf, 8)

	if v8 >= 8388608 then
		v8 -= 16777216
	end

	local v9 = v8 / 100
	local int16 = readInt16(buf, 9) -- equivalent call inferred; original call site unknown
	local int162 = readInt16(buf, 11) -- equivalent call inferred; original call site unknown
	local int163 = readInt16(buf, 13) -- equivalent call inferred; original call site unknown
	return CFrame.new(v5, v7, v9) * CFrame.Angles(int16, int162, int163)
end

local function writeCFrame(cFrame: CFrame)
	local buf = buffer.create(15)
	local X = cFrame.X
	local Y = cFrame.Y
	local Z = cFrame.Z
	local eulerAnglesXYZ, v4, v5 = cFrame:ToEulerAnglesXYZ()
	local v6 = X * 100

	if v6 < 0 then
		v6 += 16777216
	end

	buffer.writeu16(buf, 0, v6 / 256)
	buffer.writeu8(buf, 2, v6 % 256)
	local v7 = Y * 100

	if v7 < 0 then
		v7 += 16777216
	end

	buffer.writeu16(buf, 3, v7 / 256)
	buffer.writeu8(buf, 5, v7 % 256)
	local v8 = Z * 100

	if v8 < 0 then
		v8 += 16777216
	end

	buffer.writeu16(buf, 6, v8 / 256)
	buffer.writeu8(buf, 8, v8 % 256)
	writeInt16(buf, 9, eulerAnglesXYZ) -- equivalent call inferred; original call site unknown
	writeInt16(buf, 11, v4) -- equivalent call inferred; original call site unknown
	writeInt16(buf, 13, v5) -- equivalent call inferred; original call site unknown
	return buf
end

function controller:CreateIcon(p, p2, p3)
	local v4 = Icon.new()

	if p2 then
		v4:setImage(p2)
	end

	v4:setLabel(p)
	v4:bindEvent("selected", function(object)
		object:deselect()
		v.Change:Fire(p3)
	end)
	return v4
end

function controller:CreateIconBase(p, p2, p3)
	local v4 = Icon.new()

	if p2 then
		v4:setImage(p2)
	end

	v4:setLabel(p)
	v4:modifyTheme({ "IconLabel", "TextColor3", Color3.fromRGB(152, 152, 152) })
	v4:bindEvent("selected", function(object)
		object:deselect()
		v.Change:Fire(p3)
	end)
	return v4
end

function controller:KnitStart()
	script:SetAttribute("KnitLoaded", true)
	local v4 = Icon.new()
	v4:setImage("rbxassetid://7992557358")
	v4:setLabel("Characters")
	v4:setEnabled(false)
	v4:setDropdown({
		self:CreateIcon("Honored One", nil, "Gojo"),
		self:CreateIcon("Vessel", nil, "Itadori"),
		self:CreateIcon("Restless Gambler", nil, "Hakari"),
		self:CreateIcon("Ten Shadows", nil, "Megumi"),
		self:CreateIcon("Perfection", nil, "Mahito"),
		self:CreateIcon("Blood Manipulator", nil, "Choso"),
		self:CreateIcon("Switcher", nil, "Todo"),
		self:CreateIcon("Defense Attorney", nil, "Hiromi"),
		self:CreateIcon("Cursed Partners", nil, "Yuta"),
		self:CreateIcon("Puppet Master", nil, "Mechamaru"),
		self:CreateIcon("Head of the Hei", nil, "Naoya"),
		self:CreateIcon("Salaryman", nil, "Nanami"),
		self:CreateIcon("Disaster Plants", nil, "Hanami"),
		self:CreateIcon("True Cannon", nil, "Ryu"),
		self:CreateIcon("Register", nil, "Reggie"),
		self:CreateIconBase("Locust Guy", nil, "Locust"),
		self:CreateIconBase("Star Rage", nil, "Yuki"),
		self:CreateIconBase("Aspiring Mangaka", nil, "Charles"),
		self:CreateIconBase("Lucky Coward", nil, "Haruta"),
		self:CreateIconBase("Crow Charmer", nil, "MeiMei"),
		self:CreateIconBase("Black Death", nil, "Kurourushi"),
		self:CreateIconBase("Sky Assassin", nil, "Uro")
	})
	local v5 = nil
	local v6 = nil
	local v7 = nil

	local function updateTags()
		if v5 then
			v5:destroy()
			v5 = nil
		end

		if v6 then
			v6:destroy()
			v6 = nil
		end

		if v7 then
			v7:destroy()
			v7 = nil
		end

		if workspace:GetAttribute("AllowOP") then
			v5 = self:CreateIcon("Strongest Of History", nil, "Heian")
			v5:modifyTheme({ "IconLabel", "TextColor3", Color3.fromRGB(255, 170, 0) })
			v5:joinDropdown(v4)
		end

		if localPlayer:GetAttribute("Mokou") then
			v6 = self:CreateIcon("Mokou", 129398506853336, "Mokou")
			v6:modifyTheme({ "IconLabel", "TextColor3", Color3.fromRGB(255, 170, 0) })
			v6:joinDropdown(v4)
		end

		if localPlayer:GetAttribute("Goku") or workspace:GetAttribute("AllowOP") then
			v7 = self:CreateIcon("Monkey Kid", 79537216753706, "Goku")
			v7:modifyTheme({ "IconLabel", "TextColor3", Color3.fromRGB(255, 170, 0) })
			v7:joinDropdown(v4)
		end
	end

	updateTags()
	workspace:GetAttributeChangedSignal("AllowOP"):Connect(updateTags)
	localPlayer:GetAttributeChangedSignal("Mokou"):Connect(updateTags)
	localPlayer:GetAttributeChangedSignal("Goku"):Connect(updateTags)
	task.spawn(function()
		local function updateFolder(instance)
			local function addCustomChar(child)
				if not child.Value then
					repeat
						task.wait()
					until child.Value or not child.Parent
				end

				if not (child.Parent and child.Value) then
					return
				end

				local moveNameFt = child.Value:GetAttribute("MoveNameFt") or "Unnamed"
				local IMG = child.Value:GetAttribute("IMG")

				if IMG == 0 then
					IMG = nil
				end

				local v8 = Icon.new()

				if IMG then
					v8:setImage(IMG)
				end

				v8:setLabel(moveNameFt)
				v8:bindEvent("selected", function(object2)
					object2:deselect()
					v.Change:Fire(child.Value:GetAttribute("MoveNameFt") or "Unnamed")
				end)
				v8:modifyTheme({ "IconLabel", "TextColor3", Color3.fromRGB(85, 170, 255) })
				v8:joinDropdown(v4)
				child.Destroying:Connect(function()
					v8:destroy()
				end)

				local function updateCustomChar()
					local moveNameFt2 = child.Value:GetAttribute("MoveNameFt") or "Unnamed"
					local IMG2 = child.Value:GetAttribute("IMG")

					if IMG2 == 0 then
						IMG2 = nil
					end

					if moveNameFt2 then
						v8:setLabel(moveNameFt2)
					end

					if IMG2 then
						v8:setImage("rbxassetid://" .. IMG2)
					end

					if child.Value:GetAttribute("Flip") == true then
						v8:setEnabled(true)
					else
						v8:setEnabled(false)
					end
				end

				updateCustomChar()
				child.Value:GetAttributeChangedSignal("IMG"):Connect(updateCustomChar)
				child.Value:GetAttributeChangedSignal("MoveNameFt"):Connect(updateCustomChar)
				child.Value:GetAttributeChangedSignal("Flip"):Connect(updateCustomChar)
				child.Destroying:Connect(function()
					v8:destroy()
				end)
			end

			for _, child in instance:GetChildren() do
				addCustomChar(child)
			end

			instance.ChildAdded:Connect(addCustomChar)
		end

		if workspace.LogicData:FindFirstChild("CustomChar") then
			updateFolder(workspace.LogicData.CustomChar)
		else
			workspace.LogicData.ChildAdded:Connect(function(child)
				if child.Name ~= "CustomChar" then
					return
				end

				updateFolder(child)
			end)
		end
	end)
	localPlayer:WaitForChild("leaderstats")
	local cash = localPlayer:GetAttribute("Cash") or 0
	local group = localPlayer.PlayerGui:WaitForChild("Menus").Group
	local fade = localPlayer.PlayerGui:WaitForChild("Menus").Fade

	local function fadeDrop()
		while true do
			local flag = true

			for _, child in group:GetChildren() do
				if child:GetAttribute("Loaded") then
					continue
				end

				flag = false
				break
			end

			if not flag then
				task.wait(0.1)
			end

			if not flag then
				continue
			end

			group.Parent = fade
			fade.Position = UDim2.new(0, 0, -0.2, 0)
			fade.GroupTransparency = 1
			local tween = TweenService:Create(fade, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Position = UDim2.new(0, 0, 0, 0),
				GroupTransparency = 0
			})
			tween:Play()
			tween.Completed:Once(function()
				group.Parent = fade.Parent
			end)
			break
		end
	end

	local v8 = Icon.new()
	v8:setImage("rbxassetid://9405933217")
	v8:setLabel("$" .. tostring(cash))
	localPlayer:GetAttributeChangedSignal("Cash"):Connect(function()
		cash = localPlayer:GetAttribute("Cash") or 0
		v8:setLabel("$" .. tostring(cash))
	end)
	v8:bindEvent("selected", function(_)
		group.Shop.Visible = true
		fadeDrop()
	end)
	v8:bindEvent("deselected", function(_)
		group.Shop.Visible = false
	end)
	v8:setEnabled(workspace:GetAttribute("Match") == nil)
	local v9 = Icon.new()
	v9:setImage("rbxassetid://5480743826")
	v9:bindEvent("selected", function(_)
		group.Settings.Visible = true
		fadeDrop()
	end)
	v9:bindEvent("deselected", function(_)
		group.Settings.Visible = false
	end)
	local v10 = Icon.new()
	v10:setImage("rbxassetid://6870729295")
	v10:bindEvent("selected", function(_)
		group.Inventory.Visible = true
		fadeDrop()
	end)
	v10:bindEvent("deselected", function(_)
		group.Inventory.Visible = false
	end)
	v10:setEnabled(workspace:GetAttribute("Match") == nil)
	local v11 = Icon.new()
	v11:setImage("rbxassetid://11829454151")
	v11:bindEvent("selected", function(_)
		group.Achievements.Visible = true
		fadeDrop()
	end)
	v11:bindEvent("deselected", function(_)
		group.Achievements.Visible = false
	end)
	v11:setName("Achievement")
	local v12 = false
	local v13 = Icon.new()
	v13:setImage("rbxassetid://11214451393")
	v13:bindEvent("selected", function(_)
		group.Logs.Visible = true
		fadeDrop()

		if v12 == true then
			return
		end

		v12 = true
		replicatedStorage.Remotes.UpdateLog:FireServer(v3.Ver)
	end)
	v13:bindEvent("deselected", function(_)
		group.Logs.Visible = false
	end)
	v13:setRight()
	local RobloxChatVoice, v14, v15 = require(replicatedStorage.Modules.RobloxChatVoice)
	local v16 = {}

	for k, v17 in RobloxChatVoice, v14, v15 do
		local v18 = k
		local v19 = v17
		pcall(function()
			local v20 = Icon.new()
			v20:setImage("rbxassetid://" .. v18)
			v20:setLabel(v19.Name)
			v20:bindEvent("selected", function(object2)
				object2:deselect()
				v.Talk:Fire(v18)
			end)
			table.insert(v16, v20)
		end)
	end

	local v17 = Icon.new()
	v17:setRight()
	v17:setImage("rbxassetid://14809805905")
	v17:setCaption("this roblox chat update sucks")
	v17:setDropdown(v16)
	task.spawn(function()
		local Rules = require(replicatedStorage.Modules.Rules)
		local version = Rules.Version
		local lastRulesAccepted = localPlayer:GetAttribute("LastRulesAccepted")

		if not lastRulesAccepted then
			localPlayer:GetAttributeChangedSignal("LastRulesAccepted"):Wait()
			lastRulesAccepted = localPlayer:GetAttribute("LastRulesAccepted")
		end

		local v18 = Icon.new()
		v18:setImage("rbxassetid://71437429504293")
		v18:bindEvent("selected", function(_)
			group.Rules.Visible = true
			fadeDrop()
		end)
		v18:bindEvent("deselected", function(_)
			if version == localPlayer:GetAttribute("LastRulesAccepted") then
				group.Rules.Visible = false
			else
				v18:select()
			end
		end)
		v18:setRight()

		if version ~= lastRulesAccepted then
			v18:select()
		end

		localPlayer:GetAttributeChangedSignal("LastRulesAccepted"):Once(function()
			if version == localPlayer:GetAttribute("LastRulesAccepted") then
				v18:deselect()
			end
		end)
	end)
	replicatedStorage.Remotes.UpdateLog:FireServer()
	replicatedStorage.Remotes.UpdateLog.OnClientEvent:Connect(function(p)
		if p ~= v3.Ver then
			v13:notify()
		end
	end)
	task.delay(0.05, function()
		local v18 = Icon.new()
		v18:setImage("rbxassetid://2599458148")
		v18:bindEvent("selected", function(_)
			group.Ranked.Visible = true
			fadeDrop()
		end)
		v18:bindEvent("deselected", function(_)
			group.Ranked.Visible = false
		end)
		v18:setEnabled(workspace:GetAttribute("Match") == nil)
		local v19

		if localPlayer:GetAttribute("PS_Owner") then
			v19 = Icon.new()
			v19:setImage("rbxassetid://401280105")
			v19:bindEvent("selected", function(_)
				group.Private.Visible = true
				fadeDrop()
			end)
			v19:bindEvent("deselected", function(_)
				group.Private.Visible = false
			end)
		else
			v19 = nil
		end

		localPlayer:GetAttributeChangedSignal("PS_Owner"):Connect(function()
			if localPlayer:GetAttribute("PS_Owner") and not v19 then
				v19 = Icon.new()
				v19:setImage("rbxassetid://401280105")
				v19:bindEvent("selected", function(_)
					group.Private.Visible = true
					fadeDrop()
				end)
				v19:bindEvent("deselected", function(_)
					group.Private.Visible = false
				end)
			elseif v19 then
				v19:deselect()
				v19:destroy()
				v19 = nil
			end
		end)
		localPlayer:GetAttributeChangedSignal("PS_Perms"):Connect(function()
			if localPlayer:GetAttribute("PS_Owner") then
				return
			end

			if localPlayer:GetAttribute("PS_Perms") and not v19 then
				v19 = Icon.new()
				v19:setImage("rbxassetid://401280105")
				v19:bindEvent("selected", function(_)
					group.Private.Visible = true
					fadeDrop()
				end)
				v19:bindEvent("deselected", function(_)
					group.Private.Visible = false
				end)
			elseif v19 then
				v19:deselect()
				v19:destroy()
				v19 = nil
			end
		end)

		if CmdrClient then
			local v20 = Icon.new()
			v20:setImage("rbxassetid://95498291180289")
			v20:bindEvent("selected", function(object2)
				CmdrClient:Show()
				object2:deselect()
				fadeDrop()
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateCmdr()
				if not localPlayer:GetAttribute("Cmdr") then
					v20:setEnabled(false)
				elseif UserInputService.TouchEnabled then
					v20:setEnabled(true)
				else
					v20:setEnabled(false)
				end
			end

			localPlayer:GetAttributeChangedSignal("Cmdr"):Connect(updateCmdr)
			UserInputService.InputChanged:Connect(updateCmdr)
			updateCmdr() -- equivalent call inferred; original call site unknown
		end

		local tutorialIcon = Icon.new()
		tutorialIcon:setEnabled(false)
		tutorialIcon:bindEvent("selected", function(_)
			group.Tutorial_Info.Visible = true
			fadeDrop()
		end)
		tutorialIcon:bindEvent("deselected", function(_)
			group.Tutorial_Info.Visible = false
		end)
		_G.TutorialIcon = tutorialIcon
		local workshopIcon = Icon.new()
		workshopIcon:setImage("rbxassetid://10626050757")
		workshopIcon:bindEvent("selected", function(_)
			group.Workshop.Visible = true
			fadeDrop()
		end)
		workshopIcon:bindEvent("deselected", function(_)
			group.Workshop.Visible = false
		end)
		_G.WorkshopIcon = workshopIcon

		if not localPlayer:GetAttribute("Workshop") then
			workshopIcon:setEnabled(false)
		end

		localPlayer:GetAttributeChangedSignal("Workshop"):Connect(function()
			if localPlayer:GetAttribute("Workshop") then
				workshopIcon:setEnabled(true)
			else
				workshopIcon:setEnabled(false)
			end
		end)
	end)
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
	local bindableEvent = Instance.new("BindableEvent")
	bindableEvent.Event:Connect(function()
		v.Reset:Fire()
	end)
	v.Reset:Connect(function(title, text, _, _)
		local StarterGui2 = game:GetService("StarterGui")
		StarterGui2:SetCore("SendNotification", {
			Title = title,
			Text = text
		})
	end)
	local TextChatService = game:GetService("TextChatService")
	workspace.Map.Core:FindFirstChild("Leaderboard")

	TextChatService.OnIncomingMessage = function(p)
		local textChatMessageProperties = Instance.new("TextChatMessageProperties")

		if not p.TextSource then
			return textChatMessageProperties
		end

		local playerByUserId = game.Players:GetPlayerByUserId(p.TextSource.UserId)

		if not playerByUserId:GetAttribute("Title") then
			return textChatMessageProperties
		end

		if playerByUserId:GetAttribute("Title") == "?" then
			textChatMessageProperties.PrefixText = "<font color = \"#000000\">[ ? ] ?: </font>"
			return textChatMessageProperties
		end

		textChatMessageProperties.PrefixText = "[" .. playerByUserId:GetAttribute("Title") .. "] " .. p.PrefixText
		return textChatMessageProperties
	end

	RunService.Stepped:Connect(function()
		local character = localPlayer.Character
		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
		local buf = buffer.create(9)
		local X = workspace.CurrentCamera.CFrame.X

		if X < 0 then
			X += 16777216
		end

		buffer.writeu16(buf, 0, X / 256)
		buffer.writeu8(buf, 2, X % 256)
		local Y = workspace.CurrentCamera.CFrame.Y

		if Y < 0 then
			Y += 16777216
		end

		buffer.writeu16(buf, 3, Y / 256)
		buffer.writeu8(buf, 5, Y % 256)
		local Z = workspace.CurrentCamera.CFrame.Z

		if Z < 0 then
			Z += 16777216
		end

		buffer.writeu16(buf, 6, Z / 256)
		buffer.writeu8(buf, 8, Z % 256)
		local v18

		if humanoidRootPart then
			v18 = writeCFrame(humanoidRootPart.CFrame)
		end

		v2.Camera:Fire(buf, v18, character, (0 / 0))
	end)
	local cframe = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
	RunService.RenderStepped:Connect(function(dt)
		local now = tick()

		for k, v18 in self.lastRecvServer do
			if k and k.Parent then
				if k ~= localPlayer.Character then
					local humanoidRootPart = k.HumanoidRootPart

					if v18 == false or (k:GetAttribute("Ragdoll") or 0) > 0 or k.Humanoid.Sit == true then
						humanoidRootPart.RootJoint.C0 = cframe
						humanoidRootPart:SetAttribute("MO", nil)
					elseif v18[1] and v18[2] then
						local cframe2

						if (v18[2].Position - v18[1].Position).Magnitude < 15 then
							cframe2 = (v18[2] or humanoidRootPart.CFrame):Lerp(
								v18[1],
								(math.clamp((now - v18[3]) / 0.05, 0, 1))
							)
						else
							cframe2 = v18[1]
						end

						local grabWeld = humanoidRootPart:FindFirstChild("GrabWeld")

						if grabWeld and grabWeld.Part0 and grabWeld.Part0.Name ~= "HumanoidRootPart" then
							humanoidRootPart:SetAttribute("MO", (cframe2:ToObjectSpace(humanoidRootPart.CFrame)))
						else
							local v19 = (cframe2.Position - humanoidRootPart.Position) / dt
							local velocity = v19.Magnitude > 50 and createVector(0, 0, 0) or v19
							humanoidRootPart.RootJoint.C0 = cframe
							humanoidRootPart:SetAttribute("MO", nil)
							humanoidRootPart.Velocity = velocity
							humanoidRootPart.CFrame = cframe2
						end
					else
						humanoidRootPart.RootJoint.C0 = cframe
						humanoidRootPart:SetAttribute("MO", nil)
					end
				end
			else
				self.lastRecvServer[k] = nil
			end
		end
	end)
	v2.Camera:Connect(function(items)
		for childName, item in items do
			local child = game.Players:FindFirstChild(childName)

			if not child then
				continue
			end

			local character = child.Character

			if not (character and character.Parent) then
				continue
			end

			if type(item) == "boolean" then
				self.lastRecvServer[character] = false
			else
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local v18

				if humanoidRootPart then
					v18 = humanoidRootPart.CFrame * (humanoidRootPart:GetAttribute("MO") or CFrame.new())
				end

				self.lastRecvServer[character] = { readCFrame(item), v18 or readCFrame(item), tick() }
			end
		end
	end)
	v2.Teleport:Connect(function(instance, p, p2)
		if localPlayer.Character == instance then
			v2.Teleport:Fire(p2)
		elseif instance and instance.Parent then
			instance:PivotTo((readCFrame(p)))
			self.lastRecvServer[instance] = false
		end
	end)
	v.Talk:Connect(function(instance, p)
		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local RobloxChatVoice2 = require(replicatedStorage.Modules.RobloxChatVoice)
		local v18 = RobloxChatVoice2[p]
		local sound = v18.Sound
		local clone = sounds.Impact.Players.Death:Clone()
		clone.RollOffMaxDistance = 150
		clone.SoundGroup = game.SoundService.Taunt
		clone.SoundId = "rbxassetid://" .. sound
		clone.Volume = v18.Volume or 1
		clone.Parent = humanoidRootPart
		clone:Play()
		clone.Stopped:Connect(function()
			clone:Destroy()
		end)
		local clone2 = utils.Voice:Clone()
		clone2.ImageLabel.Image = "rbxassetid://" .. p
		clone2.Parent = humanoidRootPart
		TweenService:Create(clone2, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			StudsOffsetWorldSpace = createVector(0, 5, 0)
		}):Play()
		TweenService:Create(clone2.ImageLabel, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {
			ImageTransparency = 1
		}):Play()
	end)

	while not pcall(function()
		StarterGui:SetCore("ResetButtonCallback", bindableEvent)
	end) do
		task.wait()
	end
end

function controller.KnitInit(_)
	v = Knit.GetService("JoinService")
	v2 = Knit.GetService("AntiCheatService")
	v3 = Knit.GetController("UpdateLogController")
end

return controller