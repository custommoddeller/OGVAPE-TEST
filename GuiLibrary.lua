local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local lplr = players.LocalPlayer
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local uis = game:GetService("UserInputService")
local mouse = lplr:GetMouse()

local function friendCheck(plr)
	return (GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) == nil or GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] == false)
end

local function teamCheck(plr)
	return (GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"]["Enabled"] and (plr.Team ~= lplr.Team or (lplr.Team == nil or #lplr.Team:GetPlayers() == #game:GetService("Players"):GetChildren())) or GuiLibrary["ObjectsThatCanBeSaved"]["Teams by colorToggle"]["Api"]["Enabled"] == false)
end

local function targetCheck(plr, check)
	return (check and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("ForceField") == nil or check == false)
end

local function isAlive(plr)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
	return lplr and lplr.Character and lplr.Character.Parent ~= nil and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character:FindFirstChild("Head") and lplr.Character:FindFirstChild("Humanoid")
end

local function isPlayerTargetable(plr, target, friend)
    return plr ~= lplr and GuiLibrary["ObjectsThatCanBeSaved"]["PlayersToggle"]["Api"]["Enabled"] and plr and (friend == true and friendCheck(plr) or friend == false) and isAlive(plr) and targetCheck(plr, target) and teamCheck()
end

local function vischeck(char, part)
	return not unpack(cam:GetPartsObscuringTarget({lplr.Character[part].Position, char[part].Position}, {lplr.Character, char}))
end

local function GetAllNearestHumanoidToPosition(distance)
	local returnedplayer = {}
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable(v, true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                if mag <= distance then
                    table.insert(returnedplayer, v)
                end
            end
        end
	end
	return returnedplayer
end

local function GetNearestHumanoidToPosition(distance)
	local closest, returnedplayer = distance, nil
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable(v, true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                if mag <= closest then
                    closest = mag
                    returnedplayer = v
                end
            end
        end
	end
	return returnedplayer
end

local function GetNearestHumanoidToMouse(distance, checkvis)
    local closest, returnedplayer = distance, nil
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable(v, true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and (checkvis == false or checkvis and (vischeck(v.Character, "Head") or vischeck(v.Character, "HumanoidRootPart"))) then
                local vec, vis = cam:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (uis:GetMouseLocation() - Vector2.new(vec.X, vec.Y)).magnitude
                    if mag <= closest then
                        closest = mag
                        returnedplayer = v
                    end
                end
            end
        end
    end
    return returnedplayer
end

local aimfov = {["Value"] = 1}
local aimvischeck = {["Enabled"] = false}
local aimheadshotchance = {["Value"] = 1}
local aimhitchance = {["Value"] = 1}
local kek = function() end
local kek2 = function() end
local tar = nil
local meta = getrawmetatable(game)
setreadonly(meta, false)
local old = meta.__namecall
local old2 = meta.__index
local hook

local AimAssist = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton("AimAssist", function() kek() end, function() 
	game:GetService("RunService"):UnbindFromRenderStep("AimAssist") 
	meta.__namecall = old
	meta.__index = old2
	tar = nil 
end, true)
local aimmethod = AimAssist.CreateDropdown("Method", {"FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist", "Raycast", "FindPartOnRay", "ScreenPointToRay", "ViewportPointToRay", "Mouse"}, function(val) end)
local aimtable = {["FindPartOnRayWithIgnoreList"] = 1, ["FindPartOnRayWithWhitelist"] = 1, ["Raycast"] = 2, ["FindPartOnRay"] = 1, ["ScreenPointToRay"] = 3, ["ViewportPointToRay"] = 3, ["Mouse"] = 4}
aimvischeck = AimAssist.CreateToggle("Wall Check", function() end, function() end)
aimfov = AimAssist.CreateSlider("FOV", 1, 1000, function(val) end)
aimhitchance = AimAssist.CreateSlider("Hit Chance", 1, 100, function(val) end)
aimheadshotchance = AimAssist.CreateSlider("Headshot Chance", 1, 100, function(val) end)

hook = hookfunction(workspace.FindPartOnRayWithIgnoreList, function(...) 
    local scriptname = getcallingscript()
	local Args = {...}
	
	if tar and not checkcaller() and (scriptname and not scriptname.Name:match("Camera")) and aimtable[aimmethod["Value"]] == 1 then
       Args[2] = Ray.new(Args[2].Origin, (tar.Position + Vector3.new(0, (Args[2].Origin - tar.Position).magnitude/10000, 0) - Args[2].Origin).unit * 10000)
	   if GuiLibrary["ObjectsThatCanBeSaved"]["Blatant ModeToggle"]["Api"]["Enabled"] then
			return tar, tar.Position, (tar.Position + Vector3.new(0, (Args[2].Origin - tar.Position).magnitude/10000, 0) - Args[2].Origin).unit * 10000, tar.Material
	   end
    end
	
    return hook(unpack(Args))
end)

kek = function()
	meta.__namecall = newcclosure(function(...)
		local Namecallaimmethod = getnamecallmethod()
		local Args = {...}
		local scriptname = getcallingscript()

		if tar then
			if not checkcaller() and (scriptname and not scriptname.Name:match("Camera")) and Namecallaimmethod == aimmethod["Value"] then
				if aimtable[aimmethod["Value"]] == 1 then
				   Args[2] = Ray.new(Args[2].Origin, (tar.Position + Vector3.new(0, (Args[2].Origin - tar.Position).magnitude/10000, 0) - Args[2].Origin).unit * 10000)
				   if GuiLibrary["ObjectsThatCanBeSaved"]["Blatant modeToggle"]["Api"]["Enabled"] then
						return tar, tar.Position, (tar.Position + Vector3.new(0, (Args[2].Origin - tar.Position).magnitude/10000, 0) - Args[2].Origin).unit * 10000, tar.Material
				   end
				end
				if aimtable[aimmethod["Value"]] == 2 then
				   Args[3] = (tar.Position + Vector3.new(0, (Args[2] - tar.Position).magnitude/10000, 0) - Args[2]).unit * 10000
				   if GuiLibrary["ObjectsThatCanBeSaved"]["Blatant modeToggle"]["Api"]["Enabled"] then
						local haha = RaycastParams.new()
						haha.FilterType = Enum.RaycastFilterType.Whitelist
						haha.FilterDescendantsInstances = {tar}
						Args[4] = haha
				   end
				end
				if aimtable[aimmethod["Value"]] == 3 then
					return Ray.new(cam.CFrame.p, (tar.Position + Vector3.new(0, (cam.CFrame.p - tar.Position).magnitude/10000, 0) - cam.CFrame.p).unit * 10000)
				end
			end
		end

		return old(unpack(Args))
	end)
	meta.__index = newcclosure(function(lol, lol2)
		if tar and not checkcaller() and lol == mouse and aimmethod["Value"] == "Mouse" then
			if tostring(lol2) == "Hit" then
				return tar.CFrame
			elseif tostring(lol2) == "Target" then
				return tar
			end
		end
		return old2(lol, lol2)
	end)
    game:GetService("RunService"):BindToRenderStep("AimAssist", 1, function() 
		local plr = GetNearestHumanoidToMouse(aimfov["Value"], GuiLibrary["ObjectsThatCanBeSaved"]["Blatant modeToggle"]["Api"]["Enabled"] == false and aimvischeck["Enabled"])
		if plr and (math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)) <= aimhitchance["Value"] then
			tar = (math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100)) <= aimheadshotchance["Value"] and plr.Character.Head or plr.Character.HumanoidRootPart
		else
			tar = nil
		end
    end)
end

local speedval = {["Value"] = 1}
local bodyvelo
local speed = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Speed", function()
	game:GetService("RunService"):BindToRenderStep("Speed", 1, function() 
		if isAlive() and (bodyvelo == nil or bodyvelo ~= nil and bodyvelo.Parent ~= lplr.Character.HumanoidRootPart) then
			bodyvelo = Instance.new("BodyVelocity")
			bodyvelo.Parent = lplr.Character.HumanoidRootPart
			bodyvelo.MaxForce = Vector3.new(100000, 0, 100000)
		else
			if isAlive() then
				bodyvelo.Velocity = lplr.Character.Humanoid.MoveDirection * speedval["Value"]
				if (lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running or lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics) and lplr.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
					lplr.Character.Humanoid:ChangeState(3)
				end
			end
		end
	end)
end, function() 
	if bodyvelo then
		bodyvelo:Remove()
	end
	game:GetService("RunService"):UnbindFromRenderStep("Speed")
end, true)
speedval = speed.CreateSlider("Speed", 1, 150, function(val) end)

local flyval = {["Value"] = 1}
local bodyvelofly
local fly = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Fly", function()
	game:GetService("RunService"):BindToRenderStep("Fly", 1, function() 
		if isAlive() and (bodyvelofly == nil or bodyvelofly ~= nil and bodyvelofly.Parent ~= lplr.Character.HumanoidRootPart) then
			bodyvelofly = Instance.new("BodyVelocity")
			bodyvelofly.Parent = lplr.Character.HumanoidRootPart
			bodyvelofly.MaxForce = Vector3.new(100000, 100000, 100000)
		else
			if isAlive() then
				bodyvelofly.Velocity = lplr.Character.Humanoid.MoveDirection * flyval["Value"]
			end
		end
	end)
end, function() 
	if bodyvelofly then
		bodyvelofly:Remove()
	end
	game:GetService("RunService"):UnbindFromRenderStep("Fly")
end, true)
flyval = fly.CreateSlider("Fly Speed", 1, 150, function(val) end)

local killaurarange = {["Value"] = 1}
local Killaura = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Killaura", function()
	game:GetService("RunService"):BindToRenderStep("Killaura", 1, function() 
		local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
		local plr = GetAllNearestHumanoidToPosition(killaurarange["Value"], false)
		if tool then
			local touch = tool:FindFirstChild("Handle") and tool.Handle:FindFirstChildWhichIsA("TouchTransmitter")
			if touch then
				for i,v in pairs(plr) do
					firetouchinterest(tool.Handle, v.Character.Head, 1)
					firetouchinterest(tool.Handle, v.Character.Head, 0)
				end
			end
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("Killaura") end, true)
killaurarange = Killaura.CreateSlider("Attack range", 1, 1000, function(val) end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = GuiLibrary["MainGui"]
players.PlayerRemoving:connect(function(plr)
	if ESPFolder:FindFirstChild(plr.Name) then
		ESPFolder[plr.Name]:Remove()
	end
end)
local ESPColor = {["Value"] = 0.44}
local ESPMethod = "2D"
local ESP = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("ESP", function() 
	game:GetService("RunService"):BindToRenderStep("ESP", 500, function()
		for i,plr in pairs(players:GetChildren()) do
			if ESPMethod == "2D" then
				local thing
				if ESPFolder:FindFirstChild(plr.Name) then
					thing = ESPFolder[plr.Name]
					thing.Visible = false
					thing.Line1.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line2.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line3.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line4.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
				else
					thing = Instance.new("Frame")
					thing.BackgroundTransparency = 1
					thing.BorderSizePixel = 0
					thing.Visible = false
					thing.Name = plr.Name
					thing.Parent = ESPFolder
					local line1 = Instance.new("Frame")
					line1.BorderSizePixel = 0
					line1.Name = "Line1"
					line1.Size = UDim2.new(1, 0, 0, 3)
					line1.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line1.Parent = thing
					local line2 = Instance.new("Frame")
					line2.BorderSizePixel = 0
					line2.Name = "Line2"
					line2.Size = UDim2.new(1, 0, 0, 3)
					line2.Position = UDim2.new(0, 0, 1, -3)
					line2.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line2.Parent = thing
					local line3 = Instance.new("Frame")
					line3.BorderSizePixel = 0
					line3.Name = "Line3"
					line3.Size = UDim2.new(0, 3, 1, 0)
					line3.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line3.Parent = thing
					local line4 = Instance.new("Frame")
					line4.BorderSizePixel = 0
					line4.Name = "Line4"
					line4.Size = UDim2.new(0, 3, 1, 0)
					line4.Position = UDim2.new(1, -3, 0, 0)
					line4.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line4.Parent = thing
				end
				
				if isPlayerTargetable(plr, false, false) then
					local rootPos, rootVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
					local rootSize = plr.Character.HumanoidRootPart.Size.X * 1500
					local headPos, headVis = cam:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0, 1, 0))
					local legPos, legVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0, 4 + plr.Character.Humanoid.HipHeight, 0))
					
					if rootVis then
						thing.Visible = rootVis
						thing.Size = UDim2.new(0, rootSize / rootPos.Z, 0, headPos.Y - legPos.Y)
						thing.Position = UDim2.new(0, rootPos.X - thing.Size.X.Offset / 2, 0, (rootPos.Y - thing.Size.Y.Offset / 2) - 36)
					end
				end
			end
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("ESP") ESPFolder:ClearAllChildren() end, true)
ESPColor = ESP.CreateColorSlider("Player Color", function(val) end)
ESP.CreateDropdown("Mode", {"2D", "3D"}, function(val) ESPMethod = val end)
--[[local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "ChamsFolder"
ChamsFolder.Parent = GuiLibrary["MainGui"]
players.PlayerRemoving:connect(function(plr)
	if ChamsFolder:FindFirstChild(plr.Name) then
		ChamsFolder[plr.Name]:Remove()
	end
end)
local ChamsColor = {["Value"] = 0.44}
local Chams = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("Chams", function() 
	game:GetService("RunService"):BindToRenderStep("Chams", 500, function()
		for i,plr in pairs(players:GetChildren()) do
				local thing
				if ChamsFolder:FindFirstChild(plr.Name) then
					thing = ChamsFolder[plr.Name]
					for partnumber, part in pairs(thing:GetChildren()) do
						part.Visible = false
						part.Color3 = Color3.fromHSV(ChamsColor["Value"], 1, 1)
					end
				end
				
				if isPlayerTargetable(plr, false) then
					if ChamsFolder:FindFirstChild(plr.Name) == nil then
						for partnumber, part in pairs(plr.Character:GetChildren()) do
							local boxhandle = 
						end
					end
					for partnumber, part in pairs(thing:GetChildren()) do
						part.Visible = true
					end
				end
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("Chams") ChamsFolder:ClearAllChildren() end, true)
ChamsColor = Chams.CreateColorSlider("Player Color", function(val) end)]]
local lightingsettings = {}
local lightingconnection
local lightingchanged = false
GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("Fullbright", function() 
	lightingsettings["Brightness"] = lighting.Brightness
	lightingsettings["ClockTime"] = lighting.ClockTime
	lightingsettings["FogEnd"] = lighting.FogEnd
	lightingsettings["GlobalShadows"] = lighting.GlobalShadows
	lightingsettings["OutdoorAmbient"] = lighting.OutdoorAmbient
	lightingchanged = false
	lighting.Brightness = 2
	lighting.ClockTime = 14
	lighting.FogEnd = 100000
	lighting.GlobalShadows = false
	lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	lightingchanged = true
	lightingconnection = lighting.Changed:connect(function()
		if not lightingchanged then
			lightingsettings["Brightness"] = lighting.Brightness
			lightingsettings["ClockTime"] = lighting.ClockTime
			lightingsettings["FogEnd"] = lighting.FogEnd
			lightingsettings["GlobalShadows"] = lighting.GlobalShadows
			lightingsettings["OutdoorAmbient"] = lighting.OutdoorAmbient
			lightingchanged = true
			lighting.Brightness = 2
			lighting.ClockTime = 14
			lighting.FogEnd = 100000
			lighting.GlobalShadows = false
			lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
			lightingchanged = false
		end
	end)
end, function() for name,thing in pairs(lightingsettings) do lighting[name] = thing lightingconnection:Disconnect()  end end, false)

local healthColorToPosition = {
		[Vector3.new(Color3.fromRGB(255, 28, 0).r,
      Color3.fromRGB(255, 28, 0).g,
      Color3.fromRGB(255, 28, 0).b)] = 0.1;
		[Vector3.new(Color3.fromRGB(250, 235, 0).r,
      Color3.fromRGB(250, 235, 0).g,
      Color3.fromRGB(250, 235, 0).b)] = 0.5;
		[Vector3.new(Color3.fromRGB(27, 252, 107).r,
      Color3.fromRGB(27, 252, 107).g,
      Color3.fromRGB(27, 252, 107).b)] = 0.8;
	}
	local min = 0.1
	local minColor = Color3.fromRGB(255, 28, 0)
	local max = 0.8
	local maxColor = Color3.fromRGB(27, 252, 107)

	local function HealthbarColorTransferFunction(healthPercent)
		if healthPercent < min then
			return minColor
		elseif healthPercent > max then
			return maxColor
		end

	
		local numeratorSum = Vector3.new(0,0,0)
		local denominatorSum = 0
		for colorSampleValue, samplePoint in pairs(healthColorToPosition) do
			local distance = healthPercent - samplePoint
			if distance == 0 then
				
				return Color3.new(colorSampleValue.x, colorSampleValue.y, colorSampleValue.z)
			else
				local wi = 1 / (distance*distance)
				numeratorSum = numeratorSum + wi * colorSampleValue
				denominatorSum = denominatorSum + wi
			end
		end
		local result = numeratorSum / denominatorSum
		return Color3.new(result.x, result.y, result.z)
	end
	
local NameTagsFolder = Instance.new("Folder")
NameTagsFolder.Name = "NameTagsFolder"
NameTagsFolder.Parent = GuiLibrary["MainGui"]
players.PlayerRemoving:connect(function(plr)
	if NameTagsFolder:FindFirstChild(plr.Name) then
		NameTagsFolder[plr.Name]:Remove()
	end
end)
local NameTagsColor = {["Value"] = 0.44}
local NameTagsHealth = {["Enabled"] = false}
local NameTags = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("NameTags", function() 
	game:GetService("RunService"):BindToRenderStep("NameTags", 500, function()
		for i,plr in pairs(players:GetChildren()) do
				local thing
				if NameTagsFolder:FindFirstChild(plr.Name) then
					thing = NameTagsFolder[plr.Name]
					thing.Visible = false
				else
					thing = Instance.new("TextLabel")
					thing.BackgroundTransparency = 0.5
					thing.BackgroundColor3 = Color3.new(0, 0, 0)
					thing.BorderSizePixel = 0
					thing.Visible = false
					thing.RichText = true
					thing.Name = plr.Name
					thing.Font = (GuiLibrary["ObjectsThatCanBeSaved"]["VapeOptionsSmooth fontToggle"]["Api"]["Enabled"] and Enum.Font.SourceSans or Enum.Font.Sarpanch)
					thing.TextSize = 14
					if plr.Character and plr.Character:FindFirstChild("Humanoid") then
						local rawText = plr.Name
						if NameTagsHealth["Enabled"] then
							rawText = plr.Name.." "..math.floor(plr.Character.Humanoid.Health)
						end
						local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
						local modifiedText = plr.Name
						if NameTagsHealth["Enabled"] then
							modifiedText = plr.Name..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.floor(plr.Character.Humanoid.Health).."</font>"
						end
						local nametagSize = game:GetService("TextService"):GetTextSize(rawText, thing.TextSize, thing.Font, Vector2.new(100000, 100000))
						thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
						thing.Text = modifiedText
					else
						local nametagSize = game:GetService("TextService"):GetTextSize(plr.Name, thing.TextSize, thing.Font, Vector2.new(100000, 100000))
						thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
						thing.Text = plr.Name
					end
					thing.TextColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(NameTagsColor["Value"], 1, 1)
					thing.Parent = NameTagsFolder
				end
				
				if isPlayerTargetable(plr, false, false) then
					local headPos, headVis = cam:WorldToViewportPoint((plr.Character.HumanoidRootPart:GetRenderCFrame() * CFrame.new(0, plr.Character.Head.Size.Y + plr.Character.HumanoidRootPart.Size.Y, 0)).Position)
					
					if headVis then
						local rawText = plr.Name
						if NameTagsHealth["Enabled"] then
							rawText = plr.Name.." "..math.floor(plr.Character.Humanoid.Health)
						end
						local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
						local modifiedText = plr.Name
						if NameTagsHealth["Enabled"] then
							modifiedText = plr.Name..' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.floor(plr.Character.Humanoid.Health).."</font>"
						end
						local nametagSize = game:GetService("TextService"):GetTextSize(rawText, thing.TextSize, thing.Font, Vector2.new(100000, 100000))
						thing.Size = UDim2.new(0, nametagSize.X + 4, 0, nametagSize.Y)
						thing.Text = modifiedText
						thing.TextColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(NameTagsColor["Value"], 1, 1)
						thing.Visible = headVis
						thing.Position = UDim2.new(0, headPos.X - thing.Size.X.Offset / 2, 0, (headPos.Y - thing.Size.Y.Offset) - 36)
					end
				end
			end

	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("NameTags") NameTagsFolder:ClearAllChildren() end, true)
NameTagsColor = NameTags.CreateColorSlider("Player Color", function(val) end)
NameTagsHealth = NameTags.CreateToggle("Health", function() end, function() end)
local TracersFolder = Instance.new("Folder")
TracersFolder.Name = "TracersFolder"
TracersFolder.Parent = GuiLibrary["MainGui"]
players.PlayerRemoving:connect(function(plr)
	if TracersFolder:FindFirstChild(plr.Name) then
		TracersFolder[plr.Name]:Remove()
	end
end)
local TracersColor = {["Value"] = 0.44}
local Tracers = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("Tracers", function() 
	game:GetService("RunService"):BindToRenderStep("Tracers", 500, function()
		for i,plr in pairs(players:GetChildren()) do
				local thing
				if TracersFolder:FindFirstChild(plr.Name) then
					thing = TracersFolder[plr.Name]
					if thing.Visible then
						thing.Visible = false
					end
				else
					thing = Instance.new("Frame")
					thing.BackgroundTransparency = 0
					thing.AnchorPoint = Vector2.new(0.5, 0.5)
					thing.BackgroundColor3 = Color3.new(0, 0, 0)
					thing.BorderSizePixel = 0
					thing.Visible = false
					thing.Name = plr.Name
					thing.Parent = TracersFolder
				end
				
				if isPlayerTargetable(plr, false, false) then
					local rootScrPos = cam:WorldToViewportPoint(plr.Character.Head.Position)
					local tempPos = cam.CFrame:pointToObjectSpace(plr.Character.Head.Position)
					if rootScrPos.Z < 0 then
						tempPos = CFrame.Angles(0, 0, (math.atan2(tempPos.Y, tempPos.X) + math.pi)):vectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):vectorToWorldSpace(Vector3.new(0, 0, -1))));
					end
					local tracerPos = cam:WorldToViewportPoint(cam.CFrame:pointToWorldSpace(tempPos))
					local screensize = cam.ViewportSize
					local startVector = Vector2.new(screensize.X / 2, screensize.Y / 2)
					local endVector = Vector2.new(tracerPos.X, tracerPos.Y)
					local Distance = (startVector - endVector).Magnitude
					thing.Visible = true
					thing.BackgroundColor3 = tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or Color3.fromHSV(TracersColor["Value"], 1, 1)
					thing.Size = UDim2.new(0, Distance, 0, 2)
					thing.Position = UDim2.new(0, (startVector.X + endVector.X) / 2, 0, ((startVector.Y + endVector.Y) / 2) - 36)
					thing.Rotation = math.atan2(endVector.Y - startVector.Y, endVector.X - startVector.X) * (180 / math.pi)
				end
			end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("Tracers") TracersFolder:ClearAllChildren() end, true)
TracersColor = Tracers.CreateColorSlider("Player Color", function(val) end)
