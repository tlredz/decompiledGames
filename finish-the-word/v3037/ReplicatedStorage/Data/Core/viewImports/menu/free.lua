local import = _G.import("romodel")
local import2 = _G.import("iterator")
local import3 = _G.import("viewImports")
local basic = import3:get("basic")
local menu = import3:get("menu")
local page = import3:get("dailyQuests").Page
local v = { "playTime", "daily", "group" }
local v2 = {
	"playTime",
	"daily",
	"group",
	"dailyQuests"
}
local v3 = {
	playTime = {
		DisplayName = "Play Time",
		Icon = "Time"
	},
	daily = {
		DisplayName = "Daily",
		Icon = "Cash"
	},
	group = {
		DisplayName = "Group",
		Icon = "Flag"
	},
	dailyQuests = {
		DisplayName = "Daily Quests",
		Icon = "Tasks",
		Page = page
	}
}
local model = import.model(menu.Button)

function model.init(p)
	return {
		Text = v3[p.Id].DisplayName,
		Size = UDim2.new(0.3, 0, 1, 0),
		MouseButton1Down = function(p2)
			p2.Ui:openPage(p2.Id)
		end
	}
end

local model2 = import.model(basic.EmptyList)

function model2.init()
	return {
		Position = UDim2.new(0.27, 0, 0.048, 0),
		Size = UDim2.new(0.6, 0, 0.1, 0),
		Padding = UDim.new(0.05, 0),
		HorizontalAlignment = Enum.HorizontalAlignment.Center
	}, import2.mapArr(v, function(p, id)
		return p, import.make(model, {
			Id = id
		})
	end)
end

local model3 = import.model("Frame")

function model3.init()
	return {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.03, 0, 0.185, 0),
		Size = UDim2.new(0.94, 0, 0.765, 0)
	}, import2.mapArr(v2, function(p, p2)
		local page2 = import3:get(p2).Page
		return p2, import.make(page2, {
			Visible = p == 2
		})
	end)
end

function model3.spawn(pages)
	pages.Ui.Pages = pages
end

local model4 = import.model(menu.PagesList)

function model4.init()
	return {
		Pages = {
			{
				Id = "dailyQuests",
				Label = v3.dailyQuests.DisplayName,
				Icon = v3.dailyQuests.Icon,
				Page = v3.dailyQuests.Page,
				OpenPage = function(p, p2)
					p.Ui:openPage(p2)
				end
			}
		}
	}
end

local model5 = import.model(menu.MenuContainer)

function model5.init()
	return {
		Title = "Perks"
	}, {
		MenuButtons = import.make(model2),
		PagesList = import.make(model4),
		Content = import.make(model3)
	}
end

local model6 = import.model("ScreenGui", basic.Ui, menu.Menu)

function model6.getExclamPages()
	return { page }
end

function model6.init()
	return {
		IgnoreGuiInset = true,
		Name = "Perks",
		DisplayOrder = 5,
		Scale = 0.55,
		MinSize = 500,
		AspectRatio = 1.777,
		Location = "Center",
		Content = {
			Main = import.make(model5)
		}
	}
end

function model6:openPage(p2)
	for _, guiObject in pairs(self.Pages:GetChildren()) do
		if not guiObject:IsA("GuiObject") then
			return
		end

		guiObject.Visible = false
	end

	self.Pages[p2].Visible = true
end

return {
	Free = model6
}