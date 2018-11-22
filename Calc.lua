
TankHelper.GetUptimePercentage = function( fightDuration , inactiveDuration )
    return ((fightDuration-inactiveDuration)*100)/fightDuration
end

TankHelper.GetCurrentTimeInSeconds = function()
    return GetGameTimeMilliseconds()/1000
end