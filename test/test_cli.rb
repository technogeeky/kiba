require_relative 'helper'
require 'kiba/cli'

class TestCli < Kiba::Test
  def test_cli_launches
    Kiba::Cli.run([fixture('valid.etl')])
  end

  def test_cli_reports_filename_and_lineno
    exception = assert_raises(NameError) do
      Kiba::Cli.run([fixture('bogus.etl')])
    end

    assert_match(/uninitialized constant(.*)UnknownThing/, exception.message)
    assert_includes exception.backtrace.to_s, 'test/fixtures/bogus.etl:2:in'
  end
  
  def test_shell_cli_invokation_runs_at_exit_hook
    test_file = 'at_exit.etl.ran'
    remove_files(test_file)
    assert_raises(RuntimeError, 'Command failed') do
      system! "#{File.dirname(__FILE__)}/../bin/kiba #{fixture('at_exit.etl')} >/dev/null 2>&1"
    end
    assert File.exist?(test_file)
    assert_equal 'Parse error', IO.read(test_file)
  ensure
    remove_files(test_file)
  end
end
