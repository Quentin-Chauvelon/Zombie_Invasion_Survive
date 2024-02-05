while true do
	if game.Lighting.ClockTime > 18 and game.Lighting.ClockTime < 23 then
		script.Parent.PointLight.Enabled = true
		script.Parent.PointLight.Color = Color3.fromRGB(255,0,0)
		for i = 0,255,10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(255,i,0)
		end
		for i = 255,0,-10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(i,255,0)
		end
		for i = 0,255,10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(0,255,i)
		end
		for i = 255,0,-10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(0,i,255)
		end
		for i = 0,255,10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(i,0,255)
		end
		for i = 255,0,-10 do
			wait(0.2)
			script.Parent.PointLight.Color = Color3.fromRGB(255,0,i)
		end
		wait(1)
	else
	script.Parent.PointLight.Enabled = false	
	end
	wait(1)
end