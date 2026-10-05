local PlayerBillboardNameHandler = {}
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local UI_EmitterModule = require(game.ReplicatedStorage.UI_EmitterModule)
local AdminUsers = require(ReplicatedStorage.SharedUtils.AdminUsers)
local devs = AdminUsers.Devs
local Maid = require(ReplicatedStorage.SharedUtils.Maid)
local CharacterVisibilityHandler = require(ReplicatedStorage.SharedUtils.CharacterVisibilityHandler)
local nameTag = ReplicatedStorage:WaitForChild("Parts"):WaitForChild("NameTag")
local Titles = require(ReplicatedStorage.SharedData.Titles)
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local SettingsFlags = require(ReplicatedStorage.SharedUtils.SettingsFlags)
local v = false
local v2 = {}

local function addCharacter(instance)
	if not instance:IsDescendantOf(workspace) then
		task.wait(5)

		if not instance:IsDescendantOf(workspace) then
			return
		end
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if not playerFromCharacter then
		return
	end

	local humanoidRootPart = nil

	while playerFromCharacter and playerFromCharacter.Parent do
		humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

		if humanoidRootPart then
			break
		else
			task.wait(1)
		end
	end

	if not (playerFromCharacter and playerFromCharacter.Parent and humanoidRootPart) then
		return
	end

	local maid = Maid.new()
	maid:GiveTask(instance.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			maid:Destroy()
		end
	end))
	local clone = nameTag:Clone()
	maid:GiveTask(instance:GetAttributeChangedSignal("RPName"):Connect(function()
		local rPName = instance:GetAttribute("RPName") or ""

		if rPName == "" or rPName == " " then
			rPName = playerFromCharacter.Name
		end

		local displayName = clone:WaitForChild("Frame"):WaitForChild("DisplayName")
		displayName.Visible = true
		displayName.Text = tostring(rPName)
	end))

	if Universe:IsGame() and playerFromCharacter == Players.LocalPlayer then
		clone.PlayerToHideFrom = Players.LocalPlayer
	end

	clone.Frame.DisplayName.Text = playerFromCharacter.DisplayName
	clone.Frame.UserName.Text = "@" .. playerFromCharacter.Name .. ""

	if tostring(playerFromCharacter.DisplayName) == tostring(playerFromCharacter.Name) then
		clone.Frame.DisplayName.Visible = false
	end

	local groupRank = clone.Frame.GroupRank

	if table.find(devs, playerFromCharacter.UserId) then
		local v3 = playerFromCharacter.UserId == 86131129
		groupRank.Text = v3 and "[Owner]" or "[Developer]"
		groupRank.TextColor3 = v3 and Color3.fromRGB(255, 135, 163) or Color3.fromRGB(130, 174, 255)
		groupRank.Visible = true
	else
		groupRank.Visible = false
	end

	clone.MaxDistance = 30
	clone.Adornee = humanoidRootPart
	clone.Parent = humanoidRootPart
	maid:GiveTask(clone)
	local title = clone:WaitForChild("Frame"):WaitForChild("Bottom"):WaitForChild("Title")
	local imageLabel = clone.Frame.Bottom:WaitForChild("Frame"):WaitForChild("ImageLabel")
	local shine = title:WaitForChild("Shine")
	local particles = shine.Particles

	for _, emitter in pairs(particles:GetChildren()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		UI_EmitterModule:AddEmitter(emitter, 1)
		local v3 = emitter
		maid:GiveTask(function()
			UI_EmitterModule:RemoveEmitter(v3)
		end)
	end

	task.spawn(function()
		local uIGradient = shine:WaitForChild("UIGradient")

		local function do_failable_action(callback)
			if uIGradient and uIGradient.Parent and particles and particles.Parent then
				callback()
			end
		end

		while uIGradient and uIGradient.Parent and particles and particles.Parent do
			uIGradient.Offset = Vector2.new(-0.8, 0)
			tweenHelpers.playTween(uIGradient, TweenInfo.new(1), {
				Offset = Vector2.new(0.9, 0)
			}):Play()
			task.wait(0.2)

			if uIGradient and uIGradient.Parent and particles and particles.Parent then
				particles.Sparkle.Enabled = true
			end

			task.wait(0.15)

			if uIGradient and uIGradient.Parent and particles and particles.Parent then
				particles.Sparkle.Enabled = false
			end

			task.wait(5)
		end
	end)

	local function updateTitle()
		local equippedTitle = instance:GetAttribute("EquippedTitle") or "None"
		local v3 = equippedTitle and Titles[equippedTitle]

		if not v3 then
			title.Parent.Visible = false
			return
		end

		title.Text = string.format("[ %s ]", v3.DisplayName)
		shine.Text = string.format("[ %s ]", v3.DisplayName)

		for _, uIGradient in pairs(title:GetChildren()) do
			if uIGradient:IsA("UIGradient") then
				uIGradient.Enabled = uIGradient.Name == v3.UIGradient
			end
		end

		imageLabel.Image = v3.Image == nil and "" or v3.Image or ""
		imageLabel.Visible = v3.Image ~= nil
		title.Parent.Visible = true
	end

	maid:GiveTask(instance:GetAttributeChangedSignal("EquippedTitle"):Connect(function()
		updateTitle()
	end))
	updateTitle()
	local bubbleChat = humanoidRootPart:FindFirstChild("BubbleChat")

	if bubbleChat then
		clone.Adornee = bubbleChat
	end

	local childAddedConnection = nil
	childAddedConnection = humanoidRootPart.ChildAdded:Connect(function(adornee)
		if adornee.Name == "BubbleChat" then
			if clone then
				clone.Adornee = adornee
			end

			if childAddedConnection then
				childAddedConnection:Disconnect()
			end
		end
	end)
	maid:GiveTask(childAddedConnection)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateBillboardVisibility()
		clone.Enabled = not (v or CharacterVisibilityHandler:IsHidden(instance))
	end

	v2[clone] = updateBillboardVisibility
	maid:GiveTask(function()
		v2[clone] = nil
	end)
	maid:GiveTask(CharacterVisibilityHandler.VisibilityChanged:Connect(function(p)
		if p == instance then
			updateBillboardVisibility() -- equivalent call inferred; original call site unknown
		end
	end))
	updateBillboardVisibility() -- equivalent call inferred; original call site unknown
end

function PlayerBillboardNameHandler:SetNameTagsHidden(flag: boolean)
	local v3 = flag == true

	if v == v3 then
		return
	end

	v = v3

	for _, v4 in pairs(v2) do
		v4()
	end
end

function PlayerBillboardNameHandler.AreNameTagsHidden(_)
	return v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function bindToNameTagSetting()
	task.spawn(function()
		local modules = ReplicatedStorage:WaitForChild("Modules", 60)

		if not modules then
			warn("[PlayerBillboardNameHandler] Modules folder not found; name tag setting not applied")
			return
		end

		local myDataController = modules:FindFirstChild("MyDataController")

		if not myDataController then
			local clientUI = modules:FindFirstChild("ClientUI")
			myDataController = clientUI and clientUI:WaitForChild("MyDataController", 60)
		end

		if not myDataController then
			warn("[PlayerBillboardNameHandler] MyDataController not found; name tag setting not applied")
			return
		end

		local module = require(myDataController)
		module:onReplicaReady(function(object)
			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateSetting()
				local nameTagToggle = object.Data.Settings and object.Data.Settings.NameTagToggle
				PlayerBillboardNameHandler:SetNameTagsHidden(SettingsFlags:GetEffective(nameTagToggle, "NameTagToggle") ~= true)
			end

			object:ListenToChange({ "Settings", "NameTagToggle" }, updateSetting)
			updateSetting() -- equivalent call inferred; original call site unknown
		end)
	end)
end

function PlayerBillboardNameHandler.Start(_)
	if RunService:IsServer() or script:GetAttribute("Started") then
		return
	end

	script:SetAttribute("Started", true)
	CollectionService:GetInstanceAddedSignal("Character"):Connect(addCharacter)

	for _, v3 in pairs(CollectionService:GetTagged("Character")) do
		task.spawn(addCharacter, v3)
	end

	bindToNameTagSetting() -- equivalent call inferred; original call site unknown
end

return PlayerBillboardNameHandler