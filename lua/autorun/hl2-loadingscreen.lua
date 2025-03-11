hl2_loadingscreen = hl2_loadingscreen or {}
hl2_loadingscreen.Folder = "hl2_loadingscreen"
hl2_loadingscreen.File = "hl2_loadingscreen.png"
hl2_loadingscreen.Path = hl2_loadingscreen.Folder .. "/" .. hl2_loadingscreen.File
hl2_loadingscreen.ShutDown = hl2_loadingscreen.ShutDown or false
hl2_loadingscreen.Transition = false
if CLIENT then
    if game.SinglePlayer() then
        local lEP, lEA
        hook.Add("PostDrawTranslucentRenderables", "hl2_loadingscreen.PostDrawTranslucentRenderables", function()
            lEP, lEA = EyePos(), EyeAngles() 
        end)
        hook.Add("InitPostEntity", "hl2_loadingscreen.InitPostEntity", function()
            file.Delete(hl2_loadingscreen.Path) 
        end)
        function hl2_loadingscreen:SaveImage()
            if not file.Exists(hl2_loadingscreen.Folder, "DATA") then
                file.CreateDir(hl2_loadingscreen.Folder)
            end
            if file.Exists(hl2_loadingscreen.Path, "DATA") then 
                file.Delete(hl2_loadingscreen.Path) 
            end
            gui.HideGameUI()
            
            render.RenderView({
                  origin = lEP, angles = lEA,
                  x = 0, y = 0,
                  w = ScrW(), h = ScrH(),
                  zfar = 9000;
                  -- do you need FOV? nah lol
                })  
            timer.Simple(0, function()
            local data = render.Capture( {
                format = "png",
                x = 0,
                y = 0,
                w = ScrW(),
                h = ScrH(),
                quality = 70, -- 
                alpha = false, -- only needed for the png format to prevent the depth buffer leaking in, see BUG
            } )
            file.Write(hl2_loadingscreen.Path, data )
            end)
        end
        -- Trying to fix dis but not gonna work at all.
        net.Receive( "hl2_loadingscreen", function( len, ply )
            hl2_loadingscreen:SaveImage()
        end)
    end
end
if SERVER then
    util.AddNetworkString( "hl2_loadingscreen" )
    if game.SinglePlayer() then
        hook.Add( "AcceptInput", "hl2_loadingscreen.AcceptInput", function( ent, name, activator, caller, data )
            if name:lower() == "outsidetransition" and hl2_loadingscreen.Transition == false then
                hl2_loadingscreen.Transition = true
                net.Start( "hl2_loadingscreen" )
                    net.WriteString( "" )
                net.Broadcast()
            end
        end )
    end
end