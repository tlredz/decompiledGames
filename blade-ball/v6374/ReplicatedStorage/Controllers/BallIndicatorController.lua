local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Shared.UseBall2)
local v2 = require3(ReplicatedStorage2.Controllers.AnalyticsController)
local v3 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
require3(ReplicatedStorage2.Shared.GetServerType)
local v4 = require3(ReplicatedStorage2.ServerInfo)
require3("@game/ReplicatedStorage/Types/Templates")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local ballIndicator = playerGui:WaitForChild("BallIndicator")
local cutscene = playerGui:WaitForChild("Cutscene")
local holder = ballIndicator:WaitForChild("Holder")
local arrow = holder:WaitForChild("Arrow")
local currentCamera = workspace.CurrentCamera
local v5 = {}
local BallIndicatorController = {}

function BallIndicatorController:_addBallPVInstance(instance)
	local isBallV = v()
	v5[instance] = {
		isBallV2 = isBallV,
		fetchTarget = function()
			if isBallV then
				local collisionWhitelist = instance:FindFirstChild("CollisionWhitelist")
				return collisionWhitelist and collisionWhitelist.Value
			end

			for _, child in workspace.Balls:GetChildren() do
				if not (child.Name == instance.Name and child:GetAttribute("realBall") == true) then
					continue
				end

				local target = child:GetAttribute("target")

				if typeof(target) == "string" and target ~= "" then
					return (workspace.Alive:FindFirstChild(target))
				end

				return nil
			end

			return nil
		end
	}
end

function BallIndicatorController:_removeBallPVInstance(p)
	v5[p] = nil
end

function BallIndicatorController:_fetchTargetFromPVInstance(p)
	local v6 = v5[p]

	if v6 then
		return v6.fetchTarget()
	end

	return nil
end

function BallIndicatorController:Start()
	if v4.isDungeonsMatchServer() then
		return
	end

	if not (v4.isLTMServer() or v4.isTestGame() or v2:GetRemoteConfigValue("BallIndicatorArrowEnabled", false):expect()) then
		return
	end

	local v6 = false
	task.spawn(function()
		local function onDataUpdate()
			v6 = v3:GetKey("BallIndicator") == true
		end

		v3.DataUpdatedEvent:Connect(onDataUpdate)
		task.spawn(onDataUpdate)
	end)

	local function onBallAdded(instance)
		if v() then
			self:_addBallPVInstance(instance)
		else
			task.wait()

			if instance:GetAttribute("realBall") then
				return
			else
				self:_addBallPVInstance(instance)
			end
		end

		instance.Destroying:Once(function()
			self:_removeBallPVInstance(instance)
		end)
	end

	workspace.Balls.ChildAdded:Connect(onBallAdded)

	for _, child in workspace.Balls:GetChildren() do
		task.spawn(onBallAdded, child)
	end

	local v7 = false
	local v8 = 0
	local playingFinisher = workspace:GetAttribute("PlayingFinisher")
	workspace:GetAttributeChangedSignal("PlayingFinisher"):Connect(function()
		playingFinisher = workspace:GetAttribute("PlayingFinisher")
	end)
	RunService.PreRender:Connect(function(dt: number)
		local character = localPlayer.Character
		local enabled = v6

		if enabled then
			if character == nil or character.Parent ~= workspace.Alive or next(v5) == nil then
				enabled = false
			else
				enabled = not (cutscene.Enabled or playingFinisher)
			end
		end

		if enabled ~= v7 then
			ballIndicator.Enabled = enabled
			v7 = enabled
		end

		local flag = true

		if enabled then
			local cFrame = currentCamera.CFrame
			local v10 = 1e999
			local v11 = nil

			for k in v5 do
				local magnitude = (k:GetPivot().Position - cFrame.Position).Magnitude

				if not (magnitude < v10) then
					continue
				end

				v11 = k
				v10 = magnitude
			end

			if not v11 then
				return
			end

			local position = v11:GetPivot().Position

			if self:_fetchTargetFromPVInstance(v11) == localPlayer.Character then
				v8 = 1 - math.clamp(0.1 + localPlayer:DistanceFromCharacter(position) / 300, 0, 1)
				flag = false
			end

			arrow.ImageColor3 = Color3.fromHSV(1, 0, 1):Lerp(Color3.fromHSV(1, 1, 1), v8)
			local viewportSize = currentCamera.ViewportSize
			local v12 = math.tan(math.rad(currentCamera.FieldOfView) * 0.5) * 2
			local v13 = viewportSize.X / viewportSize.Y * v12
			local pointToObjectSpace = cFrame:PointToObjectSpace(position)
			local v14 = 0.5 + pointToObjectSpace.X / v13
			local v15 = 0.5 - pointToObjectSpace.Y / v12
			local unit = Vector2.new(v14, v15).Unit
			local v16 = 0.5 + unit.X * 0.5
			local v17 = 0.5 + unit.Y * 0.5
			holder.Rotation = math.deg((math.atan2(v15 - v16, v14 - v17))) + 90
			local worldToViewportPoint, v18 = currentCamera:WorldToViewportPoint(position)
			holder.Visible = not (v18 and worldToViewportPoint.Z > 0.1)
		end

		if flag then
			v8 = math.max(v8 - dt * 6, 0)
		end
	end)
end

return BallIndicatorController