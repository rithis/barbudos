module.exports.watch = function (directory, options) {
    var compileProcess,
        spawn = require('child_process').spawn,
        watch = require('watch'),
        fs = require('fs');

    var recompile = function () {
        if (compileProcess) {
            return;
        }

        compileProcess = spawn('compass', [
            'compile',
            '--relative-assets',
            '-s', 'compress',
            '--css-dir', options.css,
            '--sass-dir', options.sass
        ]);

        compileProcess.on('exit', function () {
            compileProcess = null;
        });
    };

    watch.watchTree(directory, function (file) {
        if (typeof file != "object" && /\.scss$/.test(file)) {
            recompile();
        }
    });

    recompile();
};
