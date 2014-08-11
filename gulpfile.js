var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var browserify = require('gulp-browserify');
var concat = require('gulp-concat');

gulp.task('coffee', function() {
  return gulp.src('./src/**/*.coffee')
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib/'));
});

gulp.task('browserlib', ['coffee'], function() {
  return gulp.src(['./lib/index.js'])
    .pipe(browserify({
      ignore: ['xmlhttprequest', './serialportclient']
    }))
    .on('prebundle', function(bundle) {
      bundle.require('coptermanager');
    })
    .pipe(concat('coptermanager-browser.js'))
    .pipe(gulp.dest('./dist'));
});

gulp.task('copy-browserlib', ['browserlib'], function() {
  return gulp.src('./dist/coptermanager-browser.js')
    .pipe(gulp.dest('../coptermanager_server/apps/coptermanager_web/priv/static/js/lib'));
});
