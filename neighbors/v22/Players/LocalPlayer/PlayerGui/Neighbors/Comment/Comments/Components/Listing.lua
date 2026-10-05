local Listing = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Network = require(ReplicatedStorage.Modules.Network)
local TableUtil = require(ReplicatedStorage.Modules.TableUtil)
require(ReplicatedStorage.Assets.Data.Comment.Types)
local module = require("./Slot")
local module2 = require("./Filter")
local frame = script:FindFirstAncestorOfClass("Frame")
local list = frame.List
local corner = frame.Corner
local _ = frame.Options

-- equivalent calls inferred from this helper; original call sites unknown
local function safeCancel(_thread: thread)
	pcall(task.cancel, _thread)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isAtBottomOfPage()
	return math.abs(list.CanvasPosition.Y - (list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)) < 30
end

function Listing.new(player)
	local object = setmetatable({}, {
		__index = Listing
	})
	object.Player = player
	object.Slots = {}
	object.QueryRequest = {
		SearchText = corner.Search.Input.Text,
		FlipDirection = module2:GetProperty("SortDirection") == "Ascending",
		Type = module2:GetProperty("SortType"),
		Cursor = nil
	}
	object.Index = 0
	object._fetching = false
	object._finished = false
	object._destroyed = false
	object._thread = task.delay(0.1, function()
		while true do
			-- equivalent call inferred; original call site unknown
			if isAtBottomOfPage() then
				object:Fetch()
			end

			task.wait(0.3)
		end
	end)
	return object
end

function Listing:Add(p)
	if self._destroyed or self.Slots[p.Name] then
		return
	end

	local v = module.new(p)
	v.Container.LayoutOrder = self.Index * 20
	self.Slots[p.Name] = v

	if p.Pinned then
		v.Container.LayoutOrder -= 10000

		if not list:FindFirstChild("Break") then
			local clone = script.Break:Clone()
			clone.LayoutOrder = -9000
			clone.Parent = list
		end
	end

	self.Index += 1
	v.Container.Parent = list
	v:AddReplies()
end

function Listing:Fetch()
	if self._fetching or self._finished or typeof(self.Player) == "Instance" and not self.Player:IsDescendantOf(Players) then
		return
	end

	print("fetching...", self.QueryRequest)
	self._fetching = true

	if not next(self.Slots) then
		frame.Loading.Visible = true
		frame.Empty.Visible = false
	end

	print(self.Player)
	local v = typeof(self.Player) == "Instance" and "Comment/RequestComments" or "Comment/ForceRequestComments"
	local v2 = Network:invoke(v, v == "Comment/RequestComments" and self.Player or self.Player.Name, self.QueryRequest)

	if v2 then
		print("received", v2)

		if #v2.Items == 0 then
			self._finished = true
		end

		self.QueryRequest.Cursor = v2.Cursor
		print("new cursor", v2.Cursor)

		for _, item in next, v2.Items, nil do
			self:Add(item)
		end
	end

	frame.Loading.Visible = false
	frame.Empty.Visible = TableUtil.count(self.Slots) == 0
	print("fetched!")
	self._fetching = false
end

function Listing:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	for _, slot in next, self.Slots, nil do
		slot:Destroy()
	end

	local firstChild = list:FindFirstChild("Break")

	if firstChild then
		firstChild:Destroy()
	end

	table.clear(self.Slots)
	safeCancel(self._thread) -- equivalent call inferred; original call site unknown
end

return Listing