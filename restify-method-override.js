var qs = require('qs');


function methodOverride() {
    function _methodOverride(req, res, next) {
        var q = req.getQuery();
        
        // If the query plugin wasn't used, we need to hack it in now
        if (typeof q === 'string') {
            req.query = qs.parse(q);   
        }

        if (req.query._method) {
            req.method = req.query._method;
        }

        next();
    }

    return (_methodOverride);
}

module.exports = methodOverride;
