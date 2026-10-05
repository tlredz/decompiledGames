local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SplitFieldsCountdown"
})
local v2 = {
	"Days",
	"Hours",
	"Minutes",
	"Seconds"
}

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	local v3 = {}

	for _, v4 in v2 do
		local frame = self.Instance[v4]
		v3[v4] = {
			frame = frame,
			number = frame.Number
		}
	end

	local anyMomentNow = self.Instance.AnyMomentNow

	local function readEndUnix()
		local splitFieldsCountdownTargetTime = self.Instance:GetAttribute("SplitFieldsCountdownTargetTime")

		if typeof(splitFieldsCountdownTargetTime) == "number" then
			return splitFieldsCountdownTargetTime
		end

		return nil
	end

	local splitFieldsCountdownTargetTime = self.Instance:GetAttribute("SplitFieldsCountdownTargetTime")

	if typeof(splitFieldsCountdownTargetTime) ~= "number" then
		splitFieldsCountdownTargetTime = nil
	end

	self._Janitor:Add(self.Instance:GetAttributeChangedSignal("SplitFieldsCountdownTargetTime"):Connect(function()
		local splitFieldsCountdownTargetTime2 = self.Instance:GetAttribute("SplitFieldsCountdownTargetTime")

		if typeof(splitFieldsCountdownTargetTime2) ~= "number" then
			splitFieldsCountdownTargetTime2 = nil
		end

		splitFieldsCountdownTargetTime = splitFieldsCountdownTargetTime2
	end))
	local v4 = {}
	local v5 = nil

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyFinished(visible: boolean)
		if v5 == visible then
			return
		end

		v5 = visible

		for _, v6 in v3 do
			v6.frame.Visible = not visible
		end

		anyMomentNow.Visible = visible
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function setField(p2: string, p3: number)
		local text = string.format("%02d", p3)

		if v4[p2] == text then
			return
		end

		v4[p2] = text
		v3[p2].number.Text = text
	end

	self._Janitor:Add(RunService.Heartbeat:Connect(function()
		local serverTimeNow = workspace:GetServerTimeNow()

		if not (typeof(serverTimeNow) == "number" and splitFieldsCountdownTargetTime ~= nil) then
			return
		end

		local v6 = math.max(0, splitFieldsCountdownTargetTime - serverTimeNow)
		local visible = v6 <= 0
		applyFinished(visible) -- equivalent call inferred; original call site unknown

		if visible then
			return
		end

		local v8 = math.max(0, (math.floor(v6 + 0.5)))
		local v9 = math.floor(v8 / 86400)
		local v10 = v8 - v9 * 86400
		local v11 = math.floor(v10 / 3600)
		local v12 = v10 - v11 * 3600
		local v13 = math.floor(v12 / 60)
		local v14 = v12 - v13 * 60
		setField("Days", v9) -- equivalent call inferred; original call site unknown
		setField("Hours", v11) -- equivalent call inferred; original call site unknown
		setField("Minutes", v13) -- equivalent call inferred; original call site unknown
		setField("Seconds", v14) -- equivalent call inferred; original call site unknown
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v