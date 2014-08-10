var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var browserify = require('gulp-browserify');
var concat = require('gulp-concat');

gulp.task('coffee', function() {
  gulp.src('./src/**/*.coffee')
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib/'))
});

gulp.task('browser', ['coffee'], function() {
  gulp.src(['./lib/index.js'])
    .pipe(browserify({
      ignore: ['xmlhttprequest', './serialportclient']
    }))
    .pipe(concat('coptermanager-browser.js'))
    .pipe(gulp.dest('./dist'));
});
