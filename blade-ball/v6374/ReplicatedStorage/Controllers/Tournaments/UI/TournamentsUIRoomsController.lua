local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.Utils)
local v = require3(ReplicatedStorage2.Packages.Trove)
local v2 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.TournamentData)
require3(ReplicatedStorage2.Shared.MapData)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v3 = require3(tournaments.TournamentsController)
local v4 = require3(tournaments.UI.TournamentsUIController)
local _ = Players.LocalPlayer
local scrollingFrame = v4.TabsFolder.Rooms.ScrollingFrame
local template = scrollingFrame.UIListLayout.Template
local maid = v.new()
local TournamentsUIRoomsController = {}

function TournamentsUIRoomsController:RenderList(list)
	maid:Clean()
	scrollingFrame.NoRoomsAvailable.Visible = #list <= 0

	for k, v5 in list do
		local v6 = maid:Add(template:Clone())
		v6.LayoutOrder = k
		v6.RoomName.Text = v5.name
		v6.Location.Text = v5.region
		v6.PlayerCount.Text = `{#v5.playersInRoom}/{v5.players}`
		v6.PlayerCount.TextColor3 = #v5.playersInRoom >= v5.players and Color3.fromRGB(245, 80, 80) or Color3.new(
			1,
			1,
			1
		)
		v6.JoinButton.Visible = true
		v6.SpectateButton.Visible = false
		v6.Parent = scrollingFrame
		local v7 = v5
		maid:Add(v6.JoinButton.Activated:Connect(function()
			v3.Remotes.JoinTournamentRoom:InvokeServer(v7.partitionKey, false)
		end))
	end
end

function TournamentsUIRoomsController:UpdateRooms()
	maid:Clean()
	local v5, v6 = v3.Remotes.SearchTournamentRooms:InvokeServer()

	if not v5 then
		return
	end

	self:RenderList(v6)
end

function TournamentsUIRoomsController:Start()
	v2:OnGuiOpen("Tournaments", function()
		self:UpdateRooms()
	end)
end

return TournamentsUIRoomsController