require 'commander'
require 'fastlane/version'


module Firebase
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'firebase'
      program :version, Fastlane::VERSION
      program :description, 'CLI for \'PEM\' - Automatically generate and renew your push notification profiles'
      program :help, 'Author', 'Felix Krause <pem@krausefx.com>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'GitHub', 'https://github.com/fastlane/PEM'
      program :help_formatter, :compact

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }

      command :list do |c|
        c.syntax = 'fastlane firebase list'
        c.description = 'Lists all projects in your firebase'

        FastlaneCore::CommanderGenerator.new.generate(Firebase::Options.available_options, command: c)

        c.action do |args, options|
          Firebase.config = FastlaneCore::Configuration.create(Firebase::Options.available_options, options.__hash__)
          #Firebase::Manager.start
        end
      end

      default_command :list

      run!
    end
  end
end