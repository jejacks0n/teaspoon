module Teaspoon

  RESULT_ATTRS = [
    :type,
    :suite,
    :label,
    :status,
    :skipped,
    :link,
    :message,
    :trace,
    :elapsed,
    :total,
    :start,
    :level,
    :coverage,
    :original_json,
  ]

  class Result < Struct.new(*RESULT_ATTRS)

    def self.build_from_json(json)
      new(*RESULT_ATTRS.map{ |attr| json[attr.to_s] })
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
