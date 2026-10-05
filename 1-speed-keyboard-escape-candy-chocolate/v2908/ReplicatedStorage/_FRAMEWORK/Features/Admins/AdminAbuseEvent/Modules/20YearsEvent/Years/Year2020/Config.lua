local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage._FRAMEWORK.Libraries.AAEventWinAward)
require(ReplicatedStorage._FRAMEWORK.Libraries.floatingOrbWins.Types)
return {
	scriptablesFolderName = "Scriptables",
	mailboxesFolderName = "Mailboxes",
	promptName = "MailboxPrompt",
	mailboxIdAttributeName = "MailboxId",
	promptActionText = "Collect Mail",
	promptObjectText = "Mailbox",
	promptHoldSeconds = 0.5,
	promptDistanceStuds = 10,
	maxCollectDistanceStuds = 18,
	mailAward = {
		source = "20YearsEvent:2020:Mailbox",
		multiplier = 10
	},
	orbSpawnZoneName = "OrbSpawnZone",
	winOrbs = {
		orbTemplate = "AdminAbuse/20Anniversary/Assets/CollectibleOrb",
		spawnIntervalMinSeconds = 0.5,
		spawnIntervalMaxSeconds = 1,
		orbsPerWave = 14,
		initialOrbsPerPlayer = 250,
		maxActivePerPlayer = 250,
		orbLifetimeSeconds = 60,
		hoverHeightStuds = 2,
		triggerRadiusStuds = 10,
		floatDurationSeconds = 0.45
	},
	winOrbAward = {
		source = "20YearsEvent:2020:WinOrb",
		multiplier = 0.5
	}
}