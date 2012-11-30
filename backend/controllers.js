module.exports = {
    list: function (Model) {
        return function (req, res, next) {
            Model.find(function (err, documents) {
                if (err) {
                    return next(err);
                }

                res.send(documents);
                return next();
            });
        };
    },
    post: function (Model) {
        return function (req, res, next) {
            (new Model(req.body)).save(function (err, document) {
                if (err) {
                    return next(err);
                }

                res.send(document);
                return next();
            });
        }
    }
};
