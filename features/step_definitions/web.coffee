module.exports = ->
    @World = require('../support/world').World

    @When /^I opened page "([^"]*)"$/, (uri, callback) ->
        @visit "http://localhost:3000/#!#{uri}", callback

    @When /^I reload page$/, (callback) ->
        @reload callback

    @When /^I choice category "([^"]*)"$/, (category, callback) ->
        @toCategory category, callback

    @When /^I clicked on button named "([^"]*)" in dish block about "([^"]*)"$/,
        (button, dish, callback) ->
            @clickDishButton dish, button, callback

    @Then /^I should see "([^"]*)" on the page$/, (text, callback) ->
        unless @checkPageContainsText text
            callback.fail new Error "Page doesn't contains text '#{text}'"
        else
            callback()

    @Then /^I should not see "([^"]*)" on the page$/, (text, callback) ->
        if @checkPageContainsText text
            callback.fail new Error "Page contains text '#{text}'"
        else
            callback()

    @Then /^I should see "([^"]*)" as a page title$/, (title, callback) ->
        unless @pageTitleIs title
            callback.fail new Error "Page title not '#{title}'"
        else
            callback()
    
    @Then /^I should see dish "([^"]*)" which "([^"]*)" with price "([^"]*)"$/,
        (name, description, price, callback) ->
            unless @checkPageContainsDish name, description, price
                callback.fail new Error """
                    Page doesn't containes dish '#{name}'
                    with description '#{description}'
                    price #{price}
                    """
            else
                callback()

    @Then /^I should see categories list contains only these categories in right order:$/,
        (categories, callback) ->
            current = []
            for category in categories.hashes() then do (category) ->
                current.push category.name
                
            unless @checkPageCategoriesOrder current
                callback.fail new Error "Categories not ordered right"
            else
                callback()

    @Then /^category "([^"]*)" should be current$/, (category, callback) ->
        unless @categoryIsActive category
            callback.fail new Erorr "Category not active '#{category}'"
        else
            callback()

    @Then /^I should see these dishes:$/, (dishes, callback) ->
        dishExists = @dishExists
        for dish in dishes.hashes() then do (dish) ->
            unless dishExists dish.name
                return callback.fail new Error "Dish not exists '#{dish.name}'"

        callback()

    @Then /^I should see "([^"]*)" in dish "([^"]*)" amount input$/,
        (amount, dish, callback) ->
            unless @dishAmountIs dish, amount
                callback.fail new Error "Dish amount is not #{amount}"

            callback()
