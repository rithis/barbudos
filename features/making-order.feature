Feature: Making Order
    In order to fill my stomach
    As a customer
    I want to make an order

    Scenario: Choice some dishes
        Given collection "dishes":
            | name   | price |
            | Meat   | 1     |
            | Milk   | 1     |
            | Banana | 1     |
        When I opened page "/"
        Then I should see "Меню" on the page
        And I should see "Meat" on the page
        And I should see "Milk" on the page
        And I should see "Banana" on the page
