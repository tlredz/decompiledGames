local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local localPlayer = Players.LocalPlayer
local loadingScreen = script:WaitForChild("LoadingScreen")
local load = loadingScreen:WaitForChild("Load")
local skipLoad = load:WaitForChild("SkipLoad")
local loading = load:WaitForChild("Loading")
local maxLoad = load:WaitForChild("MaxLoad")
local currentLoad = maxLoad:WaitForChild("CurrentLoad")
local maxLoadBG = load:WaitForChild("MaxLoadBG")
local label = load:FindFirstChild("Label")
load.Position = UDim2.new(0.5, 0, 0.5, 0)
script.Parent:RemoveDefaultLoadingScreen()
loadingScreen.Parent = localPlayer:WaitForChild("PlayerGui")
local flag = true
local v = false
local v2 = false
task.spawn(function()
	while flag do
		if loading.Text == "LOADING..." then
			loading.Text = "LOADING."
		elseif loading.Text == "LOADING." then
			loading.Text = "LOADING.."
		elseif loading.Text == "LOADING.." then
			loading.Text = "LOADING..."
		end

		task.wait(0.75)
	end
end)
skipLoad.Activated:Connect(function()
	if not v then
		v = true
		flag = false

		if localPlayer:FindFirstChild("SkippedLoading") then
			localPlayer.SkippedLoading.Value = true
		end

		local success, result = pcall(function()
			load:TweenPosition(UDim2.new(0.5, 0, -1, 0), "Out", "Sine", 1, true)
		end)

		if not success then
			warn("TweenPosition failed on loadObject:", result)
		end

		task.wait(1)
		loadingScreen:Destroy()
	end
end)

if label and label:IsA("GuiObject") then
	local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0)
	local _, _ = pcall(function()
		TweenService:Create(label, tweenInfo, {
			Size = UDim2.new(0.366, 0, 0.257, 0)
		}):Play()
	end)
end

local descendants = game:GetDescendants()
local count = #descendants

local function closeLoadingScreen()
	if loadingScreen.Parent then
		task.wait(2)
		local _, _ = pcall(function()
			load:TweenPosition(UDim2.new(0.5, 0, -1, 0), "Out", "Sine", 1, true)
		end)
		task.wait(1)
		loadingScreen:Destroy()
	end
end

task.spawn(function()
	local function waitForGameAndPlayerData()
		while not (game:IsLoaded() and game.ReplicatedStorage:FindFirstChild("PlayerData") and game.ReplicatedStorage.PlayerData:FindFirstChild((tostring(localPlayer.UserId)))) do
			task.wait(0.5)
		end
	end

	local flag2 = false
	local flag3 = false
	task.spawn(function()
		waitForGameAndPlayerData()
		flag3 = true

		if flag2 then
			v2 = true
			closeLoadingScreen()
		end
	end)

	for i, descendant in ipairs(descendants) do
		if not loadingScreen.Parent then
			break
		end

		local v3 = descendant
		local success, result = pcall(function()
			ContentProvider:PreloadAsync({ v3 })
		end)

		if not success then
			warn("Failed to preload asset:", descendant:GetFullName(), result)
		end

		local v5 = i / count
		local _, _ = pcall(function()
			currentLoad:TweenSize(UDim2.new(v5, 0, 1, 0), "Out", "Sine", 0.75, true)
		end)

		if i % 5 == 0 then
			task.wait()
		end

		if i ~= count then
			continue
		end

		flag2 = true
		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local v6 = { TweenService:Create(maxLoad, tweenInfo, {
				BackgroundTransparency = 1
			}), TweenService:Create(currentLoad, tweenInfo, {
				ImageTransparency = 1
			}), TweenService:Create(maxLoadBG, tweenInfo, {
				BackgroundTransparency = 1
			}) }

		for _, v7 in ipairs(v6) do
			local v8 = v7
			local success2, _ = pcall(function()
				v8:Play()
			end)

			if success2 then
			end
		end

		if flag3 then
			v2 = true
			closeLoadingScreen()
		else
			v6[#v6].Completed:Connect(function()
				if flag3 then
					v2 = true
					closeLoadingScreen()
				end
			end)
		end
	end
end)
task.spawn(function()
	task.wait(30)

	if loadingScreen.Parent and not v2 then
		flag = false
		task.wait(2)
		local _, _ = pcall(function()
			load:TweenPosition(UDim2.new(0.5, 0, -1, 0), "Out", "Sine", 1, true)
		end)
		task.wait(1)
		loadingScreen:Destroy()
	end
end)