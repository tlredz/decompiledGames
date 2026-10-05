local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CreateTween = require(ReplicatedStorage.Packages.CreateTween)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local Animals = require(ReplicatedStorage.Shared.Animals)
local remoteFunction = Net:RemoteFunction("AdminboardService/ListCycle")
return {
	Start = function(_)
		local v = remoteFunction:InvokeServer()
		Observers.observeTag("Adminboard", function(instance)
			local maid = Trove.new()
			local surfaceGui = instance.SurfaceGui
			surfaceGui.Parent = Players.LocalPlayer.PlayerGui
			maid:Add(surfaceGui)
			local slots = surfaceGui.EventChosen.Slots
			local slots2 = surfaceGui.LuckMulti.Slots
			local slots3 = surfaceGui.Item.Slots

			local function createSlider(slots4, p: number)
				local v2 = nil
				local v3 = maid:Add(Instance.new("NumberValue"))
				v3.Value = 1
				v3.Changed:Connect(function(p2)
					slots4.Frame.Position = UDim2.fromScale(-((p2 - 1) % p), 0.5)
				end)
				return function(p2: number, flag: boolean?)
					if v2 then
						v2:Cancel()
						v2 = nil
					end

					v3.Value = 0
					local v4 = p * 8 + p2 - v3.Value % p

					if flag then
						v3.Value = v4
					else
						v2 = CreateTween(v3, TweenInfo.new(4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
							Value = v4
						})
					end
				end
			end

			local slider = createSlider(slots, #v.Events)
			local slider2 = createSlider(slots2, #v.Luck)
			local slider3 = createSlider(slots3, #v.Items)

			for i = 1, #v.Events + 1 do
				local event = v.Events[(i - 1) % #v.Events + 1]
				local clone = slots.Frame.UIListLayout.Entry:Clone()
				clone.LayoutOrder = i
				clone.Image = event.Icon or "rbxassetid://17451423471"
				clone.Parent = slots.Frame
			end

			for i = 1, #v.Luck + 1 do
				local v2 = v.Luck[(i - 1) % #v.Luck + 1]
				local clone = slots2.Frame.UIListLayout.Entry:Clone()
				clone.LayoutOrder = i
				clone.Image = v2.Icon or "rbxassetid://17451423471"
				clone.Parent = slots2.Frame
			end

			for i = 1, #v.Items + 1 do
				local item = v.Items[(i - 1) % #v.Items + 1]
				local clone = slots3.Frame.UIListLayout.Entry:Clone()
				clone.LayoutOrder = i
				local v2 = Animals:AttachOnViewport(item.Name, clone, true, nil, true)

				if v2 then
					maid:Add(v2)
				end

				clone.Parent = slots3.Frame
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateEvent(flag: boolean?)
				local event = instance:GetAttribute("Event")

				if event then
					slider(event, flag)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateLuck(flag: boolean?)
				local luck = instance:GetAttribute("Luck")

				if luck then
					slider2(luck, flag)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateItem(flag: boolean?)
				local item = instance:GetAttribute("Item")

				if item then
					slider3(item, flag)
				end
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function updateSpinningIn()
				local spinningIn = instance:GetAttribute("SpinningIn") == true
				slots.Visible = not spinningIn
				surfaceGui.EventChosen.Mark.Visible = spinningIn
				slots2.Visible = not spinningIn
				surfaceGui.LuckMulti.Mark.Visible = spinningIn
				slots3.Visible = not spinningIn
				surfaceGui.Item.Mark.Visible = spinningIn
			end

			maid:Add(instance:GetAttributeChangedSignal("SpinningIn"):Connect(updateSpinningIn))
			updateSpinningIn() -- equivalent call inferred; original call site unknown
			maid:Add(instance:GetAttributeChangedSignal("Event"):Connect(updateEvent))
			updateEvent(true) -- equivalent call inferred; original call site unknown
			maid:Add(instance:GetAttributeChangedSignal("Luck"):Connect(updateLuck))
			updateLuck(true) -- equivalent call inferred; original call site unknown
			maid:Add(instance:GetAttributeChangedSignal("Item"):Connect(updateItem))
			updateItem(true) -- equivalent call inferred; original call site unknown
			return maid:WrapClean()
		end, { workspace })
	end
}