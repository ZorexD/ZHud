local w, h = ScrW(), ScrH()
local ply = LocalPlayer()
local mul
local count = 0
local currclass 
local checkclass
local currammo
local ammostate = 0
local strammostate = 0
local ammoprecentage = 0
local ammopos = 0
local ammofont = "Zhud1Font"
local magazines = 0
local drawcolor = Color(255,255,255)

local ignoreclasses = 
{
	"weapon_physgun",
	"gmod_tool",
	"weapon_physcannon",
	"stunstick"
}

hook.Add("HUDPaint", "ZHudAmmo", function()
	ply = LocalPlayer()
	if (IsValid(ply)) then
		if (ply:Alive()) then
			if (ply:GetActiveWeapon():IsValid()) then
				if (not table.HasValue(ignoreclasses, ply:GetActiveWeapon():GetClass())) then
					ammo =  ply:GetActiveWeapon():Clip1()
					magazines = ply:GetAmmoCount(ply:GetActiveWeapon():GetPrimaryAmmoType())
					ammoprecentage = (ply:GetActiveWeapon():Clip1() / ply:GetActiveWeapon():GetMaxClip1()) * 100

					if (ammoprecentage <= 20) then
						drawcolor = Color(255,0,0)
					else
						drawcolor = Color(255,255,255)
					end

					if (ammo == 0) then
						ammopos = h - 120
						ammofont = "Zhud3Font"
					else
						ammopos = h - 100
						ammofont = "Zhud1Font"
					end

					if ((ammo + magazines) != 0) then
						currclass = ply:GetActiveWeapon():GetClass()

						if (currclass != checkclass) then
							count = 0
						end

						if (count == 0) then
							currammo = ply:GetActiveWeapon():GetMaxClip1()
							checkclass = currclass
							mul = 360 / ammo
							count = 1
						end

						strammostate = ply:GetActiveWeapon():Clip1()
						ammostate = Lerp(0.1,ammostate,ply:GetActiveWeapon():Clip1() * mul)
						if (strammostate < currammo) then
							ammofont = "Zhud3Font"
							ammopos = h - 120
							timer.Simple(.02, function () ammofont = "Zhud1Font" currammo = ply:GetActiveWeapon():Clip1() end)
						end

						if(strammostate == ply:GetActiveWeapon():GetMaxClip1()) then
							ammopos = h - 100
							currammo = ply:GetActiveWeapon():GetMaxClip1()
						end

						draw.CircleCustom(w - 100,ScrH() - 75,8,8, ammostate,drawcolor,-62,0 )
						draw.SimpleText(strammostate, ammofont, w-102, ammopos, drawcolor, TEXT_ALIGN_CENTER, nil)
						draw.SimpleText(magazines, "Zhud2Font", w-102, h - 70, Color(255,255,255), TEXT_ALIGN_CENTER, nil)
					end
				end
			end
		end
	end

end)