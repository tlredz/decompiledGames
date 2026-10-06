local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EffectPlayer = require(ReplicatedStorage.Engine.Service.EffectPlayer)
local Config = require(ReplicatedStorage.Engine.Service.Config)
local v = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("小球牌子")
local clonesByName = {}
local DuelAimBallBadge = {}

local function formatNumber(value: number)
	return (string.format("%d", (math.max(0, (math.floor(value))))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	))
end

local function prepareTemplates()
	for _, model in ipairs(v:GetChildren()) do
		if not model:IsA("Model") then
			continue
		end

		local clone = model:Clone()
		local part = clone:FindFirstChild("碰撞箱")

		if part and part:IsA("BasePart") then
			for _, descendant in ipairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.Anchored = false
					descendant.CanCollide = false
					descendant.CanQuery = false
					descendant.Massless = true
				elseif descendant:IsA("Sound") and descendant.RollOffMaxDistance > 50 then
					warn(string.format(
						"[DuelAimBallBadge] %s 的 RollOffMaxDistance %.1f 超过 50，已限制为 50",
						descendant:GetFullName(),
						descendant.RollOffMaxDistance
					))
					descendant.RollOffMaxDistance = 50
				end
			end

			clone.PrimaryPart = part
			part.Anchored = true
			clonesByName[model.Name] = clone
		else
			warn(string.format("[DuelAimBallBadge] 牌子缺少碰撞箱: %s", model:GetFullName()))
			clone:Destroy()
		end
	end
end

prepareTemplates()

function DuelAimBallBadge.attach(parent, cframe: CFrame, p: string, value: number?, value2: number?)
	if typeof(value) ~= "number" then
		return nil
	end

	local v2

	if typeof(value2) == "number" then
		local v3 = Config.ball.byCnId[p]
		v2 = v3 and v3.isSpecial == true and "特殊击杀数+编号牌子" or "击杀数+编号牌子"
	else
		v2 = "击杀数牌子"
	end

	local v3 = clonesByName[v2]

	if not v3 then
		warn(string.format("[DuelAimBallBadge] 找不到预处理牌子: %s", v2))
		return nil
	end

	local clone = v3:Clone()
	local primaryPart = clone.PrimaryPart
	local attachment = primaryPart and primaryPart:FindFirstChild("朝向标记")

	if primaryPart and attachment and attachment:IsA("Attachment") then
		local firstChild = clone:FindFirstChild("文本")
		local v4 = firstChild and firstChild:FindFirstChild("列表")
		local v5 = v4 and v4:FindFirstChild("击杀数")
		local label = v5 and v5:FindFirstChild("数值")

		if label and label:IsA("TextLabel") then
			label.Text = formatNumber(value)

			if typeof(value2) == "number" then
				local v6 = v4 and v4:FindFirstChild("编号")
				local label2 = v6 and v6:FindFirstChild("数值")

				if label2 and label2:IsA("TextLabel") then
					label2.Text = "#" .. formatNumber(value2)
				else
					warn("[DuelAimBallBadge] 击杀数+编号牌子缺少编号文本")
					clone:Destroy()
					return nil
				end
			end

			clone.Parent = parent
			clone:PivotTo(cframe * attachment.CFrame:Inverse() * primaryPart.PivotOffset)
			local v6 = EffectPlayer.playAndHold(clone, nil, 0.98)
			task.delay(3, function()
				v6:destroy()
			end)
			return v6
		else
			warn(string.format("[DuelAimBallBadge] %s 缺少击杀数文本", v2))
			clone:Destroy()
			return nil
		end
	else
		warn(string.format("[DuelAimBallBadge] %s 缺少碰撞箱朝向标记", v2))
		clone:Destroy()
		return nil
	end
end

return DuelAimBallBadge