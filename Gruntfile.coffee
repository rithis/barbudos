module.exports = (grunt) ->
    grunt.initConfig
        clean:
            docs: "docs"
        simplemocha:
            integration:
                src: "test/integration/*.coffee"
                options: reporter: "spec"
            acceptance:
                src: "test/acceptance/*.coffee"
                options: reporter: "spec"
            options: ignoreLeaks: true
        coffeelint:
            public: "public/scripts/**/*.coffee"
            test: "test/**/*.coffee"
            barbudos: "barbudos.coffee"
            grunt: "Gruntfile.coffee"
            options: indentation: value: 4
        docco:
            all: ["barbudos.coffee", "public/scripts/**/*.coffee"]
            options: output: "docs"

    grunt.registerTask "default", ["clean", "test", "lint", "docs"]
    grunt.registerTask "test", "simplemocha"
    grunt.registerTask "lint", "coffeelint"
    grunt.registerTask "docs", "docco"

    grunt.loadNpmTasks "grunt-contrib-clean"
    grunt.loadNpmTasks "grunt-simple-mocha"
    grunt.loadNpmTasks "grunt-coffeelint"
    grunt.loadNpmTasks "grunt-docco"
