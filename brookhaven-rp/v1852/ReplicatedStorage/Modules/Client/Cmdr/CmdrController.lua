local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CmdrPermissions = require(ReplicatedStorage.Modules.Shared.Cmdr.CmdrPermissions)
local InstanceLoadingUtil = require(ReplicatedStorage.Modules.Shared.Utils.InstanceLoadingUtil)
local Platform = require(ReplicatedStorage.Modules.Client.Util.Platform)
local packages = ReplicatedStorage:WaitForChild("Packages")
local Promise = require(packages.Promise)
local v = { Enum.KeyCode.F2, Enum.KeyCode.Semicolon }
local v2 = RunService:IsStudio() and 0.25 or 4
local flag = false

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCmdr()
	if flag then
		return
	end

	flag = true
	task.delay(5, function()
		local cmdrClient = ReplicatedStorage:WaitForChild("CmdrClient")
		local v3 = {}
		table.insert(v3, InstanceLoadingUtil.waitForDescendantsToLoad(cmdrClient:WaitForChild("Commands"), v2))
		table.insert(v3, InstanceLoadingUtil.waitForDescendantsToLoad(cmdrClient:WaitForChild("Types"), v2))
		Promise.allSettled(v3):expect()
		local module = require(cmdrClient)
		module:SetActivationKeys(v)
		local count = 0
		local v4 = false
		ContextActionService:BindAction("CmdrControllerHoldToggle", function(_, p)
			if p == Enum.UserInputState.Begin then
				count += 1
				local v5 = count
				v4 = true
				task.delay(0.5, function()
					if not v4 or v5 ~= count then
						return
					end

					module:Toggle()
				end)
			elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
				v4 = false
			end

			return Enum.ContextActionResult.Pass
		end, false, Enum.KeyCode.ButtonX)

		if not Platform.IsMobile() then
			return
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "CmdrMobile"
		screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
		local frame = Instance.new("Frame")
		frame.Name = "CmdrMobileFrame"
		frame.Size = UDim2.fromScale(1, 1)
		frame.BackgroundTransparency = 1
		frame.Parent = screenGui
		local textButton = Instance.new("TextButton")
		textButton.Name = "CmdrMobileButton"
		textButton.Parent = frame
		textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		textButton.BackgroundTransparency = 0.7
		textButton.AnchorPoint = Vector2.new(1, 1)
		textButton.Position = UDim2.fromScale(1, 1)
		textButton.Size = UDim2.fromScale(0.1, 0.1)
		textButton.TextScaled = true
		textButton.Text = "CMDR"
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0.5, 0.5)
		uICorner.Parent = textButton
		textButton.Activated:Connect(function()
			module:Toggle()
		end)
	end)
end

local CmdrController = {}

function CmdrController.FrameworkStart()
	local localPlayer = Players.LocalPlayer

	if CmdrPermissions.hasCmdrAccess(localPlayer) and not flag then
		flag = true
		task.delay(5, function()
			local cmdrClient = ReplicatedStorage:WaitForChild("CmdrClient")
			local v3 = {}
			table.insert(v3, InstanceLoadingUtil.waitForDescendantsToLoad(cmdrClient:WaitForChild("Commands"), v2))
			table.insert(v3, InstanceLoadingUtil.waitForDescendantsToLoad(cmdrClient:WaitForChild("Types"), v2))
			Promise.allSettled(v3):expect()
			local module = require(cmdrClient)
			module:SetActivationKeys(v)
			local count = 0
			local v4 = false
			ContextActionService:BindAction("CmdrControllerHoldToggle", function(_, p)
				if p == Enum.UserInputState.Begin then
					count += 1
					local v5 = count
					v4 = true
					task.delay(0.5, function()
						if not v4 or v5 ~= count then
							return
						end

						module:Toggle()
					end)
				elseif p == Enum.UserInputState.End or p == Enum.UserInputState.Cancel then
					v4 = false
				end

				return Enum.ContextActionResult.Pass
			end, false, Enum.KeyCode.ButtonX)

			if not Platform.IsMobile() then
				return
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Name = "CmdrMobile"
			screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			local frame = Instance.new("Frame")
			frame.Name = "CmdrMobileFrame"
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 1
			frame.Parent = screenGui
			local textButton = Instance.new("TextButton")
			textButton.Name = "CmdrMobileButton"
			textButton.Parent = frame
			textButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			textButton.BackgroundTransparency = 0.7
			textButton.AnchorPoint = Vector2.new(1, 1)
			textButton.Position = UDim2.fromScale(1, 1)
			textButton.Size = UDim2.fromScale(0.1, 0.1)
			textButton.TextScaled = true
			textButton.Text = "CMDR"
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0.5, 0.5)
			uICorner.Parent = textButton
			textButton.Activated:Connect(function()
				module:Toggle()
			end)
		end)
	end

	localPlayer:GetAttributeChangedSignal(CmdrPermissions.PRIVATE_SERVER_COMMAND_ACCESS_ATTRIBUTE):Connect(function()
		if CmdrPermissions.hasCmdrAccess(localPlayer) then
			setupCmdr() -- equivalent call inferred; original call site unknown
		end
	end)
end

function CmdrController.HasPermission()
	return CmdrPermissions.hasCmdrAccess(Players.LocalPlayer)
end

return CmdrController