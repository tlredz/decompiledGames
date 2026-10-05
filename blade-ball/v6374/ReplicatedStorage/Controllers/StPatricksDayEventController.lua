local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Shared.UniverseIds)
local v2 = require3(ReplicatedStorage2.Common.RewardInfo)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
require3(ReplicatedStorage2.Packages.Net)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v7 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v8 = require3(ReplicatedStorage2.Shared.StPatricksDayEventData)
local v9 = nil
local v10 = nil
local frame = Players.LocalPlayer.PlayerGui.StPatricksDayEvent.Frame
local fill = frame.Progression.Bar.Holder.Fill
local label = frame.Progression.Bar.Holder.Label
local StPatricksDayEventController = {}

function StPatricksDayEventController:GetEndTime()
	return v6:IsDataReady() and v6:GetKey("StPatricksDayEventEndTime") or 1742659200
end

function StPatricksDayEventController:GetRemaining()
	return self:GetEndTime() - workspace:GetServerTimeNow()
end

function StPatricksDayEventController:IsActive()
	if game.PlaceId == v.Default.PlaceId or game.PlaceId == v.MobileServers.PlaceId then
		return self:GetRemaining() > 0
	end

	return false
end

function StPatricksDayEventController:HasLuck()
	local v11 = v9 or v3.Client:GetReplion("Data")

	if v11 and self:IsActive() then
		return v11:Get("StPatricksDayEvent.HasLuck") == true
	end

	return false
end

function StPatricksDayEventController:Update()
	if not (v10:Get("Loaded") and v6:IsDataReady() and self:IsActive() and v5:IsOpen("StPatricksDayEvent")) then
		return
	end

	local key = v6:GetKey("StPatricksEventGlobalMilestones")
	local key2 = v6:GetKey("StPatricksEventLocalMilestones")

	if type(key) ~= "table" or type(key2) ~= "table" then
		return
	end

	local v11 = v10:Get({ "Values", (`StPatricksDayEventClovers_{v8.VERSION}`) })

	if not v11 then
		return
	end

	local v12 = v9:Get("StPatricksDayEvent.Clover") or 0

	for _, guiObject in frame.Progression.Bar.Items:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local name = tonumber(guiObject.Name)

		if not (type(name) == "number" and name == name) then
			continue
		end

		local v13 = key2[name]
		local v14 = key[name]

		if not (type(v13) == "number" and type(v14) == "number") then
			continue
		end

		local info = guiObject.Info
		info.Visible = v12 < v13 and v14 <= v11
		guiObject.Info.Label.Text = `Contribute 💥 {v4.ValueConvertor:AddCommas(v13)}`
		guiObject.Label.Text = v4.ValueConvertor:ShrinkNumber(v14)
		guiObject.Holder.Lock.Visible = guiObject.Info.Visible
		local check = guiObject.Holder.Check
		check.Visible = v9:Find("StPatricksDayEvent.Rewards", name) ~= nil and not guiObject.Holder.Lock.Visible
	end

	local count = #key
	local total = 0

	for i = 1, count do
		local v13 = key[i - 1] or 0
		local v14 = key[i]

		if v11 <= v13 then
			break
		else
			total += math.min((v11 - v13) / (v14 - v13), 1) / count
		end
	end

	fill.Size = UDim2.fromScale(total, 1)
	label.Position = UDim2.fromScale(math.max(total - 0.02, label.Size.X.Scale + 0.02), 0.5)
	label.Text = v4.ValueConvertor:ShrinkNumber(v11)
	frame.YouContributed.TextLabel.Text = `You Contributed: 💥 {v4.ValueConvertor:ShrinkNumber(v12)}`
end

function StPatricksDayEventController:Start()
	v9 = v3.Client:WaitReplion("Data")
	v10 = v3.Client:WaitReplion("GlobalNumbers")
	frame.Close.Activated:Connect(function()
		v5:Close("StPatricksDayEvent")
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		self:Update()
	end

	v5:OnGuiOpen("StPatricksDayEvent", function()
		if self:IsActive() then
			update() -- equivalent call inferred; original call site unknown
		else
			v5:Close("StPatricksDayEvent")
		end
	end)
	v10:OnChange("Values", update)
	v10:OnChange("Loaded", update)
	v4.Thread.Every(1, update)
	task.spawn(update)
	v7:AddFromRewardInfo(frame.Progression.Bar.Items["2"].Holder.Vector, v2.createSwordReward("Viridian Edge"))

	if not v10:Get("Loaded") then
		frame.Loading.Visible = true
		local top = frame.Loading.RadialBar.Top
		local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
			top.Rotation += dt * 60 * 3
		end)
		v10:OnChange("Loaded", function(p)
			if p then
				frame.Loading.Visible = false
				postSimulationConnection:Disconnect()
			end
		end)
	end
end

return StPatricksDayEventController