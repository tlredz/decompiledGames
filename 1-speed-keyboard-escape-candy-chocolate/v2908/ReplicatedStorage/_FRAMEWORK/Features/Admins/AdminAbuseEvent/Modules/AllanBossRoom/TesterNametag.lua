local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Janitor = require(ReplicatedStorage.Utilities.Janitor)
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
local Tester = require(ReplicatedStorage.FeatureConfigs.GroupTags.Configs.Tester)
local TesterNametag = {}
local uDim = UDim2.new(6, 0, 1, 0)
local vector2 = Vector2.new(0, 0.3)
local color = Color3.fromRGB(0, 0, 0)
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function playerHasOwnOverheadTag(instance)
	return AdminPermissions.getRole(instance.UserId) ~= nil or instance:GetAttribute("GroupTagKey") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkHeadReady(instance)
	local head = instance:FindFirstChild("Head") or instance:WaitForChild("Head", 5)

	if head and head:IsA("BasePart") then
		return true, head
	end

	return false, nil
end

local function buildBillboard()
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "AllanBossRoomTesterNametag"
	billboardGui.AlwaysOnTop = true
	billboardGui.Size = uDim
	billboardGui.SizeOffset = vector2
	billboardGui.StudsOffset = createVector(0, 2.5, 0)
	billboardGui.MaxDistance = 150
	billboardGui.ResetOnSpawn = false
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Title"
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Text = Tester.label
	textLabel.TextColor3 = Tester.color
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextScaled = true
	textLabel.Parent = billboardGui
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2
	uIStroke.Color = color
	uIStroke.Parent = textLabel
	return billboardGui
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshCharacter(object, instance, character)
	if playerHasOwnOverheadTag(instance) then
		object:Remove("billboard")
		return
	end

	local v2, parent = checkHeadReady(character) -- equivalent call inferred; original call site unknown

	if v2 then
		local billboard = buildBillboard()
		billboard.Parent = parent
		object:Add(billboard, "Destroy", "billboard")
	end
end

local function watchPlayer(object, player)
	local v2 = Janitor.new()

	local function refresh()
		local character = player.Character

		if character then
			refreshCharacter(v2, player, character) -- equivalent call inferred; original call site unknown
		end
	end

	local characterAddedConnection = player.CharacterAdded:Connect(function(character)
		refreshCharacter(v2, player, character) -- equivalent call inferred; original call site unknown
	end)
	local groupTagKeyChangedConnection = player:GetAttributeChangedSignal("GroupTagKey"):Connect(refresh)
	local character = player.Character

	if character then
		if playerHasOwnOverheadTag(player) then
			v2:Remove("billboard")
		else
			local v3, parent = checkHeadReady(character) -- equivalent call inferred; original call site unknown

			if v3 then
				local billboard = buildBillboard()
				billboard.Parent = parent
				v2:Add(billboard, "Destroy", "billboard")
			end
		end
	end

	v2:Add(characterAddedConnection)
	v2:Add(groupTagKeyChangedConnection)
	object:Add(v2, "Destroy", player)
end

function TesterNametag.start()
	assert(RunService:IsServer(), "AllanBossRoom.TesterNametag: start() is server-only")
	TesterNametag.stop()
	local v2 = Janitor.new()
	v = v2
	local playerAddedConnection = Players.PlayerAdded:Connect(function(player)
		watchPlayer(v2, player)
	end)
	local playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		v2:Remove(player)
	end)

	for _, v3 in Players:GetPlayers() do
		task.spawn(watchPlayer, v2, v3)
	end

	v2:Add(playerAddedConnection)
	v2:Add(playerRemovingConnection)
end

function TesterNametag.stop()
	if v then
		v:Cleanup()
		v = nil
	end
end

return TesterNametag