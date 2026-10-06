local BallCopySelection = require(game.ReplicatedStorage.Engine.Service.BallCopySelection)
local BallUpgradeRules = require(game.ReplicatedStorage.Engine.Service.BallUpgradeRules)
local AssetLibrary = require(game.ReplicatedStorage.Engine.Service.AssetLibrary)
local BallCardQuality = require(game.ReplicatedStorage.Engine.Service.BallCardQuality)
local Config = require(game.ReplicatedStorage.Engine.Service.Config)
local templateNames = BallCardQuality.templateNames
return {
	bind = function(parent, p, p2)
		local v = p2 or parent:WaitForChild("名称文本")
		local clones = {}

		for k, templateName in templateNames do
			local clone = AssetLibrary.Clone("小球卡片品质", templateName)
			clone.Name = templateName .. "名称文本"
			clone.AnchorPoint = v.AnchorPoint
			clone.Position = v.Position
			clone.Size = v.Size
			clone.SizeConstraint = v.SizeConstraint
			clone.Rotation = v.Rotation
			clone.LayoutOrder = v.LayoutOrder
			clone.ZIndex = v.ZIndex
			clone.Visible = false
			clone.Parent = v.Parent
			clones[k] = clone
		end

		local clone = AssetLibrary.Clone("击杀统计", "左对齐击杀数")
		clone.Name = "击杀数"
		clone.Visible = false

		for _, v2 in {
			"AnchorPoint",
			"Position",
			"Size",
			"SizeConstraint",
			"Rotation",
			"LayoutOrder",
			"ZIndex"
		} do
			clone[v2] = p[v2]
		end

		local firstChild = parent:FindFirstChild("击杀数")

		if firstChild then
			firstChild:Destroy()
		end

		clone.Parent = parent
		local v2 = clone:WaitForChild("数值")
		return {
			showBall = function(p3, text, options, p4)
				local v3 = options or {}
				local resolved = BallCopySelection.resolve(v3, p4, p3)
				local v4 = resolved and v3[resolved]
				local v5

				if v4 and BallCopySelection.available(v4) then
					v5 = v4
				end

				local kind = BallCardQuality.kind(v5, Config.ball.byCnId[p3])
				v.Visible = false

				for k, v6 in clones do
					v6.Text = text
					v6.Visible = k == kind
				end

				clone.Visible = v5 ~= nil and BallUpgradeRules.kind(v5) ~= "Classic"
				local v8

				if v4 then
					v8 = BallUpgradeRules.killCount(v4)
				end

				v2.Text = tostring((math.max(0, (math.floor(typeof(v8) ~= "number" and 0 or v8))))):reverse():gsub(
					"(%d%d%d)",
					"%1,"
				):reverse():gsub(
					"^,",
					""
				)
				return kind
			end,
			showUpgrade = function()
				clone.Visible = false

				for _, v3 in clones do
					v3.Visible = false
				end

				v.Visible = true
			end
		}
	end
}