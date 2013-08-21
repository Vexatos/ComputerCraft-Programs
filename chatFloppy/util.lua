-- Helper API for MiscPeripherals integrated programs

-- Gets all peripherals of the specified type
function getPeripherals(typ, amount)
  peripherals = {}
  sides = {}
  if amount == nil then amount = 1000000 end
  
  count = 0
  for _, side in pairs(rs.getSides()) do
    peripheralType = peripheral.getType(side)
    if peripheralType == typ then
      -- Directly attached
      table.insert(peripherals, peripheral.wrap(side))
      table.insert(sides, side)
      count = count + 1
      if count >= amount then
        return peripherals, sides
      end
    elseif peripheralType == "modem" and not peripheral.call(side, "isWireless") then
      -- Look for remote peripherals
      modem = peripheral.wrap(side)
      for _, name in pairs(modem.getNamesRemote()) do
        if modem.getTypeRemote(name) == typ then
          -- Found one
          table.insert(peripherals, wrapRemote(modem, name))
          table.insert(sides, side..":"..name)
          count = count + 1
          if count >= amount then
            return peripherals, sides
          end
        end
      end
    end
  end
  
  return peripherals, sides
end

function getPeripheral(typ)
  resultPeripheral, resultSide = getPeripherals(typ, 1)
  return resultPeripheral[1], resultSide[1]
end

-- Modified version of peripheral.wrap for remote peripherals
function wrapRemote(modem, name)
  result = {}
	methods = modem.getMethodsRemote(name)
  for _, method in pairs(methods) do
    result[method] = function(...)
      return modem.callRemote(name, method, ...)
    end
  end
  return result
end