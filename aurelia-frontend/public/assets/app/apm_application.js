// Generated by CoffeeScript 1.10.0
(function() {
  var application;

  application = null;

  this.ApmApplication = (function() {
    ApmApplication.initialized = false;

    function ApmApplication(css_id) {
      this.css_id = css_id;
      application = this.setup();
    }

    ApmApplication.prototype.setup = function() {
      console.log("Initializing application");
      this.initialized = true;
      return this;
    };

    return ApmApplication;

  })();

}).call(this);
