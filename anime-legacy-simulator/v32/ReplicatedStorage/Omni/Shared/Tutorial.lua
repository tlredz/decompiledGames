local Tutorial = {
	MapName = "Heaven Island",
	NextMapName = "Slayers Village",
	StarName = "Heaven Island",
	NpcName = "Namy",
	FirstEnemyName = "Kume",
	QuestClass = "Main",
	QuestName = "Heaven Island",
	MessageDuration = 8,
	Rewards = {
		{
			Type = "Item",
			Name = "Luck Boost",
			Amount = 2
		},
		{
			Type = "Item",
			Name = "Yen Boost",
			Amount = 2
		},
		{
			Type = "Item",
			Name = "Damage Boost",
			Amount = 2
		}
	},
	Texts = {
		Title = "Tutorial",
		Prompt = "Welcome, warrior! Want a quick tutorial to learn the basics?",
		Accept = "Yes, teach me!",
		Decline = "No, thanks",
		Next = "Next",
		Finish = "Finish",
		GotIt = "Got it",
		Skip = "Skip",
		SkipTitle = "Skip Tutorial",
		SkipDescription = "Are you sure? You won't be able to do the tutorial again and won't receive its reward.",
		SkipConfirm = "Skip",
		SkipCancel = "Cancel",
		Pause = "Return to Heaven Island to continue the tutorial.",
		MissionCompleted = "Nice! Next target: {Enemy}."
	},
	Lessons = {
		{
			Name = "Achievements",
			Text = "Nice! Next target: {Enemy}. Complete achievements in Feats to earn extra rewards!"
		},
		{
			Name = "Settings",
			Text = "Great! Next target: {Enemy}. You can change your game settings in the Menu."
		},
		{
			Name = "Guilds",
			Text = "Awesome! Next target: {Enemy}. Join or create a Guild with other players in the Menu."
		},
		{
			Name = "Trade",
			Text = "Almost there! Next target: {Enemy}. Trade fighters and items with other players in the Menu."
		}
	},
	Steps = {
		{
			Name = "Welcome",
			Kind = "Info",
			Text = "Your journey starts here! Follow the arrows and I'll show you how to get stronger."
		},
		{
			Name = "FighterAttack",
			Kind = "Action",
			Event = "FighterKill",
			Text = "This is your first fighter! {Click} the enemy marked by the arrow and press Attack to send your fighter."
		},
		{
			Name = "Level",
			Kind = "Info",
			MessagePlacement = "Top",
			Text = "Every enemy you defeat gives you EXP. Level up to become stronger!"
		},
		{
			Name = "LevelStats",
			Kind = "Info",
			MessagePlacement = "Top",
			Text = "Open your Level menu. Each level gives you points to upgrade your stats here."
		},
		{
			Name = "LevelRewards",
			Kind = "Info",
			MessagePlacement = "Top",
			Text = "Open the Rewards tab to see what you get for reaching each level."
		},
		{
			Name = "MeleeAttack",
			Kind = "Action",
			Event = "Kill",
			Text = "You can fight too! Get close to an enemy and {click} to punch it with your Melee."
		},
		{
			Name = "CollectYen",
			Kind = "Action",
			Event = "Currency",
			Text = "Defeat enemies to earn Yen. You need {Price} Yen to open a Star."
		},
		{
			Name = "OpenStar",
			Kind = "Action",
			Event = "StarRoll",
			Text = "Stars give you new fighters! Walk to the Star and open it."
		},
		{
			Name = "Fighters",
			Kind = "Info",
			Text = "Your fighters are stored here. Open this menu to equip, check and manage them."
		},
		{
			Name = "Backpack",
			Kind = "Info",
			Text = "Your items, weapons, mounts and more are stored in your Bag."
		},
		{
			Name = "AcceptQuest",
			Kind = "Action",
			Event = "QuestAccepted",
			Text = "Talk to Namy to get the main quest of the island."
		},
		{
			Name = "QuestTracker",
			Kind = "Info",
			Text = "{Click} this arrow to show or hide your active quest and its progress."
		},
		{
			Name = "Multipliers",
			Kind = "Info",
			Text = "Close your quest and {click} the blue arrow to see all your active multipliers."
		},
		{
			Name = "AutoAttack",
			Kind = "Info",
			MessagePlacement = "Top",
			Text = "Auto Attack makes your fighters attack nearby enemies by themselves."
		},
		{
			Name = "AutoClicker",
			Kind = "Info",
			MessagePlacement = "Top",
			Text = "Auto Clicker keeps attacking with your weapon for you."
		},
		{
			Name = "TimeRewards",
			Kind = "Info",
			Text = "Stay in the game to earn free rewards over time. Claim them here!"
		},
		{
			Name = "CompleteQuest",
			Kind = "Action",
			Event = "QuestCompleted",
			Text = "Defeat the enemies from your quest. The arrow shows the nearest one!"
		},
		{
			Name = "ClaimQuest",
			Kind = "Action",
			Event = "QuestClaimed",
			Text = "Quest complete! Return to Namy to claim your reward."
		},
		{
			Name = "Teleport",
			Kind = "Action",
			Event = "Teleport",
			Text = "A new island is unlocked! Open the Worlds menu and travel to Slayers Village."
		},
		{
			Name = "Finish",
			Kind = "Info",
			Text = "Tutorial complete! Here are some potions to help you on your journey. Good luck!"
		}
	}
}

function Tutorial.GetStep(value: number)
	if typeof(value) == "number" then
		return Tutorial.Steps[value]
	end

	return nil
end

function Tutorial.GetStepIndex(p: string)
	for k, step in Tutorial.Steps do
		if step.Name == p then
			return k
		end
	end

	return nil
end

function Tutorial.FormatText(value: string, flag: boolean, items)
	local v = string.gsub(value, "{Click}", flag and "Tap" or "Click")
	local v2 = string.gsub(v, "{click}", flag and "tap" or "click")

	if items then
		for k, item in items do
			v2 = string.gsub(v2, "{" .. k .. "}", (tostring(item)))
		end
	end

	return v2
end

return Tutorial