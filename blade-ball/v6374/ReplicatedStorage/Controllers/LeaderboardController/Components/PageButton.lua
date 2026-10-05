local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.UseNewLobby)()
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Controllers.LeaderboardController.Info)
local v4 = require3(ReplicatedStorage2.Common.Utils.Utilities.FFlag)
local PageButton = {
	Click = function(self, p)
		local page = p.Container:GetAttribute("Page")
		p.SortFrame:SetAttribute("CurrentPage", page)
	end,
	Update = function(self, p)
		local leaderboardName = p.SortFrame:GetAttribute("LeaderboardName")
		local currentPage = p.SortFrame:GetAttribute("CurrentPage") or "AllTime"
		local page = p.Container:GetAttribute("Page")
		local colorPalette = v3.ColorPalettes[leaderboardName]

		if colorPalette then
			if v or v2.isDuelLobbyServer() or v2.isRankedLobbyServer() or v2.isTradingPlazaServer() or v2.isFiftyPlayersServer() then
				local container = p.Container
				local imageColor

				if page == currentPage then
					imageColor = colorPalette.Active
				else
					imageColor = colorPalette.Selected
				end

				container.ImageColor3 = imageColor
				local container2 = p.Container
				local image

				if page == currentPage then
					image = colorPalette.UnselectedImage
				else
					image = colorPalette.SelectedImage
				end

				container2.Image = image
			else
				local textLabel = p.Container:FindFirstChildOfClass("TextLabel")

				if textLabel then
					local textColor

					if page == currentPage then
						textColor = colorPalette.Inactive
					else
						textColor = colorPalette.Active
					end

					textLabel.TextColor3 = textColor
				end

				if p.Container:IsA("ImageButton") then
					local container = p.Container
					local imageColor

					if page == currentPage then
						imageColor = colorPalette.Active
					else
						imageColor = colorPalette.Inactive
					end

					container.ImageColor3 = imageColor
				else
					local container = p.Container
					local backgroundColor

					if page == currentPage then
						backgroundColor = colorPalette.Active
					else
						backgroundColor = colorPalette.Inactive
					end

					container.BackgroundColor3 = backgroundColor
				end
			end
		end
	end
}

function PageButton:Hook(p)
	local page = p.Container:GetAttribute("Page")
	p.SortFrame:GetAttribute("LeaderboardName")
	task.defer(function()
		workspace:WaitForChild("Spawn")
		p.SortFrame:GetAttributeChangedSignal("CurrentSection"):Connect(function()
			PageButton:Update(p)
		end)
		p.SortFrame:GetAttributeChangedSignal("CurrentPage"):Connect(function()
			PageButton:Update(p)
		end)
	end)
	PageButton:Update(p)
	p.Container.Activated:Connect(function()
		PageButton:Click(p)
	end)

	if page == "Monthly" then
		local function updateVisibility()
			p.Container.Visible = v4.GetFFlag("MonthlyLeaderboardEnabled")

			if not p.Container.Visible and p.SortFrame:GetAttribute("CurrentPage") == page then
				p.SortFrame:SetAttribute("CurrentSection", "Global")
				p.SortFrame:SetAttribute("CurrentPage", "AllTime")
			end
		end

		v4.OnChange(updateVisibility)
		task.defer(updateVisibility)
	end
end

function PageButton.Init(_, container)
	local v5 = {
		Container = container,
		Data = {},
		Page = {},
		SortFrame = container.Parent.Parent
	}
	task.spawn(function()
		PageButton:Hook(v5)
	end)
	return v5
end

return PageButton