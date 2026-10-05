local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

if not RunService:IsStudio() then
	return
end

local Trove = require(ReplicatedStorage.Packages.Trove)
local Signal = require(ReplicatedStorage.Packages.Signal)
local v = Signal.new()
local v2 = Signal.new()
local v3 = table.create(256)
local flag = false

for i = 1, 256 do
	v3[i] = {}
end

local v4 = {}

local function watchModel(folder)
	if v4[folder] then
		return
	end

	local maid = Trove.new()
	maid:AttachToInstance(folder)
	v4[folder] = maid
	maid:Add(function()
		v4[folder] = nil
	end)
	local flag2 = false

	local function onInvalidated()
		if flag or flag2 then
			return
		end

		flag2 = true
		v2:Once(function()
			flag2 = false
			table.insert(v3[#v3], folder)
		end)
	end

	local v5 = {}

	local function watchProperties(descendant)
		if not (flag or flag2) then
			flag2 = true
			v2:Once(function()
				flag2 = false
				table.insert(v3[#v3], folder)
			end)
		end

		local maid2 = maid:Extend()
		maid2:AttachToInstance(descendant)
		v5[descendant] = maid2
		maid2:Add(function()
			v5[descendant] = nil
		end)
		maid2:Add(descendant.Changed:Connect(function()
			if flag or flag2 then
				return
			end

			flag2 = true
			v2:Once(function()
				flag2 = false
				table.insert(v3[#v3], folder)
			end)
		end))
	end

	if not (flag or flag2) then
		flag2 = true
		v2:Once(function()
			flag2 = false
			table.insert(v3[#v3], folder)
		end)
	end

	for _, descendant in folder:GetDescendants() do
		watchProperties(descendant)
	end

	maid:Add(folder.DescendantAdded:Connect(watchProperties))
	maid:Add(folder.DescendantRemoving:Connect(function(descendant)
		if not (flag or flag2) then
			flag2 = true
			v2:Once(function()
				flag2 = false
				table.insert(v3[#v3], folder)
			end)
		end

		if v5[descendant] then
			v5[descendant]:Destroy()
		end
	end))
end

for _, v5 in workspace:QueryDescendants("Model > MeshPart [HasSkinnedMesh = true]") do
	local model = v5:FindFirstAncestor("Model")

	if model then
		watchModel(model)
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant.ClassName == "MeshPart" then
		local model = descendant:FindFirstAncestorOfClass("Model")

		if not model then
			return
		end

		watchModel(model)
	end
end)
local fastClusterCounters = script.FastClusterCounters
fastClusterCounters.Enabled = true
fastClusterCounters.Parent = game.Players.LocalPlayer.PlayerGui
local v5 = {}

for i = 1, 256 do
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(255, 93, 87)
	frame.LayoutOrder = i
	frame.Position = UDim2.fromScale(i / 256, 1)
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.BorderSizePixel = 0
	frame.Parent = fastClusterCounters.Frame.Bars
	frame.MouseEnter:Connect(function() end)
	v5[i] = frame
end

RunService.RenderStepped:Connect(function()
	v2:Fire()

	if not flag then
		table.remove(v3, 1)
		v3[#v3 + 1] = 0
	end

	local text = math.max(24, (math.max(unpack(v3))))

	for i = 1, 256 do
		local v7 = v3[i]

		if v7 and text ~= 0 then
			v5[i].Size = UDim2.fromScale(0.00390625, (math.clamp(v7 / text, 0, 1)))
		else
			v5[i].Size = UDim2.fromScale(0.00390625, 0)
		end
	end

	fastClusterCounters.Frame.ValueMax.Text = text
	fastClusterCounters.Frame.ValueHalf.Text = text // 2
	fastClusterCounters.Frame.ValueZero.Text = "0"
	v:Fire()
end)
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		flag = true
	elseif input.KeyCode == Enum.KeyCode.O and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		flag = false
	elseif input.KeyCode == Enum.KeyCode.L and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		fastClusterCounters.Enabled = not fastClusterCounters.Enabled
	elseif input.KeyCode == Enum.KeyCode.E then
		v2:Once(function()
			v3[#v3] = math.random(1, 24)
		end)
	end
end)