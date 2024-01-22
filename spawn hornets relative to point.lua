-- good way to get the table to configure groups is creating a group doing the same thing is ME, save,
-- open mission file with a text editor, can be visual studio and copying pasting the table. not all
-- info there is required (hoggit can help with this)

SPAWN_GROUP_NAME = 'Hornet'
SPAWN_GROUP_QUANTITY = 1

REFERENCE_UNIT_NAME = 'reference'


-- returns group config table
function createGroupData(x, y, distanceX, distanceY, name)

    local groupData = {

        ["name"] = name .. "-" .. SPAWN_GROUP_QUANTITY,
        ["task"] = "CAP",

        ["route"] = {
            ["points"] = {
                [1] = {
                    ["alt"] = 2000,
                    ["type"] = "Turning Point",
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = y + distanceY,
                    ["x"] = x + distanceX,
                    ["speed"] = 205,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {
                                [1] = {
                                    ["enabled"] = true,
                                    ["key"] = "CAP",
                                    ["id"] = "EngageTargets",
                                    ["number"] = 1,
                                    ["auto"] = true,
                                    ["params"] = {
                                        ["targetTypes"] = {
                                            [1] = "Air"
                                        }, -- end of ["targetTypes"]
                                        ["priority"] = 0
                                    } -- end of ["params"]
                                }, -- end of [1]
                                [2] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 2,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["name"] = 17
                                            } -- end of ["params"]
                                        } -- end of ["action"]
                                    } -- end of ["params"]
                                }, -- end of [2]
                                [3] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 3,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = 4,
                                                ["name"] = 18
                                            } -- end of ["params"]
                                        } -- end of ["action"]
                                    } -- end of ["params"]
                                }, -- end of [3]
                                [4] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 4,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["name"] = 19
                                            } -- end of ["params"]
                                        } -- end of ["action"]
                                    } -- end of ["params"]
                                }, -- end of [4]
                                [5] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 5,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "Option",
                                            ["params"] = {
                                                ["targetTypes"] = {}, -- end of ["targetTypes"]
                                                ["name"] = 21,
                                                ["value"] = "none;",
                                                ["noTargetTypes"] = {
                                                    [1] = "Fighters",
                                                    [2] = "Multirole fighters",
                                                    [3] = "Bombers",
                                                    [4] = "Helicopters",
                                                    [5] = "Infantry",
                                                    [6] = "Fortifications",
                                                    [7] = "Tanks",
                                                    [8] = "IFV",
                                                    [9] = "APC",
                                                    [10] = "Artillery",
                                                    [11] = "Unarmed vehicles",
                                                    [12] = "AAA",
                                                    [13] = "SR SAM",
                                                    [14] = "MR SAM",
                                                    [15] = "LR SAM",
                                                    [16] = "Aircraft Carriers",
                                                    [17] = "Cruisers",
                                                    [18] = "Destroyers",
                                                    [19] = "Frigates",
                                                    [20] = "Corvettes",
                                                    [21] = "Light armed ships",
                                                    [22] = "Unarmed ships",
                                                    [23] = "Submarines",
                                                    [24] = "Cruise missiles",
                                                    [25] = "Antiship Missiles",
                                                    [26] = "AA Missiles",
                                                    [27] = "AG Missiles",
                                                    [28] = "SA Missiles"
                                                } -- end of ["noTargetTypes"]
                                            } -- end of ["params"]
                                        } -- end of ["action"]
                                    } -- end of ["params"]
                                }, -- end of [5]
                                [6] = {
                                    ["enabled"] = true,
                                    ["auto"] = true,
                                    ["id"] = "WrappedAction",
                                    ["number"] = 6,
                                    ["params"] = {
                                        ["action"] = {
                                            ["id"] = "EPLRS",
                                            ["params"] = {
                                                ["value"] = true,
                                                ["groupId"] = 1
                                            } -- end of ["params"]
                                        } -- end of ["action"]
                                    } -- end of ["params"]
                                } -- end of [6]
                            } -- end of ["tasks"]
                        } -- end of ["params"]
                    } -- end of ["task"]
                }, -- end of [1]
                [2] = {
                    ["alt"] = 2000,
                    ["type"] = "Turning Point",
                    ["action"] = "Turning Point",
                    ["alt_type"] = "BARO",
                    ["form"] = "Turning Point",
                    ["y"] = y,
                    ["x"] = x,
                    ["speed"] = 205,
                    ["task"] = {
                        ["id"] = "ComboTask",
                        ["params"] = {
                            ["tasks"] = {} -- end of ["tasks"]
                        } -- end of ["params"]
                    } -- end of ["task"]
                } -- end of [2]
            } -- end of ["points"]
        }, -- end of ["route"]

        ["units"] = {
            [1] = {
                ["name"] = name .. "-" .. SPAWN_GROUP_QUANTITY .. "-1",
                ["type"] = "FA-18C_hornet",
                ["y"] = y + distanceY,
                ["x"] = x + distanceX,

                ["alt"] = 2000,
                ["alt_type"] = "BARO",
                ["speed"] = 205,

                ["callsign"] = {
                    [1] = 1,
                    [2] = 1,
                    [3] = 1,
                    ["name"] = "Enfield11"
                }, -- end of ["callsign"]
                ["payload"] = {
                    ["pylons"] = {
                        [1] = {
                            ["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}"
                        }, -- end of [1]
                        [2] = {
                            ["CLSID"] = "LAU-115_2*LAU-127_AIM-120C"
                        }, -- end of [2]
                        [3] = {
                            ["CLSID"] = "{FPU_8A_FUEL_TANK}"
                        }, -- end of [3]
                        [4] = {
                            ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"
                        }, -- end of [4]
                        [5] = {
                            ["CLSID"] = "{FPU_8A_FUEL_TANK}"
                        }, -- end of [5]
                        [6] = {
                            ["CLSID"] = "{40EF17B7-F508-45de-8566-6FFECC0C1AB8}"
                        }, -- end of [6]
                        [7] = {
                            ["CLSID"] = "{FPU_8A_FUEL_TANK}"
                        }, -- end of [7]
                        [8] = {
                            ["CLSID"] = "LAU-115_2*LAU-127_AIM-120C"
                        }, -- end of [8]
                        [9] = {
                            ["CLSID"] = "{5CE2FF2A-645A-4197-B48D-8720AC69394F}"
                        } -- end of [9]
                    }, -- end of ["pylons"]
                    ["fuel"] = 4900,
                    ["flare"] = 60,
                    ["ammo_type"] = 1,
                    ["chaff"] = 60,
                    ["gun"] = 100
                } -- end of ["payload"]
            } -- end of [1]
        } -- end of ["units"]

    }

    return groupData
end

-- spawn a group of 1 hornet, blue coalition, country usa
function spawnHornetGroup(x, y, distanceX, distanceY, name)
    local groupData = createGroupData(x, y, distanceX, distanceY, name)

    local group = coalition.addGroup(country.id.USA, Group.Category.AIRPLANE, groupData)
    SPAWN_GROUP_QUANTITY = SPAWN_GROUP_QUANTITY + 1

    return group
end


-- test
-- will spawn a hornet group 80km from the x axis of the reference unit, execute is not local so it can be called
-- multiple times in other triggers in game and can maybe being local be called many times by schedulefuntion
-- DO ONE TO GET ALL RED AIRCRAFT GROUPS AND SPAWN ONE HORNET GROUP FOR EACH
function execute()
    local referenceUnitPosition = Unit.getByName(REFERENCE_UNIT_NAME):getPoint()
    local group = spawnHornetGroup(referenceUnitPosition.x, referenceUnitPosition.z, 80000, 0, SPAWN_GROUP_NAME)
    trigger.action.outText(group:getName() .. ' spawned', 10)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------

execute()   -- execution (may be called in another trigger)