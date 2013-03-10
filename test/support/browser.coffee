zombie = require "zombie"
_      = require "lodash"


class Browser extends zombie.Browser
  getCategories: ->
    elements = @queryAll ".categories-list-item"
    _.map elements, (element) ->
      element.textContent

  getActiveCategory: ->
    element = @query ".categories-list-item-current"
    element.textContent

  getDishes: ->
    elements = @queryAll ".dishes-item-title"
    _.map elements, (element) ->
      element.textContent

  getDishAmount: (dish) ->
    element = @query "input.amount-input", @queryDishElement dish
    element.value

  pageCotainsText: (text) ->
    nodeSet = @xpath "//*[text()=\"#{text}\"]"
    return false if nodeSet.value.length is 0

    element    = nodeSet.value[0]
    display    = element.style.getPropertyValue "display"
    visibility = element.style.getPropertyValue "visibility"

    display != "none" and visibility != "hidden"

  selectCategory: (category, callback) ->
    @clickLink category, callback

  addDishToCart: (dish, callback) ->
    element = @query "button:contains(В корзину)", @queryDishElement dish
    @fire "click", element, callback

  setDishAmount: (dish, amount, callback) ->
    element = @query "input.amount-input", @queryDishElement dish
    @fill element, amount, callback

  makeOrder: (address, phone, callback) ->
    promise = @fill ".cart-form-address", address
    promise.fill ".cart-form-phone", phone
    promise.pressButton "button.cart-form-submit", callback

  queryDishElement: (dish) ->
    element = @query ".dishes-item-title:contains(#{dish})"
    element.parentNode


createBrowserInstance = (settings) ->
  new Browser settings


module.exports = createBrowserInstance
