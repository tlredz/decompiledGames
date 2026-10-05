local Players = game:GetService("Players")
game:GetService("StarterGui")
game:GetService("ReplicatedStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
local Observers = require(ReplicatedStorage.Packages.Observers)
local BackpackController = require(ReplicatedStorage.Controllers.BackpackController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local hotbar = nil
local highlight = Instance.new("Highlight")
highlight.Name = "MainHighlight"
highlight.DepthMode = Enum.HighlightDepthMode.Occluded
highlight.FillColor = Color3.fromRGB(255, 0, 0)
highlight.FillTransparency = 0.5
highlight.OutlineColor = Color3.fromRGB(155, 0, 0)
highlight.OutlineTransparency = 0.8
highlight.Parent = workspace
highlight.Adornee = script
local v = {}

local function CooldownFunction(instance)
	local currentSlot = instance:GetAttribute("CurrentSlot")
	local cooldownTime = tonumber(instance:GetAttribute("CooldownTime") or 0) or 0

	if not (hotbar and currentSlot) then
		return
	end

	local child = hotbar:FindFirstChild(currentSlot)

	if not child then
		return
	end

	local icon = child:FindFirstChild("Icon")

	if not icon then
		return
	end

	local visible = not (cooldownTime <= 0)
	local cooldownTextLabel = icon:FindFirstChild("CooldownTextLabel")

	if cooldownTextLabel then
		cooldownTextLabel.Text = string.format("%0.1f", cooldownTime)
		cooldownTextLabel.Visible = visible
	end

	icon.ImageColor3 = visible and Color3.fromRGB(90, 90, 90) or Color3.fromRGB(255, 255, 255)
end

local function SetupTool(tool)
	tool:GetAttributeChangedSignal("CooldownTime"):Connect(function()
		CooldownFunction(tool)
	end)
	tool:GetAttributeChangedSignal("CurrentSlot"):Connect(function()
		CooldownFunction(tool)
	end)
	task.spawn(CooldownFunction, tool)
end

local ItemController = {}

function ItemController.Load(_)
	for _, moduleScript in script:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local success, result = pcall(require, moduleScript)

		if success and result and result.Start then
			result:Start()
		end
	end
end

function ItemController:Start()
	local function updateBlockTools()
		BackpackController:SetEnabled(
			"BlockTools",
			not (localPlayer:GetAttribute("BlockTools") or localPlayer:GetAttribute("Stealing") or localPlayer:GetAttribute("CartSeated") or localPlayer:GetAttribute("TrainSeated") or localPlayer:GetAttribute("SleighSeated") or ReplicatedStorage:GetAttribute("InTrainTravelCutscene"))
		)
	end

	ReplicatedStorage:GetAttributeChangedSignal("InTrainTravelCutscene"):Connect(updateBlockTools)
	localPlayer:GetAttributeChangedSignal("SleighSeated"):Connect(updateBlockTools)
	localPlayer:GetAttributeChangedSignal("TrainSeated"):Connect(updateBlockTools)
	localPlayer:GetAttributeChangedSignal("CartSeated"):Connect(updateBlockTools)
	localPlayer:GetAttributeChangedSignal("BlockTools"):Connect(updateBlockTools)
	localPlayer:GetAttributeChangedSignal("Stealing"):Connect(updateBlockTools)
	task.spawn(updateBlockTools)
	hotbar = playerGui:WaitForChild("BackpackGui", 999):WaitForChild("Backpack"):WaitForChild("Hotbar")
	Observers.observeCharacter(localPlayer, function(instance, _)
		local backpack = instance:WaitForChild("Backpack")

		if not backpack then
			return nil
		end

		for _, tool in backpack:GetChildren() do
			if tool:IsA("Tool") then
				task.spawn(SetupTool, tool)
			end
		end

		local childAddedConnection = backpack.ChildAdded:Connect(function(tool)
			if tool:IsA("Tool") then
				SetupTool(tool)
			end
		end)
		return function()
			childAddedConnection:Disconnect()
		end
	end)
	Net:RemoteEvent("Tools/Cooldown").OnClientEvent:Connect(function(instance, p: number)
		local lastTime = os.clock()
		local v2 = v[instance.Name]

		if v2 and coroutine.status(v2) ~= "suspended" then
			task.cancel(v2)
			instance:SetAttribute("CooldownTime", nil)
			v[instance.Name] = nil
		end

		local thread = task.spawn(function()
			while true do
				local v4 = p - (os.clock() - lastTime)

				if v4 <= 0 then
					break
				end

				instance:SetAttribute("CooldownTime", v4)
				task.wait(0.05)
			end

			instance:SetAttribute("CooldownTime", nil)
			v[instance.Name] = nil
		end)
		v[instance.Name] = thread
	end)
end

return ItemController