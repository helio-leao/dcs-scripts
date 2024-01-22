local groupData = {
    
    ["name"] = "Ground Group",
    ["task"] = "Ground Nothing",

    ["units"] = {
        [1] = {
            ["name"] = "Ground Unit1",
            ["type"] = "LAV-25",
            ["y"] = 00011690,
            ["x"] = 00075875,
        }, -- end of [1]
    }, -- end of ["units"]

}

coalition.addGroup(country.id.USA, Group.Category.GROUND, groupData)
