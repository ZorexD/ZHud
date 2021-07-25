local smoothedhealth = 0
local smoothedarmor = 0
local hp
local armor
local ply = LocalPlayer()

local plyinfo = {
	rpname,
	job,
	salary,
	money
}

local plyusergroup
local lowercase
local w, h = ScrW(), ScrH()

//This function was made by https://github.com/kruzgi/Garrys-Mod-Draw-Circle - credit to him for making it
function draw.CircleCustom( x, y, w, h, ang, color, x0, y0 )
    for i=0,ang do
        local c = math.cos(math.rad(i))
        local s = math.sin(math.rad(i))
        local newx = y0 * s - x0 * c
        local newy = y0 * c + x0 * s

        draw.NoTexture()
        surface.SetDrawColor(color)
        surface.DrawTexturedRectRotated(x + newx,y + newy,w,h,i)
    end
end

local function zhud_DrawCircleStats()
	--Intizialize all of these variables for every frame
	ply = LocalPlayer()
	hp = ply:Health()
	armor = ply:Armor()
    smoothedhealth = Lerp(0.1,smoothedhealth,hp)
    smoothedarmor = Lerp(0.1,smoothedarmor,armor)

    if(ply:Alive()) then
        draw.CircleCustom(75,ScrH() - 75,15,15,smoothedhealth * 3.6,Color(220,20,60),-50,0 )

        --First, checking if we need the armor circle, then we check where we should place the HP text
        if armor != 0 then
        	draw.SimpleText(hp,"Zhud1Font",75,ScrH() - 100,Color(255,255,255),TEXT_ALIGN_CENTER,nil)
        	draw.SimpleText(armor,"Zhud2Font",75,ScrH() - 75,Color(255,255,255),TEXT_ALIGN_CENTER,nil)
        	draw.CircleCustom(75,ScrH() - 75,5,5,smoothedarmor * 3.6,Color(65,105,225),-62,0 )
        else
        	draw.SimpleText(hp,"Zhud1Font",75,ScrH() - 75,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        end

    end

end

local function zhud_FormatGroup()
	lowercase = string.sub( plyusergroup, 0, 1)

	lowercase = string.upper(lowercase)
	plyusergroup = lowercase .. string.sub(plyusergroup, 2)

end

local function zhud_UpdatePlyDetails(var, newval)
	if (var and newval) then 
		plyinfo[var] = newval
	end
end

local function zhud_DrawRPStats(var, newval)
	draw.SimpleText(plyinfo["rpname"], "Zhud1Font", 130, h - 140, Color( 255, 255, 255, 255 ))
	draw.SimpleText(plyinfo["job"], "Zhud1Font", 140, h - 110, Color( 255, 255, 255, 255 ))
	draw.SimpleText(plyusergroup, "Zhud1Font", 140, h - 80, Color( 255, 255, 255, 255 ))
	draw.SimpleText(DarkRP.formatMoney(plyinfo["money"]) .. ' / '..DarkRP.formatMoney(plyinfo["salary"]), "Zhud2Font", 130, h - 45, Color( 0, 255, 0, 255 ))
end

net.Receive("ZHUDPlayerInitialSpawn", function ()
	if (IsValid(ply) and ply:Alive()) then
	 	plyinfo["rpname"] = ply:getDarkRPVar("rpname")
		plyinfo["job"] = ply:getDarkRPVar("job")
		plyinfo["money"] = ply:getDarkRPVar("money")
		plyinfo["salary"] = ply:getDarkRPVar("salary")
	end
end)

hook.Add("HUDPaint","ZHudDraw", function()
	plyusergroup = ply:GetNWString("usergroup")
	zhud_FormatGroup()
	zhud_DrawCircleStats() -- Drawing HP and Armor
	zhud_DrawRPStats() -- Drawing RP Stats (Name, Money, Salary, Job)
end)

hook.Add("DarkRPVarChanged", "UpdateRPStats", function(updateply, varname, old, new)
	if (ply == updateply) then
		zhud_UpdatePlyDetails(varname, new)
	end
end)

local hideHUDElements = {
    ["DarkRP_HUD"] = true,

    ["DarkRP_EntityDisplay"] = true,

    ["DarkRP_LocalPlayerHUD"] = true,

    ["DarkRP_Hungermod"] = false,

    ["DarkRP_Agenda"] = false,

    ["DarkRP_LockdownHUD"] = false,

    ["DarkRP_ArrestedHUD"] = false,

    ["DarkRP_ChatReceivers"] = false,

    ["CHudHealth"] = true,

    ["CHudBattery"] = true,

    ["CHudAmmo"] = true
}

-- this is the code that actually disables the drawing.
hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name)
    if hideHUDElements[name] then return false end
end)