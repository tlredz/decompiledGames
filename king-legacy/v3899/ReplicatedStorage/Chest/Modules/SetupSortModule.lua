local SetupSortModule = {}
local TweenService = game:GetService("TweenService")
game:GetService("UserInputService")
local currentCamera = workspace.CurrentCamera
local localPlayer = game.Players.LocalPlayer

function SetupSortModule.Init(p)
	local mainFrame = p.MainFrame
	local bin = p.Bin

	for _, guiObject in pairs(mainFrame:GetChildren()) do
		if guiObject:IsA("TextLabel") or guiObject:IsA("Frame") then
			guiObject:Destroy()
		end
	end

	for _, guiObject in pairs(bin:GetChildren()) do
		if guiObject:IsA("TextLabel") or guiObject:IsA("Frame") then
			guiObject:Destroy()
		end
	end

	local tweens = {}
	local guiObjects = {}
	local v = {}
	local v2 = {}
	local v3 = 1
	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Exponential)
	local tweenInfo2 = TweenInfo.new(0.35, Enum.EasingStyle.Sine)
	local bossesHealthBar = nil

	local function Update()
		if not bossesHealthBar then
			pcall(function()
				bossesHealthBar = localPlayer.PlayerGui.MainGui.StarterFrame.BossesHealthBar
			end)
		end

		for _, v4 in pairs(tweens) do
			v4:Pause()
		end

		tweens = {}
		local v4 = not (bossesHealthBar and bossesHealthBar.Frames.UIListLayout.AbsoluteContentSize.Y > 0) and 0 or bossesHealthBar.Frames.AbsolutePosition.Y + bossesHealthBar.Frames.UIListLayout.AbsoluteContentSize.Y
		local total = 0

		for k, v5 in pairs(guiObjects) do
			local tween = TweenService:Create(v5, tweenInfo, {
				Position = UDim2.new(0, 0, 0, v4 + (k - 1) * v5.AbsoluteSize.Y + 5)
			})
			tween:Play()
			total += v5.AbsoluteSize.Y
			table.insert(tweens, tween)
		end

		if mainFrame.Parent:FindFirstChild("AreaText") then
			TweenService:Create(mainFrame.Parent.AreaText, tweenInfo, {
				Position = UDim2.new(0.5, 0, 0, total)
			}):Play()
		end
	end

	local function RemoveFromSort(p2)
		for k, v4 in pairs(guiObjects) do
			if v4 ~= p2 then
				continue
			end

			table.remove(guiObjects, k)
			break
		end
	end

	mainFrame.ChildAdded:Connect(function(guiObject)
		if guiObject:IsA("TextLabel") or guiObject:IsA("Frame") and guiObject:GetAttribute("ImageDrop") then
			guiObject.Size = UDim2.new(1, 0, 0, 40)

			if currentCamera.ViewportSize.Y < 700 then
				guiObject.Size = UDim2.new(1, 0, 0, 20)
			end

			local debrisTime = guiObject:GetAttribute("DebrisTime") or 5
			guiObject.Position = UDim2.new(0, 0, 0, 0)
			guiObject:SetAttribute("DebrisTime", nil)
			guiObject:SetAttribute("RealDebrisTime", debrisTime)
			table.insert(guiObjects, guiObject)
			v[guiObject] = tick()
			v2[guiObject] = guiObject:GetAttributeChangedSignal("DebrisTime"):Connect(function()
				local debrisTime2 = guiObject:GetAttribute("DebrisTime")

				if debrisTime2 then
					guiObject:SetAttribute("RealDebrisTime", debrisTime2)
					guiObject:SetAttribute("DebrisTime", nil)
					v[guiObject] = tick()
				end
			end)
			local v4 = #guiObjects
			local tween = TweenService:Create(guiObject, tweenInfo2, {
				Position = UDim2.new(0, 0, 0, (v4 - 1) * guiObject.AbsoluteSize.Y + 5)
			})
			tween:Play()
			table.insert(tweens, tween)
		end
	end)
	task.spawn(function()
		while wait(tweenInfo.Time) do
			local v4 = {}

			for i = 1, #guiObjects do
				local v5 = guiObjects[i]

				if not (v[v5] and v5 and v5.Parent and tick() - v[v5] > (v5:GetAttribute("RealDebrisTime") or 1)) then
					continue
				end

				if not (#v4 < 6) then
					continue
				end

				v[v5] = nil

				if v2[v5] and v2[v5].Connected then
					v2[v5]:Disconnect()
					v2[v5] = nil
				end

				v5.Parent = bin
				local v6 = v3
				TweenService:Create(v5, tweenInfo2, {
					Position = UDim2.new(v6, 0, 0, v5.AbsolutePosition.Y)
				}):Play()
				_G.PU:Dust(v5, 0.5)
				v3 = -v3
				table.insert(v4, v5)
				wait()
			end

			for _, v5 in pairs(v4) do
				RemoveFromSort(v5)
			end

			Update()
		end
	end)
end

return SetupSortModule