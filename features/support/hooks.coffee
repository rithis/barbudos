module.exports = ->
    this.Before (callback) ->
        this.dropDatabase callback
