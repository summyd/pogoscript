((function() {
    var self, terms;
    self = this;
    terms = require("./terms");
    module.exports = terms.term({
        constructor: function(value) {
            var self;
            self = this;
            self.isInteger = true;
            return self.integer = value;
        },
        generateJavaScript: function(buffer, scope) {
            var self;
            self = this;
            return buffer.write(self.integer.toString());
        }
    });
})).call(this);