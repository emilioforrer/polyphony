# frozen_string_literal: true

require 'bundler/setup'
require 'polyphony'

spin {
  spin {
    spin {
      pp Fiber.current.caller
    }.await
  }.await
}.await