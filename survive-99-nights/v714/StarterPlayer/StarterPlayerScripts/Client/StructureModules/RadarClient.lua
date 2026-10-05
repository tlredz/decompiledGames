local RadarClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService2 = game:GetService("RunService")
RunService = RunService2
local scanner = nil
local v = nil
local mouseButton1DownConnection = nil
local flag = true
local flag2 = false
local v2 = false

function DoErrorMessage(p, p2)
	if flag then
		Client.PopUpUI.AddPopUp(p2, "warning")
		flag = false
		task.spawn(function()
			for _ = 1, 3 do
				p.TextColor3 = Color3.fromRGB(255, 0, 0)
				wait(0.3)
				p.TextColor3 = Color3.fromRGB(255, 255, 255)
				wait(0.3)
			end

			p.TextColor3 = Color3.fromRGB(255, 0, 0)
		end)
		task.spawn(function()
			wait(2.1)
			p.TextColor3 = Color3.fromRGB(255, 255, 255)
			flag = true
		end)
	end
end

function AttemptScan(p)
	local totalScrap = workspace.Map.Campground:GetAttribute("TotalScrap") or 0

	if v and v == "Twitch" then
		if totalScrap < 10 then
			DoErrorMessage(scanner.IconHolderTwitch.Twitch.Frame.Materials.ScrapAmount, "not enough scrap")
		elseif (workspace.Map.Campground:GetAttribute("TotalWood") or 0) < 20 then
			DoErrorMessage(scanner.IconHolderTwitch.Twitch.Frame.Materials.WoodAmount, "not enough wood")
		elseif (workspace.Map.Campground:GetAttribute("TotalGems") or 0) < 1 then
			DoErrorMessage(scanner.IconHolderTwitch.Twitch.Frame.Materials.GemAmount, "not enough cultist gems")
		elseif flag2 then
			return
		end

		flag2 = true
		task.spawn(function()
			wait(6)

			if not v2 then
				flag2 = false
				UpdateScanOptions()
			end
		end)
	elseif totalScrap < 6 then
		DoErrorMessage(scanner.Amount.ScrapAmount, "not enough scrap")
		return
	end

	local v3 = v

	if v3 then
		Client.Events.RequestScanStructure:FireServer(v3, p)

		if flag2 then
			UpdateScanOptions()
		end
	end

	scanner.Visible = false
end

function FormatLandmarkName(value)
	local v3 = string.gsub(value, "(%u)", " %1")
	return (string.gsub(v3, "^ ", ""))
end

function SelectButton(p)
	local iconHolder = scanner.IconHolder
	v = p

	for _, child in pairs(iconHolder:GetChildren()) do
		if not (child.Name ~= "UIGridLayout" and child.Name ~= "Template") then
			continue
		end

		if child.Name == p then
			child.BackgroundTransparency = 0
			child.TextLabel.Text = FormatLandmarkName(p)
			child.TextLabel.Visible = true
		else
			child.BackgroundTransparency = 1

			if child.ImageLabel.Visible then
				child.TextLabel.Visible = false
			end
		end
	end
end

function UpdateScanOptions()
	local v3 = GetOptions()
	local v4 = GetCompleted()
	local iconHolder = scanner.IconHolder
	local guide = Client.Interface.MapHolder.Guide

	for _, child in pairs(iconHolder:GetChildren()) do
		if child.Name ~= "Template" and child.Name ~= "UIGridLayout" then
			child:Destroy()
		end
	end

	for _, child in pairs(guide:GetChildren()) do
		if child.Name ~= "Template" and child.Name ~= "UIListLayout" then
			child:Destroy()
		end
	end

	if v3 and not (#v3 <= 0) then
		scanner.IconHolderTwitch.Visible = false
		scanner.ScansCompleted.Visible = false
	elseif flag2 then
		scanner.ScansCompleted.Visible = true
		scanner.IconHolderTwitch.Visible = false
	end

	for k, name in pairs(v3) do
		local clone = iconHolder.Template:Clone()
		clone.Name = name
		local v7 = name == "UFOCrash" and "UFOCrash1" or name
		local v8 = name == "Cave Entrance" and "Cave Entrance1" or v7
		local v9 = name == "Jungle MiniTemple" and "Jungle MiniTemple1" or v8
		local icon = Client.MapDrawClient.GetIcon(v9)

		if icon then
			clone.ImageLabel.Image = icon
			clone.TextLabel.Visible = false
		else
			clone.ImageLabel.Visible = false
			clone.TextLabel.Text = FormatLandmarkName(name)
			clone.TextLabel.Visible = true
		end

		clone.Parent = iconHolder
		clone.Name = name
		clone.Visible = true
		clone.LayoutOrder = k
		local v10 = name
		clone.MouseButton1Down:Connect(function()
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})
			SelectButton(v10)
		end)
	end

	for k, name in pairs(v4) do
		local v7 = name == "UFOCrash" and "UFOCrash1" or name
		local v8 = name == "Cave Entrance" and "Cave Entrance1" or v7
		local v9 = name == "Jungle MiniTemple" and "Jungle MiniTemple1" or v8
		local icon = Client.MapDrawClient.GetIcon(v9)

		if not icon then
			continue
		end

		local clone = guide.Template:Clone()
		clone.TextLabel.Text = FormatLandmarkName(name)
		clone.ImageLabel.Image = icon
		clone.LayoutOrder = k
		clone.Name = name
		clone.Parent = guide
		clone.Visible = true
	end

	SelectButton(v3[1])
end

function GetOptions()
	local radar = game.ReplicatedStorage.Shops.Radar
	local result = {}

	for k, v3 in pairs(radar:GetAttributes()) do
		if v3 == false then
			table.insert(result, (string.gsub(k, "_", " ")))
		end
	end

	local scanOrder = radar:GetAttribute("ScanOrder")

	if not scanOrder then
		return result
	end

	local count = 0
	local v3 = {}

	for k in string.gmatch(scanOrder, "[^|]+") do
		count += 1
		v3[k] = count
	end

	table.sort(result, function(a, b)
		return (v3[a] or 1e999) < (v3[b] or 1e999)
	end)
	return result
end

function GetCompleted()
	local radar = game.ReplicatedStorage.Shops.Radar
	local result = {}

	for k, v3 in pairs(radar:GetAttributes()) do
		if v3 == true and string.sub(k, 1, 6) == "Found_" then
			table.insert(result, (string.gsub(string.sub(k, 7), "_", " ")))
		end
	end

	return result
end

function RadarClient.OpenRadarMenu(p)
	local v3 = GetOptions()
	print("scan options are", v3)
	scanner.Visible = true

	if mouseButton1DownConnection then
		mouseButton1DownConnection:Disconnect()
	end

	mouseButton1DownConnection = scanner.BuyButton.MouseButton1Down:Connect(function()
		Client.Sound.Play("CloseButton", {
			Duplicate = true
		})
		AttemptScan(p)
	end)
end

Client.Events.FoundTwitch:Connect(function()
	flag2 = true
	v2 = true
end)
Client.Events.RejectRadar:Connect(function(totalScrap)
	workspace.Map.Campground:SetAttribute("TotalScrap", totalScrap)
end)
Client.Events.ScanSuccess:Connect(function(p, p2)
	if p == localPlayer then
		if p2 then
			Client.PopUpUI.AddPopUp("a new room has appeared on the map...", "purple")
		end

		local visible = Client.Interface.MapHolder.Visible
		task.spawn(function()
			local visibleChangedConnection = Client.Interface.MapHolder:GetPropertyChangedSignal("Visible"):Connect(function()
				visible = true
			end)
			wait(2)

			if visibleChangedConnection then
				visibleChangedConnection:Disconnect()
			end

			if scanner and scanner.Visible == false and not visible then
				Client.MapDrawClient.OpenMap()
			end

			if not p2 then
				Client.PopUpUI.AddPopUp("scan successful")
			end
		end)
	end

	if workspace.Structures:FindFirstChild("Radar") then
		local radar = workspace.Structures:FindFirstChild("Radar")
		local block = radar.Spinny.Block

		for _, emitter in pairs(block:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 3)
			end
		end

		local v3 = true
		local spinny = radar.Spinny
		task.spawn(function()
			task.wait(5)
			v3 = false
		end)
		task.spawn(function()
			while v3 == true do
				local v4 = RunService.RenderStepped:Wait() * 180
				spinny:PivotTo(spinny.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(v4), 0))
			end
		end)
	end
end)

function RadarAdded(instance)
	if instance:IsDescendantOf(workspace) then
		Client.Interface.MapHolder.Guide.Visible = true
	end
end

function RadarClient.Init()
	task.spawn(function()
		scanner = Client.Interface.Scanner
		game.ReplicatedStorage:WaitForChild("Shops"):WaitForChild("Radar").AttributeChanged:Connect(UpdateScanOptions)
		UpdateScanOptions()
		local totalScrap = workspace.Map.Campground:GetAttribute("TotalScrap") or 0
		scanner.Amount.ScrapAmount.Text = totalScrap
		workspace.Map.Campground:GetAttributeChangedSignal("TotalScrap"):Connect(function()
			totalScrap = workspace.Map.Campground:GetAttribute("TotalScrap")
			scanner.Amount.ScrapAmount.Text = totalScrap
		end)
		scanner.CloseButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("CloseButton", {
				Duplicate = true
			})
			scanner.Visible = false
		end)
		Client.Utility.ForAllTagged("Radar", RadarAdded)
	end)
end

return RadarClient