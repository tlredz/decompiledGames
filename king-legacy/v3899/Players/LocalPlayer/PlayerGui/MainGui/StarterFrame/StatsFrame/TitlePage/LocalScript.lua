local parent = script.Parent
local scrollingFrame = parent:WaitForChild("ScrollingFrame")
local colorsScrollingFrame = parent:WaitForChild("ColorsScrollingFrame")
local uIGridLayout = colorsScrollingFrame:WaitForChild("UIGridLayout")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character

if not character then
	character = localPlayer.CharacterAdded:Wait()
end

repeat
	wait()
until localPlayer:FindFirstChild("DataLoaded")

local playerStats = localPlayer:WaitForChild("PlayerStats")
local titleStore = playerStats:WaitForChild("TitleStore")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TitleModule = require(ReplicatedStorage.Chest.Modules.TitleModule)
local TitleColorModule = require(ReplicatedStorage.Chest.Modules.TitleModule.TitleColorModule)
local clones = {}

repeat
	wait()
until character.PrimaryPart

function UpdateScrolling()
	uIGridLayout.CellSize = UDim2.new(
		0,
		(colorsScrollingFrame.AbsoluteSize.X - colorsScrollingFrame.ScrollBarThickness) * 1,
		0,
		(colorsScrollingFrame.AbsoluteSize.Y - colorsScrollingFrame.ScrollBarThickness) * 0.2857142857142857
	)
	colorsScrollingFrame.CanvasSize = UDim2.new(
		0,
		uIGridLayout.AbsoluteContentSize.X,
		0,
		uIGridLayout.AbsoluteContentSize.Y
	)
end

parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateScrolling()
end)

function UpdateTitleColorFrames()
	for k, _ in pairs(TitleColorModule) do
		local clone = script.TitleFrame:Clone()
		clone.Name = k
		clone.Equip.Visible = false
		clone.TitleName.Text = k
		local v = TitleColorModule[k]

		if v then
			local obtain = v.Obtain or 0
			local lore = v.Lore
			clone.TitleName.TextColor3 = v.Color
			clone.LayoutOrder = obtain
			clone.TitleInfo.Text = lore
		end

		local colorName = k
		clone.Equip.MouseButton1Click:Connect(function()
			if ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("EquipTitleColor", {
				ColorName = colorName
			}) then
				_G.ClickFrameEffect({
					Sound = true,
					Sound2 = true
				})
				clone.Equip.Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
				TweenService:Create(
					clone.Equip,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = UDim2.new(0.44999999999999996, 0, 0.6000000000000001, 0)
					}
				):Play()
				Update()
			end
		end)
		local v4 = clone
		clone.Equip.MouseEnter:Connect(function()
			v4.Equip.Size = UDim2.new(0.3, 0, 0.4, 0)
			TweenService:Create(v4.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
			}):Play()
		end)
		local v5 = clone
		clone.Equip.MouseLeave:Connect(function()
			TweenService:Create(v5.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.3, 0, 0.4, 0)
			}):Play()
		end)
		clone.Parent = parent.ColorsScrollingFrame
	end
end

function GetPlayerTitleNumThatUnlockedNoSpecial(p)
	local jSONDecode = HttpService:JSONDecode(p.PlayerStats.TitleStore.Value)
	local count = 0

	for _, _ in pairs(jSONDecode) do
		count += 1
	end

	return count
end

function LoadTitleFrames()
	local v = GetPlayerTitleNumThatUnlockedNoSpecial(localPlayer) or "?"
	local count = 0

	for k, v2 in pairs(TitleModule) do
		if not v2.Special then
			count += 1
		end

		local clone = script.TitleFrame:Clone()
		clone.Name = k
		clone.TitleName.Text = k
		clone.Equip.Visible = false
		clone.LayoutOrder = 2

		if v2.Special then
			clone.Visible = false
		end

		local v3 = TitleModule[k]

		if v3 then
			local lore = v3.Lore

			if v3.Number then
				clone.TitleName.Text = " #" .. string.format("%03d", v3.Number) .. " " .. clone.TitleName.Text
				clone.LayoutOrder = v3.Number
			end

			if playerStats.Language.Value == "TH" then
				lore = v3.LoreTH
			end

			clone.TitleInfo.Text = lore
		end

		local v4 = k
		clone.Equip.MouseButton1Click:Connect(function()
			if ReplicatedStorage.Chest.Remotes.Functions.EquipTitle:InvokeServer(v4) then
				_G.ClickFrameEffect({
					Sound = true,
					Sound2 = true
				})
				clone.Equip.Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
				TweenService:Create(
					clone.Equip,
					TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
					{
						Size = UDim2.new(0.44999999999999996, 0, 0.6000000000000001, 0)
					}
				):Play()
				Update()
			end
		end)
		local v6 = clone
		clone.Equip.MouseEnter:Connect(function()
			v6.Equip.Size = UDim2.new(0.3, 0, 0.4, 0)
			TweenService:Create(v6.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.345, 0, 0.45999999999999996, 0)
			}):Play()
		end)
		local v7 = clone
		clone.Equip.MouseLeave:Connect(function()
			TweenService:Create(v7.Equip, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
				Size = UDim2.new(0.3, 0, 0.4, 0)
			}):Play()
		end)
		clone.Parent = scrollingFrame
		table.insert(clones, clone)
	end

	parent.TotalFrame.TextLabel.Text = v .. "/" .. count
	table.sort(clones, function(a, b)
		return a.LayoutOrder < b.LayoutOrder
	end)
end

local flag = nil
local flag2 = nil
parent.TitlesButton.MouseButton1Click:Connect(function()
	if flag then
		return
	end

	flag = true
	_G.ClickFrameEffect({
		Sound = true
	})
	parent.TitlesButton.Size = UDim2.new(0.2875, 0, 0.11499999999999999, 0)
	TweenService:Create(
		parent.TitlesButton,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(0.375, 0, 0.15000000000000002, 0)
		}
	):Play()
	parent.ScrollingFrame.Visible = true
	parent.ColorsScrollingFrame.Visible = false
	task.delay(0.1, function()
		flag = nil
	end)
end)
parent.TitlesButton.MouseEnter:Connect(function()
	parent.TitlesButton.Size = UDim2.new(0.25, 0, 0.1, 0)
	TweenService:Create(parent.TitlesButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.2875, 0, 0.11499999999999999, 0)
	}):Play()
end)
parent.TitlesButton.MouseLeave:Connect(function()
	TweenService:Create(parent.TitlesButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.25, 0, 0.1, 0)
	}):Play()
end)
parent.ColorsButton.MouseButton1Click:Connect(function()
	if flag2 then
		return
	end

	flag2 = true
	_G.ClickFrameEffect({
		Sound = true
	})
	parent.ColorsButton.Size = UDim2.new(0.2875, 0, 0.11499999999999999, 0)
	TweenService:Create(
		parent.ColorsButton,
		TweenInfo.new(0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut, 0, true, 0),
		{
			Size = UDim2.new(0.375, 0, 0.15000000000000002, 0)
		}
	):Play()
	parent.ScrollingFrame.Visible = false
	parent.ColorsScrollingFrame.Visible = true
	task.delay(0.1, function()
		flag2 = nil
	end)
end)
parent.ColorsButton.MouseEnter:Connect(function()
	parent.ColorsButton.Size = UDim2.new(0.25, 0, 0.1, 0)
	TweenService:Create(parent.ColorsButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.2875, 0, 0.11499999999999999, 0)
	}):Play()
end)
parent.ColorsButton.MouseLeave:Connect(function()
	TweenService:Create(parent.ColorsButton, TweenInfo.new(0.15, Enum.EasingStyle.Quart), {
		Size = UDim2.new(0.25, 0, 0.1, 0)
	}):Play()
end)

function Update()
	local HttpService2 = game:GetService("HttpService")
	local jSONDecode = HttpService2:JSONDecode(titleStore.Value)

	for _, image in pairs(scrollingFrame:GetChildren()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		local v = TitleModule[image.Name]

		if not v then
			continue
		end

		if jSONDecode[image.Name] then
			image.Visible = true
			image.Equip.Visible = true
			image.Equip.Text = "Equip"
			image.TitleName.Text = image.Name
			local lore = v.Lore

			if v.Number then
				image.TitleName.Text = " #" .. string.format("%03d", v.Number) .. " " .. image.TitleName.Text
				image.LayoutOrder = v.Number
			end

			if playerStats.Language.Value == "TH" then
				lore = v.LoreTH
			end

			image.TitleInfo.Text = lore

			if playerStats.Title.Value == image.Name then
				image.Equip.Text = "Equipped"
			end
		else
			local v2 = not v and 0 or v.Number or 0
			local lore = v.Lore

			if v.Number then
				image.LayoutOrder = v.Number
			end

			if playerStats.Language.Value == "TH" then
				lore = v.LoreTH
			end

			image.TitleInfo.Text = lore
			image.TitleName.Text = "#" .. string.format("%03d", v2) .. " - (LOCKED)"
			image.Equip.Visible = false
		end
	end

	UpdateColor()
	UpdateTitleFrames()
end

function UpdateColor()
	local v = ReplicatedStorage.Chest.Remotes.Functions.EtcFunction:InvokeServer("GetTitleColors")

	if not v then
		return
	end

	for _, image in pairs(parent.ColorsScrollingFrame:GetChildren()) do
		if not image:IsA("ImageLabel") then
			continue
		end

		local v2 = TitleColorModule[image.Name]

		if not v2 then
			continue
		end

		if (v2.Obtain or 0) <= v then
			image.Equip.Visible = true
			image.Equip.Text = "Equip"

			if playerStats.TitleColor.Value == image.Name then
				image.Equip.Text = "Equipped"
			end
		else
			image.Equip.Visible = false
		end
	end
end

function UpdateViewing()
	local Y = scrollingFrame.CanvasPosition.Y
	local Y2 = scrollingFrame.AbsoluteSize.Y

	for _, v in ipairs(clones) do
		if v:GetAttribute("Hiding") then
			v.Visible = nil
		else
			local offset = v.Position.Y.Offset
			v.Visible = Y <= offset + v.AbsoluteSize.Y and offset <= Y + Y2
		end
	end
end

function UpdateTitleFrames()
	local v = (scrollingFrame.AbsoluteSize.X - scrollingFrame.ScrollBarThickness) / 1
	local v2 = scrollingFrame.AbsoluteSize.Y / 3.5
	local jSONDecode = HttpService:JSONDecode(titleStore.Value)
	local v3 = 1

	for _, v4 in ipairs(clones) do
		local v5 = TitleModule[v4.Name]

		if v5 and v5.Special and not jSONDecode[v4.Name] then
			v4:SetAttribute("Hiding", true)
		else
			if v4:GetAttribute("Hiding") then
				v4:SetAttribute("Hiding", nil)
			end

			v4.Size = UDim2.fromOffset(v, v2)
			v4.Position = UDim2.fromOffset(0, (v3 - 1) * v2)
			v3 += 1
		end
	end

	scrollingFrame.CanvasSize = UDim2.fromOffset(0, (v3 - 1) * v2)
	UpdateViewing()
end

scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	UpdateTitleFrames()
end)
local lastTime = os.clock()
local flag3 = nil

function BeginScrolling()
	lastTime = os.clock()

	if flag3 then
		return
	end

	flag3 = true

	while true do
		task.wait(0.03333333333333333)

		if os.clock() - lastTime > 0.1 then
			break
		end

		UpdateViewing()
	end

	flag3 = nil
	UpdateViewing()
end

scrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(BeginScrolling)
titleStore.Changed:Connect(Update)
task.delay(5, function()
	UpdateTitleColorFrames()
	LoadTitleFrames()
	UpdateScrolling()
	Update()
end)
playerStats:WaitForChild("Title").Changed:Connect(Update)