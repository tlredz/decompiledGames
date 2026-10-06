local createVector = vector.create
local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf
	local root = data.Root

	if not char then
		return
	end

	tick()
	local v = 0.5

	local function CreateTrails(value, value2, position, p, p2, value3)
		local step = value2 or 15
		local v3 = value or 15
		local v4 = value3 or 2
		local v5 = p or { (Color3.fromRGB(255, 255, 255)) }
		local v6 = v5[math.random(1, #v5)]
		local clone

		if p2 and math.random(1, v4) == v4 then
			clone = script.Trails.Trail2:Clone()
			clone.Attachment1.Trail.WidthScale = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.3, v3 * 0.01),
				NumberSequenceKeypoint.new(1, 0)
			})
		else
			clone = script.Trails.Trail:Clone()
		end

		clone.Attachment1.Trail.LightEmission = 0.5
		clone.CFrame = CFrame.new(position) * CFrame.new(
			math.random(-v3, v3),
			math.random(-v3, v3),
			math.random(-v3, v3)
		)
		clone.Attachment1.Trail.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, v6),
			ColorSequenceKeypoint.new(1, v6)
		})
		clone.Parent = workspace.Effects

		if v6 == Color3.fromRGB(0, 0, 0) then
			clone.Attachment1.Trail.LightEmission = 0
			clone.Attachment1.Trail.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
		end

		coroutine.wrap(function()
			local position2 = clone.Position
			local v7 = position
			local v9 = (position2 + v7) / 2 + Vector3.new(
				math.random(-v3, v3),
				math.random(-v3, v3),
				math.random(-v3, v3)
			)
			PeodizService.ForLoop({
				Step = step
			}, function(p3)
				local v10 = math.floor(p3 * step) / step
				local position3 = position2
				local v12 = position3 + (v9 - position3) * v10
				local v13 = v9
				clone.Position = v12 + (v13 + (v7 - v13) * v10 - v12) * v10
				v7 = position
			end)
			_G.PU:Dust(clone, clone.Attachment1.Trail.Lifetime)
		end)()
	end

	local v2 = { Color3.fromRGB(204, 93, 18), (Color3.fromRGB(0, 0, 0)) }
	local clone = replicatedStorage.Chest.SwordEffect.AncientSword.Thrust.ball:Clone()
	clone.CFrame = root.CFrame * CFrame.new(0, 0, -5)
	clone.Size = Vector3.new()
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 11)
	TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(2, 2, 2) * v
	}):Play()
	local weld = Instance.new("Weld")
	weld.Parent = clone
	weld.Part0 = root
	weld.Part1 = clone
	weld.C0 = CFrame.new(0, 0, -5)
	_G.PU:Dust(weld, 11)
	local lastTime = tick()
	PeodizService.HeartbeatWait({
		Time = 8,
		WaitTime = 0.075
	}, function()
		if not char:IsDescendantOf(workspace.PlayerCharacters) then
			return true
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not (humanoidRootPart and char:FindFirstChild("ancient_charge")) then
			return true
		end

		if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 15 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallestBump")
		end

		local _ = humanoidRootPart.CFrame
		CreateTrails(15, 12, (humanoidRootPart.CFrame * CFrame.new(0, 0, -5)).p, v2)

		if tick() - lastTime > 0.5 then
			v = math.min(v + 0.25, 1.5)
			lastTime = tick()
			TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(2, 2, 2) * v
			}):Play()
		end
	end)

	if clone then
		TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 0)
		}):Play()
		_G.PU:Dust(clone, 1)
	end
end