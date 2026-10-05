local localPlayer = game.Players.LocalPlayer

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local arrow = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar").Block.Arrow
local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In, -1, true)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UseBall2 = require(ReplicatedStorage2.Shared.UseBall2)
local v = true
local v2 = nil
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
ReplicatedStorage3.Remotes.TimesParriedUpdate.OnClientEvent:Connect(function(p)
	v2 = p
end)
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
v2 = ReplicatedStorage4.Remotes.getParryAmt:InvokeServer()
local v3 = not (v2 > 6)
local v4 = {
	[0] = 1.5,
	[1] = 1.25,
	[2] = 1,
	[3] = 0.75,
	[4] = 0.625
}
setmetatable(v4, {
	__index = function(_, _)
		return 0.55
	end
})

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenTransparency()
	v = not v

	if v then
		arrow.ImageTransparency = 1
	else
		arrow.ImageTransparency = 0
	end
end

local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include

if v3 then
	local v5

	if UserInputService.TouchEnabled and not (UserInputService.KeyboardEnabled and UserInputService.GamepadEnabled) then
		arrow.AnchorPoint = Vector2.new(0.5, 0.5)
		arrow.Position = UDim2.new(-0.15, 0, 0.5, 0)
		arrow.Rotation = -90
		local TweenService = game:GetService("TweenService")
		v5 = TweenService:Create(arrow, tweenInfo, {
			Position = UDim2.new(-0.25, 0, 0.5, 0)
		})
	else
		local TweenService = game:GetService("TweenService")
		v5 = TweenService:Create(arrow, tweenInfo, {
			Position = UDim2.new(0.5, 0, -0.1, 0)
		})
	end

	v5:Play()

	local function charAdded(instance)
		if v2 >= 5 then
			return
		end

		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		local heartbeatConnection = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function cancel()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			arrow.ImageTransparency = 1
		end

		local function start()
			cancel() -- equivalent call inferred; original call site unknown
			overlapParams.FilterDescendantsInstances = { instance }
			local v6 = 0
			local useBall2 = UseBall2()
			local RunService = game:GetService("RunService")
			heartbeatConnection = RunService.Heartbeat:Connect(function()
				local now = os.clock()

				if not (v6 <= now) then
					return
				end

				v6 = os.clock() + 0.05

				if v2 >= 5 or not humanoidRootPart then
					cancel() -- equivalent call inferred; original call site unknown
				else
					local children = workspace.Balls:GetChildren()

					for _, v8 in pairs(children) do
						local v9, position

						if useBall2 then
							local collisionWhitelist = v8:FindFirstChild("CollisionWhitelist")

							if collisionWhitelist and collisionWhitelist.Value == localPlayer.Character then
								v9 = v8.Body.Position + v8.Body.AssemblyLinearVelocity * (v4[v2] + localPlayer:GetNetworkPing())
								position = v8.Body.Position
							else
								arrow.ImageTransparency = 1
								continue
							end
						else
							if not v8:GetAttribute("realBall") then
								continue
							end

							if v8:GetAttribute("target") == localPlayer.Name then
								v9 = v8.Position + v8.AssemblyLinearVelocity * (v4[v2] + localPlayer:GetNetworkPing())
								position = v8.Position
							else
								arrow.ImageTransparency = 1
								continue
							end
						end

						if v2 < 2 then
							if v then
								tweenTransparency() -- equivalent call inferred; original call site unknown
							end
						elseif #workspace:GetPartBoundsInRadius(
							position + (v9 - position) / 2,
							((v9 - position) / 2).Magnitude + 7.5,
							overlapParams
						) > 0 then
							if v then
								tweenTransparency() -- equivalent call inferred; original call site unknown
							end
						elseif not v then
							tweenTransparency() -- equivalent call inferred; original call site unknown
						end
					end
				end
			end)
		end

		instance.AncestryChanged:Connect(function()
			if instance.Parent == workspace.Alive and v2 < 5 then
				start()
				return
			end

			cancel() -- equivalent call inferred; original call site unknown
		end)
		instance:WaitForChild("Humanoid").Died:Connect(cancel)
	end

	localPlayer.CharacterAdded:Connect(charAdded)

	if localPlayer.Character then
		task.spawn(charAdded, localPlayer.Character)
	end
end