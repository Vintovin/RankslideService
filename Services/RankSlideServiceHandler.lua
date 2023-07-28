local RSS = require(game:GetService("ServerScriptService").Services.RankslideServiceREV2)


RSS.Init()

game:GetService("ReplicatedStorage").RemoteEvent.OnServerEvent:Connect(function(plr,r)
	RSS:ChangeRank(plr,r)
end)
