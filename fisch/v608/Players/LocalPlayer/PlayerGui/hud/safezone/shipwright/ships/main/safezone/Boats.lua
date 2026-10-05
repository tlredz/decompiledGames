local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local character = require(ReplicatedStorage.shared.modules.character)
local vessels = require(ReplicatedStorage.shared.modules.vessels)
local library = vessels.library
local fx = require(ReplicatedStorage.shared.modules.fx)
local debris = require(ReplicatedStorage.shared.modules.fx.debris)
local WorldController = require(ReplicatedStorage.client.legacyControllers.WorldController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local localPlayer = Players.LocalPlayer
local flag = false
local playerGui = localPlayer.PlayerGui
local safezone = playerGui.hud.safezone
local remoteFunction = Net:RemoteFunction("Boats/Spawn")
local remoteFunction2 = Net:RemoteFunction("Boats/Purchase")
local remoteEvent = Net:RemoteEvent("Boats/Open")
local remoteFunction3 = Net:RemoteFunction("Boats/Favorite")
local CurrencyController = require(game.ReplicatedStorage.client.legacyControllers.CurrencyController)
local _ = {
	FirstSea = "Sea 1",
	SecondSea = "Sea 2"
}
local _ = {
	FirstSea = { 135499799161875 },
	SecondSea = { 135499799161875 }
}
local _ = RunService:IsStudio() and 135499799161875

-- equivalent calls inferred from this helper; original call sites unknown
local function fastTween(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween.Completed:Once(function()
		tween:Destroy()
	end)
	tween:Play()
	return tween
end

local v = nil
local v2 = {
	AncientDock = {
		onOpen = function()
			for _, frame in script.Parent:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				if string.find(frame.Name, "The Essex Boat") then
					frame:SetAttribute("AlwaysVisible", true)
					frame:SetAttribute("CanForceSpawn", true)
					frame.Visible = true
				else
					frame:SetAttribute("Hidden", true)
					frame.Visible = false
				end
			end
		end,
		onClose = function()
			for _, frame in script.Parent:GetChildren() do
				if not frame:IsA("Frame") then
					continue
				end

				if string.find(frame.Name, "The Essex Boat") then
					frame:SetAttribute("AlwaysVisible", nil)
					frame:SetAttribute("CanForceSpawn", nil)
				else
					frame:SetAttribute("Hidden", nil)
				end
			end
		end
	}
}
local v3 = character.PS(localPlayer)

if v3 == nil then
	repeat
		task.wait(1)
		v3 = character.PS(localPlayer)
	until v3 ~= nil
end

local boats = v3:WaitForChild("Boats")
script.Parent:GetAttributeChangedSignal("IsUtilityTab"):Connect(function()
	if script.Parent:GetAttribute("IsUtilityTab") then
		for _, frame in script.Parent:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame:GetAttribute("Hidden") then
				frame.Visible = false
			elseif frame:GetAttribute("AlwaysVisible") then
				frame.Visible = true
			else
				frame.Visible = frame:GetAttribute("IsUtility") == true
				frame:SetAttribute("CanSearch", frame:GetAttribute("IsUtility") == true)
			end
		end
	else
		for _, frame in script.Parent:GetChildren() do
			if not frame:IsA("Frame") then
				continue
			end

			if frame:GetAttribute("Hidden") then
				frame.Visible = false
			elseif frame:GetAttribute("AlwaysVisible") then
				frame.Visible = true
			else
				frame.Visible = frame:GetAttribute("IsUtility") ~= true and frame:GetAttribute("CanUsuallySearch")
				frame:SetAttribute(
					"CanSearch",
					frame:GetAttribute("CanUsuallySearch") and not frame:GetAttribute("IsUtility")
				)
			end
		end
	end
end)

function UpdateCanvasSize(p, p2)
	p.CanvasSize = UDim2.new(0, 0, 0, p2.AbsoluteContentSize.Y)
end

local count = 0

function CreateButton(boatName)
	count += 1
	local v4 = library[boatName]
	local clone = script:WaitForChild("template"):Clone()
	clone.title.Text = boatName
	clone.speed.Text = "Speed: " .. v4.MaxSpeed .. "S/ps"
	clone.turning.Text = "Steering: " .. tostring((math.round(v4.TurningSpeed * 100))) .. "°"
	clone.accel.Text = "Acceleration: " .. tostring(v4.Accel) .. "S/ps"
	clone.desc.Text = tostring(v4.Description)

	if boatName == "Random Boat" then
		clone.speed.Visible = false
		clone.turning.Visible = false
		clone.accel.Visible = false
	end

	local durability = v4.Durability

	if durability then
		clone.durability.Text = `Durability: {durability}`
		clone.durability.Visible = true
	end

	clone:SetAttribute("BoatName", boatName)

	local function updateVisibility()
		if v4.IsUtility then
			clone.Visible = false
			clone:SetAttribute("IsUtility", true)
			clone:SetAttribute("CanSearch", false)
			clone:SetAttribute("CanUsuallySearch", true)
		elseif v4.Unpurchasable then
			local visible2 = boats:FindFirstChild(boatName) ~= nil
			clone.Visible = visible2
			clone:SetAttribute("CanSearch", visible2)
			clone:SetAttribute("CanUsuallySearch", visible2)
		else
			clone.Visible = true
			clone:SetAttribute("CanSearch", true)
			clone:SetAttribute("CanUsuallySearch", true)
		end

		if v4.HideInShop and not boats:FindFirstChild(boatName) then
			clone.Visible = false
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLayoutOrder()
		local level = v4.Level

		if v4.Unpurchasable then
			level += 10000
		end

		if v4.SortOffset then
			level += v4.SortOffset
		end

		clone.LayoutOrder = level
	end

	updateLayoutOrder() -- equivalent call inferred; original call site unknown
	updateVisibility()
	clone.icon.Image = v4.Icon

	local function ButtonColorUpdate()
		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		if boats:FindFirstChild(boatName) then
			clone.Visible = not clone:GetAttribute("IsUtility") or script.Parent:GetAttribute("IsUtilityTab")
			clone:SetAttribute(
				"CanSearch",
				not clone:GetAttribute("IsUtility") or script.Parent:GetAttribute("IsUtilityTab")
			)
		end

		local canForceSpawn = clone:GetAttribute("CanForceSpawn")

		if CurrencyController:Get() >= v4.Price and v4.Price ~= -1 and v3:WaitForChild("Stats"):WaitForChild("level").Value >= v4.Level or boats:FindFirstChild(boatName) or canForceSpawn then
			clone.spawn.TextColor3 = Color3.fromRGB(162, 234, 166)
			clone.spawn.border.Color = Color3.fromRGB(162, 234, 166)
			clone.stroke.Color = Color3.fromRGB(122, 138, 116)
		else
			clone.spawn.TextColor3 = Color3.fromRGB(81, 81, 81)
			clone.spawn.border.Color = Color3.fromRGB(81, 81, 81)
			clone.stroke.Color = Color3.fromRGB(48, 48, 48)
		end
	end

	local instance

	repeat
		instance = CurrencyController:GetInstance()
	until instance or not task.wait()

	instance.Changed:Connect(function()
		ButtonColorUpdate()
	end)

	local function IsPurchased(p)
		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		if p == false then
			clone.spawn.Text = "[Purchase]"

			if v4.Price == -1 then
				clone.price.Text = v4.ObtainText or "Not For Sale"
				clone.price.TextColor3 = Color3.fromRGB(81, 81, 81)
			else
				clone.price.Text = tostring(v4.Price) .. CurrencyController:GetDisplay()
				clone.price.TextColor3 = Color3.fromRGB(162, 234, 166)
			end

			clone.Name = boatName

			if Players.LocalPlayer:GetAttribute("ABTest_QuickBoats") and boatName == "Rowboat" then
				if v3:WaitForChild("Stats"):WaitForChild("level").Value < Players.LocalPlayer:GetAttribute("ABTest_QuickBoats") then
					clone.spawn.Text = `[Requires Level {Players.LocalPlayer:GetAttribute("ABTest_QuickBoats")}]`
				end
			elseif v3:WaitForChild("Stats"):WaitForChild("level").Value < v4.Level then
				clone.spawn.Text = "[Requires Level " .. v4.Level .. "]"
			end

			clone.ownedIcon.Image = "rbxassetid://17849848660"

			if v4.HideInShop and not boats:FindFirstChild(boatName) then
				clone.Visible = false
			end
		else
			clone.spawn.Text = "[Spawn]"
			clone.price.Text = "Owned"
			clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
			clone.Name = "1" .. boatName
			clone.Visible = true
			clone.ownedIcon.Image = "rbxassetid://17849844038"
		end

		updateVisibility()
		ButtonColorUpdate()
	end

	local favorite = clone.favorite

	local function UpdateFavorited(flag2: boolean)
		favorite.Image = flag2 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
		favorite.ImageTransparency = flag2 and 0.25 or 0.75
		local favorite2 = favorite
		local imageColor

		if flag2 then
			imageColor = Color3.fromRGB(255, 162, 0)
		else
			imageColor = Color3.fromRGB(255, 255, 255)
		end

		favorite2.ImageColor3 = imageColor
		local title = clone.title
		local textColor

		if flag2 then
			textColor = Color3.fromRGB(255, 162, 0)
		else
			textColor = Color3.fromRGB(255, 255, 255)
		end

		title.TextColor3 = textColor
		updateLayoutOrder() -- equivalent call inferred; original call site unknown

		if flag2 then
			clone.LayoutOrder -= 10000000
		end
	end

	local v5 = false

	local function SetupFavoriteButton()
		local child = boats:FindFirstChild(boatName)
		favorite.Visible = child

		if child and not v5 then
			v5 = true
			local favorited = child:FindFirstChild("favorited")

			if favorited then
				UpdateFavorited(favorited.Value)
			end

			favorite.Activated:Connect(function()
				local v6 = remoteFunction3:InvokeServer(boatName)

				if v6 ~= nil then
					UpdateFavorited(v6)
				end
			end)
		end
	end

	SetupFavoriteButton()
	clone:GetAttributeChangedSignal("CanForceSpawn"):Connect(function()
		if not clone:GetAttribute("CanForceSpawn") and not boats:FindFirstChild(boatName) then
			IsPurchased(false)
			return
		end

		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		clone.spawn.Text = "[Spawn]"
		clone.price.Text = "Owned"
		clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
		clone.Name = "1" .. boatName
		clone.Visible = true
		clone.ownedIcon.Image = "rbxassetid://17849844038"
		updateVisibility()
		ButtonColorUpdate()
	end)
	clone:GetAttributeChangedSignal("Hidden"):Connect(function()
		if clone:GetAttribute("Hidden") then
			clone.Visible = false
		else
			updateVisibility()
		end
	end)
	clone:GetAttributeChangedSignal("AlwaysVisible"):Connect(function()
		if clone:GetAttribute("AlwaysVisible") then
			clone.Visible = true
		else
			updateVisibility()
		end
	end)

	if boats:FindFirstChild(boatName) then
		if clone:GetAttribute("Hidden") then
			clone.Visible = false
		else
			clone.spawn.Text = "[Spawn]"
			clone.price.Text = "Owned"
			clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
			clone.Name = "1" .. boatName
			clone.Visible = true
			clone.ownedIcon.Image = "rbxassetid://17849844038"
			updateVisibility()
			ButtonColorUpdate()
		end
	else
		IsPurchased(false)
	end

	boats.ChildAdded:Connect(function()
		SetupFavoriteButton()

		if not boats:FindFirstChild(boatName) then
			IsPurchased(false)
			return
		end

		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		clone.spawn.Text = "[Spawn]"
		clone.price.Text = "Owned"
		clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
		clone.Name = "1" .. boatName
		clone.Visible = true
		clone.ownedIcon.Image = "rbxassetid://17849844038"
		updateVisibility()
		ButtonColorUpdate()
	end)
	boats.ChildRemoved:Connect(function()
		SetupFavoriteButton()

		if not boats:FindFirstChild(boatName) then
			IsPurchased(false)
			return
		end

		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		clone.spawn.Text = "[Spawn]"
		clone.price.Text = "Owned"
		clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
		clone.Name = "1" .. boatName
		clone.Visible = true
		clone.ownedIcon.Image = "rbxassetid://17849844038"
		updateVisibility()
		ButtonColorUpdate()
	end)
	clone.spawn.MouseButton1Click:Connect(function()
		if flag then
			return
		end

		if boats:FindFirstChild(boatName) ~= nil or clone:GetAttribute("CanForceSpawn") then
			flag = true
			script.Parent.Parent.Visible = false
			script.Parent.Parent.Parent.waitingforResponse.Visible = true
			remoteFunction:InvokeServer(boatName)
			script.Parent.Parent.Visible = true
			script.Parent.Parent.Parent.waitingforResponse.Visible = false
			local shipwright = script:FindFirstAncestor("shipwright")
			shipwright.Visible = false
			playerGui.backpack.Enabled = true
			task.wait(0.5)
			flag = false
		else
			flag = true
			safezone.shipwright:SetAttribute("DontClose", true)
			local v6, v7 = remoteFunction2:InvokeServer(boatName)

			if v6 == true then
				task.wait(0.25)
				playerGui.backpack.Enabled = false
				safezone.shipwright.Visible = true
			else
				if v7 and v7 == "Money" then
					HudController:RedirectPurchase()
				end

				local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
				fx:PlaySound(
					ReplicatedStorage2:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("ui"):WaitForChild("deny"),
					script.Parent,
					true
				)
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
				colorCorrectionEffect.Parent = game:GetService("Lighting")
				colorCorrectionEffect.TintColor = Color3.fromRGB(214, 81, 81)
				fastTween(
					colorCorrectionEffect,
					TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
					{
						TintColor = Color3.fromRGB(255, 255, 255)
					}
				) -- equivalent call inferred; original call site unknown
				debris:AddItem(colorCorrectionEffect, 2)
				task.wait(1)
			end

			safezone.shipwright:SetAttribute("DontClose", nil)
			flag = false
		end
	end)
	favorite.Activated:Connect(function() end)
	v3:WaitForChild("Stats"):WaitForChild("level").Changed:Connect(function()
		ButtonColorUpdate()

		if not boats:FindFirstChild(boatName) then
			IsPurchased(false)
			return
		end

		if clone:GetAttribute("Hidden") then
			clone.Visible = false
			return
		end

		clone.spawn.Text = "[Spawn]"
		clone.price.Text = "Owned"
		clone.price.TextColor3 = Color3.fromRGB(30, 30, 30)
		clone.Name = "1" .. boatName
		clone.Visible = true
		clone.ownedIcon.Image = "rbxassetid://17849844038"
		updateVisibility()
		ButtonColorUpdate()
	end)
	UpdateCanvasSize(script.Parent.Parent, script.Parent.UIListLayout)
	ButtonColorUpdate()
	clone.Parent = script.Parent
end

local function isPlaceIdInItemWorlds(p)
	local v4 = not p.Worlds and { "Sea 1", "Sea 2" } or p.Worlds
	local currentWorldIndex = WorldController:GetCurrentWorldIndex()

	if table.find(v4, currentWorldIndex) then
		return true
	end

	return false
end

for childName, v4 in pairs(library) do
	if v4.Worlds then
		local v5 = not v4.Worlds and { "Sea 1", "Sea 2" } or v4.Worlds
		local currentWorldIndex = WorldController:GetCurrentWorldIndex()

		if not (table.find(v5, currentWorldIndex) or boats:FindFirstChild(childName)) then
			continue
		end
	end

	CreateButton(childName)
end

local shipwright = script:FindFirstAncestor("shipwright")
local visible = false
shipwright.Changed:Connect(function()
	if visible ~= shipwright.Visible then
		visible = shipwright.Visible

		if shipwright.Visible == true then
			task.wait()
			fastTween(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				FieldOfView = 60
			}) -- equivalent call inferred; original call site unknown
			local Lighting = game:GetService("Lighting")
			fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 10
				}
			) -- equivalent call inferred; original call site unknown
			local Lighting2 = game:GetService("Lighting")
			local tween = TweenService:Create(
				Lighting2:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = -0.07,
					TintColor = Color3.fromRGB(184, 184, 184),
					Saturation = -0.3
				}
			)
			tween.Completed:Once(function()
				tween:Destroy()
			end)
			tween:Play()
		else
			fastTween(workspace.CurrentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				FieldOfView = 70
			}) -- equivalent call inferred; original call site unknown
			local Lighting = game:GetService("Lighting")
			fastTween(
				Lighting:WaitForChild("uiblur"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Size = 0
				}
			) -- equivalent call inferred; original call site unknown
			local Lighting2 = game:GetService("Lighting")
			fastTween(
				Lighting2:WaitForChild("uicc"),
				TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
				{
					Brightness = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
					Saturation = 0
				}
			) -- equivalent call inferred; original call site unknown
			local v5 = v and v2[v]

			if v5 and v5.onClose then
				v5.onClose()
			end
		end
	end

	UpdateCanvasSize(script.Parent.Parent, script.Parent.UIListLayout)
end)
local count2 = 0
local RunService2 = game:GetService("RunService")
RunService2.Heartbeat:Connect(function()
	count2 += 1

	if count2 == 5 then
		count2 = 0
		UpdateCanvasSize(script.Parent.Parent, script.Parent.UIListLayout)
	end
end)
remoteEvent.OnClientEvent:Connect(function(isUtilityTab: boolean, p: string)
	safezone.shipwright.ships.main.safezone:SetAttribute("IsUtilityTab", isUtilityTab)
	local v4 = v and v2[v]

	if v4 and v4.onClose then
		v4.onClose()
	end

	local v5 = p and v2[p]

	if v5 and v5.onOpen then
		v5.onOpen()
		v = p
	end

	playerGui.backpack.Enabled = false
	safezone.shipwright.Visible = true
end)