((function() {
    var self, terms;
    self = this;
    terms = require("./terms");
    module.exports = terms.term({
        constructor: function(name) {
            var self;
            self = this;
            self.isIdentifier = true;
            return self.identifier = name;
        },
        arguments: function() {
            var self;
            self = this;
            return void 0;
        }
    });
})).call(this);