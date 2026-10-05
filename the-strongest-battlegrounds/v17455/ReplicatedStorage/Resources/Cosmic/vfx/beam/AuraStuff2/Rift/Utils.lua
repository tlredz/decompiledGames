local createVector = vector.create
local TweenService = game:GetService("TweenService")
local random = Random.new()
local assets = script.Parent:WaitForChild("Assets")

local function GetRandomOrientation()
	return CFrame.Angles(
		math.rad((random:NextNumber(-360, 360))),
		math.rad((random:NextNumber(-360, 360))),
		(math.rad((random:NextNumber(-360, 360))))
	)
end

local function GetShard()
	local shards = script:WaitForChild("Shards")
	local debris = shards:WaitForChild("Debris")
	local riftShards = shards:WaitForChild("RiftShards")
	return debris:GetChildren()[1] or riftShards:GetChildren()[math.random(1, #riftShards:GetChildren())]:Clone()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ReturnShard(p)
	local shards = script:WaitForChild("Shards")
	local debris = shards:WaitForChild("Debris")
	shards:WaitForChild("RiftShards")

	if p.Parent ~= debris then
		p.Parent = debris
	end
end

return {
	Create = function(self, p, p2, p3, color)
		local model = Instance.new("Model")
		model.Parent = self
		local highlight = Instance.new("Highlight")
		highlight.Enabled = false
		highlight.Parent = model
		return {
			CreateShard = function(_, p4)
				local shard = GetShard()
				shard.CFrame = p2 * GetRandomOrientation()
				shard.Size = createVector(0, 0, 0)
				shard.Color = color

				if p4 then
					shard.Parent = model
					shard.Material = Enum.Material.Glass
					shard.Transparency = 15
				else
					shard.Parent = self
					shard.Material = Enum.Material.Neon
					shard.Transparency = 0
				end

				local cFrame = p2 * CFrame.new(
					random:NextNumber(-25, 25) * p,
					random:NextNumber(-35, -5) * p,
					random:NextNumber(-25, 25) * p
				) * GetRandomOrientation()
				local tween = TweenService:Create(
					shard,
					TweenInfo.new(random:NextNumber(0.75, 1.25) * p3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						CFrame = cFrame
					}
				)
				local tween2 = TweenService:Create(
					shard,
					TweenInfo.new(random:NextNumber(0.2, 0.4) * p3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{
						Size = shard:GetAttribute("OriginalSize") * p + Vector3.new(
							random:NextNumber(1, 2),
							random:NextNumber(-0.5, 2),
							random:NextNumber(1, 2)
						) * p
					}
				)
				local tween3 = TweenService:Create(
					shard,
					TweenInfo.new(random:NextNumber(0.3, 0.75) * p3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = createVector(0, 0, 0),
						CFrame = cFrame * GetRandomOrientation()
					}
				)
				tween:Play()
				tween2:Play()
				task.delay(tween.TweenInfo.Time * 1.25, function()
					tween:Destroy()
					tween3:Play()
					task.wait(tween3.TweenInfo.Time)
					tween3:Destroy()
					ReturnShard(shard) -- equivalent call inferred; original call site unknown
				end)
				task.delay(tween2.TweenInfo.Time, function()
					tween2:Destroy()
				end)
			end,
			CreateDistort = function(_)
				local clone = assets.Distort:Clone()
				clone:PivotTo(p2 * CFrame.Angles(0, math.rad((random:NextNumber(-360, 360))), 0))
				clone:ScaleTo(p)
				clone.Parent = model
				local size = clone.PrimaryPart.Size
				clone.PrimaryPart.Size = createVector(0, 0, 0)
				TweenService:Create(
					clone.PrimaryPart,
					TweenInfo.new(0.1 * p3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = size * p
					}
				):Play()
				task.delay(0.35 * p3, function()
					task.wait(0.25 * p3)
					TweenService:Create(
						clone.PrimaryPart,
						TweenInfo.new(2 * p3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					task.wait(2 * p3)
					clone:Destroy()
				end)
			end
		}
	end
}