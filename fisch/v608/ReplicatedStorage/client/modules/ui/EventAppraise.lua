local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("SoundService")
local legacyControllers = ReplicatedStorage:WaitForChild("client").legacyControllers
require(legacyControllers.DataController)
local CurrencyController = require(legacyControllers.CurrencyController)
local EventAppraiseButton = require(script.EventAppraiseButton)
local packages = ReplicatedStorage:WaitForChild("packages")
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local modules = ReplicatedStorage:WaitForChild("shared").modules
require(modules.library.fish)
local EventAppraise = require(modules.EventAppraise)
local v = Trove.new()
local eventAppraise = Players.LocalPlayer.PlayerGui:WaitForChild("EventAppraise")
local eventAppraise2 = eventAppraise.EventAppraise
local defaultWeight = 0
local v2 = {}
local v3 = {}
local remoteEvent = Net:RemoteEvent("EventAppraiseService/Complete", -1)
local remoteEvent2 = Net:RemoteEvent("EventAppraiseService/RequestAppraiseUI", -1)
local remoteEvent3 = Net:RemoteEvent("EventAppraiseService/StartAppraise", -1)
local remoteEvent4 = Net:RemoteEvent("EventAppraiseService/CancelAppraise", -1)
local remoteFunction = Net:RemoteFunction("EventAppraiseService/SelectIndex", -1)
local remoteEvent5 = Net:RemoteEvent("EventAppraiseService/TakeNow", -1)
local EventAppraise2 = {}

local function GetModifiersMultiplier(p)
	local v4 = p or v2
	local v5 = 1

	for i = 1, #v4 do
		v5 *= v4[i]
	end

	return v5
end

local function GetWeight(p: number?, p2)
	local v4 = p or defaultWeight
	local v5 = p2 or v2
	local v6 = 1

	for i = 1, #v5 do
		v6 *= v5[i]
	end

	return v4 * v6
end

function EventAppraise2:Toggle(enabled: boolean?)
	if enabled == nil and eventAppraise.Enabled == true then
		return
	end

	if enabled == nil then
		enabled = not eventAppraise.Enabled
	end

	if enabled == eventAppraise.Enabled then
		return
	end

	if enabled == true then
		EventAppraise2:SetStage("Preview")
	else
		remoteEvent4:FireServer()
	end

	eventAppraise.Enabled = enabled
end

function EventAppraise2:SetStage(p: string, data)
	v:Clean()
	table.clear(v2)
	eventAppraise2.Tip.Visible = p == "Selection"

	if p == "Preview" then
		eventAppraise2.Weight.Visible = false
		eventAppraise2.Header.Weight.Visible = false
		eventAppraise2.Appraise.Visible = false
		eventAppraise2.TakeNow.Visible = false

		for i = 1, EventAppraise.SlotAmount do
			local v4 = EventAppraiseButton.new()
			v4:SetParent(eventAppraise2.List)
			v3[i] = v4
			v:Add(v4, "Destroy")
		end
	elseif p == "Selection" then
		eventAppraise2.Appraise.Visible = false
		eventAppraise2.TakeNow.Visible = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateWeightLabel()
			local v4 = defaultWeight
			local v5 = v2
			local v6 = 1

			for i = 1, #v5 do
				v6 *= v5[i]
			end

			local v7 = math.round(v4 * v6 * 100) / 100
			local v8

			if v7 % 1 == 0 then
				v8 = tostring(v7)
			else
				v8 = string.format("%.2f", v7)
			end

			eventAppraise2.Weight.Text = `Total: {v8} kg`
			eventAppraise2.Weight.Visible = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateWeightModifierLabel()
			local v4 = v2
			local v5 = 1

			for i = 1, #v4 do
				v5 *= v4[i]
			end

			local v6

			if v5 % 1 == 0 then
				v6 = tostring(v5)
			else
				v6 = string.format("%.2f", v5)
			end

			eventAppraise2.Header.Weight.Text = `{v6}x kg`
			eventAppraise2.Header.Weight.Visible = true
		end

		UpdateWeightLabel() -- equivalent call inferred; original call site unknown
		UpdateWeightModifierLabel() -- equivalent call inferred; original call site unknown

		for i = 1, EventAppraise.SlotAmount do
			local v4 = EventAppraiseButton.new()
			v4:SetParent(eventAppraise2.List)
			local v5 = i
			v4:SetActivatedCallback(function()
				local v7 = remoteFunction:InvokeServer(v5)

				if v7 ~= nil then
					table.insert(v2, v7)
					v4:SetModifier(v7)
					v4:SetState("Unlocked")
					UpdateWeightLabel() -- equivalent call inferred; original call site unknown
					UpdateWeightModifierLabel() -- equivalent call inferred; original call site unknown

					if v7 == EventAppraise.SuccessModifier[#EventAppraise.SuccessModifier] then
						script.Gold:Play()
						eventAppraise2.TakeNow.Visible = true
					elseif v7 >= 1 then
						eventAppraise2.TakeNow.Visible = true
						script.Success:Play()
					else
						script.Fail:Play()
					end
				end
			end)
			v3[i] = v4
			v:Add(v4, "Destroy")
		end
	elseif p == "Result" then
		script.Finish:Play()
		eventAppraise2.Appraise.Visible = true
		eventAppraise2.TakeNow.Visible = false

		local function UpdateWeightLabel()
			local defaultWeight2 = data.Item.sub.DefaultWeight or data.Item.sub.Weight
			local selectedList = data.SelectedList
			local v4 = defaultWeight2 or defaultWeight
			local v5 = selectedList or v2
			local v6 = 1

			for i = 1, #v5 do
				v6 *= v5[i]
			end

			local v7 = math.round(v4 * v6 * 100) / 100
			local v8

			if v7 % 1 == 0 then
				v8 = tostring(v7)
			else
				v8 = string.format("%.2f", v7)
			end

			eventAppraise2.Weight.Text = `Total: {v8} kg`
			eventAppraise2.Weight.Visible = true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function UpdateWeightModifierLabel()
			local selectedList = data.SelectedList or v2
			local v4 = 1

			for i = 1, #selectedList do
				v4 *= selectedList[i]
			end

			local v5

			if v4 % 1 == 0 then
				v5 = tostring(v4)
			else
				v5 = string.format("%.2f", v4)
			end

			eventAppraise2.Header.Weight.Text = `{v5}x kg`
			eventAppraise2.Header.Weight.Visible = true
		end

		UpdateWeightLabel()
		UpdateWeightModifierLabel() -- equivalent call inferred; original call site unknown

		for i = 1, EventAppraise.SlotAmount do
			local v4 = EventAppraiseButton.new()
			v4:SetParent(eventAppraise2.List)
			v4:SetSelected(table.find(data.SelectedIndex, i) ~= nil)
			v4:SetModifier(data.List[i])
			v4:SetState("Unlocked")
			v3[i] = v4
			v:Add(v4, "Destroy")
		end
	end
end

function EventAppraise2:Appraise(p)
	defaultWeight = p.sub.DefaultWeight or p.sub.Weight
	EventAppraise2:SetStage("Selection")
end

function EventAppraise2.init()
	remoteEvent2.OnClientEvent:Connect(function(...)
		EventAppraise2:Toggle(...)
	end)
	remoteEvent3.OnClientEvent:Connect(function(...)
		EventAppraise2:Appraise(...)
	end)
	remoteEvent.OnClientEvent:Connect(function(p)
		EventAppraise2:SetStage("Result", p)
	end)
	eventAppraise2.Close.Activated:Connect(function()
		EventAppraise2:Toggle(false)
	end)
	local appraise = eventAppraise2.Appraise
	appraise.Activated:Connect(function()
		remoteEvent3:FireServer()
	end)
	appraise.coins.Text = `{EventAppraise.Price} {CurrencyController:GetDisplay(EventAppraise.Currency)}`
	eventAppraise2.TakeNow.Activated:Connect(function()
		remoteEvent5:FireServer()
	end)
	EventAppraise2:Toggle(false)
end

return EventAppraise2