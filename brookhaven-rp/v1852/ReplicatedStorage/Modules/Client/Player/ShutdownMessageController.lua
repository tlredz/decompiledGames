local ShutdownMessageController = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GameSdkShared = require(ReplicatedStorage.Packages.GameSdkShared)
local ABTest = require(GameSdkShared.Modules.ABTest)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
ShutdownMessageController.OnShutdownMessageReceived = Signal.new()
local localPlayer = Players.LocalPlayer

local function startMarquee(shutdownText, maid)
	local parent = shutdownText.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		return function() end
	end

	local v = {
		AutomaticSize = shutdownText.AutomaticSize,
		Position = shutdownText.Position,
		AnchorPoint = shutdownText.AnchorPoint,
		TextXAlignment = shutdownText.TextXAlignment,
		Size = shutdownText.Size,
		ContainerClipsDescendants = parent.ClipsDescendants
	}
	shutdownText.AutomaticSize = Enum.AutomaticSize.X
	shutdownText.AnchorPoint = Vector2.new(0, shutdownText.AnchorPoint.Y)
	shutdownText.TextXAlignment = Enum.TextXAlignment.Left
	shutdownText.Size = UDim2.new(0, 0, shutdownText.Size.Y.Scale, shutdownText.Size.Y.Offset)
	parent.ClipsDescendants = true
	local clone = shutdownText:Clone()
	clone.Name = shutdownText.Name .. "_MarqueeClone"
	clone.Parent = parent
	maid:Add(clone, "Destroy")
	maid:Add(function()
		shutdownText.AutomaticSize = v.AutomaticSize
		shutdownText.Position = v.Position
		shutdownText.AnchorPoint = v.AnchorPoint
		shutdownText.TextXAlignment = v.TextXAlignment
		shutdownText.Size = v.Size
		parent.ClipsDescendants = v.ContainerClipsDescendants
	end, true)
	local X = parent.AbsoluteSize.X
	local v2 = parent.AbsoluteSize.X * 2

	local function setText(text: string)
		shutdownText.Text = text
		clone.Text = text
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyPosition(p, p2: number)
		p.Position = UDim2.new(0, math.floor(p2), p.Position.Y.Scale, p.Position.Y.Offset)
	end

	maid:Add(RunService.RenderStepped:Connect(function(dt: number)
		if shutdownText.Parent == nil then
			return
		end

		local X2 = parent.AbsoluteSize.X
		local X3 = shutdownText.AbsoluteSize.X

		if X2 <= 0 then
			return
		end

		if X3 <= 0 then
			applyPosition(shutdownText, X2) -- equivalent call inferred; original call site unknown
			applyPosition(clone, X2) -- equivalent call inferred; original call site unknown
		else
			local v3 = X3 + 100
			local v4 = dt * 90
			X -= v4
			v2 -= v4

			if X <= -X3 then
				X = v2 + v3
			end

			if v2 <= -X3 then
				v2 = X + v3
			end

			applyPosition(shutdownText, X) -- equivalent call inferred; original call site unknown
			applyPosition(clone, v2) -- equivalent call inferred; original call site unknown
		end
	end), "Disconnect")
	return setText
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderShutdownMessage(p: number)
	if p <= 0 then
		return "Teleporting..."
	end

	local v = math.floor(p)
	local v2 = math.floor(v / 60)
	local v3 = v % 60
	return string.format(
		"A new version of Brookhaven is available! Teleporting to newest version in: %02d:%02d",
		v2,
		v3
	)
end

function ShutdownMessageController.FrameworkInit() end

function ShutdownMessageController.FrameworkStart()
	local v, v2 = ABTest.GetExperimentVariable("shutdown-message", "enabled"):timeout(10):await()

	if not (v and v2) then
		return
	end

	local shutdownText = localPlayer:WaitForChild("PlayerGui"):WaitForChild("SettingsMain"):WaitForChild("Settings"):FindFirstChild(
		"ShutdownText",
		true
	)

	if not shutdownText then
		warn("ShutdownMessageController: ShutdownText not found")
		return
	end

	shutdownText.Visible = false
	local v4 = startMarquee(shutdownText, Janitor.new())
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function publishMessage(p: number)
		local shutdownMessage = renderShutdownMessage(p) -- equivalent call inferred; original call site unknown
		ShutdownMessageController.OnShutdownMessageReceived:Fire(shutdownMessage)
		v4(shutdownMessage)
	end

	Remotes.connect("ShutdownMessage", function(p: number)
		if flag then
			return
		end

		flag = true
		shutdownText.Visible = true
		local v5 = os.clock() + p
		task.spawn(function()
			while true do
				local v6 = v5 - os.clock()
				publishMessage(v6) -- equivalent call inferred; original call site unknown

				if v6 <= 0 then
					break
				else
					task.wait(1)
				end
			end
		end)
	end)
end

return ShutdownMessageController