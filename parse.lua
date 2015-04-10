local function shell(p)
  local f=io.popen(p)
  local r=f:read("all")
  f:close()
  return r
end
local f=1
local function frame(o) -- syntax of o: {["OBJECT_NAME"]={["x"]=X,["y"]=Y}}
  shell("ffmpeg -i stuff/blank.png -c:v libx264 -vf fps=25 -pix_fmt yuv420p stuff/temp.mp4")
  for a,b in pairs(o) do
    --ensure file exists
    local file=io.open("stuff/"..a..".png")
    assert(file,"File "..a..".png does not exist")
    file:close()
    shell("ffmpeg -i stuff/temp.mp4 -i stuff/"..a..".png -filter_complex \"[0:v][1:v] overlay="..b.x..":"..b.y.."\" stuff/temp1.mp4")
    shell("mv stuff/temp1.mp4 stuff/temp.mp4")
  end
  shell("ffmpeg -i stuff/temp.mp4 stuff/frames/f"..f..".png")
  shell("rm stuff/temp.mp4")
end
frame{["ballImage"]={["x"]=1,["y"]=5}}
