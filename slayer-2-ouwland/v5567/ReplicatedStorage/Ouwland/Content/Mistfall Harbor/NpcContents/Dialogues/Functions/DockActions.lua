local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DayAndNightHandler = require(ReplicatedStorage.CAM.Global.DayAndNightHandler)
local DeliverAction = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests.DeliverAction)
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local DockActions = {}
DockActions.DeliverPermitStampToSofen = DeliverAction(
	"Ill find the permit stamp(Lv 45)",
	"Return to Sofen",
	"Sofen_Thanks",
	"Sofen_NoStamp"
)
DockActions.DeliverHaulToRuno = DeliverAction(
	"Ill fill your crates(Lv 45)",
	"Return to Runo",
	"Runo_Thanks",
	"Runo_Short"
)
DockActions.DeliverGoodCatchToRuno = DeliverAction(
	"Ill land the good catch(Lv 60)",
	"Return to Runo",
	"Runo_CatchThanks",
	"Runo_CatchShort"
)
DockActions.ReportSupplyBoxToNiko = DeliverAction(
	"Ill deliver the supply box(Lv 70)",
	"Report back to Niko",
	"Niko_Thanks",
	"Niko_Waiting"
)

function DockActions.SofenPullLedger(_, _)
	local data = Utility.GetData(Players.LocalPlayer)

	if data == nil or data.Wen.Value < 2500 then
		return "Sofen_LedgerBroke"
	end

	SignalEvent.ToServer("SofenPullLedger")
	return "Sofen_LedgerDone"
end

function DockActions.IsaoTakeToll(_, _)
	if DayAndNightHandler.IsEnabled() and not DayAndNightHandler.IsNight() then
		return "Isao_Silent"
	end

	SignalEvent.ToServer("IsaoTakeToll")
	return "Isao_Toll"
end

return DockActions