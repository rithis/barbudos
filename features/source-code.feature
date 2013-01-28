Feature: Check source code
    In order to ensure source code quality
    As a developer
    I want to test source code for problems

    Scenario: Lint coffeescript
        When I run coffeelint for "barbudos.coffee"
        And I run coffeelint for "app"
        And I run coffeelint for "features"
        Then coffeelint should be success
