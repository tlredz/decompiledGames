local SimpleTest = require(game.ReplicatedStorage.Packages.SimpleTest)
local Groups = require(script.Parent.Groups)
local v = {
	{
		Method = "folderMapValid"
	},
	{
		Method = "resolveDefault"
	},
	{
		Method = "mappedFolderName"
	},
	{
		Method = "unmappedFolderName"
	},
	{
		Method = "missingFolderName"
	},
	{
		Method = "resolveAttribute"
	},
	{
		Method = "resolveBadAttribute"
	},
	{
		Method = "parsePositional"
	},
	{
		Method = "parseOptions"
	},
	{
		Method = "duckMin"
	},
	{
		Method = "duckSetting"
	},
	{
		Method = "compressorRules"
	},
	{
		Method = "soundServiceGroups"
	},
	{
		Method = "storageRouting"
	}
}
return SimpleTest.Test.new({ SimpleTest.Parameter.Choose.new("TestCase", v, function(p)
		return p.Method
	end) }, function(p)
	if p.Method == "folderMapValid" then
		for _, v2 in Groups.Config.FolderToGroup do
			if not Groups.isGroupName(v2) then
				return false
			end
		end

		return Groups.isGroupName(Groups.Config.DefaultGroup)
	else
		if p.Method == "resolveDefault" then
			local stringValue = Instance.new("StringValue")
			return Groups.resolveTemplateGroup(stringValue, Instance.new("Folder")) == Groups.Config.DefaultGroup
		end

		if p.Method == "mappedFolderName" then
			return Groups.groupForFolderName("Ambience") == "LowPriority" and Groups.groupForFolderName("JingleBells") == "LowPriority" and Groups.groupForFolderName("Gacha") == "HighPriority" and Groups.groupForFolderName("UI") == "HighPriority"
		elseif p.Method == "unmappedFolderName" then
			return Groups.groupForFolderName("ValentinesEvent") == "HighPriority" and Groups.groupForFolderName("TrialSounds") == "HighPriority" and Groups.groupForFolderName("WeatherSounds") == "HighPriority" and Groups.groupForFolderName("CampfireSFX") == "HighPriority"
		else
			if p.Method == "missingFolderName" then
				return Groups.groupForFolderName(nil) == Groups.Config.DefaultGroup
			end

			if p.Method == "resolveAttribute" then
				local stringValue = Instance.new("StringValue")
				stringValue:SetAttribute("SoundGroup", "LowPriority")
				return Groups.resolveTemplateGroup(stringValue, Instance.new("Folder")) == "LowPriority"
			elseif p.Method == "resolveBadAttribute" then
				local stringValue = Instance.new("StringValue")
				stringValue:SetAttribute("SoundGroup", "NotAGroup")
				return Groups.resolveTemplateGroup(stringValue, Instance.new("Folder")) == Groups.Config.DefaultGroup
			elseif p.Method == "parsePositional" then
				local playOptions = Groups.parsePlayOptions(30, 1.2, 0.8, 0.5)
				return playOptions.radius == 30 and playOptions.speed == 1.2 and playOptions.volume == 0.8 and playOptions.fadeIn == 0.5 and playOptions.group == nil
			elseif p.Method == "parseOptions" then
				local playOptions = Groups.parsePlayOptions({
					group = "HighPriority",
					volume = 0.4
				})
				return playOptions.group == "HighPriority" and playOptions.volume == 0.4 and playOptions.radius == nil
			elseif p.Method == "duckMin" then
				local duck = Groups.duck({
					LowPriority = 0.5
				})
				local duck2 = Groups.duck({
					LowPriority = 0.2
				})
				local v2 = Groups.getEffectiveFactor("LowPriority") == 0.2
				duck2:Release()
				local v3 = Groups.getEffectiveFactor("LowPriority") == 0.5
				duck:Release()
				duck:Release()
				local v4 = Groups.getEffectiveFactor("LowPriority") == 1
				return v2 and v3 and v4
			elseif p.Method == "duckSetting" then
				Groups.setSettingFactor("LowPriority", 0.5)
				local duck = Groups.duck({
					LowPriority = 0.4
				})
				local v2 = math.abs(Groups.getEffectiveFactor("LowPriority") - 0.2) < 1e-9
				duck:Release()
				Groups.setSettingFactor("LowPriority", 1)
				return v2 and Groups.getEffectiveFactor("LowPriority") == 1
			elseif p.Method == "compressorRules" then
				if #Groups.Config.Compressors ~= 1 then
					return false
				end

				local compressor = Groups.Config.Compressors[1]
				return compressor.On == "LowPriority" and compressor.SideChain == "HighPriority" and Groups.Config.Priorities[compressor.SideChain] > Groups.Config.Priorities[compressor.On]
			elseif p.Method == "soundServiceGroups" then
				local v2 = {}

				for _, v3 in Groups.Config.GroupOrder do
					v2[v3] = true
				end

				local count = 0

				for _, soundGroup in game.SoundService:GetChildren() do
					if not soundGroup:IsA("SoundGroup") then
						continue
					end

					count += 1

					if not v2[soundGroup.Name] then
						return false
					end
				end

				return count == #Groups.Config.GroupOrder
			else
				if p.Method ~= "storageRouting" then
					error((`unknown case: {p.Method}`))
					return
				end

				local sound = game.ReplicatedStorage.Storage.Sound
				local trialSounds = sound:FindFirstChild("TrialSounds")
				local campfireSFX = sound:FindFirstChild("CampfireSFX")
				local ambience = sound:FindFirstChild("Ambience")
				local weatherSounds = sound:FindFirstChild("WeatherSounds")
				local bF_Cave_Trial_Ambience_01 = trialSounds and trialSounds:FindFirstChild("BF_Cave_Trial_Ambience_01")
				local dracoV4TrialMusic = trialSounds and trialSounds:FindFirstChild("DracoV4TrialMusic")
				local bF_Trial_Volcano_Explosion_01 = trialSounds and trialSounds:FindFirstChild("BF_Trial_Volcano_Explosion_01")
				local campfire_Looped_Ambience_01 = campfireSFX and campfireSFX:FindFirstChild("Campfire_Looped_Ambience_01")
				local campfire_Interact_OpenCookingMenu_01 = campfireSFX and campfireSFX:FindFirstChild("Campfire_Interact_OpenCookingMenu_01")
				local iceDoor_Icy_Door_Open_01 = ambience and ambience:FindFirstChild("IceDoor_Icy_Door_Open_01")
				local lightningStrike = weatherSounds and weatherSounds:FindFirstChild("LightningStrike")

				if not (bF_Cave_Trial_Ambience_01 and dracoV4TrialMusic and bF_Trial_Volcano_Explosion_01 and campfire_Looped_Ambience_01 and campfire_Interact_OpenCookingMenu_01 and iceDoor_Icy_Door_Open_01 and lightningStrike) then
					return false
				end

				if Groups.resolveTemplateGroup(bF_Cave_Trial_Ambience_01, sound) == "LowPriority" and Groups.resolveTemplateGroup(
					dracoV4TrialMusic,
					sound
				) == "LowPriority" and Groups.resolveTemplateGroup(bF_Trial_Volcano_Explosion_01, sound) == "HighPriority" and Groups.resolveTemplateGroup(
					campfire_Looped_Ambience_01,
					sound
				) == "LowPriority" and Groups.resolveTemplateGroup(campfire_Interact_OpenCookingMenu_01, sound) == "HighPriority" and Groups.resolveTemplateGroup(
					iceDoor_Icy_Door_Open_01,
					sound
				) == "HighPriority" then
					return Groups.resolveTemplateGroup(lightningStrike, sound) == "HighPriority"
				else
					return false
				end
			end
		end
	end
end, #v + 1)