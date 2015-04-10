local function shell(p)
  print(">"..p)
  local f=io.popen(p)
  local r=f:read("all")
  f:close()
  return r
end
local function explode(div,str) -- credit: http://richard.warburton.it
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end
local function process(n)
    shell("ffmpeg -framerate 1/5 -i "..n..".png -c:v libx264 -pix_fmt yuv420p -r 30 "..n.."_TMP.mp4")
    shell("ffmpeg -i "..n.."_TMP.mp4 -y -vf fade=in:0:30 fade_in_"..n.."_TMP.mp4")
    shell("ffmpeg -i fade_in_"..n.."_TMP.mp4 -y -vf fade=out:120:30 "..n..".mp4")
    shell("ffmpeg -i "..n..".mp4 -c copy -bsf:v h264_mp4toannexb -f mpegts "..n..".ts")
    shell("rm "..n..".mp4;rm "..n.."_TMP.mp4;rm fade_in_"..n.."_TMP.mp4")
end
local files=explode("\n",shell("for file in *.png;do echo ${file%.*};done"))
local script="ffmpeg -r 30 -i \"concat:"
local first=true
for i=1,#files do
  process(files[i])
  script=script..files[i]..".ts"
  if first then first=false else script=script.."|" end
end
script=script.."\" -c copy -bsf:a aac_adtstoasc output.mp4"
shell(script)