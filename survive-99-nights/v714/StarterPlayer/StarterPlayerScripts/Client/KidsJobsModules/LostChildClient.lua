local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local v = {
	"NeedsFire",
	"NeedsBandage",
	"NeedsCake",
	"NeedsSleep"
}
local color = Color3.fromRGB(198, 46, 46)
local color2 = Color3.fromRGB(160, 48, 42)
local v2 = {
	"Friending",
	"Working",
	"Hunger",
	"FriendXP",
	"SelectedTask"
}
local v3 = {
	DinoKid = {
		Happy = "rbxassetid://113897531096408",
		KindaHappy = "rbxassetid://139751330923668",
		Crying = "rbxassetid://96742687430852"
	},
	KrakenKid = {
		Happy = "rbxassetid://115761031860078",
		KindaHappy = "rbxassetid://117774834121620",
		Crying = "rbxassetid://82660896825017"
	},
	SquidKid = {
		Happy = "rbxassetid://137958343858411",
		KindaHappy = "rbxassetid://133920312767465",
		Crying = "rbxassetid://111168702143123"
	},
	KoalaKid = {
		Happy = "rbxassetid://137395554797760",
		KindaHappy = "rbxassetid://137857179994217",
		Crying = "rbxassetid://78446213430527"
	}
}
local LostChildClient = {}
local v4 = {
	NeedsFire = "rbxassetid://112269409726807",
	NeedsBandage = "rbxassetid://70748893795308",
	NeedsCake = "rbxassetid://79670012814180",
	NeedsSleep = "rbxassetid://86071297685902"
}
local v5 = {
	NeedsFire = "%s is freezing. Put more fuel on the Campfire",
	NeedsBandage = "%s was attacked by a wolf and needs a Bandage",
	NeedsCake = "%s wants a sweet treat. Bring them a Cake",
	NeedsSleep = "%s is sleepy. Make their Bed for them (in their Tent)"
}
local v6 = {
	DinoKid = "rbxassetid://130009604520646"
}
local v7 = {
	"DinoKid",
	"KrakenKid",
	"SquidKid",
	"KoalaKid"
}

for _, v8 in pairs(v) do
	table.insert(v2, v8)
end

local v8 = {}
local v9 = nil
local backgroundColor3 = nil
local textColor3 = nil
local clones = {}
local v10 = nil
local v11 = nil
local clones2 = {}
local v12 = nil
local v13 = nil

function GetKidName(instance)
	return instance:GetAttribute("PingName") or instance.Name
end

function SetExclaimCount(p, p2)
	local exclaim = p.Container.Exclaim
	local exclaims = p.Exclaims

	for i = #exclaims + 1, p2 do
		local clone = exclaim:Clone()
		clone.LayoutOrder = i
		clone.Visible = true
		clone.Parent = exclaim.Parent
		table.insert(exclaims, clone)
	end

	for i = #exclaims, p2 + 1, -1 do
		exclaims[i]:Destroy()
		table.remove(exclaims, i)
	end
end

function GetKidStatus(instance)
	local count = 0

	for _, attributeName in pairs(v) do
		if instance:GetAttribute(attributeName) then
			count += 1
		end
	end

	local v14 = (instance:GetAttribute("Hunger") or 200) / 200
	local v15 = v3[instance:GetAttribute("KidId")] or v3.DinoKid
	local happy = v15.Happy
	local v16 = false

	if count > 0 or v14 < 0.25 then
		happy = v15.Crying
		v16 = true
	elseif v14 < 0.7 then
		happy = v15.KindaHappy
	end

	return count, v14, happy, v16
end

function LostChildClient.IsKidSad(p)
	local _, _, _, v14 = GetKidStatus(p)
	return v14
end

function UpdateGui(data)
	local model = data.Model
	local gui = data.Gui

	if not model:GetAttribute("Friending") then
		gui.Enabled = false
		return
	end

	gui.Enabled = true
	local visible = time() < data.LevelUpEndTime
	local v15 = model:GetAttribute("Working") ~= nil
	local working = model:GetAttribute("Working")

	if working == "CookFood" then
		v15 = nil
		working = nil
	end

	gui.LevelUp.Visible = visible
	gui.Working.Visible = v15 and not visible
	gui.Default.Visible = not (visible or v15)

	if working == "ChopWood" then
		gui.Working.Item.Image = "rbxassetid://130009604520646"
	elseif working == "FindScrap" then
		gui.Working.Item.Image = "rbxassetid://114940147180571"
	elseif working == "FishForFood" then
		gui.Working.Item.Image = "rbxassetid://99332192556877"
	end

	if visible then
		gui.LevelUp.TextLabel.Text = "LEVEL " .. (model:GetAttribute("FriendLevel") or 1)
	elseif v15 then
		gui.Working.Amount.Text = tostring(#data.Inventory:GetChildren())
	else
		local v16, v17, image, v19 = GetKidStatus(model)
		local container = data.Container
		container.Face.Image = image
		container.Face.Level.Text = "lvl " .. (model:GetAttribute("FriendLevel") or 1)
		SetExclaimCount(data, v16)
		container.LevelAndHunger.Visible = v16 == 0

		if v16 == 0 then
			local v20 = v17 < 0.25
			local bar = container.LevelAndHunger.Hunger.ProgressBarContainer.Bar
			bar.Size = UDim2.new(math.clamp(v17, 0, 1), 0, 1, 0)
			bar.BackgroundColor3 = v20 and color or data.HungerBarColour
			container.LevelAndHunger.HungerLabel.TextColor3 = v20 and color or data.HungerLabelColour
		end

		if v19 then
			data.Face.Texture = "rbxassetid://2799075615"
		else
			data.Face.Texture = "rbxasset://textures/face.png"
		end
	end

	UpdateKidFrame()
end

function OnFriendLevelChanged(state)
	local friendLevel = state.Model:GetAttribute("FriendLevel")
	local lastLevel = state.LastLevel
	state.LastLevel = friendLevel

	if lastLevel and friendLevel and lastLevel < friendLevel then
		state.LevelUpEndTime = time() + 12
		task.delay(12, function()
			UpdateGui(state)
		end)
	end

	UpdateGui(state)
end

function UpdateWarnings(instance)
	local kidFrame = Client.Interface.KidFrame
	local frame = kidFrame.AdditionalStatus.Frame
	local warning = frame:FindFirstChild("Warning")

	for _, v14 in pairs(clones) do
		v14:Destroy()
	end

	clones = {}
	local v14 = GetKidName(instance)
	local count = 0

	for _, attributeName in pairs(v) do
		if not instance:GetAttribute(attributeName) then
			continue
		end

		count += 1
		local clone = warning:Clone()
		clone.LayoutOrder = count
		clone.Icon.Image = v4[attributeName] or clone.Icon.Image
		local name = clone:FindFirstChild("Name")
		name.Text = string.format(v5[attributeName] or "", v14)
		clone.Visible = true
		clone.Parent = frame
		table.insert(clones, clone)
	end

	local v15 = not (count > 0) and 0 or count * 0.16 + 0.12
	kidFrame.AdditionalStatus.Position = UDim2.new(0.5, 0, v15 + 0.5, 0)
end

function RebuildTaskButtons(instance)
	local window = Client.Interface.KidFrame.Window
	local kidId = instance:GetAttribute("KidId")
	local otherKidsHaveJobs = game.ReplicatedStorage.Configs:GetAttribute("OtherKidsHaveJobs") == true
	local v14

	if otherKidsHaveJobs then
		v14 = Client.Databases.KidTasks.GetTasks(kidId) or nil
	end

	local friendLevel = instance:GetAttribute("FriendLevel") or 1
	local selectedTask = instance:GetAttribute("SelectedTask")
	local v15 = tostring(kidId) .. "|" .. friendLevel .. "|" .. tostring(selectedTask) .. "|" .. tostring(otherKidsHaveJobs)

	if v12 == instance and v13 == v15 then
		return
	end

	v12 = instance
	v13 = v15

	for _, v16 in pairs(clones2) do
		v16:Destroy()
	end

	clones2 = {}
	window.TaskButtons.Visible = v14 ~= nil
	window.TaskTextLabel.Visible = v14 ~= nil
	window.TaskTextLabel.Text = ""

	if not v14 then
		return
	end

	for k, v16 in pairs(v14) do
		local v17 = friendLevel < v16.Level
		local v18 = not v17 and v16.Id == selectedTask
		local unlocked = v11.Unlocked

		if v17 then
			unlocked = v11.Locked
		elseif v18 then
			unlocked = v11.Selected
		end

		local clone = unlocked:Clone()
		clone.LayoutOrder = k
		clone.Upper.TextLabel.Text = v17 and "Unlocks at Lv " .. v16.Level or v16.Name
		clone.Interactable = not v17
		clone.Visible = true
		local v21 = v16
		clone.Activated:Connect(function()
			if not (v17 or v18) then
				Client.Events.SelectKidTask:FireServer(instance, v21.Id)
			end
		end)
		clone.Parent = window.TaskButtons
		table.insert(clones2, clone)

		if v18 then
			window.TaskTextLabel.Text = v16.Description or ""
		end
	end
end

function UpdateKidFrame()
	local kidFrame = Client.Interface.KidFrame
	local v14 = v9

	if not (kidFrame.Visible and v14 and v14.Parent) then
		return
	end

	local window = kidFrame.Window
	local _, v15, image, v17 = GetKidStatus(v14)
	window.PortraitContainer.ImageLabel.Image = image
	local name = window:FindFirstChild("Name")
	local text = GetKidName(v14)

	if v17 then
		name.Text = text .. " (sad)"
		name.TextColor3 = color2
	else
		if v14:GetAttribute("Working") then
			name.Text = text .. " (Working)"
		else
			name.Text = text
		end

		name.TextColor3 = textColor3
	end

	local friendLevel = v14:GetAttribute("FriendLevel") or 1
	local friendXP = v14:GetAttribute("FriendXP") or 0
	local xPRequired = v14:GetAttribute("XPRequired")
	window.Level.Text = "Level " .. friendLevel .. "/5"

	if xPRequired then
		window.ProgressBarContainer.EXP.Text = friendXP .. "/" .. xPRequired .. " EXP"
		window.ProgressBarContainer.Bar.Size = UDim2.new(math.clamp(friendXP / xPRequired, 0, 1), 0, 1, 0)
	else
		window.ProgressBarContainer.EXP.Text = "MAX"
		window.ProgressBarContainer.Bar.Size = UDim2.new(1, 0, 1, 0)
	end

	local bar = window.Hunger.ProgressBarContainer.Bar
	bar.Size = UDim2.new(math.clamp(v15, 0, 1), 0, 1, 0)

	if v15 < 0.25 then
		bar.BackgroundColor3 = color
	else
		bar.BackgroundColor3 = backgroundColor3
	end

	window.Hunger.Icon.WarningIcon.Visible = v15 < 0.25
	RebuildTaskButtons(v14)
	UpdateWarnings(v14)
end

function PlayXPBarTween()
	local v14 = v9

	if not v14 then
		return
	end

	local xPRequired = v14:GetAttribute("XPRequired")
	local v15 = not xPRequired and 1 or math.clamp((v14:GetAttribute("FriendXP") or 0) / xPRequired, 0, 1)
	local bar = Client.Interface.KidFrame.Window.ProgressBarContainer.Bar

	if v10 then
		v10:Cancel()
		v10 = nil
	end

	bar.Size = UDim2.new(0, 0, 1, 0)
	local v16 = math.max(v15 * 0.75, 0.05)
	v10 = TweenService:Create(bar, TweenInfo.new(v16, Enum.EasingStyle.Linear), {
		Size = UDim2.new(v15, 0, 1, 0)
	})
	v10:Play()
end

function ToggleKidFrame(p)
	local kidFrame = Client.Interface.KidFrame

	if kidFrame.Visible and v9 == p then
		kidFrame.Visible = false
		return
	end

	v9 = p
	kidFrame.Visible = true
	UpdateKidFrame()
	PlayXPBarTween()
end

function SetupKidFrame()
	local kidFrame = Client.Interface.KidFrame
	kidFrame.Visible = false
	backgroundColor3 = kidFrame.Window.Hunger.ProgressBarContainer.Bar.BackgroundColor3
	textColor3 = kidFrame.Window:FindFirstChild("Name").TextColor3
	local taskButtons = kidFrame.Window.TaskButtons
	v11 = {
		Selected = taskButtons.SelectedButton,
		Unlocked = taskButtons.UnlockedButton,
		Locked = taskButtons.LockedButton
	}

	for _, v14 in pairs(v11) do
		v14.Visible = false
	end

	taskButtons.Visible = false
	kidFrame.Window.TaskTextLabel.Visible = false
	game.ReplicatedStorage.Configs:GetAttributeChangedSignal("OtherKidsHaveJobs"):Connect(function()
		UpdateKidFrame()
	end)
	kidFrame.Window.CloseButton.Activated:Connect(function()
		kidFrame.Visible = false
		Client.Sound.Play("CloseButton")
	end)
end

function KidAdded(instance)
	local kidId = instance:GetAttribute("KidId")

	if not kidId or v8[instance] then
		return
	end

	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
	local friendGui = humanoidRootPart:FindFirstChild("FriendGui")

	if friendGui == nil then
		friendGui = game.ReplicatedStorage.Assets.Billboards.FriendGui:Clone()
		friendGui.Working.Item.Image = v6[kidId] or "rbxassetid://130009604520646"
		friendGui.Parent = humanoidRootPart
	end

	local face = instance:WaitForChild("Head"):WaitForChild("face")
	local child = game.ReplicatedStorage.Shops.KidInventory:WaitForChild(kidId)
	local container = friendGui.Default.Container
	local v14 = {
		Model = instance,
		Gui = friendGui,
		Container = container,
		Face = face,
		Inventory = child,
		Exclaims = {},
		Connections = {},
		LastLevel = instance:GetAttribute("FriendLevel"),
		LevelUpEndTime = 0,
		HungerBarColour = container.LevelAndHunger.Hunger.ProgressBarContainer.Bar.BackgroundColor3,
		HungerLabelColour = container.LevelAndHunger.HungerLabel.TextColor3
	}
	v8[instance] = v14
	local connections = v14.Connections

	for _, v15 in pairs(v2) do
		table.insert(connections, instance:GetAttributeChangedSignal(v15):Connect(function()
			UpdateGui(v14)
		end))
	end

	table.insert(connections, instance:GetAttributeChangedSignal("FriendLevel"):Connect(function()
		OnFriendLevelChanged(v14)
	end))
	table.insert(connections, child.ChildAdded:Connect(function()
		UpdateGui(v14)
	end))
	table.insert(connections, child.ChildRemoved:Connect(function()
		UpdateGui(v14)
	end))
	UpdateGui(v14)
end

function KidRemoved(p)
	local v14 = v8[p]

	if not v14 then
		return
	end

	for _, connection in pairs(v14.Connections) do
		connection:Disconnect()
	end

	v8[p] = nil

	if v9 == p then
		v9 = nil
		Client.Interface.KidFrame.Visible = false
	end
end

function ShowXPPopup(instance, p: number)
	local torso = instance:FindFirstChild("Torso") or instance:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local XP = humanoidRootPart and humanoidRootPart:FindFirstChild("XP")

	if not (torso and XP) then
		return
	end

	local clone = XP:Clone()
	clone.TextLabel.Text = p .. "xp"
	clone.Adornee = torso
	clone.Enabled = true
	local vector2 = Vector3.new(
		(math.random() - 0.5) * 1.5 * 2,
		(math.random() - 0.5) * 1.5,
		(math.random() - 0.5) * 1.5 * 2
	)
	clone.StudsOffsetWorldSpace = vector2
	clone.Parent = torso
	local v14 = math.clamp((p - 10) / 80, 0, 1) * 0.5 + 1.5
	TweenService:Create(clone, TweenInfo.new(v14, Enum.EasingStyle.Linear), {
		StudsOffsetWorldSpace = vector2 + createVector(0, 1.25, 0)
	}):Play()
	Debris:AddItem(clone, v14)
end

function LostChildClient.Init()
	for _, v14 in pairs(v7) do
		Client.InteractionHandler.RegisterInteraction("Befriend" .. v14, function() end)
	end

	local function toggleFromTent(instance)
		local kidId = instance:GetAttribute("KidId")

		for k, _ in pairs(v8) do
			if not (k:GetAttribute("KidId") == kidId and k:GetAttribute("Friending")) then
				continue
			end

			ToggleKidFrame(k)
			break
		end
	end

	Client.InteractionHandler.RegisterInteraction("KidTent", toggleFromTent)
	Client.InteractionHandler.RegisterInteraction("DinoKidTent", toggleFromTent)
	Client.InteractionHandler.RegisterInteraction("MakeKidBed", function() end)
	SetupKidFrame()
	Client.Events.KidXPGained:Connect(ShowXPPopup)
	Client.Utility.ForAllTagged("ChildNPC", KidAdded, KidRemoved)
end

return LostChildClient