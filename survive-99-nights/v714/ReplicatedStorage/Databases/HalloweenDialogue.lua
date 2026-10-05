return {
	Root = {
		Message = "Happy Halloween!!",
		Responses = {
			{
				Response = "Goodbye",
				Event = "CloseHalloweenDialogue"
			}
		}
	},
	PickedUpHead = {
		Message = "Help! The Ram messed me up",
		Responses = {
			{
				Response = "What happened?",
				Node = "WhatHappened"
			},
			{
				Response = "How can I help?",
				Node = "HowCanIHelp"
			},
			{
				Response = "Let's go",
				Event = "StartHelpHappyQuest"
			}
		}
	},
	WhatHappened = {
		Message = "That crazy Ram knocked me to pieces",
		Responses = {
			{
				Response = "Show me what happened to you",
				Cutscene = "UpdateCutscene52"
			},
			{
				Response = "How can I help?",
				Node = "HowCanIHelp"
			},
			{
				Response = "Let's go",
				Event = "StartHelpHappyQuest"
			}
		}
	},
	HowCanIHelp = {
		Message = "You need to find my body pieces and rebuild them near the camp",
		Responses = {
			{
				Response = "What happened?",
				Node = "WhatHappened"
			},
			{
				Response = "Let's go",
				Event = "StartHelpHappyQuest"
			}
		}
	},
	SawWhatHappened = {
		Message = "SEE? The Ram got me good...",
		Responses = {
			{
				Response = "How can I help?",
				Node = "HowCanIHelpAfterCutscene"
			},
			{
				Response = "Let's go",
				Event = "StartHelpHappyQuest"
			}
		}
	},
	HowCanIHelpAfterCutscene = {
		Message = "You need to find my body pieces and rebuild them near the camp",
		Responses = {
			{
				Response = "Let's go",
				Event = "StartHelpHappyQuest"
			}
		}
	},
	GrabScytheFirst = {
		Message = "Wait, grab my scythe first, it will be helpful",
		Responses = {
			{
				Response = "Okay",
				Event = "CloseHalloweenDialogue"
			}
		}
	},
	GrabScytheReminder = {
		Message = "Grab the Scythe, it's right next to me!",
		Responses = {
			{
				Response = "Okay",
				Event = "CloseHalloweenDialogue"
			}
		}
	},
	GrabbedScythe = {
		Message = "Great! Let's go find my stuff!"
	},
	WolfHasArm = {
		Message = "Hey! That wolf has my arm!!"
	},
	FindMoreBodyPieces = {
		Message = "You need to find my body pieces!"
	},
	BodyPieceAdded = {
		Message = "Nice!! That's another one!",
		Responses = {
			{
				Response = "Keep Searching",
				Event = "CloseHalloweenDialogue"
			}
		}
	},
	CanPlaceHead = {
		Message = "You found everything!! Quick, put my head on!!"
	},
	RamHeadDropped = {
		Message = "He dropped me! Quick, put my head back on"
	},
	RamHeadPickedUp = {
		Message = "Put my head back on my body"
	},
	RamSpawnedWithHead = {
		Message = "The Ram's got me!! Make him run into something solid so I fall off!!!"
	},
	RamReminder = {
		Message = "Make him run into something solid so I fall off!!!"
	},
	RamGotMe = {
		Message = "Find the Ram! Make it run into something solid to free me!"
	},
	RamSmacked4 = {
		Message = "I THINK THAT WORKED!! DO IT AGAIN!!"
	},
	RamSmacked3 = {
		Message = "IT'S WORKING!! KEEP GOING!!"
	},
	RamSmacked2 = {
		Message = "A COUPLE MORE SHOULD DO IT! KEEP GOING!!"
	},
	RamSmacked1 = {
		Message = "ONE MORE TIME!! YOU NEARLY HAVE IT!!"
	},
	HappyAfterQuestComplete = {
		Message = "Thanks for your help!!",
		Responses = {
			{
				Response = "When does halloween start?",
				Node = "WhenDoesHalloweenStart"
			},
			{
				Response = "No problem",
				Event = "CloseHalloweenDialogue"
			}
		}
	},
	HappyCompleteQuest = {
		Message = "PHEW! Thanks for helping me out..",
		Responses = {
			{
				Response = "Choose Reward",
				Event = "RequestCompleteHappyQuest"
			}
		}
	},
	WhenDoesHalloweenStart = {
		Message = "It's the next update on 17th October!",
		Responses = {
			{
				Response = "Yay",
				Event = "CloseHalloweenDialogue"
			}
		}
	}
}