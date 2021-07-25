local eyetraceply 
local drawoverinfo 
local smoothedhealth = 0
local smoothedarmor = 0
local hp = 0
local usergroup
local armor = 0
local drawtrans = 0
local door_max_dist = 700
local global_doors = global_doors or {}
local player_pos = Vector(0,0,0)
local RenderScaleMult = 1 / .1
local doortitle
local ply = LocalPlayer()
local unownedtext = "Press F2 to purchase."

local function DrawShadowedText(txt,f,x,y,c,align_horiz,align_vert)
	align_horiz = align_horiz or TEXT_ALIGN_CENTER
	align_vert = align_vert or TEXT_ALIGN_TOP
	return draw.SimpleText(txt, f, x, y, c, align_horiz, align_vert)
end

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

local function zhud_FormatGroup()
	lowercase = string.sub( usergroup, 0, 1)

	lowercase = string.upper(lowercase)
	usergroup = lowercase .. string.sub(usergroup, 2)

end 


hook.Add("HUDPaint", "ZHudOverHead", function()

	local doortext = ""

	if (IsValid(ply) and ply:GetEyeTrace().Entity and ply:GetEyeTrace()) then

		targ = ply:GetEyeTrace().Entity
		if (targ:GetPos() and ply:GetPos()) then
			dist = LocalPlayer():GetPos():Distance( targ:GetPos() )
		end

		print(dist)

		if targ then pos = targ:EyePos() end

		print(dist<300)
		if targ:isDoor() and targ:isKeysOwnable() then

			local door = targ
			hook.Add("PostDrawTranslucentRenderables", "ZHUDDrawDoors", function(_, depthDrawing)
				

			    if depthDrawing then return end

				local doorisfree = false
			    local ang = targ:GetAngles()
			    local textpos = 0
			    local posa = targ:GetPos()
			    local minB, maxB = targ:GetModelBounds()
				local base_dangle = targ:GetAngles()
				local door_width_x = math.abs(minB[1] - maxB[1])
				local door_width_y = math.abs(minB[2] - maxB[2])
				print(minB, maxB)
				local drawcolor = Color(255,255,255,255-dist)
				local door_width = door_width_y
				local textpos = door_width_x * 10
				local backposa = posa
				local backang = ang

				print(door_width_x, door_width_y)

				if (door_width_x > door_width_y) then 
					posa = posa
					ang = ang  + Angle(0,180,90)
					backposa = backposa + backang:Right() * 4
					backang = backang + Angle(0,90 + 90 + 90 + 90,90)
				else
					posa = posa + ang:Forward() * 1.5
					ang = ang + Angle(0,90,90)
					backposa = backposa - backang:Forward() * 2
					backang = backang + Angle(0,90+90+90,90)
				end
			    
			    if (targ:getDoorOwner()) then
					doortitle = targ:getDoorData().title
			    	doortext = targ:getDoorOwner():Nick()
			    else
					doorisfree = true
			    	doortext = "Unowned"
			    end
				
				surface.SetFont("Zhud1Font")
				local getmidx, getmidy = surface.GetTextSize(doortext)
				local unownedtextx, unownedtexty = surface.GetTextSize(unownedtext)
				

			    --Drawing in the front of the door
			    cam.Start3D2D( posa, ang,.1 )
					if doorisfree then 
						draw.SimpleText(unownedtext, "Zhud1Font",((door_width * 10) /2) - (unownedtextx * .1) , -80, Color(255,255,255, 255-dist) ) 
						drawcolor = Color(255,43,43, 255-dist) 
					else
						if (doortitle) then
							surface.SetFont("Zhud3Font")
							local titlex, titley = surface.GetTextSize(doortitle)
							draw.SimpleText(doortitle, "Zhud3Font",(door_width_x * 20) - (titlex/2) , -120, Color(255,255,255, 255-dist) ) 
						end
					end
			    	draw.SimpleText(doortext, "Zhud1Font",(door_width_x * 20) - (getmidx/2) , -50, drawcolor)
			    cam.End3D2D()

			    --Drawing in the back of the door
			    cam.Start3D2D( backposa, backang, 0.1 )
				if doorisfree then 
					draw.SimpleText(unownedtext, "Zhud1Font",(-1 * (door_width_x * 20)) - (unownedtextx/2), -80, Color(255,255,255, 255-dist) ) 
					drawcolor = Color(255,43,43, 255-dist) 
				else
					if (doortitle) then
						surface.SetFont("Zhud3Font")
						local titlex, titley = surface.GetTextSize(doortitle)
						draw.SimpleText(doortitle, "Zhud3Font",(-1 * (door_width_x * 20)) - (titlex/2), -120, Color(255,255,255, 255-dist) ) 
					end
				end
			    	draw.SimpleText(doortext, "Zhud1Font", (-1 * (door_width_x * 20)) - (getmidx/2), -50, drawcolor)
			    cam.End3D2D()

			end)
		end

		--Drawing player display
		if dist < 250 and targ:IsPlayer() then
			drawtrans = 255 - dist
			hp = targ:Health()
			armor = targ:Armor()
			smoothedhealth = Lerp(0.1,smoothedhealth,hp)
			smoothedarmor = Lerp(0.1,smoothedarmor,armor)
	    	pos.z = pos.z + 1
	    	pos = pos:ToScreen()
	    		
	    	if not targ:getDarkRPVar("wanted") then      
	        	pos.y = pos.y - 1
	        else
	        	draw.SimpleText("WANTED", "Zhud4Font", pos.x + 135,textpos - 50, Color( 255, 0, 0, drawtrans), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	    	end  

	    	name, plyTeam = targ:Nick(), targ:getDarkRPVar("job")
	    	usergroup = targ:GetNWString("usergroup")

	    	zhud_FormatGroup()

	    	draw.CircleCustom(pos.x + 100,pos.y + 80,10,10,smoothedhealth * 3.6,Color(220,20,60,drawtrans),-30,0 )

	    	if armor > 0 then
	    		textpos = pos.y + 75	
	    		draw.CircleCustom(pos.x + 100,pos.y + 80,3.3,3.3,smoothedarmor * 3.6,Color(65,105,225,drawtrans),-38,0 )
	    		draw.SimpleText(armor, "Zhud5Font", pos.x + 98,pos.y + 90, Color( 255, 255, 255, 255,drawtrans), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	    	else
	    		textpos = pos.y + 80
	    	end

	    	draw.SimpleText(hp, "Zhud4Font", pos.x + 98,textpos, Color( 255, 255, 255, drawtrans), TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
	    	draw.SimpleText(name,"Zhud4Font",pos.x + 140, pos.y + 55, Color(255,255,255,drawtrans),TEXT_ALIGN_LEFT ,TEXT_ALIGN_CENTER)
	    	draw.SimpleText(plyTeam,"Zhud4Font",pos.x + 140, pos.y + 75, Color(255,255,255,drawtrans),TEXT_ALIGN_LEFT ,TEXT_ALIGN_CENTER)
	    	draw.SimpleText(usergroup,"Zhud4Font",pos.x + 140, pos.y + 95, Color(255,255,255,drawtrans),TEXT_ALIGN_LEFT ,TEXT_ALIGN_CENTER)
	    end
	    
	end


end)
