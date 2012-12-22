module Teabag
  class Result < Struct.new(:type, :suite, :label, :status, :skipped, :link, :message, :trace, :elapsed, :total, :start, :level)

    def self.build_from_json(json)
      new json["type"],
          json["suite"],
          json["label"],
          json["status"],
          json["skipped"],
          json["link"],
          json["message"],
          json["trace"],
          json["elapsed"],
          json["total"],
          json["start"],
          json["level"]
    end

    def description
      "#{suite} #{label}"
    end

    def failing?
      (status != "passed" && status != "pending") && type == "spec"
    end

    def passing?
      status == "passed"
    end

    def pending?
      status == "pending"
    end
  end
end
