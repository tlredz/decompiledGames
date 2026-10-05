local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
require(ReplicatedStorage.CUI)
local MovementDebug = require(ReplicatedStorage._FRAMEWORK.Features.MovementDebug)
require(ReplicatedStorage._FRAMEWORK.Features.MovementDebug.Types)
require(script.Parent.Parent.Types)
local color = Color3.fromRGB(150, 164, 196)
local v = {
	neutral = Color3.fromRGB(226, 234, 250),
	good = Color3.fromRGB(120, 235, 150),
	warn = Color3.fromRGB(255, 200, 90),
	bad = Color3.fromRGB(255, 120, 120)
}

local function BuildPage(system, componentCtn)
	local viewerCheckbox = nil
	componentCtn:AddTitle(function(object)
		object:SetTitle(system.label)
	end)

	if system.drawsProbes then
		viewerCheckbox = componentCtn:AddCheckbox(function(object)
			object:SetText("Draw probes"):SetValue(MovementDebug.isViewerEnabled(system.id)):SetYSize(22):SetOnChanged(function(p)
				MovementDebug.setViewerEnabled(system.id, p)
			end)
		end)
	else
		componentCtn:AddText(function(object)
			object:SetText("This system pushes targets, it casts no probes"):SetTextColor(Color3.fromRGB(150, 150, 150)):SetYSize(22)
		end)
	end

	componentCtn:AddSeparator(function(_) end)
	local values = {}

	for k, v4 in system.readRows() do
		local v5 = v4
		local v6 = k
		componentCtn:AddSplit(function(object)
			object:SetLeftSizePercent(0.45)
			object.LeftComponents:AddText(function(object2)
				object2:SetText(v5.label):SetTextColor(color):SetYSize(20)
			end)
			values[v6] = object.RightComponents:AddText(function(object2)
				object2:SetText(v5.value):SetTextColor(v[v5.tone or "neutral"]):SetYSize(20):SetTextXAlignment(Enum.TextXAlignment.Right)
			end)
		end)
	end

	return {
		System = system,
		ViewerCheckbox = viewerCheckbox,
		Values = values
	}
end

local function RenderPage(data)
	local rows = data.System.readRows()

	for k, value in data.Values do
		local row = rows[k]

		if row then
			value:SetText(row.value):SetTextColor(v[row.tone or "neutral"])
		else
			value:SetText("--"):SetTextColor(v.neutral)
		end
	end

	local viewerCheckbox = data.ViewerCheckbox

	if viewerCheckbox and viewerCheckbox:GetValue() ~= MovementDebug.isViewerEnabled(data.System.id) then
		viewerCheckbox:SetValue(MovementDebug.isViewerEnabled(data.System.id))
	end
end

return {
	DisplayName = "Movement",
	Permission = "cui.dev.movement",
	Order = 20,
	Setup = function(object, p)
		if not RunService:IsClient() then
			return
		end

		local systems = MovementDebug.getSystems()

		if #systems == 0 then
			object:AddText(function(object2)
				object2:SetText("MovementDebug has not initialised on this client."):SetYSize(22)
			end)
			return
		end

		local v2 = {}
		local v3 = nil
		object:AddTab(function(object2)
			v3 = object2
			local labels = {}

			for k, system in systems do
				labels[k] = system.label
			end

			object2:SetTabs(labels)

			for _, system in systems do
				v2[system.label] = BuildPage(system, object2:GetComponentCtn(system.label))
			end
		end)
		local v4 = false
		local v5 = 0

		local function CanRender()
			return not v4 and p.isVisible()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function RenderOpenPage()
			local v6 = v2[v3:GetOpenTabName()]

			if v6 then
				RenderPage(v6)
			end
		end

		local heartbeatConnection = RunService.Heartbeat:Connect(function()
			if v4 or not p.isVisible() then
				return
			end

			local now = os.clock()

			if now - v5 < 0.1 then
				return
			end

			v5 = now
			RenderOpenPage() -- equivalent call inferred; original call site unknown
		end)
		local onTabOpenedConnection = v3.OnTabOpened:Connect(RenderOpenPage)
		local visibilityChangedConnection = p.visibilityChanged:Connect(function(p2)
			local v6 = p2 and v2[v3:GetOpenTabName()]

			if v6 then
				RenderPage(v6)
			end
		end)
		v3:GetUI().Destroying:Connect(function()
			v4 = true
			heartbeatConnection:Disconnect()
			onTabOpenedConnection:Disconnect()
			visibilityChangedConnection:Disconnect()
			table.clear(v2)
		end)
		RenderOpenPage() -- equivalent call inferred; original call site unknown
	end
}