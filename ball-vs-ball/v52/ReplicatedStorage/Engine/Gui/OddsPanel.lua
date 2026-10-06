local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)
local GachaPool = require(ReplicatedStorage.Engine.Service.GachaPool)
local ConfirmDialogController = require(script.Parent.ConfirmDialogController)
local flag = false
local v = nil
local v2 = nil

local function ratingColor(rating: number?)
	for _, v3 in Config.rating.list do
		if v3.lvl == rating then
			return Color3.fromHex(v3.colorHex)
		end
	end

	return Color3.new(1, 1, 1)
end

local function prepareTemplate(instance)
	if v then
		return v
	end

	local v3 = instance:WaitForChild("物品模板")
	v3.Parent = nil

	for _, button in instance:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	v = v3
	return v3
end

local function paintCard(clone, data, p: number)
	local definition = data.definition
	local color = ratingColor(definition.rating)
	local firstChild = clone:FindFirstChild("物品图标")

	if firstChild then
		firstChild.Image = definition.image or ""
	end

	local firstChild2 = clone:FindFirstChild("名称")
	local v4 = firstChild2 and firstChild2:FindFirstChild("文字")

	if v4 then
		v4.Text = definition.displayName or definition.name or data.row.targetId
	end

	for _, v5 in { clone, firstChild2 } do
		local uIStroke = v5 and v5:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Color = color
		end
	end

	local firstChild3 = clone:FindFirstChild("概率")

	if firstChild3 then
		firstChild3.Text = string.format("%.2f%%", not (p > 0) and 0 or data.weight / p * 100)
	end

	local firstChild4 = clone:FindFirstChild("解锁提示")

	if firstChild4 then
		firstChild4.Visible = false
	end

	clone.Visible = true
end

local function render(instance, p: string)
	local parent = instance:WaitForChild("奖池")
	local v4 = prepareTemplate(parent)

	for _, button in parent:GetChildren() do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	local chances, v5 = GachaPool.getChances(p)
	local v6 = nil
	local chances2 = {}

	for _, chance in chances do
		if chance.unlockAt then
			v6 = math.min(v6 or 1e999, chance.unlockAt)
		end

		if chance.weight > 0 and chance.definition then
			table.insert(chances2, chance)
		end
	end

	if #chances2 == 0 then
		warn((`[OddsPanel] 奖池 {p} 没有可展示的物品`))
	end

	table.sort(chances2, function(a, b)
		local rating = a.definition.rating or 0
		local rating2 = b.definition.rating or 0

		if rating == rating2 then
			return a.weight < b.weight
		end

		return rating2 < rating
	end)

	for k, v7 in chances2 do
		local clone = v4:Clone()
		clone.Name = "物品" .. k
		clone.LayoutOrder = k
		paintCard(clone, v7, v5)
		clone.Parent = parent
	end

	parent.CanvasPosition = Vector2.zero
	return v6
end

return {
	Open = function(p: string, p2: string?)
		if flag then
			return
		end

		flag = true
		ConfirmDialogController.Enqueue("查看概率面板", {
			category = "Odds",
			onShown = function(instance, callback)
				local firstChild = instance:FindFirstChild("标题")

				if firstChild then
					v2 = v2 or firstChild.Text
					firstChild.Text = p2 or v2
				end

				local v3 = true
				local v4 = render(instance, p)

				local function refresh()
					if v3 and instance.Visible then
						v4 = render(instance, p)
					end
				end

				local v5 = GachaPool.observeLocalUnlocks(refresh)
				task.spawn(function()
					local TimeService = require(ReplicatedStorage.Engine.Service.TimeService)

					while v3 and instance.Parent and v4 do
						task.wait(1)

						if not (v3 and v4) then
							continue
						end

						local now = TimeService.now()

						if v4 <= now and v3 and instance.Visible then
							v4 = render(instance, p)
						end
					end
				end)
				local v6 = instance:WaitForChild("确定按钮")
				local connection = nil
				connection = ConfirmDialogController.BindButton(v6, "A", function()
					v3 = false
					v5()
					connection:Disconnect()
					flag = false
					callback()
				end)
			end
		})
	end
}