local JungleSpikeTrapClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local v = {}

function Dist(p)
	return (workspace.CurrentCamera.Focus.Position - p.Position).Magnitude
end

function VisualExtendSpikes(instance)
	local jungleSpikesModel = instance:WaitForChild("JungleSpikesModel")

	if jungleSpikesModel:GetAttribute("ExtendedCF") == nil then
		jungleSpikesModel:SetAttribute("ExtendedCF", jungleSpikesModel:GetPivot())
	end

	local extendedCF = jungleSpikesModel:GetAttribute("ExtendedCF")

	if v[jungleSpikesModel] then
		v[jungleSpikesModel]:Stop()
		v[jungleSpikesModel] = nil
	end

	if not (Dist(extendedCF) < 200) then
		jungleSpikesModel:PivotTo(extendedCF)
		return
	end

	local pivot = jungleSpikesModel:GetPivot()
	local v2 = (pivot.Position - extendedCF.Position).Magnitude / 4 * 0.07
	local tweenModule = Client.TweenModule.new(function(p)
		jungleSpikesModel:PivotTo((pivot:Lerp(extendedCF, p)))
	end, v2)
	v[jungleSpikesModel] = tweenModule
	tweenModule:Play()
end

function VisualRetractSpikes(instance)
	local jungleSpikesModel = instance:WaitForChild("JungleSpikesModel")

	if jungleSpikesModel:GetAttribute("ExtendedCF") == nil then
		jungleSpikesModel:SetAttribute("ExtendedCF", jungleSpikesModel:GetPivot())
	end

	local extendedCF = jungleSpikesModel:GetAttribute("ExtendedCF")
	local v2 = extendedCF * CFrame.new(0, -5, 0)

	if v[jungleSpikesModel] then
		v[jungleSpikesModel]:Stop()
		v[jungleSpikesModel] = nil
	end

	if not (Dist(extendedCF) < 200) then
		jungleSpikesModel:PivotTo(v2)
		return
	end

	local pivot = jungleSpikesModel:GetPivot()
	local v3 = (pivot.Position - v2.Position).Magnitude / 4 * 0.6
	local tweenModule = Client.TweenModule.new(function(p)
		jungleSpikesModel:PivotTo((pivot:Lerp(v2, p)))
	end, v3)
	v[jungleSpikesModel] = tweenModule
	tweenModule:Play()
end

function IsExtended(instance)
	if instance:GetAttribute("Extended") or instance:GetAttribute("LocalExtended") then
		return true
	end
end

function SpikeTrapAdded(instance)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function update()
		if IsExtended(instance) then
			VisualExtendSpikes(instance)
		else
			VisualRetractSpikes(instance)
		end
	end

	local v2 = 0
	instance:WaitForChild("JungleSpikesModel"):WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if not IsExtended(instance) or time() - v2 < 2 then
			return
		end

		if otherPart.Parent == localPlayer.Character then
			v2 = time()
			Client.Events.JungleSpikeTrapDamage:FireServer(instance)
		end
	end)
	instance:GetAttributeChangedSignal("Extended"):Connect(update)
	instance:GetAttributeChangedSignal("LocalExtended"):Connect(update)
	update() -- equivalent call inferred; original call site unknown
end

function JungleSpikeTrapClient.Init()
	Client.Utility.ForAllTagged("JungleSpikeTrap", SpikeTrapAdded)
end

return JungleSpikeTrapClient