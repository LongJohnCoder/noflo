noflo = require "noflo"
base = require "./BasecampComponent"

class ReadTaskLists extends base.BasecampComponent
    constructor: ->
        @project = null

        do @basePortSetup
        @inPorts.project = new noflo.Port()

        @outPorts =
            out: new noflo.Port()

        @inPorts.project.on "data", (data) =>
            @project = data
        @inPorts.project.on "disconnect", =>
            do @readTaskLists if @hostname and @apikey

    readTaskListsAll: ->
        @get "/todo_lists.xml", (data) =>
            @parseTaskLists data

    readTaskLists: ->
        return @readTaskListsAll unless @project

        @get "/projects/#{@project}/todo_lists.xml", (data) =>
            @parseTaskLists data

    parseTaskLists: (data) ->
        target = @outPorts.out
        id = "https://#{@hostname}/"
        @parse data, (parsed) ->
            return unless parsed['todo-list']

            unless toString.call(parsed['todo-list']) is '[object Array]'
                target.send parsed['todo-list'], id
                return target.disconnect()

            target.send taskList, id for taskList in parsed['todo-list']
            target.disconnect()

exports.getComponent = ->
    new ReadTaskLists
