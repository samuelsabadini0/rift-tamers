local Environment={}
function Environment.light()
	local lighting=game:GetService("Lighting")
	lighting.ClockTime=15.5
	lighting.Brightness=2.4
	lighting.Ambient=Color3.fromRGB(109,107,124)
	lighting.OutdoorAmbient=Color3.fromRGB(143,151,154)
	lighting.EnvironmentDiffuseScale=.7
	lighting.EnvironmentSpecularScale=.45
	lighting.GlobalShadows=true
	local air=lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",lighting)
	air.Density,air.Offset,air.Haze=.27,.12,1.05
	air.Color,air.Decay=Color3.fromRGB(216,230,231),Color3.fromRGB(152,161,178)
end
return Environment
