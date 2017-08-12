--EvanTheBuilder: Minimap GUI Script V1.0
--Written September 22nd, 2015

--This script uses ETB:GlobalDebugModule in V1.1 format	
require(workspace["ETB:GlobalDebugModule"])(script)function etb(m,p,e)etb_G(script,m,p,e)end

b = script.Parent
w = game.Workspace
p = game.Players.LocalPlayer

script:WaitForChild("Enemy")
script:WaitForChild("Enemy")

minimap_Time = 0.5
minimap_Range = 150
minimap_EnemyIcon = script.Enemy
minimap_AllyIcon = script.Ally

whitelist = {"EvanTheBuilder","Vultre"}
blacklist = {"Zombie"}

function checkIfHumanoid(object)
	local found = false
	if object:IsA("Model") then
		for _,c in pairs(object:GetChildren()) do
			if c:IsA("Humanoid") then
				found = true
			elseif c:IsA("Part") and c.Name == "Torso" then
				found = true
			end
		end
	end
	if object == p.Character then found = false end
	return found
end

function checkIfFriendly(object)
	local friendly = true
	for _,c in ipairs(blacklist) do
		if object.Name == c then
			friendly = false
		end
	end
	return friendly
end


function showEnemy(x, y)                              --magnitude from 0 to 1 of 50
	local nme = minimap_EnemyIcon:Clone()
	nme.Parent = b.MinimapBack
	nme.Position = UDim2.new(x, -8, y, -8)
	spawn(function()
		wait(1/(0.1-minimap_Time))
		for i = 0, 1, 0.075 do
			wait(1/(100*minimap_Time))
			nme.ImageTransparency = i
		end
	nme:Destroy()end)
end

function showAlly(x, y, dir, a)
	local ali
	if not b.MinimapBack:FindFirstChild(a.Name) then
		ali = minimap_AllyIcon:Clone()
		ali.Parent = b.MinimapBack
		ali.Name = a.Name
	else
		ali = b.MinimapBack:FindFirstChild(a.Name)
	end
	ali.Position = UDim2.new(x, -9, y, -9)
	local heading = math.atan2(dir.x, dir.z)
	heading = math.deg(heading)
	ali.Rotation = 180 - heading
end

function getMinimapCoords(c)
	local partRef = nil
	if c:FindFirstChild("Torso") then
		partRef = c.Torso
	elseif c:FindFirstChild("Head") then
		partRef = c.Head
	else
		etb("Minimap draw error! Model " .. c .. " incorrectly passed as humanoid!", 2, true)
	end
	local xdist = (p.Character.Torso.Position.X - partRef.Position.X)
	local zdist = (p.Character.Torso.Position.Z - partRef.Position.Z)
	local dir = partRef.CFrame.lookVector
	local magnitude = math.sqrt(xdist^2 + zdist^2)
	local x_mag = 0.5 - (xdist)/(minimap_Range)
	local z_mag = 0.5 - (zdist)/(minimap_Range)
	if x_mag < 0 then x_mag = 0 end
	if z_mag < 0 then z_mag = 0 end
	if x_mag > 1 then x_mag = 1 end
	if z_mag > 1 then z_mag = 1 end
	local xfc = 0.5 - (x_mag)
	local zfc = 0.5 - (z_mag)
	local radius = math.sqrt(xfc^2 + zfc^2)
	if radius > 0.5 then
		local angle = math.atan2(zfc, xfc)  --theta = arctan(z/x)
		x_mag = 0.5 - (0.5 * (math.cos(angle)))  --(0.5costheta, 0.5sintheta)
		z_mag = 0.5 - (0.5 * (math.sin(angle)))
	end
	return x_mag, z_mag, dir
end

function checkForEnemies()
	if p.Character.Humanoid.Health > 0 then
		for _,c in pairs(workspace:GetChildren()) do
			if checkIfHumanoid(c) then
				local x_coord, z_coord = getMinimapCoords(c)
				if not checkIfFriendly(c) then showEnemy(x_coord, z_coord) end
			end
		end
	end
end

function checkForAllies()
	if p.Character.Humanoid.Health > 0 then
		for _,c in pairs(workspace:GetChildren()) do
			if checkIfHumanoid(c) and checkIfFriendly(c) then
				local x_coord, z_coord, dir = getMinimapCoords(c)
				showAlly(x_coord, z_coord, dir, c)
			end
		end
	end
end
	
function rotateMinimap()
	local look = p.Character.Torso.CFrame.lookVector
	local heading = math.atan2(look.x, look.z)
	heading = math.deg(heading)
	b.MinimapBack.Rotation = heading + 180
end

enemyChecker = coroutine.create(function()
	while true do
		wait(minimap_Time)
		checkForEnemies()
	end
end)

coroutine.resume(enemyChecker)
etb("EnemyChecker initiated", 1)

allyChecker = coroutine.create(function()
	while true do
		wait()
		checkForAllies()
	end
end)

coroutine.resume(allyChecker)
etb("AllyChecker initiated", 1)

etb("Initiating Minimap for " .. p.Name, 1)
while true do
	wait()
	rotateMinimap()
end
