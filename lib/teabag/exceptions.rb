module Teabag
  class Failure < Exception; end
  class UnknownSuite < Exception; end
  class RunnerException < Exception; end
  class AssetNotServable < Exception; end
  class EnvironmentNotFound < Exception; end
end
