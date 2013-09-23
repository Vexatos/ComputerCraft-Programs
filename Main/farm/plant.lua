while true do
  bl = false
  nosp = false
  plce = false
  turtle.select(1)
  plnt = turtle.getItemCount(1)
  if plnt>=2 then
    plce = turtle.place()
    if plce == true then
      print("Planting...")
    end
  else
    print("Not enough saplings!")
  end
  if plce == false then
    bnml = turtle.getItemCount(2)
    if bnml>=2 then
      if turtle.detect() == true then
        turtle.select(1)
        if turtle.compare() == true then
          turtle.select(2)
          turtle.place()
          turtle.select(1)
          print("Bonemealing...")
        else
          print("No sapling detected in front...")
          nosp = true
        end
      else
        if nosp ~= true then
          print("No sapling detected in front...")
        end
      end
    else
      print("Not enough bonemeal!")
    end
  end
  sleep(20)
end