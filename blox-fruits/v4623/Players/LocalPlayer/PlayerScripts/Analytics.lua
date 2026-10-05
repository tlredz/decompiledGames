local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require(game.ReplicatedStorage.Packages.Option)
local Vec = require(game.ReplicatedStorage.Packages.Vec)
local React = require(game.ReplicatedStorage.Packages.React)
local ReactRoblox = require(game.ReplicatedStorage.Packages.ReactRoblox)
local BuildInfo = require(game.ReplicatedStorage.BuildInfo)
require(game.ReplicatedStorage.React.RobloxTypes)
local Net = require(game.ReplicatedStorage.Modules.Net)
local Frustum = require(game.ReplicatedStorage.Util.Frustum)
local touchEnabled = not BuildInfo.IS_PUBLISHED and UserInputService.TouchEnabled
local remoteEvent = Net:RemoteEvent("OnFPSToggleCommand")
local onAnalyticsUpdate = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("OnAnalyticsUpdate")
local createElement = React.createElement
local v = nil
local class = {}
class.__index = class

function class:Destroy()
	if not self._IsAlive then
		return
	end

	self._IsAlive = false

	if v == self then
		v = nil
	end

	self._Connections:forEach(function(connection)
		pcall(function()
			connection:Disconnect()
		end)
	end)
	self._CleanUpCallbacks:forEach(function(callback)
		pcall(callback)
	end)
	setmetatable(self, nil)
	table.clear(self)
end

function class:GetIfInitialized()
	if v then
		return v._IsAlive
	end

	return false
end

function class.init()
	local v2 = v

	if class:GetIfInitialized() and v2 then
		return function()
			return v2:Destroy()
		end
	end

	local object = setmetatable({
		_IsAlive = true,
		_Connections = Vec.emptyMut(),
		_CleanUpCallbacks = Vec.emptyMut()
	}, class)
	local userIds = {}
	object._Connections:push(Players.PlayerAdded:Connect(function(player)
		if Players.LocalPlayer:IsFriendsWith(player.UserId) and not table.find(userIds, player.UserId) then
			table.insert(userIds, player.UserId)
		end
	end))
	object._Connections:push(Players.PlayerRemoving:Connect(function(player)
		local index = table.find(userIds, player.UserId)

		if index then
			table.remove(userIds, index)
		end
	end))
	local v3 = {}
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local count = 0
	object._Connections:push(RunService.RenderStepped:Connect(function(_)
		count += 1

		if count % 30 ~= 0 then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera then
			return
		end

		local character = Players.LocalPlayer.Character

		if character then
			raycastParams.FilterDescendantsInstances = { character }
		else
			raycastParams.FilterDescendantsInstances = {}
		end

		local v4 = Frustum.fromCamera(currentCamera, 1000)

		for _, v5 in Players:GetPlayers() do
			if v5.UserId == Players.LocalPlayer.UserId or v3[v5.UserId] then
				continue
			end

			local character2 = v5.Character

			if not character2 then
				continue
			end

			local humanoidRootPart = character2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart or not humanoidRootPart:IsA("BasePart") or (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude > 1000 or not Frustum.sphereInFrustum(
				v4,
				humanoidRootPart.Position,
				3
			) then
				continue
			end

			local raycastResult = workspace:Raycast(
				currentCamera.CFrame.Position,
				(humanoidRootPart.Position - currentCamera.CFrame.Position).Unit * 1000,
				raycastParams
			)

			if not raycastResult or raycastResult.Instance:IsDescendantOf(character2) then
				v3[v5.UserId] = true
			end
		end
	end))

	if touchEnabled then
		local function rootComponent(_)
			local state, setState = React.useState(0)
			local state2, setState2 = React.useState(false)
			React.useEffect(function()
				if state2 == false then
					return function() end
				end

				local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
					setState(1 / dt)
				end)
				return function()
					renderSteppedConnection:Disconnect()
				end
			end, { state2 })
			React.useEffect(function()
				local onClientEventConnection = remoteEvent.OnClientEvent:Connect(function()
					setState2(not state2)
				end)
				return function()
					onClientEventConnection:Disconnect()
				end
			end, { state2 })
			return React.createElement("TextLabel", {
				Size = UDim2.fromOffset(0, 0),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				TextSize = 14,
				Visible = state2,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = string.format("FPS: %.2f", state),
				TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
				TextStrokeTransparency = 0.5
			})
		end

		local function bootGui()
			local flag = true
			local screenGui = Instance.new("ScreenGui")
			screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			screenGui.Name = "FPSCounter"
			screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
			screenGui.Enabled = true
			screenGui.ResetOnSpawn = false
			local root = ReactRoblox.createRoot(screenGui)
			local thread = task.spawn(function()
				root:render((ReactRoblox.createPortal(createElement(rootComponent, {
					Root = screenGui
				}), screenGui)))
			end)
			object._CleanUpCallbacks:push(function()
				if not flag then
					return
				end

				flag = false
				root:unmount()
				screenGui:Destroy()
				task.cancel(thread)
			end)
		end

		local thread = task.spawn(function()
			bootGui()
		end)
		object._CleanUpCallbacks:push(function()
			task.cancel(thread)
		end)
	end

	local lastTime = tick()
	object._Connections:push(RunService.RenderStepped:Connect(function(_: number)
		if tick() - lastTime >= 15 then
			lastTime = tick()
			local v4 = UserInputService.MouseEnabled and "PC" or UserInputService.GamepadEnabled and "Console" or UserInputService.TouchEnabled and "Mobile" or "Unknown"
			local v5 = nil
			local success, result = pcall(function()
				return ReplicatedStorage.Remotes.GetSetting:InvokeServer("MobileSchemeMode")
			end)
			local success2, result2 = pcall(function()
				return ReplicatedStorage.Remotes.GetSetting:InvokeServer("MobileSkillMode")
			end)
			local v6

			if success == true then
				v6 = result == true
			end

			if success2 == true and type(result2) == "number" then
				v5 = result2
			end

			local v7 = {}

			for k, _ in pairs(v3) do
				table.insert(v7, k)
			end

			table.clear(v3)
			local Global = require(game.ReplicatedStorage.Global)
			onAnalyticsUpdate:FireServer(
				userIds,
				Global.Shiftlock,
				Players.LocalPlayer.LocaleId,
				v4,
				workspace.CurrentCamera.ViewportSize,
				v6,
				v5,
				v7
			)
		end
	end))
	local v4 = v
	v = object

	if v4 then
		v4:Destroy()
	end

	return function()
		object:Destroy()
	end
end

class.init()