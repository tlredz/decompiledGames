local ReplicatedStorage = game:GetService("ReplicatedStorage")
local faye = require(ReplicatedStorage.Packages.faye)
return {
	TxtInfo0 = faye.Info(0.5),
	TxtInfo1 = faye.Info(0.5, nil, nil, nil, nil, 1),
	TxtInfo2 = faye.Info(0.5, nil, nil, nil, nil, 0.5),
	InInfo = faye.Info(0.35),
	InInfo2 = faye.SpringInfo(1, 1, 0.75),
	InInfo3 = faye.SpringInfo(1.2, 1, 0.75),
	TransitionInfo = faye.Info(0.15)
}