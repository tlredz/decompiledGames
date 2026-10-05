_G.import("iterator")
local import = _G.import("romodel")
local import2 = _G.import("iconData")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local avatar = import3:get("avatar").Avatar
local DataStoreService = game:GetService("DataStoreService")
local v = {}
local now = 0
local v2 = {
	Cash = {
		DisplayName = "MOST CASH",
		Color = Color3.fromRGB(81, 230, 58)
	},
	Streak = {
		DisplayName = "HIGHEST STREAK",
		Color = Color3.fromRGB(230, 60, 60)
	},
	Wins = {
		DisplayName = "MOST WINS",
		Color = Color3.fromRGB(230, 230, 60)
	}
}

local function fetchUserName(key)
	if v[key] then
		return v[key]
	end

	for _ = 1, 5 do
		local v3 = 0.5 - (os.clock() - now)

		if v3 > 0 then
			task.wait(v3)
		end

		now = os.clock()
		local success, result = pcall(function()
			return game.Players:GetNameFromUserIdAsync(key)
		end)

		if success then
			v[key] = result
			return result
		end

		if tostring(result):find("429") then
			task.wait(5)
		else
			v[key] = "invalid user"
			return "invalid user"
		end
	end

	return "invalid user"
end

local wrapped = import.wrap(basic.Corner, basic.Stroke)
local model = import.model(basic.EmptyList)

function model.init(data)
	local _ = v2[data.Id]
	local userName = data.UserName or "invalid user"
	return {
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Size = UDim2.new(1, 0, 0.06, 0),
		Padding = UDim.new(0.025, 0)
	}, {
		RankLabel = import.make(wrapped, {
			BackgroundColor3 = Color3.fromRGB(2, 194, 197),
			Size = UDim2.new(0.14, 0, 1, 0),
			StrokeWidth = 3,
			CornerRadius = UDim.new(0.1, 0),
			LayoutOrder = 1
		}, {
			TextLabel = import.make(basic.TextLabel, {
				LayoutOrder = 1,
				Location = "Center",
				Size = UDim2.new(1, 0, 0.7, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = "#" .. data.Order,
				StrokeWidth = 2
			})
		}),
		PlayerAvatar = import.make(wrapped, {
			Size = UDim2.new(0.0745, 0, 1, 0),
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(2, 194, 197),
			CornerRadius = UDim.new(0.1, 0),
			StrokeWidth = 3,
			LayoutOrder = 2
		}, {
			Avatar = import.make(avatar, {
				Location = "Center",
				Size = UDim2.new(1.1, 0, 1.1, 0),
				CornerRadius = UDim.new(0.1, 0),
				UserId = data.UserId
			})
		}),
		Username = import.make(wrapped, {
			BackgroundColor3 = Color3.fromRGB(2, 194, 197),
			LayoutOrder = 3,
			Size = UDim2.new(0.45, 0, 1, 0),
			StrokeWidth = 3,
			CornerRadius = UDim.new(0.1, 0)
		}, {
			TextLabel = import.make(basic.TextLabel, {
				Location = "Center",
				Size = UDim2.new(0.825, 0, 0.7, 0),
				Text = "@" .. string.upper(userName),
				StrokeWidth = 2
			})
		}),
		Count = import.make(wrapped, {
			BackgroundColor3 = Color3.fromRGB(2, 194, 197),
			LayoutOrder = 4,
			Size = UDim2.new(0.25, 0, 1, 0),
			StrokeWidth = 3,
			CornerRadius = UDim.new(0.1, 0)
		}, {
			Icon = import.make(basic.ImageLabel, {
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.1, 0, 0.5, 0),
				Size = UDim2.new(1.1, 0, 1.1, 0),
				Image = import2[data.Id]
			}),
			TextLabel = import.make(basic.TextLabel, {
				LayoutOrder = 3,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.475, 0, 0.5, 0),
				Size = UDim2.new(1.4, 0, 0.7, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = data.Value,
				StrokeWidth = 2
			})
		})
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	return {
		Face = Enum.NormalId.Right,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0.0175, 0)
	}
end

function model2:render()
	local id = self.Ui.Id
	local orderedDataStore = DataStoreService:GetOrderedDataStore("Leaderboard/" .. id)
	local success, result = pcall(function()
		return orderedDataStore:GetSortedAsync(false, 10)
	end)
	local v3 = {}

	if success then
		local count = 0
		local count2 = 0
		local v4 = {}

		while count < 5 do
			count += 1
			local currentPage = result:GetCurrentPage()

			for _, v5 in pairs(currentPage) do
				count2 += 1
				table.insert(v4, {
					key = v5.key,
					value = v5.value,
					order = count2
				})
			end

			if count >= 5 or result.IsFinished then
				break
			else
				result:AdvanceToNextPageAsync()
			end
		end

		for _, v5 in ipairs(v4) do
			local key = tonumber(v5.key)

			if not v[key] then
				fetchUserName(key)
			end
		end

		for _, v5 in ipairs(v4) do
			local key = tonumber(v5.key)
			table.insert(v3, import.make(model, {
				Id = id,
				Order = v5.order,
				UserId = key,
				Value = v5.value,
				UserName = v[key] or "invalid user"
			}))
		end

		for _, guiObject in pairs(self._Children) do
			if guiObject:IsA("GuiObject") then
				guiObject:Destroy()
			end
		end
	end

	local v4 = math.max(self.Parent.Size.Y.Scale, #v3 * 0.0775)
	self.Size = UDim2.new(1, -6, 1 / v4, 0)
	self.Parent.CanvasSize = UDim2.new(0, 0, v4, 0)
	import.apply(self, nil, v3)
end

function model2:prespawn()
	task.defer(function()
		self.Con = true

		while self.Con do
			self:render()
			task.wait(480)
		end
	end)
end

function model2:despawn()
	self.Con = false
end

local model3 = import.model(wrapped)

function model3.init(p)
	local v3 = v2[p.Id]
	return {
		StrokeWidth = 8,
		BackgroundColor3 = v3.Color
	}, {
		LeftIcon = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0.03, 0, 0.5, 0),
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Image = import2[p.Id]
		}),
		RightIcon = import.make(basic.ImageLabel, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(0.97, 0, 0.5, 0),
			Size = UDim2.new(0.6, 0, 0.6, 0),
			Image = import2[p.Id]
		}),
		Title = import.make(basic.TextLabel, {
			Location = "Center",
			Size = UDim2.new(1, 0, 0.5, 0),
			Text = v3.DisplayName,
			StrokeWidth = 4
		})
	}
end

local model4 = import.model("SurfaceGui", basic.Ui)

function model4.init(p)
	local _ = v2[p.Id]
	return {
		Face = Enum.NormalId.Back,
		Id = p.Id,
		CanvasSize = Vector2.new(15, 18.5) * 40
	}, {
		Wrapper = import.make(import.wrap(basic.List, basic.Corner, basic.Padding), {
			BackgroundColor3 = Color3.new(1, 1, 1),
			Location = "Center",
			Size = UDim2.new(0.98, 0, 0.98, 0),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.025, 0),
			PaddingTop = UDim.new(0.03, 0)
		}, {
			Title = import.make(model3, {
				Size = UDim2.new(0.95, 0, 0.13, 0),
				Id = p.Id
			}),
			ScrollingFrame = import.make("ScrollingFrame", {
				ScrollBarThickness = 0,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.97, 0, 0.842, 0),
				CanvasSize = UDim2.new(0, 0, 2, 0)
			}, {
				PlayersFrame = import.make(model2, {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 4),
					Id = p.Id,
					Size = UDim2.new(1, -6, 0.5, 0)
				})
			})
		})
	}
end

return {
	Leaderboard = model4
}