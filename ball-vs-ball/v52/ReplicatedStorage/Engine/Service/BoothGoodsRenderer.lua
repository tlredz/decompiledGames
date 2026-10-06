local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Engine.Service.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function isValidImageValue(image)
	return typeof(image) == "string" and image ~= "" and string.match(image, "^%a+://") ~= nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function findRatingByLvl(rating: number)
	for _, v in Config.rating.list do
		if v.lvl == rating then
			return v
		end
	end

	return nil
end

local function resolveItemDisplay(itemType: string, itemId: string)
	if itemType == "Ball" then
		local v = Config.ball.byCnId[itemId]

		if not v then
			return nil
		end

		local ratingByLvl = findRatingByLvl(v.rating) -- equivalent call inferred; original call site unknown
		local v2 = {
			name = v.displayName,
			image = 0,
			ratingColor = 0
		}
		local validImageValue = isValidImageValue(v.image) -- equivalent call inferred; original call site unknown
		v2.image = not validImageValue and "" or v.image
		local ratingColor

		if ratingByLvl then
			ratingColor = Color3.fromHex(ratingByLvl.colorHex)
		end

		v2.ratingColor = ratingColor
		return v2
	else
		local v = Config.skin.byCnId[itemId]

		if not v then
			return nil
		end

		local ratingByLvl = findRatingByLvl(v.rating) -- equivalent call inferred; original call site unknown
		local v2 = {
			name = v.name,
			image = 0,
			ratingColor = 0
		}
		local validImageValue = isValidImageValue(v.image) -- equivalent call inferred; original call site unknown
		v2.image = not validImageValue and "" or v.image
		local ratingColor

		if ratingByLvl then
			ratingColor = Color3.fromHex(ratingByLvl.colorHex)
		end

		v2.ratingColor = ratingColor
		return v2
	end
end

return {
	bind = function(parent, instance, callback)
		local size = instance.Size
		assert(parent:FindFirstChildOfClass("UIListLayout"), "商品列表缺少 UIListLayout")
		local flag = true
		local v = {}

		for _, child in parent:GetChildren() do
			if child:GetAttribute("BoothGeneratedGoods") then
				child:Destroy()
			end
		end

		local function resize()
			if not flag then
				return
			end

			local absoluteSize = parent.AbsoluteSize
			local v2 = math.max(1, size.X.Scale * absoluteSize.X + size.X.Offset)
			local v3 = math.max(1, size.Y.Scale * absoluteSize.Y + size.Y.Offset)

			for _, v4 in v do
				v4.cell.Size = UDim2.fromOffset(v2, v3)
			end
		end

		local absoluteSizeChangedConnection = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)
		local v2 = {
			Update = function(_, items)
				if not flag then
					return
				end

				local v3 = {}

				for k, item in items do
					local itemDisplay = resolveItemDisplay(item.itemType, item.itemId)
					local listingId = item.listingId

					if not (itemDisplay and typeof(listingId) == "string") then
						continue
					end

					v3[listingId] = true
					local v4 = v[listingId]

					if not v4 then
						local clone = instance:Clone()
						clone.Name = "商品格" .. k
						clone.Visible = true
						clone:SetAttribute("BoothGeneratedGoods", true)
						clone.Parent = parent
						v4 = {
							cell = clone,
							entry = item
						}
						v[listingId] = v4
						local button = clone:FindFirstChild("购买按钮")

						if button and button:IsA("GuiButton") then
							button.Active = true
							button.Interactable = true
							button.AutoButtonColor = true
							v4.connection = button.Activated:Connect(function()
								if flag then
									callback(v4.entry)
								end
							end)
						end
					end

					v4.entry = item
					local cell = v4.cell
					cell.LayoutOrder = k
					local firstChild = cell:FindFirstChild("名称")
					local label = firstChild and firstChild:FindFirstChild("文字")

					if label and label:IsA("TextLabel") then
						label.Text = itemDisplay.name
					end

					local image = cell:FindFirstChild("商品图片")

					if image and image:IsA("ImageLabel") then
						image.Image = itemDisplay.image
					end

					local uIStroke = cell:FindFirstChild("品质描边")

					if uIStroke and uIStroke:IsA("UIStroke") and itemDisplay.ratingColor then
						uIStroke.Color = itemDisplay.ratingColor
					end

					local firstChild2 = cell:FindFirstChild("购买按钮")
					local label2 = firstChild2 and firstChild2:FindFirstChild("数量")

					if label2 and label2:IsA("TextLabel") then
						label2.Text = tostring(item.price)
					end
				end

				for k, v4 in v do
					if v3[k] then
						continue
					end

					if v4.connection then
						v4.connection:Disconnect()
					end

					v4.cell:Destroy()
					v[k] = nil
				end

				resize()
			end,
			Destroy = function(self)
				if not flag then
					return
				end

				flag = false
				absoluteSizeChangedConnection:Disconnect()

				for _, v3 in v do
					if v3.connection then
						v3.connection:Disconnect()
					end

					v3.cell:Destroy()
				end

				table.clear(v)
			end
		}
		resize()
		return v2
	end
}