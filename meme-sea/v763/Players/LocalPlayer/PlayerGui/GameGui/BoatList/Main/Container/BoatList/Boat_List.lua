local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local boatFolder = workspace:WaitForChild("BoatFolder")
local otherEvent = ReplicatedStorage:WaitForChild("OtherEvent")
local moduleScript = ReplicatedStorage:WaitForChild("ModuleScript")
local modules = ReplicatedStorage:WaitForChild("Modules")
local guiTemplate = ReplicatedStorage:WaitForChild("GuiTemplate")
ReplicatedStorage:WaitForChild("Sound_Effect")
local boat = ReplicatedStorage:WaitForChild("Boat")
local sound_Effect = ReplicatedStorage:WaitForChild("Sound_Effect")
local boatAssets = guiTemplate:WaitForChild("BoatAssets")
local buyEvents = otherEvent:WaitForChild("BuyEvents")
local guiEvents = otherEvent:WaitForChild("GuiEvents")
local mainEvents = otherEvent:WaitForChild("MainEvents")
local SetText = require(moduleScript:WaitForChild("SetText"))
require(moduleScript:WaitForChild("Translate"))
local Abbreviate = require(moduleScript:WaitForChild("Abbreviate"))
local Setting = require(moduleScript:WaitForChild("Setting"))
local setting = Setting.Setting
local Gamepass_Assets = require(moduleScript:WaitForChild("Gamepass_Assets"))
local FadeModule = require(modules:WaitForChild("FadeModule"))
localPlayer:WaitForChild("PlayerData", 60)
localPlayer:WaitForChild("PlayerSettings", 60)
local playerSpecial = localPlayer:WaitForChild("PlayerSpecial", 60)
localPlayer:WaitForChild("PlayerGui", 60)
local guiEvent = guiEvents:WaitForChild("GuiEvent")
local modules2 = mainEvents:WaitForChild("Modules")
local buyProduct = buyEvents:WaitForChild("BuyProduct")
local parent = script.Parent
local frame = parent.Frame
local parent2 = parent.Parent.Parent.Parent
local container = frame.Container
local topFrame = frame.TopFrame
local buyFrame = parent.Parent.Parent.BuyFrame
local despawnFrame = parent.Parent.Parent.DespawnFrame
local despawn = topFrame.Despawn
local boatSearch = topFrame.BoatSearch
local search = boatSearch.Search
local boat_Template = boatAssets:WaitForChild("Boat_Template")
local boatSettings = setting.BoatSettings
local gamepasses_Cost = setting.Gamepasses_Cost
local gamepass_RobuxCosts = setting.Gamepass_RobuxCosts
local connections = {}

local function OpeningThisFrame()
	return parent2.Visible == true and parent2.Position == UDim2.new(0.5, 0, 0.5, 0)
end

local function TextColor(p, p2)
	if p and p2 then
		return (`<font color="rgb({p2})">{p}</font>`)
	end
end

local function RemoveSpace(value)
	return value:gsub(" ", "")
end

local function Setup_Hover(button)
	button.MouseEnter:Connect(function()
		if button.HoverText.TextTransparency ~= 0 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if button.HoverText.TextTransparency ~= 1 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1
			}):Play()
		end
	end)
	button.MouseButton1Up:Connect(function()
		if button.HoverText.TextTransparency ~= 1 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 1
			}):Play()
		end
	end)
	button.MouseButton1Down:Connect(function()
		if button.HoverText.TextTransparency ~= 0 then
			TweenService:Create(button.HoverText, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = 0
			}):Play()
		end
	end)
end

local function Active_BuyFrame(p, p2)
	if p == true and buyFrame.Visible == false and p2 then
		if buyFrame:GetAttribute("Type") == "Robux" then
			if localPlayer:GetAttribute("TH") then
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} โรบัค`
				local v2

				if formatted then
					v2 = `<font color="rgb(75,230,75)">{formatted}</font>`
				end

				title.Text = `คุณต้องการซื้อเรือลำนี้ในราคา {v2} หรือไม่?`
			else
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} Robux?`
				local v2

				if formatted then
					v2 = `<font color="rgb(75,230,75)">{formatted}</font>`
				end

				title.Text = `Would you like to purchase this boat for {v2}`
			end
		elseif buyFrame:GetAttribute("Type") == "Gem" then
			if localPlayer:GetAttribute("TH") then
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} เพชร`
				local v2

				if formatted then
					v2 = `<font color="rgb(175,125,255)">{formatted}</font>`
				end

				title.Text = `คุณต้องการซื้อเรือลำนี้ในราคา {v2} หรือไม่?`
			else
				local title = buyFrame.Frame.Title
				local formatted = `{Abbreviate.Comma(buyFrame:GetAttribute("Price"))} Gem?`
				local v2

				if formatted then
					v2 = `<font color="rgb(175,125,255)">{formatted}</font>`
				end

				title.Text = `Would you like to purchase this boat for {v2}`
			end
		end

		buyFrame.Visible = true
		FadeModule.FadeIn(buyFrame, 0.25)
	elseif p == false and buyFrame.Visible == true then
		FadeModule.FadeOut(buyFrame, 0.25)
		task.wait(0.25)
		buyFrame.Visible = false
	end
end

local function Active_DespawnFrame(p)
	if p == true and despawnFrame.Visible == false then
		despawnFrame.Visible = true
		FadeModule.FadeIn(despawnFrame, 0.25)
	elseif p == false and despawnFrame.Visible == true then
		FadeModule.FadeOut(despawnFrame, 0.25)
		task.wait(0.25)
		despawnFrame.Visible = false
	end
end

local function GenerateBoat()
	search.Text = ""

	for _, frame2 in ipairs(container:GetChildren()) do
		if frame2:IsA("Frame") then
			frame2:Destroy()
		end
	end

	for _, connection in ipairs(connections) do
		if connection then
			connection:Disconnect()
		end
	end

	table.clear(connections)

	for _, gamepass_Asset in ipairs(Gamepass_Assets) do
		local gamepassId = gamepass_Asset.GamepassId
		local boatSetting = boatSettings[gamepass_Asset.Asset_Name]

		if not (boatSetting and boatSetting.Image) then
			continue
		end

		local clone = boat_Template:Clone()
		clone.Name = gamepass_Asset.Asset_Name
		clone.Icon.Image = boatSetting.Image
		clone.Title.Text = `{clone.Name}`
		clone.Price.Text = `[${Abbreviate.Comma(boatSetting.Cost)}]`
		clone:SetAttribute("RobuxPrice", gamepass_RobuxCosts[clone.Name])
		clone:SetAttribute("GemPrice", gamepasses_Cost[clone.Name])
		clone.Buy_Robux.Robux.Price_Frame.Textlabel.Text = ` {clone:GetAttribute("RobuxPrice")}`
		clone.Buy_Gem.Gem.Price_Frame.Textlabel.Text = `{Abbreviate.Comma(clone:GetAttribute("GemPrice"))}`

		if playerSpecial:FindFirstChild(clone.Name) and playerSpecial:FindFirstChild(clone.Name).Value == true then
			local v = clone
			connections[#connections + 1] = clone.SpawnFrame.Spawn.Activated:Connect(function()
				local child = playerSpecial:FindFirstChild(v.Name)

				if child and child.Value == true then
					guiEvent:Fire({
						MenuName = "BoatList",
						Action = "Close"
					})
					modules2:FireServer("Spawn_Boat", {
						Boat_Name = v.Name
					})
				end
			end)
		else
			clone.SpawnFrame.Visible = false
			clone.Price.Visible = false
			clone.Locked.Visible = true
			clone.Buy_Gem.Visible = true
			clone.Buy_Robux.Visible = true
			local gamepassId2 = gamepassId
			local v2 = clone
			connections[#connections + 1] = clone.Buy_Robux.Robux.Activated:Connect(function()
				if buyFrame.Visible == false then
					buyFrame:SetAttribute("GamepassId", gamepassId2)
					buyFrame:SetAttribute("Type", "Robux")
					buyFrame:SetAttribute("Price", v2:GetAttribute("RobuxPrice"))
					Active_BuyFrame(true, v2)
				end
			end)
			local gamepassId3 = gamepassId
			local v4 = clone
			connections[#connections + 1] = clone.Buy_Gem.Gem.Activated:Connect(function()
				if buyFrame.Visible == false then
					buyFrame:SetAttribute("GamepassId", gamepassId3)
					buyFrame:SetAttribute("Type", "Gem")
					buyFrame:SetAttribute("Price", v4:GetAttribute("GemPrice"))
					Active_BuyFrame(true, v4)
				end
			end)
		end

		clone.Visible = true
		clone.Parent = container
	end
end

local function Despawn_Boat()
	if boatFolder:FindFirstChild((`{localPlayer.Name}'s Boat`)) then
		modules2:FireServer("Despawn_Boat")
		sound_Effect.Success2:Play()
		guiEvent:Fire({
			MenuName = "BoatList",
			Action = "Close"
		})
	else
		sound_Effect.Error:Play()

		if localPlayer:GetAttribute("TH") then
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "ตอนนี้ยังไม่มีเรือที่คุณได้เสกไว้!",
				MessageColor = "Red"
			})
		else
			SetText.SetText(localPlayer, "CustomMessage", {
				Message = "You don't have a spawned boat!",
				MessageColor = "Red"
			})
		end
	end

	if despawnFrame.Visible == true then
		FadeModule.FadeOut(despawnFrame, 0.25)
		task.wait(0.25)
		despawnFrame.Visible = false
	end
end

local function BoatSearching()
	local text = string.lower(search.Text)

	for _, frame2 in ipairs(container:GetChildren()) do
		if not frame2:IsA("Frame") then
			continue
		end

		if text == "" or string.find(string.lower(frame2.Name), text) then
			frame2.Visible = true
		else
			frame2.Visible = false
		end
	end
end

function Purchase_Product()
	if buyFrame:GetAttribute("Type") == "Robux" then
		MarketplaceService:PromptGamePassPurchase(localPlayer, buyFrame:GetAttribute("GamepassId"))
	else
		buyProduct:FireServer({
			Action = "Buy_Gamepass",
			GamepassId = buyFrame:GetAttribute("GamepassId")
		})
	end

	if buyFrame.Visible == true then
		FadeModule.FadeOut(buyFrame, 0.25)
		task.wait(0.25)
		buyFrame.Visible = false
	end
end

for _, child in ipairs(playerSpecial:GetChildren()) do
	if boat:FindFirstChild(child.Name) then
		child:GetPropertyChangedSignal("Value"):Connect(GenerateBoat)
	end
end

for _, button in ipairs(topFrame:GetChildren()) do
	if button:IsA("GuiButton") then
		Setup_Hover(button)
	end
end

buyFrame.Frame.BuyFrame.Button.Activated:Connect(Purchase_Product)
buyFrame.Frame.CloseFrame.Button.Activated:Connect(function()
	if buyFrame.Visible == true then
		FadeModule.FadeOut(buyFrame, 0.25)
		task.wait(0.25)
		buyFrame.Visible = false
	end
end)
despawn.Activated:Connect(function()
	if despawnFrame.Visible ~= false then
		return
	end

	despawnFrame.Visible = true
	FadeModule.FadeIn(despawnFrame, 0.25)
end)
despawnFrame.Frame.YesFrame.Button.Activated:Connect(Despawn_Boat)
despawnFrame.Frame.CloseFrame.Button.Activated:Connect(function()
	if despawnFrame.Visible == true then
		FadeModule.FadeOut(despawnFrame, 0.25)
		task.wait(0.25)
		despawnFrame.Visible = false
	end
end)
search:GetPropertyChangedSignal("Text"):Connect(BoatSearching)
search.Focused:Connect(function()
	if boatSearch.UIStroke.Color ~= Color3.fromRGB(73, 76, 83) then
		TweenService:Create(boatSearch.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(73, 76, 83)
		}):Play()
	end
end)
search.FocusLost:Connect(function()
	if boatSearch.UIStroke.Color ~= Color3.fromRGB(57, 59, 65) then
		TweenService:Create(boatSearch.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(57, 59, 65)
		}):Play()
	end
end)
guiEvent.Event:Connect(function(p)
	local menuName = p.MenuName
	local action = p.Action

	if menuName == "Refresh_BoatList" and action == "Open" then
		GenerateBoat()

		if buyFrame.Visible == true then
			FadeModule.FadeOut(buyFrame, 0.25)
			task.wait(0.25)
			buyFrame.Visible = false
		end

		if despawnFrame.Visible == true then
			FadeModule.FadeOut(despawnFrame, 0.25)
			task.wait(0.25)
			despawnFrame.Visible = false
		end
	end
end)