local BallQualityTextStyle = require(game.ReplicatedStorage.Engine.Service.BallQualityTextStyle)
local CopiesView = {}
local v = "All"
local v2 = {
	"全部筛选",
	"经典筛选",
	"闪光筛选",
	"彩虹筛选"
}
local v3 = {
	"All",
	"Classic",
	"Shiny",
	"Rainbow"
}
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = {}
local v8 = false

function CopiesView.Kind(p)
	if not p then
		return "Classic"
	end

	if typeof(p.serial) == "number" then
		return "Rainbow"
	end

	if typeof(p.killCount) == "number" then
		return "Shiny"
	end

	return "Classic"
end

function CopiesView:ApplyKindStyle(text)
	self.Text = text
	BallQualityTextStyle.apply(self, text)
end

function CopiesView.Reset()
	v = "All"
end

function CopiesView.Filter(list, p)
	if not p then
		v = "All"
	end

	local v9 = {
		All = #list,
		Classic = 0,
		Shiny = 0,
		Rainbow = 0
	}
	local result = {}

	for _, v10 in list do
		local kind = CopiesView.Kind(v10)
		v9[kind] += 1

		if v == "All" or kind == v then
			table.insert(result, v10)
		end
	end

	for k, v10 in v2 do
		local v11 = v5[v10]
		v11.Visible = p or k == 1
		v11["文字组"]["文字"].Text = v3[k]
		v11["文字组"]["数量"].Text = tostring(v9[v3[k]])
		v11.BackgroundColor3 = v11:GetAttribute(v == v3[k] and "SelectedColor" or "DefaultColor")
	end

	return result
end

function CopiesView.Init(p, callback, callback2, p2)
	v8 = p2
	v4 = p
	v5 = p["副本标题栏"]
	v6 = p["右框"]

	for k, v9 in {
		Classic = "经典筛选",
		Shiny = "闪光筛选",
		Rainbow = "彩虹筛选"
	} do
		BallQualityTextStyle.apply(v5[v9]["文字组"]["文字"], k)
	end

	for _, guiObject in v6:GetChildren() do
		if guiObject:IsA("GuiObject") then
			v7[guiObject] = {
				Position = guiObject.Position,
				Size = guiObject.Size,
				AnchorPoint = guiObject.AnchorPoint
			}
		end
	end

	v7[v6["物品图标"]] = {
		Position = UDim2.fromScale(0.05, 0.085),
		Size = UDim2.fromScale(0.9, 0.255),
		AnchorPoint = Vector2.zero
	}
	v7[v6["详细描述"]] = {
		Position = UDim2.fromScale(0.06, 0.34),
		Size = UDim2.fromScale(0.88, 0.1),
		AnchorPoint = Vector2.zero
	}
	v7[v6["描述分隔线"]] = {
		Position = UDim2.fromScale(0.06, 0.455),
		Size = UDim2.fromScale(0.88, 0.003),
		AnchorPoint = Vector2.zero
	}
	v7[v6["装备按钮"]] = {
		Position = UDim2.fromScale(0.505, 0.6225),
		Size = UDim2.fromScale(0.84, 0.12),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	v7[v6["升级按钮"]] = {
		Position = UDim2.fromScale(0.5, 0.9),
		Size = UDim2.fromScale(0.84, 0.12),
		AnchorPoint = Vector2.new(0.5, 0.5)
	}
	local ButtonActions = require(game.ReplicatedStorage.Engine.Service.GamepadSupport.ButtonActions)
	local GamepadSupport = require(game.ReplicatedStorage.Engine.Service.GamepadSupport)

	for k, v9 in v2 do
		local v10 = v5[v9]
		callback(v10)
		local v12 = k
		ButtonActions.Bind(v10, function()
			if not GamepadSupport.CanActivate(v10) then
				return
			end

			v = v3[v12]
			callback2()
		end)
	end
end

function CopiesView.Detail(p, visible, p2)
	local v9 = not p and "Classic" or CopiesView.Kind(p)
	local v10 = v6[(not visible or v9 == "Classic") and "升级按钮" or v9 == "Shiny" and "合成彩虹按钮" or "最高形态按钮"]

	for _, v11 in { "合成彩虹按钮", "最高形态按钮" } do
		v6[v11].Visible = false
	end

	v6.Position = UDim2.fromScale(0.87993741, visible and 0.56 or 0.5)
	v6.Size = UDim2.fromScale(0.240125149, visible and 0.88 or 1)

	for k, v11 in v7 do
		for k2, v12 in v11 do
			k[k2] = v12
		end
	end

	v6["副本属性"].Visible = p2 and visible and p ~= nil
	v6["副本击杀数"].Visible = false
	v6["装备按钮"]["文字"].Text = "Equip"
	v6["装备按钮"].AnchorPoint = Vector2.new(0.5, 0.5)
	local v11 = v6["装备按钮"]
	local position

	if visible then
		position = UDim2.fromScale(0.5, 0.72)
	else
		position = UDim2.fromScale(0.505, 0.6225)
	end

	v11.Position = position
	v10.AnchorPoint = Vector2.new(0.5, 0.5)
	v10.Position = UDim2.fromScale(0.5, 0.9)
	v10.Size = UDim2.fromScale(0.84, 0.12)
	v6["升级按钮"]["合成文字"].Text = visible and "Fuse" or "Upgrade"
	v6["升级按钮"]["品质文字"].Visible = visible

	if p2 then
		if not visible then
			return
		end

		v6["升级按钮"].Visible = false
		v6["物品图标"].Position = UDim2.fromScale(0.05, 0.075)
		v6["物品图标"].Size = UDim2.fromScale(0.9, 0.265)
		v6["副本属性"].Position = UDim2.fromScale(0.06, 0.34)
		v6["详细描述"].Position = UDim2.fromScale(0.06, 0.415)
		v6["详细描述"].Size = UDim2.fromScale(0.88, 0.235)
		v6["描述分隔线"].Position = UDim2.fromScale(0.06, 0.4)
		v10.Visible = p ~= nil

		if not v8 or v9 == "Rainbow" then
			v10.Active = false
			v10.Interactable = false
			v10.Selectable = false
			v10.BackgroundColor3 = Color3.fromRGB(92, 98, 112)
		end

		v6["拥有数量"].Visible = false
		v6["分类数量"].Visible = false
		v6["当前装备"].Visible = false
		v6["未拥有详细描述区"].Visible = false
		v6["副本状态"].Visible = false
		v6["详情分隔线"].Visible = false

		if not p then
			return
		end

		CopiesView.ApplyKindStyle(v6["副本属性"], v9)
		v6["详细描述"].Text = typeof(p.config.detailDesc) ~= "string" and "" or p.config.detailDesc
	else
		for _, v13 in { "升级按钮", "合成彩虹按钮", "最高形态按钮" } do
			v6[v13].Visible = false
		end

		v6["详细描述"].Visible = false
		v6["描述分隔线"].Visible = false
		v6["品质"].Position = UDim2.fromScale(0.05, 0.35)
		v6["拥有数量"].Position = UDim2.fromScale(0.07, 0.475)
		v6["当前装备"].Position = UDim2.fromScale(0.5, 0.58)
		v6["装备按钮"].Position = UDim2.fromScale(0.5, 0.72)
		v6["查看副本按钮"].Position = UDim2.fromScale(0.5, 0.89)

		if visible then
			v6["拥有数量"].Visible = false
			v6["当前装备"].Visible = false
		end
	end
end

return CopiesView