Feature: Thrown C++ exceptions are captured by Bugsnag

  Background:
    Given I clear all persistent data

  Scenario: Throwing a C++ exception
    When I run "CxxExceptionScenario" and relaunch the app
    And I configure Bugsnag for "CxxExceptionScenario"
    And I wait to receive a request
    Then the request is valid for the error reporting API version "4.0" for the "OSX Bugsnag Notifier" notifier
    And the exception "errorClass" equals "P16kaboom_exception"
    And the exception "type" equals "cocoa"
    And the payload field "events.0.exceptions.0.stacktrace" is an array with 0 elements
    And the event "severity" equals "error"
    And the event "unhandled" is true
    And the event "severityReason.type" equals "unhandledException"
