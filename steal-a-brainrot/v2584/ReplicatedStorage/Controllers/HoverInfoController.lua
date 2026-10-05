local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local Gradients = require(ReplicatedStorage.Packages.Gradients)
local ReplicatorClient = require(ReplicatedStorage.Packages.ReplicatorClient)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local Net = require(ReplicatedStorage.Packages.Net)
local datas = ReplicatedStorage:WaitForChild("Datas")
local Animals = require(datas.Animals)
local Rarities = require(datas.Rarities)
local Mutations = require(datas.Mutations)
local LuckyBlocks = require(datas.LuckyBlocks)
local v = {}

for k, luckyBlock in LuckyBlocks do
	for _, name in luckyBlock.Animals do
		if type(name) ~= "string" then
			name = name.Name
		end

		if not name or v[name] then
			continue
		end

		v[name] = k
	end
end

local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local shared = ReplicatedStorage:WaitForChild("Shared")
local Animals2 = require(shared.Animals)
local MutationText = require(ReplicatedStorage.Shared.MutationText)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local popup = playerGui:WaitForChild("Index"):WaitForChild("Popup")
local txt1 = popup:WaitForChild("Header"):WaitForChild("Txt1")
local infos = popup:WaitForChild("Infos")
local rarity = infos:WaitForChild("Rarity")
local cps = infos:WaitForChild("Cps")
local obtained = infos:WaitForChild("Obtained")
local exists = infos:WaitForChild("Exists")
local label = exists:WaitForChild("Label")
local ITEM_IMAGE = exists:WaitForChild("ITEM_IMAGE")
local publicExistCounts = ReplicatorClient.get("PublicExistCounts")
local v2 = {}
local v3 = 0
local renderSteppedConnection = nil
local color = Color3.fromRGB(166, 166, 166)
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local HoverInfoController = {}

local function isRealMutation(p: string?)
	return p ~= nil and p ~= "Default" and p ~= "All" and Mutations[p] ~= nil
end

local function findParticipant(guiObjectsAtPosition)
	for _, parent in guiObjectsAtPosition do
		while parent and parent ~= playerGui and parent.Name ~= "Starburst" do
			local v11 = v2[parent]

			if v11 then
				return parent, v11
			else
				parent = parent.Parent
			end
		end
	end

	return nil, nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupEffects()
	if v8 then
		v8()
		v8 = nil
	end

	if v9 then
		v9()
		v9 = nil
	end
end

local function applyExists(p: string, p2: string?)
	local v11

	if p2 == nil or p2 == "Default" or p2 == "All" then
		v11 = false
	else
		v11 = Mutations[p2] ~= nil
	end

	if v9 then
		v9()
		v9 = nil
	end

	local v12 = publicExistCounts:TryIndex({ "data", p })

	if not v12 then
		exists.Visible = false
		return
	end

	local v13 = v12.mutations[not v11 and "None" or p2] or 0
	local v14

	if v13 > 999999 then
		v14 = NumberUtils:ToString(v13)
	else
		v14 = NumberUtils:Comma(v13)
	end

	ITEM_IMAGE.Image = not v11 and "rbxassetid://139326264265904" or Mutations[p2].Icon
	label.TextColor3 = color
	local apply = MutationText.apply

	if not v11 then
		p2 = nil
	end

	v9 = apply(label, p2)
	label.Text = `{v14} Exist`
	label.RichText = false
	exists.Visible = true
end

local function unbindExistsListener()
	if v10 then
		v10()
		v10 = nil
	end
end

local function bindExistsListener(p: string)
	if v10 then
		v10()
		v10 = nil
	end

	v10 = publicExistCounts:Listen({ "data", p }, function()
		applyExists(p, v7)
	end)
end

local v11 = false

local function populate(p: string, value: string?, list)
	local formatted = ("%*\0%*\0%*"):format(p, value or "Default", not list and "" or table.concat(list, ","))

	if formatted == v5 then
		return
	end

	if not v11 then
		v11 = true
		task.spawn(function()
			if ServerData.IsTsunamiServer() or ServerData.IsDuelsServer() then
				return
			end

			Net:RemoteEvent("ExistCounts/RequestPublic"):FireServer("4833d1a5-7006-4219-a006-18550cb9f1c6")
		end)
	end

	local v12 = p ~= v6
	v5 = formatted
	v6 = p
	v7 = value

	if v12 then
		bindExistsListener(p)
	end

	local animal = Animals[p]
	local rarity2 = Rarities[animal.Rarity]
	local v13

	if value == nil or value == "Default" or value == "All" then
		v13 = false
	else
		v13 = Mutations[value] ~= nil
	end

	cleanupEffects() -- equivalent call inferred; original call site unknown
	txt1.Text = animal.DisplayName
	rarity.Text = animal.Rarity

	if rarity2 and rarity2.GradientPreset then
		rarity.TextColor3 = Color3.fromRGB(255, 255, 255)
		v8 = Gradients.apply(rarity, rarity2.GradientPreset)
	elseif rarity2 then
		rarity.TextColor3 = rarity2.Color
	end

	if animal.Generation or animal.Price then
		local v15

		if v13 then
			v15 = value
		end

		cps.Text = `${NumberUtils:ToString((Animals2:GetGeneration(p, v15, list)))}/s`
		cps.Visible = true
	else
		cps.Visible = false
	end

	local v14 = FFlags:GetInstant("Sources", {})[p]
	local obtainedFrom = animal.ObtainedFrom
	local source = nil
	local v15 = true

	if obtainedFrom then
		source = obtainedFrom.Source
		v15 = obtainedFrom.Obtainable ~= false
	elseif animal.RoadWeight then
		source = "The Red Carpet"
		v15 = true
	elseif v[p] then
		source = v[p]
		v15 = true
	end

	if source then
		obtained.Visible = true
		local v16 = obtained

		if v14 then
			source = v14
		elseif not (obtainedFrom and obtainedFrom.FullText) then
			source = `This {v15 and "is" or "was"} obtained from {source}`
		end

		v16.Text = source
	else
		obtained.Visible = false
	end

	applyExists(p, value)
end

local function movePopup(mouseLocation: Vector2)
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local absoluteSize = popup.AbsoluteSize
	local v12 = mouseLocation.X + 16
	local v13 = mouseLocation.Y + 16

	if v12 + absoluteSize.X > viewportSize.X then
		v12 -= absoluteSize.X
	end

	if v13 + absoluteSize.Y > viewportSize.Y then
		v13 -= absoluteSize.Y
	end

	popup.Position = UDim2.fromOffset(v12, v13)
end

local function onRender()
	local mouseLocation = UserInputService:GetMouseLocation()
	local Y = GuiService:GetGuiInset().Y
	local participant, v12 = findParticipant(playerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y - Y))

	if participant and v12 then
		local v13, v14, v15 = v12()

		if v13 and Animals[v13] then
			v4 = participant
			populate(v13, v14, v15)
			movePopup(mouseLocation)
			popup.Visible = true
			return
		end
	end

	v4 = nil
	v5 = nil
	v6 = nil
	v7 = nil

	if v10 then
		v10()
		v10 = nil
	end

	popup.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureLoop()
	if renderSteppedConnection then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(onRender)
end

local function stopLoopIfIdle()
	if v3 > 0 or not renderSteppedConnection then
		return
	end

	renderSteppedConnection:Disconnect()
	renderSteppedConnection = nil
	cleanupEffects() -- equivalent call inferred; original call site unknown
	v4 = nil
	v5 = nil
	v6 = nil
	v7 = nil

	if v10 then
		v10()
		v10 = nil
	end

	popup.Visible = false
end

function HoverInfoController.Add(_, instance, callback)
	if v2[instance] then
		return function() end
	end

	v2[instance] = callback
	v3 += 1
	ensureLoop() -- equivalent call inferred; original call site unknown
	local flag = false
	local destroyingConnection = instance.Destroying:Once(function()
		flag = true
		HoverInfoController:Remove(instance)
	end)
	return function()
		if flag then
			return
		end

		flag = true
		destroyingConnection:Disconnect()
		HoverInfoController:Remove(instance)
	end
end

function HoverInfoController:Remove(p)
	if not v2[p] then
		return
	end

	v2[p] = nil
	v3 -= 1

	if v4 == p then
		v4 = nil
		v5 = nil
		v6 = nil
		v7 = nil

		if v10 then
			v10()
			v10 = nil
		end

		popup.Visible = false
	end

	if not (v3 > 0) then
		if not renderSteppedConnection then
			return
		end

		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
		cleanupEffects() -- equivalent call inferred; original call site unknown
		v4 = nil
		v5 = nil
		v6 = nil
		v7 = nil

		if v10 then
			v10()
			v10 = nil
		end

		popup.Visible = false
	end
end

function HoverInfoController.Start(_)
	popup.Visible = false
end

return HoverInfoController