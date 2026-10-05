local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BitohiUI = require(ReplicatedStorage:WaitForChild("BitohiUI"))
local UIController = require(ReplicatedStorage:WaitForChild("UIController"))
local enthusiasticArrive = BitohiUI.EnthusiasticArrive
local UIIdle = require(ReplicatedStorage:WaitForChild("UIIdle"))
local parent = script.Parent
local v = {
	Header = {
		S = 0.45,
		R = 18,
		Y = -0.14,
		Tune = "Card",
		PoseTune = { 0.5, 3.6 }
	},
	Close = {
		S = 0,
		R = -220,
		Tune = "Card",
		PoseTune = { 0.55, 4.2 }
	}
}
local v2 = {
	Header = 0.07,
	Close = 0.16
}
local v3 = {
	Step = 0.01,
	MaxTotal = 0.04,
	ScaleTo = 0.4,
	Spin = 8,
	Pull = 0.15,
	Wind = 0.03,
	OutTuning = { 1, 11 }
}
local v4 = {
	Header = v.Header,
	Close = v.Close
}

local function wire(child)
	local v5 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cancel()
		for i = #v5, 1, -1 do
			v5[i]:Cancel()
			v5[i] = nil
		end
	end

	local function isPart(instance)
		for childName in pairs(v4) do
			local child2 = child:FindFirstChild(childName)

			if child2 and (instance == child2 or instance:IsDescendantOf(child2)) then
				return true
			end
		end

		return false
	end

	local count = 0
	local v6 = {}

	for childName in pairs(v4) do
		local guiObject = child:FindFirstChild(childName)

		if guiObject and guiObject:IsA("GuiObject") then
			enthusiasticArrive.mark(guiObject)
		end
	end

	UIController.decorate(child, {
		Skip = isPart,
		CloseLead = 0.08,
		Open = function(p)
			cancel() -- equivalent call inferred; original call site unknown
			UIIdle.stop(child, not p)
			count += 1
			local v7 = count
			task.delay(0.6, function()
				if v7 == count and child.Visible then
					UIIdle.start(child)
				end
			end)

			if p then
				table.clear(v6)
				local v8 = {}

				for childName, pose in pairs(v4) do
					local guiObject = child:FindFirstChild(childName)

					if not (guiObject and guiObject:IsA("GuiObject") and guiObject.Visible) then
						continue
					end

					v6[guiObject] = pose
					table.insert(v8, {
						Obj = guiObject,
						Pose = pose,
						At = v2[childName]
					})
				end

				if #v8 > 0 then
					table.insert(v5, enthusiasticArrive.timeline(v8))
				end
			else
				for k, v8 in pairs(v6) do
					if k.Parent then
						enthusiasticArrive.play(k, v8, {
							Reset = false
						})
					end
				end
			end
		end,
		Close = function()
			cancel() -- equivalent call inferred; original call site unknown
			count += 1
			UIIdle.stop(child, true)
			local v7 = {}

			for k in pairs(v6) do
				if k.Parent and k.Visible then
					table.insert(v7, k)
				end
			end

			if #v7 > 0 then
				table.insert(v5, enthusiasticArrive.out(v7, v3))
			end
		end,
		Hidden = function()
			cancel() -- equivalent call inferred; original call site unknown
			count += 1
			UIIdle.stop(child)
			local v7 = {}

			for k in pairs(v6) do
				table.insert(v7, k)
			end

			enthusiasticArrive.reset(v7)
		end
	})
end

local v5 = {
	"Index",
	"Products",
	"Shop",
	"Rebirth",
	"Settings",
	"Gifting",
	"OfflineEarnings",
	"EggTracker",
	"Sell",
	"Fusion"
}

for _, childName in ipairs({ "Gifting", "OfflineEarnings", "EggTracker" }) do
	local child = parent:FindFirstChild(childName)

	if child then
		wire(child)
	end
end

local UIRewardFX = require(ReplicatedStorage:WaitForChild("UIRewardFX"))
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v6 = { "Products", "Shop" }

local function faint(instance)
	local function set(p)
		local success, result = pcall(function()
			return instance[p]
		end)

		if success and type(result) == "number" and result < 1 then
			instance[p] = math.max(result, 0.99)
		end
	end

	if instance:IsA("GuiObject") then
		local v7 = "BackgroundTransparency"
		local success, result = pcall(function()
			return instance[v7]
		end)

		if success and type(result) == "number" and result < 1 then
			instance.BackgroundTransparency = math.max(result, 0.99)
		end
	end

	if instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
		local v7 = "ImageTransparency"
		local success, result = pcall(function()
			return instance[v7]
		end)

		if success and type(result) == "number" and result < 1 then
			instance.ImageTransparency = math.max(result, 0.99)
		end
	end

	if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
		local v7 = "TextTransparency"
		local success, result = pcall(function()
			return instance[v7]
		end)

		if success and type(result) == "number" and result < 1 then
			instance.TextTransparency = math.max(result, 0.99)
		end

		local v8 = "TextStrokeTransparency"
		local success2, result2 = pcall(function()
			return instance[v8]
		end)

		if success2 and type(result2) == "number" and result2 < 1 then
			instance.TextStrokeTransparency = math.max(result2, 0.99)
		end
	end

	if instance:IsA("UIStroke") or instance.ClassName == "UIShadow" then
		local v7 = "Transparency"
		local success, result = pcall(function()
			return instance[v7]
		end)

		if success and type(result) == "number" and result < 1 then
			instance.Transparency = math.max(result, 0.99)
		end
	end
end

local function primeWindow(child, screenGui)
	local clone = child:Clone()

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") or descendant:IsA("ValueBase") then
			descendant:Destroy()
		else
			for _, tag in ipairs(descendant:GetTags()) do
				descendant:RemoveTag(tag)
			end

			faint(descendant)
		end
	end

	for _, tag in ipairs(clone:GetTags()) do
		clone:RemoveTag(tag)
	end

	faint(clone)
	clone.Visible = true
	clone.Interactable = false
	clone.Parent = screenGui
end

local function fn()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "UIPrimer"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = -1000
	screenGui.IgnoreGuiInset = parent.IgnoreGuiInset
	screenGui.ScreenInsets = parent.ScreenInsets
	screenGui.ZIndexBehavior = parent.ZIndexBehavior

	for _, childName in ipairs(v6) do
		local child = parent:FindFirstChild(childName)

		if not child or child.Visible then
			continue
		end

		primeWindow(child, screenGui)
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Image = "rbxassetid://126628363806518"
	imageLabel.ImageTransparency = 0.99
	imageLabel.BackgroundTransparency = 1
	imageLabel.Size = UDim2.fromOffset(64, 64)
	imageLabel.Parent = screenGui
	screenGui.Parent = playerGui
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	RunService.RenderStepped:Wait()
	screenGui:Destroy()
end

local v7 = {
	{
		"Products",
		{
			"Header",
			"Close",
			"Holder.DragonEgg",
			"Holder.GiantEgg",
			"Gift"
		}
	},
	{ "Products" }
}

local function imageIds(folder, p, images)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(guiObject)
		if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
			local image = guiObject.Image

			if image ~= "" and not p[image] then
				p[image] = true
				table.insert(images, image)
			end
		end
	end

	add(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(folder:GetDescendants()) do
		add(descendant) -- equivalent call inferred; original call site unknown
	end
end

local v8 = false
task.spawn(function()
	task.wait()
	pcall(ContentProvider.PreloadAsync, ContentProvider, { "rbxassetid://126628363806518" })
	local v9 = {
		["rbxassetid://126628363806518"] = true
	}

	for _, v10 in ipairs(v7) do
		local child = parent:FindFirstChild(v10[1])

		if not child then
			continue
		end

		local v11 = {}

		if v10[2] then
			for _, v12 in ipairs(v10[2]) do
				local child2 = child

				for childName in v12:gmatch("[^%.]+") do
					child2 = child2 and child2:FindFirstChild(childName)
				end

				if child2 then
					imageIds(child2, v9, v11)
				end
			end
		else
			imageIds(child, v9, v11)
		end

		if #v11 > 0 then
			pcall(ContentProvider.PreloadAsync, ContentProvider, v11)
		end
	end

	while not v8 do
		task.wait(0.1)
	end

	fn()
end)
task.delay(1, function()
	for _, childName in ipairs(v5) do
		local child = parent:FindFirstChild(childName)

		if child then
			UIIdle.warm(child)
			UIController.warm(child)
		end

		task.wait()
	end

	UIRewardFX.warm()
	v8 = true
end)