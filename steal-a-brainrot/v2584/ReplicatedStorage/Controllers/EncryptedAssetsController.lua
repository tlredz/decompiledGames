local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("Players")
local Net = require(ReplicatedStorage.Packages.Net)
local v = {}
local EncryptedAssetsController = {}

function EncryptedAssetsController.WaitForAssetId(_, p: string)
	while not v[p] do
		task.wait()
	end
end

function EncryptedAssetsController.Start(_)
	for k, v2 in Net:Invoke("EncryptedAssetsService/Load") do
		local v3 = k
		local v4 = v2
		task.spawn(function()
			ContentProvider:RegisterSessionEncryptedAsset(v3, v4)
			v[v3] = true
		end)
	end
end

return EncryptedAssetsController