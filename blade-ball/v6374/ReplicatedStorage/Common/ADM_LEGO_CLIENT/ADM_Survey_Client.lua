local ADMSurveyClient = {}
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local v = nil
local aDMSurvey = nil
local areAdsAllowed = nil
local flag = false
local v2 = game.Players.LocalPlayer.UserId == 3339860557 or game.Players.LocalPlayer.UserId == 7658109668

local function devPrint(...)
	if v2 then
		print("[AdMonitor DEV]", ...)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function checkValidSetup()
	if script:WaitForChild("AdTechSurveyUI", 20) then
		return true
	end

	if RunService:IsStudio() then
		warn("[AdMonitor]: No survey UI inside the SDK! Please update your AdMonitor installer plugin and re-install the tech.")
	end

	devPrint("Missing Survey UI!")
end

local function isPlayerAgeAppropriate()
	if areAdsAllowed ~= nil then
		return areAdsAllowed
	end

	areAdsAllowed = PolicyService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer).AreAdsAllowed
	return areAdsAllowed
end

function ADMSurveyClient.handleActiveSurveys(p)
	devPrint("Reading active surveys")

	if flag then
		devPrint("Already read active surveys.")
		return
	end

	flag = true

	for k, survey in p.surveys do
		if not survey.age_restricted then
			continue
		end

		if areAdsAllowed == nil then
			areAdsAllowed = PolicyService:GetPolicyInfoForPlayerAsync(game.Players.LocalPlayer).AreAdsAllowed
		end

		if areAdsAllowed then
			continue
		end

		devPrint("Local player isn't old enough for this survey: ", k)
		p.surveys[k] = nil
	end

	devPrint("Iterating npcs:")

	for k, npc in p.npcs do
		devPrint("NPC", k)
		local count = #npc.surveys

		if count == 0 then
			devPrint("No surveys assigned to NPC", k)
		else
			local survey = npc.surveys[math.random(count)]
			devPrint("ChosenSurvey", survey)
			local v3 = p.surveys[survey] and #p.surveys[survey].question_sets or 0

			if v3 == 0 then
				devPrint("No question sets for chosen survey", survey)
			else
				local question_set = p.surveys[survey].question_sets[math.random(v3)]
				v.addQuestionSet(question_set)
				v.addNpc(k, npc, question_set.uuid)
				devPrint("Added NPC and question set")
			end
		end
	end

	devPrint("Finished looping npcs")
	v.addedNpcs()
	devPrint("Finished reading active surveys")
end

function ADMSurveyClient.init()
	devPrint("Initing")

	-- equivalent call inferred; original call site unknown
	if not checkValidSetup() then
		devPrint("Invalid setup")
		return
	end

	devPrint("Waiting for survey remote event")
	aDMSurvey = game.ReplicatedStorage:WaitForChild("ADM-Survey")
	devPrint("Requiring and initing NpcHandler")
	local NpcHandler = require(script:WaitForChild("NpcHandler"))
	v = NpcHandler
	v.init()
	devPrint("Conecting and firing survey event")
	aDMSurvey.OnClientEvent:Connect(ADMSurveyClient.handleActiveSurveys)
	aDMSurvey:FireServer("GetConversations")
	devPrint("Init over")
end

return ADMSurveyClient