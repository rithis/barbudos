module.exports = function (grunt) {
    'use strict';

    grunt.initConfig({
        bower: {
            dir: 'app/components'
        },
        coffee: {
            compile: {
                files: {
                    'app/scripts/*.js': 'app/scripts/**/*.coffee',
                    'test/spec/*.js': 'test/spec/**/*.coffee'
                }
            }
        },
        compass: {
            dist: {
                options: {
                    css_dir: 'temp/styles',
                    sass_dir: 'app/styles',
                    images_dir: 'app/images',
                    javascripts_dir: 'temp/scripts',
                    force: true
                }
            }
        },
        manifest: {
            dest: 'temp/manifest.appcache'
        },
        watch: {
            coffee: {
                files: 'app/scripts/**/*.coffee',
                tasks: 'coffee reload'
            },
            compass: {
                files: [
                    'app/styles/**/*.scss'
                ],
                tasks: 'compass reload'
            },
            reload: {
                files: [
                    'app/*.html',
                    'app/styles/**/*.css',
                    'app/scripts/**/*.js',
                    'app/views/**/*.html',
                    'app/images/**/*'
                ],
                tasks: 'reload'
            }
        },
        lint: {
            files: [
                'Gruntfile.js',
                'app/scripts/**/*.js',
                'test/spec/**/*.js'
            ]
        },
        jshint: {
            options: {
                curly: true,
                eqeqeq: true,
                immed: true,
                latedef: true,
                newcap: true,
                noarg: true,
                sub: true,
                undef: true,
                boss: true,
                eqnull: true,
                browser: true
            },
            globals: {
                angular: true
            }
        },
        staging: 'temp',
        output: 'dist',
        mkdirs: {
            staging: 'app'
        },
        css: {
            'styles/main.css': ['styles/**/*.css']
        },
        rev: {
            js: 'scripts/**/*.js',
            css: 'styles/**/*.css',
            img: 'images/**'
        },
        'usemin-handler': {
            html: 'index.html'
        },
        usemin: {
            html: ['index.html', 'views/*.html'],
            css: ['styles/*.css']
        },
        html: {
            files: ['**/*.html']
        },
        img: {
            dist: '<config:rev.img>'
        },
        rjs: {
            optimize: 'none',
            baseUrl: './scripts',
            wrap: true
        },
        rsync: {
            "deploy-staging": {
                src: "dist/",
                dest: "/var/www/bar-barbudos.ru",
                host: "www-data@static.rithis.com",
                recursive: true
            }
        }
    });

    grunt.registerTask('test', 'run the testacular test driver', function () {
        var done = this.async();
        require('child_process').exec('testacular start', function (err, stdout) {
            grunt.log.write(stdout);
            done(err);
        });
    });

    grunt.loadNpmTasks("grunt-rsync");

    grunt.registerTask('deploy', 'build rsync');
};
