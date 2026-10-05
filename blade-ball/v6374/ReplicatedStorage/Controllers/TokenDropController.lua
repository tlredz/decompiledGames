local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Common.Utils)
local v4 = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Shared.FastUtils)
local localPlayer = Players.LocalPlayer
local remoteEvent = v2:RemoteEvent("SpawnToken")
local remoteEvent2 = v2:RemoteEvent("CollectToken")
local remoteEvent3 = v2:RemoteEvent("DestroyToken")
local remoteEvent4 = v2:RemoteEvent("UpdateTokenPosition")
local remoteFunction = v2:RemoteFunction("CanClaimToken")
local v5 = {}
local TokenDropController = {}
local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = "Players"
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = { workspace.Runtime, workspace.Alive, workspace.Dead }

function TokenDropController:ClaimToken(data)
	local model = data.Model
	local trove = data.Trove

	if not (model and trove) then
		self:DestroyToken(data)
		return
	end

	if model:GetAttribute("Claimed") then
		return
	end

	model:SetAttribute("Claimed", true)
	remoteEvent2:FireServer(data.ID)
	v3.Sounds:Play("CollectToken")
	local pivot = localPlayer.Character and localPlayer.Character:GetPivot()

	if pivot then
		local tween = TweenService:Create(model, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
			CFrame = CFrame.new(pivot.Position)
		})
		trove:Add(tween)
		trove:Add(tween.Completed:Once(function()
			local clone = ReplicatedStorage2.Assets.TokenDropVFX:Clone()
			clone.CFrame = pivot
			clone.Parent = workspace.Runtime
			self:DestroyToken(data)
			Debris:AddItem(clone, (v3.Visual:PlayEffects(clone)))
		end))
		tween:Play()
	else
		self:DestroyToken(data)
	end

	local glow = model:FindFirstChild("Center") and model.Center:FindFirstChild("Glow")

	if glow then
		glow.Enabled = false
	end
end

function TokenDropController:CreateToken(state)
	local maid = v4.new()
	local child = state.CustomTokenModel and ReplicatedStorage2.Assets:FindFirstChild(state.CustomTokenModel)
	local clone

	if child then
		clone = child:Clone()
	elseif state.Reward.Type == "LimitedEgg" then
		clone = ReplicatedStorage2.Assets:WaitForChild("LimitedEggUGC"):Clone()
		clone.Size *= 2
	else
		clone = ReplicatedStorage2.Assets:WaitForChild("TokenDrop"):Clone()
	end

	clone.Name = `Token-{state.ID}`
	clone.Token.Icon.Image = state.Reward.Icon or ""
	clone.Parent = workspace.Runtime
	state.Model = clone
	state.Trove = maid
	self:UpdatePosition(state)
	maid:AttachToInstance(clone)
	maid:Add(clone.Touched:Connect(function(otherPart)
		if localPlayer.Character and otherPart:IsDescendantOf(localPlayer.Character) and not clone:GetAttribute("Claimed") and remoteFunction:InvokeServer(state.ID) then
			self:ClaimToken(state)
		end
	end))
	v5[state.ID] = state
end

function TokenDropController:DestroyToken(p)
	if p.Model then
		p.Model:Destroy()
	end

	v5[p.ID] = nil
end

function TokenDropController:UpdatePosition(state)
	local model = state.Model

	if not model then
		return
	end

	local v6 = state.Reward.Type == "LegoBrick"
	local v7 = model.Size.Y / 2
	local v8 = v7 + 0.25
	local raycastResult = workspace:Raycast(
		state.SpawnPivot.Position + createVector(0, 1, 0) * v8,
		createVector(-0, -30, -0),
		raycastParams
	)

	if raycastResult and raycastResult.Instance then
		v8 -= raycastResult.Distance - v7
	end

	local v9 = state.SpawnPivot * CFrame.new(0, v8, 0)
	model:PivotTo(v9)
	local v10 = 3
	local v11 = 5

	if v6 then
		model.Token.Size = UDim2.fromScale(1.75, 1.75)
		v10 *= 1.25
		v11 *= 1.25
	end

	local random = Random.new()
	local number = random:NextNumber(v10, v11)
	local number2 = random:NextNumber(v10, v11)

	if random:NextNumber() < 0.5 then
		number *= -1
	end

	if random:NextNumber() < 0.5 then
		number2 *= -1
	end

	local v12 = v9.Position + Vector3.new(number, 0, number2)

	if state.TweenPop then
		state.Trove:Remove(state.TweenPop)
	end

	if state.TweenOut then
		state.Trove:Remove(state.TweenOut)
	end

	local tween = TweenService:Create(model, TweenInfo.new(0.15, Enum.EasingStyle.Cubic), {
		CFrame = CFrame.new(v9.Position + Vector3.new(
			random:NextNumber(0.2, 0.4) * number,
			random:NextNumber(8, 11),
			random:NextNumber(0.2, 0.4) * number2
		))
	})
	state.Trove:Add(tween)
	tween:Play()
	state.TweenPop = tween
	task.delay(0.10999999999999999, function()
		local cframe = CFrame.new(v12)
		local tween2 = TweenService:Create(
			model,
			TweenInfo.new(random:NextNumber(0.2, 0.3), Enum.EasingStyle.Sine, Enum.EasingDirection.In),
			{
				CFrame = cframe
			}
		)
		state.Trove:Add(tween2)
		tween2:Play()
		state.TweenOut = tween2
	end)
end

function TokenDropController:Start()
	remoteEvent.OnClientEvent:Connect(function(p)
		self:CreateToken(p)
	end)
	remoteEvent3.OnClientEvent:Connect(function(p: string)
		local v6 = v5[p]

		if not v6 or v6.Model and v6.Model:GetAttribute("Claimed") then
			return
		end

		self:DestroyToken(v6)
	end)
	remoteEvent4.OnClientEvent:Connect(function(p: string, spawnPivot: CFrame)
		local v6 = v5[p]

		if not (v6 and v6.Model) or v6.Model and v6.Model:GetAttribute("Claimed") then
			return
		end

		v6.SpawnPivot = spawnPivot
		self:UpdatePosition(v6)
	end)
	v3.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()

		for k, v6 in pairs(v5) do
			if v6.Expiration < serverTimeNow then
				if v6.Model then
					v6.Model:Destroy()
				end

				v5[k] = nil
			elseif v6.Expiration - 2 < serverTimeNow and v6.Model and not v6.Model:GetAttribute("FadingOut") then
				v6.Model:SetAttribute("FadingOut", true)
				local tween = TweenService:Create(v6.Model.Token.Icon, TweenInfo.new(2), {
					ImageTransparency = 1
				})
				v6.Trove:Add(tween)
				tween:Play()
				local center = v6.Model:FindFirstChild("Center")

				if center then
					center.Glow.Enabled = false
				end
			end
		end
	end)

	if v.isDungeonsMatchServer() then
		workspace:GetAttributeChangedSignal("Dungeons_CurrentZone"):Connect(function()
			for _, v6 in pairs(v5) do
				self:ClaimToken(v6)
			end
		end)
	else
		ReplicatedStorage2.Remotes.RoundEnded.OnClientEvent:Connect(function(p)
			if not (p and p.winners and table.find(p.winners, localPlayer)) then
				return
			end

			task.wait(3)

			for _, v6 in pairs(v5) do
				if v6.Reward.Type ~= "LegoBrick" then
					continue
				end

				if remoteFunction:InvokeServer(v6.ID) then
					self:ClaimToken(v6)
				end

				task.wait()
			end
		end)
	end
end

return TokenDropController