module.exports = ->
    this.Before '@backend', (callback) ->
        this.spawnBackend callback

    this.After '@backend', (callback) ->
        this.killBackend callback

    this.Before '@browser', (callback) ->
        this.initBrowser callback

    this.Before '@db', (callback) ->
        this.createDatabaseConnection callback

    this.After '@db', (callback) ->
        this.closeDatabaseConnection callback

    this.After (callback) ->
        this.resetCoffeelintStatus callback
