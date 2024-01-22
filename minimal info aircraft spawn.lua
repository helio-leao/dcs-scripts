-- using hoggit as reference, reduced the info to only the "required" descripted there to spawn one aircraft

local groupData = {

    ["name"] = "Hornet Group-1",
    ["task"] = "CAP",

    ["units"] = {
        [1] = {
            ["name"] = "Hornet Unit-1-1",
            ["type"] = "FA-18C_hornet",
            ["y"] = 00011690,
            ["x"] = 00075875,

            ["alt"] = 3000,
            ["alt_type"] = "BARO",
            ["speed"] = 205,

            ["payload"] = {
                ["pylons"] = {}, -- end of ["pylons"]
                ["fuel"] = 4900,
                ["flare"] = 60,
                ["ammo_type"] = 1,
                ["chaff"] = 60,
                ["gun"] = 100,
            }, -- end of ["payload"]

            ["callsign"] = {
                [1] = 1,
                [2] = 1,
                [3] = 1,
                ["name"] = "Enfield11",
            }, -- end of ["callsign"]
        }, -- end of [1]
    }, -- end of ["units"]

}

coalition.addGroup(country.id.USA, Group.Category.AIRPLANE, groupData)
