local createVector = vector.create
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local unreliableRemoteEvent = Net:UnreliableRemoteEvent("CragCrab/Snapshot", 1e999)
local remoteEvent = Net:RemoteEvent("CragCrab/RewardReady", 1e999)
local v = {}

local function updatePromptState(state)
	local proximityPrompt = state.RootPart:FindFirstChild("ProximityPrompt")

	if not proximityPrompt then
		return
	end

	if state.HasReward then
		proximityPrompt.ActionText = "Claim Reward"
		proximityPrompt.Enabled = true
	elseif state.RootPart:GetAttribute("Busy") then
		proximityPrompt.Enabled = false
	else
		proximityPrompt.ActionText = "Send Mining"
		proximityPrompt.Enabled = true
	end

	if state.RewardBillboard and not state.RewardBillboard:IsDescendantOf(game) then
		state.RewardBillboard:Destroy()
		state.RewardBillboard = nil
	end

	if state.HasReward and not state.RewardBillboard then
		local billboardGui = Instance.new("BillboardGui")
		billboardGui.Name = "RewardIndicator"
		billboardGui.Size = UDim2.fromOffset(40, 40)
		billboardGui.StudsOffset = createVector(0, 3.5, 0)
		billboardGui.AlwaysOnTop = true
		billboardGui.MaxDistance = 512
		billboardGui.ResetOnSpawn = false
		billboardGui.AutoLocalize = false
		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.fromScale(1, 1)
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.3
		textLabel.TextScaled = true
		textLabel.AutoLocalize = false
		textLabel.Text = "!"
		textLabel.Parent = billboardGui
		billboardGui.Parent = state.RootPart
		state.RewardBillboard = billboardGui
	elseif not state.HasReward and state.RewardBillboard then
		state.RewardBillboard:Destroy()
		state.RewardBillboard = nil
	end
end

local v2 = {}
return {
	Start = function(_)
		local cragCrabs = workspace:WaitForChild("CragCrabs", 30)

		if not cragCrabs then
			return
		end

		local function trackCrab(child)
			local rootPart = child:FindFirstChild("RootPart")

			if not rootPart then
				return
			end

			local v3 = tonumber(child.Name:match("CragCrab_(%d+)"))

			if not v3 then
				return
			end

			local v4 = {
				RootPart = rootPart,
				TargetPos = rootPart.Position,
				TargetAngle = 0,
				CurrentPos = rootPart.Position,
				CurrentAngle = 0,
				Initialized = false,
				PrevPos = rootPart.Position,
				PrevAngle = 0,
				BobPhase = math.random() * 6.283185307179586,
				BobFreq = 6,
				BobAmp = 0.02 + math.random() * 0.04,
				RollMax = math.rad(6 + math.random() * 6),
				PitchMax = math.rad(4 + math.random() * 4),
				CurrentRoll = 0,
				CurrentPitch = 0,
				PrevSpeed = 0,
				HasReward = v2[v3] or false
			}
			v[v3] = v4
			v4.BusyWatch = rootPart:GetAttributeChangedSignal("Busy"):Connect(function()
				updatePromptState(v4)
			end)
			updatePromptState(v4)
		end

		for _, child in cragCrabs:GetChildren() do
			trackCrab(child)
		end

		cragCrabs.ChildAdded:Connect(trackCrab)
		cragCrabs.ChildRemoved:Connect(function(child)
			local v3 = tonumber(child.Name:match("CragCrab_(%d+)"))

			if not v3 then
				return
			end

			local v4 = v[v3]

			if not v4 then
				return
			end

			if v4.BusyWatch then
				v4.BusyWatch:Disconnect()
			end

			if v4.RewardBillboard then
				v4.RewardBillboard:Destroy()
			end

			table.clear(v4)
			v[v3] = nil
		end)
		unreliableRemoteEvent.OnClientEvent:Connect(function(buf: buffer)
			for i = 1, buffer.len(buf) / 16 do
				local v3 = (i - 1) * 16
				local v4 = v[i]

				if not v4 then
					continue
				end

				local vector2 = Vector3.new(
					buffer.readf32(buf, v3),
					buffer.readf32(buf, v3 + 4),
					(buffer.readf32(buf, v3 + 8))
				)
				local v5 = buffer.readf32(buf, v3 + 12)

				if not v4.Initialized then
					v4.CurrentPos = vector2
					v4.CurrentAngle = v5
					v4.PrevPos = vector2
					v4.PrevAngle = v5
					v4.PrevSpeed = 0
					v4.Initialized = true
				end

				v4.TargetPos = vector2
				v4.TargetAngle = v5
			end
		end)
		remoteEvent.OnClientEvent:Connect(function(p: number, hasReward: boolean)
			v2[p] = hasReward or nil
			local v3 = v[p]

			if v3 and v3.RootPart.Parent then
				v3.HasReward = hasReward
				updatePromptState(v3)
			end
		end)
		RunService.RenderStepped:Connect(function(dt)
			local v3 = 1 - math.exp(-12 * dt)
			local v4 = math.max(dt, 0.001)

			for _, v5 in v do
				if not (v5.Initialized and v5.RootPart.Parent) then
					continue
				end

				v5.CurrentPos = v5.CurrentPos:Lerp(v5.TargetPos, v3)
				local v6 = (v5.TargetAngle - v5.CurrentAngle) % 6.283185307179586

				if v6 > 3.141592653589793 then
					v6 -= 6.283185307179586
				end

				v5.CurrentAngle += v6 * v3
				local prevSpeed = (v5.CurrentPos - v5.PrevPos).Magnitude / v4
				v5.PrevPos = v5.CurrentPos
				local v8 = (v5.CurrentAngle - v5.PrevAngle) / v4
				v5.PrevAngle = v5.CurrentAngle
				local v9 = math.clamp(prevSpeed / 5, 0, 1)
				v5.BobPhase += dt * v5.BobFreq * v9
				local v10 = math.sin(v5.BobPhase * 6.283185307179586) * v5.BobAmp * v9
				local v11 = math.clamp(-v8 * 0.15, -1, 1) * v5.RollMax
				v5.CurrentRoll += (v11 - v5.CurrentRoll) * math.min(1, 8 * dt)
				local v12 = (prevSpeed - v5.PrevSpeed) / v4
				v5.PrevSpeed = prevSpeed
				local v13 = math.clamp(-v12 * 0.03, -1, 1) * v5.PitchMax
				v5.CurrentPitch += (v13 - v5.CurrentPitch) * math.min(1, 6 * dt)
				v5.RootPart.CFrame = CFrame.new(v5.CurrentPos + Vector3.new(0, v10, 0)) * CFrame.Angles(
					0,
					v5.CurrentAngle + 1.5707963267948966,
					0
				) * CFrame.Angles(v5.CurrentPitch, 0, v5.CurrentRoll)
			end
		end)
	end
}