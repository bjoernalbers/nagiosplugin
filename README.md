# NagiosPlugin

The one Nagios Plugin framework, forged in the fires of Mount Doom.

[![Gem Version](https://badge.fury.io/rb/nagiosplugin.svg)](http://badge.fury.io/rb/nagiosplugin)
[![Build Status](https://secure.travis-ci.org/bjoernalbers/nagiosplugin.png)](http://travis-ci.org/bjoernalbers/nagiosplugin)

## Introduction

NagiosPlugin is an
[embarrassingly simple](https://github.com/bjoernalbers/nagiosplugin/blob/master/lib/nagiosplugin/plugin.rb)
framework to write custom monitoring plugins for
[Nagios](http://www.nagios.org/).
It was born out of duplication, because all nagios plugins share some
common behaviour...

## Installation

Via bundler: Add this to your Gemfile and run `bundle install`:

```Ruby
gem 'nagiosplugin'
```

Manually via Rubygems: Run `gem install nagiosplugin`.


## Usage

Writing your custom plugin is really simple:

### Step 1: Describe when something is critical, warning and ok.

Create your subclass from `NagiosPlugin::Plugin` and define these
instance methods to determine the status:

```Ruby
require 'nagiosplugin'

class MyFancyPlugin < NagiosPlugin::Plugin
  def critical?
    # Enter your code here (returns true when critical, else false).
  end

  def warning?
    # Enter your code here (returns true when warning, else false).
  end

  def ok?
    # Enter your code... you get the idea.
  end
end
```

**Please keep in mind that the "worst" status always wins, i.e. if both
`critical?` and `warning?` are true then the status would be critical
(if none is true, then the status would be unknown of course)!**

You may use your `initialize` method to setup check data (NagiosPlugin
doesn't use that either), parse CLI options, etc.

### Step 2: Provide some context via status message (optionally).

Ask yourself what might be important to know (and fits into a text
message) when Nagios send you an alert in the middle of the night.

```Ruby
def message
  # Create an info string (this will be printed after the
  # status on stdout).
  # Service name, status and message should be longer than 78 chars!!!
end
```

### Step 3: Perform the actual check.

In your binary then just call the build-in class method `check` and you're done:

```Ruby
MyFancyPlugin.check(options)
```

(Optional arguments, i.e. from your favorite [CLI option
parser](https://www.ruby-toolbox.com/categories/CLI_Option_Parsers), will be
forwarded to you initializer method.)

This will output the check result and exits in compliance with the
official
[Nagios plug-in development
guidelines](http://nagiosplug.sourceforge.net/developer-guidelines.html)

If anything funky happens in your code: NagiosPlugin does a "blind
rescue mission" and transforms any execptions to an unknown status.


## Note on Patches/Pull Requests

* Fork the project and run `bundle install` to resolve all development
  dependencies.
* Add specs and/or features for it. This is important so I don't break
  it in a future version unintentionally.
* Make your feature addition or bug fix.
* Commit, do not mess with the Rakefile or gemspec.
  (If you want to have your own version, that is fine but bump version
in a commit by itself I can ignore when I pull.)
* Send me a pull request. Bonus points for topic branches.


## Acknowledgments

Thanks to the following contributors for improving NagiosPlugin:

* [szuecs (Sandor Szücs)](https://github.com/szuecs)


## Copyright

Copyright (c) 2011-2013 Björn Albers. See LICENSE for details.
