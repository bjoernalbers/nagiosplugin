# Nagios::Plugin

A Nagios Plugin framework that fits on a folded napkin.

[![Gem Version](https://badge.fury.io/rb/nagiosplugin.svg)](http://badge.fury.io/rb/nagiosplugin)
[![Build Status](https://secure.travis-ci.org/bjoernalbers/nagiosplugin.png)](http://travis-ci.org/bjoernalbers/nagiosplugin)


## Introduction

*Nagios::Plugin* helps you write [Nagios](http://www.nagios.org/) Plugins with Ruby:
It ensures that your plugin returns a [compliant](http://nagiosplug.sourceforge.net/developer-guidelines.html) exit code and status output.

Besides, it is [easy to understand](https://github.com/bjoernalbers/nagiosplugin/blob/master/lib/nagios/plugin.rb) and comes with automated tests.


## Installation

Via bundler: Add this to your Gemfile and run `bundle install`:

```Ruby
gem 'nagiosplugin'
```

Manually via Rubygems: Run `gem install nagiosplugin`.


## Quick Start

Here, a full working (but totally useless) example plugin named `check_fancy`:

```Ruby
#!/usr/bin/env ruby

require 'nagiosplugin'

# Create your custom plugin as subclass from Nagios::Plugin 
class Fancy < Nagios::Plugin
  # Required method: Is the status critical?
  def critical?
    @number < 3
  end

  # Required method: Is the status warning?
  def warning?
    @number < 5
  end

  # Required method: Is the... I see, you got it.
  def ok?
    @number > 6
  end

  # Optional method that is executed once before determining the status.
  def check
    @number = rand(10)
  end

  # Optional method: The returned stuff will be appended to plugin output.
  def message
    "#{@number} was picked"
  end
end

# Call the build-in class method to display the status and exit properly:
Fancy.run!
```

When you run it you'd something like this:

```
$ check_fancy; echo $?                                                                                                                                  
FANCY CRITICAL: 2 was picked
2
$ check_fancy; echo $?
FANCY UNKNOWN: 6 was picked
3
$ check_fancy; echo $?
FANCY OK: 7 was picked
0
```


## Thinks to remember

- the "worst" status always wins, for example if both `critical?` and
  `warning?` return true then the status would be critical
- `Nagios::Plugin.run!` does a "blind rescue mission" and transforms any
  execptions to an unknown status.
- drink more water!


## Copyright

Copyright (c) 2011-2014 Björn Albers
