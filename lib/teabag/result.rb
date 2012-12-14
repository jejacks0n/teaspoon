module Teabag
  class Result < Struct.new(:teabag_suite,
                            :type,
                            :suite,
                            :spec,
                            :full_description,
                            :status,
                            :skipped,
                            :link,
                            :message,
                            :trace,
                            :elapsed,
                            :failures,
                            :pending,
                            :total)

    def self.build_from_json(suite_name, json)
      new suite_name,
        json["type"],
        json["suite"],
        json["spec"],
        json["full_description"],
        json["status"],
        json["skipped"],
        json["link"],
        json["message"],
        json["trace"],
        json["elapsed"],
        json["failures"],
        json["pending"],
        json["total"]
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
