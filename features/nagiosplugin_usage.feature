Feature: NagiosPlugin Usage

  In order to write Nagios Plugins with Ruby
  As a busy (developer|sysadmin|devop|hacker|superhero|rockstar)
  I want to use the one Nagios Plugin framework.

  Scenario Outline: Subclass from NagiosPlugin
    Given a file named "check_chunky_bacon.rb" with:
      """
      require 'nagiosplugin'

      class ChunkyBacon < Nagios::Plugin
        def critical?
          <critical>
        end

        def warning?
          <warning>
        end

        def ok?
          <ok>
        end

        def message
          42
        end
      end

      ChunkyBacon.run!
      """
    When I run `ruby check_chunky_bacon.rb`
    Then the exit status should be <es>
    And the stdout should contain exactly:
      """
      <stdout>

      """

    Examples:
     | critical | warning | ok    | status   | es | stdout                   |
     | true     | true    | true  | CRITICAL | 2  | CHUNKYBACON CRITICAL: 42 |
     | false    | true    | true  | WARNING  | 1  | CHUNKYBACON WARNING: 42  |
     | false    | false   | true  | OK       | 0  | CHUNKYBACON OK: 42       |
     | false    | false   | false | UNKNOWN  | 3  | CHUNKYBACON UNKNOWN: 42  |
