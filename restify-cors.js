function cors(origins, headers) {
    headers = headers ? headers : ['Content-Type'];
    headers = headers.join(' ');

    function _cors(req, res, next) {
        var i = origins.indexOf(req.header('Origin'));
        i = i >= 0 ? i : 0;

        res.setHeader('Access-Control-Allow-Origin', origins[i]);
        res.setHeader('Access-Control-Allow-Headers', headers);
        res.setHeader('Access-Control-Allow-Methods', '*');
        res.setHeader('Access-Control-Max-Age', '1000');

        next();
    }

    return (_cors);
}

module.exports = cors;
