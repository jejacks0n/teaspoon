module ExitCodes
  SUCCESS = 0
  EXCEPTION = 1
  MINIMUM_COVERAGE = 2
  MAXIMUM_COVERAGE_DROP = 3

  def stub_exit_code(code)
    `(exit #{code})`
  end
end
