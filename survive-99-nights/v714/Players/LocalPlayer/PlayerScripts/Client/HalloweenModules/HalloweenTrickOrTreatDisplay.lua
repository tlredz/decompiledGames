local HalloweenTrickOrTreatDisplay = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local tricksAndTreats = Client.Interface.TricksAndTreats
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
local folders = {}
local folders2 = {}
local v = false
local v2 = false

function Show(childName)
	local child = tricksAndTreats:FindFirstChild(childName)

	if not child then
		return
	end

	tricksAndTreats.Visible = true
	child.Size = UDim2.fromScale(0, 0)
	child.Visible = true
	TweenService:Create(child, tweenInfo, {
		Size = UDim2.fromScale(0.264, 0.964)
	}):Play()
end

function Hide(childName)
	local child = tricksAndTreats:FindFirstChild(childName)

	if not child then
		return
	end

	tricksAndTreats.Visible = true
	local tween = TweenService:Create(child, tweenInfo2, {
		Size = UDim2.fromScale(0, 0)
	})
	tween:Play()
	tween.Completed:Once(function()
		child.Visible = false
	end)
end

function SetNotifs()
	local trick = tricksAndTreats.Trick
	local count = 0

	for _, _ in pairs(folders2) do
		count += 1
	end

	trick.ImageLabel.TextLabel.Text = count
	local treat = tricksAndTreats.Treat
	local count2 = 0

	for _, _ in pairs(folders) do
		count2 += 1
	end

	treat.ImageLabel.TextLabel.Text = count2
end

function RenderFolders()
	for _, v3 in pairs(CollectionService:GetTagged("TrickOrTreatDelete")) do
		v3:Destroy()
	end

	folders = {}
	folders2 = {}

	local function makeText(childName, description)
		local child = tricksAndTreats:FindFirstChild(childName)

		if #child.Display.Holder:GetChildren() >= 6 then
			return
		end

		local clone = child.Display.Holder.Template:Clone()
		clone.Parent = child.Display.Holder
		clone.TextLabel.Text = description
		clone:AddTag("TrickOrTreatDelete")
		clone.Visible = true
	end

	local halloweenEffects = localPlayer:FindFirstChild("HalloweenEffects")
	local names = {}

	for _, folder in pairs(halloweenEffects:GetChildren()) do
		if not folder:IsA("Folder") or table.find(names, folder.Name) then
			continue
		end

		table.insert(names, folder.Name)
		local effectType = folder:GetAttribute("EffectType")
		makeText(effectType or "Treat", folder:GetAttribute("Description") or "Something is effecting you")

		if effectType == "Treat" then
			table.insert(folders, folder)
		else
			table.insert(folders2, folder)
		end
	end

	SetNotifs()

	if #folders > 0 and not v then
		Show("Treat")
		v = true
	elseif #folders <= 0 and v then
		Hide("Treat")
		v = false
	end

	if #folders2 > 0 and not v2 then
		Show("Trick")
		v2 = true
	elseif #folders2 <= 0 and v2 then
		Hide("Trick")
		v2 = false
	end
end

function SetupButtons()
	tricksAndTreats.Treat.Activated:Connect(function()
		Client.Sound.Play("KeyPress")

		if folders and #folders > 0 then
			tricksAndTreats.Treat.Display.Visible = not tricksAndTreats.Treat.Display.Visible
		else
			tricksAndTreats.Treat.Display.Visible = false
		end
	end)
	tricksAndTreats.Trick.Activated:Connect(function()
		Client.Sound.Play("KeyPress")

		if folders2 and #folders2 > 0 then
			tricksAndTreats.Trick.Display.Visible = not tricksAndTreats.Trick.Display.Visible
		else
			tricksAndTreats.Trick.Display.Visible = false
		end
	end)
	tricksAndTreats.Treat.Display.CloseButton.Activated:Connect(function()
		tricksAndTreats.Treat.Display.Visible = false
		Client.Sound.Play("CloseButton")
	end)
	tricksAndTreats.Trick.Display.CloseButton.Activated:Connect(function()
		tricksAndTreats.Trick.Display.Visible = false
		Client.Sound.Play("CloseButton")
	end)
end

function SetupFolderEvents(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function folderSetup(child)
		child.AttributeChanged:Connect(function()
			if not child or not child.Parent or child.Parent ~= instance then
				return
			end

			RenderFolders()
		end)
		RenderFolders()
	end

	for _, folder in pairs(instance:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		local v3 = folder
		folder.AttributeChanged:Connect(function()
			if not v3 or not v3.Parent or v3.Parent ~= instance then
				return
			end

			RenderFolders()
		end)
		RenderFolders()
	end

	instance.ChildAdded:Connect(function(child)
		folderSetup(child) -- equivalent call inferred; original call site unknown
	end)
	instance.ChildRemoved:Connect(function(_)
		RenderFolders()
	end)
	RenderFolders()
end

function HalloweenTrickOrTreatDisplay.Init()
	task.spawn(function()
		SetupButtons()
		local halloweenEffects = localPlayer:FindFirstChild("HalloweenEffects")

		if halloweenEffects then
			SetupFolderEvents(halloweenEffects)
		end
	end)
end

return HalloweenTrickOrTreatDisplay