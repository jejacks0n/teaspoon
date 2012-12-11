describe "Teabag.Reporters.NormalizedSpec", ->

  describe "constructor", ->

    describe "with jasmine type spec", ->

      it "has the expected properties"

    describe "with mocha type spec", ->

      it "has the expected properties"


  describe "#errors", ->

    describe "with jasmine type spec", ->

      it "returns the expected object"

    describe "with mocha type spec", ->

      it "returns the expected object"


  describe "#results", ->

    describe "with jasmine type spec", ->

      describe "passing", ->

        it "returns the expected object"

      describe "pending", ->

        it "returns the expected object"

      describe "failing", ->

        it "returns the expected object"

    describe "with mocha type spec", ->

      describe "passing", ->

        it "returns the expected object"

      describe "pending", ->

        it "returns the expected object"

      describe "failing", ->

        it "returns the expected object"



describe "Teabag.Reporters.NormalizedSuite", ->

  describe "constructor", ->

    describe "with jasmine type suite", ->

      it "has the expected properties"

    describe "with mocha type suite", ->

      it "has the expected properties"



describe "Teabag.Reporters.BaseView", ->

  describe "constructor", ->

    it "calls build"


  describe "#build", ->

    it "builds an element"


  describe "#appendTo", ->

    it "appends itself to another element"


  describe "#append", ->

    it "appends an element"


  describe "#createEl", ->

    it "creates an element"
    it "can add a classname to that element"


  describe "#findEl", ->

    it "can find and momoizes an element"


  describe "#setText", ->

    it "sets the innerTEXT of an element"


  describe "#setHtml", ->

    it "sets the innerHTML of an element"


  describe "#setClass", ->

    it "sets the class of an element"
