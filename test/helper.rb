require 'minitest/autorun'
require 'minitest/pride'
require 'kiba'

class Kiba::Test < Minitest::Test
  extend Minitest::Spec::DSL

  def remove_files(*files)
    files.each do |file|
      File.delete(file) if File.exist?(file)
    end
  end

  def fixture(file)
    File.join(File.dirname(__FILE__), 'fixtures', file)
  end
  
  def system!(command)
    fail "Command fail" unless system(command)
  end
end
