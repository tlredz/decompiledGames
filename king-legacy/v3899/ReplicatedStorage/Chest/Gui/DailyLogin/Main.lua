local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local mainFrame = script.Parent:WaitForChild("MainFrame")
local TweenService = game:GetService("TweenService")
local PeoUtils = require(ReplicatedStorage.Chest.Modules:WaitForChild("PeoUtils"))
local localPlayer = game.Players.LocalPlayer
require(ReplicatedStorage.Chest.Modules.MaterialList)
mainFrame.Size = UDim2.new()
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
	Size = UDim2.new(0.83, 0, 0.52, 0)
}):Play()
local flag = nil
local connections = {}

function ClearConnection()
	for _, connection in pairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end

	connections = {}
end

function ClaimEvent()
	if flag then
		return
	end

	coroutine.wrap(function()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://6792280577",
			Volume = 0.4
		})
		_G.PU:Dust(sound, 5)
		sound.Parent = workspace.Effects
		sound:Play()
	end)()
	task.spawn(function()
		_G.ClickFrameEffect({
			Parent = mainFrame.Parent
		})
	end)

	if ReplicatedStorage.Chest.Remotes.Functions.Reward:InvokeServer() then
		flag = true
		Update(true)
		task.wait(0.75)
		TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		_G.PU:Dust(script.Parent, 1)
	end
end

function Update(p)
	ClearConnection()
	local v = ReplicatedStorage.Chest.Remotes.Functions.GetRewards:InvokeServer()

	if v then
		for _, button in pairs(mainFrame:GetDescendants()) do
			if button:IsA("TextButton") and button:GetAttribute("DayButton") then
				button:Destroy()
			end
		end

		local jSONDecode = HttpService:JSONDecode(localPlayer.PlayerStats.LoginRewards.Value)

		for i = 1, 7 do
			local list = mainFrame.List
			local v2, v3

			if i > 5 then
				list = mainFrame.ListBIG
				v2 = 0.49
				v3 = 1.025
			else
				v2 = 0.195
				v3 = 1.05
			end

			local clone = script.Folder.DayButton:Clone()

			if p then
				clone.Size = UDim2.new(v2, 0, 1, 0)
			else
				clone.Size = UDim2.new(0, 0, 0, 0)
				coroutine.wrap(function()
					local sound = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://9065073444",
						Volume = 0.5
					})
					_G.PU:Dust(sound, 1)
					sound.Parent = workspace.Effects
					sound:Play()
				end)()
			end

			clone.LayoutOrder = i
			clone.Frame.Day.Text = "Day" .. i
			clone.Visible = true

			if not p then
				TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					Size = UDim2.new(v2, 0, 1, 0)
				}):Play()
			end

			if v["Day" .. i].Thing == "Gem" then
				local amt = v["Day" .. i].Amt
				clone.Frame.Frame.ImageLabel.Image = "rbxassetid://88515569255432"

				if amt >= 5 and amt < 10 then
					clone.Frame.Frame.ImageLabel.Image = "rbxassetid://86210177389251"
				elseif amt >= 10 and amt < 15 then
					clone.Frame.Frame.ImageLabel.Image = "rbxassetid://75913161559538"
				elseif amt >= 15 and amt < 30 then
					clone.Frame.Frame.ImageLabel.Image = "rbxassetid://106547378840571"
				elseif amt >= 30 then
					clone.Frame.Frame.ImageLabel.Image = "rbxassetid://112630312321366"
				end

				clone.Frame.Frame.TextLabel.Text = v["Day" .. i].Thing .. " x" .. amt
			end

			if v["Day" .. i].Thing == "Material" then
				local item = v["Day" .. i].Item
				clone.Frame.Frame.ImageLabel.Image = item == "Common" and "http://www.roblox.com/asset/?id=11961524728" or item == "Uncommon" and "http://www.roblox.com/asset/?id=11961523908" or item == "Rare" and "http://www.roblox.com/asset/?id=11961523484" or item == "Epic" and "http://www.roblox.com/asset/?id=11961521994" or item == "Legendary" and "http://www.roblox.com/asset/?id=11961520465" or false
				clone.Frame.Frame.TextLabel.Text = v["Day" .. i].Item .. " Material"
			end

			if v["Day" .. i].Thing == "Fruit" then
				local item = v["Day" .. i].Item
				clone.Frame.Frame.ImageLabel.Image = item == "Common" and "rbxassetid://8704131464" or item == "Uncommon" and "rbxassetid://9170466907" or item == "Rare" and "rbxassetid://9170467299" or item == "Epic" and "rbxassetid://9170467728" or item == "Legendary" and "rbxassetid://9170468009" or false
				clone.Frame.Frame.TextLabel.Text = v["Day" .. i].Item .. " Fruit"
			end

			clone.Parent = list

			if i <= jSONDecode.CurrentDay then
				clone.Frame.CheckMark.ImageTransparency = 1
				clone.Frame.CheckMark.Size = UDim2.new(2.5, 0, 2.5, 0)
				clone.Frame.CheckMark.BackgroundTransparency = 1
				clone.Frame.CheckMark.Visible = true
				TweenService:Create(clone.Frame.CheckMark, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
					ImageTransparency = 0,
					BackgroundTransparency = 0.25,
					Size = UDim2.new(1, 0, 1, 0)
				}):Play()
			end

			table.insert(connections, clone.MouseButton1Click:Connect(function()
				ClaimEvent()
			end))
			table.insert(connections, clone.MouseEnter:Connect(function()
				clone.Frame.UIStroke.Enabled = true
				clone.Size = UDim2.new(v2, 0, 1, 0)
				TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
					Size = UDim2.new(v2 * v3, 0, v3 * 1, 0)
				}):Play()
			end))
			local v5 = clone
			table.insert(connections, clone.MouseLeave:Connect(function()
				v5.Frame.UIStroke.Enabled = nil
				TweenService:Create(v5, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
					Size = UDim2.new(v2, 0, 1, 0)
				}):Play()
			end))

			if not p then
				task.wait(0.25)
			end
		end
	end
end

Update()
task.spawn(function()
	local lastTime = tick()

	while not (tick() - lastTime > 60) do
		while mainFrame.Visible do
			local v = task.wait() * 60

			for _, uIGradient in pairs(mainFrame:GetDescendants()) do
				if uIGradient:IsA("UIGradient") then
					uIGradient.Rotation = (uIGradient.Rotation + v * 1) % 360
				end
			end
		end

		task.wait()
		mainFrame:GetPropertyChangedSignal("Visible"):Wait()
	end
end)