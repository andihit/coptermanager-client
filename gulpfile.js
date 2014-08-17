var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var browserify = require('gulp-browserify');
var concat = require('gulp-concat');
var del = require('del');

var paths = {
  coffee: './src/**/*.coffee'
};

gulp.task('clean', function(cb) {
  del(['./lib', './dist'], cb);
});

gulp.task('coffee', ['clean'], function() {
  return gulp.src(paths.coffee)
    .pipe(coffee().on('error', gutil.log))
    .pipe(gulp.dest('./lib/'));
});

gulp.task('watch', function() {
  gulp.watch(paths.coffee, ['coffee']);
});

gulp.task('browserlib', ['coffee'], function() {
  return gulp.src(['./lib/index.js'])
    .pipe(browserify({
      ignore: ['xmlhttprequest', './serialportclient']
    }))
    .on('prebundle', function(bundle) {
      bundle.require('./index.js', {expose: 'coptermanager'});
    })
    .pipe(concat('coptermanager-browser.js'))
    .pipe(gulp.dest('./dist'));
});

gulp.task('copy-browserlib', ['browserlib'], function() {
  return gulp.src('./dist/coptermanager-browser.js')
    .pipe(gulp.dest('../coptermanager_server/apps/coptermanager_web/priv/static-src/external/js'));
});

gulp.task('default', ['coffee', 'browserlib', 'watch']);
