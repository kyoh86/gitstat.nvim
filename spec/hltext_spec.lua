describe("hltext", function()
    local hltext = require("gitstat.hltext")
    local instance = hltext:new()

    describe("empty", function()
        assert.are.equals("", instance.text)
        assert.are.same({}, instance.columns)
        assert.are.same({}, instance.groups)
    end)

    describe("first one", function()
        instance:add("part1", "val1", {})
        assert.are.equals(" val1 ", instance.text)
        assert.are.same({
            {
                group = "GitStatPart1",
                col_start = 0,
                col_end = 6, -- NOTE: includes padding spaces
            },
        }, instance.columns)
        assert.are.same({ {
            group = "GitStatPart1",
            val = {},
        } }, instance.groups)
    end)

    describe("add difficult style part", function()
        instance:add("part2", "val2", {
            fg = 0,
        })
        assert.are.equals(" val1  val2 ", instance.text)
        assert.are.same({
            {
                group = "GitStatPart1",
                col_start = 0,
                col_end = 6,
            },
            {
                group = "GitStatPart2",
                col_start = 6,
                col_end = 12,
            },
        }, instance.columns)
        assert.are.same({
            {
                group = "GitStatPart1",
                val = {},
            },
            {
                group = "GitStatPart2",
                val = { fg = 0 },
            },
        }, instance.groups)
    end)

    describe("add same style part", function()
        instance:add("part3", "val3", {
            fg = 0,
        })
        assert.are.equals(" val1  val2 val3 ", instance.text)
        assert.are.same({
            {
                group = "GitStatPart1",
                col_start = 0,
                col_end = 6,
            },
            {
                group = "GitStatPart2",
                col_start = 6,
                col_end = 12,
            },
            {
                group = "GitStatPart3",
                col_start = 12,
                col_end = 17,
            },
        }, instance.columns)
        assert.are.same({
            {
                group = "GitStatPart1",
                val = {},
            },
            {
                group = "GitStatPart2",
                val = { fg = 0 },
            },
            {
                group = "GitStatPart3",
                val = { fg = 0 },
            },
        }, instance.groups)
    end)
end)
