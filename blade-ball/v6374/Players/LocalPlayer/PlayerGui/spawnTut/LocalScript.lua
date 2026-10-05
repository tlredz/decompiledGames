local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local Replion = require(ReplicatedStorage.Packages.Replion)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.ServerInfo)
local DeviceListener = require(ReplicatedStorage.ClientGameModules.DeviceListener)
local ABTestController = require(ReplicatedStorage.Controllers.ABTestController)
local FFlag = require(ReplicatedStorage.Common.Utils.Utilities.FFlag)
local remoteEvent = Net:RemoteEvent("CloseTutorialFrame")
local v = Replion.Client:WaitReplion("Data")
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local v2 = game.ReplicatedStorage.Remotes.isFirstTime:InvokeServer()

if not v2 then
	local ServerInfo = require(game.ReplicatedStorage.ServerInfo)
	v2 = ServerInfo.isTutorialServer()
end

local fFlag = FFlag.GetFFlag("QuickStartTutorial", true)
local lastTime = os.clock()
local v3 = false
local thread = nil

while not ABTestController:IsLoaded() and os.clock() - lastTime < 7 and not fFlag do
	task.wait()
end

local aB_HideTutorialUI = localPlayer:GetAttribute("AB_HideTutorialUI") or localPlayer:GetAttribute("AB_QuickStartTutorial") or fFlag

if v2 and not aB_HideTutorialUI then
	parent.Enabled = true
	local connection = DeviceListener:Observe(function(p)
		parent.Frame.Background.GamepadIcon.Visible = p == "Console"
	end)
	local inputBeganConnection = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function close()
		parent.Enabled = false
		connection:Disconnect()
		inputBeganConnection:Disconnect()
		remoteEvent:FireServer()
	end

	inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
		if input.KeyCode == Enum.KeyCode.ButtonB and not gameProcessed then
			close() -- equivalent call inferred; original call site unknown
		end
	end)
	parent.Frame.Background.X.Activated:Connect(close)

	local function updateAutoClose()
		v3 = v:Get("AutoCloseTutorialEnabled") == true

		if thread then
			task.cancel(thread)
			thread = nil
		end

		if v3 then
			thread = task.delay(25, function()
				if not parent.Enabled then
					return
				end

				close() -- equivalent call inferred; original call site unknown
			end)
		end
	end

	localPlayer:GetAttributeChangedSignal("TutorialFrameClosed"):Connect(function()
		if localPlayer:GetAttribute("TutorialFrameClosed") then
			close() -- equivalent call inferred; original call site unknown
		end
	end)
	v:OnChange("AutoCloseTutorialEnabled", updateAutoClose)
	updateAutoClose()
else
	parent.Enabled = false
	remoteEvent:FireServer()
end