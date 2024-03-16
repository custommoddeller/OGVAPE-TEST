-- Credits to Inf Yield & all the other scripts that helped me make bypasses
local GuiLibrary = shared.GuiLibrary
local players = game:GetService("Players")
local lplr = players.LocalPlayer
local workspace = game:GetService("Workspace")
local lighting = game:GetService("Lighting")
local cam = workspace.CurrentCamera
local targetinfo = shared.VapeTargetInfo
local uis = game:GetService("UserInputService")
local mouse = lplr:GetMouse()
local robloxfriends = {}
local bedwars = {}
local getfunctions
getfunctions = function()
	for i,v in pairs(getgc(true)) do
		if type(v) == "table" then
			if rawget(v, "blocksFolder") then
				bedwars["BlockController"] = v
			end
			if rawget(v, "launchProjectile") then
			    local bowtable1 = debug.getconstants(debug.getupvalues(v["launchProjectile"])[2])
			    for i3 = 1, #bowtable1 do
			        if tostring(bowtable1[i3]):match("-") then
			            bedwars["FireProjectile"] = bowtable1[i3]
			        end
			    end
			end
			if rawget(v, "SwordController") then
				bedwars["SwordController"] = v["SwordController"]
			end
			if rawget(v, "attackEntity") then
				bedwars["attackEntity"] = v["attackEntity"]
			end
			if rawget(v, "requestSelfDamage") then
				bedwars["damageTable"] = v
			end
			for i2,v2 in pairs(v) do
				if tostring(i2):match("sprinting") and type(v2) == "boolean" then
					bedwars["sprintTable"] = v
				  end
				if tostring(i2):match("placeBlock") then
					bedwars["placeBlock"] = function(newpos)
						v2(bedwars["BlockController"], "wool_"..lplr.Team.Name:lower(), Vector3.new(newpos.X / 3, newpos.Y / 3, newpos.Z / 3), {["skipCulling"] = true, ["player"] = lplr})
						game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.PlaceBlock:InvokeServer({
							["position"] = Vector3.new(newpos.X / 3, newpos.Y / 3, newpos.Z / 3),
							["blockType"] = "wool_"..lplr.Team.Name:lower()
						})
					end
				end
			end
		end
	end

	if bedwars["FireProjectile"] and bedwars["BlockController"] and bedwars["SwordController"] and bedwars["attackEntity"] and bedwars["damageTable"] and bedwars["sprintTable"] then

	else
		wait(1)
		getfunctions()
	end
end
getfunctions()
bedwars["breakBlock"] = function(pos)
    game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.BreakBlock:InvokeServer({
        ["blockRef"] = {
            ["blockPosition"] = Vector3.new(math.floor(pos.X / 3), math.floor(pos.Y / 3), math.floor(pos.Z / 3))
        },
        ["hitPosition"] = pos,
        ["hitNormal"] = Vector3.new(1, 0, 0)
    })
end

local function friendCheck(plr)
	if not robloxfriends[plr.UserId] then
		if lplr:IsFriendsWith(plr.UserId) then
			table.insert(robloxfriends, plr.Name)
			robloxfriends[plr.UserId] = true
		end
	end
	return (GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] and ((GuiLibrary["ObjectsThatCanBeSaved"]["Use Roblox FriendsToggle"]["Api"]["Enabled"] and table.find(robloxfriends, plr.Name) == nil) and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) == nil) or GuiLibrary["ObjectsThatCanBeSaved"]["Use FriendsToggle"]["Api"]["Enabled"] == false)
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

local function getEquipped()
	local type = ""
	local obj = (isAlive() and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value or nil)
	if obj then
		if obj.Name:match("sword") then
			type = "sword"
		end
		if obj.Name:match("wool") then
			type = "block"
		end
		if obj.Name:match("bow") then
			type = "bow"
		end
	end
    return {["Object"] = obj, ["Type"] = type}
end

local function isPlayerTargetable(plr, target, friend)
    return plr ~= lplr and GuiLibrary["ObjectsThatCanBeSaved"]["PlayersToggle"]["Api"]["Enabled"] and plr and isAlive(plr) and targetCheck(plr, target) and teamCheck(plr)
end

local function vischeck(char, part)
	return not unpack(cam:GetPartsObscuringTarget({lplr.Character[part].Position, char[part].Position}, {lplr.Character, char}))
end

local function GetAllNearestHumanoidToPosition(distance, amount)
	local returnedplayer = {}
	local currentamount = 0
    if isAlive() then
        for i, v in pairs(players:GetChildren()) do
            if isPlayerTargetable(v, true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") and currentamount < amount then
                local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                if mag <= distance then
                    table.insert(returnedplayer, v)
					currentamount = currentamount + 1
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
            if isPlayerTargetable(v, true, false) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
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

local function findTouchInterest(tool)
	for i,v in pairs(tool:GetDescendants()) do
		if v:IsA("TouchTransmitter") then
			return v
		end
	end
	return nil
end

local aimfov = {["Value"] = 1}
local aimvischeck = {["Enabled"] = false}
local aimheadshotchance = {["Value"] = 1}
local aimhitchance = {["Value"] = 1}
local aimmethod = {["Value"] = "FindPartOnRayWithIgnoreList"}
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
end, true, function() 
	if aimmethod["Value"]:match("FindPartOnRay") then
		return " Ray"
	else
		return " "..string.gsub(aimmethod["Value"], "PointToRay", "") 
	end
end)
aimmethod = AimAssist.CreateDropdown("Method", {"FindPartOnRayWithIgnoreList", "FindPartOnRayWithWhitelist", "Raycast", "FindPartOnRay", "ScreenPointToRay", "ViewportPointToRay", "Mouse"}, function(val) end)
local aimtable = {["FindPartOnRayWithIgnoreList"] = 1, ["FindPartOnRayWithWhitelist"] = 1, ["Raycast"] = 2, ["FindPartOnRay"] = 1, ["ScreenPointToRay"] = 3, ["ViewportPointToRay"] = 3, ["Mouse"] = 4}
aimvischeck = AimAssist.CreateToggle("Wall Check", function() end, function() end)
aimfov = AimAssist.CreateSlider("FOV", 1, 1000, function(val) end)
aimhitchance = AimAssist.CreateSlider("Hit Chance", 1, 100, function(val) end)
aimheadshotchance = AimAssist.CreateSlider("Headshot Chance", 1, 100, function(val) end)

kek = function()

end

local autoclickercps = {["GetRandomValue"] = function() return 1 end}
local autoclicker = {["Enabled"] = false}
local autoclickertick = tick()
autoclicker = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton("AutoClicker", function()
	game:GetService("RunService"):BindToRenderStep("AutoClicker", 1, function() 
		local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
		if tool and isAlive() and uis:IsMouseButtonPressed(0) and autoclickertick <= tick() then
			tool:Activate()
			autoclickertick = tick() + (1 / autoclickercps["GetRandomValue"]()) * Random.new().NextNumber(Random.new(), 0.75, 1)
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("AutoClicker") end, true)
autoclickercps = autoclicker.CreateTwoSlider("CPS", 1, 20, function(val) end, false, 8, 12)

local reachrange = {["Value"] = 1}
local oldsize = {}
local Reach = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton("Reach", function()
	game:GetService("RunService"):BindToRenderStep("Reach", 1, function() 
		local tool = lplr and lplr.Character and lplr.Character:FindFirstChildWhichIsA("Tool")
		if tool and isAlive() then
			local touch = findTouchInterest(tool)
			if touch then
				local size = rawget(oldsize, tool.Name)
				if size then
					touch.Parent.Size = Vector3.new(size.X + reachrange["Value"], size.Y, size.Z + reachrange["Value"])
					touch.Parent.Massless = true
				else
					oldsize[tool.Name] = touch.Parent.Size
				end
			end
		end
	end)
end, function() 
	game:GetService("RunService"):UnbindFromRenderStep("Reach")
	for i2,v2 in pairs(lplr.Character:GetChildren()) do
		if v2:IsA("Tool") and rawget(oldsize, v2.Name) then
			local touch = findTouchInterest(v2)
			if touch then
				touch.Parent.Size = rawget(oldsize, v2.Name)
				touch.Parent.Massless = false
			end
		end
	end
	for i2,v2 in pairs(lplr.Backpack:GetChildren()) do
		if v2:IsA("Tool") and rawget(oldsize, v2.Name) then
			local touch = findTouchInterest(v2)
			if touch then
				touch.Parent.Size = rawget(oldsize, v2.Name)
				touch.Parent.Massless = false
			end
		end
	end
	oldsize = {}
end, true)
reachrange = Reach.CreateSlider("Range", 1, 20, function(val) end)
local Sprint = {["Enabled"] = false}
Sprint = GuiLibrary["ObjectsThatCanBeSaved"]["CombatWindow"]["Api"].CreateOptionsButton("Sprint", function()
	spawn(function()
		repeat
			wait()
			if bedwars["sprintTable"].sprinting == false then
				getmetatable(bedwars["sprintTable"])["startSprinting"](bedwars["sprintTable"])
			end
		until Sprint["Enabled"] == false
	end)
end, function() end, true)

local Blink = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Blink", function() 
	settings():GetService("NetworkSettings").IncomingReplicationLag = 99999
end, function()
	settings():GetService("NetworkSettings").IncomingReplicationLag = 0
end, false)

local function getScaffold(vec)
    return Vector3.new(math.floor((vec.X / 3) + 0.5) * 3, math.floor((vec.Y / 3) + 0.5) * 3, math.floor((vec.Z / 3) + 0.5) * 3) 
end

local function scaffoldBlock(newpos)
    bedwars["placeBlock"](newpos)
end

local hitboxexpand = {["Value"] = 1}
local Hitbox =  GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("HitBoxes", function()
	game:GetService("RunService"):BindToRenderStep("HitBoxes", 1, function() 
		for i,plr in pairs(players:GetChildren()) do
			if isPlayerTargetable(plr, true, true) and isAlive(plr) then
				plr.Character.HumanoidRootPart.Size = Vector3.new(2 + (hitboxexpand["Value"] * 0.2), 2 + (hitboxexpand["Value"] * 0.2), 1 + (hitboxexpand["Value"] * 0.2))
			end
		end
	end)
end, function() 
	game:GetService("RunService"):UnbindFromRenderStep("HitBoxes") 
	for i,plr in pairs(players:GetChildren()) do
		if isAlive(plr) then
			plr.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
		end
	end
end, true)
hitboxexpand = Hitbox.CreateSlider("Expand amount", 1, 10, function(val) end)

local killaurarange = {["Value"] = 1}
local killauraangle = {["Value"] = 90}
local killauramouse = {["Enabled"] = false}
local killauracframe = {["Enabled"] = false}
local Killaura = {["Enabled"] = false}
local killauradelay = 0
Killaura = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Killaura", function()
	game:GetService("RunService"):BindToRenderStep("Killaura", 1, function() 
		local targettable = {}
		local targetsize = 0
		if (killauradelay <= tick()) then
			local plr = GetNearestHumanoidToPosition(killaurarange["Value"], false)
			if isAlive() and plr and plr.Character.PrimaryPart and lplr.Character.PrimaryPart and getEquipped()["Type"] == "sword" and (killauramouse["Enabled"] and uis:IsMouseButtonPressed(0) or killauramouse["Enabled"] == false) then
				if killauracframe["Enabled"] then
					lplr.Character:SetPrimaryPartCFrame(CFrame.new(lplr.Character.PrimaryPart.Position, Vector3.new(plr.Character:FindFirstChild("HumanoidRootPart").Position.X, lplr.Character.PrimaryPart.Position.Y, plr.Character:FindFirstChild("HumanoidRootPart").Position.Z)))
				end
				targettable[plr.Name] = {
					["UserId"] = plr.UserId,
					["Health"] = plr.Character.Humanoid.Health,
					["MaxHealth"] = plr.Character.Humanoid.MaxHealth
				}
				targetsize = targetsize + 1
				killauradelay = tick() + 0.1
				bedwars["attackEntity"](bedwars["SwordController"], {["instance"] = plr.Character, ["player"] = plr, ["getInstance"] = function() return plr.Character end})	
			end
			if getEquipped()["Type"] ~= "bow" then
				targetinfo.UpdateInfo(targettable, targetsize)
			end
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("Killaura") end, true, function()
	return " BedWars"
end)
killaurarange = Killaura.CreateSlider("Attack range", 1, 25, function(val) end)
killauraangle = Killaura.CreateSlider("Max angle", 1, 360, function(val) end, 90)
killauramouse = Killaura.CreateToggle("Require mouse down", function() end, function() end, false)
killauracframe = Killaura.CreateToggle("Face target", function() end, function() end)

local bednukerrange = {["Value"] = 1}
local BedNuker = {["Enabled"] = false}
BedNuker = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("BedNuker", function()
	spawn(function()
		repeat
			wait(0.2)
			local tab = game.Workspace.Map.Blocks:GetChildren()
			for i = 1, #tab do
				local obj = tab[i]
				pcall(function()
					if obj.Name == "bed" and (obj.Name:match(lplr.Team.Name:lower()) == nil) and (lplr.Character.HumanoidRootPart.Position - obj.Position).magnitude <= 20 then
						bedwars["breakBlock"](obj.Position)
					end
				end)
			end
		until BedNuker["Enabled"] == false
	end)
end, function() end, true)
bednukerrange = BedNuker.CreateSlider("Break range", 1, 20, function(val) end)

local fastbreak = {["Enabled"] = false}
fastbreak = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("FastBreak", function()
	spawn(function()
		repeat
			wait()
			local tab = game.Workspace.Map.Blocks:GetChildren()
			for i = 1, #tab do
				local obj = tab[i]
				obj:SetAttribute("Health", 0)
			end
		until fastbreak["Enabled"] == false
	end)
end, function() end, true)

local longjumpboost = {["Value"] = 1}
local longjump = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("LongJump", function()
	game:GetService("RunService"):BindToRenderStep("LongJump", 1, function() 
		if isAlive() then
			if (lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Freefall or lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Jumping) and lplr.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
				lplr.Character.HumanoidRootPart.Velocity = lplr.Character.HumanoidRootPart.Velocity + lplr.Character.Humanoid.MoveDirection * (longjumpboost["Value"] / 2.5)
			end
		end
	end)
end, function() game:GetService("RunService"):UnbindFromRenderStep("LongJump") end, true, function() return "" end, true)
longjumpboost = longjump.CreateSlider("Boost", 1, 5, function(val) end)

local speedval = {["Value"] = 1}
local speedmethod = {["Value"] = "AntiCheat A"}
local speedjump = {["Enabled"] = false}
local bodyvelo

local speed = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Speed", function()
	game:GetService("RunService"):BindToRenderStep("Speed", 1, function(delta)
		if isAlive() then
			if speedmethod["Value"] == "AntiCheat A" then
				if (bodyvelo == nil or bodyvelo ~= nil and bodyvelo.Parent ~= lplr.Character.HumanoidRootPart) then
					bodyvelo = Instance.new("BodyVelocity")
					bodyvelo.Parent = lplr.Character.HumanoidRootPart
					bodyvelo.MaxForce = Vector3.new(100000, 0, 100000)
				else
					bodyvelo.Velocity = lplr.Character.Humanoid.MoveDirection * speedval["Value"]
				end
			elseif speedmethod["Value"] == "AntiCheat B" then
				if (bodyvelo ~= nil) then
					bodyvelo:Remove()
				end
				lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + (lplr.Character.Humanoid.MoveDirection * (speedval["Value"] * delta))
			end
			if speedjump["Enabled"] then
				if (lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running or lplr.Character.Humanoid:GetState() == Enum.HumanoidStateType.RunningNoPhysics) and lplr.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0) then
					if speedmethod["Value"] == "AntiCheat A" then
						lplr.Character.HumanoidRootPart.Velocity = Vector3.new(lplr.Character.HumanoidRootPart.Velocity.X, 20, lplr.Character.HumanoidRootPart.Velocity.Z)
					elseif speedmethod["Value"] == "AntiCheat B" then
						lplr.Character.HumanoidRootPart.CFrame = lplr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 0.2, 0)
					end
				end
			end
		end
	end)
end, function() 
	if bodyvelo then
		bodyvelo:Remove()
	end
	game:GetService("RunService"):UnbindFromRenderStep("Speed")
end, true, function() return " "..speedmethod["Value"] end, true)
speedmethod = speed.CreateDropdown("Mode", {"AntiCheat A", "AntiCheat B"}, function(val) end)
speedval = speed.CreateSlider("Speed", 1, 150, function(val) end)
speedjump = speed.CreateToggle("AutoJump", function() end, function() end)

local Scaffold = {["Enabled"] = false}
local oldpos = Vector3.new(0, 0, 0)
Scaffold = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("Scaffold", function()
	game:GetService("RunService"):BindToRenderStep("Scaffold", 1, function(delta)
		if isAlive() then
			local newpos = getScaffold((lplr.Character.Head.Position + (lplr.Character.Humanoid.MoveDirection * 3.5)) + Vector3.new(0, -6, 0))
			if newpos ~= oldpos then
				local block = scaffoldBlock(newpos)
				oldpos = newpos
			end
		end
	end)
end, function()
	game:GetService("RunService"):UnbindFromRenderStep("Scaffold")
	oldpos = Vector3.new(0, 0, 0)
end, true)

local AutoToxic = {["Enabled"] = false}
local autotoxicconnection
AutoToxic = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("AutoToxic", function()
	autotoxicconnection = lplr.PlayerGui.ChildAdded:connect(function(obj)
		spawn(function()
			if obj:IsA("ScreenGui") and obj.Name:match("1") then
				for i2,v2 in pairs(obj:GetChildren()) do
					if v2.Name:match("2") then
						for i3,v3 in pairs(v2:GetChildren()) do
							if v3.Name:match("3") then
								for i4,v4 in pairs(v3:GetChildren()) do
									if v4:IsA("ImageLabel") then
										v4:GetPropertyChangedSignal("Image"):connect(function()
											if v4.Image:match(lplr.UserId) then
												game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("gg", "All")
												game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("EZ L TRASH KIDS", "All")
											end
										end)
									end
								end
							end
						end
					end
				end
			end
		end)
	end)	
end, function()
	autotoxicconnection:Disconnect()
end, true)

local BuyArrows = {["Enabled"] = false}
local BowAura = {["Enabled"] = false}
local bowaurarange = {["Value"] = 50}
local BowDelay2 = {["Value"] = 5}
local BowTargets = {["Value"] = 1}
BowAura = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("BowAura", function()
	spawn(function()
		repeat
			wait(BowDelay2["Value"] / 10)
			if isAlive() and getEquipped()["Type"] == "bow" then
				local targettable = {}
				local targetsize = 0
				local plrs = GetAllNearestHumanoidToPosition(bowaurarange["Value"], BowTargets["Value"])
				for i,v in pairs(plrs) do
					wait(0.03)
					if isPlayerTargetable(v, true, true) and v.Character and v.Character:FindFirstChild("Head") then
						local bowcheck = (getEquipped()["Object"].Name:match("crossbow") and "crossbow_arrow" or "arrow")
						targettable[v.Name] = {
							["UserId"] = v.UserId,
							["Health"] = v.Character.Humanoid.Health,
							["MaxHealth"] = v.Character.Humanoid.MaxHealth
						}
						targetsize = targetsize + 1
						game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged[bedwars["FireProjectile"]]:InvokeServer(getEquipped()["Object"])
						pcall(function()
							game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged["ed6af8d6-0758-484c-a404-6897b1a95c5e"]:InvokeServer(bowcheck, game.Workspace[bowcheck], {
								["part"] = v.Character.Head,
								["velocity"] = Vector3.new(1, 0, 0),
								["hitCFrame"] =  v.Character.Head.CFrame,
								["velocityMultiplier"] = 1
							})
						end)
					end
				end
				targetinfo.UpdateInfo(targettable, targetsize)
			end
		until BowAura["Enabled"] == false
	end)
end, function() end, true)
bowaurarange = BowAura.CreateSlider("Bow Range", 1, 70, function(val) end, 70)
BowDelay2 = BowAura.CreateSlider("Bow Delay", 1, 20, function(val) end, 5)
BowTargets = BowAura.CreateSlider("Bow Targets", 1, 20, function(val) end, 1)

local BuyArrows = {["Enabled"] = false}
local BowExploit = {["Enabled"] = false}
local BowDelay = {["Value"] = 10}
BowExploit = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("BowExploit", function()
	spawn(function()
		repeat
			wait(BowDelay["Value"] / 10)
			if isAlive() and getEquipped()["Type"] == "bow" then
				if BuyArrows["Enabled"] then
					local args = {
						[1] = {
							["shopItem"] = {
								["price"] = 16,
								["currency"] = "iron",
								["itemType"] = "arrow",
								["amount"] = 8
							}
						}
					}
					
					game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.BedwarsPurchaseItem:InvokeServer(unpack(args))
					game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.BedwarsPurchaseItem:InvokeServer(unpack(args))
				end
				local targettable = {}
				local targetsize = 0
				for i,v in pairs(players:GetChildren()) do
					if isPlayerTargetable(v, true, true) and v.Character and v.Character:FindFirstChild("Head") then
						local bowcheck = (getEquipped()["Object"].Name:match("crossbow") and "crossbow_arrow" or "arrow")
						targettable[v.Name] = {
							["UserId"] = v.UserId,
							["Health"] = v.Character.Humanoid.Health,
							["MaxHealth"] = v.Character.Humanoid.MaxHealth
						}
						targetsize = targetsize + 1
						game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged[bedwars["FireProjectile"]]:InvokeServer(getEquipped()["Object"])
						pcall(function()
							game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged["ed6af8d6-0758-484c-a404-6897b1a95c5e"]:InvokeServer(bowcheck, game.Workspace[bowcheck], {
								["part"] = v.Character.Head,
								["velocity"] = Vector3.new(1, 0, 0),
								["hitCFrame"] =  v.Character.Head.CFrame,
								["velocityMultiplier"] = 1
							})
						end)
					end
				end
				targetinfo.UpdateInfo(targettable, targetsize)
			end
		until BowExploit["Enabled"] == false
	end)
end, function() end, true)
BowDelay = BowExploit.CreateSlider("Bow Delay", 1, 20, function(val) end, 10)
BuyArrows = BowExploit.CreateToggle("Buy Arrows", function() end, function() end, true)

local OldNoFallFunction
local NoFall = GuiLibrary["ObjectsThatCanBeSaved"]["BlatantWindow"]["Api"].CreateOptionsButton("NoFall", function()
	OldNoFallFunction = bedwars["damageTable"]["requestSelfDamage"]
	bedwars["damageTable"]["requestSelfDamage"] = function() end
end, function()
	bedwars["damageTable"]["requestSelfDamage"] = OldNoFallFunction
end, true)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = GuiLibrary["MainGui"]
players.PlayerRemoving:connect(function(plr)
	if ESPFolder:FindFirstChild(plr.Name) then
		ESPFolder[plr.Name]:Remove()
	end
end)
local ESPColor = {["Value"] = 0.44}
local ESPMethod = {["Value"] = "2D"}
local ESP = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("ESP", function() 
	game:GetService("RunService"):BindToRenderStep("ESP", 500, function()
		for i,plr in pairs(players:GetChildren()) do
			if ESPMethod["Value"] == "2D" then
				local thing
				if ESPFolder:FindFirstChild(plr.Name) then
					thing = ESPFolder[plr.Name]
					thing.Visible = false
					thing.Line1.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line2.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line3.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					thing.Line4.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
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
					line1.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line1.Parent = thing
					local line2 = Instance.new("Frame")
					line2.BorderSizePixel = 0
					line2.Name = "Line2"
					line2.Size = UDim2.new(1, 0, 0, 3)
					line2.Position = UDim2.new(0, 0, 1, -3)
					line2.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line2.Parent = thing
					local line3 = Instance.new("Frame")
					line3.BorderSizePixel = 0
					line3.Name = "Line3"
					line3.Size = UDim2.new(0, 3, 1, 0)
					line3.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line3.Parent = thing
					local line4 = Instance.new("Frame")
					line4.BorderSizePixel = 0
					line4.Name = "Line4"
					line4.Size = UDim2.new(0, 3, 1, 0)
					line4.Position = UDim2.new(1, -3, 0, 0)
					line4.BackgroundColor3 = (GuiLibrary["ObjectsThatCanBeSaved"]["Use colorToggle"]["Api"]["Enabled"] and table.find(GuiLibrary["FriendsObject"]["Friends"], plr.Name) and Color3.fromHSV(GuiLibrary["ObjectsThatCanBeSaved"]["Friends ColorSliderColor"]["Api"]["Value"], 1, 1)) or tostring(plr.TeamColor) ~= "White" and plr.TeamColor.Color or Color3.fromHSV(ESPColor["Value"], 1, 1)
					line4.Parent = thing
				end
				
				if isPlayerTargetable(plr, false, false) then
					local rootPos, rootVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
					local rootSize = plr.Character.HumanoidRootPart.Size.X * 1500
					local headPos, headVis = cam:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0, 1, 0))
					local legPos, legVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0, 4 + plr.Character.Humanoid.HipHeight, 0))
					rootPos = rootPos * (1 / GuiLibrary["MainRescale"].Scale)
					
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
ESPMethod = ESP.CreateDropdown("Mode", {"2D", "3D"}, function(val) end)
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
local NameTagsDisplayName = {["Enabled"] = false}
local NameTagsHealth = {["Enabled"] = false}
local NameTagsDistance = {["Enabled"] = false}
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
					if plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("HumanoidRootPart") then
						local rawText = (NameTagsDisplayName["Enabled"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name)
						if NameTagsHealth["Enabled"] then
							rawText = (NameTagsDisplayName["Enabled"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name).." "..math.floor(plr.Character.Humanoid.Health)
						end
						local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
						local modifiedText = (NameTagsDistance["Enabled"] and isAlive() and '<font color="rgb(85, 255, 85)">[</font>'..math.floor((lplr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude)..'<font color="rgb(85, 255, 85)">]</font> ' or '')..(NameTagsDisplayName["Enabled"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name)..(NameTagsHealth["Enabled"] and ' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.floor(plr.Character.Humanoid.Health).."</font>" or '')
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
					headPos = headPos * (1 / GuiLibrary["MainRescale"].Scale)
					
					if headVis then
						local rawText = (NameTagsDistance["Enabled"] and isAlive() and "["..math.floor((lplr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude).."] " or "")..(NameTagsDisplayName["Enabled"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name)..(NameTagsHealth["Enabled"] and " "..math.floor(plr.Character.Humanoid.Health) or "")
						local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
						local modifiedText = (NameTagsDistance["Enabled"] and isAlive() and '<font color="rgb(85, 255, 85)">[</font><font color="rgb(255, 255, 255)">'..math.floor((lplr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude)..'</font><font color="rgb(85, 255, 85)">]</font> ' or '')..(NameTagsDisplayName["Enabled"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name)..(NameTagsHealth["Enabled"] and ' <font color="rgb('..tostring(math.floor(color.R * 255))..','..tostring(math.floor(color.G * 255))..','..tostring(math.floor(color.B * 255))..')">'..math.floor(plr.Character.Humanoid.Health).."</font>" or '')
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
NameTagsDisplayName = NameTags.CreateToggle("Use Display Name", function() end, function() end)
NameTagsHealth = NameTags.CreateToggle("Health", function() end, function() end)
NameTagsDistance = NameTags.CreateToggle("Distance", function() end, function() end)

local searchColor = {["Value"] = 0.44}
local searchModule = {["Enabled"] = false}
local searchFolder = Instance.new("Folder")
searchFolder.Name = "SearchFolder"
searchFolder.Parent = GuiLibrary["MainGui"]
local function searchFindBoxHandle(part)
	for i,v in pairs(searchFolder:GetChildren()) do
		if v.Adornee == part then
			return v
		end
	end
	return nil
end
local searchAdd
local searchRemove
local searchRefresh = function()
	searchFolder:ClearAllChildren()
	if searchModule["Enabled"] then
		for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and table.find(GuiLibrary["Settings"]["SearchObject"]["List"], v.Name) and searchFindBoxHandle(v) == nil then
				local boxhandle = Instance.new("BoxHandleAdornment")
				boxhandle.Name = v.Name
				boxhandle.AlwaysOnTop = true
				boxhandle.Color3 = Color3.fromHSV(searchColor["Value"], 1, 1)
				boxhandle.Adornee = v
				boxhandle.ZIndex = 10
				boxhandle.Size = v.Size
				boxhandle.Transparency = 0.5
				boxhandle.Parent = searchFolder
			end
		end
	end
end
local searchTextList = {["RefreshValues"] = function() end}
searchModule = GuiLibrary["ObjectsThatCanBeSaved"]["RenderWindow"]["Api"].CreateOptionsButton("Search", function() 
	searchRefresh()
	searchAdd = workspace.DescendantAdded:connect(function(v)
		if v:IsA("BasePart") and table.find(GuiLibrary["Settings"]["SearchObject"]["List"], v.Name) and searchFindBoxHandle(v) == nil then
			local boxhandle = Instance.new("BoxHandleAdornment")
			boxhandle.Name = v.Name
			boxhandle.AlwaysOnTop = true
			boxhandle.Color3 = Color3.fromHSV(searchColor["Value"], 1, 1)
			boxhandle.Adornee = v
			boxhandle.ZIndex = 10
			boxhandle.Size = v.Size
			boxhandle.Transparency = 0.5
			boxhandle.Parent = searchFolder
		end
	end)
	searchRemove = workspace.DescendantRemoving:connect(function(v)
		if v:IsA("BasePart") then
			local boxhandle = searchFindBoxHandle(v)
			if boxhandle then
				boxhandle:Remove()
			end
		end
	end)
end, function() 
	pcall(function()
		searchFolder:ClearAllChildren()
		searchAdd:Disconnect()
		searchRemove:Disconnect()
	end)
end, false)
searchColor = searchModule.CreateColorSlider("new part color", function(val)
	for i,v in pairs(searchFolder:GetChildren()) do
		v.Color3 = Color3.fromHSV(val, 1, 1)
	end
end)
SearchTextList = searchModule.CreateTextList("SearchList", "part name", function(user)
	table.insert(GuiLibrary["Settings"]["SearchObject"]["List"], user)
	SearchTextList["RefreshValues"](GuiLibrary["Settings"]["SearchObject"]["List"])
	searchRefresh()
end, function(num) 
	table.remove(GuiLibrary["Settings"]["SearchObject"]["List"], num) 
	SearchTextList["RefreshValues"](GuiLibrary["Settings"]["SearchObject"]["List"])
	searchRefresh()
end)

local XrayAdd
local Xray = GuiLibrary["ObjectsThatCanBeSaved"]["WorldWindow"]["Api"].CreateOptionsButton("Xray", function() 
	XrayAdd = workspace.DescendantAdded:connect(function(v)
		if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
			v.LocalTransparencyModifier = 0.5
		end
	end)
	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
			v.LocalTransparencyModifier = 0.5
		end
	end
end, function()
	for i, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") and not v.Parent.Parent:FindFirstChild("Humanoid") then
			v.LocalTransparencyModifier = 0
		end
	end
	XrayAdd:Disconnect()
end, false)

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
					startVector = startVector * (1 / GuiLibrary["MainRescale"].Scale)
					endVector = endVector * (1 / GuiLibrary["MainRescale"].Scale)
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

Spring = {} do
	Spring.__index = Spring

	function Spring.new(freq, pos)
		local self = setmetatable({}, Spring)
		self.f = freq
		self.p = pos
		self.v = pos*0
		return self
	end

	function Spring:Update(dt, goal)
		local f = self.f*2*math.pi
		local p0 = self.p
		local v0 = self.v

		local offset = goal - p0
		local decay = math.exp(-f*dt)

		local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
		local v1 = (f*dt*(offset*f - v0) + v0)*decay

		self.p = p1
		self.v = v1

		return p1
	end

	function Spring:Reset(pos)
		self.p = pos
		self.v = pos*0
	end
end

local cameraPos = Vector3.new()
local cameraRot = Vector2.new()
local velSpring = Spring.new(5, Vector3.new())
local panSpring = Spring.new(5, Vector2.new())

Input = {} do

	keyboard = {
		W = 0,
		A = 0,
		S = 0,
		D = 0,
		E = 0,
		Q = 0,
		Up = 0,
		Down = 0,
		LeftShift = 0,
	}

	mouse = {
		Delta = Vector2.new(),
	}

	NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
	PAN_MOUSE_SPEED = Vector2.new(3, 3)*(math.pi/64)
	NAV_ADJ_SPEED = 0.75
	NAV_SHIFT_MUL = 0.25

	navSpeed = 1

	function Input.Vel(dt)
		navSpeed = math.clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

		local kKeyboard = Vector3.new(
			keyboard.D - keyboard.A,
			keyboard.E - keyboard.Q,
			keyboard.S - keyboard.W
		)*NAV_KEYBOARD_SPEED

		local shift = uis:IsKeyDown(Enum.KeyCode.LeftShift)

		return (kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
	end

	function Input.Pan(dt)
		local kMouse = mouse.Delta*PAN_MOUSE_SPEED
		mouse.Delta = Vector2.new()
		return kMouse
	end

	do
		function Keypress(action, state, input)
			keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
			return Enum.ContextActionResult.Sink
		end

		function MousePan(action, state, input)
			local delta = input.Delta
			mouse.Delta = Vector2.new(-delta.y, -delta.x)
			return Enum.ContextActionResult.Sink
		end

		function Zero(t)
			for k, v in pairs(t) do
				t[k] = v*0
			end
		end

		function Input.StartCapture()
			game:GetService("ContextActionService"):BindActionAtPriority("FreecamKeyboard",Keypress,false,Enum.ContextActionPriority.High.Value,
			Enum.KeyCode.W,
			Enum.KeyCode.A,
			Enum.KeyCode.S,
			Enum.KeyCode.D,
			Enum.KeyCode.E,
			Enum.KeyCode.Q,
			Enum.KeyCode.Up,
			Enum.KeyCode.Down
			)
			game:GetService("ContextActionService"):BindActionAtPriority("FreecamMousePan",MousePan,false,Enum.ContextActionPriority.High.Value,Enum.UserInputType.MouseMovement)
		end

		function Input.StopCapture()
			navSpeed = 1
			Zero(keyboard)
			Zero(mouse)
			game:GetService("ContextActionService"):UnbindAction("FreecamKeyboard")
			game:GetService("ContextActionService"):UnbindAction("FreecamMousePan")
		end
	end
end

local function GetFocusDistance(cameraFrame)
	local znear = 0.1
	local viewport = cam.ViewportSize
	local projy = 2*math.tan(cameraFov/2)
	local projx = viewport.x/viewport.y*projy
	local fx = cameraFrame.rightVector
	local fy = cameraFrame.upVector
	local fz = cameraFrame.lookVector

	local minVect = Vector3.new()
	local minDist = 512

	for x = 0, 1, 0.5 do
		for y = 0, 1, 0.5 do
			local cx = (x - 0.5)*projx
			local cy = (y - 0.5)*projy
			local offset = fx*cx - fy*cy + fz
			local origin = cameraFrame.p + offset*znear
			local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
			local dist = (hit - origin).magnitude
			if minDist > dist then
				minDist = dist
				minVect = offset.unit
			end
		end
	end

	return fz:Dot(minVect)*minDist
end

local PlayerState = {} do
	mouseBehavior = ""
	mouseIconEnabled = ""
	cameraType = ""
	cameraFocus = ""
	cameraCFrame = ""
	cameraFieldOfView = ""

	function PlayerState.Push()
		cameraFieldOfView = cam.FieldOfView
		cam.FieldOfView = 70

		cameraType = cam.CameraType
		cam.CameraType = Enum.CameraType.Custom

		cameraCFrame = cam.CFrame
		cameraFocus = cam.Focus

		mouseIconEnabled = uis.MouseIconEnabled
		uis.MouseIconEnabled = true

		mouseBehavior = uis.MouseBehavior
		uis.MouseBehavior = Enum.MouseBehavior.Default
	end

	function PlayerState.Pop()
		cam.FieldOfView = cameraFieldOfView
        cameraFieldOfView = nil

		cam.CameraType = cameraType
		cameraType = nil

		cam.CFrame = cameraCFrame
		cameraCFrame = nil

		cam.Focus = cameraFocus
		cameraFocus = nil

		uis.MouseIconEnabled = mouseIconEnabled
		mouseIconEnabled = nil

		uis.MouseBehavior = mouseBehavior
		mouseBehavior = nil
	end
end

local Freecam = GuiLibrary["ObjectsThatCanBeSaved"]["WorldWindow"]["Api"].CreateOptionsButton("Freecam", function()
	local cameraCFrame = cam.CFrame
	if pos then
		cameraCFrame = pos
	end
	cameraRot = Vector2.new()
	cameraPos = cameraCFrame.p
	cameraFov = cam.FieldOfView

	velSpring:Reset(Vector3.new())
	panSpring:Reset(Vector2.new())

	PlayerState.Push()
	game:GetService("RunService"):BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, function(dt)
        local vel = velSpring:Update(dt, Input.Vel(dt))
        local pan = panSpring:Update(dt, Input.Pan(dt))

        local zoomFactor = math.sqrt(math.tan(math.rad(70/2))/math.tan(math.rad(cameraFov/2)))

        cameraRot = cameraRot + pan*Vector2.new(0.75, 1)*8*(dt/zoomFactor)
        cameraRot = Vector2.new(math.clamp(cameraRot.x, -math.rad(90), math.rad(90)), cameraRot.y%(2*math.pi))

        local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*Vector3.new(1, 1, 1)*64*dt)
        cameraPos = cameraCFrame.p

        cam.CFrame = cameraCFrame
        cam.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
        cam.FieldOfView = cameraFov
    end)
	Input.StartCapture()
end, function() 
	Input.StopCapture()
	game:GetService("RunService"):UnbindFromRenderStep("Freecam")
	PlayerState.Pop()
end, true, function() return "" end, true)
freecamspeed = Freecam.CreateSlider("Speed", 1, 150, function(val) NAV_KEYBOARD_SPEED = Vector3.new(val / 75,  val / 75, val / 75) end, 75)

local Panic = GuiLibrary["ObjectsThatCanBeSaved"]["UtilityWindow"]["Api"].CreateOptionsButton("Panic", function()
	for i,v in pairs(GuiLibrary["ObjectsThatCanBeSaved"]) do
		if v["Type"] == "Button" or v["Type"] == "OptionsButton" then
			if v["Api"]["Enabled"] then
				v["Api"]["ToggleButton"]()
			end
		end
	end
end, function() end, false) 
