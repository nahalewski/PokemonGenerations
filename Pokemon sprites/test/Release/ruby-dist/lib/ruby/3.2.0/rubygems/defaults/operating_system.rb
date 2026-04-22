module Gem
  class << self
    alias :old_default_dir :default_dir
    alias :old_default_path :default_path
    alias :old_default_bindir :default_bindir
    alias :old_ruby :ruby
    alias :old_default_specifications_dir :default_specifications_dir
  end

  def self.default_dir
    path = [
      "/opt/homebrew",
      "lib",
      "ruby",
      "gems",
      "3.2.0"
    ]

    @homebrew_path ||= File.join(*path)
  end

  def self.private_dir
    path = if defined? RUBY_FRAMEWORK_VERSION then
             [
               File.dirname(RbConfig::CONFIG['sitedir']),
               'Gems',
               RbConfig::CONFIG['ruby_version']
             ]
           elsif RbConfig::CONFIG['rubylibprefix'] then
             [
              RbConfig::CONFIG['rubylibprefix'],
              'gems',
              RbConfig::CONFIG['ruby_version']
             ]
           else
             [
               RbConfig::CONFIG['libdir'],
               ruby_engine,
               'gems',
               RbConfig::CONFIG['ruby_version']
             ]
           end

    @private_dir ||= File.join(*path)
  end

  def self.default_path
    if Gem.user_home && File.exist?(Gem.user_home)
      [user_dir, default_dir, old_default_dir, private_dir]
    else
      [default_dir, old_default_dir, private_dir]
    end
  end

  def self.default_bindir
    "/opt/homebrew/lib/ruby/gems/3.2.0/bin"
  end

  def self.ruby
    "/opt/homebrew/opt/ruby/bin/ruby"
  end

  # https://github.com/Homebrew/homebrew-core/issues/40872#issuecomment-542092547
  # https://github.com/Homebrew/homebrew-core/pull/48329#issuecomment-584418161
  def self.default_specifications_dir
    File.join(Gem.old_default_dir, "specifications", "default")
  end
end
