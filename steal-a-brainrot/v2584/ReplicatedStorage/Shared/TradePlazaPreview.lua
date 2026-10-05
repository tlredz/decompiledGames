local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TradePlazaPreview = {
	PreviewingAttribute = "PreviewingBaseOrder"
}
local cframe = CFrame.new(10000, 0, 0)

function TradePlazaPreview.getSlotCFrame(p: number)
	return cframe * CFrame.new(p * 1000, 0, 0)
end

function TradePlazaPreview.getBaseRootCFrame(cframe2: CFrame)
	local tradePlazaPreviewMap = ReplicatedStorage:FindFirstChild("TradePlazaPreviewMap")
	local plots = tradePlazaPreviewMap and tradePlazaPreviewMap:FindFirstChild("Plots")
	local plotFixed = plots and plots:FindFirstChild("PlotFixed")

	if tradePlazaPreviewMap and plotFixed then
		return cframe2 * tradePlazaPreviewMap:GetPivot():ToObjectSpace(plotFixed:GetPivot())
	end

	return cframe2
end

function TradePlazaPreview.getBaseSpawnCFrame(cframe2: CFrame, childName: string?)
	local tradePlazaPreviewMap = ReplicatedStorage:FindFirstChild("TradePlazaPreviewMap")
	local plots = tradePlazaPreviewMap and tradePlazaPreviewMap:FindFirstChild("Plots")
	local plotFixed = plots and plots:FindFirstChild("PlotFixed")
	local bases = ReplicatedStorage:FindFirstChild("Bases")
	local child = childName and bases and bases:FindFirstChild(childName)
	local spawn = child and child:FindFirstChild("Spawn")
	local childRoot = child and child:FindFirstChild("Root", true)

	if tradePlazaPreviewMap and plotFixed and childRoot and childRoot:IsA("BasePart") and spawn and spawn:IsA("BasePart") then
		return TradePlazaPreview.getBaseRootCFrame(cframe2) * childRoot.CFrame:ToObjectSpace(spawn.CFrame) + createVector(
			0,
			3,
			0
		)
	end

	return cframe2 + createVector(0, 5, 0)
end

return TradePlazaPreview