local Players = game:GetService("Players")
local SignalEvent = require(game.ReplicatedStorage:WaitForChild("Communication"):WaitForChild("ServerAndClient"):WaitForChild("Signals"):WaitForChild("SignalEvent"))
local BunchaIcons = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("BunchaIcons"))

local function completionState(p: string)
	return function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", p)
	end
end

local FianlSelection = {
	FinalSelectionOpening = {
		Text = "Tonight, you stand before the Demon Slayer Corps' Final Selection.",
		Answers = true,
		AutoNext = 1.5,
		NoInput = true,
		IfTrue = "FinalSelectionOpening_2",
		CameraCFrame = game.PlaceId == 17047024836 and CFrame.new(
			-145.357361,
			3.84627962,
			-51.9563141,
			1,
			0,
			0,
			-0,
			1,
			0,
			-0,
			-0,
			1
		) or CFrame.new(
			-2625.69019,
			284.877075,
			-189.560501,
			0.99999994,
			-1.33500145e-12,
			5.81470649e-10,
			-2.98155597e-19,
			0.992951035,
			-0.118520692,
			-1.74622983e-10,
			0.118520699,
			0.992950976
		)
	},
	FinalSelectionOpening_2 = {
		Text = "Demons captured over the years are confined on this mountain, held back only by the [wisteria]<Color=(.71,.55,.86)> blooming along its slopes.",
		Answers = true,
		AutoNext = 2,
		NoInput = true,
		IfTrue = "FinalSelectionOpening_3",
		ContinueCamera = true
	},
	FinalSelectionOpening_3 = {
		Text = "Past the flowers, that protection ends. [Demons roam freely there.]<Color=(1,.3,.3)>",
		Answers = true,
		IfTrue = "FinalSelectionOpening_4",
		AutoNext = 1.5,
		NoInput = true,
		ContinueCamera = true
	},
	FinalSelectionOpening_4 = {
		Text = "Survive beyond that point, complete the trials and quests ahead, and you'll earn your place in the Corps.",
		Answers = true,
		IfTrue = "FinalSelectionOpening_5",
		AutoNext = 2,
		NoInput = true,
		ContinueCamera = true
	},
	FinalSelectionOpening_5 = {
		Text = "[Your trial begins now.]<Style=Fade,Color=(1,.3,.3)>",
		ContinueCamera = true,
		NoInput = true,
		Answers = 1e999
	},
	FinalSelectionArrival = {
		Text = "You made it up the mountain. The wisteria does not bloom here - nothing holds the demons back now.",
		Name = "The Sisters",
		Icon = BunchaIcons.FinalSelectionSisters,
		Answers = true,
		SurviveRespawn = true,
		IfTrue = "FinalSelectionArrival_2"
	},
	FinalSelectionArrival_2 = {
		Text = "We heard a girl crying for help nearby. [Find her.]<Color=(1,.85,.3)>",
		ContinueIcon = true,
		Answers = {
			["Locate Rem"] = "AddQuest"
		}
	},
	FinalSelectionFailed = {
		Text = "You have fallen. [Your Final Selection ends here.]<Color=(1,.3,.3)>",
		Answers = true,
		NoInput = true,
		AutoNext = 2.5,
		SurviveRespawn = true,
		IfTrue = "FinalSelectionFailed_2"
	},
	FinalSelectionFailed_2 = {
		Text = "[Recover your strength. The wisteria will bloom for you again.]<Style=Fade>",
		NoInput = true,
		Answers = 1e999
	},
	FinalSelectionClosing = {
		Text = "Welcome back. Congratulations - you survived.",
		Name = "The Sisters",
		Icon = BunchaIcons.FinalSelectionSisters,
		Answers = true,
		OnShow = function()
			local character = Players.LocalPlayer.Character

			if character == nil then
				return
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart == nil then
				return
			end

			local clone = script.CameraRig:Clone()
			clone.Parent = workspace.Debree
			clone.RootPart.Weld.Part0 = humanoidRootPart
			clone.AnimationController.Animator:LoadAnimation(script.Looped):Play()
			clone.AnimationController.Animator:LoadAnimation(script.Inital):Play()
			local bone = clone:FindFirstChild("Bone", true)
			game.ReplicatedStorage.Communication.CnC.ClientEffects:Fire("Camera_Controller_C", bone, nil, true)
		end,
		IfTrue = "FinalSelectionClosing_2"
	}
}
local v2 = "GiveClothing"
FianlSelection.FinalSelectionClosing_2 = {
	Text = "Before anything else, we'll issue your uniform and register your rank in the Corps.",
	ContinueIcon = true,
	Answers = true,
	OnShow = function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", v2)
	end,
	IfTrue = "FinalSelectionClosing_3"
}
FianlSelection.FinalSelectionClosing_3 = {
	Text = "There are ten ranks, from [\"Mizunoto\"]<Color=(.6,.75,1)> to [\"Kinoe\"]<Color=(1,.85,.4)>. Every new Slayer starts at [\"Mizunoto\"]<Color=(.6,.75,1)>.",
	ContinueIcon = true,
	Answers = true,
	IfTrue = "FinalSelectionClosing_4"
}
local v4 = "GiveOre"
FianlSelection.FinalSelectionClosing_4 = {
	Text = "Take this [\"Ore\"]<Color=(.55,.8,.9)> - spend it on your gear instead of using Robux.",
	ContinueIcon = true,
	Answers = true,
	OnShow = function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", v4)
	end,
	IfTrue = "FinalSelectionClosing_4b"
}
local v6 = "GiveIngot"
FianlSelection.FinalSelectionClosing_4b = {
	Text = "And this [\"Crude Iron\"]<Color=(.31,.73,1)>. The armoury in [Hidden Mist Village]<Color=(.6,.75,1)> will forge it into your first blade.",
	ContinueIcon = true,
	Answers = true,
	OnShow = function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", v6)
	end,
	IfTrue = "FinalSelectionClosing_5"
}
FianlSelection.FinalSelectionClosing_5 = {
	Text = "You'll also receive a [\"Kasugai Crow\"]<Color=(.8,.8,.8)>. It carries missions and messages between you and the Corps.",
	ContinueIcon = true,
	Answers = true,
	OnShow = function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", "GiveCrow")
		local Crow = require(game.ReplicatedStorage.ToolScripts.Crow.Crow)
		Crow.Equipped(Players.LocalPlayer.Character, "Crow")
	end,
	IfTrue = "FinalSelectionClosing_6"
}
local v8 = "ClosingDone"
FianlSelection.FinalSelectionClosing_6 = {
	Text = "[Welcome to the Demon Slayer Corps.]<Style=Fade>",
	ContinueIcon = true,
	Answers = true,
	OnHidden = function()
		SignalEvent.ToServer("FinalSelection_Completion_Helper", v8)
	end
}
return FianlSelection