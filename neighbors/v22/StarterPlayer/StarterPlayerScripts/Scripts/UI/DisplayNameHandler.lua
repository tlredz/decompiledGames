local localPlayer = game.Players.LocalPlayer
local currentCamera = workspace.CurrentCamera
local CollectionService = game:GetService("CollectionService")
game:GetService("Players")
local RunService = game:GetService("RunService")
require(game.ReplicatedStorage.Modules.Network)
require(game.ReplicatedStorage.Assets.Data.Store.Titles)
local Title = require(game.ReplicatedStorage.Modules.Title)
require(game.ReplicatedStorage.Modules.Janitor)

local function lerp(p: number, p2: number, p3: number)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isStreaming()
	return localPlayer:GetAttribute("StreamerMode") == nil or localPlayer:GetAttribute("StreamerMode")
end

local function update(instance)
	local fakeHumanoid = instance:FindFirstChild("FakeHumanoid")
	local playerFromCharacter = game.Players:GetPlayerFromCharacter(instance)

	if fakeHumanoid then
		playerFromCharacter = game.Players:FindFirstChild(instance.Name:split(" Puppet")[1])
	end

	if not playerFromCharacter then
		return
	end

	local title = playerFromCharacter:GetAttribute("Title")

	if not (fakeHumanoid or instance:WaitForChild("Humanoid", 10)) then
		return
	end

	local head = instance:WaitForChild("Head", 10)

	if not (head and head:FindFirstChild("DisplayName")) then
		return
	end

	local displayName = head.DisplayName

	if playerFromCharacter:GetAttribute("CustomTitleActive") then
		local customTitleJsonData = playerFromCharacter:GetAttribute("CustomTitleJsonData")

		if not customTitleJsonData or customTitleJsonData == "" then
			return
		end

		local convertTitleInfo_JSONEncodedToRoblox = Title.ConvertTitleInfo_JSONEncodedToRoblox(customTitleJsonData)

		if not convertTitleInfo_JSONEncodedToRoblox then
			return
		end

		Title:ConstructWithInfo(playerFromCharacter, displayName, convertTitleInfo_JSONEncodedToRoblox)
	else
		Title:Construct(playerFromCharacter, displayName, title)
	end

	local canvasGroup = displayName:FindFirstChildOfClass("CanvasGroup")

	if instance:GetAttribute("PuppetName") then
		local hex = Color3.fromRGB(0, 0, 0):ToHex()
		canvasGroup.Title.Visible = false
		canvasGroup.Label.Text = `<font color="#{hex}">{instance:GetAttribute("PuppetName")}</font>`
	end

	if playerFromCharacter == game.Players.LocalPlayer then
		displayName.PlayerToHideFrom = playerFromCharacter:GetAttribute("ShowOwnTag") and playerFromCharacter or nil
	end

	canvasGroup.Visible = true

	if playerFromCharacter:GetAttribute("Protected") then
		canvasGroup.Label.Text = "<font size=\"15\">🛡️</font>" .. (playerFromCharacter:GetAttribute("Verified") and "" or " ") .. canvasGroup.Label.Text
		canvasGroup.Label.TextColor3 = Color3.fromRGB(130, 211, 255)
	else
		canvasGroup.Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	canvasGroup.Label.Position = canvasGroup.Title.Text == "" and canvasGroup.Title.Position or UDim2.new(0.5, 0, 0, 0)
end

local function updatePlayer(player)
	if player.Character then
		return update(player.Character)
	end
end

local function addNameTag(instance)
	local head = instance:FindFirstChild("Head")

	if not head or head:FindFirstChild("DisplayName") then
		return
	end

	local clone = script.DisplayName:Clone()
	clone.MaxDistance = 100
	clone.Parent = head
	clone.AncestryChanged:Connect(function(_, parent)
		if not parent then
			clone:Destroy()
		end
	end)
	CollectionService:AddTag(clone, "DisplayTag")
	update(instance)
	return clone
end

local function registerCharacter(instance)
	local fakeHumanoid

	if instance:HasTag("Clone") then
		fakeHumanoid = instance:WaitForChild("FakeHumanoid")
	else
		fakeHumanoid = instance:WaitForChild("Humanoid")
	end

	fakeHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	fakeHumanoid:GetPropertyChangedSignal("DisplayName"):connect(function()
		return update(instance)
	end)
	instance:GetAttributeChangedSignal("PuppetName"):Connect(function()
		return update(instance)
	end)
	instance:GetAttributeChangedSignal("Invisible"):connect(function()
		return update(instance)
	end)
	instance.ChildAdded:connect(function(p)
		if p.Name == "Head" then
			return addNameTag(instance)
		end
	end)
	return addNameTag(instance)
end

local function registerPlayer(player)
	if not player.Character then
		player.CharacterAdded:Wait()
	end

	player:GetAttributeChangedSignal("Title"):connect(function()
		if player:GetAttribute("CustomTitleActive") then
			return
		else
			return updatePlayer(player)
		end
	end)
	player:GetAttributeChangedSignal("UseMasculineTitles"):connect(function()
		return updatePlayer(player)
	end)
	player:GetAttributeChangedSignal("CustomTitleActive"):Connect(function()
		if player.Character then
			update(player.Character)
		end
	end)
	player:GetAttributeChangedSignal("CustomTitleJsonData"):Connect(function()
		if player:GetAttribute("CustomTitleActive") then
			local v = player

			if v.Character then
				update(v.Character)
			end
		end
	end)
	player:GetAttributeChangedSignal("Protected"):connect(function()
		return updatePlayer(player)
	end)

	if player == game.Players.LocalPlayer then
		player:GetAttributeChangedSignal("ShowOwnTag"):connect(function()
			local v = player

			if not v.Character then
				return
			end

			update(v.Character)
		end)
		player:GetAttributeChangedSignal("HideGoldNametag"):connect(function()
			local v = player

			if not v.Character then
				return
			end

			update(v.Character)
		end)
	end

	player.CharacterAdded:connect(registerCharacter)

	if player.Character then
		return registerCharacter(player.Character)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setGroupTransparency(instance, p: number)
	if not instance:FindFirstChildOfClass("CanvasGroup") then
		return
	end

	local canvasGroup = instance:FindFirstChildOfClass("CanvasGroup")
	canvasGroup.GroupTransparency = p * 1 + 0
end

local function getScreenSize()
	return currentCamera.ViewportSize
end

local function calculateWidth(p: number)
	return 200 - p * 0.2
end

local function calculateHeight(p: number)
	return 45 - p * 0.3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function calculateOffset(parent, p: number)
	return parent.Parent:GetExtentsSize().Y / 3 + p * 0.01 * (1080 / currentCamera.ViewportSize.Y)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isTagVisible(parent)
	local lowerTorso = parent.Parent:FindFirstChild("LowerTorso")

	if lowerTorso then
		return lowerTorso.Transparency < 1
	end

	return parent.Transparency < 1
end

local function isTagVisible_Old(instance)
	local worldToScreenPoint, v = currentCamera:WorldToScreenPoint(instance.Position)

	if instance.Parent:GetAttribute("SetNameTag") then
		return true
	end

	if not v then
		return false
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { instance.Parent, localPlayer.Character }
	raycastParams.IgnoreWater = true
	local screenPointToRay = currentCamera:ScreenPointToRay(worldToScreenPoint.X, worldToScreenPoint.Y, 0)

	if workspace:Raycast(screenPointToRay.Origin, screenPointToRay.Direction * worldToScreenPoint.Z, raycastParams) then
		return true
	end
end

game.Players.PlayerAdded:Connect(function(player)
	registerPlayer(player)
end)

for _, v in game.Players:GetPlayers() do
	local v2 = v
	task.spawn(function()
		registerPlayer(v2)
	end)
end

CollectionService:GetInstanceAddedSignal("Clone"):Connect(function(p)
	registerCharacter(p)
end)
RunService.RenderStepped:Connect(function(_)
	local position = currentCamera.CFrame.Position
	local streaming = isStreaming() -- equivalent call inferred; original call site unknown

	for _, v in CollectionService:GetTagged("DisplayTag") do
		local magnitude = (v.Parent.Position - position).magnitude

		if magnitude < 100 then
			if streaming then
				v.Enabled = false
			else
				local v2 = magnitude - magnitude % 2
				local v3 = 200 - v2 * 0.2
				local v4 = 45 - v2 * 0.3
				local offset = calculateOffset(v.Parent, v2) -- equivalent call inferred; original call site unknown
				v.Size = UDim2.new(0, v3, 0, v4)
				v.StudsOffset = Vector3.new(0, offset, 0)
				local tagVisible = isTagVisible(v.Parent) -- equivalent call inferred; original call site unknown
				v.Enabled = tagVisible
				local v6 = magnitude / 100

				if v6 >= 0.8 then
					setGroupTransparency(v, math.min(1, (v6 - 0.8) / 0.19999999999999996)) -- equivalent call inferred; original call site unknown
				elseif v:FindFirstChildOfClass("CanvasGroup") then
					local canvasGroup = v:FindFirstChildOfClass("CanvasGroup")
					canvasGroup.GroupTransparency = 0
				end
			end
		else
			v.Enabled = false
		end
	end
end)