local RunService = game:GetService("RunService")
game:GetService("ContentProvider")
local isClient = RunService:IsClient()
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = isClient and Players.LocalPlayer
local ImpactFrames = {}
local v = {
	FrameRate = 0.041666666666666664
}

local function reconcileConfig(options)
	local result = options or {}

	for k, v2 in pairs(v) do
		if result[k] ~= nil then
			v2 = result[k] or v2
		end

		result[k] = v2
	end

	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hasProperty(screenGui, name)
	local success, _ = pcall(function()
		screenGui[name] = screenGui[name]
	end)
	return success
end

local impact_Frames = ReplicatedStorage:FindFirstChild("Assets"):FindFirstChild("Impact_Frames")
local v2 = {}

local function release(p: string)
	local v3 = v2[p]

	if v3 == nil then
		return
	end

	v2[p] = nil
	v3.gui:Destroy()
end

local v3 = { "Frames" }
local parent

if isClient then
	parent = localPlayer.PlayerGui:FindFirstChild("ImpactFramesCache")

	if not parent then
		parent = Instance.new("ScreenGui")
		parent.Name = "ImpactFramesCache"
		parent.Enabled = false
		parent.ResetOnSpawn = false
		parent.Parent = localPlayer.PlayerGui
	end
else
	parent = nil
end

function ImpactFrames.GetSet(childName: string)
	if v2[childName] then
		return v2[childName].gui, v2[childName].images
	end

	local child = impact_Frames:FindFirstChild(childName)

	if not child then
		warn(string.format("%s Impact Frames Not Found", childName))
		return false
	end

	if not child:FindFirstChild("Frames") then
		warn(string.format("Frames Folder Missing on %s", childName))
		return false
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Name = string.format("%sFlipbooks", childName)

	for _, child2 in pairs(child:GetChildren()) do
		if table.find(v3, child2.Name) or not hasProperty(screenGui, child2.Name) then
			continue
		end

		screenGui[child2.Name] = child2.Value
	end

	local result = {}

	for _, child2 in pairs(child:FindFirstChild("Frames"):GetChildren()) do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Parent = screenGui
		imageLabel.BackgroundTransparency = 1
		imageLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Size = UDim2.new(0, 0, 0, 0)
		imageLabel.Selectable = false
		imageLabel.ScaleType = Enum.ScaleType.Crop
		imageLabel.Image = child2.Texture
		imageLabel.Name = childName .. child2.Name
		result[tonumber(child2.Name)] = imageLabel
	end

	screenGui.Parent = parent
	v2[childName] = {
		gui = screenGui,
		images = result
	}
	return screenGui, result
end

function ImpactFrames.PlaySet(p)
	if not isClient then
		return
	end

	assert(p.FramesSetName, "Impact Frames Set Name Missing")
	local v5 = reconcileConfig(p)
	local set, v6 = ImpactFrames.GetSet(v5.FramesSetName)

	if not set then
		return false
	end

	local v7 = v2[v5.FramesSetName]

	if v7.release ~= nil then
		task.cancel(v7.release)
		v7.release = nil
	end

	set.Parent = localPlayer.PlayerGui
	local fn
	local now = 0
	local v8 = 0
	local v9 = string.format("%s_FlipBooks", v5.FramesSetName)
	RunService:BindToRenderStep(v9, Enum.RenderPriority.Camera.Value - 1, function(_: number)
		if os.clock() - now < v5.FrameRate then
			return
		end

		now = os.clock()
		local v10 = v8 + 1

		if v6[v10] == nil then
			if v6[v10 + 1] then
				warn(string.format("%s Flipbooks Frame %i Missing", v5.FramesSetName, v10))
			end

			return fn()
		else
			if v6[v8] then
				v6[v8].Size = UDim2.new(0, 0, 0, 0)
			end

			v6[v10].Size = UDim2.new(1, 0, 1, 0)
			v8 = v10
		end
	end)
	local thread = nil
	local flag = false

	fn = function()
		if flag then
			return
		end

		flag = true

		if thread and coroutine.status(thread) == "suspended" then
			task.cancel(thread)
		end

		thread = nil
		RunService:UnbindFromRenderStep(v9)

		if v6[v8] then
			v6[v8].Size = UDim2.new(0, 0, 0, 0)
		end

		set.Parent = parent

		if v7.release ~= nil then
			task.cancel(v7.release)
		end

		v7.release = task.delay(180, release, v5.FramesSetName)
	end

	thread = task.delay(v5.FrameRate * (#v6 + 1), fn)
	return fn
end

return ImpactFrames