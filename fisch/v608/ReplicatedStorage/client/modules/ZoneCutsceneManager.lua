local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local ZoneCutsceneManager = {}
local cutscenes = script.Cutscenes
local module = require("@self/CutscenePlayer")
local remoteEvent = Net:RemoteEvent("ZoneCutsceneService/SetInCutscene")
local TesterSettingsController = require(ReplicatedStorage.client.legacyControllers.TesterSettingsController)
local NotificationController = require(ReplicatedStorage.client.legacyControllers.NotificationController)
local v = {}

local function getCutsceneRuntime(data)
	local total = 0

	if data.SEGMENTS then
		for _, v2 in ipairs(data.SEGMENTS) do
			total += v2.duration or 0
		end
	end

	if data.FINAL_FADE_OUT_TIME then
		total += data.FINAL_FADE_OUT_TIME
	end

	if data.FINAL_HOLD_TIME then
		total += data.FINAL_HOLD_TIME
	end

	return total
end

function ZoneCutsceneManager:PlayCutsceneForDiscovery(childName, childName2, p)
	if v[childName] then
		return false
	end

	local moduleScript = cutscenes:FindFirstChild(childName) or cutscenes:FindFirstChild(childName2)

	if not (moduleScript and moduleScript:IsA("ModuleScript")) then
		return false
	end

	if TesterSettingsController:GetSettingValue("disableZoneCutscenes") and not p then
		NotificationController:FancyNotify({
			Components = {
				{
					Type = "Text",
					Text = `Zone discovery cutscene for "{childName2}" skipped by QA setting`
				},
				{
					Type = "Button",
					Text = "Play Anyways",
					OnClick = function()
						ZoneCutsceneManager:PlayCutsceneForDiscovery(childName, childName2, true)
					end,
					DismissOnClick = true
				}
			}
		})
		return false
	end

	if not ReplicatedStorage:GetAttribute("LoadingScreenFinished") then
		ReplicatedStorage:GetAttributeChangedSignal("LoadingScreenFinished"):Wait()
	end

	local module2 = require(moduleScript)
	local total = 0

	if module2.SEGMENTS then
		for _, v2 in ipairs(module2.SEGMENTS) do
			total += v2.duration or 0
		end
	end

	if module2.FINAL_FADE_OUT_TIME then
		total += module2.FINAL_FADE_OUT_TIME
	end

	if module2.FINAL_HOLD_TIME then
		total += module2.FINAL_HOLD_TIME
	end

	remoteEvent:FireServer(true)
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function releaseProtection()
		if flag then
			return
		end

		flag = true
		remoteEvent:FireServer(false)
	end

	task.delay(total, releaseProtection)
	local success, result = pcall(function()
		return module.PlayCutscene(module2)
	end)

	if success and result then
		v[childName] = true
		return true
	end

	releaseProtection() -- equivalent call inferred; original call site unknown
	return false
end

return ZoneCutsceneManager